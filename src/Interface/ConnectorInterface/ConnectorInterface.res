open ConnectorTypes
open ConnectorInterfaceUtils

// Interface
module type ConnectorInterface = {
  type mapperInput
  type mapperOutput
  type filterCriteria
  type input
  type output
  let mapDictToConnectorPayload: mapperInput => mapperOutput
  let mapJsonArrayToConnectorPayloads: (JSON.t, filterCriteria) => array<mapperOutput>
  let mapConnectorPayloadToConnectorType: (input, array<mapperOutput>) => array<output>
}

// Each module implements the ConnectorInterface and maps to common types with respective intermediate types

// Module Implementation for V1
module V1: ConnectorInterface
  with type mapperInput = Dict.t<JSON.t>
  and type mapperOutput = connectorPayloadCommonType
  and type filterCriteria = connectorTypeVariants
  and type input = connector
  and type output = connectorTypes = {
  type mapperInput = Dict.t<JSON.t>
  type mapperOutput = connectorPayloadCommonType
  type filterCriteria = connectorTypeVariants
  type input = connector
  type output = connectorTypes

  let mapDictToConnectorPayload = (dict: mapperInput): mapperOutput =>
    mapDictToConnectorPayload(dict)->mapV1DictToCommonConnectorPayload
  let mapJsonArrayToConnectorPayloads = (json: JSON.t, retainInList: filterCriteria) =>
    mapJsonArrayToConnectorPayloads(json, retainInList)
  let mapConnectorPayloadToConnectorType = (
    connectorType: input,
    connectorList: array<mapperOutput>,
  ): array<output> => mapConnectorPayloadToConnectorType(~connectorType, connectorList)
}

// Module Implementation for V2
module V2: ConnectorInterface
  with type mapperInput = Dict.t<JSON.t>
  and type mapperOutput = connectorPayloadCommonType
  and type filterCriteria = connectorTypeVariants
  and type input = connector
  and type output = connectorTypes = {
  type mapperInput = Dict.t<JSON.t>
  type mapperOutput = connectorPayloadCommonType
  type filterCriteria = connectorTypeVariants
  type input = connector
  type output = connectorTypes
  let mapDictToConnectorPayload = (dict: mapperInput): mapperOutput =>
    mapDictToConnectorPayloadV2(dict)->mapV2DictToCommonConnectorPayload
  let mapJsonArrayToConnectorPayloads = (json: JSON.t, retainInList: filterCriteria) =>
    mapJsonArrayToConnectorPayloadsV2(json, retainInList)
  let mapConnectorPayloadToConnectorType = (
    connectorType: input,
    connectorList: array<mapperOutput>,
  ): array<output> => mapConnectorPayloadToConnectorTypeV2(~connectorType, connectorList)
}

//parametric polymorphism, connectorInterfaceFCM is a type that takes 5 type parameters
// This allows for parametric polymorphism, meaning we can generalize the ConnectorInterface module with different types ('a, 'b, etc.).
type connectorInterfaceFCM<'a, 'b, 'c, 'd, 'e> = module(ConnectorInterface with
  type mapperInput = 'a
  and type mapperOutput = 'b
  and type filterCriteria = 'c
  and type input = 'd
  and type output = 'e
)

//Creating Instances of the Interface

//Defines connectorInterfaceV1 as an instance of ConnectorInterface using V1.
let connectorInterfaceV1: connectorInterfaceFCM<
  Dict.t<JSON.t>,
  connectorPayloadCommonType,
  connectorTypeVariants,
  connector,
  connectorTypes,
> = module(V1)

// Defines connectorInterfaceV2 using V2.
let connectorInterfaceV2: connectorInterfaceFCM<
  Dict.t<JSON.t>,
  connectorPayloadCommonType,
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
  type a b c d e,
  module(L: ConnectorInterface with
    type mapperInput = a
    and type mapperOutput = b
    and type filterCriteria = c
    and type input = d
    and type output = e
  ),
  inp: a,
): b => {
  L.mapDictToConnectorPayload(inp)
}

let mapJsonArrayToConnectorPayloads = (
  type a b c d e,
  module(L: ConnectorInterface with
    type mapperInput = a
    and type mapperOutput = b
    and type filterCriteria = c
    and type input = d
    and type output = e
  ),
  inp: JSON.t,
  filterCriteria: c,
): array<b> => {
  L.mapJsonArrayToConnectorPayloads(inp, filterCriteria)
}

let mapConnectorPayloadToConnectorType = (
  type a b c d e,
  module(L: ConnectorInterface with
    type mapperInput = a
    and type mapperOutput = b
    and type filterCriteria = c
    and type input = d
    and type output = e
  ),
  inp1: d,
  inp2: array<b>,
): array<e> => {
  L.mapConnectorPayloadToConnectorType(inp1, inp2)
}

let useConnectorArrayMapper = (~interface, ~retainInList=PaymentProcessor) => {
  let json = Recoil.useRecoilValueFromAtom(HyperswitchAtom.connectorListAtom)
  let data = mapJsonArrayToConnectorPayloads(interface, json, retainInList)
  data
}
