@react.component
let make = () => {
  <AuthInfoProvider>
    <AuthWrapper>
      <GlobalProvider>
        <HyperSwitchApp />
      </GlobalProvider>
    </AuthWrapper>
  </AuthInfoProvider>
}
