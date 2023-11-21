type errorObject = {
  error_reason: string,
  count: string,
  percentage: string,
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
    count: dict->getString(Count->colMapper, "NA"),
    percentage: dict->getString(Percentage->colMapper, "NA"),
  }
}

let getObjects: Js.Json.t => array<errorObject> = json => {
  open LogicUtils
  json
  ->LogicUtils.getArrayFromJson([])
  ->Js.Array2.map(item => {
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
  | Count => Text(errorObj.count)
  | Percentage => Text(errorObj.percentage)
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
let make = (~errorMessage) => {
  let (showModal, setShowModal) = React.useState(_ => false)
  let (offset, setOffset) = React.useState(_ => 0)

  let defaultSort: Table.sortedObject = {
    key: "",
    order: Table.INC,
  }

  let errors =
    errorMessage
    ->Js.String2.split("$$")
    ->Js.Array2.filter(err => err->Js.String2.length > 0)
    ->Js.Array2.map(Js.String2.trim)
    ->Js.Array2.reverseInPlace

  let getCellText = {
    let errorStr =
      errors
      ->Belt.Array.get(0)
      ->Belt.Option.getWithDefault("Error Reasons")
      ->Js.String2.slice(~from=0, ~to_=15)

    `${errorStr}...`
  }

  let getItem = (arr, index) => arr->Belt.Array.get(index)->Belt.Option.getWithDefault("")

  let tableData = if errors->Js.Array2.length > 0 {
    errors->Js.Array2.map(item => {
      let arr = item->Js.String2.split("(")
      let error_reason = arr->getItem(0)
      let percentage = arr->getItem(1)->Js.String2.split(")")->getItem(0)
      let count = arr->getItem(2)->Js.String2.split(")")->getItem(0)

      {
        error_reason,
        percentage,
        count,
      }->Js.Nullable.return
    })
  } else {
    []
  }

  let tableBorderClass = "border-collapse border border-jp-gray-940 border-solid border-2 rounded-sm border-opacity-30 dark:border-jp-gray-dark_table_border_color dark:border-opacity-30 -mt-4"

  <>
    {if errors->Js.Array2.length > 0 {
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
      <div className="border-t-1 border-x-1">
        <LoadedTable
          visibleColumns
          title=" "
          hideTitle=true
          actualData={tableData}
          entity=tableEntity
          resultsPerPage=10
          totalResults={tableData->Js.Array2.length}
          offset
          setOffset
          defaultSort
          currrentFetchCount={tableData->Js.Array2.length}
          tableLocalFilter=false
          tableheadingClass=tableBorderClass
          tableBorderClass
          tableDataBorderClass=tableBorderClass
          isAnalyticsModule=true
        />
      </div>
    </Modal>
  </>
}
