open Window

@react.component
let make = () => {
  let (viewType, setViewType) = React.useState(_ => HSwitchSDKUtils.DemoApp)
  let (isShowFilters, setIsShowFilters) = React.useState(_ => true)
  let (isShowTestCards, setIsShowTestCards) = React.useState(_ => true)

  React.useEffect1(() => {
    let windowUrl = urlSearch(location.href)

    let paramViewType = windowUrl.searchParams.get(. "viewType")->Js.Json.decodeString
    let paramIsShowFilters = windowUrl.searchParams.get(. "isShowFilters")->Js.Json.decodeString
    let paramIsShowTestCards = windowUrl.searchParams.get(. "isShowTestCards")->Js.Json.decodeString

    switch paramViewType {
    | Some(val) =>
      switch val->Js.String2.toLowerCase {
      | "demoapp" => setViewType(_ => HSwitchSDKUtils.DemoApp)
      | "sdkpreview" => setViewType(_ => HSwitchSDKUtils.SdkPreview)
      | _ => setViewType(_ => HSwitchSDKUtils.DemoApp)
      }
    | None => ()
    }

    switch paramIsShowFilters {
    | Some(val) =>
      switch val->Js.String2.toLowerCase {
      | "true" => setIsShowFilters(_ => true)
      | "false" => setIsShowFilters(_ => false)
      | _ => setIsShowFilters(_ => true)
      }
    | None => ()
    }

    switch paramIsShowTestCards {
    | Some(val) =>
      switch val->Js.String2.toLowerCase {
      | "true" => setIsShowTestCards(_ => true)
      | "false" => setIsShowTestCards(_ => false)
      | _ => setIsShowTestCards(_ => true)
      }
    | None => ()
    }

    None
  }, [location.href])

  <div>
    <Recoil.RecoilRoot>
      {switch viewType {
      | HSwitchSDKUtils.DemoApp =>
        <HSwitchDemoAppPreview isShowFilters isShowTestCards>
          <HyperswitchSDK viewType />
        </HSwitchDemoAppPreview>
      | HSwitchSDKUtils.SdkPreview =>
        <HSwitchSdkPreview isShowFilters isShowTestCards>
          <HyperswitchSDK viewType />
        </HSwitchSdkPreview>
      }}
    </Recoil.RecoilRoot>
  </div>
}
