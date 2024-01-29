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

module DisputesInfoBarComponent = {
  @react.component
  let make = (~disputeStatus, ~isFromPayments=false, ~disputeDataValue=None) => {
    open DisputeTypes

    let subStyle = `${HSwitchUtils.getTextClass(
        ~textVariant=P1,
        ~paragraphTextVariant=Regular,
        (),
      )} opacity-60`
    let redirectionTextStyle = `${HSwitchUtils.getTextClass(
        ~textVariant=P1,
        ~paragraphTextVariant=Medium,
        (),
      )} text-blue-900`

    let headerStyle = HSwitchUtils.getTextClass(~textVariant=H3, ~h3TextVariant=Leading_2, ())

    <div
      className="border w-full rounded-md border-blue-700 border-opacity-40 bg-blue-700 bg-opacity-10 p-6 flex gap-6">
      <div className="flex gap-3 items-start justify-start">
        <Icon name="note-icon" size=22 />
        {switch disputeStatus {
        | Initiated =>
          <div className="flex flex-col gap-6">
            <div className="flex flex-col gap-2">
              <p className=headerStyle> {"Why was the dispute raised?"->React.string} </p>
              <p className=subStyle>
                {"The customer claims that they did not authorise this purchase."->React.string}
              </p>
            </div>
            <div
              className="flex gap-2 group items-center cursor-pointer"
              onClick={_ =>
                Window._open("https://docs.hyperswitch.io/features/merchant-controls/disputes")}>
              <p className=redirectionTextStyle> {"Learn how to respond"->React.string} </p>
              <Icon
                name="thin-right-arrow"
                size=20
                className="group-hover:scale-125 transition duration-200 ease-in-out"
                customIconColor="#006DF9"
              />
            </div>
          </div>
        | Accepted =>
          <div className="flex flex-col gap-2">
            <p className=headerStyle> {"You accepted this dispute"->React.string} </p>
            <p className=subStyle>
              {"A refund is issued for the customer. No further action is required from you."->React.string}
            </p>
          </div>

        | _ => React.null
        }}
      </div>
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
    open APIUtils
    open UIUtils
    let updateDetails = useUpdateMethod()
    let (disputeStatus, setDisputeStatus) = React.useState(_ =>
      data.dispute_status->disputeStatusVariantMapper->disputeValueBasedOnStatus
    )
    let showPopUp = PopUpState.useShowPopUp()
    let {disputeEvidenceUpload} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

    let handleAcceptDispute = async () => {
      try {
        let url = getURL(
          ~entityName=ACCEPT_DISPUTE,
          ~methodType=Post,
          ~id=Some(data.dispute_id),
          (),
        )
        let response = await updateDetails(url, Dict.make()->Js.Json.object_, Post, ())
        setDisputeData(_ => response)
        setDisputeStatus(_ => Accepted)
      } catch {
      | _ => ()
      }
    }

    let handlePopupOpen = () => {
      showPopUp({
        popUpType: (Warning, WithIcon),
        heading: "Accept this dispute?",
        description: "By accepting you will lose this dispute and will have to refund the amount to the user. You won’t be able to submit evidence once you accept"->React.string,
        handleConfirm: {text: "Proceed", onClick: _ => handleAcceptDispute()->ignore},
        handleCancel: {text: "Cancel"},
      })
    }

    <OrderUtils.Section
      customCssClass={`border border-jp-gray-940 border-opacity-75 dark:border-jp-gray-960 ${bgColor} rounded-md p-6 flex flex-col gap-6`}>
      <div className="flex items-center justify-between">
        <div className="flex gap-2 items-center">
          <p className="font-bold text-3xl">
            {DisputesEntity.amountValue(
              data.amount,
              data.currency->String.toUpperCase,
            )->React.string}
          </p>
          {getStatus(data)}
        </div>
        <RenderIf
          condition={disputeEvidenceUpload &&
          showDisputeInfoStatus->Array.includes(
            data.dispute_status->DisputesUtils.disputeStatusVariantMapper,
          )}>
          <div className="flex gap-4">
            <Button
              buttonType={Secondary}
              text="Accept Dispute"
              buttonSize={Small}
              customButtonStyle="!py-3 !px-2.5"
              onClick={_ => handlePopupOpen()}
            />
            <Button
              buttonType={Primary}
              text="Counter Dispute"
              buttonSize={Small}
              customButtonStyle="!py-3 !px-2.5"
              buttonState={Disabled}
            />
          </div>
        </RenderIf>
      </div>
      <div className="h-px w-full bg-grey-200 opacity-30" />
      <RenderIf
        condition={disputeEvidenceUpload &&
        showDisputeInfoStatus->Array.includes(
          data.dispute_status->DisputesUtils.disputeStatusVariantMapper,
        )}>
        <DisputesInfoBarComponent disputeStatus />
      </RenderIf>
      <FormRenderer.DesktopRow>
        <div
          className={`flex flex-wrap ${justifyClassName} dark:bg-jp-gray-lightgray_background dark:border-jp-gray-no_data_border`}>
          {detailsFields
          ->Array.mapWithIndex((colType, i) => {
            <RenderIf
              condition={!(excludeColKeys->Array.includes(colType))} key={Belt.Int.toString(i)}>
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
    <>
      <div className={`font-bold text-fs-16 dark:text-white dark:text-opacity-75 mt-4 mb-4`}>
        {"Summary"->React.string}
      </div>
      <Details data=disputesData getHeading getCell detailsFields=allColumns setDisputeData />
      <DisputesNoteComponent disputesData />
    </>
  }
}

@react.component
let make = (~id) => {
  open APIUtils
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (disputeData, setDisputeData) = React.useState(_ => Js.Json.null)

  let fetchDisputesData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let disputesUrl = getURL(~entityName=DISPUTES, ~methodType=Get, ~id=Some(id), ())
      let response = await fetchDetails(disputesUrl)
      setDisputeData(_ => response)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Js.Exn.Error(e) =>
      let err = Js.Exn.message(e)->Option.getOr("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }

  React.useEffect0(() => {
    fetchDisputesData()->ignore
    None
  })
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
      <DisputesInfo orderDict={disputeData->LogicUtils.getDictFromJsonObject} setDisputeData />
    </div>
  </PageLoaderWrapper>
}
