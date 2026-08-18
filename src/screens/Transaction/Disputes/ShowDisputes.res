open DisputesEntity
module Details = {
  @react.component
  let make = (
    ~data: DisputeTypes.disputes,
    ~getHeading,
    ~excludeColKeys=[],
    ~detailsFields,
    ~justifyClassName="justify-start",
    ~widthClass="w-1/4",
    ~bgColor="bg-white dark:bg-jp-gray-lightgray_background",
    ~children=?,
    ~setDisputeData,
  ) => {
    open DisputeTypes
    open DisputesUtils
    open LogicUtils
    let {orgId, merchantId} = React.useContext(
      UserInfoProvider.defaultContext,
    ).getCommonSessionDetails()
    let connectorTypeFromName = data.connector->ConnectorUtils.getConnectorNameTypeFromString
    let {disputeEvidenceUpload} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
    let (uploadEvidenceModal, setUploadEvidenceModal) = React.useState(_ => false)
    let (fileUploadedDict, setFileUploadedDict) = React.useState(_ => Dict.make())
    let (disputeEvidenceStatus, setDisputeEvidenceStatus) = React.useState(_ => Landing)
    let daysToRespond = getDaysDiffForDates(
      ~startDate=Date.now(),
      ~endDate=data.challenge_required_by->DateTimeUtils.parseAsFloat,
    )

    <OrderUtils.Section
      customCssClass={`border border-jp-gray-940 border-opacity-75 dark:border-jp-gray-960 ${bgColor} rounded-md p-6 flex flex-col gap-6`}>
      <div className="flex items-center justify-between">
        <div className="flex gap-2 items-center">
          <p className="flex font-bold text-3xl gap-2">
            {amountValue(data.amount, data.currency->String.toUpperCase)->React.string}
          </p>
          {useGetStatus(data)}
          <RenderIf
            condition={data.dispute_status->disputeStatusVariantMapper === DisputeOpened &&
              data.challenge_required_by->isNonEmptyString}>
            <div
              className="border text-orange-950 bg-orange-100 text-sm px-2 py-1 rounded-md font-semibold">
              {`${daysToRespond->Float.toString} days to respond`->React.string}
            </div>
          </RenderIf>
        </div>
        <RenderIf
          condition={disputeEvidenceUpload &&
          ConnectorUtils.existsInArray(connectorTypeFromName, connectorSupportCounterDispute) &&
          data.dispute_status->disputeStatusVariantMapper === DisputeOpened &&
          disputeEvidenceStatus === Landing}>
          <UploadEvidenceForDisputes
            setUploadEvidenceModal
            disputeID={data.dispute_id}
            setDisputeData
            connector={data.connector}
          />
        </RenderIf>
      </div>
      <div className="h-px w-full bg-grey-200 opacity-30" />
      <RenderIf
        condition={disputeEvidenceUpload &&
        ConnectorUtils.existsInArray(connectorTypeFromName, connectorSupportCounterDispute) &&
        showDisputeInfoStatus->Array.includes(data.dispute_status->disputeStatusVariantMapper)}>
        <UploadEvidenceForDisputes.DisputesInfoBarComponent
          disputeEvidenceStatus
          fileUploadedDict
          disputeId={data.dispute_id}
          setDisputeEvidenceStatus
          setUploadEvidenceModal
          disputeStatus={data.dispute_status->disputeStatusVariantMapper}
          setFileUploadedDict
          setDisputeData
        />
      </RenderIf>
      <UploadEvidenceForDisputes.UploadDisputeEvidenceModal
        uploadEvidenceModal
        setUploadEvidenceModal
        disputeId={data.dispute_id}
        setDisputeEvidenceStatus
        fileUploadedDict
        setFileUploadedDict
      />
      <FormRenderer.DesktopRow>
        <div
          className={`flex flex-wrap ${justifyClassName} lg:flex-row flex-col dark:bg-jp-gray-lightgray_background dark:border-jp-gray-no_data_border`}>
          {detailsFields
          ->Array.mapWithIndex((colType, i) => {
            <RenderIf condition={!(excludeColKeys->Array.includes(colType))} key={Int.toString(i)}>
              <div className={`flex ${widthClass} items-center`}>
                <OrderUtils.DisplayKeyValueParams
                  heading={getHeading(colType)}
                  value={getCell(data, colType, merchantId, orgId)}
                  customMoneyStyle="!font-normal !text-sm"
                  labelMargin="!py-0 mt-2"
                  overridingHeadingStyles="text-black text-sm font-medium"
                  textColor="!font-normal !text-jp-gray-700"
                />
              </div>
            </RenderIf>
          })
          ->React.array}
        </div>
      </FormRenderer.DesktopRow>
      <RenderIf condition={children->Option.isSome}>
        {children->Option.getOr(React.null)}
      </RenderIf>
    </OrderUtils.Section>
  }
}
module DisputesInfo = {
  @react.component
  let make = (~orderDict, ~setDisputeData, ~merchantId, ~orgId) => {
    let disputesData = DisputesEntity.itemToObjMapper(orderDict)

    <>
      <div className={`font-bold text-fs-16 dark:text-white dark:text-opacity-75 mt-4 mb-4`}>
        {"Summary"->React.string}
      </div>
      <RenderIf condition={disputesData.is_already_refunded}>
        <DisputesHelper.DualRefundsAlert
          customLearnMoreComponent={<DisputesHelper.LearnMoreComponent
            disputesData merchantId orgId
          />}
          subText="The chargeback has exceeded the dispute amount. Go to the Payments tab to learn more."
        />
      </RenderIf>
      <Details data=disputesData getHeading detailsFields=allColumns setDisputeData />
    </>
  }
}

@react.component
let make = (~id, ~profileId, ~merchantId, ~orgId) => {
  open APIUtils
  open LogicUtils
  let url = RescriptReactRouter.useUrl()
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let (disputeData, setDisputeData) = React.useState(_ => JSON.Encode.null)
  let internalSwitch = OMPSwitchHooks.useInternalSwitch()
  let showToast = ToastAdapter.useShowToast()

  let fetchDisputesData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let disputesUrl = getURL(~entityName=V1(DISPUTES), ~methodType=Get, ~id=Some(id))
      let _ = await internalSwitch(
        ~expectedOrgId=orgId,
        ~expectedMerchantId=merchantId,
        ~expectedProfileId=profileId,
      )
      let response = await fetchDetails(disputesUrl)
      setDisputeData(_ => response)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }

  React.useEffect(() => {
    fetchDisputesData()->ignore
    None
  }, [url])

  let data = disputeData->getDictFromJsonObject
  let paymentId = data->getString("payment_id", "")

  let showSyncButton = React.useCallback(_ => {
    let status = data->getString("dispute_status", "")->DisputesUtils.disputeStatusVariantMapper

    !(id->HSwitchOrderUtils.isTestData) &&
    status !== DisputeWon &&
    status !== DisputeLost &&
    status !== DisputeExpired &&
    status !== DisputeCancelled &&
    status !== DisputeAccepted &&
    data->Dict.keysToArray->isNonEmptyArray
  }, [disputeData])

  let syncData = async () => {
    try {
      let disputesUrl = getURL(
        ~entityName=V1(DISPUTES),
        ~methodType=Get,
        ~id=Some(id),
        ~queryParameters=Some("force_sync=true"),
      )
      let _ = await internalSwitch(
        ~expectedOrgId=orgId,
        ~expectedMerchantId=merchantId,
        ~expectedProfileId=profileId,
      )
      let response = await fetchDetails(disputesUrl)
      setDisputeData(_ => response)
      showToast(~message="Details Updated", ~toastType=ToastSuccess)
    } catch {
    | _ => ()
    }
  }

  <PageLoaderWrapper screenState>
    <div className="flex flex-col overflow-scroll">
      <div className="mb-4 flex justify-between">
        <div className="flex items-center justify-between w-full">
          <div>
            <PageUtils.PageHeading title="Disputes" />
            <BreadCrumbNavigation
              path=[{title: "Disputes", link: "/disputes"}] currentPageTitle=id
            />
          </div>
          <RenderIf condition={showSyncButton()}>
            <ACLButton
              authorization={userHasAccess(~groupAccess=OperationsView)}
              text="Sync"
              leftIcon={Button.CustomIcon(<Icon name="sync" className="text-nd_gray-600" />)}
              buttonType={Primary}
              customButtonStyle="mr-1"
              onClick={_ => syncData()->ignore}
            />
          </RenderIf>
        </div>
      </div>
      <DisputesInfo orderDict={data} setDisputeData merchantId orgId />
      <div className="mt-5" />
      <RenderIf
        condition={featureFlagDetails.auditTrail &&
        userHasAccess(~groupAccess=AnalyticsView) == Access}>
        <OrderUIUtils.RenderAccordion
          accordion={[
            {
              title: "Events and logs",
              renderContent: (~currentAccordionState as _, ~closeAccordionFn as _) => {
                <LogsWrapper wrapperFor={#DISPUTE}>
                  <DisputeLogs disputeId=id paymentId />
                </LogsWrapper>
              },
              renderContentOnTop: None,
            },
          ]}
        />
      </RenderIf>
    </div>
  </PageLoaderWrapper>
}
