open LogicUtils
open DateRangePresetTypes

let filterDateFormat = "YYYY-MM-DDTHH:mm:ss[Z]"

let formatDateString = date =>
  date->Date.toISOString->TimeZoneHook.formattedISOString(filterDateFormat)

let lastHoursId = ("last_", "_hours")
let lastDaysId = ("last_", "_days")
let defaultDaysId = ("default_last_", "_days")
let lastSixMonthsPresetId = "last6Months"

let makePresetId = ((prefix, suffix), amount) => `${prefix}${amount}${suffix}`

let getPresetAmount = ((prefix, suffix), preset) =>
  preset->String.startsWith(prefix) && preset->String.endsWith(suffix)
    ? preset
      ->String.slice(
        ~start=prefix->String.length,
        ~end=preset->String.length - suffix->String.length,
      )
      ->Float.fromString
    : None

let lastHoursPresetId = hours => lastHoursId->makePresetId(hours->Float.toString)
let lastDaysPresetId = days => lastDaysId->makePresetId(days->Float.toString)
let defaultRangePresetId = (~range) => defaultDaysId->makePresetId(range->Int.toString)

let storageKey = "dateRangePresets"

let getPresetSelections = () =>
  try {
    SessionStorage.sessionStorage.getItem(storageKey)
    ->Nullable.toOption
    ->mapOptionOrDefault(Dict.make(), value => value->safeParse->getDictFromJsonObject)
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

let savePresetSelection = ({startKey, endKey, preset, startTime, endTime}: presetSelection) => {
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

let namedRollingPresets = {
  open DateRangePickerBinding.DateRangePreset
  Dict.fromArray([
    (last30Minutes, LastHours(0.5)),
    (last1Hour, LastHours(1.0)),
    (last6Hours, LastHours(6.0)),
    (last24Hours, LastHours(24.0)),
    (today, SinceMidnight(0)),
    (last7Days, SinceMidnight(6)),
    (last30Days, SinceMidnight(29)),
    (thisMonth, ThisMonth),
    (lastSixMonthsPresetId, LastSixMonths),
  ])
}

let rollingPresetMapper = preset =>
  switch namedRollingPresets->Dict.get(preset) {
  | Some(rollingPreset) => Some(rollingPreset)
  | None =>
    switch (
      lastHoursId->getPresetAmount(preset),
      lastDaysId->getPresetAmount(preset),
      defaultDaysId->getPresetAmount(preset),
    ) {
    | (Some(hours), _, _) => Some(LastHours(hours))
    | (_, Some(days), _) => Some(LastDays(days))
    | (_, _, Some(days)) => Some(SinceMidnight(days->Float.toInt))
    | _ => None
    }
  }

let getRollingRange = (preset, ~now) =>
  switch preset {
  | LastHours(hours) => DateRangeUtils.getLastHoursRange(~now, hours)
  | LastDays(days) => DateRangeUtils.getLastDaysRange(~now, days)
  | SinceMidnight(daysAgo) => (now->getLocalMidnight(~daysAgo), now)
  | ThisMonth => (
      Date.makeWithYMD(~year=now->Date.getFullYear, ~month=now->Date.getMonth, ~date=1),
      now,
    )
  | LastSixMonths => DateRangeUtils.getLastSixMonthsRange(~now)
  }

let getRolledRange = filterValueJson =>
  getPresetSelections()
  ->Dict.valuesToArray
  ->Array.map(json => json->getDictFromJsonObject->itemToObjMapper)
  ->Array.findMap(selection => {
    let currentStart = filterValueJson->getString(selection.startKey, "")
    let currentEnd = filterValueJson->getString(selection.endKey, "")
    let isCurrentRange =
      currentStart->isSameInstant(selection.startTime) &&
        currentEnd->isSameInstant(selection.endTime)

    if isCurrentRange {
      selection.preset
      ->rollingPresetMapper
      ->Option.flatMap(rollingPreset => {
        let (start, end) = rollingPreset->getRollingRange(~now=Date.make())
        let (startTime, endTime) = (start->formatDateString, end->formatDateString)
        let hasMoved = !(
          startTime->isSameInstant(currentStart) && endTime->isSameInstant(currentEnd)
        )
        hasMoved ? Some({...selection, startTime, endTime}) : None
      })
    } else {
      None
    }
  })
