@react.component
let make = (~onRedirectBaseUrl) => {
  open LogicUtils
  open Typography
  let (showLeastCostModal, setShowLeastCostModal) = React.useState(_ => false)
  let (showManageModal, setShowManageModal) = React.useState(_ => false)
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let {userInfo: {profileId}} = React.useContext(UserInfoProvider.defaultContext)
  let fetchBusinessProfileFromId = BusinessProfileHook.useFetchBusinessProfileFromId()
  let (debitRouting, setDebitRouting) = React.useState(_ => false)
  // let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let handleButtonClick = _ => {
    if debitRouting {
      setShowManageModal(_ => true)
    } else {
      setShowLeastCostModal(_ => true)
    }
  }
  let fetchBusinessProfileData = async () => {
    try {
      // setScreenState(_ => PageLoaderWrapper.Loading)
      let res = await fetchBusinessProfileFromId(~profileId=Some(profileId))
      let dict = res->getDictFromJsonObject
      let isEnabled = dict->LogicUtils.getBool("is_debit_routing_enabled", false)
      setDebitRouting(_ => isEnabled)
      // setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => ()
    //  setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch data"))
    }
  }
  let buttonText = debitRouting ? "Manage" : "Setup"
  React.useEffect(() => {
    fetchBusinessProfileData()->ignore
    None
  }, [profileId])
  // <PageLoaderWrapper screenState>
  <div className="flex flex-1 flex-col bg-white border rounded px-5 py-5 gap-8">
    <div className="flex flex-1 flex-col gap-7">
      <div className="flex w-full items-center flex-wrap justify-between">
        <Icon name="leastCostRouting" size=15 className="w-20" />
      </div>
      <div className="flex flex-1 flex-col gap-3">
        <p className={`${body.md.semibold} text-lightgray_background`}>
          {"Least Cost Routing Configuration"->React.string}
        </p>
        <p className={`${body.md.medium} opacity-50 text-lightgray_background`}>
          {"Optimize processing fees on debit payments by routing traffic to the cheapest network"->React.string}
        </p>
      </div>
    </div>
    <ACLButton
      text={buttonText}
      authorization={userHasAccess(~groupAccess=WorkflowsManage)}
      customButtonStyle="mx-auto w-full"
      buttonType={Secondary}
      buttonSize=Small
      onClick={_ => {
        handleButtonClick()
        mixpanelEvent(~eventName=`${onRedirectBaseUrl}_setup_leastcost`)
      }}
    />
    <DebitRoutingConfigureModal showModal=showLeastCostModal setShowModal=setShowLeastCostModal />
    <DebitRoutingDeactivateModal showModal=showManageModal setShowModal=setShowManageModal />
  </div>
  // </PageLoaderWrapper>
}
