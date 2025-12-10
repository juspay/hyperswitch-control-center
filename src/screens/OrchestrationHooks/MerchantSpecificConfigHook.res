/**
 * @module MerchantSpecificConfigHook
 *
 * @description This exposes a hook to fetch the merchant specific config
 *               and to check if the merchant has access to config
 *
 *  @functions
 *  - fetchMerchantSpecificConfig : fetches the list of user group level access
 *  - useIsFeatureEnabledForMerchant: checks if the merchant has access
 *         @params
 *         - config : merchant config
 *
 *
 *
 */
type useMerchantSpecificConfig = {
  fetchMerchantSpecificConfig: unit => promise<unit>,
  useIsFeatureEnabledForDenyListMerchant: FeatureFlagUtils.config => bool,
  useIsFeatureEnabledForAllowListMerchant: FeatureFlagUtils.config => bool,
  merchantSpecificConfig: FeatureFlagUtils.merchantSpecificConfig,
}

let useMerchantSpecificConfig = () => {
  open APIUtils
  let updateAPIHook = useUpdateMethod(~showErrorToast=false)
  let setMerchantSpecificConfig =
    HyperswitchAtom.merchantSpecificConfigAtom->Recoil.useSetRecoilState
  let {userInfo: {orgId, merchantId, profileId}} = React.useContext(UserInfoProvider.defaultContext)
  let merchantSpecificConfig =
    HyperswitchAtom.merchantSpecificConfigAtom->Recoil.useRecoilValueFromAtom
  let fetchMerchantSpecificConfig = async () => {
    try {
      let domain = HSLocalStorage.getDomainfromStore()->Option.getOr("")
      let merchantConfigURL = ` ${GlobalVars.getHostUrlWithBasePath}/config/merchant?domain=${domain}` // todo: domain shall be removed from query params later
      let body =
        [
          ("org_id", orgId->JSON.Encode.string),
          ("merchant_id", merchantId->JSON.Encode.string),
          ("profile_id", profileId->JSON.Encode.string),
        ]->LogicUtils.getJsonFromArrayOfJson
      let response = await updateAPIHook(merchantConfigURL, body, Post)
      let mapMerchantSpecificConfig = response->FeatureFlagUtils.merchantSpecificConfig
      setMerchantSpecificConfig(_ => mapMerchantSpecificConfig)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }
  let useIsFeatureEnabledForDenyListMerchant = (config: FeatureFlagUtils.config) => {
    config.orgId->Option.isNone &&
    config.merchantId->Option.isNone &&
    config.profileId->Option.isNone
  }

  let useIsFeatureEnabledForAllowListMerchant = (config: FeatureFlagUtils.config) => {
    config.orgId->Option.isSome ||
    config.merchantId->Option.isSome ||
    config.profileId->Option.isSome
  }

  {
    fetchMerchantSpecificConfig,
    useIsFeatureEnabledForDenyListMerchant,
    useIsFeatureEnabledForAllowListMerchant,
    merchantSpecificConfig,
  }
}
