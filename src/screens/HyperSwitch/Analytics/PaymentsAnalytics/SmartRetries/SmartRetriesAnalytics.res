module SmartRetries = {
  @react.component
  let make = (
    ~pageTitle="",
    ~startTimeFilterKey: string,
    ~endTimeFilterKey: string,
    ~tabKeys: array<string>,
    ~initialFixedFilters: Js.Json.t => array<EntityType.initialFilters<'t>>,
    ~singleStatEntity: DynamicSingleStat.entityType<'singleStatColType, 'b, 'b2>,
    ~moduleName: string,
  ) => {
    let {updateExistingKeys, filterValueJson} = React.useContext(FilterContext.filterContext)
    let (_totalVolume, setTotalVolume) = React.useState(_ => 0)
    let defaultFilters = [startTimeFilterKey, endTimeFilterKey]

    let setInitialFilters = HSwitchRemoteFilter.useSetInitialFilters(
      ~updateExistingKeys,
      ~startTimeFilterKey,
      ~endTimeFilterKey,
    )

    React.useEffect0(() => {
      setInitialFilters()
      None
    })

    let headerTextStyle = HSwitchUtils.getTextClass(~textVariant=H1, ())

    <UIUtils.RenderIf condition={filterValueJson->Js.Dict.entries->Array.length > 0}>
      <div className="flex flex-col gap-0 mb-10">
        <div className={`${headerTextStyle} pt-2`}> {pageTitle->React.string} </div>
        <div className="mt-2 -ml-1">
          <DynamicFilter
            initialFilters=[]
            options=[]
            popupFilterFields=[]
            initialFixedFilters={initialFixedFilters(Js.Json.object_(Dict.make()))}
            defaultFilterKeys=defaultFilters
            tabNames=tabKeys
            updateUrlWith=updateExistingKeys //
            key="1"
            filtersDisplayOption=false
            filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
            showCustomFilter=false
            refreshFilters=false
          />
        </div>
        <DynamicSingleStat
          entity=singleStatEntity
          startTimeFilterKey
          endTimeFilterKey
          filterKeys=[]
          moduleName
          setTotalVolume
          showPercentage=false
          statSentiment={singleStatEntity.statSentiment->Belt.Option.getWithDefault(Dict.make())}
        />
      </div>
    </UIUtils.RenderIf>
  }
}

@react.component
let make = () => {
  open SmartRetriesAnalyticsEntity

  let metrics = [[("name", "retries_count"->Js.Json.string)]->Dict.fromArray->Js.Json.object_]

  <SmartRetries
    pageTitle="Smart Retries"
    key="PaymentsAnalytics"
    moduleName="Payments"
    tabKeys=[]
    singleStatEntity={getSingleStatEntity(metrics)}
    startTimeFilterKey
    endTimeFilterKey
    initialFixedFilters=HSAnalyticsUtils.initialFixedFilterFields
  />
}
