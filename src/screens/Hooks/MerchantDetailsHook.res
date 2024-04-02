let useFetchMerchantDetails = () => {
  let setMerchantDetailsValue = HyperswitchAtom.merchantDetailsValueAtom->Recoil.useSetRecoilState

  let fetchDetails = APIUtils.useGetMethod()

  async _ => {
    try {
      let accountUrl = APIUtils.getURL(~entityName=MERCHANT_ACCOUNT, ~methodType=Get, ())
      let merchantDetailsJSON = await fetchDetails(accountUrl)
      setMerchantDetailsValue(._ =>
        merchantDetailsJSON->MerchantAccountDetailsMapper.getMerchantDetails
      )
    } catch {
    | Exn.Error(e) => GenericCatch.handleCatch(~error=e, ())
    }
  }
}
