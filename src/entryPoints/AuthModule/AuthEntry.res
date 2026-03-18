@react.component
let make = () => {
  open HyperswitchAtom
  let {downTime} = featureFlagAtom->Jotai.useAtomValue
  <>
    <RenderIf condition={downTime}>
      <UnderMaintenance />
    </RenderIf>
    <RenderIf condition={!downTime}>
      <AuthInfoProvider>
        <AuthWrapper>
          <GlobalProvider>
            <UserInfoProvider>
              <ProductSelectionProvider>
                <OMPSwitchUserFromURL>
                  <HyperSwitchApp />
                </OMPSwitchUserFromURL>
              </ProductSelectionProvider>
            </UserInfoProvider>
          </GlobalProvider>
        </AuthWrapper>
      </AuthInfoProvider>
    </RenderIf>
  </>
}
