open AdditionalDetailsSidebarHelper
open Typography

module ApplePaySimplifiedLandingCard = {
  @react.component
  let make = (~setApplePayIntegrationType, ~appleIntegrationType) => {
    <div
      className="p-6 m-2 cursor-pointer"
      onClick={_ => setApplePayIntegrationType(_ => #simplified)}>
      <Card heading="Web Domain" isSelected={appleIntegrationType === #simplified}>
        <div className={` mt-2 text-base text-hyperswitch_black opacity-50 font-normal`}>
          {"Get Apple Pay enabled on your web domains by hosting a verification file, that’s it."->React.string}
        </div>
        <div className="flex gap-2 mt-4">
          <CustomTag tagText="Faster Configuration" tagSize=4 tagLeftIcon=Some("ellipse-green") />
          <CustomTag tagText="Recommended" tagSize=4 tagLeftIcon=Some("ellipse-green") />
        </div>
      </Card>
    </div>
  }
}

module ApplePayManualLandingCard = {
  @react.component
  let make = (~setApplePayIntegrationType, ~appleIntegrationType) => {
    <div className="p-6 m-2 cursor-pointer" onClick={_ => setApplePayIntegrationType(_ => #manual)}>
      <Card heading="iOS Certificate" isSelected={appleIntegrationType === #manual}>
        <div className={` mt-2 text-base text-hyperswitch_black opacity-50 font-normal`}>
          <CustomSubText />
        </div>
        <div className="flex gap-2 mt-4">
          <CustomTag tagText="For Web & Mobile" tagSize=4 tagLeftIcon=Some("ellipse-green") />
          <CustomTag
            tagText="Additional Details Required" tagSize=4 tagLeftIcon=Some("ellipse-green")
          />
        </div>
      </Card>
    </div>
  }
}

module ApplePayDecryptedLandingBanner = {
  @react.component
  let make = () => {
    <div
      className="p-4 cursor-pointer border border-nd_yellow-500 bg-nd_yellow-50 rounded-xl mx-6 mt-4 my-6">
      <div className={`${body.lg.semibold}`}>
        {"Decrypted flow is enabled by default and needs no setup"->React.string}
      </div>
      <div className={`mt-2 text-hyperswitch_black opacity-50 ${body.md.regular}`}>
        {"If needed, choose one of the options below to continue. Once connected, you can't revert back."->React.string}
      </div>
    </div>
  }
}
