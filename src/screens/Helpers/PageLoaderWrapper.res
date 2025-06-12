@unboxed
type viewType = Loading | Error(string) | Success | Custom

module ScreenLoader = {
  @react.component
  let make = (~sectionHeight="h-80-vh") => {
    let loaderLottieFile = LottieFiles.useLottieJson("hyperswitch_loader.json")
    let loader = LottieFiles.useLottieJson("loader-circle.json")
    let themeId = HyperSwitchEntryUtils.getThemeIdfromStore()
    let {branding} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
    let showLoader = themeId->Option.getOr("")->LogicUtils.isNonEmptyString
    <div className={`${sectionHeight} flex flex-col justify-center items-center`}>
      <RenderIf condition={!branding}>
        <ReactSuspenseWrapper>
          <Lottie
            animationData={showLoader ? loader : loaderLottieFile}
            autoplay=true
            loop=true
            style={{height: 300, width: 300, transform: "unset"}}
          />
        </ReactSuspenseWrapper>
      </RenderIf>
      <RenderIf condition={branding}>
        <Loader />
      </RenderIf>
    </div>
  }
}

@react.component
let make = (
  ~children=?,
  ~screenState: viewType,
  ~customUI=?,
  ~sectionHeight="h-80-vh",
  ~customStyleForDefaultLandingPage="",
  ~customLoader=?,
  ~showLogoutButton=false,
) => {
  switch screenState {
  | Loading =>
    switch customLoader {
    | Some(loader) => loader
    | _ => <ScreenLoader sectionHeight />
    }
  | Error(_err) =>
    <DefaultLandingPage
      title="Oops, we hit a little bump on the road!"
      customStyle={`py-16 !m-0 ${customStyleForDefaultLandingPage} ${sectionHeight}`}
      overriddingStylesTitle="text-2xl font-semibold"
      buttonText="Refresh"
      overriddingStylesSubtitle="!text-sm text-grey-700 opacity-50 !w-3/4"
      subtitle="We apologize for the inconvenience, but it seems like we encountered a hiccup while processing your request."
      onClickHandler={_ => Window.Location.hardReload(true)}
      isButton=true
      showLogoutButton
    />
  | Success =>
    switch children {
    | Some(ui) => ui
    | None => React.null
    }

  | Custom =>
    switch customUI {
    | Some(ui) => ui
    | None => React.null
    }
  }
}
