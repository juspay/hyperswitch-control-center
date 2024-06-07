@react.component
let make = () => {
  <AuthInfoProvider>
    <TotpAuthWrapper>
      <GlobalProvider>
        <HyperSwitchApp />
      </GlobalProvider>
    </TotpAuthWrapper>
  </AuthInfoProvider>
}
