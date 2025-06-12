let useFetchBusinessProfiles = () => {
  open APIUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let setBusinessProfiles = Recoil.useSetRecoilState(HyperswitchAtom.businessProfilesAtom)

  async _ => {
    try {
      let url = getURL(~entityName=V1(BUSINESS_PROFILE), ~methodType=Get)
      let res = await fetchDetails(url)
      setBusinessProfiles(_ => res->BusinessProfileMapper.getArrayOfBusinessProfile)
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

open APIUtils
open APIUtilsTypes
let useFetchBusinessProfileFromId = () => {
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let setBusinessProfileRecoil = HyperswitchAtom.businessProfileFromIdAtom->Recoil.useSetRecoilState
  let setBusinessProfileInterfaceRecoil =
    HyperswitchAtom.businessProfileFromIdAtomInterface->Recoil.useSetRecoilState
  async (~profileId) => {
    try {
      let url = getURL(~entityName=V1(BUSINESS_PROFILE), ~methodType=Get, ~id=profileId)
      let res = await fetchDetails(url, ~version=UserInfoTypes.V1)
      //Todo: remove this once we start using businessProfileInterface
      setBusinessProfileRecoil(_ => res->BusinessProfileMapper.businessProfileTypeMapper)
      setBusinessProfileInterfaceRecoil(_ => res)
      res
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }
}

let useUpdateBusinessProfile = () => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let profileId = (
    HyperswitchAtom.businessProfileFromIdAtom->Recoil.useRecoilValueFromAtom
  ).profile_id
  let setBusinessProfileRecoil = HyperswitchAtom.businessProfileFromIdAtom->Recoil.useSetRecoilState

  async (~body) => {
    try {
      let url = getURL(~entityName=V1(BUSINESS_PROFILE), ~methodType=Post, ~id=Some(profileId))
      let res = await updateDetails(url, body, Post)
      setBusinessProfileRecoil(_ => res->BusinessProfileMapper.businessProfileTypeMapper)
      res
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }
}
let useBusinessProfileMapper = (~interface) => {
  let value = Recoil.useRecoilValueFromAtom(HyperswitchAtom.businessProfileFromIdAtomInterface)
  let data = BusinessProfileInterface.mapJsonToBusinessProfile(interface, value)
  data
}
