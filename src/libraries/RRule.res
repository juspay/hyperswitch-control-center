type recurrenceFrequency =
  | Daily
  | Weekly
  | Monthly
  | Yearly
type recurrenceRule = {
  frequency: recurrenceFrequency,
  interval: int,
  byDay: option<array<int>>,
  byDate: option<array<int>>,
  byWeek: option<array<int>>,
  byMonth: option<array<int>>,
  byYear: option<array<int>>,
}

type durationUnit =
  | Second
  | Minute
  | Hour
  | Day

type scheduleRuleRecipe = {
  recurrence: option<recurrenceRule>,
  dateWhitelist: option<array<Js.Date.t>>,
  dateBlacklist: option<array<Js.Date.t>>,
  durationUnit: durationUnit,
  durationAmount: int,
}

let durationSeconds: (durationUnit, int) => int = (dUnit, dAmount) => {
  switch dUnit {
  | Second => dAmount
  | Minute => dAmount * 60
  | Hour => dAmount * 60 * 60
  | Day => dAmount * 60 * 60 * 24
  }
}

let isScheduled: (scheduleRuleRecipe, Js.Date.t, Js.Date.t, Js.Date.t) => bool = (
  recipe,
  startTime,
  endTime,
  currentTime,
) => {
  //check if date in date blacklist
  let getDay = date => {
    Belt.Float.toInt(Js.Date.getDay(date))
  }
  let byDay = switch recipe.recurrence {
  | Some(recur) =>
    switch recur.byDay {
    | Some(days) => {
        let day = getDay(currentTime)
        switch days->Array.find(x => x == day) {
        | Some(_a) => true
        | None => false
        }
      }

    | None => true
    }
  | None => true
  }
  let getDate = date => {
    Belt.Float.toInt(Js.Date.getDate(date))
  }

  let byDate = switch recipe.recurrence {
  | Some(recur) =>
    switch recur.byDate {
    | Some(days) => {
        let day = getDate(currentTime)
        switch days->Array.find(x => x == day) {
        | Some(_a) => true
        | None => false
        }
      }

    | None => true
    }
  | None => true
  }
  let getMonth = date => {
    Belt.Float.toInt(Js.Date.getMonth(date))
  }

  let byMonth = switch recipe.recurrence {
  | Some(recur) =>
    switch recur.byMonth {
    | Some(days) => {
        let day = getMonth(currentTime)
        switch days->Array.find(x => x == day) {
        | Some(_a) => true
        | None => false
        }
      }

    | None => true
    }
  | None => true
  }
  let getYear = date => {
    Belt.Float.toInt(Js.Date.getFullYear(date))
  }

  let byYear = switch recipe.recurrence {
  | Some(recur) =>
    switch recur.byYear {
    | Some(days) => {
        let day = getYear(currentTime)
        switch days->Array.find(x => x == day) {
        | Some(_a) => true
        | None => false
        }
      }

    | None => true
    }
  | None => true
  }

  let getWeek = date => {
    // let dat = getDate(date)
    // let da = getDay(date)
    // let a = Js.Math.ceil_int(Belt.Int.toFloat(dat + da)) / 7
    // a + 1
    let firstWeekDay = Js.Date.makeWithYMD(
      ~year=Js.Date.getFullYear(date),
      ~month=Js.Date.getMonth(date),
      ~date=1.0,
      (),
    )
    let offsetDate =
      Belt.Int.fromFloat(Js.Date.getDate(date)) +
      Belt.Int.fromFloat(Js.Date.getDay(firstWeekDay)) - 1
    Js.Math.floor_int(Belt.Float.fromInt(offsetDate / 7)) + 1
  }
  let byWeek = switch recipe.recurrence {
  | Some(recur) =>
    switch recur.byWeek {
    | Some(days) => {
        let day = getWeek(currentTime)
        switch days->Array.find(x => x == day) {
        | Some(_a) => true
        | None => false
        }
      }

    | None => true
    }
  | None => true
  }

  let frequencyCheck = switch recipe.recurrence {
  | Some(recur) =>
    if recur.interval === 0 {
      false
    } else {
      switch recur.frequency {
      | Yearly => mod(getYear(currentTime) - getYear(startTime), recur.interval) == 0
      | Monthly =>
        mod(
          (currentTime->DayJs.getDayJsForJsDate).diff(. Js.Date.toString(startTime), "month"),
          recur.interval,
        ) == 0
      | Weekly =>
        mod(
          (currentTime->DayJs.getDayJsForJsDate).diff(. Js.Date.toString(startTime), "week"),
          recur.interval,
        ) == 0
      | Daily =>
        mod(
          (currentTime->DayJs.getDayJsForJsDate).diff(. Js.Date.toString(startTime), "day"),
          recur.interval,
        ) == 0
      }
    }
  | None => true
  }

  let rest =
    startTime <= currentTime &&
    currentTime <= endTime &&
    byDay &&
    byDate &&
    byMonth &&
    byYear &&
    byWeek &&
    frequencyCheck

  let isWhitelist = rest => {
    switch recipe.dateWhitelist {
    | Some(whitelist) =>
      switch whitelist->Array.find(x => x == currentTime) {
      | Some(_a) => true
      | None => rest
      }
    | None => rest
    }
  }
  let isBlackList = rest => {
    switch recipe.dateBlacklist {
    | Some(blacklist) =>
      switch blacklist->Array.find(x => x == currentTime) {
      | Some(_a) => false
      | None => rest
      }
    | None => rest
    }
  }
  isWhitelist(isBlackList(rest))
}
