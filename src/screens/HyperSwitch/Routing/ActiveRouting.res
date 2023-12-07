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
    | COST => <Icon name="costLevel" size=25 className="w-14" />
    | _ => React.null
    }
  }
}
module TopRightIcons = {
  @react.component
  let make = (~routeType: routingType) => {
    switch routeType {
    | VOLUME_SPLIT | PRIORITY => <Icon name="quickSetup" size=25 className="w-28" />
    | COST => <Icon name="comingSoon" size=35 className="!w-40" />
    | _ => React.null
    }
  }
}
module ActionButtons = {
  @react.component
  let make = (~routeType: routingType) => {
    let url = RescriptReactRouter.useUrl()
    let hyperswitchMixPanel = HSMixPanel.useSendEvent()
    let showToast = ToastState.useShowToast()
    let updateDetails = APIUtils.useUpdateMethod(~showErrorToast=false, ())

    let handleSubmitRequest = async _ => {
      try {
        let requestBody =
          [
            ("rating", 5.0->Js.Json.number),
            ("category", "Routing request"->Js.Json.string),
            ("feedbacks", `Request for Cost based Routing`->Js.Json.string),
          ]
          ->Js.Dict.fromArray
          ->Js.Json.object_

        let body = requestBody->HSwitchUtils.getBodyForFeedBack()
        let feedbackUrl = APIUtils.getURL(~entityName=FEEDBACK, ~methodType=Post, ())
        let _res = await updateDetails(feedbackUrl, body->Js.Json.object_, Post)
        showToast(
          ~toastType=ToastSuccess,
          ~message="Request submitted successfully!",
          ~autoClose=false,
          (),
        )
      } catch {
      | Js.Exn.Error(_e) =>
        showToast(~message="Failed to submit request !", ~toastType=ToastState.ToastError, ())
      }
    }

    switch routeType {
    | PRIORITY
    | VOLUME_SPLIT
    | ADVANCED =>
      <Button
        text={"Setup"}
        buttonType=Secondary
        buttonSize={Small}
        customButtonStyle="border !border-blue-700 bg-white !text-blue-700"
        onClick={_ => {
          RescriptReactRouter.push(`routing/${routingTypeName(routeType)}`)
          hyperswitchMixPanel(
            ~pageName=`${url.path->LogicUtils.getListHead}_active`,
            ~contextName=`${routeType->routingTypeName}based`,
            ~actionName="setup",
            (),
          )
        }}
      />
    | DEFAULTFALLBACK =>
      <Button
        text={"Manage"}
        buttonType=Secondary
        customButtonStyle="border !border-blue-700 bg-white !text-blue-700"
        buttonSize={Small}
        onClick={_ => {
          RescriptReactRouter.push(`routing/${routingTypeName(routeType)}`)
          hyperswitchMixPanel(
            ~pageName=`${url.path->LogicUtils.getListHead}_active`,
            ~contextName=`${routeType->routingTypeName}`,
            ~actionName="manage",
            (),
          )
        }}
      />

    | COST =>
      <Button
        text={"I'm interested"}
        buttonType=Secondary
        buttonSize={Small}
        customButtonStyle="!w-fit !px-14"
        onClick={_ => handleSubmitRequest()->ignore}
      />
    | _ => React.null
    }
  }
}
module DefaultSection = {
  @react.component
  let make = () => {
    <div className="relative flex flex-col flex-wrap bg-white  rounded w-full gap-5">
      <div className="text-lightgray_background font-semibold text-base">
        {getContent(DEFAULTFALLBACK).heading->React.string}
      </div>
      <div className="text-lightgray_background font-medium text-base opacity-50 text-fs-14 ">
        {getContent(DEFAULTFALLBACK).subHeading->React.string}
      </div>
      <div className="flex gap-5 w-1/4 ">
        <ActionButtons routeType={DEFAULTFALLBACK} />
      </div>
    </div>
  }
}
module ActiveSection = {
  @react.component
  let make = (~activeRouting, ~activeRoutingId) => {
    open LogicUtils
    let hyperswitchMixPanel = HSMixPanel.useSendEvent()
    let url = RescriptReactRouter.useUrl()
    let activeRoutingType =
      activeRouting->getDictFromJsonObject->getString("kind", "")->routingTypeMapper

    let routingName = switch activeRoutingType {
    | DEFAULTFALLBACK => ""
    | _ => `${activeRouting->getDictFromJsonObject->getString("name", "")->capitalizeString} - `
    }

    let profileId = activeRouting->getDictFromJsonObject->getString("profile_id", "")

    <div
      className="relative flex flex-col flex-wrap bg-white border rounded w-full px-6 py-10 gap-12">
      <div>
        <div
          className="absolute top-0 left-0 bg-green-800 text-white py-2 px-4 rounded-br font-semibold">
          {"ACTIVE"->React.string}
        </div>
        <div className="flex flex-col my-6 pt-4 gap-2">
          <div className=" flex gap-4  align-center">
            <p className="text-lightgray_background font-semibold text-base">
              {`${routingName}${getContent(activeRoutingType).heading}`->React.string}
            </p>
            <Icon name="primary-tag" size=25 className="w-20" />
          </div>
          <UIUtils.RenderIf condition={profileId->Js.String2.length > 0}>
            <div className="flex gap-2">
              <MerchantAccountUtils.BusinessProfile
                profile_id={profileId}
                className="text-lightgray_background text-base opacity-50 text-sm"
              />
              <p className="text-lightgray_background text-base opacity-50 text-sm">
                {`: ${profileId}`->React.string}
              </p>
            </div>
          </UIUtils.RenderIf>
        </div>
        <div className="text-lightgray_background font-medium text-base opacity-50 text-fs-14 ">
          {`${getContent(activeRoutingType).heading} : ${getContent(
              activeRoutingType,
            ).subHeading}`->React.string}
        </div>
        <div className="flex gap-5 pt-6 w-1/4">
          <Button
            text="Manage"
            buttonType=Secondary
            customButtonStyle="w-2/3"
            buttonSize={Small}
            onClick={_ => {
              switch activeRoutingType {
              | DEFAULTFALLBACK =>
                RescriptReactRouter.push(`routing/${routingTypeName(activeRoutingType)}`)
              | _ =>
                RescriptReactRouter.push(
                  `routing/${routingTypeName(
                      activeRoutingType,
                    )}?id=${activeRoutingId}&isActive=true`,
                )
              }
              hyperswitchMixPanel(
                ~pageName=`${url.path->LogicUtils.getListHead}_active`,
                ~contextName=`${activeRoutingType->routingTypeName}`,
                ~actionName="manage",
                (),
              )
            }}
          />
        </div>
      </div>
    </div>
  }
}

module LevelWiseRoutingSection = {
  @react.component
  let make = (~types: array<routingType>) => {
    <div className="flex flex-col flex-wrap  rounded w-full py-6 gap-5">
      <div className="flex flex-wrap justify-evenly gap-9 items-stretch">
        {types
        ->Array.mapWithIndex((value, index) =>
          <div
            key={index->string_of_int}
            className="flex flex-1 flex-col  bg-white border rounded px-5 py-5 gap-8">
            <div className="flex flex-1 flex-col gap-7">
              <div className="flex w-full items-center flex-wrap justify-between ">
                <TopLeftIcons routeType=value />
                <TopRightIcons routeType=value />
              </div>
              <div className="flex flex-1 flex-col gap-3">
                <p className="text-base font-semibold text-lightgray_background">
                  {getContent(value).heading->React.string}
                </p>
                <p className="text-fs-14 font-medium opacity-50 text-lightgray_background">
                  {getContent(value).subHeading->React.string}
                </p>
              </div>
            </div>
            <ActionButtons routeType=value />
          </div>
        )
        ->React.array}
      </div>
    </div>
  }
}

@react.component
let make = (~routingType: array<Js.Json.t>) => {
  <div className="mt-4 flex flex-col gap-6">
    {routingType
    ->Array.mapWithIndex((ele, i) => {
      let id = ele->LogicUtils.getDictFromJsonObject->LogicUtils.getString("id", "")
      <ActiveSection key={i->string_of_int} activeRouting={ele} activeRoutingId={id} />
    })
    ->React.array}
  </div>
}
