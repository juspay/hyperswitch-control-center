open ConnectorTypes
open ConnectorInterfaceUtils

// Interface
module type ConnectorInterface = {
  type connectorDataDict
  type typedConnectorPayload

  let mapDictToTypedConnectorPayload: connectorDataDict => typedConnectorPayload
}

// Each module implements the ConnectorInterface and maps to respective connector types

// Module Implementation for V1
module V1: ConnectorInterface
  with type connectorDataDict = Dict.t<JSON.t>
  and type typedConnectorPayload = connectorPayload = {
  type connectorDataDict = Dict.t<JSON.t>
  type typedConnectorPayload = connectorPayload

  let mapDictToTypedConnectorPayload = (dict: connectorDataDict): typedConnectorPayload =>
    mapDictToConnectorPayload(dict)
}

// Module Implementation for V2
module V2: ConnectorInterface
  with type connectorDataDict = Dict.t<JSON.t>
  and type typedConnectorPayload = connectorPayloadV2 = {
  type connectorDataDict = Dict.t<JSON.t>
  type typedConnectorPayload = connectorPayloadV2

  let mapDictToTypedConnectorPayload = (dict: connectorDataDict): typedConnectorPayload =>
    mapDictToConnectorPayloadV2(dict)
}

//parametric polymorphism, connectorInterfaceFCM is a type that takes 5 type parameters
// This allows for parametric polymorphism, meaning we can generalize the ConnectorInterface module with different types ('a, 'b, etc.).
type connectorInterfaceFCM<'a, 'b> = module(ConnectorInterface with
  type connectorDataDict = 'a
  and type typedConnectorPayload = 'b
)

//Creating Instances of the Interface

//Defines connectorInterfaceV1 as an instance of ConnectorInterface using V1.
let connectorInterfaceV1: connectorInterfaceFCM<Dict.t<JSON.t>, connectorPayload> = module(V1)

// Defines connectorInterfaceV2 using V2.
let connectorInterfaceV2: connectorInterfaceFCM<Dict.t<JSON.t>, connectorPayloadV2> = module(V2)

// Generic Function: mapDictToTypedConnectorPayload

// This function takes:
// 1. A module L implementing ConnectorInterface.
// 2. An input of type a (connectorDataDict).
// 3. It calls L.mapDictToTypedConnectorPayload and returns the mapped output.
let mapDictToTypedConnectorPayload = (
  type a b,
  module(L: ConnectorInterface with type connectorDataDict = a and type typedConnectorPayload = b),
  inp: a,
): b => {
  L.mapDictToTypedConnectorPayload(inp)
}
