open ApplePayIntegrationTypes
module SimplifiedHelper = {
  @react.component
  let make = (~customElement=?, ~heading="", ~stepNumber="1", ~subText=None) => {
    let {globalUIConfig: {backgroundColor, font: {textColor}}} = React.useContext(
      ThemeProvider.themeContext,
    )
    let bgColor = "bg-white"
    let stepColor = `${backgroundColor} text-white py-px px-2`

    <div className={`flex flex-col py-8 px-6 gap-3 ${bgColor} cursor-pointer`}>
      <div className={"flex justify-between "}>
        <div className="flex gap-4">
          <div>
            <p className={`${stepColor} font-medium`}> {stepNumber->React.string} </p>
          </div>
          <div>
            <p className={`font-medium text-base ${textColor.primaryNormal}`}>
              {heading->React.string}
            </p>
            <RenderIf condition={subText->Option.isSome}>
              <p className={`mt-2 text-base text-hyperswitch_black opacity-50 font-normal`}>
                {subText->Option.getOr("")->React.string}
              </p>
            </RenderIf>
            {switch customElement {
            | Some(element) => element
            | _ => React.null
            }}
          </div>
        </div>
      </div>
    </div>
  }
}

module HostURL = {
  @react.component
  let make = (~prefix="") => {
    let fieldInputVal = ReactFinalForm.useField(`${prefix}`).input
    let fieldInput = switch fieldInputVal.value->JSON.Decode.string {
    | Some(val) => val->LogicUtils.isNonEmptyString ? val : "domain_name"
    | None => "domain_name"
    }

    <p className="mt-2">
      {`${fieldInput}/.well-known/apple-developer-merchantid-domain-association`->React.string}
    </p>
  }
}

module SampleEmail = {
  @react.component
  let make = () => {
    let showToast = ToastState.useShowToast()

    let (isTextVisible, setIsTextVisible) = React.useState(_ => false)

    let businessDescription = "<One sentence about your business>. The business operates across <XX> countries and has customers across the world."
    let featureReqText = "We are using Hyperswitch, a Level 1 PCI DSS 3.2.1 compliant Payments Orchestrator, to manage payments on our website. In addition to Stripe, since we are using other processors as well to process payments across multiple geographies, we wanted to use Hyperswitch's Payment Processing certificate to decrypt Apple pay tokens and send the decrypted Apple pay tokens to Stripe. So, please enable processing decrypted Apple pay token feature on our Stripe account. We've attached Hyperswitch's PCI DSS AoC for reference."

    let emailContent = `Stripe Account id: <Enter your account id>

    A detailed business description: 
    ${businessDescription}

    Feature Request:
    ${featureReqText}`

    let truncatedText = isTextVisible
      ? featureReqText
      : featureReqText->String.slice(~start=0, ~end=50)

    let truncatedTextElement =
      <p className="flex gap-2">
        {truncatedText->React.string}
        <p
          className="cursor-pointer text-blue-400 text-xl"
          onClick={_ => setIsTextVisible(_ => true)}>
          {"..."->React.string}
        </p>
      </p>

    <div className="flex flex-col">
      <span className="mt-2 text-base  font-normal">
        <span className="text-hyperswitch_black opacity-50">
          {"Since the Apple Pay Web Domain flow involves decryption at Hyperswitch, you would need to write to Stripe support (support@stripe.com) to get this feature enabled for your Stripe account. You can use the following text in the email, attach our"->React.string}
        </span>
        <Link
          to_={`/compliance`}
          openInNewTab=false
          className="text-blue-600 underline underline-offset-2 px-2 !opacity-100">
          {"PCI DSS AoC certificate"->React.string}
        </Link>
        <span className="text-hyperswitch_black opacity-50">
          {"and copy our Support team (biz@hyperswitch.io):"->React.string}
        </span>
      </span>
      <div className="border border-gray-400 rounded-md flex flex-row gap-8 p-4 mt-4 bg-gray-200">
        <div className="flex flex-col gap-4 ">
          <span>
            {"Stripe Account id: <Enter your account id:you can find it "->React.string}
            <a
              className="underline text-blue-400 underline-offset-1"
              href="https://dashboard.stripe.com/settings/user">
              {"here"->React.string}
            </a>
            <span> {">"->React.string} </span>
          </span>
          <span>
            <p> {"A detailed business description:"->React.string} </p>
            {businessDescription->React.string}
          </span>
          <span>
            <p> {"Feature Request:"->React.string} </p>
            {isTextVisible ? truncatedText->React.string : truncatedTextElement}
          </span>
        </div>
        <img
          src={`/assets/CopyToClipboard.svg`}
          className="cursor-pointer h-fit w-fit"
          onClick={_ => {
            Clipboard.writeText(emailContent)
            showToast(~message="Copied to Clipboard!", ~toastType=ToastSuccess, ())
          }}
        />
      </div>
    </div>
  }
}

module CustomTag = {
  @react.component
  let make = (~tagText="", ~tagSize=5, ~tagLeftIcon=None, ~tagCustomStyle="") => {
    <div
      className={`flex items-center gap-1  shadow-connectorTagShadow border rounded-full px-2 py-1 ${tagCustomStyle}`}>
      {switch tagLeftIcon {
      | Some(icon) =>
        <div>
          <Icon name={icon} size={tagSize} />
        </div>
      | None => React.null
      }}
      <div className={"text-hyperswitch_black text-sm font-medium text-green-960"}>
        {tagText->React.string}
      </div>
    </div>
  }
}

module InfoCard = {
  @react.component
  let make = (~children, ~customInfoStyle="") => {
    <div
      className={`rounded border bg-blue-800 border-blue-700 dark:border-blue-700 relative flex w-full p-6 `}>
      <Icon className=customInfoStyle name="info-circle-unfilled" size=16 />
      <div> {children} </div>
    </div>
  }
}

let applePayValueInput = (
  ~applePayField: CommonMetaDataTypes.inputField,
  ~integrationType: option<applePayIntegrationType>=None,
  (),
) => {
  open CommonMetaDataHelper
  let {\"type", name} = applePayField
  let formName = ApplePayIntegrationUtils.applePayNameMapper(~name, ~integrationType)

  {
    switch \"type" {
    | Text => textInput(~field={applePayField}, ~formName)
    | Select => selectInput(~field={applePayField}, ~formName, ())
    | MultiSelect => multiSelectInput(~field={applePayField}, ~formName)
    | _ => textInput(~field={applePayField}, ~formName)
    }
  }
}
