let useFetchMerchantDetails = () => {
  let getURL = APIUtils.useGetURL()
  let setMerchantDetailsValue = HyperswitchAtom.merchantDetailsValueAtom->Recoil.useSetRecoilState

  let fetchDetails = APIUtils.useGetMethod()

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
