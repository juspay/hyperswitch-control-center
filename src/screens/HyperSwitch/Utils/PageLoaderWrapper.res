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
  switch screenState {
  | Loading =>
    switch customLoader {
    | Some(loader) => loader
    | _ =>
      <div className={`${sectionHeight} w-scrren flex flex-col justify-center items-center`}>
        <Loader />
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
      onClickHandler={_ => Window.Location.reload()}
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
