module BaseComponent = {
  open HSwitchUtils
  @react.component
  let make = (
    ~children,
    ~headerText="",
    ~showRightButtons=true,
    ~headerLeftIcon="",
    ~nextButton=React.null,
    ~backButton=React.null,
    ~customIcon=?,
    ~customCss="",
  ) => {
    let headerStyle = getTextClass(~textVariant=H3, ~h3TextVariant=Leading_1, ())
    <div
      className="w-standardPageWidth h-45-rem bg-white rounded-md flex flex-col gap-6 shadow-boxShadowMultiple overflow-scroll ">
      <div className="flex justify-between items-center px-10 pt-6">
        <div className="flex gap-2 items-center">
          <UIUtils.RenderIf
            condition={customIcon->Belt.Option.isNone && headerLeftIcon->String.length > 0}>
            <Icon name=headerLeftIcon size=25 />
          </UIUtils.RenderIf>
          <UIUtils.RenderIf condition={customIcon->Belt.Option.isSome}>
            {customIcon->Belt.Option.getWithDefault(React.null)}
          </UIUtils.RenderIf>
          <p className=headerStyle> {headerText->React.string} </p>
        </div>
        <UIUtils.RenderIf condition={showRightButtons}>
          <div className="flex gap-4 items-center">
            {backButton}
            {nextButton}
          </div>
        </UIUtils.RenderIf>
      </div>
      <div className="h-px w-full border" />
      <div className={`h-full px-10 pb-6 overflow-y-scroll ${customCss} overflow-x-hidden`}>
        {children}
      </div>
    </div>
  }
}

module StepCompletedPage = {
  @react.component
  let make = (~buttonGroup=React.null, ~headerText="") => {
    let textClass = `${HSwitchUtils.getTextClass(~textVariant=H2, ())} text-center`
    <div
      className="w-[40rem] p-16 flex flex-col gap-20 border rounded-md items-center bg-white shadow-boxShadowMultiple">
      <div className="flex flex-col gap-10 items-center">
        <Icon name="account-setup-completed" size=120 />
        <p className=textClass> {headerText->React.string} </p>
      </div>
      <HomeV2.HomePageHorizontalStepper
        stepperItemsArray=HomeUtils.homepageStepperItems className="!w-full"
      />
      {buttonGroup}
    </div>
  }
}

module VerticalChoiceTile = {
  open QuickStartTypes
  @react.component
  let make = (
    ~listChoices: array<landingChoiceType>,
    ~choiceState,
    ~setChoiceState,
    ~customLayoutCss,
  ) => {
    let getBlockColor = value =>
      choiceState === value ? "border border-blue-700 bg-blue-700 bg-opacity-10 " : "border"
    let headerTextStyle = `${HSwitchUtils.getTextClass(
        ~textVariant=P1,
        ~paragraphTextVariant=Medium,
        (),
      )} text-grey-700`
    let descriptionStyle = `${HSwitchUtils.getTextClass(
        ~textVariant=P2,
        ~paragraphTextVariant=Medium,
        (),
      )} text-grey-700 text-opacity-50`

    <div className={`grid grid-cols-1 gap-4 md:grid-cols-3 md:gap-4 ${customLayoutCss}`}>
      {listChoices
      ->Array.mapWithIndex((items, index) => {
        <div
          key={index->string_of_int}
          className={`p-6 flex flex-col gap-8 rounded-md cursor-pointer ${items.variantType->getBlockColor} rounded-md justify-between`}
          onClick={_ => setChoiceState(_ => items.variantType)}>
          <div className="flex justify-between items-center">
            <UIUtils.RenderIf condition={items.leftIcon->Belt.Option.isSome}>
              <Icon
                name={items.leftIcon->Belt.Option.getWithDefault("hyperswitch-short")}
                size=40
                className="cursor-pointer"
              />
            </UIUtils.RenderIf>
            <Icon
              name={choiceState === items.variantType ? "selected" : "nonselected"}
              size=20
              className="cursor-pointer !text-blue-800"
            />
          </div>
          <div className="flex flex-col gap-2">
            <p className=headerTextStyle> {items.displayText->React.string} </p>
            <p className=descriptionStyle> {items.description->React.string} </p>
          </div>
          <UIUtils.RenderIf condition={items.footerTags->Belt.Option.isSome}>
            <div className="flex gap-2 mt-6">
              {items.footerTags
              ->Belt.Option.getWithDefault([])
              ->Array.map(value =>
                <div
                  className="p-2 text-xs border border-blue-700 border-opacity-30 bg-blue-700 bg-opacity-10 rounded-md">
                  {value->React.string}
                </div>
              )
              ->React.array}
            </div>
          </UIUtils.RenderIf>
        </div>
      })
      ->React.array}
    </div>
  }
}
module HorizontalChoiceTile = {
  open QuickStartTypes
  @react.component
  let make = (
    ~listChoices: array<landingChoiceType>,
    ~choiceState,
    ~setChoiceState,
    ~customLayoutCss,
  ) => {
    let getBlockColor = value =>
      choiceState === value ? "border border-blue-700 bg-blue-700 bg-opacity-10 " : "border"
    let headerTextStyle = `${HSwitchUtils.getTextClass(
        ~textVariant=P1,
        ~paragraphTextVariant=Medium,
        (),
      )} text-grey-700`
    let descriptionStyle = `${HSwitchUtils.getTextClass(
        ~textVariant=P2,
        ~paragraphTextVariant=Medium,
        (),
      )} text-grey-700 text-opacity-50`

    <div className={`grid grid-cols-1 gap-4 md:grid-cols-2 md:gap-8 ${customLayoutCss}`}>
      {listChoices
      ->Array.mapWithIndex((items, index) => {
        <div
          key={index->string_of_int}
          className={`p-6 flex flex-col gap-4 rounded-md cursor-pointer ${items.variantType->getBlockColor} rounded-md`}
          onClick={_ => setChoiceState(_ => items.variantType)}>
          <div className="flex justify-between items-center">
            <div className="flex gap-2 items-center ">
              <p className=headerTextStyle> {items.displayText->React.string} </p>
            </div>
            <Icon
              name={choiceState === items.variantType ? "selected" : "nonselected"}
              size=20
              className="cursor-pointer !text-blue-800"
            />
          </div>
          <UIUtils.RenderIf
            condition={items.imageLink->Belt.Option.getWithDefault("")->String.length > 0}>
            <img alt="" src={items.imageLink->Belt.Option.getWithDefault("")} />
          </UIUtils.RenderIf>
          <div className="flex gap-2 items-center ">
            <p className=descriptionStyle> {items.description->React.string} </p>
          </div>
        </div>
      })
      ->React.array}
    </div>
  }
}

module LandingPageChoice = {
  @react.component
  let make = (
    ~choiceState,
    ~setChoiceState,
    ~listChoices,
    ~nextButton,
    ~headerText,
    ~backButton=React.null,
    ~isHeaderLeftIcon=true,
    ~customIcon=React.null,
    ~isVerticalTile=false,
    ~customLayoutCss="",
  ) => {
    React.useEffect0(() => {
      setChoiceState(_ => #NotSelected)
      None
    })

    <BaseComponent
      headerText
      headerLeftIcon={isHeaderLeftIcon ? "hyperswitch-logo-short" : ""}
      customIcon
      nextButton
      backButton>
      {if isVerticalTile {
        <VerticalChoiceTile listChoices choiceState setChoiceState customLayoutCss />
      } else {
        <HorizontalChoiceTile listChoices choiceState setChoiceState customLayoutCss />
      }}
    </BaseComponent>
  }
}

module SelectConnectorGrid = {
  @react.component
  let make = (~selectedConnector, ~setSelectedConnector, ~connectorList) => {
    open ConnectorTypes
    let typedConnectedConnectorList =
      HyperswitchAtom.connectorListAtom
      ->Recoil.useRecoilValueFromAtom
      ->LogicUtils.safeParse
      ->HSwitchUtils.getProcessorsListFromJson()
      ->Array.map(connectorDict =>
        connectorDict
        ->LogicUtils.getString("connector_name", "")
        ->ConnectorUtils.getConnectorNameTypeFromString
      )
    let popularConnectorList = [STRIPE, PAYPAL, ADYEN, CHECKOUT]->Array.filter(connector => {
      !(typedConnectedConnectorList->Array.includes(connector))
    })
    let remainingConnectorList =
      connectorList->Array.filter(value =>
        !(
          popularConnectorList->Array.includes(value) ||
            typedConnectedConnectorList->Array.includes(value)
        )
      )

    let headerClass = HSwitchUtils.getTextClass(~textVariant=P1, ~paragraphTextVariant=Medium, ())

    let subheaderText = "text-base font-semibold text-grey-700"
    let getBlockColor = connector =>
      selectedConnector === connector
        ? "border border-blue-700 bg-blue-700 bg-opacity-10 "
        : "border"
    <div className="flex flex-col gap-12">
      <UIUtils.RenderIf condition={popularConnectorList->Array.length > 0}>
        <div className="flex flex-col gap-4">
          <p className=headerClass> {"Popular Processors"->React.string} </p>
          <div className="grid grid-cols-1 gap-6 md:grid-cols-5 ">
            {popularConnectorList
            ->Array.mapWithIndex((connector, index) => {
              let connectorName = connector->ConnectorUtils.getConnectorNameString
              <div
                key={index->string_of_int}
                className={`py-4 px-6 flex gap-4 rounded-md cursor-pointer justify-between items-start ${connector->getBlockColor}`}
                onClick={_ => setSelectedConnector(_ => connector)}>
                <div className="flex flex-col gap-2 items-start ">
                  <GatewayIcon gateway={connectorName->String.toUpperCase} className="w-12 h-12" />
                  <p className=subheaderText>
                    {connectorName->LogicUtils.capitalizeString->React.string}
                  </p>
                </div>
                <Icon
                  name={connector === selectedConnector ? "selected" : "nonselected"}
                  size=20
                  className="cursor-pointer !text-blue-800"
                />
              </div>
            })
            ->React.array}
          </div>
        </div>
      </UIUtils.RenderIf>
      <div className="flex flex-col gap-4">
        <p className=headerClass> {"More Processors"->React.string} </p>
        <div className="grid grid-cols-1 gap-4 md:grid-cols-3 md:gap-8">
          {remainingConnectorList
          ->Array.mapWithIndex((connector, index) => {
            let connectorName = connector->ConnectorUtils.getConnectorNameString
            <div
              key={index->string_of_int}
              className={`py-4 px-6 flex flex-col gap-4 rounded-md cursor-pointer ${connector->getBlockColor}`}
              onClick={_ => setSelectedConnector(_ => connector)}>
              <div className="flex justify-between items-center">
                <div className="flex gap-2 items-center ">
                  <GatewayIcon gateway={connectorName->String.toUpperCase} className="w-8 h-8" />
                  <p className=subheaderText>
                    {connectorName->LogicUtils.capitalizeString->React.string}
                  </p>
                </div>
                <Icon
                  name={connector === selectedConnector ? "selected" : "nonselected"}
                  size=20
                  className="cursor-pointer !text-blue-800"
                />
              </div>
            </div>
          })
          ->React.array}
        </div>
      </div>
    </div>
  }
}
