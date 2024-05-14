@react.component
let make = () => {
  <AuthInfoProvider>
    <BasicAuthWrapper>
      <GlobalProvider>
        <BasicDecisionScreen />
      </GlobalProvider>
    </BasicAuthWrapper>
  </AuthInfoProvider>
}
