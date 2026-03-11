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
    ~itemWrapperClass="",
  ) => {
    <FormRenderer.DesktopRow itemWrapperClass>
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
                overiddingHeadingStyles="text-nd_gray-400 !text-sm font-medium"
                textColor="!text-nd_gray-600 leading-6 !text-fs-16 !font-medium"
              />
            </div>
          </RenderIf>
        })
        ->React.array}
      </div>
    </FormRenderer.DesktopRow>
  }
}

module CustomerInfo = {
  open VaultCustomersEntity

  @react.component
  let make = (~dict) => {
    let customerData = itemToObjMapper(dict)
    <>
      <div
        className={`font-bold leading-8 text-nd_gray-700 text-fs-24 dark:text-white dark:text-opacity-75 mt-4 mb-4`}>
        {"Customers Summary"->React.string}
      </div>
      <Details data=customerData getHeading getCell detailsFields=allColumns widthClass="" />
    </>
  }
}

module VaultedPaymentMethodsTable = {
  @react.component
  let make = (~sampleReport) => {
    open APIUtils
    open LogicUtils
    let getURL = useGetURL()
    let url = RescriptReactRouter.useUrl()
    let fetchDetails = useGetMethod()
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
    let pageDetailDict = Recoil.useRecoilValueFromAtom(LoadedTable.table_pageDetails)
    let isOrchestrationVault = Recoil.useRecoilValueFromAtom(HyperswitchAtom.orchestrationVaultAtom)
    let defaultValue: LoadedTable.pageDetails = {offset: 0, resultsPerPage: 20}
    let pageDetail = pageDetailDict->Dict.get("vaultedPaymentMethods")->Option.getOr(defaultValue)
    let (offset, setOffset) = React.useState(_ => pageDetail.offset)
    let (tableData, setTableData) = React.useState(_ => [])
    let (showModal, setShowModal) = React.useState(_ => false)
    let (paymentId, setPaymentId) = React.useState(_ => "")
    let customerIdFromUrl = if isOrchestrationVault {
      url.path->List.toArray->Array.get(2)->Option.getOr("")
    } else {
      url.path->List.toArray->Array.get(4)->Option.getOr("")
    }
    let mixpanelEvent = MixpanelHook.useSendEvent()

    let fetchPaymentMethods = async () => {
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)
        let url = getURL(
          ~entityName=V2(PAYMENT_METHOD_LIST),
          ~methodType=Get,
          ~id=Some(customerIdFromUrl),
        )
        let response = await fetchDetails(url, ~version=V2)
        let tableData =
          response
          ->getDictFromJsonObject
          ->getJsonObjectFromDict("customer_payment_methods")
          ->getArrayDataFromJson(VaultPaymentMethodsEntity.itemToObjMapper)
        setTableData(_ => tableData)
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Error(""))
      }
    }
    let fetchDummyData = () => {
      let response = VaultSampleData.pmtList
      let tableData =
        response
        ->getDictFromJsonObject
        ->getJsonObjectFromDict("customer_payment_methods")
        ->getArrayDataFromJson(VaultPaymentMethodsEntity.itemToObjMapper)
      setTableData(_ => tableData)
    }
    React.useEffect(() => {
      if !sampleReport {
        fetchPaymentMethods()->ignore
      } else {
        fetchDummyData()->ignore
      }
      None
    }, [])

    <PageLoaderWrapper screenState>
      <LoadedTable
        title="Vaulted Payment Methods"
        hideTitle=true
        resultsPerPage=7
        entity={VaultPaymentMethodsEntity.vaultPaymentMethodsEntity}
        actualData={tableData->Array.map(Nullable.make)}
        totalResults={tableData->Array.length}
        offset
        setOffset
        onEntityClick={val => {
          setPaymentId(_ => val.id)
          setShowModal(_ => true)
          mixpanelEvent(
            ~eventName=VaultHomeUtils.getVaultMixpanelEventName(
              ~isOrchestrationVault,
              ~eventName="vault_view_vaulted_payment_method_details",
            ),
          )
        }}
        currrentFetchCount={tableData->Array.length}
        showAutoScroll=true
      />
      <Modal
        showModal
        setShowModal
        closeOnOutsideClick=true
        modalClass="w-full md:w-1/2 !h-full overflow-y-scroll !overflow-x-hidden rounded-none text-jp-gray-900"
        childClass="">
        <VaultPaymentMethodDetailsSidebar paymentId setShowModal sampleReport />
      </Modal>
    </PageLoaderWrapper>
  }
}

module VaultedPaymentMethods = {
  @react.component
  let make = (~sampleReport) => {
    <>
      <div className="flex flex-col gap-1 mb-6">
        <p className="text-xl font-semibold"> {"Vaulted Payment Method"->React.string} </p>
        <p className="text-base text-nd_gray-400">
          {"Click on an entry to view detailed information about a vaulted payment method."->React.string}
        </p>
      </div>
      <VaultedPaymentMethodsTable sampleReport />
    </>
  }
}

@react.component
let make = (~id, ~sampleReport) => {
  open APIUtils
  open LogicUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (customersData, setCustomersData) = React.useState(_ => JSON.Encode.null)
  let defaultObject = Dict.make()->VaultCustomersEntity.itemToObjMapper
  let isOrchestrationVault = Recoil.useRecoilValueFromAtom(HyperswitchAtom.orchestrationVaultAtom)
  let fetchCustomersData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let customersUrl = getURL(~entityName=V2(CUSTOMERS), ~methodType=Get, ~id=Some(id))

      let response = await fetchDetails(customersUrl, ~version=V2)
      setCustomersData(_ => response)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }

  let fetchDummyData = () => {
    let response = VaultSampleData.retrieveCustomer
    let data =
      response
      ->getDictFromJsonObject
      ->getArrayFromDict("data", [])
      ->VaultCustomersEntity.getArrayOfCustomerListPayloadType
    let selectedDataArray = data->Array.filter(item => {item.id == id})

    let selectedDataObject =
      selectedDataArray->getValueFromArray(0, defaultObject)->Identity.genericTypeToJson

    setCustomersData(_ => selectedDataObject)
    setScreenState(_ => PageLoaderWrapper.Success)
  }
  React.useEffect(() => {
    if !sampleReport {
      fetchCustomersData()->ignore
    } else {
      fetchDummyData()->ignore
    }
    None
  }, [])
  <PageLoaderWrapper screenState>
    <div className="flex flex-col overflow-scroll">
      <div className="mb-4 flex justify-between">
        <div className="flex items-center">
          <div>
            <BreadCrumbNavigation
              path=[
                {
                  title: "Customers",
                  link: {
                    isOrchestrationVault ? "/vault-customers-tokens" : "/v2/vault/customers-tokens"
                  },
                },
              ]
              currentPageTitle=id
              cursorStyle="cursor-pointer"
            />
          </div>
        </div>
      </div>
      <div className="mb-8">
        <CustomerInfo dict={customersData->LogicUtils.getDictFromJsonObject} />
      </div>
      <VaultedPaymentMethods sampleReport />
    </div>
  </PageLoaderWrapper>
}
