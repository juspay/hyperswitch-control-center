// Remembers which date preset produced the current range, so a list refresh can move a rolling
// preset (e.g. "Last 30 mins") forward to now while fixed and custom ranges stay untouched.
open LogicUtils

type presetSelection = {
  preset: string,
  startTime: string,
  endTime: string,
}

let filterDateFormat = "YYYY-MM-DDTHH:mm:ss[Z]"
let hourInMs = 3600000.0
let dayInMs = 24.0 *. hourInMs

let defaultRangePresetId = (~range) => `default_last_${range->Int.toString}_days`

let getStorageKey = (~startKey, ~endKey) => `dateRangePreset-${startKey}-${endKey}`

let savePresetSelection = (~startKey, ~endKey, ~preset, ~startTime, ~endTime) => {
  try {
    let value =
      [
        ("preset", preset->JSON.Encode.string),
        ("startTime", startTime->JSON.Encode.string),
        ("endTime", endTime->JSON.Encode.string),
      ]
      ->getJsonFromArrayOfJson
      ->JSON.stringify
    SessionStorage.sessionStorage.setItem(getStorageKey(~startKey, ~endKey), value)
  } catch {
  | _ => ()
  }
}

let getPresetSelection = (~startKey, ~endKey) => {
  try {
    SessionStorage.sessionStorage.getItem(getStorageKey(~startKey, ~endKey))
    ->Nullable.toOption
    ->Option.map(value => {
      let dict = value->safeParse->getDictFromJsonObject
      {
        preset: dict->getString("preset", ""),
        startTime: dict->getString("startTime", ""),
        endTime: dict->getString("endTime", ""),
      }
    })
  } catch {
  | _ => None
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

// Reads the number out of ids such as "last_2_hours" or "default_last_30_days"
let getPresetAmount = (preset, ~prefix, ~suffix) =>
  preset->String.startsWith(prefix) && preset->String.endsWith(suffix)
    ? preset
      ->String.slice(
        ~start=prefix->String.length,
        ~end=preset->String.length - suffix->String.length,
      )
      ->Float.fromString
    : None

// Mirrors Blend's preset formulas (browser-local time) and the custom presets built in
// DateRangePickerAdapter, so a rolled range still matches the preset the user picked.
let getRollingRange = (preset, ~now) => {
  let lastMs = ms => Some((Date.fromTime(now->Date.getTime -. ms), now))
  let fromMidnight = daysAgo => Some((now->getLocalMidnight(~daysAgo), now))

  switch preset {
  | "last30Minutes" => lastMs(0.5 *. hourInMs)
  | "last1Hour" => lastMs(hourInMs)
  | "last6Hours" => lastMs(6.0 *. hourInMs)
  | "last24Hours" => lastMs(24.0 *. hourInMs)
  | "today" => fromMidnight(0)
  | "last7Days" => fromMidnight(6)
  | "last30Days" => fromMidnight(29)
  | "thisMonth" =>
    Some((Date.makeWithYMD(~year=now->Date.getFullYear, ~month=now->Date.getMonth, ~date=1), now))
  | "last6Months" => {
      let sixMonthsAgo = Date.fromTime(now->Date.getTime)
      Date.setMonth(sixMonthsAgo, Date.getMonth(sixMonthsAgo) - 6)
      Some((sixMonthsAgo, now))
    }
  | _ =>
    switch (
      preset->getPresetAmount(~prefix="last_", ~suffix="_hours"),
      preset->getPresetAmount(~prefix="last_", ~suffix="_days"),
      preset->getPresetAmount(~prefix="default_last_", ~suffix="_days"),
    ) {
    | (Some(hours), _, _) => lastMs(hours *. hourInMs)
    | (_, Some(days), _) => lastMs(days *. dayInMs)
    | (_, _, Some(days)) => fromMidnight(days->Float.toInt)
    | _ => None
    }
  }
}

let formatDate = date => date->Date.toISOString->TimeZoneHook.formattedISOString(filterDateFormat)

// The new (start, end) for a refresh, also stored as the preset's latest range. None when the
// range isn't a rolling preset (custom, Yesterday, Last month) or was changed after it was picked.
let getRolledRange = (~filterValueJson, ~startKey, ~endKey) => {
  let currentStart = filterValueJson->getString(startKey, "")
  let currentEnd = filterValueJson->getString(endKey, "")

  switch getPresetSelection(~startKey, ~endKey) {
  | Some({preset, startTime, endTime})
    if currentStart->isSameInstant(startTime) && currentEnd->isSameInstant(endTime) =>
    preset
    ->getRollingRange(~now=Date.make())
    ->Option.map(((start, end)) => (start->formatDate, end->formatDate))
    ->Option.flatMap(((start, end)) => {
      let hasMoved = !(start->isSameInstant(currentStart) && end->isSameInstant(currentEnd))
      if hasMoved {
        savePresetSelection(~startKey, ~endKey, ~preset, ~startTime=start, ~endTime=end)
      }
      hasMoved ? Some((start, end)) : None
    })
  | _ => None
  }
}
