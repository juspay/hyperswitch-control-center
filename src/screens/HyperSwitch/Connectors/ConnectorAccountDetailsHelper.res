let metaDataInputKeysToIgnore = ["google_pay", "apple_pay", "zen_apple_pay"]

let connectorsWithIntegrationSteps: array<ConnectorTypes.connectorName> = [
  ADYEN,
  CHECKOUT,
  STRIPE,
  PAYPAL,
]

let getCurrencyOption: CurrencyUtils.currencyCode => SelectBox.dropdownOption = currencyType => {
  open CurrencyUtils
  {
    label: currencyType->getCurrencyCodeStringFromVariant,
    value: currencyType->getCurrencyCodeStringFromVariant,
  }
}

let currencyField = (
  ~name,
  ~options=CurrencyUtils.currencyList,
  ~disableSelect=false,
  ~toolTipText="",
  (),
) =>
  FormRenderer.makeFieldInfo(
    ~label="Currency",
    ~isRequired=true,
    ~name,
    ~description=toolTipText,
    ~customInput=InputFields.selectInput(
      ~deselectDisable=true,
      ~disableSelect,
      ~customStyle="max-h-48",
      ~options=options->Js.Array2.map(getCurrencyOption),
      ~buttonText="Select Currency",
      (),
    ),
    (),
  )

let inputField = (
  ~name,
  ~field,
  ~label,
  ~connector,
  ~getPlaceholder,
  ~checkRequiredFields,
  ~disabled,
  ~description,
  ~toolTipPosition: ToolTip.toolTipPosition=ToolTip.Right,
  (),
) =>
  FormRenderer.makeFieldInfo(
    ~label,
    ~name,
    ~description,
    ~toolTipPosition,
    ~customInput=InputFields.textInput(~isDisabled=disabled, ()),
    ~placeholder=switch getPlaceholder {
    | Some(fun) => fun(connector, field, label)
    | None => `Enter ${label->LogicUtils.snakeToTitle}`
    },
    ~isRequired=switch checkRequiredFields {
    | Some(fun) => fun(connector, field)
    | None => true
    },
    (),
  )

module ErrorValidation = {
  @react.component
  let make = (~fieldName, ~validate) => {
    open LogicUtils
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Js.Nullable.return,
    )
    let appPrefix = LogicUtils.useUrlPrefix()
    let imageStyle = "w-4 h-4 my-auto border-gray-100"
    let errorDict = formState.values->validate->getDictFromJsonObject
    let {touched} = ReactFinalForm.useField(fieldName).meta
    let err = touched ? errorDict->Js.Dict.get(fieldName) : None
    <UIUtils.RenderIf condition={err->Belt.Option.isSome}>
      <div
        className={`flex flex-row items-center text-orange-950 dark:text-orange-400 pt-2 text-base font-medium text-start ml-1`}>
        <div className="flex mr-2">
          <img className=imageStyle src={`${appPrefix}/icons/warning.svg`} alt="warning" />
        </div>
        {React.string(err->Belt.Option.getWithDefault(""->Js.Json.string)->getStringFromJson(""))}
      </div>
    </UIUtils.RenderIf>
  }
}

module RenderConnectorInputFields = {
  open ConnectorTypes
  @react.component
  let make = (
    ~connector: connectorName,
    ~selectedConnector,
    ~details,
    ~name,
    ~keysToIgnore: array<string>=[],
    ~checkRequiredFields=?,
    ~getPlaceholder=?,
    ~isLabelNested=true,
    ~disabled=false,
    ~description="",
  ) => {
    let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
    open ConnectorUtils
    open LogicUtils
    let keys =
      details->Js.Dict.keys->Js.Array2.filter(ele => !Js.Array2.includes(keysToIgnore, ele))
    keys
    ->Array.mapWithIndex((field, i) => {
      let label = details->getString(field, "")
      let formName = isLabelNested ? `${name}.${field}` : name
      <UIUtils.RenderIf condition={label->Js.String2.length > 0} key={i->string_of_int}>
        <div key={label}>
          <FormRenderer.FieldRenderer
            labelClass="font-semibold !text-hyperswitch_black"
            field={switch (connector, field) {
            | (BRAINTREE, "merchant_config_currency") => currencyField(~name=formName, ())
            | _ =>
              inputField(
                ~name=formName,
                ~field,
                ~label,
                ~connector,
                ~checkRequiredFields,
                ~getPlaceholder,
                ~disabled,
                ~description,
                (),
              )
            }}
          />
          <ErrorValidation
            fieldName=formName
            validate={validate(
              ~selectedConnector,
              ~dict=details,
              ~fieldName=formName,
              ~isLiveMode={featureFlagDetails.isLiveMode},
            )}
          />
        </div>
      </UIUtils.RenderIf>
    })
    ->React.array
  }
}

module CurrencyAuthKey = {
  @react.component
  let make = (~dict, ~connector, ~selectedConnector: ConnectorTypes.integrationFields) => {
    open LogicUtils
    dict
    ->Js.Dict.keys
    ->Array.mapWithIndex((country, index) => {
      <Accordion
        key={index->string_of_int}
        initialExpandedArray={index == 0 ? [0] : []}
        accordion={[
          {
            title: country->snakeToTitle,
            renderContent: () => {
              <div className="grid gap-5">
                <RenderConnectorInputFields
                  details={dict->getDictfromDict(country)}
                  name={`connector_account_details.auth_key_map.${country}`}
                  connector
                  selectedConnector
                />
              </div>
            },
            renderContentOnTop: None,
          },
        ]}
        accordianTopContainerCss="border"
        accordianBottomContainerCss="p-5"
        contentExpandCss="px-10 pb-6 pt-3 !border-t-0"
        titleStyle="font-semibold text-bold text-md"
      />
    })
    ->React.array
  }
}

module ConnectorConfigurationFields = {
  open ConnectorTypes
  @react.component
  let make = (
    ~connectorAccountFields,
    ~connector: connectorName,
    ~selectedConnector: integrationFields,
    ~connectorMetaDataFields,
    ~connectorWebHookDetails,
    ~bodyType: string,
    ~isUpdateFlow=false,
    ~connectorLabelDetailField,
  ) => {
    open ConnectorUtils
    <div className="flex flex-col">
      {if bodyType->mapAuthType == #CurrencyAuthKey {
        let dict = connectorAccountFields->getAuthKeyMapFromConnectorAccountFields
        <CurrencyAuthKey dict connector selectedConnector />
      } else {
        <RenderConnectorInputFields
          details={connectorAccountFields}
          name={"connector_account_details"}
          getPlaceholder={getPlaceHolder}
          connector
          selectedConnector
        />
      }}
      <RenderConnectorInputFields
        details={connectorLabelDetailField}
        name={"connector_label"}
        keysToIgnore=metaDataInputKeysToIgnore
        checkRequiredFields={getMetaDataRequiredFields}
        connector
        selectedConnector
        isLabelNested=false
        disabled={isUpdateFlow ? true : false}
        description="This is an unique label you can generate and pass in order to identify this connector account on your Hyperswitch dashboard and reports. Eg: if your profile label is 'default', connector label can be 'stripe_default'"
      />
      <RenderConnectorInputFields
        details={connectorMetaDataFields}
        name={"metadata"}
        keysToIgnore=metaDataInputKeysToIgnore
        checkRequiredFields={getMetaDataRequiredFields}
        connector
        selectedConnector
      />
      <RenderConnectorInputFields
        details={connectorWebHookDetails}
        name={"connector_webhook_details"}
        checkRequiredFields={getWebHookRequiredFields}
        connector
        selectedConnector
      />
    </div>
  }
}

module BusinessProfileRender = {
  @react.component
  let make = (~isUpdateFlow: bool, ~selectedConnector) => {
    let {setDashboardPageState} = React.useContext(GlobalProvider.defaultContext)
    let businessProfiles = Recoil.useRecoilValueFromAtom(HyperswitchAtom.businessProfilesAtom)
    let arrayOfBusinessProfile = businessProfiles->MerchantAccountUtils.getArrayOfBusinessProfile
    let defaultBusinessProfile = businessProfiles->MerchantAccountUtils.getValueFromBusinessProfile
    let connectorLabelOnChange = ReactFinalForm.useField(`connector_label`).input.onChange

    let (showModalFromOtherScreen, setShowModalFromOtherScreen) = React.useState(_ => false)

    let hereTextStyle = isUpdateFlow
      ? "text-grey-700 opacity-50 cursor-not-allowed"
      : "text-blue-900  cursor-pointer"
    let _onClickHandler = _ => {
      if !isUpdateFlow {
        setShowModalFromOtherScreen(_ => true)
      }
      setDashboardPageState(_ => #HOME)
    }

    <>
      <FormRenderer.FieldRenderer
        labelClass="font-semibold !text-black"
        field={FormRenderer.makeFieldInfo(
          ~label="Profile",
          ~isRequired=true,
          ~name="profile_id",
          ~customInput=(~input, ~placeholder as _) =>
            InputFields.selectInput(
              ~input={
                ...input,
                onChange: {
                  ev => {
                    let profileName = (
                      arrayOfBusinessProfile
                      ->Js.Array2.find((ele: HSwitchSettingTypes.profileEntity) =>
                        ele.profile_id === ev->Identity.formReactEventToString
                      )
                      ->Belt.Option.getWithDefault(defaultBusinessProfile)
                    ).profile_name
                    connectorLabelOnChange(
                      `${selectedConnector}_${profileName}`->Identity.stringToFormReactEvent,
                    )
                    input.onChange(ev)
                  }
                },
              },
              ~deselectDisable=true,
              ~disableSelect=isUpdateFlow,
              ~customStyle="max-h-48",
              ~options={
                arrayOfBusinessProfile->MerchantAccountUtils.businessProfileNameDropDownOption
              },
              ~buttonText="Select Profile",
              ~placeholder="",
              (),
            ),
          (),
        )}
      />
      <UIUtils.RenderIf condition={!isUpdateFlow}>
        <div className="text-gray-400 text-sm mt-3">
          <span> {"Manage your list of profiles."->React.string} </span>
          <span
            className={`ml-1 ${hereTextStyle}`}
            onClick={_ => {
              setDashboardPageState(_ => #HOME)
              RescriptReactRouter.push("/business-profiles")
            }}>
            {React.string("here.")}
          </span>
        </div>
      </UIUtils.RenderIf>
      <BusinessProfile isFromSettings=false showModalFromOtherScreen setShowModalFromOtherScreen />
    </>
  }
}

module VerifyConnectorModal = {
  @react.component
  let make = (
    ~showVerifyModal,
    ~setShowVerifyModal,
    ~connector,
    ~verifyErrorMessage,
    ~suggestedActionExists,
    ~suggestedAction,
    ~setVerifyDone,
  ) => {
    <Modal
      showModal={showVerifyModal}
      setShowModal={setShowVerifyModal}
      modalClass="w-full md:w-5/12 mx-auto top-1/3 relative"
      childClass="p-0 m-0 -mt-8"
      customHeight="border-0 h-fit"
      showCloseIcon=false
      modalHeading=" "
      headingClass="h-2 bg-orange-960 rounded-t-xl"
      onCloseClickCustomFun={_ => {
        setVerifyDone(_ => NoAttempt)
        setShowVerifyModal(_ => false)
      }}>
      <div>
        <div className="flex flex-col mb-2 p-2 m-2">
          <div className="flex p-3">
            <img
              className="w-12 h-12 my-auto border-gray-100 w-fit mt-0"
              src={`/icons/warning.svg`}
              alt="warning"
            />
            <div className="text-jp-gray-900">
              <div
                className="font-semibold ml-4 text-xl px-2 dark:text-jp-gray-text_darktheme dark:text-opacity-75">
                {"Are you sure you want to proceed?"->React.string}
              </div>
              <div
                className="whitespace-pre-line break-all flex flex-col gap-1  p-2 ml-4 text-base dark:text-jp-gray-text_darktheme dark:text-opacity-50 font-medium leading-7 opacity-50">
                {`Received the following error from ${connector->LogicUtils.snakeToTitle}:`->React.string}
              </div>
              <div
                className="whitespace-pre-line break-all flex flex-col gap-1 p-4 ml-6 text-base dark:text-jp-gray-text_darktheme dark:text-opacity-50 bg-red-50 rounded-md font-semibold">
                {`${verifyErrorMessage->Belt.Option.getWithDefault("")}`->React.string}
              </div>
              <UIUtils.RenderIf condition={suggestedActionExists}>
                {suggestedAction}
              </UIUtils.RenderIf>
            </div>
          </div>
          <div className="flex flex-row justify-end gap-5 mt-4 mb-2 p-3">
            <FormRenderer.SubmitButton
              buttonType={Button.Secondary} loadingText="Processing..." text="Proceed Anyway"
            />
            <Button
              text="Cancel"
              onClick={_ => {
                setVerifyDone(_ => ConnectorTypes.NoAttempt)
                setShowVerifyModal(_ => false)
              }}
              buttonType={Primary}
              buttonSize={Small}
            />
          </div>
        </div>
      </div>
    </Modal>
  }
}
