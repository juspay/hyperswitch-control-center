external strToForm: string => ReactEvent.Form.t = "%identity"
@send external focus: Dom.element => unit = "focus"
type focusElement = From | To

let getDateString = (value, isoStringToCustomTimeZone: string => TimeZoneHook.dateTimeString) => {
  try {
    let {year, month, date} = isoStringToCustomTimeZone(value)
    `${year}-${month}-${date}`
  } catch {
  | _error => ""
  }
}

let months: array<InfraCalendar.month> = [
  Jan,
  Feb,
  Mar,
  Apr,
  May,
  Jun,
  Jul,
  Aug,
  Sep,
  Oct,
  Nov,
  Dec,
]

let getMonthInStr = (mon: InfraCalendar.month) => {
  switch mon {
  | Jan => "January, "
  | Feb => "February, "
  | Mar => "March, "
  | Apr => "April, "
  | May => "May, "
  | Jun => "June, "
  | Jul => "July, "
  | Aug => "August, "
  | Sep => "September, "
  | Oct => "October, "
  | Nov => "November, "
  | Dec => "December, "
  }
}

let getMonthFromFloat = value => {
  let valueInt = value->Belt.Float.toInt
  months[valueInt]->Belt.Option.getWithDefault(Jan)
}

let ifDateCanFitInTheRange = (start, end) => {
  let getDate = date => {
    let datevalue = Js.Date.makeWithYMD(
      ~year=Js.Float.fromString(date[0]->Belt.Option.getWithDefault("")),
      ~month=Js.Float.fromString(
        Js.String2.make(Js.Float.fromString(date[1]->Belt.Option.getWithDefault("")) -. 1.0),
      ),
      ~date=Js.Float.fromString(date[2]->Belt.Option.getWithDefault("")),
      (),
    )
    datevalue
  }
  let startDate = getDate(Js.String2.split(start, "-"))
  let endDate = getDate(Js.String2.split(end, "-"))
  startDate <= endDate
}

let defaultCellHighlighter = (_): InfraCalendar.highlighter => {
  {
    highlightSelf: false,
    highlightLeft: false,
    highlightRight: false,
  }
}

@react.component
let make = (
  ~setIsDropdownExpanded as _,
  ~disablePastDates,
  ~disableFutureDates,
  ~showTime,
  ~changeCalendarVisibility,
  ~changeStartDate: (
    ~hour: string=?,
    ~min: string=?,
    ~sec: string=?,
    ~ele: Js.String2.t,
    unit,
  ) => unit,
  ~changeEndDate: (
    ~hour: string=?,
    ~min: string=?,
    ~sec: string=?,
    ~ele: Js.String2.t,
    unit,
  ) => unit,
  ~startDate,
  ~endDate,
) => {
  let (monthYearListVisibility, setMonthYearListVisibility) = React.useState(_ => false)
  let (elementInFocus, setElementInFocus) = React.useState(_ => From)
  let fromEl = React.useRef(Js.Nullable.null)
  let toEl = React.useRef(Js.Nullable.null)
  let (calendarStartDate, setCalendarStartDate) = React.useState(_ => "")
  let (calendarEndDate, setCalendarEndDate) = React.useState(_ => "")

  let startMonth = Belt.Int.toFloat(
    Belt.Float.toInt(Js.Date.getMonth(startDate->Js.Date.fromString)),
  )

  let startYear = Js.Date.getFullYear(startDate->Js.Date.fromString)

  let (currDateIm, setCurrDate) = React.useState(() =>
    Js.Date.makeWithYM(~year=startYear, ~month=startMonth, ())
  )

  let buttonIcon = if monthYearListVisibility {
    "angle-up"
  } else {
    "angle-down"
  }

  let handleChangeMonthBy = month => {
    let currDateTemp = Js.Date.fromFloat(Js.Date.valueOf(currDateIm))
    let newDate = Js.Date.fromFloat(
      Js.Date.setMonth(
        currDateTemp,
        Belt.Int.toFloat(Belt.Float.toInt(Js.Date.getMonth(currDateTemp)) + month),
      ),
    )
    setCurrDate(_ => newDate)
  }

  let resetCalendar = _ => {
    setCalendarStartDate(_ => startDate)
    setCalendarEndDate(_ => endDate)
  }

  let onDateClick = str => {
    if elementInFocus === From {
      let dateCheck = calendarEndDate == "" ? endDate : calendarEndDate
      if ifDateCanFitInTheRange(str, dateCheck) {
        setCalendarStartDate(_ => str)
        setElementInFocus(_ => To)
      }
      toEl.current->Js.Nullable.toOption->Belt.Option.forEach(input => input->focus)->ignore
    } else if elementInFocus === To {
      let dateCheck = calendarStartDate == "" ? startDate : calendarStartDate
      if ifDateCanFitInTheRange(dateCheck, str) {
        setCalendarEndDate(_ => str)
      }
    }
  }

  React.useEffect0(() => {
    fromEl.current->Js.Nullable.toOption->Belt.Option.forEach(input => input->focus)
    setElementInFocus(_ => From)
    None
  })

  <div
    className={`w-max bg-white dark:bg-jp-gray-950 dark:text-jp-gray-text_darktheme border dark:border-jp-gray-960 shadow-md text text-jp-gray-700`}>
    {
      let currDateTemp = Js.Date.fromFloat(Js.Date.valueOf(currDateIm))
      let tempDate = Js.Date.setMonth(
        currDateTemp,
        Belt.Int.toFloat(Belt.Float.toInt(Js.Date.getMonth(currDateTemp))),
      )
      let tempMonth = Js.Date.getMonth(Js.Date.fromFloat(tempDate))
      let tempYear = Js.Date.getFullYear(Js.Date.fromFloat(tempDate))

      <span className="flex flex-row justify-between px-4 pt-4  rounded rounded-b-none">
        <span className=" inline-block pb-3">
          <div onClick={_ => setMonthYearListVisibility(v => !v)} className=" flex cursor-pointer">
            <p className={`px-2 text-small font-semibold whitespace-pre`}>
              {Js.String2.concat(
                getMonthInStr(getMonthFromFloat(tempMonth)),
                Belt.Float.toString(tempYear),
              )->React.string}
            </p>
            <div className={`items-center flex px-1`}>
              <Icon size=14 name=buttonIcon />
            </div>
          </div>
        </span>
        <span className="flex gap-2">
          <span
            onClick={_ => {
              handleChangeMonthBy(-1)
              setCurrDate(_ => Js.Date.makeWithYM(~year=tempYear, ~month=tempMonth -. 1.0, ()))
            }}
            className="cursor-pointer">
            <span className="inline-block">
              <Icon name="chevron-left" size=14 />
            </span>
          </span>
          <span
            onClick={_ => {
              handleChangeMonthBy(1)
              setCurrDate(_ => Js.Date.makeWithYM(~year=tempYear, ~month=tempMonth +. 1.0, ()))
            }}
            className="cursor-pointer">
            <span className="inline-block">
              <Icon name="chevron-right" size=14 />
            </span>
          </span>
        </span>
      </span>
    }
    <InfraCalendarList
      cellHighlighter=defaultCellHighlighter
      startDate={calendarStartDate == "" ? startDate : calendarStartDate}
      endDate={calendarEndDate == "" ? endDate : calendarEndDate}
      onDateClick
      disablePastDates
      disableFutureDates
      monthYearListVisibility
      handleChangeMonthBy
      currDateIm
      setCurrDate
    />
    <div className={showTime ? "block" : "hidden"}>
      <div className="flex justify-between items-center dark:text-jp-gray-text_darktheme">
        <div
          ref={ReactDOM.Ref.domRef(fromEl)}
          className={`w-full flex flex-col cursor-pointer p-2 border-2 ${elementInFocus === From
              ? "border-blue-800"
              : ""} outline-none`}
          onClick={_ => setElementInFocus(_ => From)}>
          <label> {"From"->React.string} </label>
          <div className="text-jp-gray-950 dark:text-jp-gray-text_darktheme">
            {(calendarStartDate == "" ? startDate : calendarStartDate)->React.string}
          </div>
        </div>
        <div
          className={`w-full flex flex-col cursor-pointer p-2 border-2 ${elementInFocus === To
              ? "border-blue-800"
              : ""} outline-none`}
          ref={ReactDOM.Ref.domRef(toEl)}
          onClick={_ => setElementInFocus(_ => To)}>
          <label> {"To"->React.string} </label>
          <div className="text-jp-gray-950 dark:text-jp-gray-text_darktheme">
            {(calendarEndDate == "" ? endDate : calendarEndDate)->React.string}
          </div>
        </div>
      </div>
    </div>
    {monthYearListVisibility
      ? <div className="flex gap-2 flex-row p-3 rounded align-center justify-end rounded-t-none">
          <Button
            text="Cancel"
            buttonType=Secondary
            buttonState=Normal
            buttonSize=Small
            onClick={_ => Js.log("Click")}
          />
          <Button
            text="Done"
            buttonType=Primary
            buttonSize=Small
            onClick={_ => setMonthYearListVisibility(_ => false)}
          />
        </div>
      : <div className="flex gap-2 flex-row p-3 rounded align-center justify-end rounded-t-none">
          <Button
            text="Reset"
            buttonType=Secondary
            buttonState={calendarStartDate == "" && calendarEndDate == "" ? Disabled : Normal}
            buttonSize=Small
            onClick={resetCalendar}
          />
          <Button
            text="Apply Range"
            buttonType=Primary
            buttonState={calendarStartDate == "" && calendarEndDate == "" ? Disabled : Normal}
            buttonSize=Small
            onClick={_ev => {
              let endDateCheck = calendarEndDate == "" ? endDate : calendarEndDate
              changeEndDate(~ele=endDateCheck, ())
              let startDateCheck = calendarStartDate == "" ? startDate : calendarStartDate
              changeStartDate(~ele=startDateCheck, ())
              changeCalendarVisibility()
            }}
          />
        </div>}
  </div>
}
