let unselectedNormalText = "text-base font-normal text-grey-700 opacity-50"
let selectedNormalText = "text-base font-medium text-grey-700 "
let dividerColor = "bg-grey-700 bg-opacity-20 h-px w-full"
let unselectedSubHeading = "text-lg font-normal text-grey-700 "

module CheckListSection = {
  open ProdOnboardingUtils
  @react.component
  let make = (
    ~headerText,
    ~checkListItems,
    ~headerVariant,
    ~sectionIndex,
    ~pageView,
    ~getConnectorDetails,
    ~setPreviewState,
  ) => {
    let {globalUIConfig: {font: {textColor}, backgroundColor}} = React.useContext(
      ConfigContext.configContext,
    )

    let stepColor =
      checkListItems->Array.includes(pageView)
        ? `${backgroundColor} text-white py-px px-2 rounded-md`
        : `${backgroundColor} bg-opacity-20  ${textColor.primaryNormal} py-px px-2 rounded-md`
    let bgColor = checkListItems->Array.includes(pageView) ? "bg-white" : "bg-jp-gray-light_gray_bg"
    let selectedItemColor = indexVal =>
      indexVal->getIndexFromVariant === pageView->getIndexFromVariant
        ? "bg-pdf_background rounded-md"
        : ""
    let handleOnClick = clickedVariant => {
      let currentViewindex =
        updatedCheckList->Array.indexOf(
          updatedCheckList
          ->Array.filter(ele => ele.itemsVariants->Array.includes(pageView))
          ->Array.get(0)
          ->Option.getOr(defaultValueOfCheckList),
        )

      switch (currentViewindex, clickedVariant) {
      | (1, #SetupProcessor)
      | (2, #SetupProcessor) =>
        getConnectorDetails(clickedVariant)->ignore
      | (2, #ConfigureEndpoint) =>
        setPreviewState(_ => Some(#ConfigureEndpoint->ProdOnboardingUtils.getPreviewState))
      | _ => setPreviewState(_ => None)
      }
    }
    <div
      className={`flex flex-col py-8 px-6 gap-3 ${bgColor} cursor-pointer`}
      onClick={_ => handleOnClick(headerVariant)}>
      <div className={"flex justify-between "}>
        <div className="flex gap-4">
          <p className={`${stepColor} font-bold`}>
            {(sectionIndex + 1)->Int.toString->React.string}
          </p>
          <p className=unselectedSubHeading> {headerText->React.string} </p>
        </div>
        <UIUtils.RenderIf condition={!(checkListItems->Array.includes(pageView))}>
          <Icon name="lock-outlined" size=20 />
        </UIUtils.RenderIf>
      </div>
      {checkListItems
      ->Array.mapWithIndex((value, index) => {
        <div
          key={index->Int.toString}
          className={`flex pl-10 gap-2 py-2 cursor-pointer ${value->selectedItemColor}`}>
          <Icon
            name={value->getIndexFromVariant < pageView->getIndexFromVariant
              ? "green-check"
              : "nonselected"}
            size=20
          />
          <p
            key={index->Int.toString}
            className={`${value->getIndexFromVariant === pageView->getIndexFromVariant
                ? selectedNormalText
                : unselectedNormalText}  `}>
            {value->sidebarTextFromVariant->React.string}
          </p>
        </div>
      })
      ->React.array}
    </div>
  }
}

module ProgressBar = {
  @react.component
  let make = (~progressState) => {
    let {globalUIConfig: {backgroundColor}} = React.useContext(ConfigContext.configContext)
    <div className={`${backgroundColor} bg-opacity-20 h-1.5 w-full`}>
      <div
        className={`h-full ${backgroundColor}`}
        style={ReactDOMStyle.make(~width=`${progressState}%`, ())}
      />
    </div>
  }
}
module SidebarChecklist = {
  open ProdOnboardingUtils
  @react.component
  let make = (~pageView, ~getConnectorDetails, ~setPreviewState) => {
    let (progressState, setProgressState) = React.useState(_ => 0)

    React.useEffect1(_ => {
      let currentIndex = pageView->ProdOnboardingUtils.getIndexFromVariant
      // Need to change to 14 after enabling the TEST_LIVE_PAYMENT
      let progress = 2 + 16 * currentIndex
      setProgressState(_ => progress)
      None
    }, [pageView])

    let getProgressText = switch progressState {
    | 2 => `0% completed`
    | _ => `${progressState->Int.toString}% completed`
    }
    <div className="flex flex-col h-full w-[30rem] border bg-white shadow">
      <p className="font-semibold text-xl p-6"> {"Setup Basic Live Account"->React.string} </p>
      <div className=dividerColor />
      <div className="flex flex-col gap-4 px-6 py-8">
        <p className=" text-grey-700 text-base font-normal"> {getProgressText->React.string} </p>
        <ProgressBar progressState={progressState->Int.toString} />
      </div>
      <div className=dividerColor />
      {updatedCheckList
      ->Array.mapWithIndex((items, sectionIndex) =>
        <div key={sectionIndex->Int.toString}>
          <CheckListSection
            headerText={items.headerText}
            checkListItems={items.itemsVariants}
            headerVariant={items.headerVariant}
            sectionIndex
            pageView
            getConnectorDetails
            setPreviewState
          />
          <div className=dividerColor />
        </div>
      )
      ->React.array}
    </div>
  }
}
@react.component
let make = () => {
  open ProdOnboardingTypes
  open ConnectorTypes
  open APIUtils
  let fetchDetails = useGetMethod()
  let (pageView, setPageView) = React.useState(_ => SELECT_PROCESSOR)
  let (selectedConnector, setSelectedConnector) = React.useState(_ => Processors(STRIPE))
  let (_paymentId, _setPaymentId) = React.useState(_ => "")
  let updateDetails = useUpdateMethod()

  let {setDashboardPageState} = React.useContext(GlobalProvider.defaultContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (buttonState, setButtonState) = React.useState(_ => Button.Normal)
  let (previewState, setPreviewState) = React.useState(_ => None)
  let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->JSON.Encode.object)
  let (connectorID, setConnectorID) = React.useState(_ => "")
  let routerUrl = RescriptReactRouter.useUrl()

  let getCssOnView = "xl:w-77-rem  mx-7 xl:ml-[7rem]"
  let centerItems = pageView === SETUP_COMPLETED ? "justify-center" : ""
  let urlPush = HSwitchGlobalVars.appendDashboardPath(~url=`/prod-onboarding?${routerUrl.search}`)

  let userRole = HSLocalStorage.getFromUserDetails("user_role")

  let getSetupCompleteEnum = (prodEnums: ProdOnboardingTypes.prodOnboading) => {
    open LogicUtils
    if prodEnums.setupComplete {
      setDashboardPageState(_ => #HOME)
      let baseUrlPath = `${HSwitchGlobalVars.getHostURLFromVariant}/${routerUrl.path
        ->List.toArray
        ->Array.joinWith("/")}`
      routerUrl.search->isNonEmptyString
        ? RescriptReactRouter.push(`${baseUrlPath}?${routerUrl.search}`)
        : RescriptReactRouter.push(`${baseUrlPath}`)
    } else {
      RescriptReactRouter.push(urlPush)
      setPageView(_ => SETUP_COMPLETED)
      setScreenState(_ => PageLoaderWrapper.Success)
    }
  }

  let getConfigureEndpointEnum = (prodEnums: ProdOnboardingTypes.prodOnboading) => {
    if prodEnums.configureEndpoint {
      getSetupCompleteEnum(prodEnums)->ignore
    } else {
      RescriptReactRouter.push(urlPush)
      setPageView(_ => REPLACE_API_KEYS)
      setScreenState(_ => PageLoaderWrapper.Success)
    }
  }

  let getSetupProcessorEnum = (prodEnums: ProdOnboardingTypes.prodOnboading) => {
    open LogicUtils
    let connectorId = prodEnums.setupProcessor.connector_id
    if connectorId->isNonEmptyString {
      setConnectorID(_ => connectorId)
      getConfigureEndpointEnum(prodEnums)->ignore
    } else {
      RescriptReactRouter.push(urlPush)
      setPageView(_ => SELECT_PROCESSOR)
      setScreenState(_ => PageLoaderWrapper.Success)
    }
  }

  let getConnectorDetails = async headerVariant => {
    open LogicUtils
    try {
      let connectorUrl = getURL(~entityName=CONNECTOR, ~methodType=Get, ~id=Some(connectorID), ())
      let json = await fetchDetails(connectorUrl)
      let connectorName = json->getDictFromJsonObject->getString("connector_name", "")
      setInitialValues(_ => json)
      setPreviewState(_ => Some(headerVariant->ProdOnboardingUtils.getPreviewState))
      RescriptReactRouter.replace(
        HSwitchGlobalVars.appendDashboardPath(~url=`/prod-onboarding?name=${connectorName}`),
      )
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error(""))
    }
  }

  let getStatus = async () => {
    open ProdOnboardingUtils
    open HomeUtils
    try {
      let url = `${getURL(
          ~entityName=USERS,
          ~userType=#USER_DATA,
          ~methodType=Get,
          (),
        )}?keys=${prodOnboardingEnumIntialArray->Array.joinWithUnsafe(",")}`
      let response = await fetchDetails(url)
      let prodEnums = response->responseDataMapper(getValueMappedForProd)->getTypedValue
      getSetupProcessorEnum(prodEnums)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error(""))
    }
  }

  let updateSetupPageCompleted = async () => {
    try {
      setButtonState(_ => Loading)
      let url = getURL(~entityName=USERS, ~userType=#MERCHANT_DATA, ~methodType=Post, ())
      let body = ProdOnboardingUtils.getProdApiBody(~parentVariant=#SetupComplete, ())
      let _ = await updateDetails(url, body, Post, ())
      setButtonState(_ => Normal)
      setDashboardPageState(_ => #HOME)
    } catch {
    | _ => setButtonState(_ => Normal)
    }
  }

  React.useEffect0(() => {
    // getSetupProcessorEnum()->ignore
    getStatus()->ignore
    None
  })

  <PageLoaderWrapper screenState sectionHeight="h-screen">
    <div className="flex h-screen w-screen">
      <SidebarChecklist pageView getConnectorDetails setPreviewState />
      <div
        className={`bg-hyperswitch_background flex items-center h-screen w-full overflow-scroll ${centerItems}`}>
        <div className={`flex flex-col ${getCssOnView}`}>
          <div className={`flex justify-end w-full pb-5`}>
            <SwitchMerchant userRole={userRole} />
          </div>
          <div className={`h-[52rem] overflow-scroll bg-white rounded-md w-full border`}>
            {switch previewState {
            | Some(previewVariant) =>
              switch previewVariant {
              | SELECT_PROCESSOR_PREVIEW =>
                <div className="h-full w-full px-11 py-8">
                  <ConnectorPreview
                    connectorInfo={initialValues}
                    currentStep=ConnectorTypes.Preview
                    setCurrentStep={_ => ()}
                    isUpdateFlow=true
                    isPayoutFlow=false
                    showMenuOption=false
                    setInitialValues
                    getPayPalStatus={_ => ()}
                  />
                </div>
              | LIVE_ENDPOINTS_PREVIEW => <LiveEndpointsSetup pageView setPageView previewState />
              | _ => React.null
              }
            | None =>
              switch pageView {
              | SELECT_PROCESSOR =>
                <ChooseConnector selectedConnector setSelectedConnector pageView setPageView />
              | SETUP_CREDS | SETUP_WEBHOOK_PROCESSOR =>
                <SetupConnectorCredentials selectedConnector pageView setPageView setConnectorID />
              | REPLACE_API_KEYS | SETUP_WEBHOOK_USER =>
                <LiveEndpointsSetup pageView setPageView previewState />
              // | TEST_LIVE_PAYMENT => <TestLivePayment pageView setPageView setPaymentId />
              | SETUP_COMPLETED =>
                <ProdOnboardingUIUtils.BasicAccountSetupSuccessfulPage
                  iconName="account-setup-completed"
                  statusText="Basic Account Setup Successful"
                  buttonText="Go to Dashboard"
                  buttonOnClick={_ => updateSetupPageCompleted()->ignore}
                  buttonState
                />
              | _ => React.null
              }
            }}
          </div>
        </div>
      </div>
    </div>
  </PageLoaderWrapper>
}
