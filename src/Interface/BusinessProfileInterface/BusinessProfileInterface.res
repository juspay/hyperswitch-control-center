open HSwitchSettingTypes
open BusinessProfileInterfaceUtils

let mapV1DictToProfilePayload: JSON.t => HSwitchSettingTypes.profileEntity = input => {
  mapJsonToBusinessProfileV1(input)
}

let mapV2DictToProfilePayload: JSON.t => HSwitchSettingTypes.profileEntity = input => {
  mapJsonToBusinessProfileV2(input)
}

module type BusinessProfileInterface = {
  type mapperInput
  type commonProfileDict
  let mapDictToCommonProfilePayload: mapperInput => commonProfileDict
}

module V1: BusinessProfileInterface
  with type mapperInput = JSON.t
  and type commonProfileDict = commonProfileEntity = {
  type mapperInput = JSON.t
  type commonProfileDict = commonProfileEntity

  let mapDictToCommonProfilePayload = (dict: mapperInput): commonProfileDict =>
    mapV1DictToProfilePayload(dict)->mapV1toCommonType
}

module V2: BusinessProfileInterface
  with type mapperInput = JSON.t
  and type commonProfileDict = commonProfileEntity = {
  type mapperInput = JSON.t
  type commonProfileDict = commonProfileEntity

  let mapDictToCommonProfilePayload = (dict: mapperInput): commonProfileDict =>
    mapV2DictToProfilePayload(dict)->mapV2toCommonType
}

type businessProfileFCM<'a, 'b> = module(BusinessProfileInterface with
  type mapperInput = 'a
  and type commonProfileDict = 'b
)
let businessProfileInterfaceV1: businessProfileFCM<JSON.t, commonProfileEntity> = module(V1)
let businessProfileInterfaceV2: businessProfileFCM<JSON.t, commonProfileEntity> = module(V2)

let mapJsonDictToCommonProfilePayload = (
  type a b,
  module(L: BusinessProfileInterface with type mapperInput = a and type commonProfileDict = b),
  inp: a,
): b => {
  L.mapDictToCommonProfilePayload(inp)
}
