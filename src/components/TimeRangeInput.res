external intToFormEvent: int => ReactEvent.Form.t = "%identity"

open TimeRangeInputUtils
module BaseTimeComponent = {
  @react.component
  let make = (~value, ~setVal, ~fontStyle="") => {
    let passedTime = Js.String2.slice(~from=0, ~to_=5, value)
    let splitValue = Js.String2.split(passedTime, ":")
    let defaultHour = switch Belt.Array.get(splitValue, 0) {
    | Some(a) => a == "" ? "12" : a
    | None => "01"
    }
    let defaultMinute = switch Belt.Array.get(splitValue, 1) {
    | Some(a) => a
    | None => "00"
    }
    let getMeridianFromValue = Js.String2.slice(~from=5, ~to_=value->Js.String2.length, value)
    let defaultMeridian = switch getMeridianFromValue->Js.String2.length {
    | 0 => "am"
    | _ => getMeridianFromValue
    }

    let hoursArr = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
    let minutesArr = ["00", "15", "29", "30", "45", "59"]
    let ampmArr = SelectBox.makeUpdatedOptions(["AM", "PM"], ["am", "pm"])

    let (hours, setHours) = React.useState(() => defaultHour)
    let (min, setMin) = React.useState(() => defaultMinute)
    let (ampm, setAmpm) = React.useState(() => defaultMeridian)

    React.useEffect3(() => {
      setVal(`${hours}:${min}${ampm}`)
      None
    }, (hours, min, ampm))

    let handleHourChange = ev => {
      let target = ev->ReactEvent.Form.target
      let value = target["value"]
      setHours(value)
    }

    let handleMinChange = ev => {
      let target = ev->ReactEvent.Form.target
      let value = target["value"]
      setMin(value)
    }
    let handleAmpmChange = ev => {
      let target = ev->ReactEvent.Form.target
      let value = target["value"]
      setAmpm(value)
    }

    <div className="flex w-min">
      <select
        name="hours"
        value={hours}
        onChange=handleHourChange
        className={`bg-transparent appearance-none outline-none ${fontStyle}`}>
        {hoursArr
        ->Js.Array2.mapi((item: string, i) => {
          <option key={string_of_int(i)} value=item> {React.string(item)} </option>
        })
        ->React.array}
      </select>
      <span className="mx-0.5"> {React.string(":")} </span>
      <select
        name="minutes"
        value={min}
        onChange={handleMinChange}
        className={`bg-transparent appearance-none outline-none mr-3 ${fontStyle}`}>
        {minutesArr
        ->Js.Array2.mapi((item: string, i) => {
          <option key={string_of_int(i)} value=item> {React.string(item)} </option>
        })
        ->React.array}
      </select>
      <select
        name="ampm"
        value={ampm}
        onChange={handleAmpmChange}
        className={`bg-transparent appearance-none outline-none ${fontStyle}`}>
        {ampmArr
        ->Js.Array2.mapi((item: SelectBox.dropdownOption, i) => {
          <option key={string_of_int(i)} value={item.value}> {React.string(item.label)} </option>
        })
        ->React.array}
      </select>
    </div>
  }
}

let getTimein24Format = time => {
  let temptime2 = if Js.String2.includes(time, "am") {
    let temp = Js.String2.split(time, "am")
    let temp2 = Js.String2.split(temp[0]->Belt.Option.getWithDefault(""), ":")
    let mins = temp2[1]->Belt.Option.getWithDefault("")
    let hour = temp2[0]->Belt.Option.getWithDefault("")
    if hour == "12" {
      Js.String2.split(`00:${mins}`, ":")
    } else {
      Js.String2.split(temp[0]->Belt.Option.getWithDefault(""), ":")
    }
  } else {
    let temp = Js.String2.split(time, "pm")
    let temp2 = Js.String2.split(temp[0]->Belt.Option.getWithDefault(""), ":")
    let mins = temp2[1]->Belt.Option.getWithDefault("")
    let hour = switch Belt.Int.fromString(temp2[0]->Belt.Option.getWithDefault("")) {
    | Some(a) => a != 12 ? Belt.Int.toString(a + 12) : Belt.Int.toString(a)
    | None => ""
    }
    Js.String2.split(`${hour}:${mins}`, ":")
  }
  temptime2
}

type valType = {start: string, end: string}
external ffInputToStringInput: ReactFinalForm.fieldRenderPropsInput => ReactFinalForm.fieldRenderPropsCustomInput<
  string,
> = "%identity"
let getTimein12Format = time => {
  let arr = Js.String2.split(time, ":")
  let hr = switch Belt.Int.fromString(arr[0]->Belt.Option.getWithDefault("00")) {
  | Some(a) => a
  | None => 0
  }
  let minutePart = arr[1]->Belt.Option.getWithDefault("00")
  let amPm = hr >= 12 ? "pm" : "am"

  let hourPart = {
    let newHours = if hr === 0 {
      12
    } else if hr > 12 {
      hr - 12
    } else {
      hr
    }
    newHours->Js.Int.toString->padZeroes2
  }
  `${hourPart}:${minutePart}${amPm}`
}

@react.component
let make = (~fieldsArray: array<ReactFinalForm.fieldRenderProps>) => {
  let customTimezoneToISOString = TimeZoneHook.useCustomTimeZoneToIsoString()
  let isoStringToCustomTimeZone = TimeZoneHook.useIsoStringToCustomTimeZone()

  let durationAmount = ReactFinalForm.useField("rule_dsl.schedule.duration_amount").input

  let startDate =
    (
      fieldsArray[0]->Belt.Option.getWithDefault(ReactFinalForm.fakeFieldRenderProps)
    ).input->ffInputToStringInput
  let endDate =
    (
      fieldsArray[1]->Belt.Option.getWithDefault(ReactFinalForm.fakeFieldRenderProps)
    ).input->ffInputToStringInput

  let startDateValue = startDate.value
  let endDateValue = endDate.value

  let getTimefromStartandEndDate = date => {
    let customTimeZone = isoStringToCustomTimeZone(date)
    if Js.String2.length(date) > 0 {
      let convertedStr = getTimein12Format(
        `${customTimeZone.hour}:${customTimeZone.minute}:${customTimeZone.second}`,
      )
      convertedStr
    } else {
      "12:00:am"
    }
  }
  let intStartTime = getTimefromStartandEndDate(startDate.value->Js.String2.make)
  let intEndTime = getTimefromStartandEndDate(endDate.value->Js.String2.make)
  let (val, setVal) = React.useState(_ => {
    start: {
      startDate.value->Js.String2.make != "" ? intStartTime : "12:00am"
    },
    end: {
      endDate.value->Js.String2.make != "" ? intEndTime : "11:59pm"
    },
  })

  let updateDuration = (stSec, endSec) => {
    let diffOfstartAndEnd = if endSec >= stSec {
      endSec - stSec
    } else {
      endSec - stSec + 86400
    }
    durationAmount.onChange(diffOfstartAndEnd->intToFormEvent)
  }

  let changeStart = a => {
    let startDateTime = isoStringToCustomTimeZone(startDate.value->Js.String2.make)
    let formattedTime = getTimein24Format(a)
    let startDateTimeCheck = customTimezoneToISOString(
      startDateTime.year,
      startDateTime.month,
      startDateTime.date,
      formattedTime[0]->Belt.Option.getWithDefault("00"),
      formattedTime[1]->Belt.Option.getWithDefault("00"),
      "00",
    )

    let startTimeInSec = getDateTimeInSec(startDateTimeCheck)
    let endTimeInSec = getDateTimeInSec(endDateValue->LogicUtils.getStringFromJson(""))
    updateDuration(startTimeInSec, endTimeInSec)
    startDate.onChange(startDateTimeCheck)
    setVal(prev => {start: a, end: prev.end})
  }
  let changeEnd = a => {
    let endDateTime = isoStringToCustomTimeZone(endDate.value->Js.String2.make)
    let formattedTime = getTimein24Format(a)
    let endDateTimeCheck = customTimezoneToISOString(
      endDateTime.year,
      endDateTime.month,
      endDateTime.date,
      formattedTime[0]->Belt.Option.getWithDefault("00"),
      formattedTime[1]->Belt.Option.getWithDefault("00"),
      "00",
    )
    let startTimeInSec = getDateTimeInSec(startDateValue->LogicUtils.getStringFromJson(""))
    let endTimeInSec = getDateTimeInSec(endDateTimeCheck)
    updateDuration(startTimeInSec, endTimeInSec)

    endDate.onChange(endDateTimeCheck)
    setVal(prev => {start: prev.start, end: a})
  }
  let time = `${val.start}  "-" ${val.end}`
  <AddDataAttributes attributes=[("data-time-range", time)]>
    <div className="flex p-3 w-min border border-jp-gray-500 rounded-lg">
      <div className="flex items-center mr-2">
        <Icon size=16 name="clock" className="" />
      </div>
      <div className="w-2" />
      <BaseTimeComponent value=val.start setVal=changeStart />
      <div className="flex items-center mr-3 ml-3">
        <Icon size=16 name="arrow-right" className="stroke-current stroke-0" />
      </div>
      <BaseTimeComponent value=val.end setVal=changeEnd />
    </div>
  </AddDataAttributes>
}
