open Typography

module FormSection = {
  @react.component
  let make = (~title, ~children) => {
    <div className="flex flex-col gap-4">
      <div className={`${heading.sm.semibold} text-nd_gray-700`}> {title->React.string} </div>
      <div className="flex flex-col gap-4 border border-nd_gray-150 bg-white rounded-xl p-5">
        children
      </div>
    </div>
  }
}

module FieldRow = {
  @react.component
  let make = (~fields) => {
    <div className="grid grid-cols-1 md:grid-cols-2 gap-x-8 gap-y-2">
      {fields
      ->Array.mapWithIndex((field, index) =>
        <FormRenderer.FieldRenderer key={index->Int.toString} field fieldWrapperClass="w-full" />
      )
      ->React.array}
    </div>
  }
}

module DemoModeBanner = {
  @react.component
  let make = () => {
    <AlertV2Binding
      alertType=Primary
      slot={{
        slot: <div className="flex items-center gap-2">
          <Icon name="nd-toast-info" size=20 className="text-nd_primary_blue-450" />
          <p className={body.md.regular}>
            {"You are viewing Offers in demo mode. To enable this feature for your merchant account, please reach out to us on "->React.string}
            <a
              href=GlobalVars.hyperswitchSlackUrl
              className="text-nd_primary_blue-450 hover:underline cursor-pointer"
              target="_blank">
              {"Slack"->React.string}
            </a>
          </p>
        </div>,
      }}
    />
  }
}

module DemoFeatureCard = {
  @react.component
  let make = (~icon, ~heading, ~description) => {
    <div className="flex flex-col gap-3 border border-nd_gray-150 rounded-xl p-5 bg-white">
      <div className="flex items-center justify-center w-9 h-9 rounded-lg bg-nd_primary_blue-50">
        <Icon name=icon size=18 className="text-nd_primary_blue-450" />
      </div>
      <div className="flex flex-col gap-1">
        <p className={`${body.md.semibold} text-nd_gray-700`}> {heading->React.string} </p>
        <p className={`${body.md.regular} text-nd_gray-400`}> {description->React.string} </p>
      </div>
    </div>
  }
}

module DemoLanding = {
  @react.component
  let make = () => {
    let mixpanelEvent = MixpanelHook.useSendEvent()

    let goToCreateOffer = (~eventName) => {
      mixpanelEvent(~eventName)
      RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/offers/new"))
    }

    <div className="flex flex-col gap-12">
      <div className="flex justify-between items-start">
        <PageUtils.PageHeading
          title="Offers"
          customHeadingStyle="mb-2"
          subTitle="View and manage offers for this merchant"
        />
        <Button
          text="Create New Offer"
          buttonType=Primary
          leftIcon={CustomIcon(<Icon name="plus" size=13 />)}
          onClick={_ => goToCreateOffer(~eventName="offers_demo_create_offer")}
        />
      </div>
      <div className="flex flex-col gap-4">
        <div className="flex flex-col gap-1">
          <p className={heading.md.semibold}>
            {"Run card offers and discounts at checkout"->React.string}
          </p>
          <p className={`${body.lg.regular} text-nd_gray-400`}>
            {"Create targeted offers that are applied automatically at checkout, with full control over who is eligible, how much they save, and how much each campaign can spend."->React.string}
          </p>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {OffersUtils.demoFeatures
          ->Array.map(feature =>
            <DemoFeatureCard
              key=feature.heading
              icon=feature.icon
              heading=feature.heading
              description=feature.description
            />
          )
          ->React.array}
        </div>
      </div>
      <div className="flex flex-col gap-4">
        <div className="flex flex-col gap-1">
          <p className={heading.md.semibold}> {"Get started with Offers"->React.string} </p>
          <p className={`${body.lg.regular} text-nd_gray-400`}>
            {"Offers isn't active for your merchant account yet. Preview the offer setup to see everything you can configure, and reach out to us to start creating offers."->React.string}
          </p>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-8 w-full">
          <ActionItem
            heading="Preview the offer setup to see every option available"
            leftElement={<Icon name="nd-eye-on" size=20 className="text-nd_primary_blue-450" />}
            customClass="py-4 bg-white"
            onClick={_ => goToCreateOffer(~eventName="offers_demo_preview_offer_setup")}
          />
          <ActionItem
            heading="Reach out to us on Slack to activate Offers"
            leftElement={<Icon
              name="nd-external-link-square" size=20 className="text-nd_primary_blue-450"
            />}
            customClass="py-4 bg-white"
            onClick={_ => {
              mixpanelEvent(~eventName="offers_demo_contact_us")
              GlobalVars.hyperswitchSlackUrl->Window._open
            }}
          />
        </div>
      </div>
    </div>
  }
}
