open SuperpositionHelper

@react.component
let make = (~showHeading=false) => {
  let api = SuperpositionHooks.useSuperpositionApi()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (logs, setLogs) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let (selectedLog, setSelectedLog) = React.useState(_ => None)

  let load = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let logs = await api.listAudit()
      setLogs(_ => logs)
      setScreenState(_ => logs->LogicUtils.isNonEmptyArray ? Success : Custom)
    } catch {
    | error =>
      setScreenState(_ => PageLoaderWrapper.Error(
        error->getExnMessage("Could not load the audit trail"),
      ))
    }
  }

  React.useEffect(() => {
    load()->ignore
    None
  }, [])

  <div className="flex flex-col gap-4">
    <RenderIf condition=showHeading>
      <PageUtils.PageHeading
        title="Audit Log" subTitle="Changes to feature values for this profile."
      />
      <FixedScope />
    </RenderIf>
    <PageLoaderWrapper
      screenState
      sectionHeight="h-40"
      customUI={<NewAnalyticsHelper.NoData height="h-40" message="No changes recorded yet." />}>
      <LoadedTable
        title="Superposition audit trail"
        hideTitle=true
        actualData={logs->Array.map(Nullable.make)}
        totalResults={logs->Array.length}
        resultsPerPage=20
        offset
        setOffset
        currentFetchCount={logs->Array.length}
        entity=SuperpositionTableEntity.auditEntity
        onEntityClick={log => setSelectedLog(_ => Some(log))}
        showResultsPerPageSelector=false
      />
    </PageLoaderWrapper>
    {switch selectedLog {
    | Some(log) =>
      <SuperpositionModals.AuditDetailModal
        showModal=true setShowModal={_ => setSelectedLog(_ => None)} log
      />
    | None => React.null
    }}
  </div>
}
