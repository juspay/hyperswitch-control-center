open HyperswitchAtom
let useFetchUserMerchantDetails = () => {
  let getURL = APIUtils.useGetURL()
  let setMerchantDetailsValue = HyperswitchAtom.merchantDetailsValueAtom->Recoil.useSetRecoilState

  let fetchDetails = APIUtils.useGetMethod()

  async (~version: UserInfoTypes.version=V1) => {
    try {
      let merchantDetailsJSON = switch version {
      | V1 => {
          let detailsUrl = getURL(~entityName=V1(USER_MERCHANT_DETAILS), ~methodType=Get)
          await fetchDetails(detailsUrl)
        }
      | V2 => {
          let detailsUrl = getURL(~entityName=V2(USER_MERCHANT_DETAILS), ~methodType=Get)
          await fetchDetails(detailsUrl, ~version=V2)
        }
      }
      let (product_type, merchant_account_type) =
        merchantDetailsJSON->MerchantAccountDetailsMapper.getUserMerchantDetails(~version)
      setMerchantDetailsValue(prev => {...prev, product_type, merchant_account_type})
      product_type
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to fetch merchant details!")
        Exn.raiseError(err)
      }
    }
  }
}

let useFetchMerchantDetails = (~showErrorToast=true) => {
  let getURL = APIUtils.useGetURL()
  let setMerchantDetailsValue = HyperswitchAtom.merchantDetailsValueAtom->Recoil.useSetRecoilState

  let fetchDetails = APIUtils.useGetMethod(~showErrorToast)

  async (~version: UserInfoTypes.version=V1) => {
    try {
      let merchantDetailsJSON = switch version {
      | V1 => {
          let accountUrl = getURL(~entityName=V1(MERCHANT_ACCOUNT), ~methodType=Get)
          await fetchDetails(accountUrl)
        }
      | V2 => {
          let accountUrl = getURL(~entityName=V2(MERCHANT_ACCOUNT), ~methodType=Get)
          await fetchDetails(accountUrl, ~version=V2)
        }
      }
      let jsonToTypedValue =
        merchantDetailsJSON->MerchantAccountDetailsMapper.getMerchantDetails(~version)
      setMerchantDetailsValue(_ => jsonToTypedValue)
      jsonToTypedValue
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to fetch merchant details!")
        Exn.raiseError(err)
      }
    }
  }
}

let useMerchantDetailsValue = () => Recoil.useRecoilValueFromAtom(merchantDetailsValueAtom)

// Pulls in the merchant account for screens needing fields the bootstrap skips
let useLoadMerchantDetails = () => {
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let fetchMerchantDetails = useFetchMerchantDetails()
  let merchantDetails = useMerchantDetailsValue()
  let {version} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()

  let isMerchantDetailsPresent = merchantDetails.publishable_key->LogicUtils.isNonEmptyString
  let hasAccountAccess = userHasAccess(~groupAccess=AccountView) === CommonAuthTypes.Access
  let (isLoaded, setIsLoaded) = React.useState(_ => isMerchantDetailsPresent)

  let loadMerchantDetails = async () => {
    try {
      let _ = await fetchMerchantDetails(~version)
      setIsLoaded(_ => true)
    } catch {
    | _ => ()
    }
  }

  React.useEffect(() => {
    if hasAccountAccess && !isMerchantDetailsPresent {
      loadMerchantDetails()->ignore
    }
    None
  }, [])

  isLoaded
}
