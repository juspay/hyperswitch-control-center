open Typography

@react.component
let make = (
  ~ingestionHistoryId: string,
  ~setSelectedTransformationHistoryId: (string => string) => unit,
  ~onTransformationStatusChange: option<bool => unit>=?,
  ~transformationConfigTabIndex: option<string>,
) => {
  open ReconEngineHooks
  open ReconEngineAccountsSourcesHelper
  open LogicUtils
  open ReconEngineAccountsOverviewUtils

  let url = RescriptReactRouter.useUrl()
  let getTransformationHistory = useGetTransformationHistory()
  let (transformationHistoryData, setTransformationHistoryData) = React.useState(_ => [])
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

  let fetchTransformationHistory = async () => {
    if ingestionHistoryId->isNonEmptyString {
      setScreenState(_ => PageLoaderWrapper.Loading)
      try {
        let transformationHistoryList = await getTransformationHistory(
          ~queryParamerters=Some(`ingestion_history_id=${ingestionHistoryId}`),
        )
        setTransformationHistoryData(_ => transformationHistoryList)

        let allProcessed =
          transformationHistoryList->Array.every(entry => entry.status === Processed)
        switch onTransformationStatusChange {
        | Some(callback) => callback(allProcessed)
        | None => ()
        }

        switch transformationHistoryList->getNonEmptyArray {
        | Some(arr) => {
            let selectedIndex = transformationConfigTabIndex->Option.getOr("0")->getIntFromString(0)
            let selectedItem =
              arr->getValueFromArray(
                selectedIndex,
                Dict.make()->getAccountsOverviewTransformationHistoryPayloadFromDict,
              )
            setSelectedTransformationHistoryId(_ => selectedItem.transformation_history_id)
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
  }, (ingestionHistoryId, transformationConfigTabIndex))

  let detailsFields: array<ReconEngineAccountsSourcesEntity.transformationHistoryColType> = [
    TransformationName,
    TransformationHistoryId,
    TransformationStats,
    TransformedAt,
    TransformationComments,
  ]

  let getActiveTabIndex = React.useMemo(() => {
    let urlTransformationHistoryId =
      url.search
      ->getDictFromUrlSearchParams
      ->getvalFromDict("transformationHistoryId")

    switch urlTransformationHistoryId {
    | Some(historyId) =>
      transformationHistoryData->Array.findIndex(config =>
        config.transformation_history_id === historyId
      )
    | None => 0
    }
  }, (url.search, transformationHistoryData))

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
                  heading={ReconEngineAccountsSourcesEntity.getTransformationHistoryHeading(
                    colType,
                  )}
                  value={ReconEngineAccountsSourcesEntity.getTransformationHistoryCell(
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
        initialIndex={getActiveTabIndex}
        tabs
        showBorder=true
        includeMargin=false
        defaultClasses={`!w-max flex flex-auto flex-row items-center justify-center ${body.sm.semibold}`}
        selectTabBottomBorderColor="bg-primary"
      />
    </div>
  </PageLoaderWrapper>
}
