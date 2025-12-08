@react.component
let make = (~errorMessage: string) => {
  open Typography
  open FramerMotion.Motion
  open CommonAuthTypes
  let errorText = errorMessage == "" ? "Error: Invalid URL" : errorMessage
  let {branding} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {logoURL} = React.useContext(ThemeProvider.themeContext)
  let (logoVariant, iconUrl) = switch (logoURL, branding) {
  | (Some(url), true) => (IconWithURL, Some(url))
  | (Some(url), false) => (IconWithURL, Some(url))
  | _ => (IconWithText, None)
  }
  <HSwitchUtils.BackgroundImageWrapper
    customPageCss="min-h-screen flex items-center justify-center">
    <div className="w-full max-w-4xl mx-auto ">
      <div className="bg-white border border-nd_gray-100 shadow-sm rounded-lg ">
        <div className="px-7 py-4">
          <Div layoutId="logo">
            <HyperSwitchLogo logoHeight="h-6" theme={Dark} logoVariant iconUrl />
          </Div>
        </div>
        <hr />
        <div className="flex flex-col gap-4 mt-8 mb-20 px-7 text-nd_gray-800">
          <div className={`${heading.xl.semibold}`}>
            {"Access blocked: Authorization Error"->React.string}
          </div>
          <div className={`${body.lg.medium}`}> {errorText->React.string} </div>
        </div>
      </div>
    </div>
  </HSwitchUtils.BackgroundImageWrapper>
}
