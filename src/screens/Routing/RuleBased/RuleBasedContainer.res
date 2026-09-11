open APIUtils
open LogicUtils
open RoutingTypes
open Typography

@react.component
let make = (~routingRuleId, ~isActive, ~urlEntityName, ~baseUrlForRedirection) => {
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let showToast = ToastAdapter.useShowToast()
  let getTimeInCustomTimeZone = TimeZoneHook.useGetTimeInCustomTimeZone()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  let url = RescriptReactRouter.useUrl()

  let (
    connectorType: ConnectorTypes.connectorTypeVariants,
    connectorPath,
  ) = switch url->RoutingUtils.urlToVariantMapper {
  | PayoutRouting => (PayoutProcessor, "/payoutconnectors")
  | _ => (PaymentProcessor, "/connectors")
  }
  let connectors =
    ConnectorListInterface.useFilteredConnectorList(
      ~retainInList=connectorType,
    )->RuleBasedUtils.routingConnectorList(~profileId)

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (pageState, setPageState) = React.useState(() => Create)
  let (showModal, setShowModal) = React.useState(_ => false)
  let (initialValues, setInitialValues) = React.useState(_ =>
    RuleBasedUtils.defaultInitialValues(
      ~currentDate=getTimeInCustomTimeZone("YYYY-MM-DD"),
      ~currentTime=getTimeInCustomTimeZone("ddd, DD MMM YYYY HH:mm:ss", ~includeTimeZone=true),
    )
  )

  let initWasm = async () => {
    try {
      let _ = await Window.connectorWasmInit()
    } catch {
    | _ => ()
    }
  }

  let activeRoutingDetails = async id => {
    try {
      let url = getURL(~entityName=urlEntityName, ~methodType=Get, ~id=Some(id))
      let response = await fetchDetails(url)
      setInitialValues(_ => response->RuleBasedUtils.normalizeLoadedConfig)
    } catch {
    | Exn.Error(e) => Exn.raiseError(Exn.message(e)->Option.getOr("Something went wrong"))
    }
  }

  let fetchActiveRoutingDetails = async () => {
    try {
      setScreenState(_ => Loading)
      await initWasm()
      switch routingRuleId {
      | Some(id) => {
          await activeRoutingDetails(id)
          setPageState(_ => Preview)
        }
      | None => setPageState(_ => Create)
      }
      setScreenState(_ => Success)
    } catch {
    | Exn.Error(e) =>
      setScreenState(_ => Error(Exn.message(e)->Option.getOr("Something went wrong")))
    }
  }

  React.useEffect(() => {
    fetchActiveRoutingDetails()->ignore
    None
  }, [routingRuleId])

  let handleActivateConfiguration = async activatingId => {
    try {
      setScreenState(_ => Loading)
      let activateRuleURL = getURL(~entityName=urlEntityName, ~methodType=Post, ~id=activatingId)
      let _ = await updateDetails(activateRuleURL, Dict.make()->JSON.Encode.object, Post)
      showToast(~message="Successfully activated!", ~toastType=ToastSuccess)
      RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url=`${baseUrlForRedirection}?`))
      setScreenState(_ => Success)
    } catch {
    | Exn.Error(e) =>
      let message = Exn.message(e)->Option.getOr("Something went wrong")
      if message->String.includes("IR_16") {
        showToast(~message="Algorithm is activated!", ~toastType=ToastSuccess)
        RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url=baseUrlForRedirection))
      } else {
        showToast(~message="Failed to Activate the Configuration!", ~toastType=ToastError)
      }
      setScreenState(_ => Success)
    }
  }

  let handleDeactivateConfiguration = async () => {
    try {
      setScreenState(_ => Loading)
      let deactivateRoutingURL = `${getURL(~entityName=urlEntityName, ~methodType=Post)}/deactivate`
      let body = [("profile_id", profileId->JSON.Encode.string)]->Dict.fromArray->JSON.Encode.object
      let _ = await updateDetails(deactivateRoutingURL, body, Post)
      showToast(~message="Successfully deactivated!", ~toastType=ToastSuccess)
      RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url=`${baseUrlForRedirection}?`))
      setScreenState(_ => Success)
    } catch {
    | Exn.Error(_) =>
      showToast(~message="Failed to Deactivate the Configuration!", ~toastType=ToastError)
      setScreenState(_ => Success)
    }
  }

  let onSubmit = async (values, isSaveRule) => {
    try {
      setScreenState(_ => Loading)
      let payload = values->RuleBasedUtils.normalizeRulePayload->getDictFromJsonObject
      payload->Dict.set("profile_id", profileId->JSON.Encode.string)
      let createRuleURL = getURL(~entityName=urlEntityName, ~methodType=Post)
      let response = await updateDetails(createRuleURL, payload->JSON.Encode.object, Post)
      showToast(~message="Successfully created a new configuration!", ~toastType=ToastSuccess)
      setShowModal(_ => false)
      setScreenState(_ => Success)
      if isSaveRule {
        RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url=baseUrlForRedirection))
      }
      Nullable.make(response)
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      showToast(~message="Failed to Save the Configuration!", ~toastType=ToastError)
      setShowModal(_ => false)
      setScreenState(_ => Success)
      Exn.raiseError(err)
    }
  }

  let onDuplicate = () => {
    setInitialValues(prev => prev->RuleBasedUtils.forDuplicate)
    setPageState(_ => Create)
  }

  <PageLoaderWrapper screenState>
    <div className="flex flex-col gap-1 mb-6">
      <p className={`${heading.md.semibold} text-nd_gray-800`}>
        {"Rule Based Configuration"->React.string}
      </p>
      <p className={`${body.sm.regular} text-nd_gray-600`}>
        {"Create smart rules to control how payments are routed, based on things like payment amount, method, or location."->React.string}
      </p>
    </div>
    {switch pageState {
    | Preview =>
      <div className="flex flex-col gap-6">
        <RuleBasedHelper.PreviewView values=initialValues />
        <div className="flex flex-col md:flex-row gap-4 p-1">
          <ACLButton
            text="Duplicate and Edit Configuration"
            buttonType={isActive ? Primary : Secondary}
            authorization={userHasAccess(~groupAccess=WorkflowsManage)}
            onClick={_ => onDuplicate()}
            customButtonStyle="w-1/5"
            buttonState=Normal
          />
          <RenderIf condition={!isActive}>
            <ACLButton
              text="Activate Configuration"
              buttonType=Primary
              authorization={userHasAccess(~groupAccess=WorkflowsManage)}
              onClick={_ => handleActivateConfiguration(routingRuleId)->ignore}
              customButtonStyle="w-1/5"
              buttonState=Normal
            />
          </RenderIf>
          <RenderIf condition={isActive}>
            <ACLButton
              text="Deactivate Configuration"
              buttonType=Secondary
              authorization={userHasAccess(~groupAccess=WorkflowsManage)}
              onClick={_ => handleDeactivateConfiguration()->ignore}
              customButtonStyle="w-1/5"
              buttonState=Normal
            />
          </RenderIf>
        </div>
      </div>
    | Create
    | Edit =>
      <>
        <RenderIf condition={connectors->isEmptyArray}>
          <RoutingHelper.NoProcessorFound connectorPath />
        </RenderIf>
        <RenderIf condition={connectors->isNonEmptyArray}>
          <Form
            initialValues
            validate=RuleBasedUtils.validate
            onSubmit={(values, _) => onSubmit(values, true)}>
            <RuleBased baseUrlForRedirection />
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
              submitButton={<RoutingUtils.SaveAndActivateButton
                onSubmit handleActivateConfiguration
              />}
              headingText="Activate Current Configuration?"
              subHeadingText="Activating this configuration will override the current one. Alternatively, save it to access later from the configuration history. Please confirm."
              leftIcon="warning-modal"
              iconSize=35
            />
          </Form>
        </RenderIf>
      </>
    }}
  </PageLoaderWrapper>
}
