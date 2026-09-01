let useFetchProfileList = () => {
  open LogicUtils
  open APIUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let showToast = ToastAdapter.useShowToast()
  let setProfileList = Recoil.useSetRecoilState(HyperswitchAtom.profileListAtom)
  let {profileId, version} = React.useContext(
    UserInfoProvider.defaultContext,
  ).getCommonSessionDetails()

  async () => {
    try {
      let response = switch version {
      | UserInfoTypes.V2 =>
        await fetchDetails(
          getURL(~entityName=V2(USERS), ~userType=#LIST_PROFILE, ~methodType=Get),
          ~version=V2,
        )
      | V1 =>
        await fetchDetails(getURL(~entityName=V1(USERS), ~userType=#LIST_PROFILE, ~methodType=Get))
      }
      let profileData = response->getArrayDataFromJson(OMPSwitchUtils.profileItemToObjMapper)
      setProfileList(_ => profileData)
      profileData
    } catch {
    | _ => {
        setProfileList(_ => [OMPSwitchUtils.ompDefaultValue(profileId, "")])
        showToast(~message="Failed to fetch profile list", ~toastType=ToastError)
        []
      }
    }
  }
}
