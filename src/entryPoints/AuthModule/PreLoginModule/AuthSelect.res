@react.component
let make = (~setSelectedAuthId) => {
  open FramerMotion.Motion
  open CommonAuthTypes
  open AuthProviderTypes
  open APIUtils

  let getURL = useGetURL()
  let fetchAuthMethods = AuthModuleHooks.useAuthMethods()
  let updateDetails = useUpdateMethod()

  let {setAuthStatus} = React.useContext(AuthInfoProvider.authStatusContext)
  let (logoVariant, iconUrl) = switch Window.env.logoUrl {
  | Some(url) => (IconWithURL, Some(url))
  | _ => (IconWithText, None)
  }
  let (authMethods, setAuthMethods) = React.useState(_ => AuthUtils.defaultListOfAuth)

  let getAuthMethods = async () => {
    let arrayFromJson = await fetchAuthMethods()
    if arrayFromJson->Array.length === 0 {
      setAuthMethods(_ => AuthUtils.defaultListOfAuth)
    } else {
      let typedvalue = arrayFromJson->SSOUtils.getAuthVariants
      typedvalue->Array.sort((item1, item2) => {
        if item1.auth_method.\"type" == PASSWORD {
          -1.
        } else if item2.auth_method.\"type" == PASSWORD {
          1.
        } else {
          0.
        }
      })
      setAuthMethods(_ => typedvalue)
    }
  }

  let handleTerminateSSO = async method_id => {
    open AuthUtils
    try {
      let body = [("id", method_id->JSON.Encode.string)]->Dict.fromArray->JSON.Encode.object
      let terminateURL = getURL(~entityName=USERS, ~userType=#AUTH_SELECT, ~methodType=Post, ())
      let response = await updateDetails(terminateURL, body, Post, ())
      setSelectedAuthId(_ => Some(method_id))
      setAuthStatus(PreLogin(getPreLoginInfo(response)))
    } catch {
    | _ => setAuthStatus(LoggedOut)
    }
  }

  React.useEffect0(() => {
    getAuthMethods()->ignore
    None
  })

  let renderComponentForAuthTypes = (method: SSOTypes.authMethodResponseType) => {
    let authMethodType = method.auth_method.\"type"
    let authMethodName = method.auth_method.name

    switch (authMethodType, authMethodName) {
    | (PASSWORD, #Email_Password) =>
      <Button
        text="Continue with Password"
        buttonType={Primary}
        buttonSize={Large}
        onClick={_ => handleTerminateSSO(method.id)->ignore}
      />
    | (OPEN_ID_CONNECT, #Okta) | (OPEN_ID_CONNECT, #Google) | (OPEN_ID_CONNECT, #Github) =>
      <Button
        text={`Login with ${(authMethodName :> string)}`}
        buttonType={PrimaryOutline}
        onClick={_ => handleTerminateSSO(method.id)->ignore}
      />
    | (_, _) => React.null
    }
  }

  <HSwitchUtils.BackgroundImageWrapper customPageCss="flex flex-col items-center  overflow-scroll ">
    <div
      className="h-full flex flex-col items-center justify-between overflow-scoll text-grey-0 w-full mobile:w-30-rem">
      <div className="flex flex-col items-center gap-6 flex-1 mt-32 w-30-rem">
        <Div layoutId="form" className="bg-white w-full text-black mobile:border rounded-lg">
          <div className="px-7 py-6">
            <Div layoutId="logo">
              <HyperSwitchLogo logoHeight="h-8" theme={Dark} logoVariant iconUrl />
            </Div>
          </div>
          <Div layoutId="border" className="border-b w-full" />
          <div className="flex flex-col gap-4 p-7">
            {authMethods
            ->Array.mapWithIndex((authMethod, index) =>
              <React.Fragment key={index->Int.toString}>
                {authMethod->renderComponentForAuthTypes}
                <UIUtils.RenderIf condition={index === 0 && authMethods->Array.length !== 1}>
                  {PreLoginUtils.divider}
                </UIUtils.RenderIf>
              </React.Fragment>
            )
            ->React.array}
          </div>
        </Div>
      </div>
    </div>
  </HSwitchUtils.BackgroundImageWrapper>
}
