@react.component
let make = (~baseUrl) => {
  open ConnectorUtils
  open LogicUtils
  open APIUtils
  open PageLoaderWrapper
  open Typography

  let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->JSON.Encode.object)
  let (screenState, setScreenState) = React.useState(_ => Loading)

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()

  let url = RescriptReactRouter.useUrl()
  let connectorID = HSwitchUtils.getConnectorIDFromUrl(url.path->List.toArray, "")

  let getConnectorDetails = async () => {
    try {
      setScreenState(_ => Loading)
      let connectorUrl = getURL(
        ~entityName=V2(V2_CONNECTOR),
        ~methodType=Get,
        ~id=Some(connectorID),
      )
      let json = await fetchDetails(connectorUrl, ~version=V2)
      setInitialValues(_ => json)
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch vault details"))
    }
  }

  React.useEffect(() => {
    getConnectorDetails()->ignore
    None
  }, [])

  let data = initialValues->getDictFromJsonObject
  let connectorInfodict = ConnectorInterface.mapDictToTypedConnectorPayload(
    ConnectorInterface.connectorInterfaceV2,
    data,
  )

  // Use hardcoded config for vault processor
  let connectorDetails = VaultProcessorUtilsV2.getConnectorConfig()
  let {connectorAccountFields} = getConnectorFields(connectorDetails)

  <PageLoaderWrapper screenState>
    <BreadCrumbNavigation
      path=[{title: "Vault Processors", link: baseUrl}]
      currentPageTitle="Hyperswitch Vault Summary"
      dividerVal=Slash
      customTextClass="text-nd_gray-400 font-medium"
      childGapClass="gap-2"
      titleTextClass="text-nd_gray-600 font-medium"
    />
    <div className="flex flex-col gap-10 p-6">
      <div className="flex gap-4 items-center">
        <GatewayIcon gateway="HYPERSWITCH_VAULT" className="w-10 h-10 rounded-sm" />
        <p className={`${heading.lg.semibold} break-all`}>
          {"Hyperswitch Vault Summary"->React.string}
        </p>
      </div>
      <div className="flex flex-col gap-12">
        <div className="flex gap-10 max-w-3xl flex-wrap px-2">
          <div className="flex flex-col gap-0.5-rem">
            <h4 className="text-nd_gray-400"> {"Profile"->React.string} </h4>
            {connectorInfodict.profile_id->React.string}
          </div>
          <div className="flex flex-col gap-0.5-rem">
            <h4 className="text-nd_gray-400"> {"Connector Label"->React.string} </h4>
            {connectorInfodict.connector_label->React.string}
          </div>
        </div>
        <div className="flex flex-col gap-4">
          <p className="text-lg font-semibold text-nd_gray-600 border-b pb-4 px-2">
            {"Authentication Keys"->React.string}
          </p>
          <ConnectorHelperV2.PreviewCreds
            connectorInfo=connectorInfodict
            connectorAccountFields
            customContainerStyle="grid grid-cols-2 gap-12 flex-wrap max-w-3xl"
            customElementStyle="px-2"
          />
        </div>
      </div>
    </div>
  </PageLoaderWrapper>
}
