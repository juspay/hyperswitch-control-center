open HSwitchSettingTypes
open BusinessProfileInterfaceUtils

let mapJsonToV1type: JSON.t => HSwitchSettingTypes.profileEntity = jsonInput => {
  mapJsonToBusinessProfileV1(jsonInput)
}

let mapJsonToV2type: JSON.t => HSwitchSettingTypes.profileEntity = jsonInput => {
  mapJsonToBusinessProfileV2(jsonInput)
}

let mapJsonToV1RequestType: JSON.t => HSwitchSettingTypes.profileEntityRequestType = jsonInput => {
  commonTypeJsonToV1ForRequest(jsonInput)
}

let mapJsonToV2RequestType: JSON.t => HSwitchSettingTypes.profileEntityRequestType = jsonInput => {
  commonTypeJsonToV1ForRequest(jsonInput)
}

module type BusinessProfileInterface = {
  type mapperInput
  type commonProfileDict
  type requestType
  let mapJsonToCommonType: mapperInput => commonProfileDict
  let mapJsonToRequestType: mapperInput => requestType
}

module V1: BusinessProfileInterface
  with type mapperInput = JSON.t
  and type commonProfileDict = commonProfileEntity
  and type requestType = profileEntityRequestType = {
  type mapperInput = JSON.t
  type commonProfileDict = commonProfileEntity
  type requestType = profileEntityRequestType

  let mapJsonToCommonType = (json: mapperInput): commonProfileDict =>
    mapJsonToV1type(json)->mapV1toCommonType
  let mapJsonToRequestType = (json: mapperInput): requestType => mapJsonToV1RequestType(json)
}

module V2: BusinessProfileInterface
  with type mapperInput = JSON.t
  and type commonProfileDict = commonProfileEntity
  and type requestType = profileEntityRequestType = {
  type mapperInput = JSON.t
  type commonProfileDict = commonProfileEntity
  type requestType = profileEntityRequestType

  let mapJsonToCommonType = (json: mapperInput): commonProfileDict =>
    mapJsonToV2type(json)->mapV2toCommonType
  let mapJsonToRequestType = (json: mapperInput): requestType => mapJsonToV2RequestType(json)
}

type businessProfileFCM<'a, 'b, 'c> = module(BusinessProfileInterface with
  type mapperInput = 'a
  and type commonProfileDict = 'b
  and type requestType = 'c
)
let businessProfileInterfaceV1: businessProfileFCM<
  JSON.t,
  commonProfileEntity,
  profileEntityRequestType,
> = module(V1)
let businessProfileInterfaceV2: businessProfileFCM<
  JSON.t,
  commonProfileEntity,
  profileEntityRequestType,
> = module(V2)

let mapJsonToCommonType = (
  type a b c,
  module(L: BusinessProfileInterface with
    type mapperInput = a
    and type commonProfileDict = b
    and type requestType = c
  ),
  inp: a,
): b => {
  L.mapJsonToCommonType(inp)
}
let mapJsonToRequestType = (
  type a b c,
  module(L: BusinessProfileInterface with
    type mapperInput = a
    and type commonProfileDict = b
    and type requestType = c
  ),
  inp: a,
): c => {
  L.mapJsonToRequestType(inp)
}
