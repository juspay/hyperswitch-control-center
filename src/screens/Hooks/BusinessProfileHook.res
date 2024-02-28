let useFetchBusinessProfiles = () => {
  open APIUtils
  let fetchDetails = useGetMethod()
  let setBusinessProfiles = Recoil.useSetRecoilState(HyperswitchAtom.businessProfilesAtom)

  async _ => {
    try {
      let url = getURL(~entityName=BUSINESS_PROFILE, ~methodType=Get, ())
      let res = await fetchDetails(url)
      let stringifiedResponse = res->JSON.stringify
      setBusinessProfiles(._ => stringifiedResponse)
      Nullable.make(stringifiedResponse->MerchantAccountUtils.getValueFromBusinessProfile)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }
}

let useGetBusinessProflile = profileId => {
  HyperswitchAtom.businessProfilesAtom
  ->Recoil.useRecoilValueFromAtom
  ->MerchantAccountUtils.getArrayOfBusinessProfile
  ->Array.find(profile => profile.profile_id == profileId)
  ->Option.getOr(MerchantAccountUtils.defaultValueForBusinessProfile)
}
