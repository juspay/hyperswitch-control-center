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
  type typedProfileDict
  type commonProfileDict
  let mapDictToTypedProfilePayload: mapperInput => typedProfileDict
  let mapDictToCommonProfilePayload: mapperInput => commonProfileDict
}

module V1: BusinessProfileInterface
  with type mapperInput = JSON.t
  and type typedProfileDict = profileEntity
  and type commonProfileDict = commonProfileEntity = {
  type mapperInput = JSON.t
  type typedProfileDict = profileEntity
  type commonProfileDict = commonProfileEntity

  let mapDictToTypedProfilePayload = (dict: mapperInput): typedProfileDict =>
    mapV1DictToProfilePayload(dict)
  let mapDictToCommonProfilePayload = (dict: mapperInput): commonProfileDict =>
    mapV1DictToProfilePayload(dict)->mapV1toCommonType
}

module V2: BusinessProfileInterface
  with type mapperInput = JSON.t
  and type typedProfileDict = profileEntity
  and type commonProfileDict = commonProfileEntity = {
  type mapperInput = JSON.t
  type typedProfileDict = profileEntity
  type commonProfileDict = commonProfileEntity

  let mapDictToTypedProfilePayload = (dict: mapperInput): typedProfileDict =>
    mapV2DictToProfilePayload(dict)
  let mapDictToCommonProfilePayload = (dict: mapperInput): commonProfileDict =>
    mapV2DictToProfilePayload(dict)->mapV2toCommonType
}

type businessProfileFCM<'a, 'b, 'c> = module(BusinessProfileInterface with
  type mapperInput = 'a
  and type typedProfileDict = 'b
  and type commonProfileDict = 'c
)
let businessProfileInterfaceV1: businessProfileFCM<
  JSON.t,
  profileEntity,
  commonProfileEntity,
> = module(V1)
let businessProfileInterfaceV2: businessProfileFCM<
  JSON.t,
  profileEntity,
  commonProfileEntity,
> = module(V2)

let mapDictToTypedProfilePayload = (
  type a b c,
  module(L: BusinessProfileInterface with
    type mapperInput = a
    and type typedProfileDict = b
    and type commonProfileDict = c
  ),
  inp: a,
): b => {
  L.mapDictToTypedProfilePayload(inp)
}

let mapJsonDictToCommonProfilePayload = (
  type a b c,
  module(L: BusinessProfileInterface with
    type mapperInput = a
    and type typedProfileDict = b
    and type commonProfileDict = c
  ),
  inp: a,
): c => {
  L.mapDictToCommonProfilePayload(inp)
}
