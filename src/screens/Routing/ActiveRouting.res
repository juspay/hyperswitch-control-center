open RoutingTypes
open RoutingUtils
open Typography
type viewType = Loading | Error(string) | Loaded
module TopLeftIcons = {
  @react.component
  let make = (~routeType: routingType) => {
    switch routeType {
    | DEFAULTFALLBACK => <Icon name="fallback" size=25 className="w-11" />
    | VOLUME_SPLIT => <Icon name="processorLevel" size=25 className="w-14" />
    | ADVANCED => <Icon name="parameterLevel" size=25 className="w-20" />
    | _ => React.null
    }
  }
}
module TopRightIcons = {
  @react.component
  let make = (~routeType: routingType) => {
    switch routeType {
    | VOLUME_SPLIT => <Icon name="quickSetup" size=25 className="w-28" />
    | _ => React.null
    }
  }
}
module ActionButtons = {
  @react.component
  let make = (~routeType: routingType, ~onRedirectBaseUrl) => {
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()

    switch routeType {
    | VOLUME_SPLIT
    | ADVANCED =>
      <ACLButton
        text={"Setup"}
        authorization={userHasAccess(~groupAccess=WorkflowsManage)}
        customButtonStyle="w-28"
        buttonType={Secondary}
        buttonSize=Small
        onClick={_ => {
          RescriptReactRouter.push(
            GlobalVars.appendDashboardPath(
              ~url=`/${onRedirectBaseUrl}/${routingTypeName(routeType)}`,
            ),
          )
          mixpanelEvent(~eventName=`${onRedirectBaseUrl}_setup_${routeType->routingTypeName}`)
        }}
      />
    | DEFAULTFALLBACK =>
      <ACLButton
        text={"Manage"}
        authorization={userHasAccess(~groupAccess=WorkflowsManage)}
        buttonType={Secondary}
        customButtonStyle="w-28"
        buttonSize=Small
        onClick={_ => {
          RescriptReactRouter.push(
            GlobalVars.appendDashboardPath(
              ~url=`/${onRedirectBaseUrl}/${routingTypeName(routeType)}`,
            ),
          )
          mixpanelEvent(~eventName=`${onRedirectBaseUrl}_setup_${routeType->routingTypeName}`)
        }}
      />

    | _ => React.null
    }
  }
}

module ActiveSection = {
  @react.component
  let make = (~activeRouting, ~activeRoutingId, ~onRedirectBaseUrl) => {
    open LogicUtils
    let {debitRouting} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
    let activeRoutingType =
      activeRouting->getDictFromJsonObject->getString("kind", "")->routingTypeMapper
    let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
    let debitRoutingValue =
      (
        HyperswitchAtom.businessProfileFromIdAtom->Recoil.useRecoilValueFromAtom
      ).is_debit_routing_enabled->Option.getOr(false)
    let routingName = switch activeRoutingType {
    | DEFAULTFALLBACK => ""
    | _ => `${activeRouting->getDictFromJsonObject->getString("name", "")->capitalizeString} - `
    }

    let profileId = activeRouting->getDictFromJsonObject->getString("profile_id", "")
    <div className="flex flex-col sm:flex-row gap-8">
      <div className="relative flex flex-1 flex-col bg-white border rounded-lg p-4 pt-10 gap-8">
        <div className=" flex flex-1 flex-col gap-7">
          <div
            className="absolute top-0 left-0 flex items-center w-fit bg-green-200 text-green-800 py-1 px-2 rounded-tl-lg rounded-br-md">
            <Icon name="check" size={8} className="mr-1" />
            <span className={`${body.sm.semibold}`}> {"Active"->React.string} </span>
          </div>
          <div className={"flex flex-col gap-3"}>
            <p className={`text-nd_gray-600 ${body.md.semibold} w-full whitespace-normal`}>
              {`${routingName}${getContent(activeRoutingType).heading}`->React.string}
            </p>
            <RenderIf condition={profileId->isNonEmptyString}>
              <div
                className={`flex gap-2 ${body.md.regular} text-lightgray_background  opacity-50`}>
                <HelperComponents.ProfileNameComponent
                  profile_id={profileId} className="text-nd_gray-600"
                />
                <p> {`: ${profileId}`->React.string} </p>
              </div>
            </RenderIf>
          </div>
        </div>
        <ACLButton
          authorization={userHasAccess(~groupAccess=WorkflowsManage)}
          text="Manage"
          buttonType=Secondary
          customButtonStyle="w-4/3"
          buttonSize={Small}
          onClick={_ => {
            switch activeRoutingType {
            | DEFAULTFALLBACK =>
              RescriptReactRouter.push(
                GlobalVars.appendDashboardPath(
                  ~url=`/${onRedirectBaseUrl}/${routingTypeName(activeRoutingType)}`,
                ),
              )
            | _ =>
              RescriptReactRouter.push(
                GlobalVars.appendDashboardPath(
                  ~url=`/${onRedirectBaseUrl}/${routingTypeName(
                      activeRoutingType,
                    )}?id=${activeRoutingId}&isActive=true`,
                ),
              )
            }
          }}
        />
      </div>
      <RenderIf condition={debitRoutingValue && debitRouting}>
        <DebitRoutingActiveCard profileId />
      </RenderIf>
    </div>
  }
}

module LevelWiseRoutingSection = {
  @react.component
  let make = (~types: array<routingType>, ~onRedirectBaseUrl) => {
    let {debitRouting} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
    <div className="flex flex-col flex-wrap rounded w-full py-6 gap-5">
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-9">
        {types
        ->Array.mapWithIndex((value, index) =>
          <div
            key={index->Int.toString}
            className="flex flex-1 flex-col bg-white border rounded-lg p-4 gap-8">
            <div className="flex flex-1 flex-col gap-7">
              <div className="flex w-full items-center flex-wrap justify-between">
                <TopLeftIcons routeType=value />
                <TopRightIcons routeType=value />
              </div>
              <div className="flex flex-1 flex-col gap-3 text-nd_gray-600">
                <p className={`${body.md.semibold}`}> {getContent(value).heading->React.string} </p>
                <p className={`${body.md.medium} opacity-50`}>
                  {getContent(value).subHeading->React.string}
                </p>
              </div>
            </div>
            <ActionButtons routeType=value onRedirectBaseUrl />
          </div>
        )
        ->React.array}
        <RenderIf condition={debitRouting}>
          <DebitRouting />
        </RenderIf>
      </div>
    </div>
  }
}

@react.component
let make = (~routingType: array<JSON.t>) => {
  <div className="mt-8 flex flex-col gap-6">
    {routingType
    ->Array.mapWithIndex((ele, i) => {
      let id = ele->LogicUtils.getDictFromJsonObject->LogicUtils.getString("id", "")
      <ActiveSection
        key={i->Int.toString} activeRouting={ele} activeRoutingId={id} onRedirectBaseUrl="routing"
      />
    })
    ->React.array}
  </div>
}
