let useFetchOrganizationList = () => {
  open LogicUtils
  open APIUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let showToast = ToastState.useShowToast()
  let setOrgList = Recoil.useSetRecoilState(HyperswitchAtom.orgListAtom)
  let setOrganizationDetailsValue =
    HyperswitchAtom.organizationDetailsValueAtom->Recoil.useSetRecoilState
  let {orgId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()

  let sortByOrgName = (org1: OMPSwitchTypes.ompListTypes, org2: OMPSwitchTypes.ompListTypes) => {
    compareLogic(org2.name->String.toLowerCase, org1.name->String.toLowerCase)
  }

  async () => {
    try {
      let url = getURL(~entityName=V1(USERS), ~userType=#LIST_ORG, ~methodType=Get)
      let response = await fetchDetails(url)
      let orgData = response->getArrayDataFromJson(OMPSwitchUtils.orgItemToObjMapper)
      orgData->Array.sort(sortByOrgName)
      setOrgList(_ => orgData)

      let currentOrgFromList =
        response
        ->getArrayFromJson([])
        ->Array.find(item => {
          let dict = item->getDictFromJsonObject
          dict->getString("org_id", "") === orgId
        })

      switch currentOrgFromList {
      | Some(orgJson) => {
          let orgDetails = orgJson->OrganizationDetailsMapper.getOrganizationDetails
          setOrganizationDetailsValue(_ => orgDetails)
        }
      | None => ()
      }

      orgData
    } catch {
    | _ => {
        setOrgList(_ => [OMPSwitchUtils.ompDefaultValue(orgId, "")])
        showToast(~message="Failed to fetch org list", ~toastType=ToastError)
        []
      }
    }
  }
}
