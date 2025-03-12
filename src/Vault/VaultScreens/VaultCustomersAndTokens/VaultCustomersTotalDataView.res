module TotalNumbersViewCard = {
  @react.component
  let make = (~title, ~count) => {
    <div
      className={`flex flex-col justify-center  gap-1 bg-white text-semibold border rounded-md pt-3 px-4 pb-2.5 w-306-px my-8 cursor-pointer hover:bg-gray-50 border-nd_gray-150`}>
      <p className="font-medium text-xs text-nd_gray-400"> {title->React.string} </p>
      <RenderIf condition={!(count->LogicUtils.isEmptyString)}>
        <p className="font-semibold text-2xl text-nd_gray-600"> {count->React.string} </p>
      </RenderIf>
    </div>
  }
}

@react.component
let make = (~sampleReport, ~custCount) => {
  open LogicUtils
  let custDisplaycount = ` ${custCount->Belt.Int.toString}`
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (tokenCount, setTokenCount) = React.useState(_ => 0)
  let getTokenCount = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      //To-do: Integrate api
      // let customersUrl = getURL(~entityName=V2(PAYMENT_METHOD_COUNT), ~methodType=Get)
      // let reponse = await fetchDetails(customersUrl)
      let response = sampleReport ? VaultSampleData.pmCount : {""}->Identity.genericTypeToJson

      let totalCount = response->getDictFromJsonObject->getInt("total_count", 0)
      setTokenCount(_ => totalCount)

      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }

  React.useEffect(() => {
    getTokenCount()->ignore
    None
  }, [sampleReport])

  <PageLoaderWrapper screenState>
    <div className="flex flex-row gap-2">
      <TotalNumbersViewCard
        title="Total Customers" count={`${custCount <= 0 ? "-" : custDisplaycount} `}
      />
      <TotalNumbersViewCard
        title="Total Vaulted Payment Methods"
        count={`${tokenCount <= 0 ? "-" : tokenCount->Belt.Int.toString}`}
      />
    </div>
  </PageLoaderWrapper>
}
