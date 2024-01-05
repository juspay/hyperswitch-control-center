open DateTimeUtils
let textBoxClass = " font-inter-style text-fs-14 leading-5 font-normal text-jp-2-light-gray-2000"
module CustomInputBox = {
  @react.component
  let make = (
    ~input: ReactFinalForm.fieldRenderPropsInput,
    ~placeholder,
    ~isDisabled=false,
    ~type_="text",
    ~inputMode="text",
    ~autoFocus=false,
    ~widthClass="w-full",
    ~fontClassName="text-jp-gray-900 text-body text-opacity-75",
    ~borderClass="h-10 pl-4 border-2 border-jp-gray-700 dark:border-jp-gray-800 border-opacity-25 focus:border-opacity-100 focus:border-blue-800 dark:focus:border-blue-800 rounded-md",
    ~maxLength=100,
    ~setVal,
  ) => {
    let cursorClass = if isDisabled {
      "cursor-not-allowed bg-jp-gray-400 dark:bg-jp-gray-950"
    } else {
      "bg-transparent"
    }
    let placeholder = if isDisabled {
      "To be filled by customer"
    } else {
      placeholder
    }
    let className = `${widthClass} ${cursorClass}
        placeholder-jp-gray-900 placeholder-opacity-50 dark:placeholder-jp-gray-700 dark:placeholder-opacity-50
         ${borderClass}
        focus:text-opacity-100 focus:outline-none dark:text-jp-gray-text_darktheme dark:text-opacity-75 dark:focus:text-opacity-100  ${fontClassName}`
    let value = switch input.value->Js.Json.decodeString {
    | Some(str) => str
    | _ => ""
    }

    <HeadlessUISelectBox
      value={String("")}
      setValue=setVal
      dropDownClass={`w-[216px] h-[296px] overflow-scroll !rounded-lg !shadow-jp-2-xs`}
      textClass=textBoxClass
      dropdownPosition=Right
      closeListOnClick=true
      options={timeOptions->Array.map(str => {
        let item: HeadlessUISelectBox.updatedOptionWithIcons = {
          label: str,
          value: str,
          isDisabled: false,
          leftIcon: NoIcon,
          rightIcon: NoIcon,
          customIconStyle: None,
          customTextStyle: None,
          description: None,
        }
        item
      })}
      className="">
      <input
        className
        name={input.name}
        onBlur={input.onBlur}
        onChange={input.onChange}
        onFocus={input.onFocus}
        value
        disabled={isDisabled}
        placeholder={placeholder}
        type_
        inputMode
        autoFocus
        maxLength
      />
    </HeadlessUISelectBox>
  }
}

@react.component
let make = (
  ~startDate,
  ~endDate,
  ~localStartDate,
  ~disableFutureDates,
  ~todayDate,
  ~todayTime,
  ~localEndDate,
  ~getTimeStringForValue,
  ~isoStringToCustomTimeZone,
  ~setStartDate,
  ~setEndDate,
  ~startTimeStr,
  ~endTimeStr,
) => {
  let todayDateTime = DayJs.getDayJs()
  let time = todayDateTime.format(. "hh:mm:ss a")

  let defaultStartTime =
    endDate == todayDateTime.format(. "YYYY-MM-DD")
      ? time->String.toUpperCase
      : (`${endDate} ${endTimeStr}`->DayJs.getDayJsForString).format(.
          "hh:mm:ss a",
        )->String.toUpperCase

  let (fromTime, setFromTime) = React.useState(_ =>
    (`${startDate} ${startTimeStr}`->DayJs.getDayJsForString).format(.
      "hh:mm:ss a",
    )->String.toUpperCase
  )
  let (toTime, settoTime) = React.useState(_ => defaultStartTime)

  let fromDateJs = startDate->DayJs.getDayJsForString
  let toDateJs = endDate->DayJs.getDayJsForString

  let inputFromDate: ReactFinalForm.fieldRenderPropsInput = {
    name: "fromDate",
    onBlur: _ => (),
    onChange: ev => {
      let value = ReactEvent.Form.target(ev)["value"]
      setFromTime(_ => value)
    },
    onFocus: _ => (),
    value: fromTime->Js.Json.string,
    checked: true,
  }

  let inputtoDate: ReactFinalForm.fieldRenderPropsInput = {
    name: "toDate",
    onBlur: _ => (),
    onChange: ev => {
      let value = ReactEvent.Form.target(ev)["value"]
      settoTime(_ => value)
    },
    onFocus: _ => (),
    value: toTime->Js.Json.string,
    checked: true,
  }

  let setFromTimeDropdown = val => {
    let fromTimeArr = val->String.split(" ")
    let fromTime = `${fromTimeArr
      ->Belt.Array.get(0)
      ->Belt.Option.getWithDefault("12:00")}:00 ${fromTimeArr
      ->Belt.Array.get(1)
      ->Belt.Option.getWithDefault("AM")}`

    setFromTime(_ => fromTime->String.toUpperCase)
  }

  let setToTimeDropdown = val => {
    let toTimeArr = val->String.split(" ")
    let toTime = `${toTimeArr
      ->Belt.Array.get(0)
      ->Belt.Option.getWithDefault("11:59")}:00 ${toTimeArr
      ->Belt.Array.get(1)
      ->Belt.Option.getWithDefault("PM")}`
    settoTime(_ => toTime->String.toUpperCase)
  }

  React.useEffect1(() => {
    let endTime = localEndDate->getTimeStringForValue(isoStringToCustomTimeZone)
    let startDateTime = `${startDate} ${fromTime}`->DayJs.getDayJsForString

    if startDateTime.isValid(.) {
      let startTimeVal = startDateTime.format(. "HH:mm:ss")

      if localStartDate !== "" {
        if disableFutureDates && startDate == todayDate && startTimeVal > todayTime {
          setStartDate(~date=startDate, ~time=todayTime)
        } else if disableFutureDates && startDate == endDate && startTimeVal > endTime {
          ()
        } else {
          setStartDate(~date=startDate, ~time=startTimeVal)
        }
      }
    }
    None
  }, [fromTime])

  React.useEffect1(() => {
    let startTime = localStartDate->getTimeStringForValue(isoStringToCustomTimeZone)
    let endDateTime = `${endDate} ${toTime}`->DayJs.getDayJsForString

    if endDateTime.isValid(.) {
      let endTimeVal = endDateTime.format(. "HH:mm:ss")
      if localEndDate !== "" {
        if disableFutureDates && endDate == todayDate && endTimeVal > todayTime {
          setEndDate(~date=startDate, ~time=todayTime)
        } else if disableFutureDates && startDate == endDate && endTimeVal < startTime {
          ()
        } else {
          setEndDate(~date=endDate, ~time=endTimeVal)
        }
      }
    }

    None
  }, [toTime])

  let updatedFromDate = fromDateJs.isValid(.)
    ? try {
        fromDateJs.format(. "dddd, MMMM DD, YYYY")
      } catch {
      | _error => ""
      }
    : ""

  let updatedToDate = toDateJs.isValid(.)
    ? try {
        toDateJs.format(. "dddd, MMMM DD, YYYY")
      } catch {
      | _error => ""
      }
    : ""

  let dateClass = "text-jp-2-light-gray-1200 text-fs-16 font-normal leading-6 mb-4"

  <div className="w-[328px] px-6 font-inter-style mb-12 pt-4 ">
    <div className="mb-10">
      <div className={dateClass}> {React.string(updatedFromDate)} </div>
      <div className="w-4/12">
        <CustomInputBox
          input=inputFromDate
          fontClassName=textBoxClass
          placeholder="09:00 AM"
          borderClass="h-10 pl-1 border-b border-jp-gray-lightmode_steelgray dark:border-jp-gray-700 border-opacity-75 focus:border-opacity-100 focus:border-blue-800 dark:focus:border-blue-800"
          setVal=setFromTimeDropdown
        />
      </div>
    </div>
    <div>
      <div className=dateClass> {React.string(updatedToDate)} </div>
      <div className="w-4/12">
        <CustomInputBox
          input=inputtoDate
          fontClassName=textBoxClass
          placeholder="11:00 PM"
          borderClass="h-10 pl-1 border-b border-jp-gray-lightmode_steelgray dark:border-jp-gray-700 border-opacity-75 focus:border-opacity-100 focus:border-blue-800 dark:focus:border-blue-800"
          setVal=setToTimeDropdown
        />
      </div>
    </div>
  </div>
}
