open Typography

module Landing = {
  @react.component
  let make = (
    ~googlePayIntegrationType,
    ~closeModal,
    ~setGooglePayIntegrationStep,
    ~setGooglePayIntegrationType,
    ~connector,
    ~update,
  ) => {
    open GPayFlowTypes
    open AdditionalDetailsSidebarHelper

    let handleConfirmClick = () => {
      if googlePayIntegrationType === #decryption {
        update(JSON.Encode.null)->ignore
        closeModal()
      } else {
        setGooglePayIntegrationStep(_ => Configure)
      }
    }
    <>
      {switch connector->ConnectorUtils.getConnectorNameTypeFromString {
      | Processors(NUVEI)
      | Processors(WORLDPAYVANTIV) =>
        <>
          <div
            className="p-6 m-2 cursor-pointer"
            onClick={_ => setGooglePayIntegrationType(_ => #decryption)}>
            <Card heading="Decrypted Flow" isSelected={googlePayIntegrationType == #decryption}>
              <div className={`${body.lg.regular} mt-2 text-nd_gray-500`}>
                {"Instantly enable Google Pay with no information or configuration needed."->React.string}
              </div>
              <div className="flex gap-2 mt-4">
                <CustomTag
                  tagText="No Details Required" tagSize=4 tagLeftIcon=Some("ellipse-green")
                />
              </div>
            </Card>
          </div>
          <div
            className="p-6 m-2 cursor-pointer"
            onClick={_ => setGooglePayIntegrationType(_ => #payment_gateway)}>
            <Card
              heading="Payment Gateway" isSelected={googlePayIntegrationType === #payment_gateway}>
              <div className={`${body.lg.regular} mt-2 text-nd_gray-500`}>
                {"Integrate Google Pay with your payment gateway."->React.string}
              </div>
              <div className="flex gap-2 mt-4">
                <CustomTag
                  tagText="Faster Configuration" tagSize=4 tagLeftIcon=Some("ellipse-green")
                />
                <CustomTag tagText="Recommended" tagSize=4 tagLeftIcon=Some("ellipse-green") />
              </div>
            </Card>
          </div>
        </>
      | Processors(TESOURO) =>
        <>
          <div
            className="p-6 m-2 cursor-pointer"
            onClick={_ => setGooglePayIntegrationType(_ => #decryption)}>
            <Card heading="Decrypted Flow" isSelected={googlePayIntegrationType == #decryption}>
              <div className={`${body.lg.regular} mt-2 text-nd_gray-500`}>
                {"Instantly enable Google Pay with no information or configuration needed."->React.string}
              </div>
              <div className="flex gap-2 mt-4">
                <CustomTag
                  tagText="No Details Required" tagSize=4 tagLeftIcon=Some("ellipse-green")
                />
              </div>
            </Card>
          </div>
          <div
            className="p-6 m-2 cursor-pointer"
            onClick={_ => setGooglePayIntegrationType(_ => #direct)}>
            <Card heading="Direct" isSelected={googlePayIntegrationType === #direct}>
              <div className={` ${body.lg.regular} mt-2 text-nd_gray-500`}>
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
        </>
      | _ =>
        <>
          <div
            className="p-6 m-2 cursor-pointer"
            onClick={_ => setGooglePayIntegrationType(_ => #payment_gateway)}>
            <Card
              heading="Payment Gateway" isSelected={googlePayIntegrationType === #payment_gateway}>
              <div className={` ${body.lg.regular} mt-2 text-nd_gray-500`}>
                {"Integrate Google Pay with your payment gateway."->React.string}
              </div>
              <div className="flex gap-2 mt-4">
                <CustomTag
                  tagText="Faster Configuration" tagSize=4 tagLeftIcon=Some("ellipse-green")
                />
                <CustomTag tagText="Recommended" tagSize=4 tagLeftIcon=Some("ellipse-green") />
              </div>
            </Card>
          </div>
          <div
            className="p-6 m-2 cursor-pointer"
            onClick={_ => setGooglePayIntegrationType(_ => #direct)}>
            <Card heading="Direct" isSelected={googlePayIntegrationType === #direct}>
              <div className={` ${body.lg.regular} mt-2 text-nd_gray-500`}>
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
        </>
      }}
      <div className={`flex gap-2 justify-end m-2 p-6`}>
        <Button
          text="Cancel"
          buttonType={Secondary}
          onClick={_ => {
            closeModal()
          }}
        />
        <Button onClick={_ => handleConfirmClick()} text="Continue" buttonType={Primary} />
      </div>
    </>
  }
}
