type month = Jan | Feb | Mar | Apr | May | Jun | Jul | Aug | Sep | Oct | Nov | Dec

type highlighter = {
  highlightSelf: bool,
  highlightLeft: bool,
  highlightRight: bool,
}

type dateObj = {
  startDate: string,
  endDate: string,
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
        React.string(day[2]->Belt.Option.getWithDefault(""))
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
    ~rowIndex as _rowIndex,
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
    ~allowedDateRange: option<dateObj>=?,
  ) => {
    let customTimezoneToISOString = TimeZoneHook.useCustomTimeZoneToIsoString()
    let highlight = cellHighlighter

    {
      if item == Belt.Array.make(7, "") {
        <tr className="h-0" />
      } else {
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
            let dateNotInRange = switch allowedDateRange {
            | Some(obj) =>
              if obj.startDate !== "" && obj.endDate !== "" {
                !(
                  date->Js.Date.getTime -.
                    obj.startDate->Js.Date.fromString->Js.Date.getTime >= 0.0 &&
                    obj.endDate->Js.Date.fromString->Js.Date.getTime -. date->Js.Date.getTime >= 0.0
                )
              } else {
                false
              }

            | None => false
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
              let isClickDisabled =
                (endDate === "" && !isInLimit) ||
                (isFutureDate ? disableFutureDates : disablePastDates) ||
                customDisabledFutureDays > 0.0 && isInCustomDisable ||
                dateNotInRange
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
              endDate === "" && !isInLimit ||
              dateNotInRange
            ) {
              "cursor-not-allowed"
            } else {
              "cursor-default"
            }
            let getDate = date => {
              let datevalue = Js.Date.makeWithYMD(
                ~year=Js.Float.fromString(date[0]->Belt.Option.getWithDefault("")),
                ~month=Js.Float.fromString(
                  String.make(Js.Float.fromString(date[1]->Belt.Option.getWithDefault("")) -. 1.0),
                ),
                ~date=Js.Float.fromString(date[2]->Belt.Option.getWithDefault("")),
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

            let textColor =
              today == renderingDate
                ? "text-blue-800"
                : "text-jp-gray-900 text-opacity-75 dark:text-opacity-75"
            let classN = if obj == "" || hSelf.highlightSelf {
              `h-9 p-0 w-9 font-semibold font-fira-code text-center ${textColor}  dark:text-jp-gray-text_darktheme  ${dayClass}`
            } else {
              `h-9 p-0 w-9 font-semibold text-center font-fira-code ${textColor}  dark:text-jp-gray-text_darktheme hover:text-opacity-100 dark:hover:text-opacity-100 hover:bg-jp-gray-lightmode_steelgray hover:bg-opacity-75 hover:rounded-lg dark:hover:bg-jp-gray-850 dark:hover:bg-opacity-100 ${dayClass} `
            }
            let c2 =
              obj != "" && hSelf.highlightSelf
                ? "h-full w-full flex flex-1 justify-center items-center bg-blue-800 bg-opacity-100 dark:bg-blue-800 dark:bg-opacity-100 text-white rounded-full"
                : "h-full w-full"

            let shouldHighlight = (startDate, endDate, obj, month, year) => {
              if startDate != "" && obj != "" {
                let parsedStartDate = getDate(String.split(startDate, "-"))
                let z = getDate([year, month, obj])

                if endDate != "" {
                  let parsedEndDate = getDate(String.split(endDate, "-"))
                  z == parsedStartDate
                    ? `h-full w-full flex flex-1 justify-center items-center bg-blue-800 bg-opacity-100 dark:bg-blue-800 dark:bg-opacity-100 text-white rounded-l-lg `
                    : z == parsedEndDate
                    ? "h-full w-full flex flex-1 justify-center items-center bg-blue-800 bg-opacity-100 dark:bg-blue-800 dark:bg-opacity-100 text-white rounded-r-lg "
                    : z > parsedStartDate && z < parsedEndDate
                    ? "h-full w-full flex flex-1 justify-center items-center bg-blue-100  dark:bg-gray-700 dark:bg-opacity-100 text-gray-600 dark:text-gray-400"
                    : "h-full w-full"
                } else if z == parsedStartDate {
                  `h-full w-full flex flex-1 justify-center items-center bg-blue-800 bg-opacity-100 dark:bg-blue-800 dark:bg-opacity-100 text-white rounded-lg ${changeHighlightCellStyle}`
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
                  "h-full w-full flex flex-1 justify-center items-center bg-blue-100 dark:bg-gray-700 dark:bg-opacity-100"
                } else {
                  "h-full w-full"
                }
              } else {
                "h-full w-full"
              }
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
              key={string_of_int(cellIndex)}
              className={classN}
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
                    endDate === "" && !isInLimit ||
                    dateNotInRange
                      ? "disabled"
                      : "enabled",
                  ),
                ]>
                <span className={startDate == "" ? c2 : c3}>
                  {cellRenderer(
                    obj == ""
                      ? None
                      : Some(
                          (Js.Date.toString(date)->DayJs.getDayJsForString).format(. "YYYY-MM-DD"),
                        ),
                  )}
                </span>
              </AddDataAttributes>
            </td>
          })
          ->React.array}
        </tr>
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
  ~highLightList=?,
  ~startDate="",
  ~endDate="",
  ~disablePastDates=true,
  ~disableFutureDates=false,
  ~dateRangeLimit=?,
  ~setShowMsg=?,
  ~showHead=true,
  ~customDisabledFutureDays=0.0,
  ~allowedDateRange=?,
) => {
  let _ = highLightList
  let months = [Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec]
  let heading = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
  let isMobileView = MatchMedia.useMobileChecker()
  let getMonthInFloat = mon => Array.indexOf(months, mon)->Belt.Float.fromInt
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
  // get first day
  let firstDay = Js.Date.getDay(
    Js.Date.makeWithYM(~year=Belt.Int.toFloat(year), ~month=getMonthInFloat(month), ()),
  )
  // get Days in month
  let daysInMonth = switch month {
  | Jan => 31
  | Feb => LogicUtils.checkLeapYear(year) ? 29 : 28
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

  <div className="text-sm px-2 pb-2">
    {showTitle
      ? {
          <h3 className="text-center font-bold text-lg text-gray-500 ">
            {React.string(month->getMonthInStr)}
            <span className="font-fira-code"> {React.string(year->Belt.Int.toString)} </span>
          </h3>
        }
      : {
          <span />
        }}
    <table className="table-auto min-w-full">
      <thead>
        {if showHead {
          <tr>
            {heading
            ->Array.mapWithIndex((item, i) => {
              <th key={string_of_int(i)}>
                <div
                  className="flex flex-1 justify-center py-1 text-jp-gray-700 dark:text-jp-gray-text_darktheme dark:text-opacity-50">
                  {React.string(isMobileView ? item->String.charAt(0) : item)}
                </div>
              </th>
            })
            ->React.array}
          </tr>
        } else {
          React.null
        }}
      </thead>
      <tbody>
        {rowInfo
        ->Array.mapWithIndex((item, rowIndex) => {
          <TableRow
            key={string_of_int(rowIndex)}
            item
            rowIndex
            onDateClick
            hoverdDate
            setHoverdDate
            ?cellHighlighter
            ?cellRenderer
            month={getMonthInFloat(month)}
            year={Belt.Int.toFloat(year)}
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
        })
        ->React.array}
      </tbody>
    </table>
  </div>
}
