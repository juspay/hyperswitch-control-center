open PaymentSettingsHelper
open Typography

module EventClassSection = {
  @react.component
  let make = (~config: WebhookConfigurationTypes.webhookEventClassConfig) => {
    <div className="p-5">
      <FormRenderer.FieldRenderer
        field={config->WebhookConfigurationUtils.makeStatusField}
        labelClass={`!${body.sm.medium} !text-nd_gray-700`}
        fieldWrapperClass="max-w-xl"
      />
    </div>
  }
}

@react.component
let make = () => {
  open FormRenderer

  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let showToast = ToastAdapter.useShowToast()
  let {version} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()

  let businessProfileRecoilVal = Recoil.useRecoilValueFromAtom(
    HyperswitchAtom.businessProfileFromIdAtomInterface,
  )
  let updateBusinessProfile = BusinessProfileHook.useUpdateBusinessProfile(~version)

  let mixpanelEvent = MixpanelHook.useSendEvent()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let (eventClassConfigs, setEventClassConfigs) = React.useState(_ => [])

  let getEventClassConfigs = async () => {
    try {
      let _ = await Window.connectorWasmInit()
      let configs =
        Window.getWebhookStatusConfig()->Array.map(WebhookConfigurationUtils.eventClassConfigMapper)
      setEventClassConfigs(_ => configs)
    } catch {
    | Exn.Error(e) => Js.log2("FAILED TO LOAD WEBHOOK STATUS CONFIG", e)
    | _ => ()
    }
  }

  React.useEffect(() => {
    getEventClassConfigs()->ignore
    None
  }, [])

  let accordion: array<Accordion.accordion> = eventClassConfigs->Array.map(config => {
    Accordion.title: config.eventClass->LogicUtils.snakeToTitle,
    renderContent: (~currentAccordionState as _, ~closeAccordionFn as _) =>
      <EventClassSection config />,
    renderContentOnTop: None,
  })

  let onSubmit = async (values, _) => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let _ = await updateBusinessProfile(~body=values, ~shouldTransform=true)
      mixpanelEvent(~eventName="payment_settings_webhook_configuration")
      showToast(~message=`Webhook configuration updated`, ~toastType=ToastState.ToastSuccess)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => {
        setScreenState(_ => PageLoaderWrapper.Success)
        showToast(
          ~message=`Failed to update webhook configuration`,
          ~toastType=ToastState.ToastError,
        )
      }
    }
    Nullable.null
  }

  <PageLoaderWrapper screenState>
    <Form
      initialValues={businessProfileRecoilVal->Identity.genericTypeToJson}
      onSubmit
      validate={values => {
        PaymentSettingsUtils.validateMerchantAccountFormV2(
          ~values,
          ~isLiveMode=featureFlagDetails.isLiveMode,
          ~businessProfileRecoilVal,
        )
      }}>
      <div className="flex flex-col gap-4">
        <div className="ml-1 mt-4">
          <FieldRenderer
            field={webhookUrl}
            errorClass={HSwitchUtils.errorClass}
            labelClass={`!${body.lg.semibold} !text-nd-gray-700`}
            fieldWrapperClass="max-w-xl"
          />
        </div>
        <hr className="mt-6" />
        <div className="flex flex-col gap-2 mt-2">
          <p className={`${body.lg.semibold} text-nd_gray-700 ml-1`}>
            {"Event Configuration"->React.string}
          </p>
          <p className={`${body.md.medium} text-nd_gray-400 ml-1`}>
            {"Choose which statuses trigger an outgoing webhook for each event type. Leave a resource untouched to keep sending webhooks for every status."->React.string}
          </p>
          <div className="max-w-3xl mt-2">
            <AccordionAdapter
              accordion
              arrowPosition=Accordion.Right
              accordionTopContainerCss="rounded-lg border border-nd_gray-200 bg-white"
              accordionBottomContainerCss="px-5 pb-5"
              contentExpandCss=""
              titleStyle={`${body.lg.semibold} text-nd_gray-700`}
              gapClass="gap-4"
            />
          </div>
        </div>
        <DesktopRow wrapperClass="mt-8">
          <div className="flex justify-end mt-4 w-full">
            <SubmitButton text="Update" buttonType=Button.Primary buttonSize=Button.Medium />
          </div>
        </DesktopRow>
      </div>
    </Form>
  </PageLoaderWrapper>
}
