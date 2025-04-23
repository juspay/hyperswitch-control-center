@react.component
let make = () => {
  open HyperswitchAtom
  let {downTime} = featureFlagAtom->Recoil.useRecoilValueFromAtom
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
                <HyperSwitchApp />
              </ProductSelectionProvider>
            </UserInfoProvider>
          </GlobalProvider>
        </AuthWrapper>
      </AuthInfoProvider>
    </RenderIf>
  </>
}
