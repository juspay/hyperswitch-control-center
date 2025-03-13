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

module VaultTotalTokens = {
  @react.component
  let make = (~sampleReport) => {
    open APIUtils
    open LogicUtils

    let getURL = useGetURL()
    let fetchDetails = useGetMethod()
    let (tokenCount, setTokenCount) = React.useState(_ => 0)
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)

    let getTokenCount = async () => {
      setScreenState(_ => PageLoaderWrapper.Loading)
      try {
        let customersUrl = getURL(~entityName=V2(TOTAL_TOKEN_COUNT), ~methodType=Get)
        let response = await fetchDetails(customersUrl, ~version=V2)
        let totalCount = response->getDictFromJsonObject->getInt("total_count", 0)
        setTokenCount(_ => totalCount)

        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | Exn.Error(e) =>
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        setScreenState(_ => PageLoaderWrapper.Error(err))
      }
    }

    let fetchDummyData = () => {
      let response = VaultSampleData.pmCount
      let totalCount = response->getDictFromJsonObject->getInt("total_count", 0)
      setTokenCount(_ => totalCount)
    }

    React.useEffect(() => {
      if !sampleReport {
        getTokenCount()->ignore
      } else {
        fetchDummyData()->ignore
      }
      None
    }, [sampleReport])

    <PageLoaderWrapper screenState>
      <TotalNumbersViewCard
        title="Total Vaulted Payment Methods"
        count={`${tokenCount <= 0 ? "-" : tokenCount->Belt.Int.toString}`}
      />
    </PageLoaderWrapper>
  }
}

@react.component
let make = (~sampleReport, ~custCount) => {
  let custDisplaycount = ` ${custCount->Belt.Int.toString}`

  <div className="flex flex-row gap-2">
    <TotalNumbersViewCard
      title="Total Customers" count={`${custCount <= 0 ? "-" : custDisplaycount} `}
    />
    <VaultTotalTokens sampleReport />
  </div>
}
