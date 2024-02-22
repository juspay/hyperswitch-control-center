@react.component
let make = (~setAuthType, ~setAuthStatus) => {
  open HyperSwitchAuthTypes
  open APIUtils
  open LogicUtils
  let url = RescriptReactRouter.useUrl()
  let updateDetails = useUpdateMethod()
  let (errorMessage, setErrorMessage) = React.useState(_ => "")
  let {setIsSidebarDetails} = React.useContext(SidebarProvider.defaultContext)
  let {acceptInvite} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let acceptInviteFormEmail = async body => {
    try {
      let url = getURL(~entityName=USERS, ~methodType=Post, ~userType=#ACCEPT_INVITE_FROM_EMAIL, ())
      let res = await updateDetails(url, body, Post, ())
      let email = res->JSON.Decode.object->Option.getOr(Dict.make())->getString("email", "")
      let token = HyperSwitchAuthUtils.parseResponseJson(
        ~json=res,
        ~email,
        ~isAcceptInvite=acceptInvite,
      )

      if !(token->isEmptyString) && !(email->isEmptyString) {
        setAuthStatus(LoggedIn(getDummyAuthInfoForToken(token)))
        setIsSidebarDetails("isPinned", false->JSON.Encode.bool)
        RescriptReactRouter.replace(`${HSwitchGlobalVars.hyperSwitchFEPrefix}/home`)
      } else {
        setAuthStatus(LoggedOut)
        RescriptReactRouter.replace(`${HSwitchGlobalVars.hyperSwitchFEPrefix}/login`)
      }
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Verification Failed")
        setErrorMessage(_ => err)
        setAuthStatus(LoggedOut)
      }
    }
  }

  React.useEffect0(() => {
    open HyperSwitchAuthUtils
    let tokenFromUrl = url.search->getDictFromUrlSearchParams->Dict.get("token")

    switch tokenFromUrl {
    | Some(token) => token->generateBodyForEmailRedirection->acceptInviteFormEmail->ignore
    | None => setErrorMessage(_ => "Token not received")
    }

    None
  })

  <HSwitchUtils.BackgroundImageWrapper customPageCss="font-semibold md:text-3xl p-16">
    {if errorMessage->String.length !== 0 {
      <div className="flex flex-col justify-between gap-32 flex items-center justify-center h-2/3">
        <Icon
          name="hyperswitch-text-icon"
          size=40
          className="cursor-pointer w-60"
          parentClass="flex flex-col justify-center items-center bg-white"
        />
        <div className="flex flex-col justify-between items-center gap-12 ">
          <img src={`/assets/WorkInProgress.svg`} />
          <div
            className={`leading-4 ml-1 mt-2 text-center flex items-center flex-col gap-6 w-full md:w-133 flex-wrap`}>
            <div className="flex gap-2.5 items-center">
              <Icon name="exclamation-circle" size=22 className="fill-red-500 mr-1.5" />
              <p className="text-fs-20 font-bold text-white">
                {React.string("Invalid Link or session expired")}
              </p>
            </div>
            <p className="text-fs-14 text-white opacity-60 font-semibold ">
              {"It appears that the link you were trying to access has expired or is no longer valid. Please try again ."->React.string}
            </p>
          </div>
          <Button
            text="Go back to login"
            buttonType={Primary}
            buttonSize={Small}
            customButtonStyle="cursor-pointer cursor-pointer w-5 rounded-md"
            onClick={_ => {
              RescriptReactRouter.replace(`${HSwitchGlobalVars.hyperSwitchFEPrefix}/login`)
              setAuthType(_ => LoginWithEmail)
            }}
          />
        </div>
      </div>
    } else {
      <div className="h-full w-full flex justify-center items-center text-white opacity-50">
        {"Accepting invite... You will be redirecting to the Dashboard.."->React.string}
      </div>
    }}
  </HSwitchUtils.BackgroundImageWrapper>
}
