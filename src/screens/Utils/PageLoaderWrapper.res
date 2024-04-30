type viewType = Loading | Error(string) | Success | Custom

@react.component
let make = (
  ~children=?,
  ~screenState: viewType,
  ~customUI=?,
  ~sectionHeight="h-80-vh",
  ~customStyleForDefaultLandingPage="",
  ~customLoader=?,
) => {
  let {branding} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let loaderLottieFile = LottieFiles.useLottieJson("hyperswitch_loader.json")
  switch screenState {
  | Loading =>
    switch customLoader {
    | Some(loader) => loader
    | _ =>
      <div className={`${sectionHeight} w-scrren flex flex-col justify-center items-center`}>
        <UIUtils.RenderIf condition={!branding}>
          <div className="w-20 h-16">
            <ReactSuspenseWrapper>
              <div className="scale-400 pt-px">
                <Lottie animationData={loaderLottieFile} autoplay=true loop=true />
              </div>
            </ReactSuspenseWrapper>
          </div>
        </UIUtils.RenderIf>
        <UIUtils.RenderIf condition={branding}>
          <Loader />
        </UIUtils.RenderIf>
      </div>
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
