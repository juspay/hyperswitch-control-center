module ShowFieldValues = {
  @react.component
  let make = (~fieldName, ~dataObj: Table.cell) => {
    <div className="grid  grid-cols-2 mt-3 mb-3">
      <div> {React.string(fieldName)} </div>
      <div className="font-semibold">
        {switch (dataObj: Table.cell) {
        | Label(x) => <Table.LabelCell labelColor=x.color text=x.title />
        | Text(x) => <CardTable.TextCard text=x />
        | Currency(amount, currency) => <Table.MoneyCell amount currency isCard=true />
        | Link(x) => <Table.LinkCell data=x />
        | Date(timestamp) => <Table.DateCell timestamp isCard=true />
        | StartEndDate(startDate, endDate) =>
          <Table.StartEndDateCell startDate endDate isCard=true />
        | _ => React.null
        }}
      </div>
    </div>
  }
}

module ShowPageLayout = {
  @react.component
  let make = (~rowData, ~heading: array<Table.header>, ~title) => {
    let (isExpanded, setIsExpanded) = React.useState(_ => true)
    <div className="flex flex-1 flex-col overflow-scroll pt-4 pl-1 pr-2">
      <div className="flex flex-col justify-between">
        <div
          className="flex flex-row justify-between p-4 font-bold border border-jp-gray-500  from-gray-100 bg-gradient-to-b from-jp-gray-200 to-jp-gray-300 dark:from-jp-gray-950  dark:to-jp-gray-950 text-jp-gray-800 dark:text-jp-gray-text_darktheme dark:text-opacity-75 whitespace-pre h-14">
          <div className="justify-items-center"> {React.string(title)} </div>
          <div
            className="flex flex-row cursor-pointer justify-items-center"
            onClick={_ => setIsExpanded(prev => !prev)}>
            <div className="mt-1">
              <Icon name={isExpanded ? "compress-alt" : "expand-alt"} size=13 />
            </div>
            <div className="font-normal ml-1">
              {React.string(isExpanded ? "Collapse" : "Expand")}
            </div>
          </div>
        </div>
      </div>
      {if isExpanded {
        <div className="pl-4 border border-jp-gray-500 dark:border-jp-gray-960 grid grid-cols-2">
          {rowData
          ->Js.Array2.mapi((obj, fieldIndex) => {
            switch heading[fieldIndex] {
            | Some(head) =>
              <div key={fieldIndex->string_of_int}>
                <ShowFieldValues fieldName={head.title} dataObj={obj} />
              </div>
            | None => React.null
            }
          })
          ->React.array}
        </div>
      } else {
        React.null
      }}
    </div>
  }
}

@react.component
let make = (
  ~json: Js.Json.t,
  ~detailsArray: array<'colType>,
  ~getHeading: 'colType => Table.header,
  ~getCell: ('t, 'colType) => Table.cell,
  ~title: string,
  ~itemToObjMapper: Js.Dict.t<Js.Json.t> => 't,
) => {
  switch json->Js.Json.decodeObject {
  | Some(dict) => {
      let detailsObject = itemToObjMapper(dict)
      let rowData = detailsArray->Js.Array2.map(colType => {
        getCell(detailsObject, colType)
      })
      let heading = detailsArray->Js.Array2.map(getHeading)
      <ShowPageLayout rowData heading title />
    }

  | _ => React.null
  }
}
