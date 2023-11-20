module PageLayout = {
  @react.component
  let make = (~title, ~keyVals: array<(Table.header, Table.cell)>) => {
    <div className="flex flex-1 flex-col overflow-scroll pt-4 pl-1 pr-2">
      <div
        className="p-4 block from-gray-500 bg-gradient-to-b from-jp-gray-200 to-jp-gray-300 dark:from-jp-gray-950  dark:to-jp-gray-950 text-jp-gray-800 dark:text-jp-gray-text_darktheme dark:text-opacity-75 whitespace-pre">
        <div className="flex justify-between">
          <h4> {React.string(title)} </h4>
        </div>
      </div>
      <div className="pl-4 border border-jp-gray-500 dark:border-jp-gray-960 grid grid-cols-2">
        {keyVals
        ->Js.Array2.mapi((keyValObj, fieldIndex) => {
          let (heading: Table.header, cell: Table.cell) = keyValObj
          <div key={fieldIndex->string_of_int}>
            <div className="grid  grid-cols-2 mt-3 mb-3">
              <div> {React.string(heading.title)} </div>
              <div className="font-semibold">
                <CardTable.ItemValue cell />
              </div>
            </div>
          </div>
        })
        ->React.array}
      </div>
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
      let keyVals = detailsArray->Js.Array2.map(colType => {
        let heading = getHeading(colType)
        let cell = getCell(detailsObject, colType)

        (heading, cell)
      })

      <PageLayout keyVals title />
    }

  | _ => React.null
  }
}
