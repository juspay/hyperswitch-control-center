open LogicUtils

@react.component
let make = () => {
  open HSAnalyticsUtils
  open AlertsFilters

  let fetchDictionary = AlertsHooks.useAlertsDictionary()
  let {filterValueJson, filterValue, updateExistingKeys, reset} = React.useContext(
    FilterContext.filterContext,
  )

  let (alertsDictionary, setAlertsDictionary) = React.useState(_ =>
    Dict.make()->JSON.Encode.object->AlertsUtils.alertsDictionaryResponseMapper
  )
  let (alertsRefetch, setAlertsRefetch) = React.useState(() => () => ())
  let (resolvedRefetch, setResolvedRefetch) = React.useState(() => () => ())

  let defaultDate = HSwitchRemoteFilter.getDateFilteredObject(~range=7)
  let startTime = filterValueJson->getString(startTimeFilterKey, defaultDate.start_time)
  let endTime = filterValueJson->getString(endTimeFilterKey, defaultDate.end_time)

  let getAlertsDictionary = async () => {
    try {
      let result = await fetchDictionary()
      setAlertsDictionary(_ => result)
    } catch {
    | Exn.Error(_) => ()
    }
  }

  React.useEffect(() => {
    getAlertsDictionary()->ignore
    None
  }, [])

  let refresh = () => {
    alertsRefetch()
    resolvedRefetch()
    getAlertsDictionary()->ignore
  }

  let filters = AlertsFilters.initialFilters(~dictionary=alertsDictionary)

  <div className="flex flex-col gap-4">
    <div className="flex justify-between items-center">
      <PageUtils.PageHeading
        title="Alerts" customHeadingStyle="mb-2" subTitle="Monitoring & Merchant Success alerts"
      />
      <Button
        text="Refresh"
        buttonType=Secondary
        leftIcon={CustomIcon(<Icon name="sync" size=14 />)}
        onClick={_ => refresh()}
      />
    </div>
    <Filter
      key="AlertsFilters"
      title="Alerts"
      defaultFilters={""->JSON.Encode.string}
      fixedFilters={initialFixedFilter()}
      requiredSearchFieldsList=[]
      localFilters=filters
      localOptions=[]
      remoteOptions=[]
      remoteFilters=filters
      autoApply=false
      defaultFilterKeys=[
        startTimeFilterKey,
        endTimeFilterKey,
        priorityFilterKey,
        stateFilterKey,
        merchantIdFilterKey,
        profileIdFilterKey,
        connectorFilterKey,
        paymentMethodFilterKey,
      ]
      updateUrlWith=updateExistingKeys
      clearFilters={() => reset()}
    />
    <AlertsTable
      isResolved=false
      startTime
      endTime
      filterValueJson
      filterValue
      registerRefetch={fn => setAlertsRefetch(_ => fn)}
    />
    <div className="flex flex-col gap-2 mt-3">
      <div className={`${Typography.heading.sm.semibold} text-nd_gray-800`}>
        {"Resolved Alerts"->React.string}
      </div>
      <AlertsTable
        isResolved=true
        startTime
        endTime
        filterValueJson
        filterValue
        registerRefetch={fn => setResolvedRefetch(_ => fn)}
      />
    </div>
  </div>
}
