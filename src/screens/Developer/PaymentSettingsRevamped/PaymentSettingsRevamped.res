@react.component
let make = () => {
  open HyperswitchAtom
  open PaymentSettingsProfileInfo

  let businessProfileRecoilVal = Recoil.useRecoilValueFromAtom(
    HyperswitchAtom.businessProfileFromIdAtomInterface,
  )
  let threedsConnectorList = ConnectorListInterface.useFilteredConnectorList(
    ~retainInList=AuthenticationProcessor,
  )
  let vaultConnectorsList = ConnectorListInterface.useFilteredConnectorList(
    ~retainInList=VaultProcessor,
  )
  let {profileId, merchantId, version} = React.useContext(
    UserInfoProvider.defaultContext,
  ).getCommonSessionDetails()
  let featureFlagDetails = featureFlagAtom->Recoil.useRecoilValueFromAtom
  let isBusinessProfileHasThreeds =
    threedsConnectorList->Array.some(item => item.profile_id == profileId)
  let isBusinessProfileHasVault =
    vaultConnectorsList->Array.some(item => item.profile_id == profileId)

  let (tabIndex, setTabIndex) = React.useState(_ => 0)
  let paymentBehaviourTab: Tabs.tab = {
    title: "Payment Behaviour",
    renderContent: () => <PaymentSettingsPaymentBehaviour />,
  }

  let threeDsTab: Tabs.tab = {
    title: "3DS",
    renderContent: () => <PaymentSettingsThreeDs />,
  }

  let vaultTab: Tabs.tab = {
    title: "Vault",
    renderContent: () => <PaymentSettingsVault />,
  }
  let paymentLinkTab: Tabs.tab = {
    title: "Payment Link",
    renderContent: () => <PaymentSettingsDomainName />,
  }

  let additionalTabs: array<Tabs.tab> = [
    {
      title: "Custom Headers",
      renderContent: () => <PaymentSettingsCustomWebhookHeaders />,
    },
    {
      title: "Metadata Headers",
      renderContent: () => <PaymentSettingsCustomMetadataHeaders />,
    },
  ]

  let tabs = {
    let baseTabs = [paymentBehaviourTab]

    if version == V1 || (version == V2 && isBusinessProfileHasThreeds) {
      baseTabs->Array.push(threeDsTab)
    }

    if version == V1 && featureFlagDetails.vaultProcessor && isBusinessProfileHasVault {
      baseTabs->Array.push(vaultTab)
    }

    baseTabs->Array.pushMany(additionalTabs)
    if version == V1 {
      baseTabs->Array.push(paymentLinkTab)
    }
    baseTabs
  }

  <div className="flex flex-col gap-4">
    <div className="flex flex-col gap-2">
      <PageUtils.PageHeading title="Payment settings" />
    </div>
    <div className={`flex flex-col`}>
      <ProfileInfoHeader businessProfileRecoilVal profileId merchantId />
      <Tabs tabs initialIndex={tabIndex} onTitleClick={index => setTabIndex(_ => index)} />
    </div>
  </div>
}
