open PaymentSettingsRevampedHelper
open Typography

module WebhookEndpointSection = {
  @react.component
  let make = () => {
    open FormRenderer

    let errorClass = `${body.md.medium} text-start ml-1 mt-2`

    <div className="flex flex-col gap-4">
      <p className={`${body.lg.semibold} text-nd_gray-700 pt-4`}>
        {"Webhook Endpoint Configuration"->React.string}
      </p>
      <FieldRenderer
        field={webhookUrl}
        errorClass
        labelClass={`!${body.lg.semibold} !text-nd-gray-700`}
        fieldWrapperClass="max-w-xl"
      />
      <FieldRenderer
        field={webhookVersion}
        labelClass={`!${body.lg.semibold} !text-nd-gray-700`}
        fieldWrapperClass="max-w-xl"
      />
      <FieldRenderer
        field={webhookUsername}
        labelClass={`!${body.lg.semibold} !text-nd-gray-700`}
        fieldWrapperClass="max-w-xl"
      />
      <FieldRenderer
        field={webhookPassword}
        labelClass={`!${body.lg.semibold} !text-nd-gray-700`}
        fieldWrapperClass="max-w-xl"
      />
    </div>
  }
}

module EventTriggersSection = {
  @react.component
  let make = () => {
    open FormRenderer

    <div className="flex flex-col gap-2 pt-6">
      <p className={`${body.lg.semibold} text-nd_gray-700`}>
        {"Automatic Event Triggers"->React.string}
      </p>
      <p className={`${body.md.medium} text-nd_gray-400`}>
        {"Enable automatic webhook notifications for payment events"->React.string}
      </p>
      <DesktopRow itemWrapperClass="mx-1">
        <FieldRenderer
          labelClass={`!${body.lg.semibold} !text-nd-gray-700`}
          fieldWrapperClass="w-full flex justify-between items-center py-4"
          field={makeFieldInfo(
            ~name="webhook_details.payment_created_enabled",
            ~label="Payment Created",
            ~customInput=InputFields.boolInput(
              ~isDisabled=false,
              ~boolCustomClass="rounded-lg",
              ~toggleEnableColor="bg-nd_primary_blue-450",
            ),
            ~description="Send webhook when a payment is created",
          )}
        />
      </DesktopRow>
      <DesktopRow itemWrapperClass="mx-1">
        <FieldRenderer
          labelClass={`!${body.lg.semibold} !text-nd-gray-700`}
          fieldWrapperClass="w-full flex justify-between items-center py-4"
          field={makeFieldInfo(
            ~name="webhook_details.payment_succeeded_enabled",
            ~label="Payment Succeeded",
            ~customInput=InputFields.boolInput(
              ~isDisabled=false,
              ~boolCustomClass="rounded-lg",
              ~toggleEnableColor="bg-nd_primary_blue-450",
            ),
            ~description="Send webhook when a payment succeeds",
          )}
        />
      </DesktopRow>
      <DesktopRow itemWrapperClass="mx-1">
        <FieldRenderer
          labelClass={`!${body.lg.semibold} !text-nd-gray-700`}
          fieldWrapperClass="w-full flex justify-between items-center py-4"
          field={makeFieldInfo(
            ~name="webhook_details.payment_failed_enabled",
            ~label="Payment Failed",
            ~customInput=InputFields.boolInput(
              ~isDisabled=false,
              ~boolCustomClass="rounded-lg",
              ~toggleEnableColor="bg-nd_primary_blue-450",
            ),
            ~description="Send webhook when a payment fails",
          )}
        />
      </DesktopRow>
    </div>
  }
}

module StatusConfigurationSection = {
  @react.component
  let make = () => {
    open FormRenderer

    <div className="flex flex-col gap-4 pt-6">
      <p className={`${body.lg.semibold} text-nd_gray-700`}>
        {"Advanced Status Configuration"->React.string}
      </p>
      <p className={`${body.md.medium} text-nd_gray-400`}>
        {"Select specific statuses for granular webhook event triggers"->React.string}
      </p>
      <FieldRenderer
        field={paymentStatusesEnabled}
        labelClass={`!${body.lg.semibold} !text-nd-gray-700`}
        fieldWrapperClass="max-w-xl"
      />
      <FieldRenderer
        field={refundStatusesEnabled}
        labelClass={`!${body.lg.semibold} !text-nd-gray-700`}
        fieldWrapperClass="max-w-xl"
      />
      <FieldRenderer
        field={payoutStatusesEnabled}
        labelClass={`!${body.lg.semibold} !text-nd-gray-700`}
        fieldWrapperClass="max-w-xl"
      />
    </div>
  }
}

@react.component
let make = () => {
  let showToast = ToastState.useShowToast()
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {version} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()

  let businessProfileRecoilVal = Recoil.useRecoilValueFromAtom(
    HyperswitchAtom.businessProfileFromIdAtomInterface,
  )
  let updateBusinessProfile = BusinessProfileHook.useUpdateBusinessProfile(~version)

  let mixpanelEvent = MixpanelHook.useSendEvent()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)

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
      initialValues={businessProfileRecoilVal
      ->PaymentSettingsRevampedUtils.parseBusinessProfileForPaymentBehaviour
      ->Identity.genericTypeToJson}
      onSubmit
      validate={values => {
        PaymentSettingsRevampedUtils.validateMerchantAccountFormV2(
          ~values,
          ~isLiveMode=featureFlagDetails.isLiveMode,
          ~businessProfileRecoilVal,
        )
      }}>
      <WebhookEndpointSection />
      <hr className="mt-6" />
      <EventTriggersSection />
      <hr className="mt-6" />
      <StatusConfigurationSection />
      <FormRenderer.DesktopRow wrapperClass="mt-8">
        <div className="flex justify-end mt-4 w-full">
          <FormRenderer.SubmitButton
            text="Update" buttonType=Button.Primary buttonSize=Button.Medium
          />
        </div>
      </FormRenderer.DesktopRow>
    </Form>
  </PageLoaderWrapper>
}
