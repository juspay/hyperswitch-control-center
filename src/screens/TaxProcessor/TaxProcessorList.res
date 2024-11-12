@react.component
let make = () => {
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let (configuredConnectors, setConfiguredConnectors) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let connectorList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.connectorListAtom)

  let getConnectorList = async _ => {
    try {
      let taxConnectorsList =
        connectorList->Array.filter(item =>
          item.connector_type->ConnectorUtils.connectorTypeStringToTypeMapper === TaxProcessor
        )

      setConfiguredConnectors(_ => taxConnectorsList)
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  React.useEffect(() => {
    getConnectorList()->ignore
    None
  }, [])

  <div>
    <PageUtils.PageHeading
      title={"Tax Processors"} subTitle={"Connect and configure Tax Processor"}
    />
    <PageLoaderWrapper screenState>
      <div className="flex flex-col gap-10">
        <RenderIf condition={configuredConnectors->Array.length > 0}>
          <LoadedTable
            title="Connected Processors"
            actualData={configuredConnectors->Array.map(Nullable.make)}
            totalResults={configuredConnectors->Array.map(Nullable.make)->Array.length}
            resultsPerPage=20
            entity={TaxProcessorTableEntity.taxProcessorEntity(
              `tax-processor`,
              ~authorization=userHasAccess(~groupAccess=ConnectorsManage),
            )}
            offset
            setOffset
            currrentFetchCount={configuredConnectors->Array.map(Nullable.make)->Array.length}
            collapseTableRow=false
          />
        </RenderIf>
        <ProcessorCards
          configuredConnectors={configuredConnectors->ConnectorUtils.getConnectorTypeArrayFromListConnectors(
            ~connectorType=ConnectorTypes.TaxProcessor,
          )}
          connectorsAvailableForIntegration=ConnectorUtils.taxProcessorList
          urlPrefix="tax-processor/new"
          connectorType=ConnectorTypes.TaxProcessor
        />
      </div>
    </PageLoaderWrapper>
  </div>
}
