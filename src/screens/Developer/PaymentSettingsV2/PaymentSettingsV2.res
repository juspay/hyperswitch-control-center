module InfoViewForWebhooks = {
  @react.component
  let make = (~heading, ~subHeading, ~isCopy=false, ~isTruncated=false, ~copyValue="") => {
    let showToast = ToastState.useShowToast()
    let onCopyClick = ev => {
      ev->ReactEvent.Mouse.stopPropagation
      Clipboard.writeText(isTruncated ? copyValue : subHeading)
      showToast(~message="Copied to Clipboard!", ~toastType=ToastSuccess)
    }

    <div className={`flex flex-col gap-2 m-2 md:m-4 w-1/3`}>
      <p className="font-medium text-fs-14 text-nd_gray-400"> {heading->React.string} </p>
      <div className="flex gap-2 break-all w-full items-start">
        <p className="font-medium text-fs-16 text-nd_gray-600 "> {subHeading->React.string} </p>
        <RenderIf condition={isCopy}>
          <Icon
            name="nd-copy"
            className="cursor-pointer"
            onClick={ev => {
              onCopyClick(ev)
            }}
          />
        </RenderIf>
      </div>
    </div>
  }
}
@react.component
let make = () => {
  open HyperswitchAtom

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

  let hashKeyVal = businessProfileRecoilVal.payment_response_hash_key->Option.getOr("NA")
  let truncatedHashKey = `${hashKeyVal->String.slice(~start=0, ~end=20)}....`

  <div className="flex flex-col gap-8">
    <div className="flex flex-col gap-2">
      <PageUtils.PageHeading
        title="Payment settings"
        subTitle="Set up and monitor transaction webhooks for real-time notifications."
      />
    </div>
    <div className={`flex flex-col`}>
      <div className="flex">
        <InfoViewForWebhooks
          heading="Profile Name" subHeading=businessProfileRecoilVal.profile_name
        />
        <InfoViewForWebhooks heading="Profile ID" subHeading=profileId isCopy=true />
      </div>
      <div className="flex ">
        <InfoViewForWebhooks heading="Merchant ID" subHeading=merchantId />
        <InfoViewForWebhooks
          heading="Payment Response Hash Key"
          subHeading={truncatedHashKey}
          isCopy=true
          isTruncated=true
          copyValue=hashKeyVal
        />
      </div>
      <Tabs
        tabs
        showBorder=true
        includeMargin=false
        initialIndex={tabIndex}
        onTitleClick={index => setTabIndex(_ => index)}
        selectTabBottomBorderColor="bg-nd_primary_blue-500"
      />
    </div>
  </div>
}
