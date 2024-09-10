let useFetchSwitchMerchantList = () => {
  open APIUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let setSwitchMerchantListAtom = HyperswitchAtom.switchMerchantListAtom->Recoil.useSetRecoilState

  async _ => {
    try {
      let url = getURL(~entityName=USERS, ~userType=#SWITCH_MERCHANT, ~methodType=Get)
      let res = await fetchDetails(url)
      let typedValueOfResponse = res->SwitchMerchantUtils.convertListResponseToTypedResponse
      setSwitchMerchantListAtom(_ => typedValueOfResponse)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }
}
