type month = Jan | Feb | Mar | Apr | May | Jun | Jul | Aug | Sep | Oct | Nov | Dec

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
        React.string(day[2]->Option.getOr(""))
      }

    | None => React.string("")
    }
  }

  @react.component
  let make = (
    ~item,
    ~month,
    ~year,
    ~rowIndex as _rowIndex,
    ~onDateClick,
    ~cellHighlighter=defaultCellHighlighter,
    ~cellRenderer=defaultCellRenderer,
    ~startDate="",
    ~endDate="",
    ~disablePastDates=true,
    ~disableFutureDates=false,
  ) => {
    open LogicUtils
    let customTimezoneToISOString = TimeZoneHook.useCustomTimeZoneToIsoString()
    let highlight = cellHighlighter

    {
      if item == Array.make(~length=7, "") {
        React.null
      } else {
        <tr className="transition duration-300 ease-in-out">
          {item
          ->Array.mapWithIndex((obj, cellIndex) => {
            let date =
              customTimezoneToISOString(
                String.make(year),
                String.make(month +. 1.0),
                String.make(obj->isEmptyString ? "01" : obj),
                "00",
                "00",
                "00",
              )->Date.fromString
            let dateToday = Date.make()
            let todayInitial = Js.Date.setHoursMSMs(
              dateToday,
              ~hours=0.0,
              ~minutes=0.0,
              ~seconds=0.0,
              ~milliseconds=0.0,
              (),
            )
            let isFutureDate = todayInitial -. date->Date.getTime < 0.0

            let onClick = _evt => {
              let isClickDisabled = isFutureDate ? disableFutureDates : disablePastDates
              switch !isClickDisabled {
              | true =>
                switch onDateClick {
                | Some(fn) =>
                  if obj->isNonEmptyString {
                    fn((Date.toISOString(date)->DayJs.getDayJsForString).format(. "YYYY-MM-DD"))
                  }
                | None => ()
                }
              | false => ()
              }
            }
            let hSelf = highlight(
              (Date.toString(date)->DayJs.getDayJsForString).format(. "YYYY-MM-DD"),
            )

            let dayClass = if (
              (isFutureDate && disableFutureDates) || (!isFutureDate && disablePastDates)
            ) {
              "cursor-not-allowed"
            } else {
              "cursor-default"
            }

            let classN =
              obj->isEmptyString || hSelf.highlightSelf
                ? `h-12 w-12 font-fira-code text-center dark:text-jp-gray-text_darktheme text-opacity-75 ${dayClass} p-0 pb-1`
                : `cursor-pointer h-12 w-12 text-center font-fira-code font-medium dark:text-jp-gray-text_darktheme text-opacity-75 dark:hover:bg-opacity-100 ${dayClass} p-0 pb-1`
            let c2 =
              obj->isNonEmptyString && hSelf.highlightSelf
                ? "h-full w-full cursor-pointer flex border flex-1 justify-center items-center bg-blue-500 bg-opacity-100 dark:bg-opacity-100 rounded-full"
                : "h-full w-full"

            let shouldHighlight = (startDate, endDate, obj, month, year) => {
              if startDate->isNonEmptyString && obj->isNonEmptyString {
                let getDate = date => {
                  let datevalue = Js.Date.makeWithYMD(
                    ~year=Js.Float.fromString(date[0]->Option.getOr("")),
                    ~month=Js.Float.fromString(
                      String.make(Js.Float.fromString(date[1]->Option.getOr("")) -. 1.0),
                    ),
                    ~date=Js.Float.fromString(date[2]->Option.getOr("")),
                    (),
                  )
                  datevalue
                }
                let parsedStartDate = getDate(String.split(startDate, "-"))
                let z = getDate([year, month, obj])
                if endDate->isNonEmptyString {
                  let parsedEndDate = getDate(String.split(endDate, "-"))
                  z == parsedStartDate && z == parsedEndDate
                    ? "h-full w-full flex flex-1 justify-center items-center bg-blue-500 bg-opacity-100 dark:bg-blue-500 dark:bg-opacity-100 text-white dark:hover:text-jp-gray-text_darktheme rounded-full"
                    : z == parsedStartDate
                    ? "h-full w-full flex flex-1 justify-center items-center bg-blue-500 bg-opacity-100 dark:bg-blue-500 dark:bg-opacity-100 text-white dark:hover:text-jp-gray-text_darktheme rounded-l-full "
                    : z == parsedEndDate
                    ? "h-full w-full flex flex-1 justify-center items-center bg-blue-500 bg-opacity-100 dark:bg-blue-500 dark:bg-opacity-100 text-white dark:hover:text-jp-gray-text_darktheme rounded-r-full "
                    : z > parsedStartDate && z < parsedEndDate
                    ? "h-full w-full flex flex-1 justify-center items-center bg-blue-500 bg-opacity-100 dark:bg-blue-500 text-white dark:hover:text-jp-gray-text_darktheme dark:bg-opacity-100"
                    : "h-full w-full"
                } else if z == parsedStartDate {
                  "h-full w-full flex flex-1 justify-center items-center bg-blue-500 bg-opacity-100 dark:bg-blue-500 text-white dark:hover:text-jp-gray-text_darktheme dark:bg-opacity-100 rounded-full"
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
                Float.toString(month +. 1.0),
                Float.toString(year),
              )
            }
            <td key={Int.toString(cellIndex)} className=classN onClick>
              <span
                className={`${startDate->isEmptyString ? c2 : c3} ${obj->isNonEmptyString
                    ? "dark:hover:border-jp-gray-400 dark:text-jp-gray-text_darktheme dark:hover:text-white"
                    : ""}`}>
                <span
                  className={obj->isEmptyString
                    ? ""
                    : "border border-transparent hover:text-jp-gray-950 hover:border-jp-gray-950 p-3 hover:bg-white dark:hover:bg-jp-gray-950 dark:hover:text-white rounded-full"}>
                  {cellRenderer(
                    obj->isEmptyString
                      ? None
                      : Some((Date.toString(date)->DayJs.getDayJsForString).format(. "YYYY-MM-DD")),
                  )}
                </span>
              </span>
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
  ~month,
  ~year,
  ~onDateClick=?,
  ~showTitle=true,
  ~cellHighlighter=?,
  ~cellRenderer=?,
  ~highLightList=?,
  ~startDate="",
  ~endDate="",
  ~disablePastDates=true,
  ~disableFutureDates=false,
) => {
  // ~cellHighlighter: option<(~date: Date.t) => highlighter>=None,
  let _ = highLightList
  let months = [Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec]
  let heading = ["S", "M", "T", "W", "T", "F", "S"]
  let getMonthInFloat = mon => Array.indexOf(months, mon)->Float.fromInt
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
    Js.Date.makeWithYM(~year=Int.toFloat(year), ~month=getMonthInFloat(month), ()),
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
  let dummyRow = Array.make(~length=6, Array.make(~length=7, ""))

  let rowMapper = (row, indexRow) => {
    Array.mapWithIndex(row, (_item, index) => {
      let subFactor = Float.toInt(firstDay)
      if indexRow == 0 && index < Float.toInt(firstDay) {
        ""
      } else if indexRow == 0 {
        Int.toString(indexRow + (index + 1) - subFactor)
      } else if indexRow * 7 + (index + 1) - subFactor > daysInMonth {
        ""
      } else {
        Int.toString(indexRow * 7 + (index + 1) - subFactor)
      }
    })
  }
  let rowInfo = Array.mapWithIndex(dummyRow, rowMapper)

  <div className="text-sm px-4 pb-2">
    {showTitle
      ? <h3 className="text-center font-bold text-lg text-gray-500 ">
          {React.string(month->getMonthInStr)}
          <span className="font-fira-code"> {React.string(year->Int.toString)} </span>
        </h3>
      : React.null}
    <table className="table-auto min-w-full">
      <thead>
        <tr>
          {heading
          ->Array.mapWithIndex((item, i) => {
            <th key={Int.toString(i)} className="p-0">
              <div
                className="flex flex-1 justify-center py-2 font-medium text-jp-gray-700 dark:text-jp-gray-text_darktheme dark:text-opacity-50">
                {React.string(item)}
              </div>
            </th>
          })
          ->React.array}
        </tr>
      </thead>
      <tbody>
        {rowInfo
        ->Array.mapWithIndex((item, rowIndex) => {
          <TableRow
            key={Int.toString(rowIndex)}
            item
            rowIndex
            onDateClick
            ?cellHighlighter
            ?cellRenderer
            month={getMonthInFloat(month)}
            year={Int.toFloat(year)}
            startDate
            endDate
            disablePastDates
            disableFutureDates
          />
        })
        ->React.array}
      </tbody>
    </table>
  </div>
}
