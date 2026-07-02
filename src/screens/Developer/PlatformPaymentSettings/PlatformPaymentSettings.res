open PaymentSettingsRevampedHelper
open PaymentSettingsProfileInfo
open Typography

module PaymentBehaviour = {
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
    let onSubmit = async (values, _) => {
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)
        let _ = await updateBusinessProfile(~body=values, ~shouldTransform=true)
        mixpanelEvent(~eventName="platform_payment_settings_payment_behaviour")
        showToast(~message="Details updated", ~toastType=ToastSuccess)
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => {
          setScreenState(_ => PageLoaderWrapper.Success)
          showToast(~message="Failed to update", ~toastType=ToastError)
        }
      }
      Nullable.null
    }

    <PageLoaderWrapper screenState>
      <Form
        initialValues={businessProfileRecoilVal->Identity.genericTypeToJson}
        onSubmit
        validate={values => {
          PaymentSettingsRevampedUtils.validateMerchantAccountFormV2(
            ~values,
            ~isLiveMode=featureFlagDetails.isLiveMode,
            ~businessProfileRecoilVal,
          )
        }}>
        <div className="ml-1 mt-4">
          <FieldRenderer
            field={webhookUrl}
            labelClass={`!${body.lg.semibold} !text-nd-gray-700`}
            fieldWrapperClass="max-w-xl"
          />
        </div>
        <DesktopRow wrapperClass="mt-8">
          <div className="flex justify-end mt-4 w-full">
            <SubmitButton text="Update" buttonType=Primary buttonSize=Medium />
          </div>
        </DesktopRow>
      </Form>
    </PageLoaderWrapper>
  }
}

@react.component
let make = () => {
  let {profileId, merchantId, version} = React.useContext(
    UserInfoProvider.defaultContext,
  ).getCommonSessionDetails()
  let businessProfileRecoilVal = Recoil.useRecoilValueFromAtom(
    HyperswitchAtom.businessProfileFromIdAtomInterface,
  )
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let (tabIndex, setTabIndex) = React.useState(_ => 0)

  let vaultConnectorsList = ConnectorListInterface.useFilteredConnectorList(
    ~retainInList=VaultProcessor,
  )
  let isBusinessProfileHasVault =
    vaultConnectorsList->Array.some(item => item.profile_id == profileId)

  let paymentBehaviourTab: Tabs.tab = {
    title: "Payment Behaviour",
    renderContent: () => <PaymentBehaviour />,
  }

  let vaultTab: Tabs.tab = {
    title: "Vault",
    renderContent: () => <PaymentSettingsVault />,
  }

  let tabs = {
    let baseTabs = [paymentBehaviourTab]
    if version == V1 && featureFlagDetails.vaultProcessor && isBusinessProfileHasVault {
      baseTabs->Array.push(vaultTab)
    }
    baseTabs
  }

  <div className="flex flex-col gap-4">
    <div className="flex flex-col gap-2">
      <PageUtils.PageHeading title="Payment settings" />
    </div>
    <div className="flex flex-col">
      <ProfileInfoHeader businessProfileRecoilVal profileId merchantId />
      <Tabs tabs initialIndex={tabIndex} onTitleClick={index => setTabIndex(_ => index)} />
    </div>
  </div>
}
