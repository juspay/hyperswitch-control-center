open ConnectorTypes
open ConnectorInterfaceUtils

// Interface
module type ConnectorInterface = {
  type mapperInput
  type mapperOutput
  type individualTypeOutput
  type filterCriteria
  type input
  type output

  let mapDictToIndividualConnectorPayload: mapperInput => individualTypeOutput
  let mapDictToConnectorPayload: mapperInput => mapperOutput
  let mapConnectorPayloadToConnectorType: (input, array<mapperOutput>) => array<output>
}

// Each module implements the ConnectorInterface and maps to common types with respective intermediate types

// Module Implementation for V1
module V1: ConnectorInterface
  with type mapperInput = Dict.t<JSON.t>
  and type mapperOutput = connectorPayloadCommonType
  and type individualTypeOutput = connectorPayload
  and type filterCriteria = connectorTypeVariants
  and type input = connector
  and type output = connectorTypes = {
  type mapperInput = Dict.t<JSON.t>
  type mapperOutput = connectorPayloadCommonType
  type individualTypeOutput = connectorPayload
  type filterCriteria = connectorTypeVariants
  type input = connector
  type output = connectorTypes

  let mapDictToIndividualConnectorPayload = (dict: mapperInput): individualTypeOutput =>
    mapDictToConnectorPayload(dict)
  let mapDictToConnectorPayload = (dict: mapperInput): mapperOutput =>
    mapDictToConnectorPayload(dict)->mapV1DictToCommonConnectorPayload
  let mapConnectorPayloadToConnectorType = (
    connectorType: input,
    connectorList: array<mapperOutput>,
  ): array<output> => mapConnectorPayloadToConnectorType(~connectorType, connectorList)
}

// Module Implementation for V2
module V2: ConnectorInterface
  with type mapperInput = Dict.t<JSON.t>
  and type mapperOutput = connectorPayloadCommonType
  and type individualTypeOutput = connectorPayloadV2
  and type filterCriteria = connectorTypeVariants
  and type input = connector
  and type output = connectorTypes = {
  type mapperInput = Dict.t<JSON.t>
  type mapperOutput = connectorPayloadCommonType
  type individualTypeOutput = connectorPayloadV2
  type filterCriteria = connectorTypeVariants
  type input = connector
  type output = connectorTypes

  let mapDictToIndividualConnectorPayload = (dict: mapperInput): individualTypeOutput =>
    mapDictToConnectorPayloadV2(dict)
  let mapDictToConnectorPayload = (dict: mapperInput): mapperOutput =>
    mapDictToConnectorPayloadV2(dict)->mapV2DictToCommonConnectorPayload
  let mapConnectorPayloadToConnectorType = (
    connectorType: input,
    connectorList: array<mapperOutput>,
  ): array<output> => mapConnectorPayloadToConnectorTypeV2(~connectorType, connectorList)
}

//parametric polymorphism, connectorInterfaceFCM is a type that takes 5 type parameters
// This allows for parametric polymorphism, meaning we can generalize the ConnectorInterface module with different types ('a, 'b, etc.).
type connectorInterfaceFCM<'a, 'b, 'c, 'd, 'e, 'f> = module(ConnectorInterface with
  type mapperInput = 'a
  and type mapperOutput = 'b
  and type individualTypeOutput = 'c
  and type filterCriteria = 'd
  and type input = 'e
  and type output = 'f
)

//Creating Instances of the Interface

//Defines connectorInterfaceV1 as an instance of ConnectorInterface using V1.
let connectorInterfaceV1: connectorInterfaceFCM<
  Dict.t<JSON.t>,
  connectorPayloadCommonType,
  connectorPayload,
  connectorTypeVariants,
  connector,
  connectorTypes,
> = module(V1)

// Defines connectorInterfaceV2 using V2.
let connectorInterfaceV2: connectorInterfaceFCM<
  Dict.t<JSON.t>,
  connectorPayloadCommonType,
  connectorPayloadV2,
  connectorTypeVariants,
  connector,
  connectorTypes,
> = module(V2)

// Generic Function: mapDictToConnectorPayload

// This function takes:
// 1. A module L implementing ConnectorInterface.
// 2. An input of type a (mapperInput).
// 3. It calls L.mapDictToConnectorPayload and returns the mapped output.
let mapDictToConnectorPayload = (
  type a b c d e f,
  module(L: ConnectorInterface with
    type mapperInput = a
    and type mapperOutput = b
    and type individualTypeOutput = c
    and type filterCriteria = d
    and type input = e
    and type output = f
  ),
  inp: a,
): b => {
  L.mapDictToConnectorPayload(inp)
}

let mapDictToIndividualConnectorPayload = (
  type a b c d e f,
  module(L: ConnectorInterface with
    type mapperInput = a
    and type mapperOutput = b
    and type individualTypeOutput = c
    and type filterCriteria = d
    and type input = e
    and type output = f
  ),
  inp: a,
): c => {
  L.mapDictToIndividualConnectorPayload(inp)
}

let mapConnectorPayloadToConnectorType = (
  type a b c d e f,
  module(L: ConnectorInterface with
    type mapperInput = a
    and type mapperOutput = b
    and type individualTypeOutput = c
    and type filterCriteria = d
    and type input = e
    and type output = f
  ),
  inp1: e,
  inp2: array<b>,
): array<f> => {
  L.mapConnectorPayloadToConnectorType(inp1, inp2)
}

let useFilteredConnectorList = (~retainInList=PaymentProcessor) => {
  let list = Recoil.useRecoilValueFromAtom(HyperswitchAtom.connectorListAtom)
  filterConnectorList(list, retainInList)
}
