open InsightsTypes
open SmartRetryStrategyAnalyticsUtils
@react.component
let make = (~entity: moduleEntity) => {
  open LogicUtils
  open APIUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (overallData, setOverallData) = React.useState(_ => [])

  let getOverallSR = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let url = getURL(~entityName=V1(ERROR_CATEGORY_ANALYSIS), ~methodType=Get)
      let primaryResponse = await fetchDetails(url, ~version=V1)

      let primaryData =
        primaryResponse
        ->getDictFromJsonObject
        ->getArrayFromDict(ErrorCategoryAnalysis->getStringFromVariant, [])

      setOverallData(_ => primaryData)

      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }
  React.useEffect(() => {
    getOverallSR()->ignore
    None
  }, [])

  let getSmartRetryGraphOptions = data => {
    data->Array.map(item => {
      let params = {
        data: item,
        xKey: "/icons/smart-retry.svg",
        yKey: TimeBucket->getStringFromVariant,
      }

      let itemDict = item->getDictFromJsonObject

      let title = itemDict->getString(GroupName->getStringFromVariant, "")

      let getValue = key =>
        itemDict->getString((key: SmartRetryStrategyAnalyticsTypes.responseKeys :> string), "")

      let description = `Billing State : ${getValue(#billing_state)}, 
      Card Funding : ${getValue(#card_funding)}, 
      Card Network : ${getValue(#card_network)}, 
      Card Issuer : ${getValue(#card_issuer)}`

      (title, LineScatterGraphUtils.getLineGraphOptions(smartRetriesMapper(~params)), description)
    })
  }

  let getMainChartOptions = (data, category) => {
    let params = {
      data: data->Identity.genericTypeToJson,
      xKey: SuccessRate->getStringFromVariant,
      yKey: TimeBucket->getStringFromVariant,
      title: category,
    }

    LineGraphUtils.getLineGraphOptions(overallSRMapper(~params))
  }

  let getTabs = () => {
    let tabs: array<Tabs.tab> = overallData->Array.map(data => {
      let primaryData = data->getDictFromJsonObject

      let category = primaryData->getString(Category->getStringFromVariant, "")

      let overallSRData =
        primaryData->getArrayFromDict(OverallSuccessRate->getStringFromVariant, [])
      let groupSRData = primaryData->getArrayFromDict(GroupwiseData->getStringFromVariant, [])

      let tab: Tabs.tab = {
        title: category,
        renderContent: () =>
          <div className="flex flex-col gap-5 mt-5">
            <div className="rounded-xl border border-gray-200 w-full bg-white">
              <div className="bg-gray-50 px-4 py-3 border-b border-gray-200 rounded-t-xl">
                <h2 className="font-medium text-gray-800">
                  {`Error Category : ${category}`->React.string}
                </h2>
              </div>
              <div className="p-4">
                <LineGraph
                  options={overallSRData->getMainChartOptions(category)} className="mr-3"
                />
              </div>
            </div>
            <div className="grid grid-cols-2 gap-5">
              {groupSRData
              ->getSmartRetryGraphOptions
              ->Array.map(item => {
                let (title, options, description) = item

                <div className="rounded-xl border border-gray-200 w-full bg-white">
                  <div
                    className="bg-gray-50 px-4 py-3 border-b border-gray-200 rounded-t-xl flex justify-between">
                    <h2 className="font-medium text-gray-800"> {title->React.string} </h2>
                    <ToolTip
                      description
                      toolTipFor={<div className="cursor-pointer flex gap-2 text-gray-700">
                        <Icon name="info-vacent" size=15 />
                        {"View Grouping"->React.string}
                      </div>}
                      toolTipPosition=ToolTip.Top
                      newDesign=true
                    />
                  </div>
                  <div className="p-4">
                    <LineScatterGraph options className="mr-3" />
                  </div>
                </div>
              })
              ->React.array}
            </div>
          </div>,
      }

      tab
    })

    tabs
  }

  <div>
    <div className="space-y-1 mb-5">
      <h2 className="text-xl font-semibold text-gray-900 mb-2"> {entity.title->React.string} </h2>
      <div className="bg-gray-50 text-gray-700 p-3 rounded-md border flex gap-2">
        <Icon size=15 name="info-circle-unfilled" />
        {"Smart retries are attempted by targeting specific error groups where the probability of success is highest."->React.string}
      </div>
    </div>
    <PageLoaderWrapper
      screenState
      customLoader={<InsightsHelper.Shimmer layoutId=entity.title className="h-64 rounded-lg" />}
      customUI={<InsightsHelper.NoData height="h-64 p-0 -m-0" />}>
      <Tabs
        initialIndex=0
        tabs={getTabs()}
        onTitleClick={_ => ()}
        disableIndicationArrow=true
        showBorder=true
        includeMargin=false
        lightThemeColor="black"
        defaultClasses="font-ibm-plex w-max flex flex-auto flex-row items-center justify-center px-6 font-semibold text-body"
      />
    </PageLoaderWrapper>
  </div>
}
