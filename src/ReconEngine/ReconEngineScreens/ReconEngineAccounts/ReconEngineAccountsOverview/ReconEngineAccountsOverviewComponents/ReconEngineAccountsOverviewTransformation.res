open Typography

@react.component
let make = (
  ~ingestionHistoryId: string,
  ~setSelectedTransformationHistoryId: (string => string) => unit,
  ~onTransformationStatusChange: option<bool => unit>=?,
) => {
  open ReconEngineIngestionHelper
  open APIUtils
  open LogicUtils
  open ReconEngineFileManagementUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (transformationHistoryData, setTransformationHistoryData) = React.useState(_ => [])
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

  let fetchTransformationHistory = async () => {
    if ingestionHistoryId->isNonEmptyString {
      setScreenState(_ => PageLoaderWrapper.Loading)
      try {
        let transformationHistoryUrl = getURL(
          ~entityName=V1(HYPERSWITCH_RECON),
          ~methodType=Get,
          ~hyperswitchReconType=#TRANSFORMATION_HISTORY,
          ~queryParamerters=Some(`ingestion_history_id=${ingestionHistoryId}`),
        )
        let transformationHistoryRes = await fetchDetails(transformationHistoryUrl)
        let transformationHistoryList =
          transformationHistoryRes->getArrayDataFromJson(transformationHistoryItemToObjMapper)
        setTransformationHistoryData(_ => transformationHistoryList)

        let allProcessed =
          transformationHistoryList->Array.every(entry => entry.status === "processed")
        switch onTransformationStatusChange {
        | Some(callback) => callback(allProcessed)
        | None => ()
        }

        switch transformationHistoryList->getNonEmptyArray {
        | Some(arr) => {
            let firstItem =
              arr->getValueFromArray(0, Dict.make()->transformationHistoryItemToObjMapper)
            setSelectedTransformationHistoryId(_ => firstItem.transformation_history_id)
          }
        | None => ()
        }
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Custom)
      }
    }
  }

  React.useEffect(() => {
    fetchTransformationHistory()->ignore
    None
  }, [ingestionHistoryId])

  let detailsFields: array<ReconEngineFileManagementEntity.transformationHistoryColType> = [
    TransformationName,
    TransformationHistoryId,
    TransformationStats,
    TransformedAt,
    TransformationComments,
  ]

  let tabs: array<Tabs.tab> = React.useMemo(() => {
    open Tabs
    transformationHistoryData->Array.map(config => {
      title: config.transformation_name,
      onTabSelection: {
        _ => setSelectedTransformationHistoryId(_ => config.transformation_history_id)
      },
      renderContent: () => {
        <div className="flex flex-col gap-4 py-4 px-2">
          <div className="grid grid-cols-4 gap-4 justify-items-start">
            {detailsFields
            ->Array.map(
              colType => {
                <DisplayKeyValueParams
                  key={LogicUtils.randomString(~length=10)}
                  heading={ReconEngineFileManagementEntity.getTransformationHistoryHeading(colType)}
                  value={ReconEngineFileManagementEntity.getTransformationHistoryCell(
                    config,
                    colType,
                  )}
                />
              },
            )
            ->React.array}
          </div>
          <Button buttonType=Secondary text="View Mappers" customButtonStyle="!w-fit" />
        </div>
      },
    })
  }, [transformationHistoryData])
  <PageLoaderWrapper
    screenState
    customUI={<NewAnalyticsHelper.NoData height="h-80" message="No data available." />}
    customLoader={<Shimmer styleClass="h-80 w-full rounded-b-xl" />}>
    <div className="flex flex-col px-6 py-3">
      <Tabs
        tabs
        showBorder=true
        includeMargin=false
        defaultClasses={`!w-max flex flex-auto flex-row items-center justify-center ${body.sm.semibold}`}
        selectTabBottomBorderColor="bg-primary"
      />
    </div>
  </PageLoaderWrapper>
}
