open ApplePayIntegrationTypesV2
module SimplifiedHelper = {
  @react.component
  let make = (
    ~customElement: option<React.element>,
    ~heading="",
    ~stepNumber="1",
    ~subText=None,
  ) => {
    let {globalUIConfig: {backgroundColor, font: {textColor}}} = React.useContext(
      ConfigContext.configContext,
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
            <UIUtils.RenderIf condition={subText->Option.isSome}>
              <p className={`mt-2 text-base text-hyperswitch_black opacity-50 font-normal`}>
                {subText->Option.getOr("")->React.string}
              </p>
            </UIUtils.RenderIf>
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

let textInput = (
  ~applePayField: CommonWalletTypes.inputField,
  ~integrationType: option<applePayIntegrationType>,
) => {
  let {placeholder, label, name, required} = applePayField
  FormRenderer.makeFieldInfo(
    ~label,
    ~name=`${ApplePayIntegrationUtilsV2.applePayNameMapper(~name, ~integrationType)}`,
    ~placeholder,
    ~customInput=InputFields.textInput(),
    ~isRequired=required,
    (),
  )
}

let selectStringInput = (
  ~applePayField: CommonWalletTypes.inputField,
  ~options,
  ~integrationType: option<applePayIntegrationType>,
) => {
  let {label, name, required} = applePayField
  FormRenderer.makeFieldInfo(
    ~label,
    ~isRequired=required,
    ~name=`${ApplePayIntegrationUtilsV2.applePayNameMapper(~name, ~integrationType)}`,
    ~customInput=(~input) =>
      InputFields.selectInput(
        ~input={
          ...input,
          onChange: event => {
            let value = event->Identity.formReactEventToString
            input.onChange(value->Identity.anyTypeToReactEvent)
          },
        },
        ~options={options},
        ~buttonText="Select Value",
        (),
      ),
    (),
  )
}

let selectArrayInput = (
  ~applePayField: CommonWalletTypes.inputField,
  ~integrationType: option<applePayIntegrationType>,
) => {
  let {label, name, required, options} = applePayField
  FormRenderer.makeFieldInfo(
    ~label,
    ~isRequired=required,
    ~name=`${ApplePayIntegrationUtilsV2.applePayNameMapper(~name, ~integrationType)}`,
    ~customInput=InputFields.selectInput(
      ~deselectDisable=true,
      ~fullLength=true,
      ~customStyle="max-h-48",
      ~customButtonStyle="pr-3",
      ~options={options->SelectBox.makeOptions},
      ~buttonText="Select Value",
      (),
    ),
    (),
  )
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
