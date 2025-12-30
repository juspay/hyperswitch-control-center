module AdvanceSettings = {
  @react.component
  let make = (~isUpdateFlow, ~frmName, ~renderCountrySelector) => {
    let (isFRMSettings, setIsFRMSettings) = React.useState(_ => isUpdateFlow)
    let form = ReactFinalForm.useForm()
    let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonDetails()

    let inputLabel: ReactFinalForm.fieldRenderPropsInput = {
      name: `input`,
      onBlur: _ => (),
      onChange: ev => {
        let value = ev->Identity.formReactEventToBool
        setIsFRMSettings(_ => value)
      },
      onFocus: _ => (),
      value: {isFRMSettings->JSON.Encode.bool},
      checked: true,
    }

    React.useEffect(() => {
      if !isUpdateFlow {
        form.change("profile_id", profileId->JSON.Encode.string)
      }
      None
    }, [profileId])
    <>
      <div className="flex gap-2 items-center p-2">
        <BoolInput input={inputLabel} isDisabled={isUpdateFlow} boolCustomClass="rounded-full" />
        <p className="font-semibold !text-black opacity-50 ">
          {"Show advanced settings"->React.string}
        </p>
      </div>
      <RenderIf condition={renderCountrySelector && isFRMSettings}>
        <ConnectorAccountDetailsHelper.BusinessProfileRender
          isUpdateFlow selectedConnector={frmName}
        />
      </RenderIf>
    </>
  }
}

module IntegrationFieldsForm = {
  open FRMUtils
  @react.component
  let make = (
    ~selectedFRMName,
    ~initialValues,
    ~onSubmit,
    ~renderCountrySelector=true,
    ~pageState=PageLoaderWrapper.Success,
    ~setCurrentStep,
    ~frmName,
    ~isUpdateFlow,
  ) => {
    let buttonText = switch pageState {
    | Error("") => "Try Again"
    | Loading => "Loading..."
    | _ => isUpdateFlow ? "Update" : "Connect and Finish"
    }

    let validateRequiredFields = (
      valuesFlattenJson,
      ~fields: array<ConnectorTypes.connectorIntegrationField>,
      ~errors,
    ) => {
      fields->Array.forEach(field => {
        let key = field.name
        let value =
          valuesFlattenJson
          ->Dict.get(key)
          ->Option.getOr(""->JSON.Encode.string)
          ->LogicUtils.getStringFromJson("")

        if field.isRequired->Option.getOr(true) && value->String.length === 0 {
          Dict.set(errors, key, `Please enter ${field.label->Option.getOr("")}`->JSON.Encode.string)
        }
      })
    }

    let validateCountryCurrency = (valuesFlattenJson, ~errors) => {
      let profileId = valuesFlattenJson->LogicUtils.getString("profile_id", "")
      if profileId->String.length <= 0 {
        Dict.set(errors, "Profile Id", `Please select your business profile`->JSON.Encode.string)
      }
    }

    let selectedFRMInfo = selectedFRMName->ConnectorUtils.getConnectorInfo

    let validate = values => {
      let errors = Dict.make()
      let valuesFlattenJson = values->JsonFlattenUtils.flattenObject(true)
      //checking for required fields
      valuesFlattenJson->validateRequiredFields(
        ~fields=selectedFRMInfo.validate->Option.getOr([]),
        ~errors,
      )

      if renderCountrySelector {
        valuesFlattenJson->validateCountryCurrency(~errors)
      }

      errors->JSON.Encode.object
    }

    let validateMandatoryField = values => {
      let errors = Dict.make()
      let valuesFlattenJson = values->JsonFlattenUtils.flattenObject(true)
      //checking for required fields
      valuesFlattenJson->validateRequiredFields(
        ~fields=selectedFRMInfo.validate->Option.getOr([]),
        ~errors,
      )

      if renderCountrySelector {
        valuesFlattenJson->validateCountryCurrency(~errors)
      }

      errors->JSON.Encode.object
    }

    <Form initialValues onSubmit validate={validateMandatoryField}>
      <div className="flex">
        <div className="grid grid-cols-2 flex-1 gap-5">
          <div className="flex flex-col gap-3">
            <AdvanceSettings isUpdateFlow frmName renderCountrySelector />
            {selectedFRMInfo.validate
            ->Option.getOr([])
            ->Array.mapWithIndex((field, index) => {
              let parse =
                field.encodeToBase64->Option.getOr(false) ? base64Parse : leadingSpaceStrParser
              let format = field.encodeToBase64->Option.getOr(false) ? Some(base64Format) : None
              <div key={index->Int.toString}>
                <FormRenderer.FieldRenderer
                  labelClass="font-semibold !text-black"
                  field={FormRenderer.makeFieldInfo(
                    ~label=field.label->Option.getOr(""),
                    ~name={field.name},
                    ~placeholder=field.placeholder->Option.getOr(""),
                    ~description=field.description->Option.getOr(""),
                    ~isRequired=true,
                    ~parse,
                    ~format?,
                  )}
                />
                <ConnectorAccountDetailsHelper.ErrorValidation fieldName={field.name} validate />
              </div>
            })
            ->React.array}
          </div>
          <div className="flex flex-row mt-6 md:mt-0 md:justify-self-end h-min">
            {if pageState === Loading {
              <Button buttonType={Primary} buttonState={Loading} text=buttonText />
            } else {
              <div className="flex gap-5">
                <Button
                  buttonType={Secondary}
                  text="Back"
                  onClick={_ => setCurrentStep(prev => prev->FRMInfo.getPrevStep)}
                />
                <FormRenderer.SubmitButton loadingText="Processing..." text=buttonText />
              </div>
            }}
          </div>
        </div>
      </div>
    </Form>
  }
}

@react.component
let make = (
  ~setCurrentStep,
  ~selectedFRMName,
  ~retrivedValues=None,
  ~setInitialValues,
  ~isUpdateFlow,
) => {
  open FRMUtils
  open FRMInfo
  open APIUtils
  open Promise
  open CommonAuthHooks

  let getURL = useGetURL()
  let showToast = ToastState.useShowToast()
  let frmName = UrlUtils.useGetFilterDictFromUrl("")->LogicUtils.getString("name", "")
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let fetchConnectorListResponse = ConnectorListHook.useFetchConnectorList()

  let (pageState, setPageState) = React.useState(_ => PageLoaderWrapper.Success)

  let {merchantId} = useCommonAuthInfo()->Option.getOr(defaultAuthInfo)

  let initialValues = React.useMemo(() => {
    open LogicUtils
    switch retrivedValues {
    | Some(json) => {
        let initialValuesObj = json->getDictFromJsonObject
        let frmAccountDetailsObj =
          initialValuesObj->getObj("connector_account_details", Dict.make())

        frmAccountDetailsObj->Dict.set(
          "auth_type",
          selectedFRMName->getFRMAuthType->JSON.Encode.string,
        )

        initialValuesObj->Dict.set(
          "connector_account_details",
          frmAccountDetailsObj->JSON.Encode.object,
        )

        initialValuesObj->JSON.Encode.object
      }

    | None =>
      generateInitialValuesDict(~selectedFRMName, ~isLiveMode={featureFlagDetails.isLiveMode})
    }
  }, [retrivedValues])

  let frmID =
    retrivedValues
    ->Option.getOr(Dict.make()->JSON.Encode.object)
    ->LogicUtils.getDictFromJsonObject
    ->LogicUtils.getString("merchant_connector_id", "")

  let submitText = if !isUpdateFlow {
    "FRM Player Created Successfully!"
  } else {
    "Details Updated!"
  }

  let updateDetails = useUpdateMethod()

  let frmUrl = if frmID->String.length <= 0 {
    getURL(~entityName=V1(FRAUD_RISK_MANAGEMENT), ~methodType=Post)
  } else {
    getURL(~entityName=V1(FRAUD_RISK_MANAGEMENT), ~methodType=Post, ~id=Some(frmID))
  }

  let updateMerchantDetails = async () => {
    let info =
      [
        ("data", "signifyd"->JSON.Encode.string),
        ("type", "single"->JSON.Encode.string),
      ]->Dict.fromArray
    let body =
      [
        ("frm_routing_algorithm", info->JSON.Encode.object),
        ("merchant_id", merchantId->JSON.Encode.string),
      ]
      ->Dict.fromArray
      ->JSON.Encode.object
    let url = getURL(~entityName=V1(MERCHANT_ACCOUNT), ~methodType=Post)
    try {
      let _ = await updateDetails(url, body, Post)
    } catch {
    | _ => ()
    }
    Nullable.null
  }

  let setFRMValues = async body => {
    open LogicUtils
    try {
      let response = await updateDetails(frmUrl, body, Post)
      let _ = updateMerchantDetails()
      let _ = await fetchConnectorListResponse()
      setInitialValues(_ => response)
      setCurrentStep(prev => prev->getNextStep)
      showToast(~message=submitText, ~toastType=ToastSuccess)
      setPageState(_ => Success)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Something went wrong")
        let errorCode = err->safeParse->getDictFromJsonObject->getString("code", "")
        let errorMessage = err->safeParse->getDictFromJsonObject->getString("message", "")

        if errorCode === "HE_01" {
          showToast(~message="Connector label already exist!", ~toastType=ToastError)
          setPageState(_ => Error(""))
        } else {
          showToast(~message=errorMessage, ~toastType=ToastError)
          setPageState(_ => Error(""))
        }
      }
    }
    Nullable.null
  }

  let onSubmit = (values, _) => {
    mixpanelEvent(~eventName="frm_step2")
    setPageState(_ => Loading)
    let body = isUpdateFlow ? values->ignoreFields : values
    setFRMValues(body)->ignore
    Nullable.null->resolve
  }

  <IntegrationFieldsForm
    selectedFRMName initialValues onSubmit pageState isUpdateFlow setCurrentStep frmName
  />
}
