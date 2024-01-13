open DateTimeUtils
external ffInputToSelectInput: ReactFinalForm.fieldRenderPropsInput => ReactFinalForm.fieldRenderPropsCustomInput<
  array<string>,
> = "%identity"

open NewCalendar
@react.component
let make = (
  ~forwardRef as _=?,
  ~changeHighlightCellStyle="",
  ~calendarContaierStyle="",
  ~month: option<month>=?,
  ~year: option<int>=?,
  ~onDateClick=?,
  ~changeEndDate=?,
  ~changeStartDate=?,
  ~count=1,
  ~cellHighlighter=?,
  ~cellRenderer=?,
  ~startDate="",
  ~endDate="",
  ~showTime=false,
  ~disablePastDates=true,
  ~disableFutureDates=false,
  ~dateRangeLimit=?,
  ~setShowMsg=?,
  ~secondCalendar=false,
  ~firstCalendar=false,
  ~customDisabledFutureDays=0.0,
) => {
  let (fromDate, setFromDate) = React.useState(_ => "")
  let (toDate, setToDate) = React.useState(_ => "")
  let (fromDateOnFocus, setFromDateOnFocus) = React.useState(_ => false)
  let (toDateOnFocus, setToDateOnFocus) = React.useState(_ => false)
  let (isDateClicked, setIsDateClicked) = React.useState(_ => false)

  let startYear = switch year {
  | Some(y) => Belt.Int.toFloat(y)
  | None => Js.Date.getFullYear(Js.Date.make())
  }
  React.useEffect2(() => {
    let fromDateJs = fromDate->DayJs.getDayJsForString
    let toDateJs = toDate->DayJs.getDayJsForString
    let permittedMaxYears = startYear->Belt.Float.toInt + 10
    let updatedFromDate =
      fromDate != "" &&
      fromDate->String.length >= 5 &&
      fromDateJs.isValid(.) &&
      fromDateJs.year(.) <= permittedMaxYears
        ? try {
            fromDateJs.format(. "YYYY-MM-DD")
          } catch {
          | _error => ""
          }
        : ""
    let updatedToDate =
      toDate != "" &&
      toDate->String.length >= 5 &&
      toDateJs.isValid(.) &&
      toDateJs.year(.) <= permittedMaxYears
        ? try {
            toDateJs.format(. "YYYY-MM-DD")
          } catch {
          | _error => ""
          }
        : ""

    if updatedFromDate != "" && updatedFromDate != startDate {
      switch changeStartDate {
      | Some(changeStartDate) => changeStartDate(updatedFromDate, false, false, None)
      | None => ()
      }
    }

    if (
      updatedFromDate != "" &&
      updatedToDate != "" &&
      updatedToDate != endDate &&
      toDateJs >= fromDateJs
    ) {
      switch changeEndDate {
      | Some(changeEndDate) => changeEndDate(updatedToDate, false, None)
      | None => ()
      }
    }

    None
  }, (fromDate, toDate))

  React.useEffect2(() => {
    if startDate != "" && !fromDateOnFocus {
      setFromDate(_ => (startDate->DayJs.getDayJsForString).format(. "MMM DD, YYYY"))
    }
    if endDate != "" && !toDateOnFocus {
      setToDate(_ => (endDate->DayJs.getDayJsForString).format(. "MMM DD, YYYY"))
    } else {
      setToDate(_ => "")
    }
    None
  }, (fromDateOnFocus, toDateOnFocus))

  React.useEffect1(() => {
    if isDateClicked {
      if startDate != "" && !fromDateOnFocus {
        setFromDate(_ => (startDate->DayJs.getDayJsForString).format(. "MMM DD, YYYY"))
      }
      if endDate != "" && !toDateOnFocus {
        setToDate(_ => (endDate->DayJs.getDayJsForString).format(. "MMM DD, YYYY"))
      } else {
        setToDate(_ => "")
      }
      setIsDateClicked(_ => false)
    }
    None
  }, [isDateClicked])

  let (hoverdDate, setHoverdDate) = React.useState(_ => "")

  let _ = onDateClick
  // check whether month and date has value
  let getMonthFromFloat = value => {
    let valueInt = value->Belt.Float.toInt
    months->Belt.Array.get(valueInt)->Belt.Option.getWithDefault(Jan)
  }
  let getMonthInFloat = mon => {
    Array.indexOf(months, mon)->Belt.Float.fromInt
  }

  let startMonth = switch month {
  | Some(m) => Belt.Int.toFloat(Belt.Float.toInt(getMonthInFloat(m)))
  | None => {
      let tMonth = Belt.Int.toFloat(Belt.Float.toInt(Js.Date.getMonth(Js.Date.make())))
      disableFutureDates && count > 1 ? tMonth -. 1.0 : tMonth
    }
  }

  let (currDateIm, _setCurrDate) = React.useState(() =>
    Js.Date.makeWithYM(~year=startYear, ~month=startMonth, ())
  )

  let dummyRow = Belt.Array.make(count, 1)
  <div
    className={`flex flex-1 flex-row justify-center overflow-auto select-none ${calendarContaierStyle}`}>
    {dummyRow
    ->Array.mapWithIndex((_item, i) => {
      let currDateTemp = Js.Date.fromFloat(Js.Date.valueOf(currDateIm))
      let tempDate = Js.Date.setMonth(
        currDateTemp,
        Belt.Int.toFloat(Belt.Float.toInt(Js.Date.getMonth(currDateTemp)) + i),
      )
      let tempMonth = if disableFutureDates {
        (Js.Date.fromFloat(tempDate)->DayJs.getDayJsForJsDate).toString(.)
        ->Js.Date.fromString
        ->Js.Date.getMonth
      } else {
        Js.Date.getMonth(Js.Date.fromFloat(tempDate))
      }
      let tempYear = Js.Date.getFullYear(Js.Date.fromFloat(tempDate))

      let inputFromDate: ReactFinalForm.fieldRenderPropsInput = {
        name: "fromDate",
        onBlur: _ => setFromDateOnFocus(_ => false),
        onChange: ev => {
          let value = ReactEvent.Form.target(ev)["value"]
          setFromDate(_ => value)
        },
        onFocus: _ => setFromDateOnFocus(_ => true),
        value: fromDate->Js.Json.string,
        checked: true,
      }

      let inputtoDate: ReactFinalForm.fieldRenderPropsInput = {
        name: "toDate",
        onBlur: _ => setToDateOnFocus(_ => false),
        onChange: ev => {
          let value = ReactEvent.Form.target(ev)["value"]
          setToDate(_ => value)
        },
        onFocus: _ => setToDateOnFocus(_ => true),
        value: toDate->Js.Json.string,
        checked: true,
      }

      let topPadding = !showTime ? "pt-6" : ""

      <div key={string_of_int(i)}>
        <div className={`flex flex-row justify-between items-center px-6 pb-5 ${topPadding}`}>
          <TextInput
            customDashboardClass="h-11 text-base font-normal shadow-jp-2-xs"
            customStyle="!text-[#344054] font-inter-style"
            input=inputFromDate
            placeholder="From"
          />
          <div
            className="font-normal text-base text-jp-gray-800 dark:text-jp-gray-text_darktheme dark:text-opacity-75 px-4">
            {React.string("-")}
          </div>
          <TextInput
            customDashboardClass="h-11 text-base font-normal shadow-jp-2-xs"
            customStyle="!text-[#344054] font-inter-style"
            input=inputtoDate
            placeholder="To"
          />
        </div>
        <NewCalendar
          key={string_of_int(i)}
          month={getMonthFromFloat(tempMonth)}
          year={Belt.Float.toInt(tempYear)}
          showTitle=false
          hoverdDate
          setHoverdDate
          ?cellHighlighter
          ?cellRenderer
          ?onDateClick
          startDate
          endDate
          disablePastDates
          disableFutureDates
          changeHighlightCellStyle
          ?dateRangeLimit
          ?setShowMsg
          customDisabledFutureDays
          setIsDateClicked
        />
      </div>
    })
    ->React.array}
  </div>
}
