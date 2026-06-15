@react.component
let make = (
  ~routingRuleId,
  ~isActive,
  ~connectorList: array<ConnectorTypes.connectorPayloadCommonType>,
  ~urlEntityName,
  ~baseUrlForRedirection,
) => {
  open APIUtils
  open AuthRateRoutingUtils
  open LogicUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()
  let businessProfileValues =
    HyperswitchAtom.businessProfileFromIdAtomInterface->Recoil.useRecoilValueFromAtom
  let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  let (profile, setProfile) = React.useState(_ => profileId)
  let (initialValues, setInitialValues) = React.useState(_ => initialValues)
  let (pageState, setPageState) = React.useState(() => RoutingTypes.Create)
  let (showModal, setShowModal) = React.useState(_ => false)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (disableFields, setDisableFields) = React.useState(_ => false)
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()

  let getVolumeSplit = async () => {
    try {
      let url = getURL(~entityName=V1(GET_VOLUME_SPLIT), ~methodType=Get)
      let response = await fetchDetails(url)
      response
    } catch {
    | _ => {
        showToast(~message="Failed to get volume split data!", ~toastType=ToastError)
        Exn.raiseError("Failed to get volume split data")
      }
    }
  }

  let activeRoutingDetails = async () => {
    try {
      let url = getURL(~entityName=urlEntityName, ~methodType=Get, ~id=routingRuleId)
      let response = await fetchDetails(url)
      let splitPercentage = await getVolumeSplit()
      let splitPercentage = splitPercentage->getDictFromJsonObject->getInt("split", 100)

      let values = response->formFieldsMapper(splitPercentage)->Identity.genericTypeToJson
      setInitialValues(_ => values)
    } catch {
    | _ => showToast(~message="Failed to fetch details!", ~toastType=ToastError)
    }
  }

  let fetchActiveRoutingDetails = async () => {
    try {
      setScreenState(_ => Loading)
      switch routingRuleId {
      | Some(_id) => {
          await activeRoutingDetails()
          setPageState(_ => Preview)
          setDisableFields(_ => true)
        }
      | None => setPageState(_ => Create)
      }
      setScreenState(_ => Success)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Something went wrong")
        setScreenState(_ => Error(err))
      }
    }
  }

  React.useEffect(() => {
    fetchActiveRoutingDetails()->ignore
    None
  }, [routingRuleId])

  let createAuthRateRouting = async (~values=JSON.Encode.null, ~isActivate=true) => {
    try {
      let dict = values->getDictFromJsonObject

      let decisionEngineConfigDict = Dict.make()
      if isActivate {
        let decisionEngineConfigValues =
          dict->getDictfromDict("decision_engine_configs")->JSON.Encode.object
        decisionEngineConfigDict->Dict.set("decision_engine_configs", decisionEngineConfigValues)
      }

      let queryParameters = `enable=${isActivate ? "dynamic_connector_selection" : "none"}`
      let url = getURL(
        ~entityName=V1(CREATE_AUTH_RATE_ROUTING),
        ~methodType=Post,
        ~queryParameters=Some(queryParameters),
      )
      let response = await updateDetails(url, decisionEngineConfigDict->JSON.Encode.object, Post)
      if !isActivate {
        RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url=baseUrlForRedirection))
      }
      response
    } catch {
    | Exn.Error(e) =>
      switch Exn.message(e) {
      | Some(message) =>
        if message->String.includes("IR_16") {
          let message = isActivate ? "Algorithm is activated!" : "Algorithm is deactivated!"
          showToast(~message, ~toastType=ToastState.ToastSuccess)
          setScreenState(_ => Success)
        } else {
          let message = isActivate
            ? "Failed to Activate the Configuration!"
            : "Failed to Deactivate the Configuration!"
          showToast(~message, ~toastType=ToastState.ToastError)
          setScreenState(_ => Error(message))
        }
      | None => setScreenState(_ => Error("Something went wrong"))
      }
      JSON.Encode.null
    }
  }

  let setVolumeSplit = async (splitPercentage: int) => {
    try {
      let queryParameters = `split=${splitPercentage->Int.toString}`
      let url = getURL(
        ~entityName=V1(SET_VOLUME_SPLIT),
        ~methodType=Post,
        ~queryParameters=Some(queryParameters),
      )
      let _ = await updateDetails(url, JSON.Encode.null, Post)
    } catch {
    | Exn.Error(e) => {
        showToast(~message="Failed to set volume split!", ~toastType=ToastError)
        let err = Exn.message(e)->Option.getOr("Something went wrong")
        Exn.raiseError(err)
      }
    }
  }

  let onSubmit = async (values, isSaveRule) => {
    try {
      let dict = values->getDictFromJsonObject
      let splitPercentage = dict->getInt("split_percentage", 100)

      let response = await createAuthRateRouting(~values)
      let routingId = response->getDictFromJsonObject->getString("id", "")
      let _ = await setVolumeSplit(splitPercentage)

      showToast(
        ~message="Successfully Created a new Configuration!",
        ~toastType=ToastState.ToastSuccess,
      )
      setScreenState(_ => Success)
      setShowModal(_ => false)

      if isSaveRule {
        RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/routing"))
      }

      let dict = Dict.make()
      Dict.set(dict, "id", routingId->JSON.Encode.string)

      Nullable.make(dict->JSON.Encode.object)
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Something went wrong!")
      showToast(~message="Failed to Save the Configuration!", ~toastType=ToastState.ToastError)
      setScreenState(_ => PageLoaderWrapper.Error(err))
      Nullable.null
    }
  }

  let handleActivateConfiguration = async (activatingId: option<string>) => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let activateRuleURL = getURL(
        ~entityName=V1(ACTIVATE_AUTH_RATE_ROUTING),
        ~methodType=Post,
        ~id=activatingId,
      )
      let _ = await updateDetails(activateRuleURL, Dict.make()->JSON.Encode.object, Post)
      showToast(~message="Successfully Activated!", ~toastType=ToastState.ToastSuccess)
      RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url=`${baseUrlForRedirection}?`))
      setScreenState(_ => Success)
    } catch {
    | Exn.Error(e) =>
      switch Exn.message(e) {
      | Some(message) =>
        if message->String.includes("IR_16") {
          showToast(~message="Algorithm is activated!", ~toastType=ToastState.ToastSuccess)
          RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url=baseUrlForRedirection))
          setScreenState(_ => Success)
        } else {
          showToast(
            ~message="Failed to Activate the Configuration!",
            ~toastType=ToastState.ToastError,
          )
          setScreenState(_ => Error(message))
        }
      | None => setScreenState(_ => Error("Something went wrong"))
      }
    }
  }

  let handleDeactivateConfiguration = async () => {
    try {
      let _ = await createAuthRateRouting(~isActivate=false, ~values=initialValues)
      showToast(~message="Successfully Deactivated!", ~toastType=ToastState.ToastSuccess)
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Deactivation failed!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }

  let validateForm = (
    values: JSON.t,
    requiredConfigKeys: array<AuthRateRoutingTypes.formFields>,
  ): JSON.t => {
    let dict = values->JSON.Decode.object->Option.getOr(Dict.make())
    let decisionEngineConfigs = dict->getDictfromDict("decision_engine_configs")
    let formErrors = Dict.make()
    let decisionEngineErrors = Dict.make()

    requiredConfigKeys->Array.forEach(key => {
      switch key {
      | BucketSize
      | ExplorationPercent =>
        if decisionEngineConfigs->getInt(getFormFieldKey(key), -1) == -1 {
          decisionEngineErrors->Dict.set(getFormFieldKey(key), "Required"->JSON.Encode.string)
          formErrors->Dict.set("decision_engine_configs", decisionEngineErrors->JSON.Encode.object)
        }
      | RolloutPercent =>
        switch dict->getInt(key->getFormFieldKey, -1) {
        | -1 => formErrors->Dict.set(key->getFormFieldKey, "Required"->JSON.Encode.string)
        | value if value > 100 =>
          formErrors->Dict.set(key->getFormFieldKey, "Cannot exceed 100"->JSON.Encode.string)
        | _ => ()
        }
      }
    })

    formErrors->JSON.Encode.object
  }

  let formFields = allFormFields->Array.mapWithIndex((field, index) => {
    <FormRenderer.FieldRenderer
      key={Int.toString(index)}
      showErrorOnChange=true
      field={FormRenderer.makeFieldInfo(
        ~label=getFormFieldLabel(field),
        ~description=getFormFieldDescription(field),
        ~toolTipPosition=ToolTip.Right,
        ~isRequired=requiredFormFields->Array.includes(field),
        ~name=getFormFieldName(field),
        ~customInput=InputFields.numericTextInput(~precision=-1, ~isDisabled=disableFields),
      )}
    />
  })

  let editConfiguration = () => {
    setPageState(_ => Create)
    setDisableFields(_ => false)
  }

  let requiredConfigKeys: array<AuthRateRoutingTypes.formFields> = [
    BucketSize,
    ExplorationPercent,
    RolloutPercent,
  ]

  <div className="my-6">
    <PageLoaderWrapper screenState>
      {connectorList->Array.length > 0
        ? <Form
            onSubmit={(values, _) => onSubmit(values, true)}
            initialValues
            validate={values => validateForm(values, requiredConfigKeys)}>
            <div className="flex flex-col gap-6">
              <div className="w-full flex justify-between">
                <BasicDetailsForm.BusinessProfileInp
                  setProfile={setProfile}
                  profile={profile}
                  options={MerchantAccountUtils.businessProfileNameDropDownOption(
                    businessProfileValues,
                  )}
                  label="Profile"
                />
              </div>
              <AlertV2Binding
                alertType=Primary
                slot={{
                  slot: <Icon name="nd-info-circle" size=20 className="text-nd_primary_blue-500" />,
                }}
                description="Auth rate routing continuously learns from recent authorization outcomes and sends each payment to the processor most likely to succeed. Use the settings below to control how it learns and how much of your traffic it manages."
              />
              <div className="border border-nd_gray-150 bg-nd_gray-25 rounded-lg p-4 max-w-700">
                {formFields->React.array}
              </div>
            </div>
            <div>
              {switch pageState {
              | Preview =>
                <div className="flex flex-col md:flex-row gap-4 p-1 mt-5">
                  <ACLButton
                    text={"Duplicate and Edit Configuration"}
                    buttonType={isActive ? Primary : Secondary}
                    authorization={userHasAccess(~groupAccess=WorkflowsManage)}
                    onClick={_ => editConfiguration()}
                    customButtonStyle="w-1/5"
                    buttonState=Normal
                  />
                  <RenderIf condition={!isActive}>
                    <ACLButton
                      text={"Activate Configuration"}
                      buttonType={Primary}
                      authorization={userHasAccess(~groupAccess=WorkflowsManage)}
                      onClick={_ => handleActivateConfiguration(routingRuleId)->ignore}
                      customButtonStyle="w-1/5"
                      buttonState=Normal
                    />
                  </RenderIf>
                  <RenderIf condition={isActive}>
                    <ACLButton
                      text={"Deactivate Configuration"}
                      buttonType={Secondary}
                      authorization={userHasAccess(~groupAccess=WorkflowsManage)}
                      onClick={_ => handleDeactivateConfiguration()->ignore}
                      customButtonStyle="w-1/5"
                      buttonState=Normal
                    />
                  </RenderIf>
                </div>
              | Create =>
                <div className="mt-5">
                  <RoutingUtils.ConfigureRuleButton setShowModal customButtonStyle="ml-1" />
                </div>
              | _ => React.null
              }}
              <CustomModal.RoutingCustomModal
                showModal
                setShowModal
                cancelButton={<FormRenderer.SubmitButton
                  text="Save Rule"
                  buttonSize=Button.Small
                  buttonType=Button.Secondary
                  customSubmitButtonStyle="w-1/5 rounded-lg"
                />}
                showCancelButton=false
                submitButton={<RoutingUtils.SaveAndActivateButton
                  onSubmit handleActivateConfiguration
                />}
                headingText="Activate Current Configuration?"
                subHeadingText="Activating this configuration will override the current one. Please confirm."
                leftIcon="warning-modal"
                iconSize=35
              />
            </div>
          </Form>
        : <NoDataFound message="Please configure at least 1 connector" renderType=InfoBox />}
    </PageLoaderWrapper>
  </div>
}
