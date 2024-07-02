type fetchAuthMethods = unit => promise<unit>
type checkAuthMethodExists = array<SSOTypes.authMethodTypes> => bool
type getAuthMethod = SSOTypes.authMethodTypes => option<array<SSOTypes.authMethodResponseType>>
type isMagicLinkEnabled = unit => bool
type isPasswordEnabled = unit => bool
type isSignUpAllowed = unit => (bool, SSOTypes.authMethodTypes)

type authMethodProps = {
  checkAuthMethodExists: checkAuthMethodExists,
  getAuthMethod: SSOTypes.authMethodTypes => option<array<SSOTypes.authMethodResponseType>>,
  fetchAuthMethods: fetchAuthMethods,
  isPasswordEnabled: isPasswordEnabled,
  isMagicLinkEnabled: isMagicLinkEnabled,
  isSignUpAllowed: isSignUpAllowed,
}
let useAuthMethods = (): authMethodProps => {
  open APIUtils
  open LogicUtils

  let getURL = useGetURL()
  let featureFlagValues = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let fetchDetails = useGetMethod(~showErrorToast=false, ())

  let {authMethods, setAuthMethods} = React.useContext(AuthInfoProvider.authStatusContext)

  let fetchAuthMethods = React.useCallback0(async () => {
    try {
      let authId = HyperSwitchEntryUtils.getSessionData(~key="auth_id", ())
      let authListUrl = getURL(
        ~entityName=USERS,
        ~userType=#GET_AUTH_LIST,
        ~methodType=Get,
        ~queryParamerters=Some(`auth_id=${authId}`),
        (),
      )

      let json = await fetchDetails(`${authListUrl}`)
      let arrayFromJson = json->getArrayFromJson([])
      let methods = if arrayFromJson->Array.length === 0 {
        AuthUtils.defaultListOfAuth
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
        typedvalue
      }
      setAuthMethods(_ => methods)
    } catch {
    | Exn.Error(_e) => setAuthMethods(_ => AuthUtils.defaultListOfAuth)
    }
  })

  let checkAuthMethodExists = React.useCallback1(methods => {
    authMethods->Array.some(v => {
      let authMethod = v.auth_method.\"type"
      methods->Array.includes(authMethod)
    })
  }, [authMethods])

  let getAuthMethod = React.useCallback1(authMethod => {
    let value = authMethods->Array.filter(v => {
      let method = v.auth_method.\"type"
      authMethod == method
    })
    value->getNonEmptyArray
  }, [authMethods])

  let isMagicLinkEnabled = React.useCallback1(() => {
    let method: SSOTypes.authMethodTypes = MAGIC_LINK
    featureFlagValues.email && getAuthMethod(method)->Option.isSome
  }, [authMethods])

  let isPasswordEnabled = React.useCallback1(() => {
    let method: SSOTypes.authMethodTypes = PASSWORD
    featureFlagValues.email && getAuthMethod(method)->Option.isSome
  }, [authMethods])

  let isSignUpAllowed = React.useCallback1(() => {
    open SSOTypes
    let magicLinkmethod = getAuthMethod(MAGIC_LINK)
    let passwordmethod = getAuthMethod(PASSWORD)

    let isSingUpAllowedinMagicLink = switch magicLinkmethod {
    | Some(magicLinkData) => magicLinkData->Array.some(v => v.allow_signup)
    | None => false
    }
    let isSingUpAllowedinPassword = switch passwordmethod {
    | Some(passwordData) => passwordData->Array.some(v => v.allow_signup)
    | None => false
    }
    let emailFeatureFlagEnable = featureFlagValues.email
    let isTotpFeatureDisable = featureFlagValues.totp

    let isLiveMode = featureFlagValues.isLiveMode

    if isLiveMode {
      // Singup not allowed in Prod
      (false, INVALID)
    } else if isSingUpAllowedinMagicLink && emailFeatureFlagEnable {
      // Singup is allowed if email feature flag and allow_signup in the magicLink method is true
      (true, MAGIC_LINK)
    } else if isSingUpAllowedinPassword {
      // Singup is allowed if email feature flag and allow_signup in the passowrd method is true
      (true, PASSWORD)
    } else if !isTotpFeatureDisable && emailFeatureFlagEnable {
      // Singup is allowed if totp feature  is disable and email feature is enabled
      (true, MAGIC_LINK)
    } else if !isTotpFeatureDisable {
      // Singup is allowed if totp feature  is disable
      (true, PASSWORD)
    } else {
      (false, INVALID)
    }
  }, [authMethods])

  {
    fetchAuthMethods,
    checkAuthMethodExists,
    getAuthMethod,
    isMagicLinkEnabled,
    isPasswordEnabled,
    isSignUpAllowed,
  }
}

let useNote = (authType, setAuthType, ()) => {
  open UIUtils
  open CommonAuthTypes
  let {globalUIConfig: {font: {textColor}}} = React.useContext(ConfigContext.configContext)
  let authId = HyperSwitchEntryUtils.getSessionData(~key="auth_id", ())

  let {isMagicLinkEnabled, isPasswordEnabled} = useAuthMethods()

  let getFooterLinkComponent = (~btnText, ~authType, ~path) => {
    <div
      onClick={_ => {
        setAuthType(_ => authType)
        HSwitchGlobalVars.appendDashboardPath(~url=path)->RescriptReactRouter.push
      }}
      className={`text-sm text-center ${textColor.primaryNormal} cursor-pointer hover:underline underline-offset-2`}>
      {btnText->React.string}
    </div>
  }

  <div className="w-96">
    {switch authType {
    | LoginWithEmail =>
      <RenderIf condition={isPasswordEnabled() && isMagicLinkEnabled()}>
        {getFooterLinkComponent(
          ~btnText="sign in using password",
          ~authType=LoginWithPassword,
          ~path=`/login?auth_id${authId}`,
        )}
      </RenderIf>
    | LoginWithPassword =>
      <RenderIf condition={isMagicLinkEnabled()}>
        {getFooterLinkComponent(
          ~btnText="sign in with an email",
          ~authType=LoginWithEmail,
          ~path=`/login?auth_id${authId}`,
        )}
      </RenderIf>
    | SignUP =>
      <RenderIf condition={isMagicLinkEnabled()}>
        <p className="text-center text-sm">
          {"We'll be emailing you a magic link for a password-free experience, you can always choose to setup a password later."->React.string}
        </p>
      </RenderIf>
    | ForgetPassword | MagicLinkEmailSent | ForgetPasswordEmailSent | ResendVerifyEmailSent =>
      <div className="w-full flex justify-center">
        <div
          onClick={_ => {
            let backState = switch authType {
            | MagicLinkEmailSent => SignUP
            | ForgetPasswordEmailSent => ForgetPassword
            | ResendVerifyEmailSent => ResendVerifyEmail
            | ForgetPassword | _ => LoginWithPassword
            }
            setAuthType(_ => backState)
          }}
          className={`text-sm text-center ${textColor.primaryNormal} hover:underline underline-offset-2 cursor-pointer w-fit`}>
          {"Cancel"->React.string}
        </div>
      </div>
    | _ => React.null
    }}
  </div>
}
