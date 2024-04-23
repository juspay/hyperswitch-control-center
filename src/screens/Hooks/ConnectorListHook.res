let useFetchConnectorList = () => {
  open APIUtils
  let fetchDetails = useGetMethod()
  let setConnectorList = HyperswitchAtom.connectorListAtom->Recoil.useSetRecoilState

  async _ => {
    try {
      let url = getURL(~entityName=CONNECTOR, ~methodType=Get, ())
      let res = await fetchDetails(url)
      setConnectorList(._ => res->ConnectorListMapper.getArrayOfConnectorListPayloadType)
      res
    } catch {
    | Exn.Error(e) => {
        let _ = GenericCatch.handleCatch(~error=e, ~raiseError=true, ())
        JSON.Encode.null
      }
    }
  }
}
