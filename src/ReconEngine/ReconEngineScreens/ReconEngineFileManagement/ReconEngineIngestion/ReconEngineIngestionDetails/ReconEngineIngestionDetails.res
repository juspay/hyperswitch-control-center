open Typography

@react.component
let make = (~id) => {
  open LogicUtils
  open APIUtils
  open ReconEngineFileManagementUtils
  open ReconEngineIngestionHelper

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (ingestionHistoryData, setIngestionHistoryData) = React.useState(_ =>
    Dict.make()->ingestionHistoryItemToObjMapper
  )

  let fetchIngestionHistoryData = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let stagingUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#INGESTION_HISTORY,
        ~id=Some(id),
      )
      let res = await fetchDetails(stagingUrl)
      let ingestionHistoryData = res->getDictFromJsonObject->ingestionHistoryItemToObjMapper
      setIngestionHistoryData(_ => ingestionHistoryData)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  React.useEffect(() => {
    fetchIngestionHistoryData()->ignore
    None
  }, [])

  <div className="flex flex-col gap-4 mb-8">
    <BreadCrumbNavigation
      path=[{title: "File Management", link: `/v1/recon-engine/file-management/ingestion-history`}]
      currentPageTitle=id
      cursorStyle="cursor-pointer"
      customTextClass="text-nd_gray-400"
      titleTextClass="text-nd_gray-600 font-medium"
      fontWeight="font-medium"
      dividerVal=Slash
      childGapClass="gap-2"
    />
    <PageUtils.PageHeading
      title="Ingestion History Detail" customTitleStyle={`${heading.lg.semibold} py-0 mt-2`}
    />
    <PageLoaderWrapper screenState>
      <IngestionHistoryDetailsInfo
        ingestionHistoryData detailsFields=[IngestionHistoryId, Status, UploadType, UploadedAt]
      />
      <ReconEngineTransformationHistory selectedIngestionHistory=ingestionHistoryData />
    </PageLoaderWrapper>
  </div>
}
