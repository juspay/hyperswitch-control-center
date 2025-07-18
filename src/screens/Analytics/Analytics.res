@get external keyCode: 'a => int = "keyCode"

open LogicUtils

module BaseTableComponent = {
  @react.component
  let make = (
    ~filters as _,
    ~tableData,
    ~defaultSort: string,
    ~tableDataLoading: bool,
    ~transactionTableDefaultCols,
    ~newDefaultCols: array<'colType>,
    ~newAllCols: array<'colType>,
    ~colMapper as _,
    ~tableEntity: EntityType.entityType<'colType, 't>,
    ~tableGlobalFilter as _,
    ~activeTab as _,
  ) => {
    open DynamicTableUtils
    let (offset, setOffset) = React.useState(_ => 0)
    let (_, setCounter) = React.useState(_ => 1)
    let refetch = React.useCallback(_ => {
      setCounter(p => p + 1)
    }, [setCounter])

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

    <div className="flex flex-1 flex-col m-5">
      <RefetchContextProvider value=refetch>
        {if tableDataLoading {
          <DynamicTableUtils.TableDataLoadingIndicator showWithData={true} />
        } else {
          <div className="relative">
            <div
              className="absolute font-bold text-xl bg-white w-full text-black text-opacity-75 dark:bg-jp-gray-950 dark:text-white dark:text-opacity-75">
              {React.string("Payments Summary")}
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
          </div>
        }}
      </RefetchContextProvider>
    </div>
  }
}

module TableWrapper = {
  @react.component
  let make = (
    ~dateKeys,
    ~filterKeys,
    ~activeTab,
    ~defaultSort,
    ~getTable: JSON.t => array<'t>,
    ~colMapper: 'colType => string,
    ~tableEntity: EntityType.entityType<'colType, 't>,
    ~deltaMetrics: array<string>,
    ~deltaArray: array<string>,
    ~tableUpdatedHeading as _,
    ~tableGlobalFilter: option<(array<Nullable.t<'t>>, JSON.t) => array<Nullable.t<'t>>>,
    ~moduleName,
    ~weeklyTableMetricsCols,
    ~distributionArray=None,
    ~formatData=None,
  ) => {
    let {globalUIConfig: {font: {textColor}, border: {borderColor}}} = React.useContext(
      ThemeProvider.themeContext,
    )
    let customFilter = Recoil.useRecoilValueFromAtom(AnalyticsAtoms.customFilterAtom)
    let {filterValueJson} = React.useContext(FilterContext.filterContext)
    let filterValueDict = filterValueJson
    let fetchDetails = APIUtils.useUpdateMethod()

    let (showTable, setShowTable) = React.useState(_ => false)
    let {getHeading, allColumns, defaultColumns} = tableEntity
    let activeTabStr = activeTab->Option.getOr([])->Array.joinWith("-")
    let (startTimeFilterKey, endTimeFilterKey) = dateKeys
    let (tableDataLoading, setTableDataLoading) = React.useState(_ => true)
    let (tableData, setTableData) = React.useState(_ => []->Array.map(Nullable.make))

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

    open Promise
    let getWeeklyData = async (data, cols) => {
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

      fetchDetails(tableEntity.uri, weeklyTableReqBody, Post)
      ->thenResolve(json => {
        setTableData(_ => getUpdatedData(data, json, cols))
        setTableDataLoading(_ => false)
        setShowTable(_ => true)
      })
      ->catch(_ => {
        setTableDataLoading(_ => false)
        resolve()
      })
      ->ignore
    }

    React.useEffect(() => {
      setShowTable(_ => false)
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

        fetchDetails(tableEntity.uri, tableReqBody, Post)
        ->thenResolve(json => {
          switch weeklyTableMetricsCols {
          | Some(cols) => getWeeklyData(json, cols)->ignore
          | _ => {
              let data = json->getDictFromJsonObject
              let value =
                data->getJsonObjectFromDict("queryData")->getTable->Array.map(Nullable.make)

              setTableData(_ => value)
              setTableDataLoading(_ => false)
              setShowTable(_ => true)
            }
          }
        })
        ->catch(_ => {
          setTableDataLoading(_ => false)
          resolve()
        })
        ->ignore
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

    let modifyData = data => {
      switch formatData {
      | Some(fun) => data->fun
      | None => data
      }
    }

    showTable
      ? <>
          <div className="h-full -mx-4 overflow-scroll">
            <Form>
              <BaseTableComponent
                filters=(startTimeFromUrl, endTimeFromUrl)
                tableData={tableData->modifyData}
                tableDataLoading
                transactionTableDefaultCols
                defaultSort
                newDefaultCols
                newAllCols
                tableEntity
                colMapper
                tableGlobalFilter
                activeTab={activeTab->Option.getOr([])}
              />
            </Form>
          </div>
          <RenderIf condition={tableData->Array.length > 0}>
            <div
              className={`flex items-start ${borderColor.primaryNormal} text-sm rounded-md gap-2 px-4 py-3`}>
              <Icon name="info-vacent" className={`${textColor.primaryNormal} mt-1`} size=18 />
              {"'NA' denotes those incomplete or failed payments with no assigned values for the corresponding parameters due to reasons like customer drop-offs, technical failures, etc."->React.string}
            </div>
          </RenderIf>
        </>
      : <Loader />
  }
}
module TabDetails = {
  @react.component
  let make = (
    ~chartEntity: DynamicChart.entity,
    ~activeTab,
    ~defaultSort: string,
    ~getTable: JSON.t => array<'t>,
    ~colMapper: 'colType => string,
    ~distributionArray,
    ~tableEntity: option<EntityType.entityType<'colType, 't>>,
    ~deltaMetrics: array<string>,
    ~deltaArray: array<string>,
    ~tableUpdatedHeading: option<
      (~item: option<'t>, ~dateObj: option<AnalyticsUtils.prevDates>) => 'colType => Table.header,
    >,
    ~tableGlobalFilter: option<(array<Nullable.t<'t>>, JSON.t) => array<Nullable.t<'t>>>,
    ~moduleName,
    ~updateUrl: Dict.t<string> => unit,
    ~weeklyTableMetricsCols,
    ~formatData=None,
  ) => {
    open AnalyticsTypes
    let analyticsType = moduleName->getAnalyticsType
    let id =
      activeTab
      ->Option.getOr(["tab"])
      ->Array.reduce("", (acc, tabName) => {acc->String.concat(tabName)})

    let isMobileView = MatchMedia.useMobileChecker()

    let wrapperClass = React.useMemo(() =>
      switch analyticsType {
      | AUTHENTICATION => `h-auto basis-full mt-4 ${isMobileView ? "w-full" : "w-1/2"}`
      | _ => "bg-white border rounded-lg p-8 mt-3 mb-7"
      }
    , [isMobileView])

    let tabTitleMapper = switch analyticsType {
    | AUTHENTICATION =>
      [
        ("browser_name", "browser"),
        ("component", "checkout_platform"),
        ("platform", "customer_device"),
      ]->Dict.fromArray
    | _ => Dict.make()
    }

    let comparitionWidget = switch analyticsType {
    | AUTHENTICATION => false
    | _ => true
    }

    let tab =
      <div className=wrapperClass>
        <DynamicChart
          entity=chartEntity
          selectedTab=activeTab
          chartId=moduleName
          updateUrl
          enableBottomChart=false
          showTableLegend=false
          showMarkers=true
          legendType=HighchartTimeSeriesChart.Points
          tabTitleMapper
          comparitionWidget
        />
        {switch tableEntity {
        | Some(tableEntity) =>
          <TableWrapper
            dateKeys=chartEntity.dateFilterKeys
            filterKeys=chartEntity.allFilterDimension
            activeTab
            getTable
            colMapper
            defaultSort
            tableEntity
            deltaMetrics
            deltaArray
            tableUpdatedHeading
            tableGlobalFilter
            moduleName
            weeklyTableMetricsCols
            distributionArray
            formatData
          />
        | None => React.null
        }}
      </div>
    switch analyticsType {
    | AUTHENTICATION => tab
    | _ => <FramerMotion.TransitionComponent id={id}> {tab} </FramerMotion.TransitionComponent>
    }
  }
}

open AnalyticsTypes
@react.component
let make = (
  ~pageTitle="",
  ~startTimeFilterKey: string,
  ~endTimeFilterKey: string,
  ~chartEntity: nestedEntityType,
  ~defaultSort: string,
  ~tabKeys: array<string>,
  ~tabValues: array<DynamicTabs.tab>,
  ~initialFilters: (JSON.t, ~isTitle: bool=?) => array<EntityType.initialFilters<'t>>,
  ~initialFixedFilters: (JSON.t, ~events: unit => unit=?) => array<EntityType.initialFilters<'t>>,
  ~options: JSON.t => array<EntityType.optionType<'t>>,
  ~getTable: JSON.t => array<'a>,
  ~colMapper: 'colType => string,
  ~tableEntity: option<EntityType.entityType<'colType, 't>>=?,
  ~deltaMetrics: array<string>,
  ~deltaArray: array<string>,
  ~singleStatEntity: DynamicSingleStat.entityType<'singleStatColType, 'b, 'b2>,
  ~filterUri: option<string>,
  ~tableUpdatedHeading: option<
    (~item: option<'t>, ~dateObj: option<AnalyticsUtils.prevDates>) => 'colType => Table.header,
  >=?,
  ~tableGlobalFilter: option<(array<Nullable.t<'t>>, JSON.t) => array<Nullable.t<'t>>>=?,
  ~moduleName: string,
  ~weeklyTableMetricsCols=?,
  ~distributionArray=None,
  ~formatData=None,
) => {
  let analyticsType = moduleName->getAnalyticsType
  let {filterValue, updateExistingKeys, filterValueJson} = React.useContext(
    FilterContext.filterContext,
  )
  let {checkUserEntity} = React.useContext(UserInfoProvider.defaultContext)

  let defaultFilters = [startTimeFilterKey, endTimeFilterKey]
  let (filteredTabKeys, filteredTabVales) = (tabKeys, tabValues)
  let chartEntity1 = chartEntity.default // User Journey - SemiDonut (Payment Metrics), Others - Default Chart Entity
  let pieChartEntity = chartEntity.userPieChart // SemiDonut (User Metrics)
  let barChartEntity = chartEntity.userBarChart // HorizontalBar (User Metrics)
  let funnelChartEntity = chartEntity.userFunnelChart // Funnel (All Metrics)
  let chartEntity1 = switch chartEntity1 {
  | Some(chartEntity) => Some({...chartEntity, allFilterDimension: filteredTabKeys})
  | None => None
  }

  let filterValueDict = filterValueJson
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let url = RescriptReactRouter.useUrl()
  let urlArray = url.path->List.toArray
  let analyticsTypeName = switch urlArray[1] {
  | Some(val) => val->kebabToSnakeCase
  | _ => ""
  }

  let initTab = React.useMemo(() => {
    switch filteredTabKeys->Array.get(0) {
    | Some(val) => [val]
    | None => [""]
    }
  }, [filteredTabKeys])

  let (activeTav, setActiveTab) = React.useState(_ =>
    filterValueDict->getStrArrayFromDict(`${moduleName}.tabName`, initTab)
  )
  let setActiveTab = React.useMemo(() => {
    (str: string) => {
      setActiveTab(_ => str->String.split(","))
    }
  }, [setActiveTab])

  let startTimeVal = filterValueDict->getString(startTimeFilterKey, "")
  let endTimeVal = filterValueDict->getString(endTimeFilterKey, "")
  let {updateAnalytcisEntity} = OMPSwitchHooks.useUserInfo()
  let {userInfo: {analyticsEntity}} = React.useContext(UserInfoProvider.defaultContext)
  let updateUrlWithPrefix = React.useMemo(() => {
    (chartType: string) => {
      (dict: Dict.t<string>) => {
        let prev = filterValue

        let prevDictArr =
          prev
          ->Dict.toArray
          ->Belt.Array.keepMap(item => {
            let (key, _) = item
            switch dict->Dict.get(key) {
            | Some(_) => None
            | None => Some(item)
            }
          })

        let currentDict =
          dict
          ->Dict.toArray
          ->Belt.Array.keepMap(item => {
            let (key, value) = item
            if value->LogicUtils.isNonEmptyString {
              Some((`${moduleName}${chartType}.${key}`, value))
            } else {
              None
            }
          })

        updateExistingKeys(Array.concat(prevDictArr, currentDict)->Dict.fromArray)
      }
    }
  }, [updateExistingKeys])

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

  let filterBody = React.useMemo(() => {
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
  React.useEffect(() => {
    setFilterDataJson(_ => None)
    if startTimeVal->LogicUtils.isNonEmptyString && endTimeVal->LogicUtils.isNonEmptyString {
      try {
        switch filterUri {
        | Some(filterUri) =>
          updateDetails(filterUri, filterBody->JSON.Encode.object, Post)
          ->thenResolve(json => setFilterDataJson(_ => Some(json)))
          ->catch(_ => resolve())
          ->ignore
        | None => ()
        }
      } catch {
      | _ => ()
      }
    }
    None
  }, (startTimeVal, endTimeVal, filterBody->JSON.Encode.object->JSON.stringify))
  let filterData = filterDataJson->Option.getOr(Dict.make()->JSON.Encode.object)

  //This is to trigger the mixpanel event to see active analytics users
  React.useEffect(() => {
    if startTimeVal->LogicUtils.isNonEmptyString && endTimeVal->LogicUtils.isNonEmptyString {
      mixpanelEvent(~eventName=`${analyticsTypeName}_date_filter`)
    }
    None
  }, (startTimeVal, endTimeVal))

  let activeTab = React.useMemo(() => {
    Some(
      filterValueDict
      ->getStrArrayFromDict(`${moduleName}.tabName`, activeTav)
      ->Array.filter(item => item->LogicUtils.isNonEmptyString),
    )
  }, [filterValueDict])
  let isMobileView = MatchMedia.useMobileChecker()
  let dateDropDownTriggerMixpanelCallback = () => {
    mixpanelEvent(~eventName=`${analyticsTypeName}_date_filter_opened`)
  }

  let tabDetailsClass = React.useMemo(() => {
    isMobileView ? "flex flex-col gap-4 my-4" : "flex flex-row gap-4 my-4"
  }, [isMobileView])
  let topFilterUi = switch filterDataJson {
  | Some(filterData) => {
      let filterData = switch analyticsType {
      | AUTHENTICATION => {
          let filteredDims = ["payment_method", "payment_experience", "source"]
          let queryData =
            filterData
            ->getDictFromJsonObject
            ->getJsonObjectFromDict("queryData")
            ->getArrayFromJson([])
            ->Array.filter(dimension => {
              let dim = dimension->getDictFromJsonObject->getString("dimension", "")
              filteredDims->Array.includes(dim)->not
            })
            ->JSON.Encode.array
          [("queryData", queryData)]->Dict.fromArray->JSON.Encode.object
        }
      | _ => filterData
      }
      <div className="flex flex-row">
        <DynamicFilter
          initialFilters={initialFilters(filterData)}
          options=[]
          popupFilterFields={options(filterData)}
          initialFixedFilters={initialFixedFilters(
            filterData,
            ~events=dateDropDownTriggerMixpanelCallback,
          )}
          defaultFilterKeys=defaultFilters
          tabNames=tabKeys
          updateUrlWith=updateExistingKeys
          key="0"
          filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
          showCustomFilter=false
          refreshFilters=false
        />
      </div>
    }
  | None =>
    <div className="flex flex-row">
      <DynamicFilter
        initialFilters=[]
        options=[]
        popupFilterFields=[]
        initialFixedFilters={initialFixedFilters(
          filterData,
          ~events=dateDropDownTriggerMixpanelCallback,
        )}
        defaultFilterKeys=defaultFilters
        tabNames=tabKeys
        updateUrlWith=updateExistingKeys //
        key="1"
        filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
        showCustomFilter=false
        refreshFilters=false
      />
    </div>
  }

  <RenderIf condition={filterValueDict->Dict.toArray->Array.length > 0}>
    {switch chartEntity1 {
    | Some(chartEntity) =>
      <div>
        <div className="flex items-center justify-between">
          <PageUtils.PageHeading title=pageTitle />
          // Refactor required
          <div className="mr-4">
            <RenderIf condition={moduleName == "Refunds" || moduleName == "Disputes"}>
              <OMPSwitchHelper.OMPViews
                views={OMPSwitchUtils.analyticsViewList(~checkUserEntity)}
                selectedEntity={analyticsEntity}
                onChange={updateAnalytcisEntity}
                entityMapper=UserInfoUtils.analyticsEntityMapper
              />
            </RenderIf>
          </div>
        </div>
        <div className="mt-2 -ml-1"> topFilterUi </div>
        <div>
          <div className="mt-5">
            <DynamicSingleStat
              entity=singleStatEntity
              startTimeFilterKey
              endTimeFilterKey
              filterKeys=chartEntity.allFilterDimension
              moduleName
              showPercentage=false
              statSentiment={singleStatEntity.statSentiment->Option.getOr(Dict.make())}
            />
          </div>
          <div className="flex flex-row">
            {switch analyticsType {
            | AUTHENTICATION =>
              <div className="flex flex-col bg-transparent w-full h-max">
                {switch funnelChartEntity {
                | Some(funnelChartEntity) =>
                  <div className={tabDetailsClass}>
                    <TabDetails
                      chartEntity={{...funnelChartEntity, moduleName: `${moduleName}Funnel`}}
                      activeTab={None}
                      defaultSort
                      getTable
                      distributionArray
                      colMapper
                      tableEntity
                      deltaMetrics
                      deltaArray
                      tableUpdatedHeading
                      tableGlobalFilter
                      moduleName={`${moduleName}Funnel`}
                      updateUrl={dict => {
                        let updateUrlWithPrefix = updateUrlWithPrefix("Funnel")
                        updateUrlWithPrefix(dict)
                      }}
                      weeklyTableMetricsCols
                    />
                  </div>
                | None => React.null
                }}
                <div className={tabDetailsClass}>
                  {switch barChartEntity {
                  | Some(barChartEntity) =>
                    <TabDetails
                      chartEntity={{...barChartEntity, moduleName: `${moduleName}Bar`}}
                      activeTab={Some(["browser_name"])}
                      defaultSort
                      getTable
                      colMapper
                      tableEntity
                      distributionArray
                      deltaMetrics
                      deltaArray
                      tableUpdatedHeading
                      tableGlobalFilter
                      moduleName={`${moduleName}Bar`}
                      updateUrl={dict => {
                        let updateUrlWithPrefix = updateUrlWithPrefix("Bar")
                        updateUrlWithPrefix(dict)
                      }}
                      weeklyTableMetricsCols
                    />
                  | None => React.null
                  }}
                </div>
                {switch pieChartEntity {
                | Some(pieChartEntity) =>
                  <div className={tabDetailsClass}>
                    <TabDetails
                      chartEntity={pieChartEntity}
                      activeTab={Some(["platform"])}
                      defaultSort
                      getTable
                      colMapper
                      tableEntity
                      distributionArray
                      deltaMetrics
                      deltaArray
                      tableUpdatedHeading
                      tableGlobalFilter
                      moduleName
                      updateUrl={dict => {
                        let updateUrlWithPrefix = updateUrlWithPrefix("")
                        updateUrlWithPrefix(dict)
                      }}
                      weeklyTableMetricsCols
                    />
                    <TabDetails
                      chartEntity={pieChartEntity}
                      activeTab={Some(["component"])}
                      defaultSort
                      getTable
                      colMapper
                      distributionArray
                      tableEntity
                      deltaMetrics
                      deltaArray
                      tableUpdatedHeading
                      tableGlobalFilter
                      moduleName
                      updateUrl={dict => {
                        let updateUrlWithPrefix = updateUrlWithPrefix("")
                        updateUrlWithPrefix(dict)
                      }}
                      weeklyTableMetricsCols
                    />
                  </div>
                | None => React.null
                }}
              </div>
            | _ =>
              <div className="flex flex-col h-full overflow-scroll w-full mt-5">
                <DynamicTabs
                  tabs=filteredTabVales
                  maxSelection=3
                  tabId=moduleName
                  setActiveTab
                  updateUrlDict={dict => {
                    let updateUrlWithPrefix = updateUrlWithPrefix("")
                    updateUrlWithPrefix(dict)
                  }}
                  tabContainerClass="analyticsTabs"
                  initalTab=?activeTab
                />
                <TabDetails
                  chartEntity
                  activeTab
                  defaultSort
                  distributionArray
                  getTable
                  colMapper
                  tableEntity
                  deltaMetrics
                  deltaArray
                  tableUpdatedHeading
                  tableGlobalFilter
                  moduleName
                  updateUrl={dict => {
                    let updateUrlWithPrefix = updateUrlWithPrefix("")
                    updateUrlWithPrefix(dict)
                  }}
                  weeklyTableMetricsCols
                  formatData
                />
              </div>
            }}
          </div>
        </div>
      </div>
    | _ => React.null
    }}
  </RenderIf>
}
