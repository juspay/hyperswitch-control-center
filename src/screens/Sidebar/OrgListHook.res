let useFetchOrgList = () => {
  open APIUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let setOrgListAtom = HyperswitchAtom.orgListAtom->Recoil.useSetRecoilState
  let url = getURL(~entityName=USERS, ~userType=#SWITCH_MERCHANT, ~methodType=Get)

  async _ => {
    try {
      let res = await fetchDetails(url)
      let typedValueOfResponse = res->OrgListUtils.convertListResponseToTypedResponse
      setOrgListAtom(_ => typedValueOfResponse)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }
}
