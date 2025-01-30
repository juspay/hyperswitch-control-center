open RoutingTypes
open RoutingUtils

type viewType = Loading | Error(string) | Loaded
module TopLeftIcons = {
  @react.component
  let make = (~routeType: routingType) => {
    switch routeType {
    | PRIORITY | DEFAULTFALLBACK => <Icon name="fallback" size=25 className="w-11" />
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
    | VOLUME_SPLIT | PRIORITY => <Icon name="quickSetup" size=25 className="w-28" />
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
    | PRIORITY
    | VOLUME_SPLIT
    | ADVANCED =>
      <ACLButton
        text={"Setup"}
        authorization={userHasAccess(~groupAccess=WorkflowsManage)}
        buttonType=Primary
        buttonSize=Small
        onClick={_ => {
          RescriptReactRouter.push(
            GlobalVars.appendDashboardPath(
              ~url=`/${onRedirectBaseUrl}/${routingTypeName(routeType)}`,
            ),
          )
          mixpanelEvent(~eventName=`routing_setup_${routeType->routingTypeName}`)
        }}
      />
    | DEFAULTFALLBACK =>
      <ACLButton
        text={"Manage"}
        authorization={userHasAccess(~groupAccess=WorkflowsManage)}
        buttonType=Primary
        buttonSize=Small
        onClick={_ => {
          RescriptReactRouter.push(
            GlobalVars.appendDashboardPath(
              ~url=`/${onRedirectBaseUrl}/${routingTypeName(routeType)}`,
            ),
          )
          mixpanelEvent(~eventName=`routing_setup_${routeType->routingTypeName}`)
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
    let activeRoutingType =
      activeRouting->getDictFromJsonObject->getString("kind", "")->routingTypeMapper
    let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()

    let routingName = switch activeRoutingType {
    | DEFAULTFALLBACK => ""
    | _ => `${activeRouting->getDictFromJsonObject->getString("name", "")->capitalizeString} - `
    }

    let profileId = activeRouting->getDictFromJsonObject->getString("profile_id", "")
    let {profile_name} = BusinessProfileHook.useGetBusinessProflile(profileId)
    <>
      <div className="font-bold text-black mt-2 text-lg">
        {"Current Active Configurations"->React.string}
      </div>
      <div className="relative flex flex-col flex-wrap bg-white border rounded w-full px-6 pt-3 ">
        <div className="flex flex-row justify-between">
          <div className="flex flex-col my-2">
            <div className="flex align-center">
              <p className="text-jp-gray-900 font-semibold">
                {`${routingName}${getContent(activeRoutingType).heading}`->React.string}
              </p>
            </div>
            <RenderIf condition={profileId->isNonEmptyString}>
              <div className="flex gap-2 mt-2 ">
                <div className="font-semibold text-sm text-jp-gray-800">
                  {"Profile:"->React.string}
                </div>
                <div className="flex flex-row text-lightgray_background opacity-50 text-sm">
                  <HelperComponents.CopyTextCustomComp
                    displayValue={profile_name}
                    customTextCss="font-semibold text-jp-gray-800 "
                    customParentClass="flex items-center gap-2"
                  />
                </div>
              </div>
            </RenderIf>
          </div>
          <div className="gap-5 pt-2 w-1/4">
            <ACLButton
              authorization={userHasAccess(~groupAccess=WorkflowsManage)}
              text="Manage"
              buttonType=Secondary
              customButtonStyle="w-2/3"
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
        </div>
      </div>
    </>
  }
}

module LevelWiseRoutingSection = {
  @react.component
  let make = (~types: array<routingType>, ~onRedirectBaseUrl) => {
    <div className="flex flex-col flex-wrap  rounded w-full  gap-5">
      <div className="flex flex-wrap justify-evenly gap-9 items-stretch">
        {types
        ->Array.mapWithIndex((value, index) =>
          <div
            key={index->Int.toString}
            className="flex flex-1 flex-col  bg-white border rounded px-5 pb-3 gap-8">
            <div className="flex flex-1 flex-col gap-7">
              <div className="flex w-full items-center flex-wrap justify-between " />
              <div className="flex flex-1 flex-col gap-3">
                <p className="text-base font-semibold text-lightgray_background">
                  {getContent(value).heading->React.string}
                </p>
                <p className="text-fs-14 font-medium opacity-50 text-lightgray_background">
                  {getContent(value).subHeading->React.string}
                </p>
              </div>
            </div>
            <ActionButtons routeType=value onRedirectBaseUrl />
          </div>
        )
        ->React.array}
      </div>
    </div>
  }
}

@react.component
let make = (~routingType: array<JSON.t>) => {
  <div className="mt-4 flex flex-col gap-2">
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
