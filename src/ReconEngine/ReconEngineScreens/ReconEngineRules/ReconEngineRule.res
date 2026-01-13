open Typography

open ReconEngineRulesEntity
@react.component
let make = () => {
  open APIUtils
  open ReconEngineRulesUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let (rulesData, setRulesData) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let resultsPerPage = 20
  let getRulesList = async _ => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#RECON_RULES,
      )
      let res = await fetchDetails(url)
      let rulesList = res->LogicUtils.getArrayDataFromJson(ruleItemToObjMapper)
      setRulesData(_ => rulesList)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  React.useEffect(() => {
    getRulesList()->ignore
    None
  }, [])

  <PageLoaderWrapper screenState>
    <div className="flex flex-col gap-8">
      <PageUtils.PageHeading
        title="Rules Library" customTitleStyle={`${heading.lg.semibold}`} customHeadingStyle="py-0"
      />
      <div className="bg-white rounded-lg">
        <LoadedTable
          title="Recon Rules"
          hideTitle=true
          actualData={rulesData->Array.map(Nullable.make)}
          entity={rulesTableEntity(`v1/recon-engine/rules`, ~authorization=Access)}
          resultsPerPage
          showSerialNumber=false
          totalResults={rulesData->Array.length}
          offset
          setOffset
          currrentFetchCount={rulesData->Array.length}
        />
      </div>
    </div>
  </PageLoaderWrapper>
}
