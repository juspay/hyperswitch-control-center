module DisplayKeyValueParams = {
  @react.component
  let make = (
    ~showTitle: bool=true,
    ~heading: Table.header,
    ~value: Table.cell,
    ~isInHeader=false,
    ~isHorizontal=false,
    ~customMoneyStyle="",
    ~labelMargin="",
    ~customDateStyle="",
    ~wordBreak=true,
    ~textColor="",
    ~overiddingHeadingStyles="",
  ) => {
    let marginClass = if labelMargin->LogicUtils.isEmptyString {
      "mt-4 py-0"
    } else {
      labelMargin
    }

    let fontClass = if isInHeader {
      "text-fs-20"
    } else {
      "text-fs-13"
    }
    let breakWords = if wordBreak {
      "break-all"
    } else {
      ""
    }

    let textColor =
      textColor->LogicUtils.isEmptyString ? "text-jp-gray-900 dark:text-white" : textColor

    let description = heading.description->Option.getOr("")

    <AddDataAttributes attributes=[("data-label", heading.title)]>
      <div className={`flex ${isHorizontal ? "flex-row gap-3" : "flex-col gap-1"}`}>
        <div
          className="flex flex-row text-fs-11 leading-3 text-jp-gray-900 text-opacity-50 dark:text-jp-gray-text_darktheme dark:text-opacity-50 items-center">
          <div className={`${overiddingHeadingStyles}`}>
            {React.string(showTitle ? heading.title : "")}
          </div>
          <RenderIf condition={description->LogicUtils.isNonEmptyString}>
            <div className="text-sm text-gray-500 mx-2 -mt-1">
              <ToolTip description={description} toolTipPosition={ToolTip.Top} />
            </div>
          </RenderIf>
        </div>
        <div className={`${fontClass} font-semibold text-left  ${textColor} ${breakWords}`}>
          <Table.TableCell
            cell=value
            textAlign=Table.Left
            fontBold=true
            customMoneyStyle
            labelMargin=marginClass
            customDateStyle
          />
        </div>
      </div>
    </AddDataAttributes>
  }
}

module Details = {
  @react.component
  let make = (
    ~data,
    ~getHeading,
    ~getCell,
    ~excludeColKeys=[],
    ~detailsFields,
    ~justifyClassName="justify-start",
    ~widthClass="w-1/4",
    ~bgColor="bg-white dark:bg-jp-gray-lightgray_background",
  ) => {
    <FormRenderer.DesktopRow itemWrapperClass="mx-0">
      <div
        className={`grid grid-cols-3 ${justifyClassName} dark:bg-jp-gray-lightgray_background dark:border-jp-gray-no_data_border gap-y-8`}>
        {detailsFields
        ->Array.mapWithIndex((colType, i) => {
          <RenderIf condition={!(excludeColKeys->Array.includes(colType))} key={Int.toString(i)}>
            <div className={`flex ${widthClass} items-center col-span-1`}>
              <DisplayKeyValueParams
                heading={getHeading(colType)}
                value={getCell(data, colType)}
                customMoneyStyle="!font-normal !text-sm"
                labelMargin="!py-0 mt-2"
                overiddingHeadingStyles="text-gray-400 text-sm font-medium"
                textColor="!font-medium !text-nd_gray-600"
              />
            </div>
          </RenderIf>
        })
        ->React.array}
      </div>
    </FormRenderer.DesktopRow>
  }
}

module PaymentMethodDetails = {
  @react.component
  let make = (~data) => {
    open VaultPaymentMethodDetailsEntity

    <div className="flex flex-col gap-6">
      <div
        className="font-semibold text-nd_gray-700 leading-6 text-fs-18 dark:text-white dark:text-opacity-75">
        {"Payment Method Details"->React.string}
      </div>
      <Details data getHeading getCell detailsFields=allColumns widthClass="" />
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
        title=" "
        hideTitle=true
        resultsPerPage=7
        entity={VaultPSPTokensEntity.pspTokensEntity}
        actualData={data->Array.map(Nullable.make)}
        totalResults={data->Array.length}
        offset
        setOffset
        currrentFetchCount={data->Array.length}
      />
    </div>
  }
}

module NetworkTokens = {
  @react.component
  let make = (~data) => {
    open VaultNetworkTokensEntity

    <div className="flex flex-col gap-6">
      <div
        className="font-semibold text-nd_gray-700 leading-6 text-fs-18 dark:text-white dark:text-opacity-75">
        {"Network Tokens"->React.string}
      </div>
      <Details data getHeading getCell detailsFields=defaultColumns widthClass="" />
    </div>
  }
}

@react.component
let make = (~paymentId, ~setShowModal) => {
  open APIUtils
  open VaultPaymentMethodDetailsTypes
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let (paymentsDetailsData, setPaymentsDetailsData) = React.useState(() =>
    JSON.Encode.null->VaultPaymentMethodDetailsUtils.itemToObjMapper
  )

  let fetchPaymentMethodDetails = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(
        ~entityName=V2(RETRIEVE_PAYMENT_METHOD),
        ~methodType=Get,
        ~id=Some(paymentId),
      )
      let response = await fetchDetails(url, ~headerType=V2Headers)
      setPaymentsDetailsData(_ => response->VaultPaymentMethodDetailsUtils.itemToObjMapper)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error(""))
    }
  }

  React.useEffect(() => {
    fetchPaymentMethodDetails()->ignore
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
        <hr />
        <PaymentMethodDetails data={paymentsDetailsData.payment_method_data.card} />
        <hr />
        <PSPTokens data={paymentsDetailsData.connector_tokens} />
      </div>
    </div>
  </PageLoaderWrapper>
}
