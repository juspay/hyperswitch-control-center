open APIUtils
open LogicUtils

@react.component
let make = (~routingRuleId, ~isActive, ~baseUrlForRedirection, ~urlEntityName) => {
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let showToast = ToastState.useShowToast()
  let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (pageState, setPageState) = React.useState((_): RoutingTypes.pageState => RoutingTypes.Create)
  let (initialValues, setInitialValues) = React.useState(_ => RuleBasedUtils.defaultInitialValues())
  let (showModal, setShowModal) = React.useState(_ => false)

  let initWasm = async () => {
    try {
      let _ = await Window.connectorWasmInit()
    } catch {
    | _ => ()
    }
  }

  let loadConfig = async id => {
    try {
      let url = getURL(~entityName=urlEntityName, ~methodType=Get, ~id=Some(id))
      let json = await fetchDetails(url)
      setInitialValues(_ => json->RuleBasedUtils.normalizeRulePayload)
      setPageState(_ => Preview)
    } catch {
    | _ => Js.log("jhj")
    }
  }

  let run = async () => {
    try {
      setScreenState(_ => Loading)
      await initWasm()
      switch routingRuleId {
      | Some(id) => await loadConfig(id)
      | None => setPageState(_ => Create)
      }
      setScreenState(_ => Success)
    } catch {
    | Exn.Error(e) => setScreenState(_ => Error(Exn.message(e)->Option.getOr("Failed to load")))
    | _ => setScreenState(_ => Error("Failed to load"))
    }
  }
  React.useEffect(() => {
    run()->ignore
    None
  }, [routingRuleId])

  let onSubmit = async (values, isSaveRule) => {
    try {
      setScreenState(_ => Loading)
      let payload = values->RuleBasedUtils.normalizeRulePayload->getDictFromJsonObject
      payload->Dict.set("profile_id", profileId->JSON.Encode.string)
      let url = getURL(~entityName=urlEntityName, ~methodType=Post)
      let response = await updateDetails(url, payload->JSON.Encode.object, Post)
      showToast(~message="Configuration saved", ~toastType=ToastState.ToastSuccess)
      setShowModal(_ => false)
      setScreenState(_ => Success)
      if isSaveRule {
        RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url=baseUrlForRedirection))
      }
      Nullable.make(response)
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to save the configuration!")
      showToast(~message=err, ~toastType=ToastState.ToastError)
      setShowModal(_ => false)
      setScreenState(_ => Success)
      Exn.raiseError(err)
    }
  }

  let handleActivate = async activatingId => {
    try {
      setScreenState(_ => Loading)
      let url = getURL(~entityName=urlEntityName, ~methodType=Post, ~id=activatingId)
      let _ = await updateDetails(url, Dict.make()->JSON.Encode.object, Post)
      showToast(~message="Successfully activated!", ~toastType=ToastState.ToastSuccess)
      RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url=`${baseUrlForRedirection}?`))
      setScreenState(_ => Success)
    } catch {
    | Exn.Error(e) =>
      let msg = Exn.message(e)->Option.getOr("")
      if msg->String.includes("IR_16") {
        showToast(~message="Algorithm is activated!", ~toastType=ToastState.ToastSuccess)
        RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url=baseUrlForRedirection))
        setScreenState(_ => Success)
      } else {
        showToast(
          ~message="Failed to activate the configuration!",
          ~toastType=ToastState.ToastError,
        )
        setScreenState(_ => Success)
      }
    }
  }

  let handleDeactivate = async () => {
    try {
      setScreenState(_ => Loading)
      let url = `${getURL(~entityName=urlEntityName, ~methodType=Post)}/deactivate`
      let body = [("profile_id", profileId->JSON.Encode.string)]->Dict.fromArray->JSON.Encode.object
      let _ = await updateDetails(url, body, Post)
      showToast(~message="Successfully deactivated!", ~toastType=ToastState.ToastSuccess)
      RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url=`${baseUrlForRedirection}?`))
      setScreenState(_ => Success)
    } catch {
    | Exn.Error(_) =>
      showToast(
        ~message="Failed to deactivate the configuration!",
        ~toastType=ToastState.ToastError,
      )
      setScreenState(_ => Success)
    }
  }

  let onDuplicate = () => {
    setInitialValues(prev => prev->RuleBasedUtils.forDuplicate)
    setPageState(_ => Create)
  }

  <PageLoaderWrapper screenState>
    {switch pageState {
    | Preview =>
      <div className="flex flex-col gap-6">
        <RuleBasedHelper.PreviewView values=initialValues />
        <div className="flex flex-wrap gap-4">
          <Button
            text="Duplicate and Edit Configuration"
            buttonType={isActive ? Primary : Secondary}
            onClick={_ => onDuplicate()}
          />
          <RenderIf condition={!isActive}>
            <Button
              text="Activate Configuration"
              buttonType=Primary
              onClick={_ => handleActivate(routingRuleId)->ignore}
            />
          </RenderIf>
          <RenderIf condition={isActive}>
            <Button
              text="Deactivate Configuration"
              buttonType=Secondary
              onClick={_ => handleDeactivate()->ignore}
            />
          </RenderIf>
        </div>
      </div>
    | _ =>
      <Form
        initialValues
        validate=RuleBasedUtils.validate
        onSubmit={(values, _) => onSubmit(values, true)}>
        <RuleBased />
        <div className="mt-6">
          <RoutingUtils.ConfigureRuleButton setShowModal />
        </div>
        <CustomModal.RoutingCustomModal
          showModal
          setShowModal
          cancelButton={<FormRenderer.SubmitButton
            text="Save Rule"
            buttonSize=Button.Small
            buttonType=Button.Secondary
            customSubmitButtonStyle="w-1/5 rounded-xl"
          />}
          submitButton={<AdvancedRoutingUIUtils.SaveAndActivateButton
            onSubmit handleActivateConfiguration=handleActivate
          />}
          headingText="Activate Current Configuration?"
          subHeadingText="Activating this configuration will override the current one. Alternatively, save it to access later from the configuration history. Please confirm."
          leftIcon="warning-modal"
          iconSize=35
        />
        <FormValuesSpy />
      </Form>
    }}
  </PageLoaderWrapper>
}
