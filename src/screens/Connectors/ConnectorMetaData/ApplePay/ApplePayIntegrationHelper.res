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
