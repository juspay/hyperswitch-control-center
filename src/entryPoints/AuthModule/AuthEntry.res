@react.component
let make = () => {
  <AuthInfoProvider>
    <AuthWrapper>
      <GlobalProvider>
        <UserInfoProvider>
          <HyperSwitchApp />
        </UserInfoProvider>
      </GlobalProvider>
    </AuthWrapper>
  </AuthInfoProvider>
}
