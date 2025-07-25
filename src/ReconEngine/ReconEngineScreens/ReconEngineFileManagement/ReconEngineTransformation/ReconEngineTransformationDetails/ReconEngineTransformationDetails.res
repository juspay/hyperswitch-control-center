open Typography

@react.component
let make = (~transformationHistoryId) => {
  open LogicUtils
  open APIUtils
  open ReconEngineFileManagementUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (transformationHistoryData, setTransformationHistoryData) = React.useState(_ =>
    Dict.make()->transformationHistoryItemToObjMapper
  )

  let fetchTransformationHistoryDetails = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#TRANSFORMATION_HISTORY,
        ~queryParamerters=None,
        ~id=Some(transformationHistoryId),
      )

      let res = await fetchDetails(url)
      let transformationHistoryData =
        res->getDictFromJsonObject->transformationHistoryItemToObjMapper
      setTransformationHistoryData(_ => transformationHistoryData)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  React.useEffect(() => {
    fetchTransformationHistoryDetails()->ignore
    None
  }, [])

  <PageLoaderWrapper
    screenState
    customLoader={<div className="h-full flex flex-col justify-center items-center">
      <div className="animate-spin">
        <Icon name="spinner" size=20 />
      </div>
    </div>}>
    <div className="flex flex-col gap-4">
      <BreadCrumbNavigation
        path=[
          {title: "File Management", link: `/v1/recon-engine/file-management/ingestion-history`},
          {
            title: transformationHistoryData.ingestion_history_id,
            link: `/v1/recon-engine/file-management/ingestion-history/${transformationHistoryData.ingestion_history_id}`,
          },
        ]
        currentPageTitle=transformationHistoryId
        cursorStyle="cursor-pointer"
        customTextClass="text-nd_gray-400"
        titleTextClass="text-nd_gray-600 font-medium"
        fontWeight="font-medium"
        dividerVal=Slash
        childGapClass="gap-2"
      />
      <PageUtils.PageHeading
        title=transformationHistoryData.transformation_name
        customTitleStyle={`${heading.lg.semibold} py-0 mt-2`}
        subTitle="Check the transformation history for the selected ingestion."
        customSubTitleStyle={body.lg.medium}
      />
      <p className={`${heading.sm.medium} text-nd_gray-400`}>
        <span className={`${heading.xl.semibold} text-nd_gray-800 mr-1`}>
          {`${transformationHistoryData.data.transformed_count->Int.toString}`->React.string}
        </span>
        {`out of ${transformationHistoryData.data.total_count->Int.toString} processed`->React.string}
      </p>
      <ReconEngineTransformationStagingEntries transformationHistoryId={transformationHistoryId} />
    </div>
  </PageLoaderWrapper>
}
