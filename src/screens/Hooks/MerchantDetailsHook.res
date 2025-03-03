let useFetchMerchantDetails = () => {
  let getURL = APIUtils.useGetURL()
  let setMerchantDetailsValue = HyperswitchAtom.merchantDetailsValueAtom->Recoil.useSetRecoilState

  let fetchDetails = APIUtils.useGetMethod()

  async _ => {
    try {
      let accountUrl = getURL(~entityName=MERCHANT_ACCOUNT, ~methodType=Get)
      let merchantDetailsJSON = await fetchDetails(accountUrl)
      let jsonToTypedValue = merchantDetailsJSON->MerchantAccountDetailsMapper.getMerchantDetails
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
