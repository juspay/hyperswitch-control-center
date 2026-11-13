@react.component
let make = (~createMerchant) => {
  open Typography

  let mixpanelEvent = MixpanelHook.useSendEvent()
  let {setCreateNewMerchant, activeProduct} = React.useContext(
    ProductSelectionProvider.defaultContext,
  )
  let userHasCreateMerchantAccess = OMPCreateAccessHook.useOMPCreateAccessHook([
    #tenant_admin,
    #org_admin,
  ])
  let {devRecoveryExternalTrigger} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {merchantId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  let (showModelSelection, setShowModelSelection) = React.useState(_ => false)

  let goToTriggerModelRoute = model =>
    RescriptReactRouter.replace(
      GlobalVars.appendDashboardPath(~url=model->RevenueRecoveryProfileUtils.getTriggerModelRoute),
    )

  let startOnboarding = (model: RevenueRecoveryProfileTypes.triggerModel) => {
    if createMerchant {
      mixpanelEvent(~eventName="recovery_get_started_new_merchant")
      if devRecoveryExternalTrigger {
        SessionStorage.sessionStorage.setItem(
          RevenueRecoveryProfileUtils.pendingTriggerModelKey,
          (model :> string),
        )
        SessionStorage.sessionStorage.setItem(
          RevenueRecoveryProfileUtils.pendingTriggerModelMerchantKey,
          merchantId,
        )
      }
      setCreateNewMerchant(ProductTypes.Recovery)
    } else {
      mixpanelEvent(~eventName="recovery_get_started")
      goToTriggerModelRoute(model)
    }
  }

  let clearPendingTriggerModel = () => {
    SessionStorage.sessionStorage.removeItem(RevenueRecoveryProfileUtils.pendingTriggerModelKey)
    SessionStorage.sessionStorage.removeItem(
      RevenueRecoveryProfileUtils.pendingTriggerModelMerchantKey,
    )
  }

  React.useEffect(() => {
    if devRecoveryExternalTrigger && !createMerchant {
      let pendingModel =
        SessionStorage.sessionStorage.getItem(RevenueRecoveryProfileUtils.pendingTriggerModelKey)
        ->Nullable.toOption
        ->Option.map(RevenueRecoveryProfileUtils.getTriggerModelFromString)
      clearPendingTriggerModel()
      pendingModel->Option.forEach(goToTriggerModelRoute)
    }
    None
  }, [])

  React.useEffect(() => {
    let choiceMerchantId =
      SessionStorage.sessionStorage.getItem(
        RevenueRecoveryProfileUtils.pendingTriggerModelMerchantKey,
      )->Nullable.toOption
    switch activeProduct {
    | OnBoarding(_) => ()
    | _ =>
      if choiceMerchantId == Some(merchantId) {
        clearPendingTriggerModel()
      }
    }
    None
  }, [activeProduct])

  <>
    <RenderIf condition={showModelSelection}>
      <RevenueRecoveryModelSelection
        authorization=userHasCreateMerchantAccess
        onBack={() => setShowModelSelection(_ => false)}
        onContinue=startOnboarding
      />
    </RenderIf>
    <RenderIf condition={!showModelSelection}>
      <div className="flex flex-1 flex-col gap-6 items-center w-full">
        <object
          type_="image/svg+xml"
          data="/assets/RevenueRecoveryHomePreview.svg"
          className="w-full max-w-4xl h-auto flex-shrink-0 rounded-2xl"
          ariaLabel="Revenue Recovery Dashboard Preview"
        />
        <div className="flex flex-col gap-4 items-center">
          <div className="flex flex-col gap-2 items-center">
            <p className={`${heading.md.bold} text-center text-nd_gray-700`}>
              {"Recover Lost Revenue & Minimize Churn"->React.string}
            </p>
            <p className={`${body.md.regular} text-center text-nd_gray-500 max-w-3xl`}>
              {"Harness smart retry strategies to automatically recover failed payments and protect your subscription revenue."->React.string}
            </p>
          </div>
          <ACLButton
            authorization={userHasCreateMerchantAccess}
            text="Explore Recovery"
            onClick={_ => {
              if devRecoveryExternalTrigger {
                setShowModelSelection(_ => true)
              } else {
                startOnboarding(RevenueRecoveryProfileTypes.InternalTriggers)
              }
            }}
            buttonType=Primary
            buttonSize=Large
            buttonState=Normal
          />
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-x-10 gap-y-6 w-full max-w-2xl mt-2">
          {RevenueRecoveryOnboardingUtils.features
          ->Array.map(feature => {
            <div
              key=feature.title
              className="flex flex-row gap-3 items-start md:last:col-span-2 md:last:justify-self-center md:last:w-[calc(50%-1.25rem)]">
              <div
                className={`${feature.bgColor} rounded-xl w-12 h-12 flex-shrink-0 flex items-center justify-center`}>
                <Icon
                  name=feature.icon
                  size=28
                  className=feature.iconColor
                  parentClass="w-full h-full flex items-center justify-center"
                />
              </div>
              <div className="flex flex-col gap-0.5">
                <p className={`${body.md.semibold} text-nd_gray-700`}>
                  {feature.title->React.string}
                </p>
                <p className={`${body.sm.regular} text-nd_gray-500`}>
                  {feature.description->React.string}
                </p>
              </div>
            </div>
          })
          ->React.array}
        </div>
      </div>
    </RenderIf>
  </>
}
