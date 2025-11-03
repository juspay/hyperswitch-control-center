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

module ModalInfoSection = {
  @react.component
  let make = (~modalInfoData: array<FeeEstimationTypes.sidebarModalData>) => {
    modalInfoData
    ->Array.map(item => {
      <div key={randomString(~length=10)} className="flex flex-col gap-1">
        <p className={`${body.md.medium} text-nd_gray-500`}> {item.title->React.string} </p>
        <div className="flex items-center gap-2">
          <RenderIf condition={item.icon->isNonEmptyString}>
            <GatewayIcon gateway={item.icon->String.toUpperCase} className="w-5 h-5" />
          </RenderIf>
          <p className={`text-nd_gray-600 ${body.lg.medium}`}> {item.value->React.string} </p>
        </div>
      </div>
    })
    ->React.array
  }
}

module MonthRangeSelector = {
  open DateTimeUtils

  let getMonthStart = (~month, ~year) => Date.makeWithYMDH(~year, ~month, ~date=1, ~hours=10)
  let getMonthEnd = (~month, ~year) => Date.makeWithYMD(~year, ~month=month + 1, ~date=0)
  let toYearMonth = date => date->Date.toString->getFormattedDate("YYYY-MM")
  let formatYearMonth = (year, month) =>
    `${year->Int.toString}-${(month + 1)->Int.toString->String.padStart(2, "0")}`

  @react.component
  let make = (~updateDateRange, ~initialStartDate, ~initialEndDate, ~isDisabled=false) => {
    let today = Date.make()
    let currentYear = today->Date.getFullYear
    let currentMonth = today->Date.getMonth
    let minYearMonth = formatYearMonth(currentYear - 2, currentMonth)
    let maxYearMonth = toYearMonth(today)

    let (selectedYear, setSelectedYear) = React.useState(_ => currentYear->Int.toString)
    let (showDateRange, setShowDateRange) = React.useState(_ => false)
    let (startDate, setStartDate) = React.useState(_ => initialStartDate)
    let (endDate, setEndDate) = React.useState(_ => initialEndDate)

    let monthRangeSelectorRef = React.useRef(Nullable.null)
    let isMobileView = MatchMedia.useMobileChecker()

    let monthRangeSelectorCss = isMobileView
      ? "absolute z-10 bg-white border w-full bottom-0 shadow-connectorTagShadow rounded-xl"
      : "absolute z-10 bg-white border w-20-rem right-0 top-12 shadow-connectorTagShadow rounded-xl"

    let getYear = () => selectedYear->getIntFromString(currentYear)

    let changeYear = delta => {
      let newYear = getYear() + delta
      if newYear <= currentYear && newYear >= currentYear - 2 {
        setSelectedYear(_ => newYear->Int.toString)
      }
    }

    let isMonthValid = monthIndex => {
      let yearMonth = formatYearMonth(getYear(), monthIndex)
      yearMonth >= minYearMonth && yearMonth <= maxYearMonth
    }

    let handleSelect = monthIndex => {
      if isMonthValid(monthIndex) {
        let year = getYear()
        let clickedDate = getMonthStart(~month=monthIndex, ~year)
        let clickedYearMonth = toYearMonth(clickedDate)

        if startDate->isEmptyString || endDate->isNonEmptyString {
          setStartDate(_ => clickedDate->Date.toString)
          setEndDate(_ => "")
        } else {
          let startYearMonth = toYearMonth(startDate->Date.fromString)
          if clickedYearMonth >= startYearMonth {
            setEndDate(_ => getMonthEnd(~month=monthIndex, ~year)->Date.toString)
          } else {
            let prevStart = startDate->Date.fromString
            let newEndDate = getMonthEnd(
              ~month=prevStart->Date.getMonth,
              ~year=prevStart->Date.getFullYear,
            )
            setStartDate(_ => clickedDate->Date.toString)
            setEndDate(_ => newEndDate->Date.toString)
          }
        }
      }
    }

    let isInSelectedRange = monthIndex => {
      startDate->isNonEmptyString &&
      endDate->isNonEmptyString && {
        let monthDate = getMonthStart(~month=monthIndex, ~year=getYear())
        monthDate >= startDate->Date.fromString && monthDate <= endDate->Date.fromString
      }
    }

    let handleCancel = () => {
      setStartDate(_ => initialStartDate)
      setEndDate(_ => initialEndDate)
      setShowDateRange(_ => false)
    }

    let onApply = () => {
      if endDate->isNonEmptyString {
        updateDateRange(
          ~startDate=startDate->getFormattedDate("YYYY-MM-DD"),
          ~endDate=endDate->getFormattedDate("YYYY-MM-DD"),
        )
        setShowDateRange(_ => false)
      }
    }

    let getCssClass = monthIndex => {
      if !isMonthValid(monthIndex) {
        "bg-grey-light text-grey-medium cursor-not-allowed"
      } else {
        let monthYearMonth = getMonthStart(~month=monthIndex, ~year=getYear())->toYearMonth
        let startYearMonth =
          startDate->isNonEmptyString ? startDate->Date.fromString->toYearMonth : ""
        let endYearMonth = endDate->isNonEmptyString ? endDate->Date.fromString->toYearMonth : ""

        switch (startYearMonth === monthYearMonth, endYearMonth === monthYearMonth) {
        | (true, true) => "bg-nd_primary_blue-450 text-white rounded-md"
        | (true, false) => "bg-nd_primary_blue-450 text-white rounded-l-md"
        | (false, true) => "bg-nd_primary_blue-450 text-white rounded-r-md"
        | (false, false) =>
          isInSelectedRange(monthIndex)
            ? "bg-nd_primary_blue-50 text-nd_gray-600"
            : "hover:bg-nd_gray-25 text-nd_gray-600"
        }
      }
    }

    let getButtonText = () => {
      startDate->isNonEmptyString && endDate->isNonEmptyString
        ? `${startDate->getFormattedDate("MMM YY")} - ${endDate->getFormattedDate("MMM YY")}`
        : "Select month range"
    }

    OutsideClick.useOutsideClick(
      ~refs=ArrayOfRef([monthRangeSelectorRef]),
      ~isActive=showDateRange,
      ~callback=() => {
        handleCancel()
      },
    )

    <div className="relative" ref={monthRangeSelectorRef->ReactDOM.Ref.domRef}>
      <RenderIf condition={showDateRange}>
        <div className=monthRangeSelectorCss>
          <div className="flex justify-between p-4">
            <div className="flex items-center gap-1">
              <RenderIf condition={startDate->isNonEmptyString}>
                <p className={body.lg.semibold}>
                  {startDate->getFormattedDate("MMM YYYY")->React.string}
                </p>
              </RenderIf>
              {endDate->isNonEmptyString
                ? <>
                    <p className={body.lg.semibold}> {"-"->React.string} </p>
                    <p className={body.lg.semibold}>
                      {endDate->getFormattedDate("MMM YYYY")->React.string}
                    </p>
                  </>
                : React.null}
            </div>
            <div
              className="flex gap-2 items-center"
              onClick={ev => ev->ReactEvent.Mouse.stopPropagation}>
              <Icon className="cursor-pointer" name="angle-left" onClick={_ => changeYear(-1)} />
              <p> {selectedYear->React.string} </p>
              <Icon className="cursor-pointer" name="angle-right" onClick={_ => changeYear(1)} />
            </div>
          </div>
          <hr />
          <div className="grid grid-cols-3 p-4 gap-y-4">
            {months
            ->Array.mapWithIndex((month, index) =>
              <div
                key={(month :> string)}
                onClick={_ => handleSelect(index)}
                className={`p-2 ${body.lg.medium} ${index->getCssClass}`}>
                {(month :> string)->React.string}
              </div>
            )
            ->React.array}
          </div>
          <hr />
          <div className="flex p-4 justify-end gap-3">
            <Button
              text="Cancel" buttonType={Secondary} onClick={_ => handleCancel()} buttonSize={Small}
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
