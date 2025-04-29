module BillingAddress = {
  @react.component
  let make = (~isSameAsBilling, ~setIsSameAsBilling) => {
    open FormRenderer
    open SDKPaymentUtils

    <>
      <DesktopRow itemWrapperClass="">
        <FieldRenderer field=enterBillingFirstName />
        <FieldRenderer field=enterBillingLastName />
      </DesktopRow>
      <FieldRenderer field=enterBillingAddress />
      <DesktopRow itemWrapperClass="">
        <FieldRenderer field=enterBillingCity />
        <FieldRenderer field=enterBillingState />
      </DesktopRow>
      <DesktopRow itemWrapperClass="">
        <FieldRenderer field=enterBillingCountry />
        <FieldRenderer field=enterBillingZipcode />
      </DesktopRow>
      <DesktopRow itemWrapperClass="">
        <FieldRenderer field=selectCountryPhoneCodeFieldForBilling />
        <FieldRenderer field=enterBillingPhoneNumber />
      </DesktopRow>
      <div>
        <label className="flex items-center mt-2 cursor-pointer p-2">
          <input
            type_="checkbox"
            checked=isSameAsBilling
            onChange={_ => setIsSameAsBilling(prev => !prev)}
            className="mr-2"
          />
          <span className="text-sm"> {"Use as shipping address"->React.string} </span>
        </label>
      </div>
    </>
  }
}

module ShippingAddress = {
  @react.component
  let make = (~isSameAsBilling) => {
    open FormRenderer
    open SDKPaymentUtils

    <RenderIf condition={!isSameAsBilling}>
      <DesktopRow itemWrapperClass="">
        <FieldRenderer field=enterShippingFirstName />
        <FieldRenderer field=enterShippingLastName />
      </DesktopRow>
      <FieldRenderer field=enterShippingAddress />
      <DesktopRow itemWrapperClass="">
        <FieldRenderer field=enterShippingCity />
        <FieldRenderer field=enterShippingState />
      </DesktopRow>
      <DesktopRow itemWrapperClass="">
        <FieldRenderer field=enterShippingCountry />
        <FieldRenderer field=enterShippingZipcode />
      </DesktopRow>
      <DesktopRow itemWrapperClass="">
        <FieldRenderer field=selectCountryPhoneCodeFieldForShipping />
        <FieldRenderer field=enterShippingPhoneNumber />
      </DesktopRow>
    </RenderIf>
  }
}

@react.component
let make = () => {
  let (showBillingAddress, setShowBillingAddress) = React.useState(() => true)
  let (isSameAsBilling, setIsSameAsBilling) = React.useState(() => true)

  let customTagComponent =
    <label className="inline-flex items-center cursor-pointer">
      <input
        type_="checkbox"
        checked=showBillingAddress
        onChange={_ => setShowBillingAddress(prev => !prev)}
        className="sr-only peer"
      />
      <div
        className="relative w-11 h-6 bg-gray-200 peer-focus:outline-none rounded-full peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"
      />
    </label>

  <div className="border p-4">
    <PageUtils.PageHeading
      title="Billing Address"
      customTitleStyle="!text-xl !font-semibold"
      customTagComponent
      customTitleSectionStyles="!justify-between"
      customHeadingStyle=""
    />
    <RenderIf condition=showBillingAddress>
      <BillingAddress isSameAsBilling setIsSameAsBilling />
    </RenderIf>
    <RenderIf condition={showBillingAddress && !isSameAsBilling}>
      <ShippingAddress isSameAsBilling />
    </RenderIf>
  </div>
}
