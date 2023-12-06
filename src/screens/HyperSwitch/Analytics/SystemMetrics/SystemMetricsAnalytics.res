module HeadingTile = {
  @react.component
  let make = (~pageTitle, ~pageSubTitle) => {
    <div className="flex items-center justify-between">
      <div className="mt-10">
        <h2
          className="font-bold text-xl pb-2 text-black text-opacity-75 dark:text-white dark:text-opacity-75">
          {pageTitle->React.string}
        </h2>
        <div className="text-black pb-2 text-opacity-60 dark:text-white dark:text-opacity-75">
          {pageSubTitle->React.string}
        </div>
      </div>
    </div>
  }
}

module APITableInfo = {
  @react.component
  let make = () => {
    let (showModal, setShowModal) = React.useState(_ => false)

    let apis = [
      "PaymentsCreate",
      "IncomingWebhookReceive",
      "PaymentsRetrieve",
      "RefundsCreate",
      "RefundsRetrieve",
      "CustomerPaymentMethodsList",
      "PaymentsConfirm",
      "UserSigninV2",
      "VerifyEmail",
      "PaymentsSessionToken",
      "CustomersCreate",
      "CustomersRetrieve",
      "CustomersDelete",
      "CustomersUpdate",
      "PaymentsUpdate",
      "PaymentsCapture",
      "PaymentsCancel",
      "PaymentMethodsCreate",
      "VerifyPaymentConnector",
      "UserSignOut",
      "PaymentsStart",
      "PaymentsRedirect",
    ]

    <>
      <div
        className="underline underline-offset-4 font-medium cursor-pointer"
        onClick={_ => setShowModal(_ => !showModal)}>
        {"API endpoints"->React.string}
      </div>
      <Modal
        closeOnOutsideClick=true
        modalHeading="API endpoints"
        showModal
        setShowModal
        modalClass="w-full max-w-md mx-auto md:mt-44 ">
        <div>
          <div className="mb-3">
            {"API endpoints subject to performance metrics monitoring."->React.string}
          </div>
          <div className="h-96 overflow-scroll show-scrollbar">
            {apis
            ->Js.Array2.map(path =>
              <div className="bg-gray-100 p-2 mb-1 rounded mr-2"> {`/${path}`->React.string} </div>
            )
            ->React.array}
          </div>
        </div>
      </Modal>
    </>
  }
}

module SystemMetricsAnalytics = {
  open AnalyticsTypes
  open LogicUtils
  @react.component
  let make = (
    ~pageTitle="",
    ~pageSubTitle="",
    ~startTimeFilterKey: string,
    ~endTimeFilterKey: string,
    ~chartEntity: nestedEntityType,
    ~filteredTabKeys: array<string>,
    ~initialFixedFilters: Js.Json.t => array<EntityType.initialFilters<'t>>,
    ~singleStatEntity: DynamicSingleStat.entityType<'singleStatColType, 'b, 'b2>,
    ~filterUri,
    ~moduleName: string,
  ) => {
    let url = RescriptReactRouter.useUrl()

    let getFilterData = AnalyticsHooks.useGetFiltersData()
    let getModuleFilters = UrlUtils.useGetFilterDictFromUrl("")
    let startTimeVal = getModuleFilters->getString(startTimeFilterKey, "")
    let endTimeVal = getModuleFilters->getString(endTimeFilterKey, "")
    let updateComponentPrefrences = UrlUtils.useUpdateUrlWith(~prefix="")
    let {filterValue, updateExistingKeys} =
      AnalyticsUrlUpdaterContext.urlUpdaterContext->React.useContext
    let (_totalVolume, setTotalVolume) = React.useState(_ => 0)
    let defaultFilters = [startTimeFilterKey, endTimeFilterKey]
    let (_filterAtom, setFilterAtom) = Recoil.useRecoilState(AnalyticsAtoms.customFilterAtom)

    let chartEntity1 = chartEntity.default
    let chartEntity1 = switch chartEntity1 {
    | Some(chartEntity) => Some({...chartEntity, allFilterDimension: filteredTabKeys})
    | None => None
    }

    let setInitialFilters = HSwitchRemoteFilter.useSetInitialFilters(
      ~updateComponentPrefrences,
      ~updateExistingKeys,
      ~startTimeFilterKey,
      ~endTimeFilterKey,
    )

    React.useEffect0(() => {
      setFilterAtom(._ => "")
      setInitialFilters()
      None
    })

    React.useEffect1(() => {
      if url.search->HSwitchUtils.isEmptyString {
        updateComponentPrefrences(~dict=filterValue)
      }
      None
    }, [url])

    React.useEffect1(() => {
      updateComponentPrefrences(~dict=filterValue)
      None
    }, [filterValue])

    let filterBody = React.useMemo3(() => {
      let filterBodyEntity: AnalyticsUtils.filterBodyEntity = {
        startTime: startTimeVal,
        endTime: endTimeVal,
        groupByNames: filteredTabKeys,
        source: "BATCH",
      }
      AnalyticsUtils.filterBody(filterBodyEntity)
    }, (startTimeVal, endTimeVal, filteredTabKeys->Js.Array2.joinWith(",")))

    let filterDataOrig = getFilterData(filterUri, Fetch.Post, filterBody)
    let filterData = filterDataOrig->Belt.Option.getWithDefault(Js.Json.object_(Js.Dict.empty()))

    <UIUtils.RenderIf condition={getModuleFilters->Js.Dict.entries->Js.Array2.length > 0}>
      {switch chartEntity1 {
      | Some(chartEntity) =>
        <div className="flex flex-col flex-1 overflow-scroll h-75-vh">
          <HeadingTile pageTitle pageSubTitle />
          <div className="mt-2 -ml-1">
            <DynamicFilter
              initialFilters=[]
              options=[]
              popupFilterFields=[]
              initialFixedFilters={initialFixedFilters(filterData)}
              defaultFilterKeys=defaultFilters
              tabNames=filteredTabKeys
              updateUrlWith=updateExistingKeys //
              key="1"
              filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
              filtersDisplayOption=false
              showCustomFilter=false
              refreshFilters=false
            />
          </div>
          <APITableInfo />
          <DynamicSingleStat
            entity=singleStatEntity
            startTimeFilterKey
            endTimeFilterKey
            filterKeys=chartEntity.allFilterDimension
            moduleName
            setTotalVolume
            showPercentage=false
            statSentiment={singleStatEntity.statSentiment->Belt.Option.getWithDefault(
              Js.Dict.empty(),
            )}
          />
        </div>
      | _ => React.null
      }}
    </UIUtils.RenderIf>
  }
}

@react.component
let make = () => {
  open APIUtils
  open SystemMetricsAnalyticsUtils
  open HSAnalyticsUtils
  open LogicUtils
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (metrics, setMetrics) = React.useState(_ => [])
  let (dimensions, setDimensions) = React.useState(_ => [])
  let fetchDetails = useGetMethod()

  let loadInfo = async () => {
    try {
      let infoUrl = getURL(~entityName=ANALYTICS_PAYMENTS, ~methodType=Get, ~id=Some(domain), ())
      let infoDetails = await fetchDetails(infoUrl)
      setMetrics(_ => infoDetails->getDictFromJsonObject->getArrayFromDict("metrics", []))
      setDimensions(_ => infoDetails->getDictFromJsonObject->getArrayFromDict("dimensions", []))
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Js.Exn.Error(e) =>
      let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }

  React.useEffect0(() => {
    loadInfo()->ignore
    None
  })

  let tabKeys = getStringListFromArrayDict(dimensions)

  let title = "System Metrics"
  let subTitle = "Gain Insights, monitor performance and make Informed Decisions with System Metrics."

  <PageLoaderWrapper screenState customUI={<NoData title subTitle />}>
    <SystemMetricsAnalytics
      pageTitle=title
      pageSubTitle=subTitle
      filterUri={`${HSwitchGlobalVars.hyperSwitchApiPrefix}/analytics/v1/filters/${domain}`}
      key="SystemMetrics"
      moduleName="SystemMetrics"
      chartEntity={default: chartEntity(tabKeys)}
      filteredTabKeys={tabKeys}
      singleStatEntity={getSingleStatEntity(metrics)}
      startTimeFilterKey
      endTimeFilterKey
      initialFixedFilters=initialFixedFilterFields
    />
  </PageLoaderWrapper>
}
