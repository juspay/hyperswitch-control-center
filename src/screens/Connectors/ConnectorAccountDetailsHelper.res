let metaDataInputKeysToIgnore = ["google_pay", "apple_pay", "zen_apple_pay", "paypal_sdk"]

let connectorsWithIntegrationSteps: array<ConnectorTypes.connectorTypes> = [
  Processors(ADYEN),
  Processors(CHECKOUT),
  Processors(STRIPE),
  Processors(PAYPAL),
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
      ~options=options->Array.map(getCurrencyOption),
      ~buttonText="Select Currency",
      (),
    ),
    (),
  )

let dropDownfield = (
  ~name,
  ~label,
  ~buttonText="Select",
  ~disableSelect=false,
  ~toolTipText="",
  ~options=[],
  (),
) => {
  FormRenderer.makeFieldInfo(
    ~label,
    ~isRequired=true,
    ~name,
    ~description=toolTipText,
    ~customInput=InputFields.selectInput(
      ~deselectDisable=true,
      ~disableSelect,
      ~customStyle="max-h-48",
      ~options=options->Array.map((item): SelectBox.dropdownOption => {
        {
          label: item,
          value: item,
        }
      }),
      ~buttonText,
      (),
    ),
    (),
  )
}

let toggleField = (~name) => {
  FormRenderer.makeFieldInfo(
    ~name,
    ~label="Pull Mechanism Enabled",
    ~customInput=InputFields.boolInput(~isDisabled=false, ~boolCustomClass="rounded-lg", ()),
    (),
  )
}

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
      ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
    )
    let appPrefix = LogicUtils.useUrlPrefix()
    let imageStyle = "w-4 h-4 my-auto border-gray-100"
    let errorDict = formState.values->validate->getDictFromJsonObject
    let {touched} = ReactFinalForm.useField(fieldName).meta
    let err = touched ? errorDict->Dict.get(fieldName) : None
    <UIUtils.RenderIf condition={err->Option.isSome}>
      <div
        className={`flex flex-row items-center text-orange-950 dark:text-orange-400 pt-2 text-base font-medium text-start ml-1`}>
        <div className="flex mr-2">
          <img className=imageStyle src={`${appPrefix}/icons/warning.svg`} alt="warning" />
        </div>
        {React.string(err->Option.getOr(""->JSON.Encode.string)->getStringFromJson(""))}
      </div>
    </UIUtils.RenderIf>
  }
}

module RenderConnectorInputFields = {
  open ConnectorTypes
  @react.component
  let make = (
    ~connector: connectorTypes,
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
    let keys = details->Dict.keysToArray->Array.filter(ele => !Array.includes(keysToIgnore, ele))

    keys
    ->Array.mapWithIndex((field, i) => {
      let label = switch field {
      | "pull_mechanism_for_external_3ds_enabled" => "Pull Mechanism Enabled"
      | "klarna_region" => "Region of your Klarna Merchant Account"
      | _ => details->getString(field, "")
      }

      let formName = isLabelNested ? `${name}.${field}` : name
      <UIUtils.RenderIf condition={label->isNonEmptyString} key={i->Int.toString}>
        <AddDataAttributes attributes=[("data-testid", label->titleToSnake->String.toLowerCase)]>
          <div key={label}>
            <FormRenderer.FieldRenderer
              labelClass="font-semibold !text-hyperswitch_black"
              field={switch (connector, field) {
              | (Processors(BRAINTREE), "merchant_config_currency") =>
                currencyField(~name=formName, ())

              | (ThreeDsAuthenticator(THREEDSECUREIO), "pull_mechanism_for_external_3ds_enabled") =>
                toggleField(~name=formName)
              | (Processors(KLARNA), "klarna_region") =>
                dropDownfield(
                  ~name=formName,
                  ~label,
                  ~buttonText="Select Region",
                  ~options=details->getStrArrayFromDict(field, []),
                  (),
                )
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
        </AddDataAttributes>
      </UIUtils.RenderIf>
    })
    ->React.array
  }
}

module CashToCodeSelectBox = {
  open ConnectorTypes
  @react.component
  let make = (
    ~opts: array<string>,
    ~dict,
    ~selectedCashToCodeMthd: cashToCodeMthd,
    ~connector,
    ~selectedConnector,
  ) => {
    open LogicUtils
    let {globalUIConfig: {font: {textColor}}} = React.useContext(ConfigContext.configContext)
    let p2RegularTextStyle = `${HSwitchUtils.getTextClass((P2, Medium))} text-grey-700 opacity-50`
    let (showWalletConfigurationModal, setShowWalletConfigurationModal) = React.useState(_ => false)
    let (country, setSelectedCountry) = React.useState(_ => "")
    let selectedCountry = country => {
      setShowWalletConfigurationModal(_ => !showWalletConfigurationModal)
      setSelectedCountry(_ => country)
    }
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
    )

    let isSelected = (country): bool => {
      let formValues =
        formState.values
        ->getDictFromJsonObject
        ->getDictfromDict("connector_account_details")
        ->getDictfromDict("auth_key_map")
        ->getDictfromDict(country)

      let wasmValues =
        dict
        ->getDictfromDict(country)
        ->getDictfromDict((selectedCashToCodeMthd: cashToCodeMthd :> string)->String.toLowerCase)
        ->Dict.keysToArray

      wasmValues
      ->Array.find(ele => formValues->getString(ele, "")->String.length <= 0)
      ->Option.isNone
    }

    <div>
      {opts
      ->Array.map(country => {
        <div className="flex items-center gap-2 break-words p-2">
          <div onClick={_e => selectedCountry(country)}>
            <CheckBoxIcon isSelected={country->isSelected} />
          </div>
          <p className=p2RegularTextStyle> {React.string(country->snakeToTitle)} </p>
        </div>
      })
      ->React.array}
      <Modal
        modalHeading={`Additional Details to enable`}
        headerTextClass={`${textColor.primaryNormal} font-bold text-xl`}
        showModal={showWalletConfigurationModal}
        setShowModal={setShowWalletConfigurationModal}
        paddingClass=""
        revealFrom=Reveal.Right
        modalClass="w-full p-4 md:w-1/3 !h-full overflow-y-scroll !overflow-x-hidden rounded-none text-jp-gray-900"
        childClass={""}>
        <div>
          <RenderConnectorInputFields
            details={dict
            ->getDictfromDict(country)
            ->getDictfromDict(
              (selectedCashToCodeMthd: cashToCodeMthd :> string)->String.toLowerCase,
            )}
            name={`connector_account_details.auth_key_map.${country}`}
            connector
            selectedConnector
          />
          <div className="flex flex-col justify-center mt-4">
            <Button
              text={"Proceed"}
              buttonType=Primary
              onClick={_ => setShowWalletConfigurationModal(_ => false)}
            />
          </div>
        </div>
      </Modal>
    </div>
  }
}

module CashToCodeMethods = {
  open ConnectorTypes
  @react.component
  let make = (~connectorAccountFields, ~selectedConnector, ~connector) => {
    open ConnectorUtils
    let dict = connectorAccountFields->getAuthKeyMapFromConnectorAccountFields
    let (selectedCashToCodeMthd, setCashToCodeMthd) = React.useState(_ => #Classic)
    let tabs = [#Classic, #Evoucher]

    let tabList: array<Tabs.tab> = tabs->Array.map(tab => {
      let tab: Tabs.tab = {
        title: (tab: cashToCodeMthd :> string),
        renderContent: () =>
          <CashToCodeSelectBox
            opts={dict->Dict.keysToArray}
            dict={dict}
            selectedCashToCodeMthd
            connector
            selectedConnector
          />,
      }
      tab
    })
    <Tabs
      tabs=tabList
      disableIndicationArrow=true
      showBorder=false
      includeMargin=false
      lightThemeColor="black"
      defaultClasses="font-ibm-plex w-max flex flex-auto flex-row items-center justify-center px-6 font-semibold text-body"
      onTitleClick={tabIndex => {
        setCashToCodeMthd(_ => tabs->LogicUtils.getValueFromArray(tabIndex, #Classic))
      }}
    />
  }
}

module ConnectorConfigurationFields = {
  open ConnectorTypes
  @react.component
  let make = (
    ~connectorAccountFields,
    ~connector: connectorTypes,
    ~selectedConnector: integrationFields,
    ~connectorMetaDataFields,
    ~connectorWebHookDetails,
    ~isUpdateFlow=false,
    ~connectorLabelDetailField,
  ) => {
    <div className="flex flex-col">
      {switch connector {
      | Processors(CASHTOCODE) =>
        <CashToCodeMethods connectorAccountFields connector selectedConnector />

      | _ =>
        <RenderConnectorInputFields
          details={connectorAccountFields}
          name={"connector_account_details"}
          getPlaceholder={ConnectorUtils.getPlaceHolder}
          connector
          selectedConnector
        />
      }}
      <RenderConnectorInputFields
        details={connectorLabelDetailField}
        name={"connector_label"}
        keysToIgnore=metaDataInputKeysToIgnore
        checkRequiredFields={ConnectorUtils.getMetaDataRequiredFields}
        connector
        selectedConnector
        isLabelNested=false
        description="This is an unique label you can generate and pass in order to identify this connector account on your Hyperswitch dashboard and reports. Eg: if your profile label is 'default', connector label can be 'stripe_default'"
      />
      <RenderConnectorInputFields
        details={connectorMetaDataFields}
        name={"metadata"}
        keysToIgnore=metaDataInputKeysToIgnore
        checkRequiredFields={ConnectorUtils.getMetaDataRequiredFields}
        connector
        selectedConnector
      />
      <RenderConnectorInputFields
        details={connectorWebHookDetails}
        name={"connector_webhook_details"}
        checkRequiredFields={ConnectorUtils.getWebHookRequiredFields}
        connector
        selectedConnector
      />
    </div>
  }
}

module BusinessProfileRender = {
  @react.component
  let make = (~isUpdateFlow: bool, ~selectedConnector) => {
    let {globalUIConfig: {font: {textColor}}} = React.useContext(ConfigContext.configContext)
    let {setDashboardPageState} = React.useContext(GlobalProvider.defaultContext)
    let businessProfiles = Recoil.useRecoilValueFromAtom(HyperswitchAtom.businessProfilesAtom)
    let defaultBusinessProfile = businessProfiles->MerchantAccountUtils.getValueFromBusinessProfile
    let connectorLabelOnChange = ReactFinalForm.useField(`connector_label`).input.onChange

    let (showModalFromOtherScreen, setShowModalFromOtherScreen) = React.useState(_ => false)

    let hereTextStyle = isUpdateFlow
      ? "text-grey-700 opacity-50 cursor-not-allowed"
      : `${textColor.primaryNormal}  cursor-pointer`

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
                      businessProfiles
                      ->Array.find((ele: HSwitchSettingTypes.profileEntity) =>
                        ele.profile_id === ev->Identity.formReactEventToString
                      )
                      ->Option.getOr(defaultBusinessProfile)
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
                businessProfiles->MerchantAccountUtils.businessProfileNameDropDownOption
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
              RescriptReactRouter.push(
                HSwitchGlobalVars.appendDashboardPath(~url="/business-profiles"),
              )
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
              className="h-12 my-auto border-gray-100 w-fit mt-0"
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
                className="whitespace-pre-line break-all flex flex-col gap-1 p-4 ml-6 text-base dark:text-jp-gray-text_darktheme dark:text-opacity-50 bg-red-100 rounded-md font-semibold">
                {`${verifyErrorMessage->Option.getOr("")}`->React.string}
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

// Wraps the component with Connector Icon + ConnectorName + Integration Steps Modal
module ConnectorHeaderWrapper = {
  @react.component
  let make = (
    ~children,
    ~headerButton,
    ~connector,
    ~handleShowModal=?,
    ~conditionForIntegrationSteps=true,
    ~connectorType=ConnectorTypes.Processor,
  ) => {
    open ConnectorUtils
    let {globalUIConfig: {font: {textColor}}} = React.useContext(ConfigContext.configContext)
    let connectorNameFromType = connector->getConnectorNameTypeFromString()
    let setShowModalFunction = switch handleShowModal {
    | Some(func) => func
    | _ => _ => ()
    }
    <>
      <div className="flex items-center justify-between border-b p-2 md:px-10 md:py-6">
        <div className="flex gap-2 items-center">
          <GatewayIcon gateway={connector->String.toUpperCase} />
          <h2 className="text-xl font-semibold">
            {connector->getDisplayNameForConnector(~connectorType)->React.string}
          </h2>
        </div>
        <div className="flex flex-row mt-6 md:mt-0 md:justify-self-end h-min">
          <UIUtils.RenderIf
            condition={connectorsWithIntegrationSteps->Array.includes(connectorNameFromType) &&
              conditionForIntegrationSteps}>
            <a
              className={`cursor-pointer px-4 py-3 flex text-sm ${textColor.primaryNormal} items-center mx-4`}
              target="_blank"
              onClick={_ => setShowModalFunction()}>
              {React.string("View integration steps")}
              <Icon name="external-link-alt" size=14 className="ml-2" />
            </a>
          </UIUtils.RenderIf>
          {headerButton}
        </div>
      </div>
      <UIUtils.RenderIf
        condition={switch connectorNameFromType {
        | Processors(BRAINTREE) => true
        | _ => false
        }}>
        <div className="flex flex-col gap-2 p-2 md:p-10">
          <h1
            className="flex items-center mx-12 leading-6 text-orange-950 bg-orange-100 border w-fit p-2 rounded-md ">
            <div className="flex items-center text-orange-950 font-bold text-fs-14 mx-2">
              <Icon name="hswitch-warning" size=18 className="mr-2" />
              {"Disclaimer:"->React.string}
            </div>
            <div>
              {"Please ensure the payment currency matches the Braintree-configured currency for the given Merchant Account ID."->React.string}
            </div>
          </h1>
        </div>
      </UIUtils.RenderIf>
      {children}
    </>
  }
}
