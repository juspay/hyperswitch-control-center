@react.component
let make = () => {
  open Typography
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
        <HSwitchUtils.AlertBanner
          bannerContent={<p>
            <RenderIf condition={isCurrentMerchantPlatform}>
              <span className={`text-nd_gray-800 ${body.md.semibold}`}>
                {"Platform Merchant Account: "->React.string}
              </span>
            </RenderIf>
            <span className={`text-nd_gray-600 ${body.md.regular}`}>
              {bannerText->React.string}
            </span>
            <span
              onClick={redirectToDocs}
              className={`text-nd_primary_blue-500 hover:cursor-pointer ${body.md.regular}`}>
              {" Learn More"->React.string}
            </span>
          </p>}
          bannerType=Warning
        />
      </div>
    </RenderIf>
    <ApiKeysTable />
    <PublishableAndHashKeySection />
  </div>
}
