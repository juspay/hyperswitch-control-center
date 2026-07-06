open Typography
open PaymentSettingsRevampedUtils

module SurchargeFields = {
  @react.component
  let make = () => {
    open FormRenderer
    open HSwitchUtils
    open PaymentSettingsRevampedHelper

    let surchargeConnectorsList = ConnectorListInterface.useFilteredConnectorList(
      ~retainInList=SurchargeProcessor,
    )

    <DesktopRow wrapperClass="pt-4 flex !flex-col gap-4" itemWrapperClass="mx-1">
      <FieldRenderer
        field={surchargeConnectorsList
        ->Array.map((item): SelectBox.dropdownOption => {
          value: item.id,
          label: `${item.connector_label} - ${item.id}`,
        })
        ->surchargeConnectors}
        errorClass
        labelClass={`text-nd_gray-700 ${body.md.semibold}`}
        fieldWrapperClass="max-w-sm"
      />
    </DesktopRow>
  }
}

@react.component
let make = () => {
  open FormRenderer

  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let showToast = ToastAdapter.useShowToast()
  let businessProfileRecoilVal = Recoil.useRecoilValueFromAtom(
    HyperswitchAtom.businessProfileFromIdAtomInterface,
  )
  let {version} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let updateBusinessProfile = BusinessProfileHook.useUpdateBusinessProfile(~version)

  let onSubmit = async (values, _) => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let _ = await updateBusinessProfile(~body=values, ~shouldTransform=true)
      mixpanelEvent(~eventName="payment_settings_surcharge")
      showToast(~message=`Details updated`, ~toastType=ToastState.ToastSuccess)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => {
        setScreenState(_ => PageLoaderWrapper.Success)
        showToast(~message=`Failed to update`, ~toastType=ToastState.ToastError)
      }
    }
    Nullable.null
  }

  <PageLoaderWrapper screenState>
    <Form
      onSubmit
      initialValues={businessProfileRecoilVal->Identity.genericTypeToJson}
      validate={values => {
        validateMerchantAccountFormV2(
          ~values,
          ~isLiveMode=featureFlagDetails.isLiveMode,
          ~businessProfileRecoilVal,
        )
      }}>
      <SurchargeFields />
      <DesktopRow wrapperClass="mt-8" itemWrapperClass="mx-1">
        <div className="flex justify-end w-full gap-2">
          <SubmitButton text="Update" buttonType=Button.Primary buttonSize=Button.Medium />
        </div>
      </DesktopRow>
    </Form>
  </PageLoaderWrapper>
}
