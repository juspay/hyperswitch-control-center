let subTextStyle = "text-base font-normal text-grey-700 opacity-50"
let headerTextStyle = "text-xl font-semibold text-grey-700"

module WarningBlock = {
  @react.component
  let make = (~warningText="", ~customComponent=None) => {
    let warningSection = switch customComponent {
    | Some(customComponent) => <> {customComponent} </>
    | None => <p className={`${subTextStyle} !opacity-100`}> {warningText->React.string} </p>
    }
    <div
      className="flex gap-2 bg-orange-200 w-fit p-4 border rounded-md border-orange-500 items-center">
      <Icon name="warning-outlined" size=25 />
      {warningSection}
    </div>
  }
}

module ModalChildElementsForSpecificConnector = {
  @react.component
  let make = (~connector: ConnectorTypes.connectorName) => {
    switch connector {
    | STRIPE =>
      // TODO - Will Add for the rest if given
      <>
        <ol className="list-decimal pl-4">
          <li className="mb-8"> {"Open Stripe Dashboard"->React.string} </li>
          <li className="mb-8">
            {"Navigate to the webhooks section of your Stripe dashboard (Developers -> Webhooks)"->React.string}
          </li>
          <li className="mb-8">
            {"Create a new webhook by clicking on Add an endpoint."->React.string}
          </li>
          <li className="mb-8">
            {"Enter the Hyperswitch url under the Endpoint URL: https://sandbox.hyperswitch.io/webhooks/{{Your_Hyperswitch_Merchant_ID}}/stripe"->React.string}
            <span>
              {"Note: You can Find your Set Country and Label in Hyperswitch under Connectors -> Processors -> Stripe"->React.string}
            </span>
          </li>
          <li className="mb-8">
            {"Note: Hyperswitch currently does not support source verification."->React.string}
          </li>
        </ol>
        <div> {"Steps to Follow on Hyperswitch Dashboard : "->React.string} </div>
        <ol className="list-decimal pl-4">
          <li className="mb-8"> {"Under Developers Tab > Webhooks"->React.string} </li>
          <li className="mb-8">
            {"Enter the URL where you want to receive the Webhooks"->React.string}
          </li>
          <li className="mb-8"> {"Click Update"->React.string} </li>
        </ol>
        <div className="italic">
          {"Congratulations! You have successfully configured with Stripe via Hyperswitch. Now in order to test the integration you can follow one of the following steps Test via Hyperswitch dashboard"->React.string}
        </div>
      </>
    | _ => React.null
    }
  }
}

module SetupWebhookProcessor = {
  @react.component
  let make = (
    ~connectorName="",
    ~headerSectionText,
    ~subtextSectionText,
    ~customRightSection,
    ~rightTag=React.null,
  ) => {
    let (showModal, setShowModal) = React.useState(_ => false)

    <div className="flex flex-col gap-8">
      // TODO To pick up when Product Team will give all the Docs
      // <UIUtils.RenderIf condition={connectorName->String.length > 0}>
      //   <p
      //     className={`${highlightedText} underline`}
      //     onClick={_ => {
      //       setShowModal(_ => true)
      //     }}>
      //     {`View Steps to Setup Webhooks on ${connectorName}`->React.string}
      //   </p>
      // </UIUtils.RenderIf>
      <div
        className="grid grid-cols-1 lg:grid-cols-2 bg-jp-gray-light_gray_bg p-10 items-center gap-6">
        <div className="flex flex-col gap-2 col-span-1">
          <div className="flex gap-4 items-center">
            <p className={`${subTextStyle} !opacity-100`}> {headerSectionText->React.string} </p>
            {rightTag}
          </div>
          <p className=subTextStyle> {subtextSectionText->React.string} </p>
        </div>
        <div className="col-span-1"> {customRightSection} </div>
      </div>
      <CustomizeNotificationsModal
        modalHeading="Steps to Setup Webook"
        headerTextClass="!text-xl !font-semibold !ml-3.5"
        element={<ModalChildElementsForSpecificConnector
          connector={connectorName->ConnectorUtils.getConnectorNameTypeFromString}
        />}
        showModal
        setShowModal
        onSubmitModal={_ => ()}
        showBackIcon=false
        onCloseClickCustomFun={_ => setShowModal(_ => false)}
        onBackClick={_ => setShowModal(_ => false)}
        headingClassOverride="!p-12"
        headerAlignmentClass="items-center"
        showModalHeadingIconName={connectorName->String.toUpperCase}
        overlayBG="bg-banner_black opacity-50"
        modalWidth="w-[35vw] !border-none"
        customIcon={Some(
          <GatewayIcon gateway={connectorName->String.toUpperCase} className="w-12 h-12" />,
        )}
      />
    </div>
  }
}

module BasicAccountSetupSuccessfulPage = {
  @react.component
  let make = (
    ~iconName,
    ~statusText,
    ~buttonText,
    ~buttonOnClick,
    ~customWidth="w-full",
    ~bgColor="bg-green-success_page_bg",
    ~buttonState=Button.Normal,
    ~isButtonVisible=true,
  ) => {
    <div className={`flex flex-col gap-4 p-9 h-full ${customWidth} justify-between rounded shadow`}>
      <div className={`p-4 h-5/6 ${bgColor} flex flex-col justify-center items-center gap-8`}>
        <Icon name=iconName size=120 />
        <p className=headerTextStyle> {statusText->React.string} </p>
      </div>
      <UIUtils.RenderIf condition={isButtonVisible}>
        <Button
          text=buttonText
          buttonSize={Small}
          buttonType={Primary}
          customButtonStyle="!rounded-md"
          onClick={_ => buttonOnClick()}
          buttonState
        />
      </UIUtils.RenderIf>
    </div>
  }
}
