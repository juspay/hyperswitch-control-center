open APIUtils
open APIUtilsTypes
open BusinessProfileInterface

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
      //Todo: remove id atom once we start using businessProfileInterface
      setBusinessProfileRecoil(_ => res->BusinessProfileInterfaceUtilsV1.mapJsonToBusinessProfileV1)
      let commonTypedData = switch version {
      | V1 => mapJsonToCommonType(businessProfileInterfaceV1, res)

      | V2 => mapJsonToCommonType(businessProfileInterfaceV2, res)
      }
      setBusinessProfileInterfaceRecoil(_ => commonTypedData)
      res
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }
}

let useUpdateBusinessProfile = (~version=UserInfoTypes.V1) => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let {state: {commonInfo: {profileId}}} = React.useContext(UserInfoProvider.defaultContext)
  let setBusinessProfileRecoil =
    HyperswitchAtom.businessProfileFromIdAtomInterface->Recoil.useSetRecoilState

  async (~body, ~shouldTransform=false) => {
    try {
      let (entityName, transformedBody, methodType: Fetch.requestMethod) = switch version {
      | V1 => (
          V1(BUSINESS_PROFILE),
          mapJsonToRequestType(businessProfileInterfaceV1, body)->Identity.genericTypeToJson,
          Post,
        )

      | V2 => (
          V2(BUSINESS_PROFILE),
          mapJsonToRequestType(businessProfileInterfaceV2, body)->Identity.genericTypeToJson,
          Put,
        )
      }
      let finalBody = shouldTransform ? transformedBody : body

      let url = getURL(~entityName, ~methodType, ~id=Some(profileId))
      let res = await updateDetails(url, finalBody, methodType)
      let commonTypedData = switch version {
      | V1 => mapJsonToCommonType(businessProfileInterfaceV1, res)

      | V2 => mapJsonToCommonType(businessProfileInterfaceV2, res)
      }
      setBusinessProfileRecoil(_ => commonTypedData)
      res
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }
}
