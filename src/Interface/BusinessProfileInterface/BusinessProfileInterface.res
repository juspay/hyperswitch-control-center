let mapJsonToV1type: JSON.t => BusinessProfileInterfaceTypesV1.profileEntity_v1 = jsonInput => {
  BusinessProfileInterfaceUtilsV1.mapJsonToBusinessProfileV1(jsonInput)
}

let mapJsonToV2type: JSON.t => BusinessProfileInterfaceTypesV2.profileEntity_v2 = jsonInput => {
  BusinessProfileInterfaceUtilsV2.mapJsonToBusinessProfileV2(jsonInput)
}

let mapJsonToV1RequestType: JSON.t => BusinessProfileInterfaceTypesV1.profileEntityRequestType_v1 = jsonInput => {
  BusinessProfileInterfaceUtilsV1.commonTypeJsonToV1ForRequest(jsonInput)
}

let mapJsonToV2RequestType: JSON.t => BusinessProfileInterfaceTypesV2.profileEntityRequestType_v2 = jsonInput => {
  BusinessProfileInterfaceUtilsV2.commonTypeJsonToV2ForRequest(jsonInput)
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
  and type commonProfileDict = BusinessProfileInterfaceTypes.commonProfileEntity
  and type requestType = BusinessProfileInterfaceTypesV1.profileEntityRequestType_v1 = {
  type mapperInput = JSON.t
  type commonProfileDict = BusinessProfileInterfaceTypes.commonProfileEntity
  type requestType = BusinessProfileInterfaceTypesV1.profileEntityRequestType_v1

  let mapJsonToCommonType = (json: mapperInput): commonProfileDict =>
    mapJsonToV1type(json)->BusinessProfileInterfaceUtilsV1.mapV1toCommonType
  let mapJsonToRequestType = (json: mapperInput): requestType => mapJsonToV1RequestType(json)
}

module V2: BusinessProfileInterface
  with type mapperInput = JSON.t
  and type commonProfileDict = BusinessProfileInterfaceTypes.commonProfileEntity
  and type requestType = BusinessProfileInterfaceTypesV2.profileEntityRequestType_v2 = {
  type mapperInput = JSON.t
  type commonProfileDict = BusinessProfileInterfaceTypes.commonProfileEntity
  type requestType = BusinessProfileInterfaceTypesV2.profileEntityRequestType_v2

  let mapJsonToCommonType = (json: mapperInput): commonProfileDict =>
    mapJsonToV2type(json)->BusinessProfileInterfaceUtilsV2.mapV2toCommonType
  let mapJsonToRequestType = (json: mapperInput): requestType => mapJsonToV2RequestType(json)
}

type businessProfileFCM<'a, 'b, 'c> = module(BusinessProfileInterface with
  type mapperInput = 'a
  and type commonProfileDict = 'b
  and type requestType = 'c
)
let businessProfileInterfaceV1: businessProfileFCM<
  JSON.t,
  BusinessProfileInterfaceTypes.commonProfileEntity,
  BusinessProfileInterfaceTypesV1.profileEntityRequestType_v1,
> = module(V1)
let businessProfileInterfaceV2: businessProfileFCM<
  JSON.t,
  BusinessProfileInterfaceTypes.commonProfileEntity,
  BusinessProfileInterfaceTypesV2.profileEntityRequestType_v2,
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
