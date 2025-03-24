module Landing = {
  @react.component
  let make = (
    ~googlePayIntegrationType,
    ~closeModal,
    ~setGooglePayIntegrationStep,
    ~setGooglePayIntegrationType,
  ) => {
    open GPayFlowTypes
    open AdditionalDetailsSidebarHelper
    <>
      <div
        className="p-6 m-2 cursor-pointer"
        onClick={_ => setGooglePayIntegrationType(_ => #payment_gateway)}>
        <Card heading="Payment Gateway" isSelected={googlePayIntegrationType === #payment_gateway}>
          <div className={` mt-2 text-base text-hyperswitch_black opacity-50 font-normal`}>
            {"Integrate Google Pay with your payment gateway."->React.string}
          </div>
          <div className="flex gap-2 mt-4">
            <CustomTag tagText="Faster Configuration" tagSize=4 tagLeftIcon=Some("ellipse-green") />
            <CustomTag tagText="Recommended" tagSize=4 tagLeftIcon=Some("ellipse-green") />
          </div>
        </Card>
      </div>
      <div
        className="p-6 m-2 cursor-pointer" onClick={_ => setGooglePayIntegrationType(_ => #direct)}>
        <Card heading="Direct" isSelected={googlePayIntegrationType === #direct}>
          <div className={` mt-2 text-base text-hyperswitch_black opacity-50 font-normal`}>
            {"Google Pay Decryption at Hyperswitch: Unlock from PSP dependency."->React.string}
          </div>
          <div className="flex gap-2 mt-4">
            <CustomTag tagText="For Web & Mobile" tagSize=4 tagLeftIcon=Some("ellipse-green") />
            <CustomTag
              tagText="Additional Details Required" tagSize=4 tagLeftIcon=Some("ellipse-green")
            />
          </div>
        </Card>
      </div>
      <div className={`flex gap-2 justify-end m-2 p-6`}>
        <Button
          text="Cancel"
          buttonType={Secondary}
          onClick={_ => {
            closeModal()
          }}
        />
        <Button
          onClick={_ => setGooglePayIntegrationStep(_ => Configure)}
          text="Continue"
          buttonType={Primary}
        />
      </div>
    </>
  }
}
