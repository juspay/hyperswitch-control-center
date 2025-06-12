module TotalNumbersViewCard = {
  @react.component
  let make = (~title, ~count, ~countTextCss="font-semibold text-2xl text-nd_gray-600") => {
    <div
      className={`flex flex-col  gap-3 h-20 justify-between bg-white text-semibold border rounded-md pt-3 px-4 pb-2.5 w-306-px my-8 border-nd_gray-150`}>
      <p className="font-medium text-xs text-nd_gray-400"> {title->React.string} </p>
      <RenderIf condition={!(count->LogicUtils.isEmptyString)}>
        <p className=countTextCss> {count->React.string} </p>
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
    let (componentState, setComponentState) = React.useState(_ => VaultCustomersType.Error)

    let getTokenCount = async () => {
      setComponentState(_ => Loading)
      try {
        let customersUrl = getURL(~entityName=V2(TOTAL_TOKEN_COUNT), ~methodType=Get)
        let response = await fetchDetails(customersUrl, ~version=V2)
        let totalCount = response->getDictFromJsonObject->getInt("total_count", 0)
        setTokenCount(_ => totalCount)

        setComponentState(_ => Success)
      } catch {
      | Exn.Error(_) => setComponentState(_ => Error)
      }
    }
    let totalTokenComponent = {
      switch componentState {
      | Loading =>
        <div className="flex items-center">
          <TotalNumbersViewCard
            title="Total Vaulted Payment Methods"
            count="Fetching Data ..."
            countTextCss="font-semibold text-sm text-nd_gray-500"
          />
        </div>
      | Success =>
        <TotalNumbersViewCard
          title="Total Vaulted Payment Methods"
          count={`${tokenCount <= 0 ? "-" : tokenCount->Int.toString}`}
        />
      | Error =>
        <TotalNumbersViewCard
          title="Total Vaulted Payment Methods"
          count="Error fetching data"
          countTextCss="font-semibold text-sm text-nd_gray-500"
        />
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

    {
      totalTokenComponent
    }
  }
}

@react.component
let make = (~sampleReport, ~custCount) => {
  let custDisplaycount = ` ${custCount->Int.toString}`

  <div className="flex flex-row gap-2">
    <TotalNumbersViewCard
      title="Total Customers" count={`${custCount <= 0 ? "-" : custDisplaycount} `}
    />
    <VaultTotalTokens sampleReport />
  </div>
}
