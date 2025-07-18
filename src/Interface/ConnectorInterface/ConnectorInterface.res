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
  let mapListToFilteredConnectorList: (array<mapperOutput>, filterCriteria) => array<mapperOutput>
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
  let mapListToFilteredConnectorList = (list: array<mapperOutput>, retainInList: filterCriteria) =>
    mapListToFilteredConnectorList(list, retainInList)
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
  let mapListToFilteredConnectorList = (list: array<mapperOutput>, retainInList: filterCriteria) =>
    mapListToFilteredConnectorListV2(list, retainInList)
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

let mapListToFilteredConnectorList = (
  type a b c d e,
  module(L: ConnectorInterface with
    type mapperInput = a
    and type mapperOutput = b
    and type filterCriteria = c
    and type input = d
    and type output = e
  ),
  inp: array<b>,
  filterCriteria: c,
): array<b> => {
  L.mapListToFilteredConnectorList(inp, filterCriteria)
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
  let list = Recoil.useRecoilValueFromAtom(HyperswitchAtom.connectorListAtom)
  let data = mapListToFilteredConnectorList(interface, list, retainInList)
  data
}
