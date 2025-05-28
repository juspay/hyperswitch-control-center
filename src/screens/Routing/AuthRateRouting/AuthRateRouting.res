@react.component
let make = (
  ~routingRuleId,
  ~isActive,
  ~connectorList: array<ConnectorTypes.connectorPayload>,
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
    HyperswitchAtom.businessProfileFromIdAtom->Recoil.useRecoilValueFromAtom
  let (profile, setProfile) = React.useState(_ => businessProfileValues.profile_id)
  let (initialValues, setInitialValues) = React.useState(_ => initialValues)
  let (pageState, setPageState) = React.useState(() => RoutingTypes.Create)
  let (showModal, setShowModal) = React.useState(_ => false)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (disableFields, setDisableFields) = React.useState(_ => false)
  let currentTabName = Recoil.useRecoilValueFromAtom(HyperswitchAtom.currentTabNameRecoilAtom)

  let getVolumeSplit = async () => {
    try {
      let url = getURL(~entityName=V1(GET_VOLUME_SPLIT), ~methodType=Get)
      let response = await fetchDetails(url)
      Nullable.make(response)
    } catch {
    | _ => {
        showToast(~message="Failed to get volumne split data", ~toastType=ToastError)
        Nullable.null
      }
    }
  }

  let activeRoutingDetails = async () => {
    open AuthRateRoutingTypes
    try {
      let url = getURL(~entityName=urlEntityName, ~methodType=Get, ~id=routingRuleId)
      let response = await fetchDetails(url)

      let response = {
        config: {
          min_aggregates_size: 5,
          default_success_rate: 100,
          max_aggregates_size: 8,
          current_block_threshold: {
            max_total_count: 5,
          },
        },
        split_percentage: 100,
        name: "Auth Rate Routing",
        description: "Auth Rate Routing configuration",
      }->Identity.genericTypeToJson

      let splitPercentage = await getVolumeSplit()

      let splitPercentage =
        splitPercentage
        ->Nullable.getOr(JSON.Encode.int(100))
        ->getDictFromJsonObject
        ->getInt("split_percentage", 100)

      let values = response->formFieldsMapper(splitPercentage)->Identity.genericTypeToJson

      // let values =
      //   defaultConfigsValue
      //   ->Identity.genericTypeToDictOfJson
      //   ->formFieldsMapper(splitPercentage)
      //   ->Identity.genericTypeToJson
      setInitialValues(_ => values)
    } catch {
    | _ => showToast(~message="Failed to fetch details", ~toastType=ToastError)
    }
  }

  let fetchDetails = async () => {
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
    fetchDetails()->ignore
    None
  }, [routingRuleId])

  let authRateRoutingConfig = async (routingId, values: JSON.t) => {
    try {
      let url = getURL(
        ~entityName=V1(SET_CONFIG_AUTH_RATE_ROUTING),
        ~methodType=Patch,
        ~id=Some(routingId),
      )
      let response = await updateDetails(url, values, Patch)
      Nullable.make(response)
    } catch {
    | _ => {
        showToast(~message="Failed to update configs", ~toastType=ToastError)
        Nullable.null
      }
    }
  }

  let enableAuthRateRouting = async (~isActivate=true) => {
    try {
      let queryParamerters = `enable=${isActivate ? "dynamic_connector_selection" : "none"}`
      let url = getURL(
        ~entityName=V1(ENABLE_AUTH_RATE_ROUTING),
        ~methodType=Post,
        ~queryParamerters=Some(queryParamerters),
      )
      let response = await updateDetails(url, JSON.Encode.null, Post)
      if !isActivate {
        RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url=baseUrlForRedirection))
      }
      Nullable.make(response)
    } catch {
    | Exn.Error(e) =>
      switch Exn.message(e) {
      | Some(message) =>
        if message->String.includes("IR_16") {
          let message = isActivate ? "Algorithm is activated!" : "Algorithm is deactivated!"
          showToast(~message, ~toastType=ToastState.ToastSuccess)
          RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url=baseUrlForRedirection))
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
      Nullable.null
    }
  }

  let setVolumeSplit = async (splitPercentage: int) => {
    try {
      let queryParamerters = `split=${splitPercentage->Int.toString}`
      let url = getURL(
        ~entityName=V1(SET_VOLUME_SPLIT),
        ~methodType=Post,
        ~queryParamerters=Some(queryParamerters),
      )
      let _ = await updateDetails(url, JSON.Encode.null, Post)
    } catch {
    | _ => showToast(~message="Failed to set volumne split", ~toastType=ToastError)
    }
  }

  let onSubmit = async (values, isSaveRule) => {
    try {
      let splitPercentage = values->getDictFromJsonObject->getInt("split_percentage", 100)
      let _ = Dict.delete(values->getDictFromJsonObject, "split_percentage")

      let response = await enableAuthRateRouting()
      let routingId =
        response->Nullable.getOr(JSON.Encode.null)->getDictFromJsonObject->getString("id", "")

      let updateRoutingId = routingRuleId->Option.getOr(routingId)

      let response = await authRateRoutingConfig(updateRoutingId, values)
      let routingId =
        response->Nullable.getOr(JSON.Encode.null)->getDictFromJsonObject->getString("id", "")

      let _ = await setVolumeSplit(splitPercentage)

      showToast(
        ~message="Successfully Created a new Configuration !",
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
      showToast(~message="Failed to Save the Configuration !", ~toastType=ToastState.ToastError)
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
      showToast(~message="Successfully Activated !", ~toastType=ToastState.ToastSuccess)
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

  let validateForm = (values: JSON.t): JSON.t => {
    let dict = values->JSON.Decode.object->Option.getOr(Dict.make())
    let errors = Dict.make()
    let configErrors = Dict.make()

    AdvancedRoutingUtils.validateNameAndDescription(
      ~dict,
      ~errors,
      ~validateFields=["name", "description"],
    )

    let config = dict->getDictfromDict("config")
    let requiredConfigKeys = ["min_aggregates_size", "default_success_rate", "max_aggregates_size"]

    requiredConfigKeys->Array.forEach(key => {
      if config->getInt(key, -1) == -1 {
        configErrors->Dict.set(key, "Required"->JSON.Encode.string)
      }
    })

    let currentBlockThreshold = config->getDictfromDict("current_block_threshold")
    if currentBlockThreshold->getInt("max_total_count", -1) == -1 {
      let thresholdErrors = Dict.make()
      thresholdErrors->Dict.set("max_total_count", "Required"->JSON.Encode.string)
      configErrors->Dict.set("current_block_threshold", thresholdErrors->JSON.Encode.object)
    }

    if configErrors->Dict.keysToArray->Array.length > 0 {
      errors->Dict.set("config", configErrors->JSON.Encode.object)
    }

    errors->JSON.Encode.object
  }

  let formFields = allFormFields->Array.map(field => {
    <FormRenderer.FieldRenderer
      field={FormRenderer.makeFieldInfo(
        ~label=getFormFieldLabel(field),
        ~isRequired=requiredFormFields->Array.includes(field),
        ~name=getFormFieldValue(field),
        ~customInput=InputFields.numericTextInput(~precision=-1, ~isDisabled=disableFields),
      )}
    />
  })

  let editConfiguration = () => {
    setPageState(_ => Create)
    setDisableFields(_ => false)
  }

  <div className="my-6">
    <PageLoaderWrapper screenState>
      {connectorList->Array.length > 0
        ? <Form
            onSubmit={(values, _) => onSubmit(values, true)} initialValues validate=validateForm>
            <div className="w-full flex flex-col justify-between">
              <BasicDetailsForm
                formState={pageState == Preview ? ViewConfig : CreateConfig}
                currentTabName
                profile
                setProfile
              />
            </div>
            <div
              className="flex flex-col gap-4 mt-5 mb-6 p-4 bg-white dark:bg-jp-gray-lightgray_background rounded-md border border-jp-gray-600 dark:border-jp-gray-850">
              <div>
                <div className="font-bold py-2">
                  {"Intelligent Routing Configuration"->React.string}
                </div>
                <div className="w-full text-jp-gray-700 dark:text-jp-gray-700 text-justify">
                  {"Dynamically route payments to maximise payment authorization rates."->React.string}
                </div>
              </div>
              <div className="max-w-[500px]"> {formFields->React.array} </div>
            </div>
            <div>
              {switch pageState {
              | Preview =>
                <div className="flex flex-col md:flex-row gap-4 p-1 mt-5">
                  <Button
                    text={"Duplicate and Edit Configuration"}
                    buttonType={isActive ? Primary : Secondary}
                    onClick={_ => editConfiguration()}
                    customButtonStyle="w-1/5"
                    buttonState=Normal
                  />
                  <RenderIf condition={!isActive}>
                    <Button
                      text={"Activate Configuration"}
                      buttonType={Primary}
                      onClick={_ => handleActivateConfiguration(routingRuleId)->ignore}
                      customButtonStyle="w-1/5"
                      buttonState=Normal
                    />
                  </RenderIf>
                  <RenderIf condition={isActive}>
                    <Button
                      text={"Deactivate Configuration"}
                      buttonType={Secondary}
                      onClick={_ => enableAuthRateRouting(~isActivate=false)->ignore}
                      customButtonStyle="w-1/5"
                      buttonState=Normal
                    />
                  </RenderIf>
                </div>
              | Create =>
                <div className="mt-5">
                  <RoutingUtils.ConfigureRuleButton setShowModal />
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
                  customSumbitButtonStyle="w-1/5 rounded-lg"
                  tooltipWidthClass="w-48"
                />}
                submitButton={<RoutingUtils.SaveAndActivateButton
                  onSubmit handleActivateConfiguration
                />}
                headingText="Activate Current Configuration?"
                subHeadingText="Activating this configuration will override the current one. Alternatively, save it to access later from the configuration history. Please confirm."
                leftIcon="warning-modal"
                iconSize=35
              />
            </div>
            <FormValuesSpy />
          </Form>
        : <NoDataFound message="Please configure at least 1 connector" renderType=InfoBox />}
    </PageLoaderWrapper>
  </div>
}
