open APIUtils
open APIUtilsTypes
open LogicUtils
open ConnectorInterfaceUtils

let useFetchConnectorList = (~entityName=V1(CONNECTOR), ~version=UserInfoTypes.V1) => {
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let setConnectorList = HyperswitchAtom.connectorListAtom->Recoil.useSetRecoilState

  async _ => {
    try {
      let url = getURL(~entityName, ~methodType=Get)
      let res = await fetchDetails(url, ~version)

      let connectorList = switch version {
      | V1 =>
        res
        ->getArrayFromJson([])
        ->Array.map(connectorJson => {
          connectorJson
          ->getDictFromJsonObject
          ->mapDictToConnectorPayload
          ->mapV1DictToCommonConnectorPayload
        })
      | V2 =>
        res
        ->getArrayFromJson([])
        ->Array.map(connectorJson => {
          connectorJson
          ->getDictFromJsonObject
          ->mapDictToConnectorPayloadV2
          ->mapV2DictToCommonConnectorPayload
        })
      }
      setConnectorList(_ => connectorList)
      connectorList
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }
}
