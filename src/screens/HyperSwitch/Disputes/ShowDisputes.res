open DisputesEntity
module DisputesNoteComponent = {
  open ConnectorUtils
  @react.component
  let make = (~disputesData: DisputeTypes.disputes) => {
    let dashboardLink = {
      switch disputesData.connector->getConnectorNameTypeFromString {
      | BLUESNAP | STRIPE =>
        <span
          className="underline underline-offset-2 cursor-pointer"
          onClick={_ => {
            let link = switch disputesData.connector->getConnectorNameTypeFromString {
            | BLUESNAP => "https://cp.bluesnap.com/jsp/developer_login.jsp"
            | STRIPE | _ => " https://dashboard.stripe.com/disputes"
            }
            link->Window._open
          }}>
          {"dashboard."->React.string}
        </span>
      | _ => <span> {"dashboard."->React.string} </span>
      }
    }

    <div
      className="flex border items-start border-blue-800 text-sm rounded-md gap-2 px-4 py-3 mt-5">
      <Icon name="info-vacent" className="text-blue-900 mt-1" size=18 />
      <span>
        {"Coming soon! You would soon be able to upload evidences against disputes directly from your Hyperswitch dashboard. Until then, please use Hyperswitch dashboard to track any changes in dispute status while uploading evidences from your relevant connector "->React.string}
        {dashboardLink}
      </span>
    </div>
  }
}
module Details = {
  @react.component
  let make = (
    ~data: DisputeTypes.disputes,
    ~getHeading,
    ~getCell,
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

    open UIUtils

    let {disputeEvidenceUpload} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
    let (uploadEvidenceModal, setUploadEvidenceModal) = React.useState(_ => false)
    let (fileUploadedDict, setFileUploadedDict) = React.useState(_ => Dict.make())
    let (disputeEvidenceStatus, setDisputeEvidenceStatus) = React.useState(_ => Landing)
    let daysToRespond = LogicUtils.getDaysDiffForDates(
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
          {getStatus(data)}
          <RenderIf condition={data.dispute_status->disputeStatusVariantMapper === DisputeOpened}>
            <div
              className="border text-orange-950 bg-orange-200 text-sm px-2 py-1 rounded-md font-semibold">
              {`${daysToRespond->Float.toString} days to respond`->React.string}
            </div>
          </RenderIf>
        </div>
        <RenderIf
          condition={disputeEvidenceUpload &&
          connectorSupportCounterDispute->Array.includes(
            data.connector->ConnectorUtils.getConnectorNameTypeFromString,
          ) &&
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
        connectorSupportCounterDispute->Array.includes(
          data.connector->ConnectorUtils.getConnectorNameTypeFromString,
        ) &&
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
          className={`flex flex-wrap ${justifyClassName} dark:bg-jp-gray-lightgray_background dark:border-jp-gray-no_data_border`}>
          {detailsFields
          ->Array.mapWithIndex((colType, i) => {
            <RenderIf condition={!(excludeColKeys->Array.includes(colType))} key={Int.toString(i)}>
              <div className={`flex ${widthClass} items-center`}>
                <OrderUtils.DisplayKeyValueParams
                  heading={getHeading(colType)}
                  value={getCell(data, colType)}
                  customMoneyStyle="!font-normal !text-sm"
                  labelMargin="!py-0 mt-2"
                  overiddingHeadingStyles="text-black text-sm font-medium"
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
  let make = (~orderDict, ~setDisputeData) => {
    let disputesData = DisputesEntity.itemToObjMapper(orderDict)

    let showNoteComponentCondition =
      DisputesUtils.connectorsSupportEvidenceUpload->Array.includes(
        disputesData.connector->ConnectorUtils.getConnectorNameTypeFromString,
      )
    <>
      <div className={`font-bold text-fs-16 dark:text-white dark:text-opacity-75 mt-4 mb-4`}>
        {"Summary"->React.string}
      </div>
      <Details data=disputesData getHeading getCell detailsFields=allColumns setDisputeData />
      <UIUtils.RenderIf condition={!showNoteComponentCondition}>
        <DisputesNoteComponent disputesData />
      </UIUtils.RenderIf>
    </>
  }
}

@react.component
let make = (~id) => {
  open APIUtils
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let (disputeData, setDisputeData) = React.useState(_ => JSON.Encode.null)

  let fetchDisputesData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let disputesUrl = getURL(~entityName=DISPUTES, ~methodType=Get, ~id=Some(id), ())
      let response = await fetchDetails(disputesUrl)
      setDisputeData(_ => response)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }

  React.useEffect0(() => {
    fetchDisputesData()->ignore
    None
  })

  let data = disputeData->LogicUtils.getDictFromJsonObject
  let paymentId = data->LogicUtils.getString("payment_id", "")

  <PageLoaderWrapper screenState>
    <div className="flex flex-col overflow-scroll">
      <div className="mb-4 flex justify-between">
        <div className="flex items-center">
          <div>
            <PageUtils.PageHeading title="Disputes" />
            <BreadCrumbNavigation
              path=[{title: "Disputes", link: "/disputes"}]
              currentPageTitle=id
              cursorStyle="cursor-pointer"
            />
          </div>
          <div />
        </div>
      </div>
      <DisputesInfo orderDict={data} setDisputeData />
      <div className="mt-5" />
      <UIUtils.RenderIf condition={featureFlagDetails.auditTrail}>
        <OrderUIUtils.RenderAccordian
          accordion={[
            {
              title: "Events and logs",
              renderContent: () => {
                <LogsWrapper wrapperFor={#REFUND}>
                  <DisputeLogs disputeId=id paymentId />
                </LogsWrapper>
              },
              renderContentOnTop: None,
            },
          ]}
        />
      </UIUtils.RenderIf>
    </div>
  </PageLoaderWrapper>
}
