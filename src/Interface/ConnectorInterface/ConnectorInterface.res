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

let useConnectorMapper = (type t, mapperModule: connectorMapper<t>, dict: Dict.t<JSON.t>): t => {
  getConnectorMapper(mapperModule, dict)
}
// Example

let result1 = useConnectorMapper(connectorMapperV1, Dict.make())
let result2 = useConnectorMapper(connectorMapperV2, Dict.make())

let result3 = getConnectorMapper(connectorMapperV1, Dict.make())
