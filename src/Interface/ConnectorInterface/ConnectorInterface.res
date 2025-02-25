open ConnectorTypes
open ConnectorInterfaceUtils
module type ConnectorMappperType = {
  type output
  let getProcessorPayloadType: Dict.t<JSON.t> => output
}

module V1: ConnectorMappperType with type output = connectorPayload = {
  type output = connectorPayload
  let getProcessorPayloadType = (dict: Dict.t<JSON.t>) => getProcessorPayloadType(dict)
}

module V2: ConnectorMappperType with type output = connectorPayloadV2 = {
  type output = connectorPayloadV2
  let getProcessorPayloadType = (dict: Dict.t<JSON.t>) => getProcessorPayloadTypeV2(dict)
}

type connectorMapper<'a> = module(ConnectorMappperType with type output = 'a)

let connectorMapperV1: connectorMapper<connectorPayload> = module(V1)
let connectorMapperV2: connectorMapper<connectorPayloadV2> = module(V2)

let getConnectorMapper = (type t, mapperModule: connectorMapper<t>, dict: Dict.t<JSON.t>): t => {
  module L = unpack(mapperModule) // Extract the module
  L.getProcessorPayloadType(dict) // Call the function
}

let getArrayOfConnectorListPayloadType = json => {
  open LogicUtils
  json
  ->getArrayFromJson([])
  ->Array.map(connectorJson => {
    let data = connectorJson->getDictFromJsonObject
    getConnectorMapper(connectorMapperV1, data)
  })
}

let getArrayOfConnectorListPayloadTypeV2 = json => {
  open LogicUtils
  json
  ->getArrayFromJson([])
  ->Array.map(connectorJson => {
    let data = connectorJson->getDictFromJsonObject
    getConnectorMapper(connectorMapperV2, data)
  })
}

module type ConnectorArrayMapperType = {
  type output
  let getArrayOfConnectorListPayloadType: JSON.t => array<output>
}

module V1ArrayMapper: ConnectorArrayMapperType with type output = connectorPayload = {
  type output = connectorPayload
  let getArrayOfConnectorListPayloadType = (json: JSON.t) =>
    getArrayOfConnectorListPayloadType(json)
}

module V2ArrayMapper: ConnectorArrayMapperType with type output = connectorPayloadV2 = {
  type output = connectorPayloadV2
  let getArrayOfConnectorListPayloadType = (json: JSON.t) =>
    getArrayOfConnectorListPayloadTypeV2(json)
}

type connectorArrayMapper<'a> = module(ConnectorArrayMapperType with type output = 'a)

let connectorArrayMapperV1: connectorArrayMapper<connectorPayload> = module(V1ArrayMapper)
let connectorArrayMapperV2: connectorArrayMapper<connectorPayloadV2> = module(V2ArrayMapper)

let getConnectorArrayMapper = (type t, mapperModule: connectorArrayMapper<t>, json: JSON.t): array<
  t,
> => {
  module L = unpack(mapperModule) // Extract the module
  L.getArrayOfConnectorListPayloadType(json) // Call the function
}

module type FilterProcessorsList = {
  type input1
  type input2
  type output
  let getProcessorsFilterList: (input1, input2) => output
}

module V1FilterProcessorsList: FilterProcessorsList
  with type input1 = array<ConnectorTypes.connectorPayload>
  and type input2 = ConnectorTypes.connector
  and type output = array<ConnectorTypes.connectorPayload> = {
  type input1 = array<ConnectorTypes.connectorPayload>
  type input2 = ConnectorTypes.connector
  type output = array<ConnectorTypes.connectorPayload>

  let getProcessorsFilterList = (connectorList: input1, removeFromList: input2): output =>
    getProcessorsFilterList(connectorList, ~removeFromList)
}

module V2FilterProcessorsList: FilterProcessorsList
  with type input1 = array<ConnectorTypes.connectorPayloadV2>
  and type input2 = ConnectorTypes.connector
  and type output = array<ConnectorTypes.connectorPayloadV2> = {
  type input1 = array<ConnectorTypes.connectorPayloadV2>
  type input2 = ConnectorTypes.connector
  type output = array<ConnectorTypes.connectorPayloadV2>

  let getProcessorsFilterList = (connectorList: input1, removeFromList: input2): output =>
    getProcessorsFilterListV2(connectorList, ~removeFromList)
}

type filterProcessorsList<'a, 'b, 'c> = module(FilterProcessorsList with
  type input1 = 'a
  and type input2 = 'b
  and type output = 'c
)

let filterProcessorsListV1: filterProcessorsList<
  array<ConnectorTypes.connectorPayload>,
  ConnectorTypes.connector,
  array<ConnectorTypes.connectorPayload>,
> = module(V1FilterProcessorsList)

let filterProcessorsListV2: filterProcessorsList<
  array<ConnectorTypes.connectorPayloadV2>,
  ConnectorTypes.connector,
  array<ConnectorTypes.connectorPayloadV2>,
> = module(V2FilterProcessorsList)

let getProcessorsFilterList = (
  type a b c,
  module(L: FilterProcessorsList with type input1 = a and type input2 = b and type output = c),
  inp1: a,
  inp2: b,
): c => {
  L.getProcessorsFilterList(inp1, inp2)
}

module type ConvertConnectorNameToType = {
  type input1
  type input2
  type output
  let convertConnectorNameToType: (input1, input2) => output
}

module V1ConvertConnectorNameToType: ConvertConnectorNameToType
  with type input1 = ConnectorTypes.connector
  and type input2 = array<ConnectorTypes.connectorPayload>
  and type output = array<ConnectorTypes.connectorTypes> = {
  type input1 = ConnectorTypes.connector
  type input2 = array<ConnectorTypes.connectorPayload>
  type output = array<ConnectorTypes.connectorTypes>

  let convertConnectorNameToType = (connectorType: input1, connectorList: input2): output =>
    convertConnectorNameToType(~connectorType, connectorList)
}

module V2ConvertConnectorNameToType: ConvertConnectorNameToType
  with type input1 = ConnectorTypes.connector
  and type input2 = array<ConnectorTypes.connectorPayloadV2>
  and type output = array<ConnectorTypes.connectorTypes> = {
  type input1 = ConnectorTypes.connector
  type input2 = array<ConnectorTypes.connectorPayloadV2>
  type output = array<ConnectorTypes.connectorTypes>

  let convertConnectorNameToType = (connectorType: input1, connectorList: input2): output =>
    convertConnectorNameToTypeV2(~connectorType, connectorList)
}

type convertConnectorNameToType<'a, 'b, 'c> = module(ConvertConnectorNameToType with
  type input1 = 'a
  and type input2 = 'b
  and type output = 'c
)

let convertConnectorNameToTypeV1: convertConnectorNameToType<
  ConnectorTypes.connector,
  array<ConnectorTypes.connectorPayload>,
  array<ConnectorTypes.connectorTypes>,
> = module(V1ConvertConnectorNameToType)

let convertConnectorNameToTypeV2: convertConnectorNameToType<
  ConnectorTypes.connector,
  array<ConnectorTypes.connectorPayloadV2>,
  array<ConnectorTypes.connectorTypes>,
> = module(V2ConvertConnectorNameToType)

let convertConnectorNameToType = (
  type a b c,
  module(L: ConvertConnectorNameToType with
    type input1 = a
    and type input2 = b
    and type output = c
  ),
  inp1: a,
  inp2: b,
): c => {
  L.convertConnectorNameToType(inp1, inp2)
}

let useConnectorMapper = (type t, mapperModule: connectorMapper<t>, dict: Dict.t<JSON.t>): t => {
  getConnectorMapper(mapperModule, dict)
}
