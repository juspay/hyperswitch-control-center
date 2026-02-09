open AdditionalDetailsSidebarHelper
open Typography

module ApplePaySimplifiedLandingCard = {
  @react.component
  let make = (~setApplePayIntegrationType, ~appleIntegrationType) => {
     let shadowClass = appleIntegrationType === #simplified ?
      "shadow-cardSelectedShadow"
      :"shadow-md"

    <div className=" cursor-pointer" onClick={_ => setApplePayIntegrationType(_ => #simplified)}>
      <Card
        heading="Web Domain"
        customCardHeaderStyle=`border rounded-md !bg-white ${shadowClass}`
        isSelected={appleIntegrationType === #simplified}>
        <div className={`mt-2 ${body.md.medium}  text-nd_gray-400`}>
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
      let shadowClass = appleIntegrationType === #manual ?
      "shadow-cardSelectedShadow"
      :"shadow-md"


    <div className="cursor-pointer" onClick={_ => setApplePayIntegrationType(_ => #manual)}>
      <Card
        heading="iOS Certificate"
        customCardHeaderStyle=`border rounded-md !bg-white ${shadowClass}`
        isSelected={appleIntegrationType === #manual}>
        <div className={` mt-2 ${body.md.medium}  text-nd_gray-400`}>
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

module ApplePayPreDecryptLandingCard = {
  @react.component
  let make = (~setApplePayIntegrationType, ~appleIntegrationType) => {
      let shadowClass = appleIntegrationType === #predecrypt ?
      "shadow-cardSelectedShadow"
      :"shadow-md"
      
    <div className="cursor-pointer" onClick={_ => setApplePayIntegrationType(_ => #predecrypt)}>
      <Card
        heading="Pre Decrypted Token"
        customCardHeaderStyle=`border rounded-md !bg-white ${shadowClass}`
        isSelected={appleIntegrationType === #predecrypt}>
        <div className={`mt-2 ${body.md.medium}  text-nd_gray-400`}>
          {"Enable Apple Pay by securely decrypting the Apple Pay payment token on your end."->React.string}
        </div>
      </Card>
    </div>
  }
}
