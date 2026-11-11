open RevenueRecoveryProfileTypes
open RevenueRecoveryProfileUtils
open RevenueRecoveryProfileHelper

@react.component
let make = (~isOnboarded, ~onProfileSaved) => {
  open LogicUtils

  let mixpanelEvent = MixpanelHook.useSendEvent()
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)
  let updateBusinessProfile = BusinessProfileHook.useUpdateBusinessProfile(~version=V2)
  let {isLiveMode} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let recoveryProfile = HyperswitchAtom.recoveryProfileAtom->Recoil.useRecoilValueFromAtom
  let webhookDetails = recoveryProfile->Option.flatMap(profile => profile.webhookDetails)
  let (retryAlgorithm, setRetryAlgorithm) = React.useState(_ => Monitoring)
  let initialValues = React.useMemo(() => getRetryConfigInitialValues(None), [])

  let validate = values => {
    let errors = values->validateRetryConfig->getDictFromJsonObject
    errors->validateWebhookUrl(values, ~isLiveMode)
    errors->JSON.Encode.object
  }

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

  let onSubmit = async (values, _form: ReactFinalForm.formApi) => {
    try {
      let body = [
        (triggerModelKey, (ExternalTriggers :> string)->JSON.Encode.string),
        (retryAlgorithmKey, (retryAlgorithm :> string)->JSON.Encode.string),
        (
          retryConfigKey,
          values->getDictFromJsonObject->getDictfromDict(retryConfigKey)->JSON.Encode.object,
        ),
      ]
      let webhookUrl = values->getWebhookUrl
      if webhookUrl->isNonEmptyString {
        body->Array.push((webhookDetailsKey, getWebhookDetailsBody(~webhookUrl, ~webhookDetails)))
      }
      let response = await updateBusinessProfile(~body=body->Dict.fromArray->JSON.Encode.object)
      mixpanelEvent(~eventName=`recovery_mode_saved_${(retryAlgorithm :> string)}`)
      onProfileSaved(response->mapJsonToRecoveryProfile)
    } catch {
    | _ => ()
    }
    Nullable.null
  }

  <div className="flex flex-row">
    <VerticalStepIndicator
      titleElement={"Setup Recovery"->React.string}
      sections=[configurationSection]
      currentStep={sectionId: configurationSection.id, subSectionId: None}
      backClick=goToDefaultPath
    />
    <div className="flex flex-col ml-14 mt-16 w-full max-w-3xl pr-14">
      <RevenueRecoveryOnboardingUtils.PageWrapper
        title="Configuration" subTitle="Choose how recovery runs and set its retry limits.">
        <Form onSubmit initialValues validate>
          <div className="flex flex-col gap-8">
            <RetryConfigFields>
              <RetryModeSelector
                selectedMode=retryAlgorithm onChange={mode => setRetryAlgorithm(_ => mode)}
              />
            </RetryConfigFields>
            <WebhookUrlField />
            {switch recoveryProfile->Option.flatMap(profile => profile.paymentResponseHashKey) {
            | Some(hashKey) =>
              <div className="px-2">
                <PaymentResponseHashKey hashKey />
              </div>
            | None => React.null
            }}
            <div className="flex gap-4 justify-end">
              <Button
                text="Back" buttonType=Secondary buttonSize=Medium onClick={_ => goToDefaultPath()}
              />
              <FormRenderer.SubmitButton
                text="Save and finish" buttonType=Button.Primary buttonSize=Button.Medium
              />
            </div>
          </div>
        </Form>
      </RevenueRecoveryOnboardingUtils.PageWrapper>
    </div>
  </div>
}
