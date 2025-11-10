let useFetchMerchantList = () => {
  open APIUtils
  open LogicUtils
  open OMPSwitchUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let showToast = ToastState.useShowToast()
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let setMerchantList = Recoil.useSetRecoilState(HyperswitchAtom.merchantListAtom)
  let {userInfo: {merchantId}} = React.useContext(UserInfoProvider.defaultContext)

  let getV2MerchantList = async () => {
    try {
      let v2MerchantListUrl = getURL(
        ~entityName=V2(USERS),
        ~userType=#LIST_MERCHANT,
        ~methodType=Get,
      )
      let v2MerchantResponse = await fetchDetails(v2MerchantListUrl, ~version=V2)
      v2MerchantResponse->getArrayFromJson([])
    } catch {
    | _ => []
    }
  }

  async () => {
    try {
      let v1MerchantListUrl = getURL(
        ~entityName=V1(USERS),
        ~userType=#LIST_MERCHANT,
        ~methodType=Get,
      )
      let v1MerchantResponse = await fetchDetails(v1MerchantListUrl)

      let v2MerchantList = if featureFlagDetails.devModularityV2 {
        await getV2MerchantList()
      } else {
        []
      }
      let concatenatedList = v1MerchantResponse->getArrayFromJson([])->Array.concat(v2MerchantList)
      let response = concatenatedList->uniqueObjectFromArrayOfObjects(keyExtractorForMerchantid)
      let concatenatedListTyped = response->getMappedValueFromArrayOfJson(merchantItemToObjMapper)
      setMerchantList(_ => concatenatedListTyped)
    } catch {
    | _ => {
        setMerchantList(_ => [ompDefaultValue(merchantId, "")])
        showToast(~message="Failed to fetch merchant list", ~toastType=ToastError)
      }
    }
  }
}
