open APIUtils
open APIUtilsTypes
let useFetchConnectorList = (~entityName=V1(CONNECTOR), ~version=UserInfoTypes.V1) => {
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let setConnectorList = HyperswitchAtom.connectorListAtom->Recoil.useSetRecoilState

  async _ => {
    try {
      let url = getURL(~entityName, ~methodType=Get)
      let res = await fetchDetails(url, ~version)
      setConnectorList(_ => res)
      res
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }
}
