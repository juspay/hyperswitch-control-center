%%raw(`require("tailwindcss/tailwind.css")`)
module ContextWrapper = {
  @react.component
  let make = (~children, ~uiConfig) => {
    let loader =
      <div className={`h-screen w-scrren flex justify-center items-center`}>
        <Loader />
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

    let root = createRoot(container)
    root->render(
      <div className={`h-screen overflow-hidden flex flex-col font-inter-style`}>
        <ContextWrapper uiConfig> children </ContextWrapper>
      </div>,
    )
  | None => ()
  }
}
