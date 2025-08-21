type t
type searchParams

// methods
@send external toString: t => string = "toString"

// property access (important: @get, not @send)
@get external searchParams: t => searchParams = "searchParams"

// URLSearchParams methods
@send external append: (searchParams, string, string) => unit = "append"
@send external set: (searchParams, string, string) => unit = "set"
@send external get: (searchParams, string) => string = "get"
@get external href: t => string = "href"
@val external decodeURIComponent: string => string = "decodeURIComponent"

@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  let {setActiveProductValue} = React.useContext(ProductSelectionProvider.defaultContext)
  let {userInfo} = React.useContext(UserInfoProvider.defaultContext)
  let val = url.search->LogicUtils.getDictFromUrlSearchParams->OMPSwitchUtils.userSwitch(userInfo)

  let internalSwitch = if (
    val.orgId != userInfo.orgId ||
    val.merchantId != userInfo.merchantId ||
    val.profileId != userInfo.profileId
  ) {
    OMPSwitchHooks.useInternalSwitch(~setActiveProductValue)
  } else {
    OMPSwitchHooks.useInternalSwitch()
  }
  let switchUser = async () => {
    try {
      await internalSwitch(
        ~expectedOrgId=Some(val.orgId),
        ~expectedMerchantId=Some(val.merchantId),
        ~expectedProfileId=Some(val.profileId),
      )
      let url = decodeURIComponent(val.destination)
      RescriptReactRouter.push(url)
    } catch {
    | _ => ()
    }
  }
  React.useEffect(() => {
    switchUser()->ignore
    None
  }, [])
  React.null
}
