@react.component
let make = () => {
  open PageUtils
  open AltPaymentMethodsUtils
  <div className="flex flex-1 flex-col gap-8  w-5/6 h-screen">
    <PageHeading
      customHeadingStyle="gap-2 flex flex-col "
      title="Alternate Payment Methods"
      customTitleStyle="text-2xl text-center font-bold text-nd_gray-700 font-600"
      customSubTitleStyle="text-lg font-medium  "
      subTitle="Augment your existing checkout using any Alternative Payment Method of your choice"
    />
    <div
      className="w-full h-64 rounded-lg border border-nd_gray-50 gap-2 bg-nd_gray-25 flex justify-center items-center">
      <object
        type_="image/svg+xml"
        data="/AlternatePaymentMethods/AlternatePaymentMethodsOnboarding.svg"
        className="w-full h-full"
        alt="alternatePaymentMethodsOnboarding"
      />
    </div>
    {alternatePaymentConfiguration
    ->Array.mapWithIndex((item, idx) =>
      <APMConfigureStep
        index=idx
        heading=item.heading
        description=item.description
        action=item.action
        buttonText=item.buttonText
      />
    )
    ->React.array}
  </div>
}
