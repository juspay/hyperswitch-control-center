open APIUtils
open APIUtilsTypes
open BusinessProfileInterface

let useFetchBusinessProfileFromIdV1 = () => {
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let setBusinessProfileRecoil = HyperswitchAtom.businessProfileFromIdAtom->Recoil.useSetRecoilState
  let setBusinessProfileInterfaceRecoil =
    HyperswitchAtom.businessProfileFromIdAtomInterface->Recoil.useSetRecoilState
  async (~profileId) => {
    try {
      let url = getURL(~entityName=V1(BUSINESS_PROFILE), ~methodType=Get, ~id=profileId)
      let businessProfile = await fetchDetails(url)
      setBusinessProfileRecoil(_ =>
        businessProfile->BusinessProfileInterfaceUtilsV1.mapJsonToBusinessProfileV1
      )
      let commonTypedData = mapJsonToCommonType(businessProfileInterfaceV1, businessProfile)
      setBusinessProfileInterfaceRecoil(_ => commonTypedData)
      businessProfile
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }
}

let useFetchBusinessProfileFromIdV2 = () => {
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let setBusinessProfileRecoil = HyperswitchAtom.businessProfileFromIdAtom->Recoil.useSetRecoilState
  let setBusinessProfileInterfaceRecoil =
    HyperswitchAtom.businessProfileFromIdAtomInterface->Recoil.useSetRecoilState
  async (~profileId) => {
    try {
      let url = getURL(~entityName=V2(BUSINESS_PROFILE), ~methodType=Get, ~id=profileId)
      let businessProfile = await fetchDetails(url, ~version=V2)
      setBusinessProfileRecoil(_ =>
        businessProfile->BusinessProfileInterfaceUtilsV1.mapJsonToBusinessProfileV1
      )
      let commonTypedData = mapJsonToCommonType(businessProfileInterfaceV2, businessProfile)
      setBusinessProfileInterfaceRecoil(_ => commonTypedData)
      businessProfile
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }
}

let useFetchBusinessProfileFromId = (~version=UserInfoTypes.V1) => {
  let fetchV1 = useFetchBusinessProfileFromIdV1()
  let fetchV2 = useFetchBusinessProfileFromIdV2()
  async (~profileId) => {
    switch version {
    | V1 => await fetchV1(~profileId)
    | V2 => await fetchV2(~profileId)
    }
  }
}

let useUpdateBusinessProfileV1 = () => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  let setBusinessProfileRecoil =
    HyperswitchAtom.businessProfileFromIdAtomInterface->Recoil.useSetRecoilState

  async (~body, ~shouldTransform=false) => {
    try {
      let transformedBody =
        mapJsonToRequestType(businessProfileInterfaceV1, body)->Identity.genericTypeToJson
      let finalBody = shouldTransform ? transformedBody : body

      let url = getURL(~entityName=V1(BUSINESS_PROFILE), ~methodType=Post, ~id=Some(profileId))
      let updatedBusinessProfile = await updateDetails(url, finalBody, Post)
      let commonTypedData = mapJsonToCommonType(businessProfileInterfaceV1, updatedBusinessProfile)
      setBusinessProfileRecoil(_ => commonTypedData)
      updatedBusinessProfile
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }
}

let useUpdateBusinessProfileV2 = () => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  let setBusinessProfileRecoil =
    HyperswitchAtom.businessProfileFromIdAtomInterface->Recoil.useSetRecoilState

  async (~body, ~shouldTransform=false) => {
    try {
      let transformedBody =
        mapJsonToRequestType(businessProfileInterfaceV2, body)->Identity.genericTypeToJson
      let finalBody = shouldTransform ? transformedBody : body

      let url = getURL(~entityName=V2(BUSINESS_PROFILE), ~methodType=Put, ~id=Some(profileId))
      let updatedBusinessProfile = await updateDetails(url, finalBody, Put, ~version=V2)
      let commonTypedData = mapJsonToCommonType(businessProfileInterfaceV2, updatedBusinessProfile)
      setBusinessProfileRecoil(_ => commonTypedData)
      updatedBusinessProfile
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }
}

let useUpdateBusinessProfile = (~version=UserInfoTypes.V1) => {
  let updateV1 = useUpdateBusinessProfileV1()
  let updateV2 = useUpdateBusinessProfileV2()
  async (~body, ~shouldTransform=false) => {
    switch version {
    | V1 => await updateV1(~body, ~shouldTransform)
    | V2 => await updateV2(~body, ~shouldTransform)
    }
  }
}
