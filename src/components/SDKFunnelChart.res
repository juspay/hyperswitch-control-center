open HighchartFunnelChart
open LogicUtils
type colType =
  | Initiate
  | Render
  | MethodSelected
  | ProceedToPayClicked
  | TxnStatus
  | QuickPayRender
  | QuickPayOpt
  | QuickPayChange
  | QuickPayOverLayClick
  | QuickPayOverLayDrop
  | FunnelSteps
let defaultColumns = [Initiate, Render, MethodSelected, ProceedToPayClicked, TxnStatus]

let getHeading = colType => {
  switch colType {
  | Initiate =>
    Table.makeHeaderInfo(
      ~key="initiate",
      ~title="Payment Page Requested",
      ~showSort=false,
      ~showFilter=false,
      (),
    )
  | Render =>
    Table.makeHeaderInfo(
      ~key="render",
      ~title="Payment Page Rendered",
      ~showSort=false,
      ~showFilter=false,
      (),
    )
  | MethodSelected =>
    Table.makeHeaderInfo(
      ~key="methodSelecyed",
      ~title="Payment Option Selected",
      ~showSort=false,
      ~showFilter=false,
      (),
    )
  | ProceedToPayClicked =>
    Table.makeHeaderInfo(
      ~key="clicked",
      ~title="Proceed to Pay Clicked",
      ~showSort=false,
      ~showFilter=false,
      (),
    )
  | TxnStatus =>
    Table.makeHeaderInfo(
      ~key="txnStatus",
      ~title="Order Success",
      ~showSort=false,
      ~showFilter=false,
      (),
    )

  | FunnelSteps =>
    Table.makeHeaderInfo(
      ~key="funnelSteps",
      ~title="Funnel Steps",
      ~showSort=false,
      ~headerElement=<div className="font-medium flex flex-row gap-4 text-sm">
        {React.string("Funnel Steps")}
        <Icon name="arrow-right" size=12 />
      </div>,
      ~showFilter=false,
      (),
    )
  | QuickPayRender =>
    Table.makeHeaderInfo(
      ~key="quickPayRender",
      ~title="Quickpay Rendered",
      ~showSort=false,
      ~showFilter=false,
      (),
    )
  | QuickPayOpt =>
    Table.makeHeaderInfo(
      ~key="quickPayOpt",
      ~title="Quickpay Opted",
      ~showSort=false,
      ~showFilter=false,
      (),
    )
  | QuickPayChange =>
    Table.makeHeaderInfo(
      ~key="quickPayChange",
      ~title="Quickpay Changed",
      ~showSort=false,
      ~showFilter=false,
      (),
    )
  | QuickPayOverLayClick =>
    Table.makeHeaderInfo(
      ~key="quickpayoverlayclick",
      ~title="Quickpay Overlay Clicked",
      ~showSort=false,
      ~showFilter=false,
      (),
    )
  | QuickPayOverLayDrop =>
    Table.makeHeaderInfo(
      ~key="qpay",
      ~title="Quickpay overlay Dropped",
      ~showSort=false,
      ~showFilter=false,
      (),
    )
  }
}

module ShowDate = {
  let parseDateRange = (dateRangeStr: string): string => {
    /* Split the date range string into start and end date parts */
    let dateParts = Js.String.split(" to ", dateRangeStr)

    switch dateParts {
    | [startStr, endStr] =>
      /* Convert date strings to Date objects */
      let startDate = Js.Date.fromString(startStr)
      let endDate = Js.Date.fromString(endStr)

      /* Format dates into a human-readable format */

      let startDateStr = Js.Date.toDateString(startDate)
      let endDateStr = Js.Date.toDateString(endDate)

      /* Create the human-readable date range */
      let dateRangeReadable = startDateStr ++ " to " ++ endDateStr
      dateRangeReadable
    | _ => /* Handle invalid input */
      "Invalid date range format"
    }
  }
  @react.component
  let make = (~data, ~selectedRow, ~setSelectedRow) => {
    let value = data->Belt.Array.get(0)->Belt.Option.getWithDefault("")
    let onClick = _ => setSelectedRow(_ => value)
    <>
      <div className="flex cursor-pointer" onClick>
        <RadioIcon isSelected={value == selectedRow} />
        <div className={`pl-2 ${value == selectedRow ? "text-blue-800" : ""}`}>
          {React.string(value->parseDateRange)}
        </div>
      </div>
      <UIUtils.RenderIf condition={value == selectedRow}>
        <div className={`text-sm text-[#B9B7B7]  ml-6 mt-1`}>
          {React.string("Reference Date")}
        </div>
      </UIUtils.RenderIf>
    </>
  }
}
module RenderCompare = {
  @react.component
  let make = (~val1, ~val2) => {
    let value1 = val1->Belt.Float.fromString->Belt.Option.getWithDefault(0.)
    let value2 = val2->Belt.Float.fromString->Belt.Option.getWithDefault(0.)

    if value1 > value2 {
      //increase
      let change = value1 -. value2
      let percentageChange = change /. value2
      let str = (percentageChange *. 100.0)->Js.Math.round->Belt.Float.toString
      <div
        className="text-green-800 p-0.5 mt-1 bg-green-200 w-fit rounded-2xl text-[10px] flex pr-2">
        <Icon name="arrow-up" size=8 className={`mx-1 fill-[#B9BABE] dark:fill-slate-500`} />
        {React.string(`${str}%`)}
      </div>
    } else {
      let change = value2 -. value1
      let percentageChange = change /. value2
      let str = (percentageChange *. 100.0)->Js.Math.round->Belt.Float.toString
      <div className="text-red-800 p-0.5 mt-1 bg-red-200 w-fit rounded-2xl text-[10px] flex pr-2">
        <Icon name="arrow-down" size=8 className={`mx-1 fill-[#B9BABE] dark:fill-slate-500`} />
        {React.string(`${str}%`)}
      </div>
    }
  }
  // Module contents
}
module ShowData = {
  // Module contents
  @react.component
  let make = (~data, ~index, ~selectedRow, ~actualData) => {
    let valueDt = data->Belt.Array.get(0)->Belt.Option.getWithDefault("")
    let value = data->Belt.Array.get(index)->Belt.Option.getWithDefault("")
    let refData =
      actualData
      ->Js.Array2.filter(x => x->Belt.Array.get(0)->Belt.Option.getWithDefault("") == selectedRow)
      ->Belt.Array.get(0)
      ->Belt.Option.getWithDefault([])
    let refVal = refData->Belt.Array.get(index)->Belt.Option.getWithDefault("")
    let pctDrop = if index == 1 {
      0.0
    } else {
      let pastVal =
        data
        ->Belt.Array.get(index - 1)
        ->Belt.Option.getWithDefault("")
        ->Belt.Float.fromString
        ->Belt.Option.getWithDefault(0.)
      let currVal = value->Belt.Float.fromString->Belt.Option.getWithDefault(0.)
      let val = (pastVal -. currVal) /. pastVal
      if currVal == 0. {
        0.0
      } else {
        (val *. 100.0)->Js.Math.round
      }
    }
    <>
      <div className="flex">
        {React.string(
          shortNum(
            ~labelValue=value->Belt.Float.fromString->Belt.Option.getWithDefault(0.0),
            ~numberFormat=IND,
            (),
          ),
        )}
        <div className="pl-2 text-gray-500">
          {pctDrop == 0.0
            ? React.null
            : {React.string(`(-${pctDrop->Js.Math.abs_float->Js.Float.toString}%)`)}}
        </div>
      </div>
      <UIUtils.RenderIf condition={valueDt != selectedRow && value != "0" && refVal != "0"}>
        <ToolTip
          description="In comparision with reference date data"
          toolTipFor={<RenderCompare val1=value val2=refVal />}
          contentAlign=Left
          justifyClass="justify-start"
        />
      </UIUtils.RenderIf>
    </>
  }
}
let getIndexOfStep = (categories, keyName) => {
  Js.Array.indexOf(keyName, categories) + 1
}

let getCell = (selectedRow, setSelectedRow, actualData, categories, data, colType): Table.cell => {
  Js.log(categories)
  switch colType {
  | FunnelSteps => CustomCell(<ShowDate data selectedRow setSelectedRow />, "true")
  | Initiate =>
    CustomCell(
      <ShowData
        data index={getIndexOfStep(categories, "Payment Page Requested")} selectedRow actualData
      />,
      "",
    )
  | Render =>
    CustomCell(
      <ShowData
        data index={getIndexOfStep(categories, "Payment Page Rendered")} selectedRow actualData
      />,
      "",
    )
  | MethodSelected =>
    CustomCell(
      <ShowData
        data index={getIndexOfStep(categories, "Payment Option Selected")} selectedRow actualData
      />,
      "",
    )
  | ProceedToPayClicked =>
    CustomCell(
      <ShowData
        data index={getIndexOfStep(categories, "Proceed to Pay Clicked")} selectedRow actualData
      />,
      "",
    )
  | TxnStatus =>
    CustomCell(
      <ShowData data index={getIndexOfStep(categories, "Order Success")} selectedRow actualData />,
      "",
    )
  | QuickPayRender =>
    CustomCell(
      <ShowData
        data index={getIndexOfStep(categories, "Quickpay Rendered")} selectedRow actualData
      />,
      "",
    )
  | QuickPayOpt =>
    CustomCell(
      <ShowData data index={getIndexOfStep(categories, "Quickpay Opted")} selectedRow actualData />,
      "",
    )
  | QuickPayChange =>
    CustomCell(
      <ShowData
        data index={getIndexOfStep(categories, "Quickpay Change")} selectedRow actualData
      />,
      "",
    )
  | QuickPayOverLayClick =>
    CustomCell(
      <ShowData
        data index={getIndexOfStep(categories, "Quickpay Overlay Clicked")} selectedRow actualData
      />,
      "",
    )
  | QuickPayOverLayDrop =>
    CustomCell(
      <ShowData
        data index={getIndexOfStep(categories, "Quickpay Overlay Drop")} selectedRow actualData
      />,
      "",
    )
  }
}
let categoryToColMapper = category => {
  switch category {
  | "Payment Page Requested" => Initiate
  | "Payment Page Rendered" => Render
  | "Quickpay Rendered" => QuickPayRender
  | "Quickpay Opted" => QuickPayOpt
  | "Quickpay Change" => QuickPayChange
  | "Quickpay Overlay Clicked" => QuickPayOverLayClick
  | "Quickpay Overlay Drop" => QuickPayOverLayDrop
  | "Payment Option Selected" => MethodSelected
  | "Proceed to Pay Clicked" => ProceedToPayClicked
  | _ => TxnStatus
  }
}
type series = {name: string}
type data = {val: string}
type formatterType = {
  x: int,
  y: int,
  series: series,
}

type primaryDataLabel =
  | PERCENT
  | ABS_VOLUME
type finalSummaryLabel =
  | RATE
  | FINAL_STEP_VOLUME
type stepComparisonRule =
  | PREVIOUS_STEP
  | FIRST_STEP

type dataSetType = {
  fromPreviousStep: array<float>,
  fromFirstStep: array<float>,
  volume: array<float>,
}
@react.component
let make = (
  ~chartColors: array<string>=[],
  ~showTable: bool=true,
  ~dataSet: Js.Dict.t<array<float>>=Js.Dict.fromArray([("val", [7650., 4064., 1987., 976.])]),
  ~categories: array<string>=["Awareness", "Interest", "Consideration", "Purchase"],
  ~primaryDataLabel: primaryDataLabel=PERCENT,
  ~finalSummaryLabel: finalSummaryLabel=RATE,
  ~stepComparisonRule: stepComparisonRule=PREVIOUS_STEP,
  ~selectStepsUi=React.null,
) => {
  // will uncomment it for testing purpose
  // let dataSet: Js.Dict.t<array<float>> = Js.Dict.fromArray([
  //   ("val", [7650., 4064., 1987., 976.]),
  //   ("val2", [7050., 3064., 987., 1976.]),
  // ])
  // let categories: array<string> = ["Awareness", "Interest", "Consideration", "Purchase"]
  let formattedDict = Js.Dict.empty()
  dataSet
  ->DictionaryUtils.copyOfDict
  ->Js.Dict.entries
  ->Js.Array2.forEach(item => {
    let (key, value) = item
    let updateValueFromFirst = value->Js.Array2.mapi((item, index) => {
      if index === 0 {
        100.
      } else {
        item *. 100. /. value->Belt.Array.get(0)->Belt.Option.getWithDefault(0.)
      }
    })
    let updateValueFromPrevious = value->Js.Array2.mapi((item, index) => {
      if index === 0 {
        100.
      } else {
        item *. 100. /. value->Belt.Array.get(index - 1)->Belt.Option.getWithDefault(0.)
      }
    })
    formattedDict->Js.Dict.set(
      key,
      {
        fromPreviousStep: updateValueFromPrevious,
        fromFirstStep: updateValueFromFirst,
        volume: value,
      },
    )
  })

  let dataSet = if primaryDataLabel === PERCENT {
    dataSet
    ->Js.Dict.entries
    ->Js.Array2.map(item => {
      let (key, value) = item
      let updateValueFromFirst = value->Js.Array2.mapi((item, index) => {
        if index === 0 {
          100.
        } else {
          item *. 100. /. value->Belt.Array.get(0)->Belt.Option.getWithDefault(0.)
        }
      })
      (key, updateValueFromFirst)
    })
    ->Js.Dict.fromArray
  } else {
    dataSet
  }

  let mergedDict = Js.Dict.empty()

  dataSet
  ->Js.Dict.values
  ->Js.Array2.forEach(arrVal => {
    arrVal->Js.Array2.forEachi((item, index) => {
      DictionaryUtils.appnedDataToKey(mergedDict, index->Belt.Int.toString, item)
    })
  })

  let formatter: Js_OO.Callback.arity1<Js.Json.t => string> =
    @this
    (pointsJson: Js.Json.t) => {
      let pointsDict = pointsJson->getDictFromJsonObject
      let x_axis = pointsDict->getInt("x", 0)

      let color = pointsDict->getString("color", "")

      let deltaArr = if x_axis === 0 {
        let getValues =
          mergedDict->Js.Dict.get(x_axis->Belt.Int.toString)->Belt.Option.getWithDefault([])
        getValues->Js.Array2.mapi((item, index) => {
          let absValue = {shortNum(~labelValue=item, ~numberFormat=IND, ())}
          let value = primaryDataLabel === PERCENT ? `${absValue}%` : absValue
          let color = chartColors->Belt.Array.get(index)->Belt.Option.getWithDefault(color)
          `<div style='' class="flex flex-row justify-between items-center">
              <div class='flex h-2 w-2 rounded-full self-center mr-2' style='background-color: ${color}'"></div>
              <div>
                ${value}
              </div>
          </div>`
        })
      } else {
        let getValues =
          mergedDict->Js.Dict.get(x_axis->Belt.Int.toString)->Belt.Option.getWithDefault([])

        getValues->Js.Array2.mapi((item, index) => {
          let absValue = {shortNum(~labelValue=item, ~numberFormat=IND, ())}
          let value = primaryDataLabel === PERCENT ? `${absValue}%` : absValue
          let color = chartColors->Belt.Array.get(index)->Belt.Option.getWithDefault(color)

          `<div style='' class="flex flex-row justify-between items-center">
              <div class='flex h-2 w-2 rounded-full self-center mr-2' style='background-color: ${color}'"></div>
              <div>
                ${value}
              </div>
            </div>`
        })
      }

      `<div class='flex flex-row gap-2' style='padding: 8px; border-radius: 8px; border: 1px solid var(--Grey-900, #E5E7EB); background: rgba(255, 255, 255, 0.90); backdrop-filter: blur(1px);'>
        ${deltaArr->Js.Array2.joinWith(
          "<div style=' border-left: 1px solid rgba(234, 232, 232, 1); float: left;'></div>",
        )}
        </div>`
    }

  let tooltipFormatter = (points: HighchartFunnelChart.tooltipPoints) => {
    let highlight = "font-weight:900; font-size:13px;"
    let fromFirstValueArr = formattedDict->Js.Dict.values
    let formattedDictKeys = formattedDict->Js.Dict.keys

    let fromPreviousStep =
      fromFirstValueArr
      ->Js.Array2.map(item => {
        `<td>${shortNum(
            ~labelValue=item.fromPreviousStep
            ->Belt.Array.get(points.x)
            ->Belt.Option.getWithDefault(0.),
            ~numberFormat=IND,
            (),
          )}%</td>`
      })
      ->Js.Array2.joinWith("<th></th>")

    let fromFirstStep =
      fromFirstValueArr
      ->Js.Array2.map(item => {
        `<td>${shortNum(
            ~labelValue=item.fromFirstStep
            ->Belt.Array.get(points.x)
            ->Belt.Option.getWithDefault(0.),
            ~numberFormat=IND,
            (),
          )}%</td>`
      })
      ->Js.Array2.joinWith("<th></th>")

    let fromValues =
      fromFirstValueArr
      ->Js.Array2.map(item => {
        `<td>${shortNum(
            ~labelValue=item.volume->Belt.Array.get(points.x)->Belt.Option.getWithDefault(0.),
            ~numberFormat=IND,
            (),
          )}</td>`
      })
      ->Js.Array2.joinWith("<th></th>")
    let formattedHeading =
      formattedDict
      ->Js.Dict.keys
      ->Js.Array2.mapi((_, index) =>
        `<th><span style='color:${chartColors
          ->Belt.Array.get(index)
          ->Belt.Option.getWithDefault("")}; ${highlight}'> ${"\u25CF"} </span>Range${(index + 1)
            ->Belt.Int.toString}</th>`
      )
      ->Js.Array2.joinWith("<th></th>")

    if points.x === categories->Js.Array2.length {
      ""
    } else if points.name === formattedDictKeys->Belt.Array.get(0)->Belt.Option.getWithDefault("") {
      `<table>
        <tr>
          <th> </th>
          ${formattedHeading}
        </tr>
        <tr>
          <td><span>Conversion Rate from the Start</span></td>
          ${fromFirstStep}
        </tr>
        <tr>
          <td><span>Conversion Rate from the Previous</span></td>
          ${fromPreviousStep}
        </tr>
        <tr>
          <td><span>Total Volume</span></td>
          ${fromValues}
        </tr>
    </table>`
    } else {
      ""
    }
  }

  let yAxisLabelFormatter = value => {
    let value = if primaryDataLabel === PERCENT {
      LineChartUtils.formatStatsAccToMetrix(Rate, value)
    } else {
      LineChartUtils.formatStatsAccToMetrix(Volume, value)
    }
    value
  }

  let _legendFormatter = (this: HighchartFunnelChart.legendObj) => {
    let (fromFirstStepRate, volumeArr) = switch formattedDict->Js.Dict.get(this.userOptions.name) {
    | Some(value) => (value.fromFirstStep, value.volume)
    | None => ([], [])
    }

    if finalSummaryLabel === RATE {
      `<div style='background: ${this.color};color: var(--table-typography-body, #111); font-family: Inter; font-size: 18px; font-style: normal; font-weight: 600; line-height: normal;' class='py-1 px-3 rounded'>
        ${shortNum(
          ~labelValue=fromFirstStepRate
          ->Belt.Array.get(fromFirstStepRate->Js.Array2.length - 1)
          ->Belt.Option.getWithDefault(0.),
          ~numberFormat=IND,
          (),
        )}%
      </div>`
    } else {
      `<div style='background: ${this.color};color: var(--table-typography-body, #111); font-family: Inter; font-size: 18px; font-style: normal; font-weight: 600; line-height: normal;' class='py-1 px-3 rounded'>
         ${shortNum(
          ~labelValue=volumeArr
          ->Belt.Array.get(fromFirstStepRate->Js.Array2.length - 1)
          ->Belt.Option.getWithDefault(0.),
          ~numberFormat=IND,
          (),
        )}
      </div>`
    }
  }
  let legendTitle = if finalSummaryLabel === RATE {
    "Conversion Rate"
  } else {
    "Conversion Volume"
  }
  <>
    <div className="flex flex-row justify-between mb-5">
      {selectStepsUi}
      <div
        className="flex flex-row justify-between p-3 border-[1px] rounded-lg gap-2 items-center  border-[#E5E7EB]">
        <div
          style={ReactDOMStyle.make(
            ~color="#6D7280",
            ~fontFamily="Inter",
            ~fontSize="14px",
            ~fontStyle="normal",
            ~fontWeight="500",
            ~lineHeight="normal",
            (),
          )}>
          {legendTitle->React.string}
        </div>
        {formattedDict
        ->Js.Dict.entries
        ->Js.Array2.mapi((item, index) => {
          let (_, value) = item
          let {fromFirstStep, volume} = value
          if finalSummaryLabel === RATE {
            <div
              key={index->Belt.Int.toString}
              style={ReactDOMStyle.make(
                ~backgroundColor=chartColors->Belt.Array.get(index)->Belt.Option.getWithDefault(""),
                ~color="var(--table-typography-body, #111)",
                ~fontFamily="Inter",
                ~fontSize="16px",
                ~fontStyle="normal",
                ~fontWeight="600",
                ~lineHeight="normal",
                (),
              )}
              className="py-1 px-2 rounded">
              {`${shortNum(
                  ~labelValue=fromFirstStep
                  ->Belt.Array.get(fromFirstStep->Js.Array2.length - 1)
                  ->Belt.Option.getWithDefault(0.),
                  ~numberFormat=IND,
                  (),
                )}%`->React.string}
            </div>
          } else {
            <div
              style={ReactDOMStyle.make(
                ~backgroundColor=chartColors->Belt.Array.get(index)->Belt.Option.getWithDefault(""),
                ~color="var(--table-typography-body, #111)0",
                ~fontFamily="Inter",
                ~fontSize="16px",
                ~fontStyle="normal",
                ~fontWeight="600",
                ~lineHeight="normal",
                (),
              )}
              className="py-1 px-3 rounded">
              {`${shortNum(
                  ~labelValue=volume
                  ->Belt.Array.get(volume->Js.Array2.length - 1)
                  ->Belt.Option.getWithDefault(0.),
                  ~numberFormat=IND,
                  (),
                )}%`->React.string}
            </div>
          }
        })
        ->React.array}
      </div>
    </div>
    <HighchartFunnelChart
      dataSet
      categories
      chartColors
      formatter
      // legendFormatter
      // legendTitle
      tooltipFormatter
      yAxisLabelFormatter
    />
  </>
}

let getData: Js.Json.t => array<array<string>> = _json => {
  []
}
module SDKFunnelTable = {
  @react.component
  let make = (~funnelStepsValue: Js.Dict.t<array<float>>, ~categories) => {
    let (selectedRow, setSelectedRow) = React.useState(_ => "")
    let dataKeys = Js.Dict.keys(funnelStepsValue)
    let actualDataR =
      dataKeys->Js.Array2.map(key =>
        Js.Array2.concat(
          [key],
          Js.Dict.get(funnelStepsValue, key)
          ->Belt.Option.getWithDefault([])
          ->Js.Array2.map(x => x->Belt.Float.toString),
        )
      )
    let actualData = actualDataR->Js.Array2.map(Js.Nullable.return)
    let (offset, setOffset) = React.useState(_ => 10)
    Js.log(actualData)
    let defaultColumns =
      categories->Js.Array2.map(ele => ele->categoryToColMapper)->Js.Array.concat([FunnelSteps])
    React.useEffect1(() => {
      let defaultSelect = dataKeys->Belt.Array.get(0)->Belt.Option.getWithDefault("")
      setSelectedRow(_ => defaultSelect)

      None
    }, [funnelStepsValue])
    let entity = EntityType.makeEntity(
      ~uri="",
      ~getObjects=getData,
      ~defaultColumns,
      ~getHeading,
      ~getCell=getCell(selectedRow, setSelectedRow, actualDataR, categories),
      ~dataKey="",
      (),
    )
    <LoadedTable
      entity
      actualData
      title="dummy"
      totalResults=2
      resultsPerPage=10
      headBottomMargin="!gap-0"
      tableDataBorderClass="border-1 border-jp-2-light-gray-300"
      customCellColor="bg-[#F6F6F6]"
      selectedRowColor=""
      offset
      setOffset
      currrentFetchCount=10
      hideTitle=true
    />
  }
}
