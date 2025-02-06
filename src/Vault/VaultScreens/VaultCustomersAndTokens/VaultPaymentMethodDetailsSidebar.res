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
      <div className={`flex ${isHorizontal ? "flex-row gap-3" : "flex-col gap-1"} py-4`}>
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
    <FormRenderer.DesktopRow>
      <div
        className={`grid grid-cols-3 ${justifyClassName} dark:bg-jp-gray-lightgray_background dark:border-jp-gray-no_data_border`}>
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
                textColor="!font-normal !text-nd_gray-600"
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

    <>
      <div className="font-bold text-fs-20 dark:text-white dark:text-opacity-75 mt-4 mb-4">
        {"Payment Method Details"->React.string}
      </div>
      <Details data getHeading getCell detailsFields=allColumns widthClass="" />
    </>
  }
}

module PSPTokens = {
  @react.component
  let make = (~data) => {
    let (offset, setOffset) = React.useState(() => 0)

    <>
      <div
        className="font-bold text-fs-20 text-nd_gray-700 dark:text-white dark:text-opacity-75 mt-4 mb-4">
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
    </>
  }
}

module NetworkTokens = {
  @react.component
  let make = (~data) => {
    let (offset, setOffset) = React.useState(() => 0)

    <>
      <div
        className="font-bold text-fs-20 text-nd_gray-700 dark:text-white dark:text-opacity-75 mt-4 mb-4">
        {"Network Tokens"->React.string}
      </div>
      <LoadedTable
        title=" "
        hideTitle=true
        resultsPerPage=7
        entity={VaultNetworkTokensEntity.networkTokensEntity}
        actualData={data->Array.map(Nullable.make)}
        totalResults={data->Array.length}
        offset
        setOffset
        currrentFetchCount={data->Array.length}
      />
    </>
  }
}

@react.component
let make = (~paymentId, ~setShowModal) => {
  open APIUtils
  open VaultPaymentMethodDetailsTypes
  let _getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)

  let paymentsData = {
    card_holder_name: "git",
    card_type: "visa",
    card_network: "stripe",
    last_four_digits: "1234",
    card_expiry_month: "04",
    card_expiry_year: "2040",
    card_issuer: "stripe",
    card_issuing_country: "usa",
    card_is_in: "",
    card_extended_bin: "",
    payment_checks: "",
    authentication_data: "",
  }

  let networkTokenData: VaultPaymentMethodDetailsTypes.network_tokensization = {
    enabled: false,
    status: "ENABLED",
    token: "token_uyrxuasytdfibausgf",
    created: "",
  }

  let networkTokenData = Array.make(~length=5, networkTokenData)

  let pspTokensData: VaultPaymentMethodDetailsTypes.psp_tokens = {
    mca_id: "mca_12345678",
    connector: "Stripe",
    status: "ENABLED",
    tokentype: "Single-use",
    token: "token_gicksudfgoieu",
    created: "",
  }

  let pspTokensData = Array.make(~length=5, pspTokensData)

  let fetchPaymentMethodDetails = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = ""
      let _response = await fetchDetails(url)
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
      <div className="py-5 px-6 flex justify-between align-top ">
        <CardUtils.CardHeader
          heading={paymentId} subHeading="" customSubHeadingStyle="w-full !max-w-none pr-10"
        />
        <div className="h-fit" onClick={_ => setShowModal(_ => false)}>
          <Icon name="nd-cross" className="cursor-pointer" size=30 />
        </div>
      </div>
      <hr />
      <div className="p-6">
        <PaymentMethodDetails data={paymentsData} />
        <NetworkTokens data={networkTokenData} />
        <PSPTokens data={pspTokensData} />
      </div>
    </div>
  </PageLoaderWrapper>
}
