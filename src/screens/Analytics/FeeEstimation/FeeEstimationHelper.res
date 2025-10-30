open BarGraphTypes
open Typography
open LogicUtils

let costBreakDownTableKey = "Cost Breakdown Overview"
let transactionViewTableKey = "Fee Estimate Transaction Overview"

let feeBreakdownBasedOnGeoLocationPayload = (
  ~feeBreakdownData: array<FeeEstimationTypes.feeBreakdownGeoLocation>,
  ~currency: string,
) => {
  let categories =
    feeBreakdownData->Array.map(item => item.region->getNonEmptyString->Option.getOr("Unknown"))

  let percentageSeries: dataObj = {
    showInLegend: false,
    name: "Percentage",
    data: feeBreakdownData->Array.map(item => item.fees),
    color: "#4392BC",
  }

  let tooltipFormatterJs = @this
  (this: pointFormatter) => {
    let point = this.points->getValueFromArray(
      0,
      {
        color: "",
        x: "",
        y: 0.0,
        point: {
          index: 0,
        },
      },
    )
    let seriesNames = ["Fees Incurred"]

    let rows =
      this.points
      ->Array.mapWithIndex((point, idx) => {
        let label = seriesNames->getValueFromArray(idx, "")
        let value = point.y
        `<div
        style="
          display: flex;
        flex-direction: column;
        justify-content: space-between;
        align-items: flex-start;
        gap: 12px;
        padding: 6px 10px;
        font-family: Inter, sans-serif;
        font-size: 13px;
        line-height: 1.5;
        color: #1a1a1a;
        border-radius: 6px;
      "
    >
      <div style="display: flex; align-items: center; gap: 8px">
        <div
          style="
            width: 10px;
            height: 10px;
            background-color: ${point.color};
            border-radius: 2px;
            flex-shrink: 0;
          "
        ></div>
        <div style="font-weight: 500">${label} <span style="font-weight:600">${currency} ${valueFormatter(
            value,
            LogicUtilsTypes.Amount,
          )}</span></div>
      </div>
    </div>
`
      })
      ->Array.joinWith("")

    `<div class="bg-white border border-nd_br_gray-200 rounded-lg" style=\"padding:8px 12px;min-width:200px;\"><div style=\"font-weight:700;margin-bottom:8px;margin-left:8px;\">${point.x}</div>${rows}</div>`
  }

  let payload: barGraphPayload = {
    categories,
    data: [percentageSeries],
    title: {text: ""},
    tooltipFormatter: asTooltipPointFormatter(tooltipFormatterJs),
  }
  payload
}

let costBreakDownBasedOnGeoLocationPayload = (
  ~costBreakDownData: array<FeeEstimationTypes.breakdownContribution>,
  ~currency: string,
) => {
  let categories =
    costBreakDownData->Array.map(item => item.cardBrand->getNonEmptyString->Option.getOr("Unknown"))

  let percentageSeries: dataObj = {
    showInLegend: false,
    name: "Cost Break Down",
    data: costBreakDownData->Array.map(item => item.value),
    color: "#4392BC",
  }

  let tooltipFormatterJs = @this
  (this: pointFormatter) => {
    let point = this.points->getValueFromArray(
      0,
      {
        color: "",
        x: "",
        y: 0.0,
        point: {
          index: 0,
        },
      },
    )
    let seriesNames = ["Cost Break Down"]

    let rows =
      this.points
      ->Array.mapWithIndex((point, idx) => {
        let label = seriesNames->getValueFromArray(idx, "")
        let value = point.y
        `<div style="display:flex;justify-content:space-between;gap:12px;padding:2px 0;">
          <div style=\"display:flex;align-items:center;gap:8px;\">
            <div style=\"width:10px;height:10px;background-color:${point.color};border-radius:2px;\"></div>
            <div>${label}</div>
          </div>
          <div style=\"font-weight:600\"> ${currency} ${valueFormatter(
            value,
            LogicUtilsTypes.Amount,
          )}</div>
        </div>`
      })
      ->Array.joinWith("")

    `<div class="bg-white border border-nd_br_gray-200 rounded-lg" style=\"padding:8px 12px;min-width:200px;\">
      <div style=\"font-weight:700;margin-bottom:8px;\">${point.x}</div>
      ${rows}
    </div>`
  }

  let payload: barGraphPayload = {
    categories,
    data: [percentageSeries],
    title: {text: ""},
    tooltipFormatter: asTooltipPointFormatter(tooltipFormatterJs),
  }
  payload
}

let labelFormatter = currency => {
  @this
  (this: labelFormatter) => {
    `<p className="${body.md.medium}"> ${this.value} ${currency} </p>`
  }
}

module MonthRangeSelector = {
  open DateTimeUtils
  let monthYear = "MMM YYYY"

  let getDaysInMonth = (year, month) => {
    switch month {
    | 0 => 31
    | 1 => checkLeapYear(year) ? 29 : 28
    | 2 => 31
    | 3 => 30
    | 4 => 31
    | 5 => 30
    | 6 => 31
    | 7 => 31
    | 8 => 30
    | 9 => 31
    | 10 => 30
    | 11 => 31
    | _ => 31
    }
  }

  let getStartDateFromSelectedMonth = (~month, ~selectedYear) => {
    let year = selectedYear->Int.fromString->Option.getOr(2025)
    Date.makeWithYMD(~year, ~month, ~date=1)
  }

  let getEndDateFromSelectedMonth = (~month, ~selectedYear) => {
    let year = selectedYear->Int.fromString->Option.getOr(2025)
    let lastDay = getDaysInMonth(year, month)
    Date.makeWithYMD(~year, ~month, ~date=lastDay)
  }

  type dateFormatType = YMD(string) | MY(string)

  @react.component
  let make = (~updateDateRange, ~initialStartDate, ~initialEndDate, ~isDisabled=false) => {
    let currentDate = Date.make()
    let lastMonth = currentDate->Date.getMonth - 1
    let currentYear = currentDate->Date.getFullYear
    let defaultStartDate = Date.makeWithYMD(~year=currentYear, ~month=lastMonth, ~date=1)

    let (selectedYear, setSelectedYear) = React.useState(_ => currentYear->Int.toString)
    let (showDateRange, setShowDateRange) = React.useState(_ => false)
    let monthRangeSelectorRef = React.useRef(Nullable.null)

    let isMobileView = MatchMedia.useMobileChecker()
    let monthRangeSelectorCss = isMobileView
      ? "absolute z-10 bg-white border w-[20rem] right-0 top-12 shadow-connectorTagShadow rounded-xl"
      : "absolute z-10 bg-white border w-full bottom-0 shadow-connectorTagShadow rounded-xl"

    OutsideClick.useOutsideClick(
      ~refs=ArrayOfRef([monthRangeSelectorRef]),
      ~isActive=showDateRange,
      ~callback=() => setShowDateRange(_ => false),
    )

    let increaseYearRange = () => {
      let currentActualDate = Date.make()->Date.getFullYear->Int.toString

      if selectedYear != currentActualDate {
        let reducedYear = selectedYear->safeParse->getIntFromJson(1999) + 1
        setSelectedYear(_ => reducedYear->Int.toString)
      }
    }
    let decreaseYearRange = () => {
      let reducedYear = selectedYear->safeParse->getIntFromJson(1999) - 1
      setSelectedYear(_ => reducedYear->Int.toString)
    }

    let (startDate, setStartDate) = React.useState(_ => initialStartDate)
    let (endDate, setEndDate) = React.useState(_ => initialEndDate)

    let isOutOfRange = index => {
      let date = Date.makeWithYMD(
        ~year=selectedYear->Int.fromString->Option.getOr(2025),
        ~month=index,
        ~date=1,
      )
      date > defaultStartDate
    }

    let handleSelect = index => {
      let date = getStartDateFromSelectedMonth(~month=index, ~selectedYear)
      let lastValidDate = Date.makeWithYMD(~year=currentYear - 2, ~month=lastMonth, ~date=1)
      if (
        !(
          date->Date.toString->dateFormat("YYYY-MM-DD") >=
            currentDate->Date.toString->dateFormat("YYYY-MM-DD")
        ) &&
        !(
          date->Date.toString->dateFormat("YYYY-MM-DD") <
            lastValidDate
            ->Date.toString
            ->dateFormat("YYYY-MM-DD")
        )
      ) {
        if startDate->isEmptyString || (startDate->isNonEmptyString && endDate->isNonEmptyString) {
          let startDate = getStartDateFromSelectedMonth(~month=index, ~selectedYear)
          setStartDate(_ => startDate->Js.Date.toString)
          setEndDate(_ => "")
        } else if startDate->isNonEmptyString && endDate->isEmptyString {
          if date > startDate->Js.Date.fromString {
            let endDate = getEndDateFromSelectedMonth(~month=index, ~selectedYear)
            setEndDate(_ => endDate->Js.Date.toString)
          } else {
            let newStartDate = getStartDateFromSelectedMonth(~month=index, ~selectedYear)
            let mon = startDate->Date.fromString->Date.getMonth
            let year = startDate->Date.fromString->Date.getFullYear->Int.toString
            let newEndDate = getEndDateFromSelectedMonth(~month=mon, ~selectedYear=year)
            setStartDate(_ => newStartDate->Js.Date.toString)
            setEndDate(_ => newEndDate->Js.Date.toString)
          }
        }
      }
    }

    let isInSelectedRange = index => {
      if startDate->isEmptyString || endDate->isEmptyString {
        false
      } else {
        getStartDateFromSelectedMonth(~month=index, ~selectedYear) >=
        startDate->Js.Date.fromString &&
          getStartDateFromSelectedMonth(~month=index, ~selectedYear) <= endDate->Js.Date.fromString
      }
    }

    let onCancel = () => {
      setEndDate(_ => "")
      setShowDateRange(_ => false)
    }

    let onApply = () => {
      updateDateRange(
        ~startDate=startDate->getFormattedDate("YYYY-MM-DD"),
        ~endDate=endDate->getFormattedDate("YYYY-MM-DD"),
      )
      setShowDateRange(_ => false)
    }

    let getFormattedDateValue = date => date->getFormattedDate(monthYear)
    let css = index => {
      let startDateFormatted = startDate->isNonEmptyString ? getFormattedDateValue(startDate) : ""
      let endDateFormatted = endDate->isNonEmptyString ? getFormattedDateValue(endDate) : ""

      let formattedDate = getFormattedDateValue(
        getStartDateFromSelectedMonth(~month=index, ~selectedYear)->Date.toString,
      )

      let now = Js.Date.fromFloat(Date.now())

      let currentYear = now->Js.Date.getFullYear
      let twoYearsAgo = Belt.Float.toInt(currentYear) - 2
      let twoYearsFromNow = now->Js.Date.setFullYear(Int.toFloat(twoYearsAgo))
      let twoMonthsInMilliSeconds = 2.0 *. 30.0 *. 24.0 *. 60.0 *. 60.0 *. 1000.0
      let isOutofStartingRange = index => {
        let date = getStartDateFromSelectedMonth(~month=index, ~selectedYear)
        date->Js.Date.getTime +. twoMonthsInMilliSeconds < twoYearsFromNow
      }

      if (
        startDateFormatted->isNonEmptyString &&
        formattedDate === startDateFormatted &&
        endDateFormatted->isNonEmptyString &&
        formattedDate === endDateFormatted
      ) {
        "bg-blue-812 text-white rounded-md"
      } else if startDateFormatted->isNonEmptyString && formattedDate === startDateFormatted {
        "bg-blue-812 text-white rounded-l-md"
      } else if endDateFormatted->isNonEmptyString && formattedDate === endDateFormatted {
        "bg-blue-812 text-white rounded-r-md"
      } else if isInSelectedRange(index) {
        "hover:bg-nd_gray-25 text-nd_gray-600"
      } else if isOutOfRange(index) {
        "bg-grey-light text-grey-medium"
      } else if isOutofStartingRange(index) {
        "bg-grey-light text-grey-medium"
      } else {
        "hover:bg-nd_gray-25 text-nd_gray-600"
      }
    }

    let getButtonText = () => {
      if startDate->String.length > 0 && endDate->String.length > 0 {
        `${startDate->getFormattedDate("MMM YY")} - ${endDate->getFormattedDate("MMM YY")}`
      } else {
        "Select month range"
      }
    }

    <div className="relative" ref={monthRangeSelectorRef->ReactDOM.Ref.domRef}>
      <RenderIf condition={showDateRange}>
        <div className=monthRangeSelectorCss>
          <div className="flex justify-between p-4">
            <div className="flex items-center">
              <RenderIf condition={startDate->String.length > 0}>
                <p className="font-semibold">
                  {startDate->getFormattedDate("MMM YYYY")->React.string}
                </p>
              </RenderIf>
              <RenderIf condition={endDate->String.length > 0}>
                <p className="font-semibold"> {"-"->React.string} </p>
                <p className="font-semibold">
                  {endDate->getFormattedDate("MMM YYYY")->React.string}
                </p>
              </RenderIf>
            </div>
            <div
              className="flex gap-2 items-center"
              onClick={ev => ev->ReactEvent.Mouse.stopPropagation}>
              <Icon
                className="cursor-pointer" name="angle-left" onClick={_ => decreaseYearRange()}
              />
              <p> {selectedYear->React.string} </p>
              <Icon
                className="cursor-pointer" name="angle-right" onClick={_ => increaseYearRange()}
              />
            </div>
          </div>
          <hr />
          <div className="grid grid-cols-3 p-4 gap-y-4">
            {months
            ->Array.mapWithIndex((ele, index) => {
              <div
                onClick={_ => handleSelect(index)}
                key={(ele :> string)}
                className={`p-2 ${body.lg.medium} cursor-pointer transition-transform transform ${index->css}`}>
                <span> {(ele :> string)->React.string} </span>
              </div>
            })
            ->React.array}
          </div>
          <hr />
          <div className="flex p-4 justify-end gap-3">
            <Button
              text="Cancel" buttonType={Secondary} onClick={_ => onCancel()} buttonSize={Small}
            />
            <Button
              text="Apply"
              buttonState={switch endDate->Js.Date.fromString->Date.toString {
              | "Invalid Date" => Disabled
              | _ => Normal
              }}
              onClick={_ => onApply()}
              buttonSize={Small}
            />
          </div>
        </div>
      </RenderIf>
      <Button
        leftIcon=FontAwesome("calendar-alt")
        text={getButtonText()}
        buttonState={isDisabled ? Disabled : Normal}
        onClick={_ => setShowDateRange(prev => !prev)}
      />
    </div>
  }
}

let expandedTableRows = (~appliedFeesData: FeeEstimationTypes.breakdownItem) => [
  [
    Table.CustomCell(
      <p className={`text-nd_gray-700 ${body.md.medium}`}> {"Interchange fees"->React.string} </p>,
      "",
    ),
    Table.CustomCell(
      <p className={`text-nd_gray-600 ${body.md.medium}`}>
        {`${appliedFeesData.estimateInterchangeVariableRate->Float.toString} % + ${appliedFeesData.transactionCurrency} ${appliedFeesData.estimateInterchangeFixedRate->Float.toString}`->React.string}
      </p>,
      "",
    ),
    Table.CustomCell(
      <p className={`text-nd_gray-600 ${body.md.medium}`}>
        {`${appliedFeesData.transactionCurrency} ${appliedFeesData.estimateInterchangeCost->Float.toString}`->React.string}
      </p>,
      "",
    ),
  ],
  [
    Table.CustomCell(
      <p className={`text-nd_gray-700 ${body.md.medium}`}> {"Scheme fees"->React.string} </p>,
      "",
    ),
    Table.CustomCell(
      <p className={`text-nd_gray-600 ${body.md.medium}`}>
        {"Charged differently"->React.string}
      </p>,
      "",
    ),
    Table.CustomCell(
      <p className={`text-nd_gray-600 ${body.md.medium}`}>
        {`${appliedFeesData.transactionCurrency} ${appliedFeesData.estimateSchemeTotalCost->Float.toString}`->React.string}
      </p>,
      "",
    ),
  ],
]
