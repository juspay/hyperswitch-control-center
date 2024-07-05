type statChartColor = [#blue | #grey]

type tableRowType = {
  rowLabel: string,
  rowValue: float,
}

type cols =
  | Label
  | Value

let visibleColumns = [Label, Value]

let colMapper = (col: cols) => {
  switch col {
  | Label => "rowLabel"
  | Value => "rowValue"
  }
}

let tableItemToObjMapper: 'a => tableRowType = dict => {
  open LogicUtils

  {
    {
      rowLabel: dict->getString(Label->colMapper, "NA"),
      rowValue: dict->getFloat(Value->colMapper, 0.0),
    }
  }
}

let getObjects: JSON.t => array<tableRowType> = json => {
  open LogicUtils
  json
  ->LogicUtils.getArrayFromJson([])
  ->Array.map(item => {
    tableItemToObjMapper(item->getDictFromJsonObject)
  })
}

let getHeading = colType => {
  let key = colType->colMapper
  switch colType {
  | Label => Table.makeHeaderInfo(~key, ~title="Currency", ~dataType=TextType, ~showSort=false, ())
  | Value => Table.makeHeaderInfo(~key, ~title="Amount", ~dataType=TextType, ~showSort=false, ())
  }
}

let percentFormat = value => {
  `${Float.toFixedWithPrecision(value, ~digits=2)}%`
}

type statType = Amount | Rate | NegativeRate | Volume | Latency | LatencyMs | Default

let stringToVarient = statType => {
  switch statType {
  | "Amount" => Amount
  | "Rate" => Rate
  | "NegativeRate" => NegativeRate
  | "Volume" => Volume
  | "Latency" => Latency
  | "LatencyMs" => LatencyMs
  | _ => Default
  }
}

// if day > then only date else time
let statValue = (val, statType) => {
  let statType = statType->stringToVarient
  open LogicUtils
  switch statType {
  | Amount => val->indianShortNum
  | Rate | NegativeRate => val->Js.Float.isNaN ? "-" : val->percentFormat
  | Volume => val->indianShortNum
  | Latency => latencyShortNum(~labelValue=val, ())
  | LatencyMs => latencyShortNum(~labelValue=val, ~includeMilliseconds=true, ())
  | Default => val->Float.toString
  }
}

let getCell = (obj, colType, stateType): Table.cell => {
  switch colType {
  | Label => Text(obj.rowLabel)
  | Value => Text(obj.rowValue->statValue(stateType))
  }
}

module ShowMore = {
  @react.component
  let make = (~value: array<tableRowType>, ~title, ~tableEntity) => {
    let (showModal, setShowModal) = React.useState(_ => false)
    let (offset, setOffset) = React.useState(_ => 0)
    let defaultSort: Table.sortedObject = {
      key: "",
      order: Table.INC,
    }

    let tableData = if value->Array.length > 0 {
      value->Array.map(item => {
        item->Nullable.make
      })
    } else {
      []
    }

    let tableBorderClass = "border-collapse border border-jp-gray-940 border-solid border-2 border-opacity-30 dark:border-jp-gray-dark_table_border_color dark:border-opacity-30"

    <>
      <div
        className="flex text-blue-900 text-sm font-bold cursor-pointer justify-end w-full"
        onClick={_ => setShowModal(_ => !showModal)}>
        {"more.."->React.string}
      </div>
      <Modal
        closeOnOutsideClick=true
        modalHeading=title
        showModal
        setShowModal
        modalClass="w-full max-w-lg mx-auto md:mt-44 ">
        <LoadedTable
          visibleColumns
          title=" "
          hideTitle=true
          actualData={tableData}
          entity=tableEntity
          resultsPerPage=10
          totalResults={tableData->Array.length}
          offset
          setOffset
          defaultSort
          currrentFetchCount={tableData->Array.length}
          tableLocalFilter=false
          tableheadingClass=tableBorderClass
          showResultsPerPageSelector=false
          tableBorderClass
          ignoreHeaderBg=true
          tableDataBorderClass=tableBorderClass
          isAnalyticsModule=true
        />
      </Modal>
    </>
  }
}

@react.component
let make = (
  ~deltaTooltipComponent=React.null,
  ~value: array<tableRowType>,
  ~title="",
  ~tooltipText="",
  ~statType="",
  ~borderRounded="rounded-lg",
  ~singleStatLoading=false,
  ~showPercentage=true,
  ~loaderType: AnalyticsUtils.loaderType=Shimmer,
  ~statChartColor: statChartColor=#blue,
  ~filterNullVals: bool=false,
  ~statSentiment: Dict.t<AnalyticsUtils.statSentiment>=Dict.make(),
  ~statThreshold: Dict.t<float>=Dict.make(),
) => {
  let isMobileWidth = MatchMedia.useMatchMedia("(max-width: 700px)")

  let tableEntity = EntityType.makeEntity(
    ~uri=``,
    ~getObjects,
    ~dataKey="",
    ~defaultColumns=visibleColumns,
    ~requiredSearchFieldsList=[],
    ~allColumns=visibleColumns,
    ~getCell=(tableRowType, cols) => getCell(tableRowType, cols, statType),
    ~getHeading,
    (),
  )

  if singleStatLoading && loaderType === Shimmer {
    <div className={`p-4`} style={ReactDOMStyle.make(~width=isMobileWidth ? "100%" : "33.33%", ())}>
      <Shimmer styleClass="w-full h-28" />
    </div>
  } else {
    <div
      className={`mt-4`} style={ReactDOMStyle.make(~width=isMobileWidth ? "100%" : "33.33%", ())}>
      <div
        className={`h-full flex flex-col border ${borderRounded} dark:border-jp-gray-850 bg-white dark:bg-jp-gray-lightgray_background overflow-hidden singlestatBox p-2 md:mr-4`}>
        <div className="p-4 flex flex-col justify-between h-full gap-2">
          <UIUtils.RenderIf condition={singleStatLoading && loaderType === SideLoader}>
            <div className="animate-spin self-end absolute">
              <Icon name="spinner" size=16 />
            </div>
          </UIUtils.RenderIf>
          <div className={"flex gap-2 items-center text-jp-gray-700 font-bold self-start"}>
            <div className="font-semibold text-base text-black dark:text-white">
              {title->React.string}
            </div>
            <ToolTip
              description=tooltipText
              toolTipFor={<div className="cursor-pointer">
                <Icon name="info-vacent" size=13 />
              </div>}
              toolTipPosition=ToolTip.Top
              newDesign=true
            />
          </div>
          <div className="flex gap-1 flex-col w-full mt-1">
            {if value->Array.length > 0 {
              <>
                {value
                ->Array.filterWithIndex((_val, index) => index < 5)
                ->Array.mapWithIndex((item, index) => {
                  <div
                    key={index->Int.toString}
                    className="flex justify-between w-full text-sm opacity-70">
                    <div> {item.rowLabel->React.string} </div>
                    <div> {item.rowValue->statValue(statType)->React.string} </div>
                  </div>
                })
                ->React.array}
                <UIUtils.RenderIf condition={value->Array.length > 5}>
                  <ShowMore value title tableEntity />
                </UIUtils.RenderIf>
              </>
            } else {
              <div
                className="w-full border flex justify-center border-dashed text-sm opacity-70 rounded-lg p-5">
                {"No Data"->React.string}
              </div>
            }}
          </div>
        </div>
      </div>
    </div>
  }
}
