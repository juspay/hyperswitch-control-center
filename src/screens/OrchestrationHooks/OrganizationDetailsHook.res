let useFetchOrganizationDetails = () => {
  let getURL = APIUtils.useGetURL()
  let fetchDetails = APIUtils.useGetMethod()
  let setOrganizationDetailsValue =
    HyperswitchAtom.organizationDetailsValueAtom->Recoil.useSetRecoilState
  let {orgId} = React.useContext(UserInfoProvider.defaultContext).getCommonDetails()

  async () => {
    try {
      let orgRetrieveUrl = getURL(
        ~entityName=V1(ORGANIZATION_RETRIEVE),
        ~methodType=Get,
        ~id=Some(orgId),
      )
      let response = await fetchDetails(orgRetrieveUrl)
      let jsonToTypedValue = response->OrganizationDetailsMapper.getOrganizationDetails
      setOrganizationDetailsValue(_ => jsonToTypedValue)
      jsonToTypedValue
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to fetch merchant details!")
        Exn.raiseError(err)
      }
    }
  }
}
