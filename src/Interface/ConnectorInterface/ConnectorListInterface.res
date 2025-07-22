open ConnectorTypes
open ConnectorInterfaceUtils

// Interface
module type ConnectorListInterface = {
  type jsonConnectorData
  type commonPayload
  type typedConnectorPayload
  type input
  type output

  let mapDictToIndividualConnectorPayload: jsonConnectorData => typedConnectorPayload
  let mapDictToConnectorPayload: jsonConnectorData => commonPayload
  let mapConnectorPayloadToConnectorType: (input, array<commonPayload>) => array<output>
}

// Each module implements the ConnectorListInterface and maps to common types with respective intermediate types

// Module Implementation for V1
module V1: ConnectorListInterface
  with type jsonConnectorData = Dict.t<JSON.t>
  and type commonPayload = connectorPayloadCommonType
  and type typedConnectorPayload = connectorPayload
  and type input = connector
  and type output = connectorTypes = {
  type jsonConnectorData = Dict.t<JSON.t>
  type commonPayload = connectorPayloadCommonType
  type typedConnectorPayload = connectorPayload
  type input = connector
  type output = connectorTypes

  let mapDictToIndividualConnectorPayload = (dict: jsonConnectorData): typedConnectorPayload =>
    mapDictToConnectorPayload(dict)
  let mapDictToConnectorPayload = (dict: jsonConnectorData): commonPayload =>
    mapDictToConnectorPayload(dict)->mapV1DictToCommonConnectorPayload
  let mapConnectorPayloadToConnectorType = (
    connectorType: input,
    connectorList: array<commonPayload>,
  ): array<output> => mapConnectorPayloadToConnectorType(~connectorType, connectorList)
}

// Module Implementation for V2
module V2: ConnectorListInterface
  with type jsonConnectorData = Dict.t<JSON.t>
  and type commonPayload = connectorPayloadCommonType
  and type typedConnectorPayload = connectorPayloadV2
  and type input = connector
  and type output = connectorTypes = {
  type jsonConnectorData = Dict.t<JSON.t>
  type commonPayload = connectorPayloadCommonType
  type typedConnectorPayload = connectorPayloadV2
  type input = connector
  type output = connectorTypes

  let mapDictToIndividualConnectorPayload = (dict: jsonConnectorData): typedConnectorPayload =>
    mapDictToConnectorPayloadV2(dict)
  let mapDictToConnectorPayload = (dict: jsonConnectorData): commonPayload =>
    mapDictToConnectorPayloadV2(dict)->mapV2DictToCommonConnectorPayload
  let mapConnectorPayloadToConnectorType = (
    connectorType: input,
    connectorList: array<commonPayload>,
  ): array<output> => mapConnectorPayloadToConnectorTypeV2(~connectorType, connectorList)
}

//parametric polymorphism, connectorInterfaceFCM is a type that takes 5 type parameters
// This allows for parametric polymorphism, meaning we can generalize the ConnectorListInterface module with different types ('a, 'b, etc.).
type connectorInterfaceFCM<'a, 'b, 'c, 'd, 'e> = module(ConnectorListInterface with
  type jsonConnectorData = 'a
  and type commonPayload = 'b
  and type typedConnectorPayload = 'c
  and type input = 'd
  and type output = 'e
)

//Creating Instances of the Interface

//Defines connectorInterfaceV1 as an instance of ConnectorListInterface using V1.
let connectorInterfaceV1: connectorInterfaceFCM<
  Dict.t<JSON.t>,
  connectorPayloadCommonType,
  connectorPayload,
  connector,
  connectorTypes,
> = module(V1)

// Defines connectorInterfaceV2 using V2.
let connectorInterfaceV2: connectorInterfaceFCM<
  Dict.t<JSON.t>,
  connectorPayloadCommonType,
  connectorPayloadV2,
  connector,
  connectorTypes,
> = module(V2)

// Generic Function: mapDictToConnectorPayload

// This function takes:
// 1. A module L implementing ConnectorListInterface.
// 2. An input of type a (jsonConnectorData).
// 3. It calls L.mapDictToConnectorPayload and returns the mapped output.
let mapDictToConnectorPayload = (
  type a b c d e,
  module(L: ConnectorListInterface with
    type jsonConnectorData = a
    and type commonPayload = b
    and type typedConnectorPayload = c
    and type input = d
    and type output = e
  ),
  inp: a,
): b => {
  L.mapDictToConnectorPayload(inp)
}

let mapDictToIndividualConnectorPayload = (
  type a b c d e,
  module(L: ConnectorListInterface with
    type jsonConnectorData = a
    and type commonPayload = b
    and type typedConnectorPayload = c
    and type input = d
    and type output = e
  ),
  inp: a,
): c => {
  L.mapDictToIndividualConnectorPayload(inp)
}

let mapConnectorPayloadToConnectorType = (
  type a b c d e,
  module(L: ConnectorListInterface with
    type jsonConnectorData = a
    and type commonPayload = b
    and type typedConnectorPayload = c
    and type input = d
    and type output = e
  ),
  inp1: d,
  inp2: array<b>,
): array<e> => {
  L.mapConnectorPayloadToConnectorType(inp1, inp2)
}

let useFilteredConnectorList = (~retainInList=PaymentProcessor) => {
  let list = Recoil.useRecoilValueFromAtom(HyperswitchAtom.connectorListAtom)
  filterConnectorList(list, retainInList)
}
