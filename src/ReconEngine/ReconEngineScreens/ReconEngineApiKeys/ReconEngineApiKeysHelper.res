open Typography
open ReconEngineApiKeysTypes

module ActionsCell = {
  @react.component
  let make = (~item: apiKey, ~onAction) => {
    <div className="flex items-center gap-4">
      <Button
        buttonType=Transparent
        buttonSize=XSmall
        showBorder=false
        customBackColor="bg-transparent"
        customRoundedClass="rounded-none"
        customButtonStyle="!border-0"
        ariaLabel="Edit API key"
        showTooltip=true
        tooltipText="Edit API key"
        leftIcon={CustomIcon(<Icon name="edit" size=14 className="text-nd_gray-700" />)}
        customIconMargin="m-0"
        customPaddingClass="p-1"
        buttonState={item.status === Active ? Normal : Disabled}
        onClick={event => {
          event->ReactEvent.Mouse.stopPropagation
          onAction(item, Edit)
        }}
      />
      <Button
        buttonType=Transparent
        buttonSize=XSmall
        showBorder=false
        customBackColor="bg-transparent"
        customRoundedClass="rounded-none"
        customButtonStyle="!border-0"
        ariaLabel="Revoke API key"
        showTooltip=true
        tooltipText="Revoke API key"
        leftIcon={CustomIcon(<Icon name="delete" size=14 className="text-nd_gray-700" />)}
        customIconMargin="m-0"
        customPaddingClass="p-1"
        buttonState={item.status === Active ? Normal : Disabled}
        onClick={event => {
          event->ReactEvent.Mouse.stopPropagation
          onAction(item, Revoke)
        }}
      />
    </div>
  }
}

module ExpirationDateField = {
  @react.component
  let make = (~isDisabled) => {
    let {input} = ReactFinalForm.useField("expiration")
    let choice = input.value->ReconEngineApiKeysUtils.expirationChoiceFromJson
    <RenderIf condition={choice === CustomDate}>
      <FormRenderer.FieldRenderer
        field={ReconEngineApiKeysUtils.expirationDateField(~isDisabled)}
        fieldWrapperClass="w-full"
        errorClass=ReconEngineApiKeysUtils.errorClass
      />
    </RenderIf>
  }
}

module CreatedKey = {
  @react.component
  let make = (~apiKey: string, ~onDone) => {
    <div className="flex flex-col gap-5">
      <div className="rounded-lg border border-nd_yellow-200 bg-nd_yellow-50 p-4">
        <p className={`${body.md.semibold} text-nd_gray-800`}>
          {"Save your API key now"->React.string}
        </p>
        <p className={`${body.sm.regular} text-nd_gray-700 mt-1`}>
          {"This is the only time the full key will be shown. Store it securely before closing this window."->React.string}
        </p>
      </div>
      <div className="rounded-lg border border-nd_gray-200 bg-nd_gray-50 p-4">
        <HelperComponents.CopyTextCustomComp
          displayValue=Some("API key")
          copyValue=Some(apiKey)
          customTextCss={`${body.sm.medium} text-nd_gray-600`}
          customParentClass="flex items-center justify-between gap-3 mb-2"
          customComponent=Some(
            <Button
              buttonType=Transparent
              buttonSize=XSmall
              showBorder=false
              ariaLabel="Copy API key"
              showTooltip=true
              tooltipText="Copy API key"
              leftIcon={CustomIcon(<Icon name="nd-copy" size=16 className="text-nd_gray-600" />)}
              customIconMargin="m-0"
              customPaddingClass="p-1.5"
            />,
          )
        />
        <code className={`${body.md.regular} text-nd_gray-800 break-all select-all`}>
          {apiKey->React.string}
        </code>
      </div>
      <div className="flex justify-end gap-3">
        <Button text="Done" buttonSize=Small onClick={_ => onDone()} />
      </div>
    </div>
  }
}
