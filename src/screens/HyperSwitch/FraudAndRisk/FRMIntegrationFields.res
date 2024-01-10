module AdvanceSettings = {
  @react.component
  let make = (~isUpdateFlow, ~frmName, ~renderCountrySelector) => {
    let (isFRMSettings, setIsFRMSettings) = React.useState(_ => isUpdateFlow)
    let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
    let form = ReactFinalForm.useForm()

    let inputLabel: ReactFinalForm.fieldRenderPropsInput = {
      name: `input`,
      onBlur: _ev => (),
      onChange: ev => {
        let value = ev->Identity.formReactEventToBool
        setIsFRMSettings(_ => value)
      },
      onFocus: _ev => (),
      value: {isFRMSettings->Js.Json.boolean},
      checked: true,
    }

    let businessProfileValue =
      Recoil.useRecoilValueFromAtom(
        HyperswitchAtom.businessProfilesAtom,
      )->MerchantAccountUtils.getValueFromBusinessProfile

    React.useEffect1(() => {
      if !isUpdateFlow {
        form.change("profile_id", businessProfileValue.profile_id->Js.Json.string)
      }
      None
    }, [businessProfileValue.profile_id])

    <UIUtils.RenderIf condition={featureFlagDetails.businessProfile}>
      <div className="flex gap-2 items-center p-2">
        <BoolInput input={inputLabel} isDisabled={isUpdateFlow} boolCustomClass="rounded-full" />
        <p className="font-semibold !text-black opacity-50 ">
          {"Show advanced settings"->React.string}
        </p>
      </div>
      <UIUtils.RenderIf condition={renderCountrySelector && isFRMSettings}>
        <ConnectorAccountDetailsHelper.BusinessProfileRender
          isUpdateFlow selectedConnector={frmName}
        />
      </UIUtils.RenderIf>
    </UIUtils.RenderIf>
  }
}

module IntegrationFieldsForm = {
  open FRMTypes
  open FRMUtils
  @react.component
  let make = (
    ~selectedFRMInfo,
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
      ~fields: array<frmIntegrationField>,
      ~errors,
    ) => {
      fields->Array.forEach(field => {
        let key = field.name
        let value =
          valuesFlattenJson
          ->Dict.get(key)
          ->Belt.Option.getWithDefault(""->Js.Json.string)
          ->LogicUtils.getStringFromJson("")

        if field.isRequired && value->String.length === 0 {
          Dict.set(errors, key, `Please enter ${field.label}`->Js.Json.string)
        }
      })
    }

    let validateCountryCurrency = (valuesFlattenJson, ~errors) => {
      let profileId = valuesFlattenJson->LogicUtils.getString("profile_id", "")
      if profileId->String.length <= 0 {
        Dict.set(errors, "Profile Id", `Please select your business profile`->Js.Json.string)
      }
    }

    let validate = values => {
      let errors = Dict.make()
      let valuesFlattenJson = values->JsonFlattenUtils.flattenObject(true)
      //checking for required fields
      valuesFlattenJson->validateRequiredFields(~fields=selectedFRMInfo.connectorFields, ~errors)

      if renderCountrySelector {
        valuesFlattenJson->validateCountryCurrency(~errors)
      }

      errors->Js.Json.object_
    }

    let validateMandatoryField = values => {
      let errors = Dict.make()
      let valuesFlattenJson = values->JsonFlattenUtils.flattenObject(true)
      //checking for required fields
      valuesFlattenJson->validateRequiredFields(~fields=selectedFRMInfo.connectorFields, ~errors)

      if renderCountrySelector {
        valuesFlattenJson->validateCountryCurrency(~errors)
      }

      errors->Js.Json.object_
    }

    <Form initialValues onSubmit validate={validateMandatoryField}>
      <div className="flex">
        <div className="grid grid-cols-2 flex-1 gap-5">
          <div className="flex flex-col gap-3">
            <AdvanceSettings isUpdateFlow frmName renderCountrySelector />
            {selectedFRMInfo.connectorFields
            ->Array.mapWithIndex((field, index) => {
              let parse = field.encodeToBase64 ? base64Parse : leadingSpaceStrParser
              let format = field.encodeToBase64 ? Some(base64Format) : None

              <div key={index->Belt.Int.toString}>
                <FormRenderer.FieldRenderer
                  labelClass="font-semibold !text-black"
                  field={FormRenderer.makeFieldInfo(
                    ~label=field.label,
                    ~name={field.name},
                    ~placeholder=field.placeholder,
                    ~customInput=field.inputType,
                    ~description=field.description->Belt.Option.getWithDefault(""),
                    ~isRequired=true,
                    ~parse,
                    ~format?,
                    (),
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
      <FormValuesSpy />
    </Form>
  }
}

@react.component
let make = (
  ~setCurrentStep,
  ~selectedFRMInfo,
  ~retrivedValues=None,
  ~setInitialValues,
  ~isUpdateFlow,
) => {
  open FRMUtils
  open FRMInfo
  open FRMTypes
  open APIUtils
  open Promise
  let showToast = ToastState.useShowToast()
  let fetchApi = useUpdateMethod()
  let frmName = UrlUtils.useGetFilterDictFromUrl("")->LogicUtils.getString("name", "")
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let (pageState, setPageState) = React.useState(_ => PageLoaderWrapper.Success)

  let initialValues = React.useMemo1(() => {
    open LogicUtils
    switch retrivedValues {
    | Some(json) => {
        let initialValuesObj = json->getDictFromJsonObject
        let frmAccountDetailsObj =
          initialValuesObj->getObj("connector_account_details", Dict.make())

        frmAccountDetailsObj->Dict.set(
          "auth_type",
          selectedFRMInfo.name->getFRMAuthType->Js.Json.string,
        )

        initialValuesObj->Dict.set(
          "connector_account_details",
          frmAccountDetailsObj->Js.Json.object_,
        )

        initialValuesObj->Js.Json.object_
      }

    | None =>
      generateInitialValuesDict(~selectedFRMInfo, ~isLiveMode={featureFlagDetails.isLiveMode}, ())
    }
  }, [retrivedValues])

  let frmID =
    retrivedValues
    ->Belt.Option.getWithDefault(Dict.make()->Js.Json.object_)
    ->LogicUtils.getDictFromJsonObject
    ->LogicUtils.getString("merchant_connector_id", "")

  let submitText = if !isUpdateFlow {
    "FRM Player Created Successfully!"
  } else {
    "Details Updated!"
  }

  let updateDetails = useUpdateMethod()

  let frmUrl = if frmID->String.length <= 0 {
    getURL(~entityName=FRAUD_RISK_MANAGEMENT, ~methodType=Post, ())
  } else {
    getURL(~entityName=FRAUD_RISK_MANAGEMENT, ~methodType=Post, ~id=Some(frmID), ())
  }

  let updateMerchantDetails = async () => {
    let merchantId = HSLocalStorage.getFromMerchantDetails("merchant_id")
    let info =
      [("data", "signifyd"->Js.Json.string), ("type", "single"->Js.Json.string)]->Dict.fromArray
    let body =
      [
        ("frm_routing_algorithm", info->Js.Json.object_),
        ("merchant_id", merchantId->Js.Json.string),
      ]
      ->Dict.fromArray
      ->Js.Json.object_
    let url = getURL(~entityName=MERCHANT_ACCOUNT, ~methodType=Post, ())
    try {
      let _ = await updateDetails(url, body, Post)
    } catch {
    | _ => ()
    }
    Js.Nullable.null
  }

  let setFRMValues = async body => {
    fetchApi(frmUrl, body, Fetch.Post)
    ->thenResolve(res => {
      setCurrentStep(prev => prev->getNextStep)
      let _ = updateMerchantDetails()
      setInitialValues(_ => res)
      showToast(~message=submitText, ~toastType=ToastSuccess, ())
      setPageState(_ => Success)
    })
    ->catch(_ => {
      setPageState(_ => Error(""))
      resolve()
    })
    ->ignore
    Js.Nullable.null
  }

  let onSubmit = (values, _) => {
    setPageState(_ => Loading)
    let body = isUpdateFlow ? values->ignoreFields : values
    setFRMValues(body)->ignore
    Js.Nullable.null->resolve
  }

  <IntegrationFieldsForm
    selectedFRMInfo initialValues onSubmit pageState isUpdateFlow setCurrentStep frmName
  />
}
