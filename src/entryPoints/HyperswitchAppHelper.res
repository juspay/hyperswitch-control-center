module LiveMode = {
  @react.component
  let make = () => {
    let isLiveMode = (HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom).isLiveMode

    <>
      <RenderIf condition={isLiveMode}>
        <div
          className="flex flex-row items-center px-2 py-3 gap-2 whitespace-nowrap cursor-default justify-between h-8 bg-white border rounded-lg  text-sm text-nd_gray-500 border-nd_gray-300">
          <span className="relative flex h-2 w-2">
            <span
              className="animate-ping absolute inline-flex h-full w-full rounded-full bg-hyperswitch_green opacity-75"
            />
            <span className="relative inline-flex rounded-full h-2 w-2 bg-hyperswitch_green" />
          </span>
          <span className="font-semibold"> {"Live Mode"->React.string} </span>
        </div>
      </RenderIf>
    </>
  }
}

module TestMode = {
  @react.component
  let make = () => {
    let isLiveMode = (HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom).isLiveMode
    let {roleId} = React.useContext(UserInfoProvider.defaultContext).getResolvedUserInfo()
    let isInternalUser = roleId->HyperSwitchUtils.checkIsInternalUser

    let showTestMode = !isLiveMode && !isInternalUser

    <RenderIf condition={showTestMode}>
      <div
        className="absolute w-fit max-w-fixedPageWidth bg-white flex flex-col items-center -top-11">
        <div
          className="bg-nd_orange-100 px-4 py-[6px] rounded-br-md rounded-bl-md w-fit flex gap-2 items-center">
          <Icon name="nd-toast-info" size=14 customIconColor="text-nd_yellow-200 text-fs-12" />
          <p className="text-nd_yellow-200 text-base leading-5 font-medium text-nowrap">
            {"You're in Test Mode"->React.string}
          </p>
          <GetProductionAccess />
        </div>
      </div>
    </RenderIf>
  }
}

// Home of the unified dashboard plus the home/overview landing of every product
let isHomeOrOverviewPath = (path: list<string>) =>
  switch path {
  | list{"v2", "home"}
  | list{"home"}
  | list{"v2", "orchestration", "home"}
  | list{"v2", "recon", "overview"}
  | list{"v1", "recon-engine", "overview"}
  | list{"v2", "recovery"}
  | list{"v2", "recovery", "invoices"}
  | list{"v2", "vault", "home"}
  | list{"v2", "cost-observability", "home"}
  | list{"v2", "dynamic-routing"} => true
  | _ => false
  }

module MaintenanceAlert = {
  @react.component
  let make = (~message) => {
    let url = RescriptReactRouter.useUrl()
    let showAlert =
      message->LogicUtils.isNonEmptyString && url.path->HSwitchUtils.urlPath->isHomeOrOverviewPath

    <RenderIf condition={showAlert}>
      <div className="w-full">
        <AlertV2Binding
          alertType=Primary
          slot={{
            slot: <Icon name="nd-toast-info" size=20 className="text-nd_primary_blue-450" />,
          }}
          description=message
        />
      </div>
    </RenderIf>
  }
}
