open LogicUtils
type loadDataType = Loading | Loaded(Js.Dict.t<Js.Json.t>, Js.Dict.t<Js.Json.t>) | LoadError(string)

type errorType = {
  error: bool,
  errorMessage: string,
  userMessage: string,
}

module EntityData = {
  @react.component
  let make = (
    ~dictData: Js.Dict.t<Js.Json.t>,
    ~syncData=Dict.make(),
    ~detailsKeyList,
    ~entity: EntityType.entityType<'colType, 't>,
  ) => {
    <div className="flex flex-1 flex-col overflow-scroll  pl-1 pr-2">
      {detailsKeyList
      ->Array.mapWithIndex((key: string, idx) => {
        switch Dict.get(syncData, key) {
        | Some(json) => <div key={idx->string_of_int}> {entity.detailsPageLayout(json, key)} </div>
        | _ =>
          switch Dict.get(dictData, key) {
          | Some(json) =>
            <div key={idx->string_of_int}> {entity.detailsPageLayout(json, key)} </div>
          | _ => React.null
          }
        }
      })
      ->React.array}
    </div>
  }
}

module MerchantDetails = {
  @react.component
  let make = (~dictData, ~syncData, ~detailsKeyList, ~entity) => {
    let merchantId = dictData->getString("merchantId", "-")
    let parentMerchantId = dictData->getString("parentMerchantId", "-")
    let (isExpanded, setIsExpanded) = React.useState(_ => true)
    <div className="flex flex-col border border-jp-gray-500 mt-4  dark:border-jp-gray-960">
      <div className="flex flex-col justify-between">
        <div
          className="flex flex-row justify-between p-4 font-bold border-4 border-jp-gray-500  from-gray-100 bg-gradient-to-b from-jp-gray-200 to-jp-gray-300 dark:from-jp-gray-950  dark:to-jp-gray-950 text-jp-gray-800 dark:text-jp-gray-text_darktheme dark:text-opacity-75 whitespace-pre">
          <div className="justify-items-center  font-bold text-2xl">
            {React.string("Merchant Details")}
          </div>
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
        <>
          <div className="p-4   grid grid-cols-2">
            <div className="flex flex-row justify-between">
              <div>
                <span> {React.string("Merchant ID :")} </span>
                <span className="ml-2 font-bold"> {React.string(merchantId)} </span>
              </div>
              <div>
                <span> {React.string("Parent Merchant ID :")} </span>
                <span className="ml-2 font-bold"> {React.string(parentMerchantId)} </span>
              </div>
            </div>
          </div>
          <EntityData dictData syncData detailsKeyList entity />
        </>
      } else {
        React.null
      }}
    </div>
  }
}
