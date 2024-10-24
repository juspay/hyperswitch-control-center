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
  useIsFeatureEnabledForMerchant: FeatureFlagUtils.config => bool,
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
      let domain = HyperSwitchEntryUtils.getSessionData(~key="domain", ~defaultValue="default")
      let merchantConfigURL = ` ${GlobalVars.getHostUrlWithBasePath}/config/merchant?domain=${domain}`
      let body =
        [
          ("org_id", orgId->JSON.Encode.string),
          ("merchant_id", merchantId->JSON.Encode.string),
          ("profile_id", profileId->JSON.Encode.string),
        ]
        ->Dict.fromArray
        ->JSON.Encode.object
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
  let useIsFeatureEnabledForMerchant = (config: FeatureFlagUtils.config) => {
    config.orgIds->Array.length > 0 ||
    config.merchantIds->Array.length > 0 ||
    config.profileIds->Array.length > 0
  }

  {fetchMerchantSpecificConfig, useIsFeatureEnabledForMerchant, merchantSpecificConfig}
}
