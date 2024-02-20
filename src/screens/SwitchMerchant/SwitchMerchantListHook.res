let useFetchSwitchMerchantList = () => {
  open APIUtils
  let fetchDetails = useGetMethod()
  let setSwitchMerchantListAtom = HyperswitchAtom.switchMerchantListAtom->Recoil.useSetRecoilState
  let url = getURL(~entityName=USERS, ~userType=#SWITCH_MERCHANT, ~methodType=Get, ())

  async _ => {
    try {
      let res = await fetchDetails(url)
      let typedValueOfResponse = res->SwitchMerchantUtils.convertListResponseToTypedResponse
      setSwitchMerchantListAtom(._ => typedValueOfResponse)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }
}
