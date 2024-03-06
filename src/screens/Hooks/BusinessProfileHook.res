let useFetchBusinessProfiles = () => {
  open APIUtils
  let fetchDetails = useGetMethod()
  let setBusinessProfiles = Recoil.useSetRecoilState(HyperswitchAtom.businessProfilesAtom)

  async _ => {
    try {
      let url = getURL(~entityName=BUSINESS_PROFILE, ~methodType=Get, ())
      let res = await fetchDetails(url)
      setBusinessProfiles(._ => res->BusinessProfileMapper.getArrayOfBusinessProfile)
      Nullable.make(res->BusinessProfileMapper.getArrayOfBusinessProfile)
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
  ->Array.find(profile => profile.profile_id == profileId)
  ->Option.getOr(MerchantAccountUtils.defaultValueForBusinessProfile)
}
