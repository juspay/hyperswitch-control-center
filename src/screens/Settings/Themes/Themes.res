open ThemePreviewUtils
open Typography

type themeOption = {
  label: string,
  value: string,
  icon: React.element,
  desc: string,
}
module ActionButtons = {
  @react.component
  let make = () => {
    // Actions
    <div className="flex flex-row gap-4 justify-end w-full">
      <Button
        text="Reset to Default"
        buttonType=Secondary
        buttonState=Normal
        buttonSize=Small
        customButtonStyle={`${body.md.semibold} py-4`}
      />
      <Button
        text="Apply Theme"
        buttonType=Primary
        buttonState=Normal
        buttonSize=Small
        customButtonStyle={`${body.md.semibold} py-4`}
      />
    </div>
  }
}

module RadioButtons = {
  @react.component
  let make = (~input: ReactFinalForm.fieldRenderPropsInput) => {
    open HeadlessUI
    let {userInfo: {orgId}} = React.useContext(UserInfoProvider.defaultContext)
    let entitites = [
      {
        label: "Organization",
        value: "organization",
        icon: <Icon name="organization-entity" size=20 />,
        desc: "Change themes to all merchants and profiles",
      },
      {
        label: "Merchant",
        value: "merchant",
        icon: <Icon name="merchant-entity" size=20 />,
        desc: "Change themes to specific merchant and its profiles",
      },
      {
        label: "Profile",
        value: "profile",
        icon: <Icon name="profile-entity" size=20 />,
        desc: "Change themes to specific profile only",
      },
    ]
    let value = input.value->LogicUtils.getStringFromJson("")
    <RadioGroup
      name="theme-create"
      value={value}
      onChange={val => input.onChange(val->Identity.stringToFormReactEvent)}>
      <div className="flex flex-col gap-4">
        <div
          className="flex flex-row gap-2 items-start flex-1 border border-yellow-500 bg-yellow-50 p-4 rounded-lg">
          <Icon name="nd-info-circle" size=20 />
          <span className={`text-nd_gray-600 ${body.md.regular}`}>
            {`You can only create theme for ${orgId} here. To create theme to another organisation, please switch the organisation.`->React.string}
          </span>
        </div>
        {entitites
        ->Array.map(option =>
          <RadioGroup.Option \"as"="div" key=option.value value=option.value>
            {checked =>
              <div
                className={"flex items-center justify-between border rounded-lg p-4 cursor-pointer transition " ++ (
                  checked["checked"] ? "border-primary" : "border-gray-200 bg-white"
                )}>
                <div className="flex items-center gap-4 w-full">
                  <div>
                    <div
                      className="w-8 h-8 border border-nd_br_gray-50 flex items-center justify-center rounded-md">
                      {option.icon}
                    </div>
                  </div>
                  <div className="flex flex-col flex-1">
                    <span className={`text-nd_gray-600 ${body.md.semibold}`}>
                      {option.label->React.string}
                    </span>
                    <span className={`text-nd_gray-400 ${body.md.medium}`}>
                      {option.desc->React.string}
                    </span>
                  </div>
                  <div>
                    <input type_="radio" checked={checked["checked"]} className="accent-primary" />
                  </div>
                </div>
              </div>}
          </RadioGroup.Option>
        )
        ->React.array}
      </div>
    </RadioGroup>
  }
}

module LineageSelectionModal = {
  @react.component
  let make = (~setShowModal, ~showModal) => {
    let onSubmit = (values, _form) => {
      switch values->JSON.Decode.object {
      | Some(dict) =>
        let entityType = dict->Dict.get("entity_type")
        Js.log2("Selected entity_type:", entityType)
      | None => Js.log("No values submitted")
      }
      // Always return a resolved promise
      Js.Promise.resolve(Js.Nullable.null)
    }
    let validate = (values: JSON.t) => {
      let errors = Dict.make()
      switch values->JSON.Decode.object {
      | Some(dict) =>
        switch dict->Dict.get("entity_type") {
        | Some(value) if value->JSON.Decode.string != None => ()
        | _ => Dict.set(errors, "entity_type", "Please select a theme scope"->JSON.Encode.string)
        }
      | None => Dict.set(errors, "entity_type", "Please select a theme scope"->JSON.Encode.string)
      }
      errors->JSON.Encode.object
    }
    let entityTypeField = FormRenderer.makeFieldInfo(
      ~label="",
      ~name="lineage.entity_type",
      ~customInput=(~input, ~placeholder as _) => <RadioButtons input />,
    )

    let modalBody = {
      <div>
        <Form key="theme-create" onSubmit validate>
          <div className="flex flex-col h-full w-full">
            <div className="py-2">
              <FormRenderer.DesktopRow>
                <FormRenderer.FieldRenderer
                  fieldWrapperClass="w-full"
                  field={entityTypeField}
                  showErrorOnChange=true
                  errorClass={ProdVerifyModalUtils.errorClass}
                  labelClass="!text-black font-medium !-ml-[0.5px]"
                />
              </FormRenderer.DesktopRow>
            </div>
            <hr className="mt-2" />
            <div className="flex justify-end gap-4  p-4">
              <Button
                text="Cancel"
                buttonType=Secondary
                onClick={_ => setShowModal(_ => false)}
                buttonSize=Small
              />
              <Button onClick={_ => ()} text="Next" buttonType={Primary} buttonSize=Small />
            </div>
          </div>
          <FormValuesSpy />
        </Form>
      </div>
    }

    <Modal
      showModal
      closeOnOutsideClick=true
      setShowModal
      modalHeading="Create Theme"
      modalHeadingClass={`${heading.sm.semibold}`}
      modalClass="w-1/3 m-auto"
      childClass="p-0"
      modalHeadingDescriptionElement={<div className={`${body.md.medium} text-nd_gray-400 mt-2`}>
        {"Select the level you want to create theme."->React.string}
      </div>}>
      modalBody
    </Modal>
  }
}
module CreateNewTheme = {
  @react.component
  let make = () => {
    let (showModal, setShowModal) = React.useState(_ => false)
    <div className="flex flex-col items-center gap-6">
      <div className="flex flex-col items-center gap-2">
        <div className={`${heading.sm.semibold} text-nd_gray-700 `}>
          {"No Themes Available"->React.string}
        </div>
        <div className={`${body.md.medium} text-nd_gray-400`}>
          {"Create your first theme, Make your dashboard for your personalized look"->React.string}
        </div>
      </div>
      <Button
        text="Create Theme"
        buttonType=Primary
        buttonState=Normal
        buttonSize=Small
        customButtonStyle={`${body.md.semibold} py-4`}
        onClick={_ => setShowModal(_ => true)}
      />
      <LineageSelectionModal setShowModal showModal />
    </div>
  }
}
@react.component
let make = () => {
  let (theme, setTheme) = React.useState(() => defaultTheme)
  let themeID = HyperSwitchEntryUtils.getThemeIdfromStore()
  let isThemePresent =
    themeID->Option.isSome && themeID->Option.getOr("")->LogicUtils.isNonEmptyString

  <div className="flex flex-col h-screen gap-8">
    <div className="flex flex-col flex-1 h-full">
      <PageUtils.PageHeading
        title="Theme Configuration"
        subTitle="Personalize your dashboard look with a live preview."
        customSubTitleStyle={`${body.lg.medium} text-nd_gray-400`}
      />
      <RenderIf condition={isThemePresent}>
        <div className="grid grid-cols-1 mt-4 lg:grid-cols-3 gap-8 ">
          // Configuration Panel
          <ThemeConfiguration theme setTheme />
          // Preview Section
          <div className="flex flex-col gap-8 w-full lg:col-span-2 ">
            <div className={`${body.lg.semibold} mt-2`}> {React.string("Preview")} </div>
            <div className="border h-3/4 rounded-xl p-8 px-10 flex items-center relative">
              <div
                className="absolute top-3 right-3 z-10 bg-white bg-opacity-80 rounded-full p-1 flex items-center justify-center shadow">
                <Icon name="eye" size=18 className="text-gray-500 opacity-70" />
              </div>
              // Mock Dashboard
              <ThemesMockDashboard theme />
            </div>
            <ActionButtons />
          </div>
        </div>
      </RenderIf>
      <RenderIf condition={!isThemePresent}>
        <div className="flex flex-1 h-full items-center justify-center overflow-hidden">
          <CreateNewTheme />
        </div>
      </RenderIf>
    </div>
  </div>
}
