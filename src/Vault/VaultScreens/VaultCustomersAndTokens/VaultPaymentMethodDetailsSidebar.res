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

    <>
      <div
        className="font-semibold text-nd_gray-700 leading-6 text-fs-20 dark:text-white dark:text-opacity-75 mt-6 mb-4">
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
        className="font-semibold text-fs-20 text-nd_gray-700 leading-6 dark:text-white dark:text-opacity-75 mt-8 mb-4">
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
        className="font-semibold text-nd_gray-700 leading-6 text-fs-20 dark:text-white dark:text-opacity-75 mt-8 mb-4">
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
  let (paymentsDetailsData, setPaymentsDetailsData) = React.useState(() => JSON.Encode.null)

  let fetchPaymentMethodDetails = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = ""
      let _response = await fetchDetails(url)

      //** TODO: replace DUMMY DATA with api response*/
      let networkTokenData: VaultPaymentMethodDetailsTypes.network_tokens = {
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

      let response = {
        merchant: "merchant",
        customer_id: Some("custid_12345678"),
        payment_method_id: "payid_2345678",
        payment_method_type: Some("card"),
        payment_method: "credit",
        card: {
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
        },
        recurring_enabled: true,
        tokenization_type: JSON.Encode.string(""),
        psp_tokensization: {psp_token: pspTokensData},
        network_tokensization: {network_token: networkTokenData},
        created: "",
        last_used_at: "",
        network_transaction_id: "network_transac_id",
      }->Identity.genericTypeToJson
      setPaymentsDetailsData(_ => response)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error(""))
    }
  }

  React.useEffect(() => {
    fetchPaymentMethodDetails()->ignore
    None
  }, [])

  let cardDetails = (paymentsDetailsData->VaultPaymentMethodDetailsUtils.itemToObjMapper).card
  let networkData = (
    paymentsDetailsData->VaultPaymentMethodDetailsUtils.itemToObjMapper
  ).network_tokensization.network_token
  let pspData = (
    paymentsDetailsData->VaultPaymentMethodDetailsUtils.itemToObjMapper
  ).psp_tokensization.psp_token

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
      <div className="px-8 pb-20">
        <PaymentMethodDetails data={cardDetails} />
        <NetworkTokens data={networkData} />
        <PSPTokens data={pspData} />
      </div>
    </div>
  </PageLoaderWrapper>
}
