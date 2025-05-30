@react.component
let make = () => {
  open LogicUtils
  open Promise
  open AuthenticationSummaryEntity
  open APIUtils
  open HSAnalyticsUtils

  let {updateExistingKeys, filterValueJson} = React.useContext(FilterContext.filterContext)

  let getURL = useGetURL()
  let fetchApi = AuthHooks.useApiFetcher()

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (_metrics, setMetrics) = React.useState(_ => [])
  let (dimensions, setDimensions) = React.useState(_ => [])
  let isSampleDataEnabled =
    filterValueJson->getStringFromDictAsBool(NewAuthenticationAnalyticsUtils.sampleDataKey, false)
  let fetchDetails = useGetMethod()
  let fetchUpdateDetails = APIUtils.useUpdateMethod()

  let mixpanelEvent = MixpanelHook.useSendEvent()
  let tabKeys = getStringListFromArrayDict(dimensions)

  let startTimeVal = filterValueJson->getString("startTime", "")
  let endTimeVal = filterValueJson->getString("endTime", "")

  // let analyticsfilterUrl = getURL(
  //   ~entityName=V1(ANALYTICS_FILTERS),
  //   ~methodType=Post,
  //   ~id=Some(domain),
  // )
  let paymentAnalyticsUrl = getURL(
    ~entityName=V1(ANALYTICS_PAYMENTS),
    ~methodType=Post,
    ~id=Some(domain),
  )

  let title = "Authentication Summary"

  let chartEntity = chartEntity(tabKeys, ~uri=paymentAnalyticsUrl)

  let tableEntity = paymentTableEntity(~uri=paymentAnalyticsUrl)

  let dateKeys = chartEntity.dateFilterKeys
  let filterKeys = chartEntity.allFilterDimension
  let activeTab = Some(["connector"])
  let getTable = getPaymentTable

  let defaultSort = "total_volume"
  let deltaMetrics = ["payment_success_rate", "payment_count", "payment_success_count"]
  let deltaArray = []

  let moduleName = "overall_summary"

  let distributionArray = Some([distribution])
  let customFilter = Recoil.useRecoilValueFromAtom(AnalyticsAtoms.customFilterAtom)
  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let filterValueDict = filterValueJson
  let {getHeading, allColumns, defaultColumns} = tableEntity
  let activeTabStr = activeTab->Option.getOr([])->Array.joinWith("-")
  let (startTimeFilterKey, endTimeFilterKey) = dateKeys

  let (tableData, setTableData) = React.useState(_ => []->Array.map(Nullable.make))
  let {globalUIConfig: {font: {textColor}, border: {borderColor}}} = React.useContext(
    ThemeProvider.themeContext,
  )

  let loadInfo = async () => {
    try {
      let infoUrl = getURL(~entityName=V1(ANALYTICS_PAYMENTS), ~methodType=Get, ~id=Some(domain))
      let infoDetails = await fetchDetails(infoUrl)
      let ignoreSessionizedPayment =
        infoDetails
        ->getDictFromJsonObject
        ->getArrayFromDict("metrics", [])
        ->AnalyticsUtils.filterMetrics
      setMetrics(_ => ignoreSessionizedPayment)
      setDimensions(_ => infoDetails->getDictFromJsonObject->getArrayFromDict("dimensions", []))
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }
  let getPaymetsDetails = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let paymentUrl = getURL(~entityName=V1(ORDERS), ~methodType=Get)
      let paymentDetails = await fetchDetails(paymentUrl)
      let data = paymentDetails->getDictFromJsonObject->getArrayFromDict("data", [])
      if data->Array.length < 0 {
        setScreenState(_ => PageLoaderWrapper.Success)
      } else {
        await loadInfo()
      }
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }

  React.useEffect(() => {
    getPaymetsDetails()->ignore
    None
  }, [])

  let setInitialFilters = HSwitchRemoteFilter.useSetInitialFilters(
    ~updateExistingKeys,
    ~startTimeFilterKey,
    ~endTimeFilterKey,
    ~origin="analytics",
    (),
  )

  React.useEffect(() => {
    setInitialFilters()
    None
  }, [])

  // let filterBody = React.useMemo(() => {
  //   let filterBodyEntity: AnalyticsUtils.filterBodyEntity = {
  //     startTime: startTimeVal,
  //     endTime: endTimeVal,
  //     groupByNames: tabKeys,
  //     source: "BATCH",
  //   }
  //   AnalyticsUtils.filterBody(filterBodyEntity)
  // }, (startTimeVal, endTimeVal, tabKeys->Array.joinWith(",")))

  // let body = filterBody->JSON.Encode.object

  // React.useEffect(() => {
  //   setFilterDataJson(_ => None)
  //   if startTimeVal->LogicUtils.isNonEmptyString && endTimeVal->LogicUtils.isNonEmptyString {
  //     try {
  //       updateDetails(analyticsfilterUrl, body, Post)
  //       ->thenResolve(json => setFilterDataJson(_ => Some(json)))
  //       ->catch(_ => resolve())
  //       ->ignore
  //     } catch {
  //     | _ => ()
  //     }
  //   }
  //   None
  // }, (startTimeVal, endTimeVal, body->JSON.stringify))

  React.useEffect(() => {
    if startTimeVal->LogicUtils.isNonEmptyString && endTimeVal->LogicUtils.isNonEmptyString {
      mixpanelEvent(~eventName="analytics_payments_date_filter")
    }
    None
  }, [startTimeVal, endTimeVal])

  let getTopLevelFilter = React.useMemo(() => {
    filterValueDict
    ->Dict.toArray
    ->Belt.Array.keepMap(item => {
      let (key, value) = item
      let keyArr = key->String.split(".")
      let prefix = keyArr->Array.get(0)->Option.getOr("")
      if prefix === moduleName && prefix->LogicUtils.isNonEmptyString {
        None
      } else {
        Some((prefix, value))
      }
    })
    ->Dict.fromArray
  }, [filterValueDict])

  let allColumns = allColumns->Option.getOr([])
  let allFilterKeys = Array.concat([startTimeFilterKey, endTimeFilterKey], filterKeys)

  let topFiltersToSearchParam = React.useMemo(() => {
    let filterSearchParam =
      getTopLevelFilter
      ->Dict.toArray
      ->Belt.Array.keepMap(entry => {
        let (key, value) = entry
        if allFilterKeys->Array.includes(key) {
          switch value->JSON.Classify.classify {
          | String(str) => `${key}=${str}`->Some
          | Number(num) => `${key}=${num->String.make}`->Some
          | Array(arr) => `${key}=[${arr->String.make}]`->Some
          | _ => None
          }
        } else {
          None
        }
      })
      ->Array.joinWith("&")

    filterSearchParam
  }, [getTopLevelFilter])

  let filterValueFromUrl = React.useMemo(() => {
    getTopLevelFilter
    ->Dict.toArray
    ->Belt.Array.keepMap(entries => {
      let (key, value) = entries
      filterKeys->Array.includes(key) ? Some((key, value)) : None
    })
    ->Dict.fromArray
    ->JSON.Encode.object
    ->Some
  }, [topFiltersToSearchParam])

  let startTimeFromUrl = React.useMemo(() => {
    getTopLevelFilter->getString(startTimeFilterKey, "")
  }, [topFiltersToSearchParam])
  let endTimeFromUrl = React.useMemo(() => {
    getTopLevelFilter->getString(endTimeFilterKey, "")
  }, [topFiltersToSearchParam])

  let parseData = json => {
    let data = json->getDictFromJsonObject
    let value = data->getJsonObjectFromDict("queryData")->getArrayFromJson([])
    value
  }

  let generateIDFromKeys = (keys, dict) => {
    keys
    ->Option.getOr([])
    ->Array.map(key => {
      dict->Dict.get(key)
    })
    ->Array.joinWithUnsafe("")
  }

  open AnalyticsTypes
  let getUpdatedData = (data, weeklyData, cols) => {
    let dataArr = data->parseData
    let weeklyArr = weeklyData->parseData

    dataArr
    ->Array.map(item => {
      let dataDict = item->getDictFromJsonObject
      let dataKey = activeTab->generateIDFromKeys(dataDict)

      weeklyArr->Array.forEach(newItem => {
        let weekklyDataDict = newItem->getDictFromJsonObject
        let weekklyDataKey = activeTab->generateIDFromKeys(weekklyDataDict)

        if dataKey === weekklyDataKey {
          cols->Array.forEach(
            obj => {
              switch weekklyDataDict->Dict.get(obj.refKey) {
              | Some(val) => dataDict->Dict.set(obj.newKey, val)
              | _ => ()
              }
            },
          )
        }
      })
      dataDict->JSON.Encode.object
    })
    ->JSON.Encode.array
    ->getTable
    ->Array.map(Nullable.make)
  }

  let getWeeklyData = (data, cols) => {
    let weeklyDateRange = HSwitchRemoteFilter.getDateFilteredObject()

    let weeklyTableReqBody = AnalyticsUtils.generateTablePayload(
      ~startTimeFromUrl=weeklyDateRange.start_time,
      ~endTimeFromUrl=weeklyDateRange.end_time,
      ~filterValueFromUrl,
      ~currenltySelectedTab=activeTab,
      ~deltaMetrics,
      ~isIndustry=false,
      ~distributionArray=None,
      ~deltaPrefixArr=deltaArray,
      ~tableMetrics=[],
      ~mode=None,
      ~customFilter,
      ~moduleName,
      ~showDeltaMetrics=true,
      (),
    )
    if isSampleDataEnabled {
      setScreenState(_ => PageLoaderWrapper.Loading)
      // let paymentsUrl = `${GlobalVars.getHostUrl}/test-data/analytics/payments.json`
      // fetchApi(paymentsUrl, ~method_=Get, ~xFeatureRoute=false, ~forceCookies=false)
      // ->then(res => res->Fetch.Response.json)
      // ->then(json => {
      //   let updatedData = getUpdatedData(
      //     data,
      //     json->getDictFromJsonObject->getJsonObjectFromDict("authenticationSummaryTableData"),
      //     cols,
      //   )
      //   setTableData(_ => updatedData)

      //   setScreenState(_ => PageLoaderWrapper.Success)

      //   resolve()
      // })
      // ->catch(_ => {
      //   setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch data!"))
      //   resolve()
      // })
      // ->ignore
      setTableData(_ =>
        getUpdatedData(
          data,
          NewAuthenticationAnalyticsUtils.authDummyData
          ->getDictFromJsonObject
          ->getJsonObjectFromDict("authenticationSummaryTableData"),
          cols,
        )
      )
      setScreenState(_ => PageLoaderWrapper.Success)
    } else {
      setScreenState(_ => PageLoaderWrapper.Loading)
      fetchUpdateDetails(tableEntity.uri, weeklyTableReqBody, Post)
      ->thenResolve(json => {
        setTableData(_ => getUpdatedData(data, json, cols))
        setScreenState(_ => PageLoaderWrapper.Success)
      })
      ->catch(_ => {
        setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch data!"))
        resolve()
      })
      ->ignore
    }
  }

  let updateTableData = json => {
    getWeeklyData(json, weeklyTableMetricsCols)->ignore
  }

  React.useEffect(() => {
    if (
      startTimeFromUrl->LogicUtils.isNonEmptyString && endTimeFromUrl->LogicUtils.isNonEmptyString
    ) {
      let tableReqBody = HSAnalyticsUtils.generateTablePayload(
        ~startTimeFromUrl,
        ~endTimeFromUrl,
        ~filterValueFromUrl,
        ~currenltySelectedTab=activeTab,
        ~deltaMetrics,
        ~isIndustry=false,
        ~distributionArray,
        ~deltaPrefixArr=deltaArray,
        ~tableMetrics=[],
        ~mode=None,
        ~customFilter,
        ~moduleName,
        ~showDeltaMetrics=true,
        (),
      )
      if isSampleDataEnabled {
        setScreenState(_ => PageLoaderWrapper.Loading)
        // let paymentsUrl = `${GlobalVars.getHostUrl}/test-data/analytics/payments.json`
        // fetchApi(paymentsUrl, ~method_=Get, ~xFeatureRoute=false, ~forceCookies=false)
        // ->then(res => res->Fetch.Response.json)
        // ->then(json => {
        //   updateTableData(
        //     json->getDictFromJsonObject->getJsonObjectFromDict("authenticationSummaryTableData"),
        //   )
        //   setScreenState(_ => PageLoaderWrapper.Success)
        //   resolve()
        // })
        // ->catch(_ => {
        //   setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch data!"))
        //   resolve()
        // })
        // ->ignore
        updateTableData(
          NewAuthenticationAnalyticsUtils.authDummyData
          ->getDictFromJsonObject
          ->getJsonObjectFromDict("authenticationSummaryTableData"),
        )
        setScreenState(_ => PageLoaderWrapper.Success)
      } else {
        fetchUpdateDetails(tableEntity.uri, tableReqBody, Post)
        ->thenResolve(json => json->updateTableData)
        ->catch(_ => {
          setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch data!"))
          resolve()
        })
        ->ignore
      }
    }
    None
  }, (topFiltersToSearchParam, activeTabStr, customFilter))
  let newDefaultCols = React.useMemo(() => {
    activeTab
    ->Option.getOr([])
    ->Belt.Array.keepMap(item => {
      defaultColumns
      ->Belt.Array.keepMap(
        columnItem => {
          let val = columnItem->getHeading
          val.key === item ? Some(columnItem) : None
        },
      )
      ->Array.get(0)
    })
    ->Array.concat(allColumns)
  }, [activeTabStr])

  let newAllCols = React.useMemo(() => {
    defaultColumns
    ->Belt.Array.keepMap(item => {
      let val = item->getHeading
      activeTab->Option.getOr([])->Array.includes(val.key) ? Some(item) : None
    })
    ->Array.concat(allColumns)
  }, [activeTabStr])

  let transactionTableDefaultCols = React.useMemo(() => {
    Recoil.atom(`${moduleName}DefaultCols${activeTabStr}`, newDefaultCols)
  }, (newDefaultCols, `${moduleName}DefaultCols${activeTabStr}`))

  let (offset, setOffset) = React.useState(_ => 0)

  let visibleColumns = Recoil.useRecoilValueFromAtom(transactionTableDefaultCols)

  let defaultSort: Table.sortedObject = {
    key: defaultSort,
    order: Table.INC,
  }

  let modifiedTableEntity = React.useMemo(() => {
    {
      ...tableEntity,
      defaultColumns: newDefaultCols,
      allColumns: Some(newAllCols),
    }
  }, (tableEntity, newDefaultCols, newAllCols))

  let tableBorderClass = "border-collapse border border-jp-gray-940 border-solid border-2 rounded-md border-opacity-30 dark:border-jp-gray-dark_table_border_color dark:border-opacity-30 mt-7"

  <PageLoaderWrapper
    screenState
    customLoader={<NewAuthenticationAnalyticsHelper.Shimmer layoutId="Authentication summary" />}
    customUI={<NoData title />}>
    <div className="flex flex-1 flex-col my-5">
      <div className="relative">
        <div
          className="absolute font-bold text-xl bg-white w-full text-black text-opacity-75 dark:bg-jp-gray-950 dark:text-white dark:text-opacity-75">
          {React.string("Authentication Summary")}
        </div>
        <LoadedTable
          visibleColumns
          title="Summary Table"
          hideTitle=true
          actualData={tableData}
          entity=modifiedTableEntity
          resultsPerPage=10
          totalResults={tableData->Array.length}
          offset
          setOffset
          defaultSort
          currrentFetchCount={tableData->Array.length}
          tableLocalFilter=false
          tableheadingClass=tableBorderClass
          tableBorderClass
          tableDataBorderClass=tableBorderClass
          isAnalyticsModule=true
        />
        <RenderIf condition={tableData->Array.length > 0}>
          <div
            className={`flex items-start ${borderColor.primaryNormal} text-sm rounded-md gap-2 px-4 py-3 my-4`}>
            <Icon name="info-vacent" className={`${textColor.primaryNormal} mt-1`} size=18 />
            {"'NA' denotes those incomplete or failed payments with no assigned values for the corresponding parameters due to reasons like customer drop-offs, technical failures, etc."->React.string}
          </div>
        </RenderIf>
      </div>
    </div>
  </PageLoaderWrapper>
}
