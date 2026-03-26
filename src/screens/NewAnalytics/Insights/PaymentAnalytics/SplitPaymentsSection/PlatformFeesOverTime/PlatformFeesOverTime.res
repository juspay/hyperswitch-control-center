open InsightsTypes
open InsightsHelper
open NewAnalyticsHelper
open PlatformFeesOverTimeUtils
open PlatformFeesOverTimeTypes

module TableModule = {
  open LogicUtils
  @react.component
  let make = (~data, ~className="") => {
    let (offset, setOffset) = React.useState(_ => 0)
    let defaultSort: Table.sortedObject = {
      key: "",
      order: Table.INC,
    }

    let visibleColumns = [Total_Platform_Fees, Time_Bucket, Connector]
    let tableData = getTableData(data)

    <div className>
      <LoadedTable
        visibleColumns
        title="Platform Fees Over Time"
        hideTitle=true
        actualData={tableData}
        entity=InsightsPaymentAnalyticsEntity.platformFeesOverTimeTableEntity
        resultsPerPage=10
        totalResults={tableData->Array.length}
        offset
        setOffset
        defaultSort
        currentFetchCount={tableData->Array.length}
        tableLocalFilter=false
        tableheadingClass=tableBorderClass
        tableBorderClass
        ignoreHeaderBg=true
        tableDataBorderClass=tableBorderClass
        isAnalyticsModule=true
      />
    </div>
  }
}

module PlatformFeesOverTimeHeader = {
  @react.component
  let make = (~viewType, ~setViewType, ~granularity, ~setGranularity, ~granularityOptions) => {
    let featureFlag = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

    let setViewType = value => {
      setViewType(_ => value)
    }

    let setGranularity = value => {
      setGranularity(_ => value)
    }

    <div className="w-full px-7 py-8 flex justify-between">
      <div className="flex justify-center">
        <RenderIf condition={featureFlag.granularity}>
          <NewAnalyticsHelper.Tabs
            option={granularity}
            setOption={setGranularity}
            options={granularityOptions}
            showSingleTab=false
          />
        </RenderIf>
      </div>
      <div className="flex gap-2">
        <TabSwitch viewType setViewType />
      </div>
    </div>
  }
}

@react.component
let make = (
  ~entity: moduleEntity,
  ~chartEntity: chartEntity<
    LineGraphTypes.lineGraphPayload,
    LineGraphTypes.lineGraphOptions,
    JSON.t,
  >,
) => {
  open LogicUtils
  open APIUtils
  open InsightsUtils
  open NewAnalyticsUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let isoStringToCustomTimeZone = TimeZoneHook.useIsoStringToCustomTimeZone()
  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (chartData, setChartData) = React.useState(_ => JSON.Encode.array([]))
  let (tableData, setTableData) = React.useState(_ => [])
  let (viewType, setViewType) = React.useState(_ => Graph)
  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")
  let currency = filterValueJson->getString((#currency: filters :> string), "")
  let featureFlag = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let defaulGranularity = getDefaultGranularity(
    ~startTime=startTimeVal,
    ~endTime=endTimeVal,
    ~granularity=featureFlag.granularity,
  )
  let granularityOptions = getGranularityOptions(~startTime=startTimeVal, ~endTime=endTimeVal)
  let (granularity, setGranularity) = React.useState(_ => defaulGranularity)

  React.useEffect(() => {
    if startTimeVal->isNonEmptyString && endTimeVal->isNonEmptyString {
      setGranularity(_ => defaulGranularity)
    }
    None
  }, (startTimeVal, endTimeVal))

  let splitFilters = SplitPaymentsSectionUtils.splitPaymentFilter()

  let getData = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let url = getURL(
        ~entityName=V1(ANALYTICS_PAYMENTS_V2),
        ~methodType=Post,
        ~id=Some((entity.domain: domain :> string)),
      )

      let filter = generateFilterObject(
        ~globalFilters=filterValueJson,
        ~localFilters=splitFilters->Some,
      )

      let body = requestBody(
        ~startTime=startTimeVal,
        ~endTime=endTimeVal,
        ~metrics=[#sessionized_total_platform_fees],
        ~groupByNames=["connector"]->Some,
        ~granularity=granularity.value->Some,
        ~filter=filter->Some,
      )

      let response = await updateDetails(url, body, Post)
      let responseData =
        response
        ->getDictFromJsonObject
        ->getArrayFromDict("queryData", [])
        ->sortQueryDataByDate

      setTableData(_ => responseData)

      if responseData->Array.length > 0 {
        let modifiedData = [responseData]->Array.map(data => {
          fillMissingDataPoints(
            ~data,
            ~startDate=startTimeVal,
            ~endDate=endTimeVal,
            ~timeKey="time_bucket",
            ~defaultValue={
              "total_platform_fees": 0,
              "time_bucket": startTimeVal,
            }->Identity.genericTypeToJson,
            ~granularity=granularity.value,
            ~isoStringToCustomTimeZone,
            ~granularityEnabled=featureFlag.granularity,
          )
        })
        setChartData(_ => modifiedData->Identity.genericTypeToJson)
        setScreenState(_ => PageLoaderWrapper.Success)
      } else {
        setScreenState(_ => PageLoaderWrapper.Custom)
      }
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  React.useEffect(() => {
    if startTimeVal->isNonEmptyString && endTimeVal->isNonEmptyString {
      getData()->ignore
    }
    None
  }, (startTimeVal, endTimeVal, granularity.value, currency))

  let params = {
    data: chartData,
    xKey: Total_Platform_Fees->getStringFromVariant,
    yKey: Time_Bucket->getStringFromVariant,
  }

  let options = chartEntity.getObjects(~params)->chartEntity.getChatOptions

  <div>
    <ModuleHeader title={entity.title} />
    <Card>
      <PageLoaderWrapper
        screenState customLoader={<Shimmer layoutId=entity.title />} customUI={<NoData />}>
        <PlatformFeesOverTimeHeader viewType setViewType granularity setGranularity granularityOptions />
        <div className="mb-5">
          {switch viewType {
          | Graph => <LineGraph options className="mr-3" />
          | Table => <TableModule data={tableData->JSON.Encode.array} className="mx-7" />
          }}
        </div>
      </PageLoaderWrapper>
    </Card>
  </div>
}
