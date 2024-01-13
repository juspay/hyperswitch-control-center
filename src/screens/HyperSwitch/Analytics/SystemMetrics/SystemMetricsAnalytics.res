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
            ->Array.map(path =>
              <div className="bg-gray-100 p-2 mb-1 rounded mr-2"> {`/${path}`->React.string} </div>
            )
            ->React.array}
          </div>
        </div>
      </Modal>
    </>
  }
}

module HSiwtchPaymentConfirmLatency = {
  open DynamicSingleStat
  open SystemMetricsAnalyticsUtils
  open Promise
  open LogicUtils
  @react.component
  let make = () => {
    let url = `${HSwitchGlobalVars.hyperSwitchApiPrefix}/analytics/v1/metrics/${domain}`
    let (isLoading, setIsLoading) = React.useState(_ => true)
    let (latency, setLatency) = React.useState(_ => 0)
    let (connectorLatency, setConnectorLatency) = React.useState(_ => 0)
    let (overallLatency, setOverallrLatency) = React.useState(_ => 0)
    let updateDetails = APIUtils.useUpdateMethod()
    let dateDict = HSwitchRemoteFilter.getDateFilteredObject()

    let singleStatBodyEntity = {
      metrics: ["latency", "api_count", "status_code_count"],
      startDateTime: dateDict.start_time,
      endDateTime: dateDict.end_time,
    }

    let singleStatBodyMake = (singleStatBodyEntity: singleStatBodyEntity, flowType) => {
      let filters =
        [
          ("api_name", ["PaymentsConfirm"->Js.Json.string]->Js.Json.array),
          ("status_code", [200.0->Js.Json.number]->Js.Json.array),
          ("flow_type", [flowType->Js.Json.string]->Js.Json.array),
        ]
        ->Dict.fromArray
        ->Js.Json.object_

      [
        AnalyticsUtils.getFilterRequestBody(
          ~filter=filters->Some,
          ~metrics=singleStatBodyEntity.metrics,
          ~delta=?singleStatBodyEntity.delta,
          ~startDateTime=singleStatBodyEntity.startDateTime,
          ~endDateTime=singleStatBodyEntity.endDateTime,
          ~mode=singleStatBodyEntity.mode,
          ~customFilter=?singleStatBodyEntity.customFilter,
          ~source=?singleStatBodyEntity.source,
          ~granularity=singleStatBodyEntity.granularity,
          ~prefix=singleStatBodyEntity.prefix,
          (),
        )->Js.Json.object_,
      ]->Js.Json.array
    }

    let parseJson = json => {
      json
      ->getDictFromJsonObject
      ->getJsonObjectFromDict("queryData")
      ->getArrayFromJson([])
      ->Belt.Array.get(0)
      ->Belt.Option.getWithDefault(Js.Json.object_(Dict.make()))
      ->getDictFromJsonObject
      ->getInt("latency", 0)
    }

    let getOverallLatency = async () => {
      updateDetails(url, singleStatBodyEntity->singleStatBodyMake("Payment"), Fetch.Post)
      ->thenResolve(json => {
        setOverallrLatency(_ => json->parseJson)
      })
      ->catch(_ => {
        setIsLoading(_ => false)
        resolve()
      })
      ->ignore
    }

    let getConnectorLatency = () => {
      updateDetails(url, singleStatBodyEntity->singleStatBodyMake("OutgoingEvent"), Fetch.Post)
      ->thenResolve(json => {
        setConnectorLatency(_ => json->parseJson)
        setIsLoading(_ => false)
      })
      ->catch(_ => {
        setIsLoading(_ => false)
        resolve()
      })
      ->ignore
    }

    React.useEffect2(() => {
      let value = overallLatency - connectorLatency
      setLatency(_ => value)

      None
    }, (overallLatency, connectorLatency))

    React.useEffect0(() => {
      getOverallLatency()->ignore
      getConnectorLatency()->ignore

      None
    })

    if isLoading {
      <div className={`p-4 w-full`}>
        <Shimmer styleClass="w-full h-28" />
      </div>
    } else {
      <div className="mt-4 w-full">
        <div
          className={`h-full flex flex-col border rounded dark:border-jp-gray-850 bg-white dark:bg-jp-gray-lightgray_background overflow-hidden singlestatBox p-4 mr-4`}>
          <div className="px-4 pb-4 pt-1 flex flex-col justify-between h-full gap-auto">
            <div className="flex flex-row h-1/2 items-end">
              <div className="font-bold text-3xl">
                {latencyShortNum(
                  ~labelValue=latency->Belt.Int.toFloat /. 1000.0,
                  ~includeMilliseconds=true,
                  (),
                )
                ->String.toLowerCase
                ->React.string}
              </div>
            </div>
            <div
              className={"flex gap-2 items-center pt-4 text-jp-gray-700 font-bold self-start h-1/2"}>
              <div className="font-semibold text-base text-black dark:text-white">
                {"Hyperswitch overhead for payment confirm"->React.string}
              </div>
              <ToolTip
                description="Average time added by the Hyperswitch application to the overall Payments Confirm API latency"
                toolTipFor={<div className="cursor-pointer">
                  <Icon name="info-vacent" size=13 />
                </div>}
                toolTipPosition=ToolTip.Top
              />
            </div>
          </div>
        </div>
      </div>
    }
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
    let {filterValueJson} = React.useContext(FilterContext.filterContext)
    let getModuleFilters = filterValueJson
    let startTimeVal = getModuleFilters->getString(startTimeFilterKey, "")
    let endTimeVal = getModuleFilters->getString(endTimeFilterKey, "")
    let {updateExistingKeys} = FilterContext.filterContext->React.useContext
    let (_totalVolume, setTotalVolume) = React.useState(_ => 0)
    let defaultFilters = [startTimeFilterKey, endTimeFilterKey]

    let chartEntity1 = chartEntity.default
    let chartEntity1 = switch chartEntity1 {
    | Some(chartEntity) => Some({...chartEntity, allFilterDimension: filteredTabKeys})
    | None => None
    }

    let setInitialFilters = HSwitchRemoteFilter.useSetInitialFilters(
      ~updateExistingKeys,
      ~startTimeFilterKey,
      ~endTimeFilterKey,
    )

    React.useEffect0(() => {
      setInitialFilters()
      None
    })

    let filterBody = React.useMemo3(() => {
      let filterBodyEntity: AnalyticsUtils.filterBodyEntity = {
        startTime: startTimeVal,
        endTime: endTimeVal,
        groupByNames: filteredTabKeys,
        source: "BATCH",
      }
      AnalyticsUtils.filterBody(filterBodyEntity)
    }, (startTimeVal, endTimeVal, filteredTabKeys->Array.joinWith(",")))

    open APIUtils
    open Promise
    let (filterDataJson, setFilterDataJson) = React.useState(_ => None)
    let updateDetails = useUpdateMethod()
    let {filterValueJson} = FilterContext.filterContext->React.useContext
    let startTimeVal = filterValueJson->getString("startTime", "")
    let endTimeVal = filterValueJson->getString("endTime", "")
    open HSwitchRemoteFilter
    React.useEffect3(() => {
      setFilterDataJson(_ => None)
      if startTimeVal->isStringNonEmpty && endTimeVal->isStringNonEmpty {
        try {
          updateDetails(filterUri, filterBody->Js.Json.object_, Post)
          ->thenResolve(json => setFilterDataJson(_ => json->Some))
          ->catch(_ => resolve())
          ->ignore
        } catch {
        | _ => ()
        }
      }
      None
    }, (startTimeVal, endTimeVal, filterBody->Js.Json.object_->Js.Json.stringify))
    let filterData = filterDataJson->Belt.Option.getWithDefault(Dict.make()->Js.Json.object_)

    <UIUtils.RenderIf condition={getModuleFilters->Dict.toArray->Array.length > 0}>
      {switch chartEntity1 {
      | Some(chartEntity) =>
        <div className="h-75-vh">
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
            statSentiment={singleStatEntity.statSentiment->Belt.Option.getWithDefault(Dict.make())}
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
