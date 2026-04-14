module PaymentMethodDetails = {
  @react.component
  let make = (~data) => {
    <div className="flex flex-col gap-6">
      <div
        className="font-semibold text-nd_gray-700 leading-6 text-fs-18 dark:text-white dark:text-opacity-75">
        {"Payment Method Details"->React.string}
      </div>
      <div className="border rounded-md py-6 px-10 bg-nd_gray-25">
        <ReactSyntaxHighlighter.SyntaxHighlighter
          wrapLines={false}
          wrapLongLines=true
          style={ReactSyntaxHighlighter.lightfair}
          language="json"
          showLineNumbers={true}
          lineNumberContainerStyle={{
            paddingLeft: "0px",
            backgroundColor: "red",
            padding: "0px",
          }}
          customStyle={{
            backgroundColor: "transparent",
            fontSize: "0.875rem",
            padding: "0px",
          }}>
          {data->JSON.stringifyWithIndent(2)}
        </ReactSyntaxHighlighter.SyntaxHighlighter>
      </div>
    </div>
  }
}

module PSPTokens = {
  @react.component
  let make = (~data) => {
    let (offset, setOffset) = React.useState(() => 0)

    <div className="flex flex-col gap-6">
      <div
        className="font-semibold text-fs-18 text-nd_gray-700 leading-6 dark:text-white dark:text-opacity-75">
        {"PSP Tokens"->React.string}
      </div>
      <LoadedTable
        title="PSP Tokens"
        hideTitle=true
        resultsPerPage=7
        entity={VaultPSPTokensEntity.pspTokensEntity}
        actualData={data->Array.map(Nullable.make)}
        totalResults={data->Array.length}
        offset
        setOffset
        currentFetchCount={data->Array.length}
        showAutoScroll=true
      />
    </div>
  }
}

module NetworkTokens = {
  @react.component
  let make = (~data) => {
    <div className="flex flex-col gap-6">
      <div
        className="font-semibold text-nd_gray-700 leading-6 text-fs-18 dark:text-white dark:text-opacity-75">
        {"Network Tokens"->React.string}
      </div>
      <div className="border rounded-md py-6 px-10 bg-nd_gray-25">
        <ReactSyntaxHighlighter.SyntaxHighlighter
          wrapLines={false}
          wrapLongLines=true
          style={ReactSyntaxHighlighter.lightfair}
          language="json"
          showLineNumbers={true}
          lineNumberContainerStyle={{
            paddingLeft: "0px",
            backgroundColor: "red",
            padding: "0px",
          }}
          customStyle={{
            backgroundColor: "transparent",
            fontSize: "0.875rem",
            padding: "0px",
          }}>
          {data->JSON.stringifyWithIndent(2)}
        </ReactSyntaxHighlighter.SyntaxHighlighter>
      </div>
    </div>
  }
}

@react.component
let make = (~paymentId, ~setShowModal, ~sampleReport) => {
  open APIUtils
  open VaultPaymentMethodDetailsTypes
  open LogicUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let (paymentsDetailsData, setPaymentsDetailsData) = React.useState(() =>
    JSON.Encode.null->VaultPaymentMethodDetailsUtils.itemToObjMapper
  )
  let defaultObject = JSON.Encode.null->VaultPaymentMethodDetailsUtils.itemToObjMapper
  let fetchPaymentMethodDetails = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(
        ~entityName=V2(RETRIEVE_PAYMENT_METHOD),
        ~methodType=Get,
        ~id=Some(paymentId),
      )

      let response = await fetchDetails(url, ~version=V2)
      setPaymentsDetailsData(_ => response->VaultPaymentMethodDetailsUtils.itemToObjMapper)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error(""))
    }
  }

  let fetchDummyData = () => {
    let response = VaultSampleData.retrievePMT
    let data =
      response
      ->getDictFromJsonObject
      ->getArrayFromDict("data", [])
      ->VaultPaymentMethodDetailsUtils.getArrayOfPaymentMethodListPayloadType
    let selectedDataArray = data->Array.filter(item => {item.id == paymentId})

    let selectedDataObject = selectedDataArray->getValueFromArray(0, defaultObject)

    setPaymentsDetailsData(_ => selectedDataObject)
  }
  React.useEffect(() => {
    if !sampleReport {
      fetchPaymentMethodDetails()->ignore
    } else {
      fetchDummyData()->ignore
    }
    None
  }, [])

  <PageLoaderWrapper screenState>
    <div className="bg-white height-screen">
      <div className="pt-8 pb-6 px-8 flex justify-between align-top ">
        <div
          className={`font-semibold text-nd_gray-600 text-fs-24 leading-6 dark:text-white dark:text-opacity-75`}>
          {paymentId->React.string}
        </div>
        <div className="h-fit" onClick={_ => setShowModal(_ => false)}>
          <Icon name="nd-cross" className="cursor-pointer" size=30 />
        </div>
      </div>
      <hr />
      <div className="px-8 py-6 flex flex-col gap-8 h-full">
        <NetworkTokens data={paymentsDetailsData.network_tokens} />
        <PaymentMethodDetails data={paymentsDetailsData.payment_method_data.card} />
        <PSPTokens data={paymentsDetailsData.connector_tokens} />
      </div>
    </div>
  </PageLoaderWrapper>
}
