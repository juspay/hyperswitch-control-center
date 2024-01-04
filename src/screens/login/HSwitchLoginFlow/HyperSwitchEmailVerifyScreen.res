let generateBody = (url: RescriptReactRouter.url) => {
  let body = Dict.make()
  let val =
    url.search
    ->LogicUtils.getDictFromUrlSearchParams
    ->Dict.get("token")
    ->Belt.Option.getWithDefault("")

  body->Dict.set("token", val->Js.Json.string)
  body->Js.Json.object_
}

@react.component
let make = (~setAuthType, ~setAuthStatus, ~authType) => {
  open HyperSwitchAuthTypes
  open APIUtils
  open HSwitchUtils
  let url = RescriptReactRouter.useUrl()
  let updateDetails = useUpdateMethod()
  let (errorMessage, setErrorMessage) = React.useState(_ => "")
  let {setIsSidebarDetails} = React.useContext(SidebarProvider.defaultContext)
  let emailVerifyUpdate = async body => {
    try {
      let userType =
        authType == HyperSwitchAuthTypes.EmailVerify ? #VERIFY_EMAIL : #VERIFY_MAGIC_LINK
      let url = getURL(~entityName=USERS, ~methodType=Post, ~userType, ())
      let res = await updateDetails(url, body, Post)
      let email =
        res
        ->Js.Json.decodeObject
        ->Belt.Option.getWithDefault(Dict.make())
        ->LogicUtils.getString("email", "")
      let token = HyperSwitchAuthUtils.parseResponseJson(~json=res, ~email)
      if !(token->isEmptyString) && !(email->isEmptyString) {
        setAuthStatus(LoggedIn(HyperSwitchAuthTypes.getDummyAuthInfoForToken(token)))
        setIsSidebarDetails("isPinned", false->Js.Json.boolean)
        RescriptReactRouter.replace(`${HSwitchGlobalVars.hyperSwitchFEPrefix}/home`)
      } else {
        setAuthStatus(LoggedOut)
        RescriptReactRouter.replace(`${HSwitchGlobalVars.hyperSwitchFEPrefix}/login`)
      }
    } catch {
    | Js.Exn.Error(e) => {
        let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Verification Failed")
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
