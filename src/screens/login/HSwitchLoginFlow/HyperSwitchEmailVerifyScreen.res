let generateBody = (url: RescriptReactRouter.url) => {
  let body = Dict.make()
  let val = url.search->LogicUtils.getDictFromUrlSearchParams->Dict.get("token")->Option.getOr("")

  body->Dict.set("token", val->JSON.Encode.string)
  body->JSON.Encode.object
}

@react.component
let make = (~setAuthType, ~setAuthStatus, ~authType) => {
  open HyperSwitchAuthTypes
  open APIUtils
  open LogicUtils
  let url = RescriptReactRouter.useUrl()
  let updateDetails = useUpdateMethod()
  let (errorMessage, setErrorMessage) = React.useState(_ => "")
  let {setIsSidebarDetails} = React.useContext(SidebarProvider.defaultContext)
  let emailVerifyUpdate = async body => {
    try {
      let userType =
        authType == HyperSwitchAuthTypes.EmailVerify ? #VERIFY_EMAIL : #VERIFY_MAGIC_LINK
      let url = getURL(~entityName=USERS, ~methodType=Post, ~userType, ())
      let res = await updateDetails(url, body, Post, ())
      let email = res->JSON.Decode.object->Option.getOr(Dict.make())->getString("email", "")
      let token = HyperSwitchAuthUtils.parseResponseJson(~json=res, ~email)
      if !(token->isEmptyString) && !(email->isEmptyString) {
        setAuthStatus(LoggedIn(HyperSwitchAuthTypes.getDummyAuthInfoForToken(token)))
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
    let body = generateBody(url)
    emailVerifyUpdate(body)->ignore
    None
  })

  <HSwitchUtils.BackgroundImageWrapper customPageCss="font-semibold md:text-3xl p-16">
    {if errorMessage->String.length !== 0 {
      <div className="flex flex-col justify-between gap-32 flex items-center justify-center h-2/3">
        <Icon
          name="hyperswitch-text-icon"
          size=40
          className="cursor-pointer w-60"
          parentClass="flex flex-col justify-center items-center"
        />
        <div className="flex flex-col justify-between items-center gap-12 ">
          <img src={`/assets/WorkInProgress.svg`} />
          <div
            className={`leading-4 ml-1 mt-2 text-center flex items-center flex-col gap-6 w-full md:w-133 flex-wrap`}>
            <div className="flex gap-2.5 items-center">
              <Icon name="exclamation-circle" size=22 className="fill-red-500 mr-1.5" />
              <p className="text-fs-20 font-bold text-gray-700">
                {React.string("Invalid Link or session expired")}
              </p>
            </div>
            <p className="text-fs-14 text-gray-700 opacity-50 font-semibold ">
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
              setAuthType(_ => HyperSwitchAuthTypes.LoginWithEmail)
            }}
          />
        </div>
      </div>
    } else {
      <div className="h-full w-full flex justify-center items-center">
        {"Verifing... You will be redirecting.."->React.string}
      </div>
    }}
  </HSwitchUtils.BackgroundImageWrapper>
}
