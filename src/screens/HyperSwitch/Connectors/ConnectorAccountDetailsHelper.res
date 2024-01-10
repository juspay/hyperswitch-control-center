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
      ~options=options->Array.map(getCurrencyOption),
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
    let err = touched ? errorDict->Dict.get(fieldName) : None
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
    let keys = details->Dict.keysToArray->Array.filter(ele => !Array.includes(keysToIgnore, ele))
    keys
    ->Array.mapWithIndex((field, i) => {
      let label = details->getString(field, "")
      let formName = isLabelNested ? `${name}.${field}` : name
      <UIUtils.RenderIf condition={label->String.length > 0} key={i->string_of_int}>
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
    let p2RegularTextStyle = `${HSwitchUtils.getTextClass(
        ~textVariant=P2,
        ~paragraphTextVariant=Medium,
        (),
      )} text-grey-700 opacity-50`
    let (showWalletConfigurationModal, setShowWalletConfigurationModal) = React.useState(_ => false)
    let (country, setSelectedCountry) = React.useState(_ => "")
    let selectedCountry = country => {
      setShowWalletConfigurationModal(_ => !showWalletConfigurationModal)
      setSelectedCountry(_ => country)
    }
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Js.Nullable.return,
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
      ->Belt.Option.isNone
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
        headerTextClass="text-blue-800 font-bold text-xl"
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
    ~connector: connectorName,
    ~selectedConnector: integrationFields,
    ~connectorMetaDataFields,
    ~connectorWebHookDetails,
    ~isUpdateFlow=false,
    ~connectorLabelDetailField,
  ) => {
    open ConnectorUtils
    <div className="flex flex-col">
      {if connector === CASHTOCODE {
        <CashToCodeMethods connectorAccountFields connector selectedConnector />
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
                      ->Array.find((ele: HSwitchSettingTypes.profileEntity) =>
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
