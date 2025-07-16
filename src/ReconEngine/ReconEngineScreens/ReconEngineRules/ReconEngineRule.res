open ReconEngineRulesEntity
@react.component
let make = () => {
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let (rulesData, setRulesData) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let resultsPerPage = 20
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  React.useEffect(() => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let response = SampleData.rules
      let data = response->LogicUtils.getArrayDataFromJson(ruleItemToObjMapper)
      setRulesData(_ => data)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to load rules data"))
    }
    None
  }, [])

  <PageLoaderWrapper screenState>
    <div className="flex flex-col gap-8 p-6">
      <PageUtils.PageHeading
        title="Rules Library" subTitle="View your Rules and their details" customHeadingStyle="py-0"
      />
      <div className="bg-white rounded-lg">
        <LoadedTable
          title="Recon Rules"
          hideTitle=true
          actualData={rulesData->Array.map(Nullable.make)}
          entity={rulesTableEntity(
            `v1/recon-engine/rules`,
            ~authorization=userHasAccess(~groupAccess=UsersManage),
          )}
          resultsPerPage
          showSerialNumber=true
          totalResults={rulesData->Array.length}
          offset
          setOffset
          currrentFetchCount={rulesData->Array.length}
        />
      </div>
    </div>
  </PageLoaderWrapper>
}
