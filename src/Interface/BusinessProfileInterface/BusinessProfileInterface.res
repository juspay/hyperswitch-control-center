open HSwitchSettingTypes
open BusinessProfileInterfaceUtils

module type BusinessProfileInterface = {
  type mapperInput
  type mapperOutput

  let mapJsonToBusinessProfile: mapperInput => mapperOutput
}

module V1: BusinessProfileInterface
  with type mapperInput = JSON.t
  and type mapperOutput = profileEntity = {
  type mapperInput = JSON.t
  type mapperOutput = profileEntity

  let mapJsonToBusinessProfile = (value: mapperInput): mapperOutput =>
    mapJsonToBusinessProfileV1(value)
}

module V2: BusinessProfileInterface
  with type mapperInput = JSON.t
  and type mapperOutput = profileEntity = {
  type mapperInput = JSON.t
  type mapperOutput = profileEntity

  let mapJsonToBusinessProfile = (value: mapperInput): mapperOutput =>
    mapJsonToBusinessProfileV2(value)
}

type businessProfileFCM<'a, 'b> = module(BusinessProfileInterface with
  type mapperInput = 'a
  and type mapperOutput = 'b
)
let businessProfileInterfaceV1: businessProfileFCM<JSON.t, profileEntity> = module(V1)
let businessProfileInterfaceV2: businessProfileFCM<JSON.t, profileEntity> = module(V2)
let mapJsonToBusinessProfile = (
  type a b,
  module(L: BusinessProfileInterface with type mapperInput = a and type mapperOutput = b),
  inp: a,
): b => {
  L.mapJsonToBusinessProfile(inp)
}

let useBusinessProfileMapper = (~interface) => {
  let value = Recoil.useRecoilValueFromAtom(HyperswitchAtom.businessProfileFromIdAtomInterface)
  let data = mapJsonToBusinessProfile(interface, value)
  data
}
