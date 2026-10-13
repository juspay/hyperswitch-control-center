open Typography
open OffersFormUtils
open OffersFormFields

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
  let make = (~fields, ~children=React.null) => {
    <div className="grid grid-cols-1 md:grid-cols-2 gap-x-8 gap-y-2">
      {fields
      ->Array.mapWithIndex((field, index) =>
        <FormRenderer.FieldRenderer
          key={index->Int.toString} field fieldWrapperClass="w-full" showErrorOnChange=true
        />
      )
      ->React.array}
      children
    </div>
  }
}

module CurrencyAmountFields = {
  @react.component
  let make = () => {
    let currencies =
      ReactFinalForm.useField("currencies").input.value->LogicUtils.getStrArrayFromJson

    currencies
    ->Array.map(currency =>
      <FieldRow
        key=currency fields=[currency->minOrderAmountField, currency->maxOrderAmountField]
      />
    )
    ->React.array
  }
}

module MaxAmountRow = {
  @react.component
  let make = () => {
    let {calculationRule} = OffersHooks.useOfferFormValues()

    <RenderIf condition={calculationRule == OffersTypes.Percentage}>
      <FieldRow fields=[maxAmountField] />
    </RenderIf>
  }
}

module CountPerCardFields = {
  @react.component
  let make = () => {
    let {startTime, endTime} = OffersHooks.useOfferFormValues()
    let options = offerDurationInSeconds(~startTime, ~endTime)->resetPeriodUnitOptionsForDuration

    <div className="flex items-end gap-3">
      <FormRenderer.FieldRenderer
        field=countPerCardField fieldWrapperClass="flex-1" showErrorOnChange=true
      />
      <span className={`pb-3 text-nd_gray-600 ${body.md.medium}`}> {"Per"->React.string} </span>
      <FormRenderer.FieldRenderer
        field={cardResetPeriodTypeField(~options)} fieldWrapperClass="w-56"
      />
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
              href="https://hyperswitch-io.slack.com/?redir=%2Fssb%2Fredirect"
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

module DemoLanding = {
  @react.component
  let make = () => {
    <div className="flex flex-col gap-4">
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
          onClick={_ =>
            RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/offers/new"))}
        />
      </div>
      <DemoModeBanner />
    </div>
  }
}
