external ffInputToSelectInput: ReactFinalForm.fieldRenderPropsInput => ReactFinalForm.fieldRenderPropsCustomInput<
  array<string>,
> = "%identity"

open Calendar
@react.component
let make = (
  ~changeHighlightCellStyle="",
  ~calendarContaierStyle="",
  ~month: option<month>=?,
  ~year: option<int>=?,
  ~onDateClick=?,
  ~count=1,
  ~cellHighlighter=?,
  ~cellRenderer=?,
  ~startDate="",
  ~endDate="",
  ~disablePastDates=true,
  ~disableFutureDates=false,
  ~dateRangeLimit=?,
  ~setShowMsg=?,
  ~secondCalendar=false,
  ~firstCalendar=false,
  ~customDisabledFutureDays=0.0,
  ~allowedDateRange=?,
) => {
  let (hoverdDate, setHoverdDate) = React.useState(_ => "")
  let months = [Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec]
  let _ = onDateClick
  // check whether month and date has value
  let getMonthFromFloat = value => {
    let valueInt = value->Belt.Float.toInt
    months[valueInt]->Belt.Option.getWithDefault(Jan)
  }
  let getMonthInFloat = mon => {
    Array.indexOf(months, mon)->Belt.Float.fromInt
  }
  let getMonthInStr = mon => {
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
  let startMonth = switch month {
  | Some(m) => Belt.Int.toFloat(Belt.Float.toInt(getMonthInFloat(m)))
  | None => {
      let tMonth = Belt.Int.toFloat(Belt.Float.toInt(Js.Date.getMonth(Js.Date.make())))
      disableFutureDates && count > 1 ? tMonth -. 1.0 : tMonth
    }
  }
  let startYear = switch year {
  | Some(y) => Belt.Int.toFloat(y)
  | None => Js.Date.getFullYear(Js.Date.make())
  }
  let (currDateIm, setCurrDate) = React.useState(() =>
    Js.Date.makeWithYM(~year=startYear, ~month=startMonth, ())
  )
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

  let dummyRow = Belt.Array.make(count, 1)
  <div
    className={`flex flex-1 flex-row justify-center overflow-auto bg-jp-gray-50 dark:bg-jp-gray-950 rounded border border-jp-gray-500 dark:border-jp-gray-960 select-none ${calendarContaierStyle}`}>
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
      let showLeft = i == 0 && !secondCalendar

      let showRight = i + 1 == Belt.Array.length(dummyRow) && !firstCalendar
      let monthAndYear = String.concat(
        getMonthInStr(getMonthFromFloat(tempMonth)),
        Belt.Float.toString(tempYear),
      )

      let iconClass = "inline-block text-jp-gray-600 dark:text-jp-gray-text_darktheme dark:text-opacity-25 cursor-pointer"

      <div key={string_of_int(i)}>
        <div className="flex flex-row justify-between items-center p-3">
          {showLeft
            ? <>
                <Icon
                  name="angle-double-left"
                  className=iconClass
                  size=24
                  onClick={_ => handleChangeMonthBy(-12)}
                />
                <Icon
                  name="chevron-left" className=iconClass onClick={_ => handleChangeMonthBy(-1)}
                />
              </>
            : React.null}
          <AddDataAttributes attributes=[("data-calendar-date", monthAndYear)]>
            <div
              className="font-bold text-sm md:text-base text-jp-gray-800 dark:text-jp-gray-text_darktheme dark:text-opacity-75">
              {React.string(monthAndYear)}
            </div>
          </AddDataAttributes>
          {showRight
            ? <>
                <Icon
                  name="chevron-right" className=iconClass onClick={_ => handleChangeMonthBy(1)}
                />
                <Icon
                  name="angle-double-right"
                  className=iconClass
                  size=24
                  onClick={_ => handleChangeMonthBy(12)}
                />
              </>
            : React.null}
        </div>
        <Calendar
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
          ?allowedDateRange
        />
      </div>
    })
    ->React.array}
  </div>
}
