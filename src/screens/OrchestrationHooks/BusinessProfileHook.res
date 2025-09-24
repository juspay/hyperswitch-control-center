open APIUtils
open APIUtilsTypes

let useFetchBusinessProfileFromId = (~version=UserInfoTypes.V1) => {
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let setBusinessProfileRecoil = HyperswitchAtom.businessProfileFromIdAtom->Recoil.useSetRecoilState
  let setBusinessProfileInterfaceRecoil =
    HyperswitchAtom.businessProfileFromIdAtomInterface->Recoil.useSetRecoilState
  async (~profileId) => {
    try {
      let entityName = switch version {
      | V1 => V1(BUSINESS_PROFILE)
      | V2 => V2(BUSINESS_PROFILE)
      }
      let url = getURL(~entityName, ~methodType=Get, ~id=profileId)
      let res = await fetchDetails(url, ~version)
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
  let {userInfo: {profileId}} = React.useContext(UserInfoProvider.defaultContext)
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
