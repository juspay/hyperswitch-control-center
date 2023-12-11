%%raw(`require("tailwindcss/tailwind.css")`)
module ContextWrapper = {
  @react.component
  let make = (~children, ~uiConfig) => {
    let loader =
      <div className="flex flex-col py-16 text-center items-center">
        <div className="animate-spin mb-10">
          <Icon name="spinner" size=20 />
        </div>
        {React.string("Loading")}
      </div>
    <React.Suspense fallback={loader}>
      <ErrorBoundary renderFallback={_ => <div> {React.string("Error")} </div>}>
        <Recoil.RecoilRoot>
          <ErrorBoundary>
            <ThemeProvider>
              <PopUpContainer>
                <SnackBarContainer>
                  <ToastContainer>
                    <TokenContextProvider>
                      <UserTimeZoneProvider>
                        <SidebarProvider>
                          <ModalContainer>
                            <ConfigContext value=uiConfig> children </ConfigContext>
                          </ModalContainer>
                        </SidebarProvider>
                      </UserTimeZoneProvider>
                    </TokenContextProvider>
                  </ToastContainer>
                </SnackBarContainer>
              </PopUpContainer>
            </ThemeProvider>
          </ErrorBoundary>
        </Recoil.RecoilRoot>
      </ErrorBoundary>
    </React.Suspense>
  }
}

let renderDashboardApp = (~uiConfig, children) => {
  switch ReactDOM.querySelector("#app") {
  | Some(container) =>
    open ReactDOM.Client
    open ReactDOM.Client.Root
    open Window

    let root = createRoot(container)
    let windowUrl = urlSearch(location.href)
    let isDemoStore = windowUrl.href->Js.String2.includes("demo-store")
    let demoStoreClass = isDemoStore ? "overflow-scroll bg-[#f6f8fb]" : "overflow-hidden"
    root->render(
      <div className={`h-screen ${demoStoreClass} flex flex-col font-inter-style`}>
        <ContextWrapper uiConfig> children </ContextWrapper>
      </div>,
    )
  | None => ()
  }
}
