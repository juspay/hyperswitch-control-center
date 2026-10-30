open APIUtils
open LogicUtils

let useFetchMerchantListV2 = () => {
  let getURL = useGetURL()
  let fetchDetails = useGetMethod(~showErrorToast=false)

  async () => {
    try {
      let v2MerchantListUrl = getURL(
        ~entityName=V2(USERS),
        ~userType=#LIST_MERCHANT,
        ~methodType=Get,
      )
      let v2MerchantListResponse = await fetchDetails(v2MerchantListUrl, ~version=V2)
      v2MerchantListResponse->getArrayFromJson([])
    } catch {
    | err =>
      Js.log2("FAILED TO FETCH V2 MERCHANT LIST", err)
      []
    }
  }
}

let useFetchMerchantList = () => {
  open OMPSwitchUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let showToast = ToastAdapter.useShowToast()
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let setMerchantList = Recoil.useSetRecoilState(HyperswitchAtom.merchantListAtom)
  let {merchantId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()

  let v2MerchantListFetcher = useFetchMerchantListV2()

  async () => {
    try {
      let v1MerchantListUrl = getURL(
        ~entityName=V1(USERS),
        ~userType=#LIST_MERCHANT,
        ~methodType=Get,
      )
      let v1MerchantResponse = await fetchDetails(v1MerchantListUrl)

      let v2MerchantList =
        UserInfoTypes.V2->ProductAccess.hasApiVersionAccess(~featureFlags=featureFlagDetails)
          ? await v2MerchantListFetcher()
          : []
      let concatenatedList = v1MerchantResponse->getArrayFromJson([])->Array.concat(v2MerchantList)
      let response = concatenatedList->uniqueObjectFromArrayOfObjects(keyExtractorForMerchantid)
      let concatenatedListTyped =
        response
        ->getMappedValueFromArrayOfJson(merchantItemToObjMapper)
        ->Array.filter(merchant =>
          ProductAccess.hasMerchantAccess(
            ~version=merchant.version->Option.getOr(UserInfoTypes.V1),
            ~product=merchant.productType->Option.getOr(ProductTypes.UnknownProduct),
            ~featureFlags=featureFlagDetails,
          )
        )
      setMerchantList(_ => concatenatedListTyped)
      concatenatedListTyped
    } catch {
    | _ => {
        setMerchantList(_ => [ompDefaultValue(merchantId, "")])
        showToast(~message="Failed to fetch merchant list", ~toastType=ToastError)
        []
      }
    }
  }
}
