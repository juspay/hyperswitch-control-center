external ffInputToSelectInput: ReactFinalForm.fieldRenderPropsInput => ReactFinalForm.fieldRenderPropsCustomInput<
  array<string>,
> = "%identity"

open Calendar

@react.component
let make = (
  ~month: option<month>=?,
  ~year: option<int>=?,
  ~onDateClick=?,
  ~onChange2=?,
  ~count=1,
  ~cellHighlighter=?,
  ~cellRenderer=?,
  ~startDate="",
  ~endDate="",
  ~start_time,
  ~end_time,
  ~disablePastDates=true,
) => {
  let _ = month
  let _ = year
  let _ = onChange2
  let _ = startDate
  let _ = endDate

  let (hoverdDate, setHoverdDate) = React.useState(_ => "")
  let months = [Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec]

  let getMonthFromFloat = value => {
    let valueInt = value->Belt.Float.toInt

    months[valueInt]->Belt.Option.getWithDefault(Jan)
  }

  let dateMonthDiff = (initialDate, finalDate) => {
    let initMonth = Belt.Float.toInt(Js.Date.getMonth(initialDate))

    let initYear = Belt.Float.toInt(Js.Date.getFullYear(initialDate))

    let finMonth = Belt.Float.toInt(Js.Date.getMonth(finalDate))

    let finYear = Belt.Float.toInt(Js.Date.getFullYear(finalDate))

    let monthsBetween = (finYear - initYear) * 12 - initMonth + finMonth

    monthsBetween + 1 <= 0 ? 0 : monthsBetween + 1
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

  let initDate = LogicUtils.getStringFromJson(start_time, "")

  let finalDate = LogicUtils.getStringFromJson(end_time, "")

  let isoStringToCustomTimeZone = TimeZoneHook.useIsoStringToCustomTimeZoneInFloat()
  let initialDateTimeObject = isoStringToCustomTimeZone(initDate)
  let finalDateTimeObject = isoStringToCustomTimeZone(finalDate)

  let currDateIm = TimeZoneHook.dateTimeObjectToDate(initialDateTimeObject)
  let endDateIm = TimeZoneHook.dateTimeObjectToDate(finalDateTimeObject)
  let dummyRow = Belt.Array.make(count, 1)

  <span className="flex flex-1 flex-row max-w-full overflow-auto">
    {dummyRow
    ->Array.mapWithIndex((_item, i) => {
      let topRow = Belt.Array.make(dateMonthDiff(currDateIm, endDateIm), 1)
      <AddDataAttributes attributes=[("data-calendar", "calendar")]>
        <div key={i->Belt.Int.toString} className="flex flex-wrap">
          {topRow
          ->Array.mapWithIndex((_item, index) => {
            let currDateTemp = Js.Date.fromFloat(Js.Date.valueOf(currDateIm))
            let newMonth = Belt.Float.toInt(Js.Date.getMonth(currDateTemp)) + index
            let updatedDate = Js.Date.fromFloat(Js.Date.setDate(currDateTemp, 1.0))
            let tempDate = Js.Date.setMonth(updatedDate, Belt.Int.toFloat(newMonth))
            let tempMonth = Js.Date.getMonth(Js.Date.fromFloat(tempDate))
            let tempYear = Js.Date.getFullYear(Js.Date.fromFloat(tempDate))

            <span
              key={index->string_of_int}
              className="border border-jp-gray-500 dark:border-jp-gray-960">
              <span className="flex flex-row justify-between px-4 pt-4">
                {false
                  ? <span>
                      <span
                        className="inline-block text-jp-gray-600 dark:text-jp-gray-text_darktheme dark:text-opacity-25">
                        <Icon name={"chevron-left"} />
                      </span>
                    </span>
                  : <span />}
                <span className=" inline-block pb-3">
                  <h3
                    className="font-bold text-base text-md text-jp-gray-800 dark:text-jp-gray-text_darktheme dark:text-opacity-75">
                    {React.string(
                      String.concat(
                        getMonthInStr(getMonthFromFloat(tempMonth)),
                        Belt.Float.toString(tempYear),
                      ),
                    )}
                  </h3>
                </span>
                {false
                  ? <span>
                      <span
                        className="inline-block text-jp-gray-600 dark:text-jp-gray-text_darktheme dark:text-opacity-25">
                        <Icon name={"chevron-right"} />
                      </span>
                    </span>
                  : <span />}
              </span>
              <Calendar
                key={string_of_int(i)}
                month={getMonthFromFloat(tempMonth)}
                year={Belt.Float.toInt(tempYear)}
                hoverdDate
                setHoverdDate
                showTitle=false
                ?cellHighlighter
                ?cellRenderer
                ?onDateClick
                disablePastDates
              />
            </span>
          })
          ->React.array}
        </div>
      </AddDataAttributes>
    })
    ->React.array}
  </span>
}
