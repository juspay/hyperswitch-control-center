// Remembers which preset produced the current date range so a list refresh can roll presets
// like "Last 30 mins" forward to now, while fixed and custom ranges stay untouched.
open LogicUtils

type presetSelection = {
  startKey: string,
  endKey: string,
  preset: string,
  startTime: string,
  endTime: string,
}

let filterDateFormat = "YYYY-MM-DDTHH:mm:ss[Z]"

let defaultRangePresetId = (~range) => `default_last_${range->Int.toString}_days`

// One sessionStorage entry keyed by `startKey:endKey`
let storageKey = "dateRangePresets"

let getPresetSelections = () =>
  try {
    SessionStorage.sessionStorage.getItem(storageKey)
    ->Nullable.toOption
    ->Option.mapOr(Dict.make(), value => value->safeParse->getDictFromJsonObject)
  } catch {
  | _ => Dict.make()
  }

let itemToObjMapper = dict => {
  startKey: dict->getString("startKey", ""),
  endKey: dict->getString("endKey", ""),
  preset: dict->getString("preset", ""),
  startTime: dict->getString("startTime", ""),
  endTime: dict->getString("endTime", ""),
}

let savePresetSelection = (~startKey, ~endKey, ~preset, ~startTime, ~endTime) => {
  try {
    let selections = getPresetSelections()
    selections->Dict.set(
      `${startKey}:${endKey}`,
      [
        ("startKey", startKey->JSON.Encode.string),
        ("endKey", endKey->JSON.Encode.string),
        ("preset", preset->JSON.Encode.string),
        ("startTime", startTime->JSON.Encode.string),
        ("endTime", endTime->JSON.Encode.string),
      ]->getJsonFromArrayOfJson,
    )
    SessionStorage.sessionStorage.setItem(
      storageKey,
      selections->JSON.Encode.object->JSON.stringify,
    )
  } catch {
  | _ => ()
  }
}

let toEpochSeconds = dateString => {
  let ms = dateString->Date.fromString->Date.getTime
  ms->Float.isNaN ? None : Some(Math.floor(ms /. 1000.0))
}

let isSameInstant = (a, b) =>
  switch (a->toEpochSeconds, b->toEpochSeconds) {
  | (Some(x), Some(y)) => x === y
  | _ => false
  }

let getLocalMidnight = (now, ~daysAgo) =>
  Date.makeWithYMD(
    ~year=now->Date.getFullYear,
    ~month=now->Date.getMonth,
    ~date=now->Date.getDate - daysAgo,
  )

// Reads the number out of ids like "last_2_hours" or "default_last_30_days"
let getPresetAmount = (preset, ~prefix, ~suffix) =>
  preset->String.startsWith(prefix) && preset->String.endsWith(suffix)
    ? preset
      ->String.slice(
        ~start=prefix->String.length,
        ~end=preset->String.length - suffix->String.length,
      )
      ->Float.fromString
    : None

// Recomputes a preset's range at `now` with the same formulas the picker uses (local time)
let getRollingRange = (preset, ~now) => {
  let lastHours = hours => Some(DateRangeUtils.getLastHoursRange(~now, hours))
  let fromMidnight = daysAgo => Some((now->getLocalMidnight(~daysAgo), now))

  switch preset {
  | "last30Minutes" => lastHours(0.5)
  | "last1Hour" => lastHours(1.0)
  | "last6Hours" => lastHours(6.0)
  | "last24Hours" => lastHours(24.0)
  | "today" => fromMidnight(0)
  | "last7Days" => fromMidnight(6)
  | "last30Days" => fromMidnight(29)
  | "thisMonth" =>
    Some((Date.makeWithYMD(~year=now->Date.getFullYear, ~month=now->Date.getMonth, ~date=1), now))
  | "last6Months" => Some(DateRangeUtils.getLastSixMonthsRange(~now))
  | _ =>
    switch (
      preset->getPresetAmount(~prefix="last_", ~suffix="_hours"),
      preset->getPresetAmount(~prefix="last_", ~suffix="_days"),
      preset->getPresetAmount(~prefix="default_last_", ~suffix="_days"),
    ) {
    | (Some(hours), _, _) => lastHours(hours)
    | (_, Some(days), _) => Some(DateRangeUtils.getLastDaysRange(~now, days))
    | (_, _, Some(days)) => fromMidnight(days->Float.toInt)
    | _ => None
    }
  }
}

let formatDate = date => date->Date.toISOString->TimeZoneHook.formattedISOString(filterDateFormat)

// New values for the date filter keys when the current range is a rolling preset that has
// moved since it was picked. None for custom or fixed ranges, or ranges edited after picking.
let getRolledRange = filterValueJson =>
  getPresetSelections()
  ->Dict.valuesToArray
  ->Array.map(json => json->getDictFromJsonObject->itemToObjMapper)
  ->Array.findMap(({startKey, endKey, preset, startTime, endTime}) => {
    let currentStart = filterValueJson->getString(startKey, "")
    let currentEnd = filterValueJson->getString(endKey, "")

    if currentStart->isSameInstant(startTime) && currentEnd->isSameInstant(endTime) {
      preset
      ->getRollingRange(~now=Date.make())
      ->Option.map(((start, end)) => (start->formatDate, end->formatDate))
      ->Option.flatMap(((start, end)) => {
        let hasMoved = !(start->isSameInstant(currentStart) && end->isSameInstant(currentEnd))
        if hasMoved {
          savePresetSelection(~startKey, ~endKey, ~preset, ~startTime=start, ~endTime=end)
        }
        hasMoved ? Some(Dict.fromArray([(startKey, start), (endKey, end)])) : None
      })
    } else {
      None
    }
  })
