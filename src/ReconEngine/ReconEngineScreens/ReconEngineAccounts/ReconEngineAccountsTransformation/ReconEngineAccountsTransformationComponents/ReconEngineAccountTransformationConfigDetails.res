open Typography

@react.component
let make = (
  ~config: ReconEngineFileManagementTypes.transformationConfigType,
  ~tabIndex: string,
) => {
  open APIUtils
  open LogicUtils
  open ReconEngineFileManagementUtils
  open ReconEngineAccountsTransformationUtils
  open ReconEngineAccountsTransformationHelper

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (transformationHistoryList, setTransformationHistoryList) = React.useState(_ => [
    Dict.make()->transformationHistoryItemToObjMapper,
  ])

  let fetchTransformationHistoryData = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let transformationHistoryUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#TRANSFORMATION_HISTORY,
        ~queryParamerters=Some(`transformation_id=${config.id}`),
      )
      let transformationHistoryRes = await fetchDetails(transformationHistoryUrl)
      let transformationHistoryList =
        transformationHistoryRes->getArrayDataFromJson(transformationHistoryItemToObjMapper)

      setTransformationHistoryList(_ => transformationHistoryList)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  React.useEffect(() => {
    fetchTransformationHistoryData()->ignore
    None
  }, [config.ingestion_id])

  let transformationConfigItems = React.useMemo(() => {
    ReconEngineAccountsTransformationUtils.getTransformationConfigData(~config)
  }, config)

  let (_percentage, label, labelColor) = React.useMemo(() => {
    getHealthyStatus(~transformationHistoryList)
  }, [transformationHistoryList])

  <PageLoaderWrapper
    screenState
    customUI={<NewAnalyticsHelper.NoData height="h-44" message="No data available." />}
    customLoader={<Shimmer styleClass="h-44 w-full rounded-xl" />}>
    <Link
      to_={GlobalVars.appendDashboardPath(
        ~url=`/v1/recon-engine/transformation/${config.account_id}?transformationConfigTabIndex=${tabIndex}`,
      )}
      className="p-5 border border-nd_gray-200 rounded-lg hover:border-nd_primary_blue-400 transition-colors duration-200 cursor-pointer">
      <div
        className="flex md:flex-row items-center justify-between gap-4 w-full border-b pb-2 border-nd_gray-150">
        <p className={`${body.md.semibold} text-nd_gray-800 truncate`}>
          {config.name->React.string}
        </p>
        <Table.TableCell
          cell={Label({
            title: label,
            color: labelColor,
          })}
          textAlign=Table.Left
          labelMargin="!py-0"
        />
      </div>
      <div className="mt-4 grid xl:grid-cols-2 grid-cols-1 items-start gap-y-8 gap-x-20">
        {transformationConfigItems
        ->Array.map(item => {
          <TransformationConfigItem key={(item.label :> string)} data={item} />
        })
        ->React.array}
      </div>
    </Link>
  </PageLoaderWrapper>
}
