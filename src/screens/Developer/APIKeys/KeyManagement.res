@react.component
let make = () => {
  open KeyManagementHelper

  let {userHasAccess, hasAnyGroupAccess} = GroupACLHooks.useUserGroupACLHook()
  let (isCurrentMerchantPlatform, isCurrentOrganizationPlatform) = OMPSwitchHooks.useOMPType()
  let mixpanelEvent = MixpanelHook.useSendEvent()

  let redirectToDocs = _ => {
    mixpanelEvent(~eventName="api_keys_banner_learn_more")
    Window._open(DeveloperUtils.platformDocsUrl)
  }

  let bannerText = {
    DeveloperUtils.bannerText(
      ~isPlatformMerchant=isCurrentMerchantPlatform,
      // TODO: Remove `MerchantDetailsManage` permission in future
      ~hasCreateApiKeyAccess=hasAnyGroupAccess(
        userHasAccess(~groupAccess=MerchantDetailsManage),
        userHasAccess(~groupAccess=AccountManage),
      ),
    )
  }

  <div>
    <PageUtils.PageHeading
      title="Keys" subTitle="Manage API keys and credentials for integrated payment services"
    />
    <RenderIf condition={isCurrentOrganizationPlatform}>
      <div className="py-4">
        <AlertV2Binding
          alertType=Warning
          slot={{slot: <Icon name="nd-toast-warning" size=20 className="text-nd_yellow-500" />}}
          heading={isCurrentMerchantPlatform ? "Platform Merchant Account:" : ""}
          description=bannerText
          actions={{
            position: Bottom,
            primaryAction: {
              text: "Learn More",
              onClick: redirectToDocs,
            },
          }}
        />
      </div>
    </RenderIf>
    <ApiKeysTable />
    <PublishableAndHashKeySection />
  </div>
}
