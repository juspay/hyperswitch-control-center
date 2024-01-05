open DateTimeUtils
type highlighter = {
  highlightSelf: bool,
  highlightLeft: bool,
  highlightRight: bool,
}

module TableRow = {
  let defaultCellHighlighter = _ => {
    highlightSelf: false,
    highlightLeft: false,
    highlightRight: false,
  }
  let defaultCellRenderer = obj => {
    switch obj {
    | Some(a) => {
        let day = String.split(a, "-")
        React.string(day->Belt.Array.get(2)->Belt.Option.getWithDefault(""))
      }

    | None => React.string("")
    }
  }

  @react.component
  let make = (
    ~changeHighlightCellStyle="",
    ~item,
    ~month,
    ~year,
    ~rowIndex,
    ~onDateClick,
    ~cellHighlighter=defaultCellHighlighter,
    ~cellRenderer=defaultCellRenderer,
    ~startDate="",
    ~endDate="",
    ~hoverdDate,
    ~setHoverdDate,
    ~disablePastDates=true,
    ~disableFutureDates=false,
    ~customDisabledFutureDays=0.0,
    ~dateRangeLimit=?,
    ~setShowMsg=?,
    ~windowIndex,
    ~setIsDateClicked=?,
  ) => {
    let customTimezoneToISOString = TimeZoneHook.useCustomTimeZoneToIsoString()
    let highlight = cellHighlighter

    {
      if item == Belt.Array.make(7, "") {
        <tr className="h-0" />
      } else {
        <>
          <tr className="transition duration-300 ease-in-out">
            {item
            ->Array.mapWithIndex((obj, cellIndex) => {
              let date =
                customTimezoneToISOString(
                  String.make(year),
                  String.make(month +. 1.0),
                  String.make(obj == "" ? "01" : obj),
                  "00",
                  "00",
                  "00",
                )->Js.Date.fromString
              let dateToday = Js.Date.make()
              let todayInitial = Js.Date.setHoursMSMs(
                dateToday,
                ~hours=0.0,
                ~minutes=0.0,
                ~seconds=0.0,
                ~milliseconds=0.0,
                (),
              )
              let isInCustomDisable = if customDisabledFutureDays > 0.0 {
                date->Js.Date.getTime -. todayInitial <=
                  customDisabledFutureDays *. 24.0 *. 3600.0 *. 1000.0
              } else {
                false
              }
              let isFutureDate = if disablePastDates {
                todayInitial -. date->Js.Date.getTime <= 0.0
              } else {
                todayInitial -. date->Js.Date.getTime < 0.0
              }

              let isInLimit = switch dateRangeLimit {
              | Some(limit) =>
                if startDate !== "" {
                  date->Js.Date.getTime -. startDate->Js.Date.fromString->Js.Date.getTime <
                    ((limit->Js.Int.toFloat -. 1.) *. 24. *. 60. *. 60. -. 60.) *. 1000.
                } else {
                  true
                }
              | None => true
              }

              let onClick = _evt => {
                switch setIsDateClicked {
                | Some(setIsDateClicked) => setIsDateClicked(_ => true)
                | _ => ()
                }
                let isClickDisabled =
                  (endDate === "" && !isInLimit) ||
                  (isFutureDate ? disableFutureDates : disablePastDates) ||
                  (customDisabledFutureDays > 0.0 && isInCustomDisable)
                switch !isClickDisabled {
                | true =>
                  switch onDateClick {
                  | Some(fn) =>
                    fn((Js.Date.toISOString(date)->DayJs.getDayJsForString).format(. "YYYY-MM-DD"))

                  | None => ()
                  }
                | false => ()
                }
              }
              let hSelf = highlight(
                (Js.Date.toString(date)->DayJs.getDayJsForString).format(. "YYYY-MM-DD"),
              )

              let dayClass = if (
                (isFutureDate && disableFutureDates) ||
                customDisabledFutureDays > 0.0 && isInCustomDisable ||
                !isFutureDate && disablePastDates ||
                (endDate === "" && !isInLimit)
              ) {
                "cursor-not-allowed"
              } else {
                "cursor-default"
              }
              let getDate = date => {
                let datevalue = Js.Date.makeWithYMD(
                  ~year=Js.Float.fromString(
                    date->Belt.Array.get(0)->Belt.Option.getWithDefault("0"),
                  ),
                  ~month=Js.Float.fromString(
                    String.make(
                      Js.Float.fromString(
                        date->Belt.Array.get(1)->Belt.Option.getWithDefault("0"),
                      ) -. 1.0,
                    ),
                  ),
                  ~date=Js.Float.fromString(
                    date->Belt.Array.get(2)->Belt.Option.getWithDefault(""),
                  ),
                  (),
                )
                datevalue
              }
              let today = (Js.Date.make()->Js.Date.toString->DayJs.getDayJsForString).format(.
                "YYYY-MM-DD",
              )

              let renderingDate = (
                getDate([Belt.Float.toString(year), Belt.Float.toString(month +. 1.0), obj])
                ->Js.Date.toString
                ->DayJs.getDayJsForString
              ).format(. "YYYY-MM-DD")
              let isTodayHighlight =
                today == renderingDate && startDate != today && endDate != today
              let textColor = isTodayHighlight
                ? "bg-jp-2-light-primary-100 rounded-full"
                : "text-jp-gray-900 text-opacity-75 dark:text-opacity-75"
              let classN = `h-10 w-10 p-0  text-center ${textColor}  dark:text-jp-gray-text_darktheme  ${dayClass}`

              let selectedcellClass = `h-10 w-10 flex flex-1 justify-center items-center bg-blue-800 bg-opacity-100 dark:bg-blue-800 dark:bg-opacity-100 text-white rounded-full `
              let c2 = obj != "" && hSelf.highlightSelf ? selectedcellClass : "h-10 w-10"

              let shouldHighlight = (startDate, endDate, obj, month, year) => {
                let cellSelectedHiglight = "h-full w-full flex flex-1 justify-center items-center  dark:bg-opacity-100 text-gray-600 dark:text-gray-400"
                let cellHoverHighlight = `h-full w-full flex flex-1 justify-center items-center  dark:bg-opacity-100`

                if startDate != "" {
                  let parsedStartDate = getDate(String.split(startDate, "-"))

                  let zObj = getDate([year, month, obj])

                  if obj != "" {
                    let z = getDate([year, month, obj])
                    if endDate != "" {
                      let parsedEndDate = getDate(String.split(endDate, "-"))
                      z == parsedStartDate
                        ? selectedcellClass
                        : z == parsedEndDate
                        ? selectedcellClass
                        : z > parsedStartDate && z < parsedEndDate
                        ? `${cellSelectedHiglight} bg-jp-2-light-primary-100  dark:bg-jp-2-dark-primary-100 ${cellIndex == 0
                            ? "rounded-l-full"
                            : ""} ${cellIndex == 6 ? "rounded-r-full" : ""}`
                        : "h-full w-full"
                    } else if z == parsedStartDate {
                      `${selectedcellClass} ${changeHighlightCellStyle}`
                    } else if (
                      hoverdDate != "" &&
                      endDate == "" &&
                      z > parsedStartDate &&
                      z <= hoverdDate->Js.Date.fromString &&
                      !(
                        (isFutureDate && disableFutureDates) ||
                        !isFutureDate && disablePastDates ||
                        (endDate === "" && !isInLimit)
                      )
                    ) {
                      `${cellHoverHighlight} bg-jp-2-light-primary-100 dark:bg-jp-2-dark-primary-100 ${cellIndex == 0
                          ? "rounded-l-full"
                          : ""} ${cellIndex == 6 ? "rounded-r-full" : ""}`
                    } else {
                      "h-full w-full"
                    }
                  } else if endDate != "" {
                    let parsedEndDate = getDate(String.split(endDate, "-"))

                    zObj > parsedStartDate && zObj < parsedEndDate
                      ? `${cellSelectedHiglight}
                      ${cellIndex == 0
                            ? "bg-gradient-to-r from-jp-2-light-primary-100/0 to-jp-2-light-primary-100/100"
                            : cellIndex == 6
                            ? "bg-gradient-to-r from-jp-2-light-primary-100/100 to-jp-2-light-primary-100/0"
                            : "bg-jp-2-light-primary-100  dark:bg-jp-2-dark-primary-100 "}
                      
                       `
                      : "h-full w-full "
                  } else if (
                    hoverdDate != "" &&
                    endDate == "" &&
                    zObj > parsedStartDate &&
                    zObj <= hoverdDate->Js.Date.fromString &&
                    !(
                      (isFutureDate && disableFutureDates) ||
                      !isFutureDate && disablePastDates ||
                      (endDate === "" && !isInLimit)
                    )
                  ) {
                    `${cellHoverHighlight}
                      ${cellIndex == 0
                        ? "bg-gradient-to-r from-jp-2-light-primary-100/0 to-jp-2-light-primary-100/100"
                        : cellIndex == 6
                        ? "bg-gradient-to-r from-jp-2-light-primary-100/100 to-jp-2-light-primary-100/0"
                        : "bg-jp-2-light-primary-100  dark:bg-jp-2-dark-primary-100 "}
                      
                       `
                  } else {
                    "h-full w-full"
                  }
                } else {
                  "h-full w-full"
                }
              }

              let shouldHighlightBackground = (startDate, endDate, obj, month, year) => {
                if startDate != "" && obj != "" {
                  let parsedStartDate = getDate(String.split(startDate, "-"))
                  let z = getDate([year, month, obj])
                  if endDate != "" {
                    let parsedEndDate = getDate(String.split(endDate, "-"))
                    z == parsedStartDate && parsedStartDate != parsedEndDate
                      ? "bg-jp-2-light-primary-100 dark:bg-jp-2-dark-primary-100  rounded-l-full hover:rounded-l-full"
                      : z == parsedEndDate && parsedStartDate != parsedEndDate
                      ? "bg-jp-2-light-primary-100 dark:bg-jp-2-dark-primary-100  rounded-r-full  hover:rounded-r-full flex justify-between"
                      : ""
                  } else if hoverdDate != "" && z == parsedStartDate {
                    "bg-jp-2-light-primary-100 dark:bg-jp-2-dark-primary-100  rounded-l-full hover:rounded-l-full"
                  } else {
                    ""
                  }
                } else {
                  ""
                }
              }

              let highlightBgClass = {
                shouldHighlightBackground(
                  startDate,
                  endDate,
                  obj,
                  Belt.Float.toString(month +. 1.0),
                  Belt.Float.toString(year),
                )
              }

              let c3 = {
                shouldHighlight(
                  startDate,
                  endDate,
                  obj,
                  Belt.Float.toString(month +. 1.0),
                  Belt.Float.toString(year),
                )
              }
              let handleHover = () => {
                let date = (Js.Date.toString(date)->DayJs.getDayJsForString).format(. "YYYY-MM-DD")
                let parsedDate = getDate(String.split(date, "-"))
                setHoverdDate(_ => parsedDate->Js.Date.toString)
                switch setShowMsg {
                | Some(setMsg) =>
                  if (
                    hoverdDate !== "" &&
                      ((!isInLimit && endDate === "" && !isFutureDate && disableFutureDates) ||
                        (!disableFutureDates && !isInLimit && endDate === ""))
                  ) {
                    setMsg(_ => true)
                  } else {
                    setMsg(_ => false)
                  }
                | None => ()
                }
              }

              <td
                key={`${windowIndex->Belt.Int.toString}X${cellIndex->Belt.Int.toString}`}
                className={`${classN} ${highlightBgClass} text-sm font-normal`}
                onClick
                onMouseOver={_ => handleHover()}
                onMouseOut={evt => setHoverdDate(_ => "")}>
                <AddDataAttributes
                  attributes=[
                    (
                      "data-calender-date",
                      hSelf.highlightSelf || startDate != "" ? "selected" : "normal",
                    ),
                    (
                      "data-calender-date-disabled",
                      (isFutureDate && disableFutureDates) ||
                      customDisabledFutureDays > 0.0 && isInCustomDisable ||
                      !isFutureDate && disablePastDates ||
                      (endDate === "" && !isInLimit)
                        ? "disabled"
                        : "enabled",
                    ),
                  ]>
                  <span
                    className={`${startDate == "" ? c2 : c3} ${isTodayHighlight
                        ? "flex flex-col justify-center items-center pl-0.5"
                        : ""}`}>
                    {cellRenderer(
                      obj == ""
                        ? None
                        : Some(
                            (Js.Date.toString(date)->DayJs.getDayJsForString).format(. "YYYY-MM-D"),
                          ),
                    )}
                    {isTodayHighlight
                      ? <div className="bg-blue-900 h-1.5 w-1.5 rounded-full" />
                      : React.null}
                  </span>
                </AddDataAttributes>
              </td>
            })
            ->React.array}
          </tr>
          {rowIndex < 5 ? <tr className="h-1" /> : React.null}
        </>
      }
    }
  }
}

@react.component
let make = (
  ~changeHighlightCellStyle="",
  ~month,
  ~year,
  ~onDateClick=?,
  ~hoverdDate,
  ~setHoverdDate,
  ~showTitle=true,
  ~cellHighlighter=?,
  ~cellRenderer=?,
  ~highLightList as _=?,
  ~startDate="",
  ~endDate="",
  ~disablePastDates=true,
  ~disableFutureDates=false,
  ~dateRangeLimit=?,
  ~setShowMsg=?,
  ~showHead=true,
  ~customDisabledFutureDays=0.0,
  ~isFutureDate=true,
  ~setIsDateClicked=?,
) => {
  let heading = ["Sun", "Mon", "Tue", "Wed", "Thr", "Fri", "Sat"]

  let isMobileView = MatchMedia.useMobileChecker()
  let getMonthInFloat = mon => Array.indexOf(months, mon)->Belt.Float.fromInt
  let totalMonths = disablePastDates
    ? 1
    : (year - 1970) * 12 + getMonthInFloat(month)->Belt.Float.toInt + 1
  let futureMonths = isFutureDate && !disableFutureDates ? 120 : 0
  let (lastStartDate, setLastStartDate) = React.useState(_ => "")

  let fn = React.useRef((_, _) => ())
  let getMonthInStr = mon => {
    switch mon {
    | Jan => "January "
    | Feb => "February "
    | Mar => "March "
    | Apr => "April "
    | May => "May "
    | Jun => "June "
    | Jul => "July "
    | Aug => "August "
    | Sep => "September "
    | Oct => "October "
    | Nov => "November "
    | Dec => "December "
    }
  }

  let handleExpand = (index, string) => fn.current(index, string)

  React.useEffect0(() => {
    handleExpand(totalMonths - 1, "center")
    None
  })

  React.useEffect2(() => {
    let currentMonth = getMonthInFloat(month)->Belt.Float.toInt + 1

    if startDate != lastStartDate {
      let startYear = startDate != "" ? (startDate->DayJs.getDayJsForString).format(. "YYYY") : ""
      let startMonth =
        (startDate != "" ? (startDate->DayJs.getDayJsForString).format(. "MM") : "")
        ->Belt.Int.fromString
        ->Belt.Option.getWithDefault(currentMonth)
      let startYearDiff = year - startYear->Belt.Int.fromString->Belt.Option.getWithDefault(2022)

      let startIndex = 12 * startYearDiff + (currentMonth - startMonth)

      if startDate != "" {
        handleExpand(totalMonths - startIndex - 1, "center")
      }
      setLastStartDate(_ => startDate)
    } else {
      let endYear = endDate != "" ? (endDate->DayJs.getDayJsForString).format(. "YYYY") : ""
      let endMonth =
        (endDate != "" ? (endDate->DayJs.getDayJsForString).format(. "MM") : "")
        ->Belt.Int.fromString
        ->Belt.Option.getWithDefault(currentMonth)
      let endYearDiff = year - endYear->Belt.Int.fromString->Belt.Option.getWithDefault(2022)

      let endIndex = 12 * endYearDiff + (currentMonth - endMonth)

      if endDate != "" {
        handleExpand(totalMonths - endIndex - 1, "center")
      }
    }
    None
  }, (startDate, endDate))

  let rows = index => {
    let windowIndex = totalMonths - index->LogicUtils.getInt("index", 0) - 1
    let newMonth = DayJs.getDayJs().subtract(. windowIndex, "month").month(.)
    let newYear = DayJs.getDayJs().subtract(. windowIndex, "month").year(.)
    let updatedMonth = months->Belt.Array.get(newMonth)->Belt.Option.getWithDefault(Jan)
    // get first day

    let firstDay = Js.Date.getDay(
      Js.Date.makeWithYM(~year=Belt.Int.toFloat(newYear), ~month=getMonthInFloat(updatedMonth), ()),
    )

    // get Days in month
    let daysInMonth = switch updatedMonth {
    | Jan => 31
    | Feb => LogicUtils.checkLeapYear(newYear) ? 29 : 28
    | Mar => 31
    | Apr => 30
    | May => 31
    | Jun => 30
    | Jul => 31
    | Aug => 31
    | Sep => 30
    | Oct => 31
    | Nov => 30
    | Dec => 31
    }
    // creating row info
    let dummyRow = Belt.Array.make(6, Belt.Array.make(7, ""))

    let rowMapper = (row, indexRow) => {
      Array.mapWithIndex(row, (_item, index) => {
        let subFactor = Belt.Float.toInt(firstDay)
        if indexRow == 0 && index < Belt.Float.toInt(firstDay) {
          ""
        } else if indexRow == 0 {
          Belt.Int.toString(indexRow + (index + 1) - subFactor)
        } else if indexRow * 7 + (index + 1) - subFactor > daysInMonth {
          ""
        } else {
          Belt.Int.toString(indexRow * 7 + (index + 1) - subFactor)
        }
      })
    }
    let rowInfo = Array.mapWithIndex(dummyRow, rowMapper)

    <div style={index->LogicUtils.getJsonObjectFromDict("style")->Identity.jsonToReactDOMStyle}>
      <div className={`font-normal text-fs-16 text-[#344054] leading-6 mt-5`}>
        {React.string(`${updatedMonth->getMonthInStr} ${newYear->Belt.Int.toString}`)}
      </div>
      <table className="table-auto min-w-full">
        <tbody>
          {rowInfo
          ->Array.mapWithIndex((item, rowIndex) => {
            <TableRow
              key={rowIndex->Belt.Int.toString}
              item
              rowIndex
              onDateClick
              hoverdDate
              setHoverdDate
              ?cellHighlighter
              ?cellRenderer
              month={getMonthInFloat(updatedMonth)}
              year={Belt.Int.toFloat(newYear)}
              startDate
              endDate
              disablePastDates
              disableFutureDates
              changeHighlightCellStyle
              ?dateRangeLimit
              ?setShowMsg
              customDisabledFutureDays
              windowIndex
              ?setIsDateClicked
            />
          })
          ->React.array}
        </tbody>
      </table>
    </div>
  }

  <div className="text-sm px-2 pb-2 font-inter-style flex flex-col items-center">
    <div className="border-b-2">
      {if showHead {
        <div className="flex flex-row justify-between">
          {heading
          ->Array.mapWithIndex((item, i) => {
            <div className="w-10" key={string_of_int(i)}>
              <div
                className="flex flex-1 justify-center pb-2.5 pt-0.5 text-jp-gray-700 dark:text-jp-gray-text_darktheme dark:text-opacity-50">
                {React.string(isMobileView ? item->String.charAt(0) : item)}
              </div>
            </div>
          })
          ->React.array}
        </div>
      } else {
        React.null
      }}
    </div>
    <ReactWindow.VariableSizeList
      ref={el => {
        open ReactWindow.ListComponent
        fn.current = el->scrollToItem
      }}
      width=300
      itemSize={_ => 290}
      height=290
      itemCount={totalMonths + futureMonths}>
      {rows}
    </ReactWindow.VariableSizeList>
  </div>
}
