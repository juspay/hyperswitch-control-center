type errorObject = {
  error_reason: string,
  count: int,
  percentage: float,
}

type cols =
  | ErrorReason
  | Count
  | Percentage

let visibleColumns = [ErrorReason, Count, Percentage]

let colMapper = (col: cols) => {
  switch col {
  | ErrorReason => "error_reason"
  | Count => "count"
  | Percentage => "percentage"
  }
}

let tableItemToObjMapper: 'a => errorObject = dict => {
  open LogicUtils
  {
    error_reason: dict->getString(ErrorReason->colMapper, "NA"),
    count: dict->getInt(Count->colMapper, 0),
    percentage: dict->getFloat(Percentage->colMapper, 0.0),
  }
}

let getObjects: Js.Json.t => array<errorObject> = json => {
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
  | ErrorReason =>
    Table.makeHeaderInfo(~key, ~title="Error Reason", ~dataType=TextType, ~showSort=false, ())
  | Count => Table.makeHeaderInfo(~key, ~title="Count", ~dataType=TextType, ~showSort=false, ())
  | Percentage =>
    Table.makeHeaderInfo(~key, ~title="Percentage", ~dataType=TextType, ~showSort=false, ())
  }
}

let getCell = (errorObj, colType): Table.cell => {
  switch colType {
  | ErrorReason => Text(errorObj.error_reason)
  | Count => Text(errorObj.count->Belt.Int.toString)
  | Percentage => Text(errorObj.percentage->Belt.Float.toString)
  }
}

let tableEntity = EntityType.makeEntity(
  ~uri=``,
  ~getObjects,
  ~dataKey="queryData",
  ~defaultColumns=visibleColumns,
  ~requiredSearchFieldsList=[],
  ~allColumns=visibleColumns,
  ~getCell,
  ~getHeading,
  (),
)

@react.component
let make = (~errors: array<AnalyticsTypes.error_message_type>) => {
  let (showModal, setShowModal) = React.useState(_ => false)
  let (offset, setOffset) = React.useState(_ => 0)

  let defaultSort: Table.sortedObject = {
    key: "",
    order: Table.INC,
  }

  let getCellText = {
    let errorStr = switch errors->Belt.Array.get(0) {
    | Some(val) => val.reason->String.slice(~start=0, ~end=15)
    | _ => "Error Reasons"
    }

    `${errorStr}...`
  }

  let tableData = if errors->Array.length > 0 {
    errors->Array.map(item => {
      {
        error_reason: item.reason,
        percentage: item.percentage,
        count: item.count,
      }->Js.Nullable.return
    })
  } else {
    []
  }

  let tableBorderClass = "border-collapse border border-jp-gray-940 border-solid border-2 border-opacity-30 dark:border-jp-gray-dark_table_border_color dark:border-opacity-30"

  <>
    {if errors->Array.length > 0 {
      <div
        className="underline underline-offset-4 font-medium cursor-pointer text-blue-900"
        onClick={_ => setShowModal(_ => !showModal)}>
        {getCellText->React.string}
      </div>
    } else {
      {"NA"->React.string}
    }}
    <Modal
      closeOnOutsideClick=true
      modalHeading="Top 5 Error Reasons"
      showModal
      setShowModal
      modalClass="w-full max-w-xl mx-auto md:mt-44 ">
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
        tableBorderClass
        ignoreHeaderBg=true
        tableDataBorderClass=tableBorderClass
        isAnalyticsModule=true
      />
    </Modal>
  </>
}
