open RevenueRecoveryProfileTypes
open RevenueRecoveryProfileUtils
open RevenueRecoveryProfileHelper

@react.component
let make = (~isOnboarded, ~onProfileSaved) => {
  open LogicUtils
  open RevenueRecoveryOnboardingUtils

  let mixpanelEvent = MixpanelHook.useSendEvent()
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)
  let updateBusinessProfile = BusinessProfileHook.useUpdateBusinessProfile(~version=V2)
  let {isLiveMode} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let recoveryProfile = HyperswitchAtom.recoveryProfileAtom->Recoil.useRecoilValueFromAtom
  let webhookDetails = recoveryProfile->Option.flatMap(profile => profile.webhookDetails)
  let (currentStep, setCurrentStep) = React.useState(_ => scheduledOnlyDefaultStep)
  let (retryAlgorithm, setRetryAlgorithm) = React.useState(_ => Monitoring)
  let (retryConfigValues, setRetryConfigValues) = React.useState(_ =>
    getRetryConfigInitialValues(None)
  )
  let webhookInitialValues = React.useMemo(
    () => getWebhookInitialValues(webhookDetails),
    [webhookDetails],
  )

  let goToDefaultPath = () =>
    RescriptReactRouter.replace(
      GlobalVars.appendDashboardPath(~url=RevenueRecoverySidebarValues.defaultPath),
    )

  React.useEffect(() => {
    setShowSideBar(_ => false)

    Some(() => setShowSideBar(_ => true))
  }, [])

  React.useEffect(() => {
    if isOnboarded {
      goToDefaultPath()
    }
    None
  }, [isOnboarded])

  // Nothing is saved until the last step, since saving the model onboards the merchant
  let onConfigurationSubmit = async (values, _form: ReactFinalForm.formApi) => {
    setRetryConfigValues(_ => values)
    VerticalStepIndicatorUtils.findNextStep(
      scheduledOnlyOnboardingSections,
      currentStep,
    )->mapOptionOrDefault((), nextStep => setCurrentStep(_ => nextStep))
    Nullable.null
  }

  let onWebhookSubmit = async (values, _form: ReactFinalForm.formApi) => {
    try {
      let body = [
        (triggerModelKey, (ExternalTriggers :> string)->JSON.Encode.string),
        (retryAlgorithmKey, (retryAlgorithm :> string)->JSON.Encode.string),
        (
          retryConfigKey,
          retryConfigValues
          ->getDictFromJsonObject
          ->getDictfromDict(retryConfigKey)
          ->JSON.Encode.object,
        ),
        (
          webhookDetailsKey,
          getWebhookDetailsBody(~webhookUrl=values->getWebhookUrl, ~webhookDetails),
        ),
      ]
      let response = await updateBusinessProfile(~body=body->Dict.fromArray->JSON.Encode.object)
      mixpanelEvent(~eventName=`recovery_mode_saved_${(retryAlgorithm :> string)}`)
      onProfileSaved(response->mapJsonToRecoveryProfile)
    } catch {
    | _ => ()
    }
    Nullable.null
  }

  let validateWebhook = values => {
    let errors = Dict.make()
    errors->validateWebhookUrl(values, ~isLiveMode)
    errors->JSON.Encode.object
  }

  <div className="flex flex-row">
    <VerticalStepIndicator
      titleElement={"Setup Recovery"->React.string}
      sections=scheduledOnlyOnboardingSections
      currentStep
      backClick=goToDefaultPath
    />
    <div className="flex flex-col ml-14 mt-16 w-full max-w-3xl pr-14">
      {switch currentStep->getScheduledOnlySectionVariant {
      | #configuration =>
        <PageWrapper
          title="Configuration" subTitle="Choose how recovery runs and set its retry limits.">
          <Form
            key={(#configuration: scheduledOnlyOnboardingSections :> string)}
            onSubmit=onConfigurationSubmit
            initialValues=retryConfigValues
            validate=validateRetryConfig>
            <div className="flex flex-col gap-8">
              <RetryConfigFields>
                <RetryModeSelector
                  selectedMode=retryAlgorithm onChange={mode => setRetryAlgorithm(_ => mode)}
                />
              </RetryConfigFields>
              <FormRenderer.SubmitButton
                text="Next" buttonSize={Small} customSubmitButtonStyle="!w-full"
              />
            </div>
          </Form>
        </PageWrapper>
      | #setupWebhook =>
        <PageWrapper
          title="Setup Webhook"
          subTitle="Add the URL we send the next retry time of each invoice to.">
          <Form
            key={(#setupWebhook: scheduledOnlyOnboardingSections :> string)}
            onSubmit=onWebhookSubmit
            initialValues=webhookInitialValues
            validate=validateWebhook>
            <div className="flex flex-col gap-8 max-w-xl">
              <WebhookUrlField />
              <FormRenderer.SubmitButton
                text="Save and finish" buttonSize={Small} customSubmitButtonStyle="!w-full"
              />
            </div>
          </Form>
        </PageWrapper>
      }}
    </div>
  </div>
}
