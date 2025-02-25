let useFetchConnectorList = () => {
  open APIUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let setConnectorList = HyperswitchAtom.connectorListAtomV2->Recoil.useSetRecoilState

  async _ => {
    try {
      let url = getURL(~entityName=CONNECTOR, ~methodType=Get)
      let res = await fetchDetails(url)
      let data = ConnectorInterface.getConnectorArrayMapper(
        ConnectorInterface.connectorArrayMapperV1,
        res,
      )
      setConnectorList(_ => data)
      res
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        Exn.raiseError(err)
      }
    }
  }
}
