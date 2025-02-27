open ConnectorTypes
open ConnectorInterfaceUtils

module type ConnectorInterface = {
  type mapperInput
  type mapperOutput
  type filterCriteria
  type input
  type output
  let getProcessorPayloadType: mapperInput => mapperOutput
  let getArrayOfConnectorListPayloadType: (JSON.t, filterCriteria) => array<mapperOutput>
  let convertConnectorNameToType: (input, array<mapperOutput>) => array<output>
}

module V1: ConnectorInterface
  with type mapperInput = Dict.t<JSON.t>
  and type mapperOutput = connectorPayload
  and type filterCriteria = ConnectorTypes.connectorTypeVariants
  and type input = ConnectorTypes.connector
  and type output = ConnectorTypes.connectorTypes = {
  type mapperInput = Dict.t<JSON.t>
  type mapperOutput = connectorPayload
  type filterCriteria = ConnectorTypes.connectorTypeVariants
  type input = ConnectorTypes.connector
  type output = ConnectorTypes.connectorTypes

  let getProcessorPayloadType = (dict: mapperInput): mapperOutput => getProcessorPayloadType(dict)
  let getArrayOfConnectorListPayloadType = (json: JSON.t, retainInList: filterCriteria) =>
    ConnectorInterfaceUtilsV2.getArrayOfConnectorListPayloadType(json, retainInList)
  let convertConnectorNameToType = (
    connectorType: input,
    connectorList: array<mapperOutput>,
  ): array<output> => convertConnectorNameToType(~connectorType, connectorList)
}

module V2: ConnectorInterface
  with type mapperInput = Dict.t<JSON.t>
  and type mapperOutput = connectorPayloadV2
  and type filterCriteria = ConnectorTypes.connectorTypeVariants
  and type input = ConnectorTypes.connector
  and type output = ConnectorTypes.connectorTypes = {
  type mapperInput = Dict.t<JSON.t>
  type mapperOutput = connectorPayloadV2
  type filterCriteria = ConnectorTypes.connectorTypeVariants
  type input = ConnectorTypes.connector
  type output = ConnectorTypes.connectorTypes
  let getProcessorPayloadType = (dict: mapperInput): mapperOutput => getProcessorPayloadTypeV2(dict)
  let getArrayOfConnectorListPayloadType = (json: JSON.t, retainInList: filterCriteria) =>
    ConnectorInterfaceUtilsV2.getArrayOfConnectorListPayloadTypeV2(json, retainInList)
  let convertConnectorNameToType = (
    connectorType: input,
    connectorList: array<mapperOutput>,
  ): array<output> => convertConnectorNameToTypeV2(~connectorType, connectorList)
}

type connectorInterfaceFCM<'a, 'b, 'c, 'd, 'e> = module(ConnectorInterface with
  type mapperInput = 'a
  and type mapperOutput = 'b
  and type filterCriteria = 'c
  and type input = 'd
  and type output = 'e
)

let connectorInterfaceV1: connectorInterfaceFCM<
  Dict.t<JSON.t>,
  connectorPayload,
  ConnectorTypes.connectorTypeVariants,
  ConnectorTypes.connector,
  ConnectorTypes.connectorTypes,
> = module(V1)

let connectorInterfaceV2: connectorInterfaceFCM<
  Dict.t<JSON.t>,
  connectorPayloadV2,
  ConnectorTypes.connectorTypeVariants,
  ConnectorTypes.connector,
  ConnectorTypes.connectorTypes,
> = module(V2)

let getConnectorMapper = (
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
  L.getProcessorPayloadType(inp)
}

let getConnectorArrayMapper = (
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
  L.getArrayOfConnectorListPayloadType(inp, filterCriteria)
}

let convertConnectorNameToType = (
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
  L.convertConnectorNameToType(inp1, inp2)
}

let useConnectorArrayMapper = (~interface, ~retainInList=PaymentProcessor) => {
  let json = Recoil.useRecoilValueFromAtom(HyperswitchAtom.connectorListAtom)
  let data = getConnectorArrayMapper(interface, json, retainInList)
  data
}

let test2 = getConnectorMapper(connectorInterfaceV1, Dict.make())

let test4 = getConnectorArrayMapper(connectorInterfaceV1, JSON.Encode.null, PaymentProcessor)
