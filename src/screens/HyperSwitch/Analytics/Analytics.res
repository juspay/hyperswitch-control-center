external toString: option<Js.Json.t> => string = "%identity"
external convertToStrDict: 't => Js.Json.t = "%identity"
external evToString: ReactEvent.Form.t => string = "%identity"
external asJson: 'a => Js.Json.t = "%identity"
external sankeyTest: string => SankeyCharts.sankeyEntity = "%identity"
@get external keyCode: 'a => int = "keyCode"
external formEventToStr: ReactEvent.Form.t => string = "%identity"
type window
@val external window: window = "window"
@scope("window") @val external parent: window = "parent"

open LogicUtils

module BaseTableComponent = {
  @react.component
  let make = (
    ~filters as _: (string, string),
    ~tableData,
    ~defaultSort: string,
    ~tableDataLoading: bool,
    ~transactionTableDefaultCols,
    ~newDefaultCols: array<'colType>,
    ~newAllCols: array<'colType>,
    ~colMapper as _: 'colType => string,
    ~tableEntity: EntityType.entityType<'colType, 't>,
    ~tableGlobalFilter as _: option<
      (array<Js.Nullable.t<'t>>, Js.Json.t) => array<Js.Nullable.t<'t>>,
    >,
    ~activeTab as _,
  ) => {
    open DynamicTableUtils

    let (authStatus, _setAuthStatus) = React.useContext(AuthInfoProvider.authStatusContext)
    let _userInfoText = React.useMemo1(() => {
      switch authStatus {
      | LoggedIn(info) =>
        `${info.merchantId}_tab_performance_table_table_${info.username}_currentTime` // tab name also need to be added based on tab currentTime need to be added
      | LoggedOut => ""
      | CheckingAuthStatus => ""
      }
    }, [authStatus])

    let (offset, setOffset) = React.useState(_ => 0)
    let (_, setCounter) = React.useState(_ => 1)
    let refetch = React.useCallback1(_ => {
      setCounter(p => p + 1)
    }, [setCounter])

    let visibleColumns = Recoil.useRecoilValueFromAtom(transactionTableDefaultCols)

    let defaultSort: Table.sortedObject = {
      key: defaultSort,
      order: Table.INC,
    }

    let modifiedTableEntity = React.useMemo3(() => {
      {
        ...tableEntity,
        defaultColumns: newDefaultCols,
        allColumns: Some(newAllCols),
      }
    }, (tableEntity, newDefaultCols, newAllCols))

    let tableBorderClass = "border-collapse border border-jp-gray-940 border-solid border-2 rounded-sm border-opacity-30 dark:border-jp-gray-dark_table_border_color dark:border-opacity-30 mt-7"

    <div className="flex flex-1 flex-col m-4">
      <RefetchContextProvider value=refetch>
        {if tableDataLoading {
          <DynamicTableUtils.TableDataLoadingIndicator showWithData={true} />
        } else {
          <div className="relative">
            <div
              className="absolute font-bold text-xl bg-white w-full text-black text-opacity-75 dark:bg-jp-gray-950 dark:text-white dark:text-opacity-75">
              {React.string("Summary Table")}
            </div>
            <LoadedTable
              visibleColumns
              title="Summary Table"
              hideTitle=true
              actualData={tableData}
              entity=modifiedTableEntity
              resultsPerPage=10
              totalResults={tableData->Js.Array2.length}
              offset
              setOffset
              defaultSort
              currrentFetchCount={tableData->Js.Array2.length}
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
    ~getTable: Js.Json.t => array<'t>,
    ~colMapper: 'colType => string,
    ~tableEntity: EntityType.entityType<'colType, 't>,
    ~deltaMetrics: array<string>,
    ~deltaArray: array<string>,
    ~tableUpdatedHeading as _: option<
      (~item: option<'t>, ~dateObj: option<AnalyticsUtils.prevDates>, 'colType) => Table.header,
    >,
    ~tableGlobalFilter: option<(array<Js.Nullable.t<'t>>, Js.Json.t) => array<Js.Nullable.t<'t>>>,
    ~moduleName,
    ~weeklyTableMetricsCols,
  ) => {
    let customFilter = Recoil.useRecoilValueFromAtom(AnalyticsAtoms.customFilterAtom)
    let getAllFilter = UrlUtils.useGetFilterDictFromUrl("")
    let fetchDetails = APIUtils.useUpdateMethod()
    let (_, setDefaultFilter) = Recoil.useRecoilState(AnalyticsHooks.defaultFilter)
    let (showTable, setShowTable) = React.useState(_ => false)
    let {getHeading, allColumns, defaultColumns} = tableEntity
    let activeTabStr = activeTab->Belt.Option.getWithDefault([])->Js.Array2.joinWith("-")
    let (startTimeFilterKey, endTimeFilterKey) = dateKeys
    let (tableDataLoading, setTableDataLoading) = React.useState(_ => true)
    let (tableData, setTableData) = React.useState(_ => []->Js.Array2.map(Js.Nullable.return))

    let getTopLevelFilter = React.useMemo1(() => {
      getAllFilter
      ->Js.Dict.entries
      ->Belt.Array.keepMap(item => {
        let (key, value) = item
        let keyArr = key->Js.String2.split(".")
        let prefix = keyArr->Belt.Array.get(0)->Belt.Option.getWithDefault("")
        if prefix === moduleName && prefix !== "" {
          None
        } else {
          Some((prefix, value))
        }
      })
      ->Js.Dict.fromArray
    }, [getAllFilter])

    let allColumns = allColumns->Belt.Option.getWithDefault([])
    let allFilterKeys = Js.Array2.concat([startTimeFilterKey, endTimeFilterKey], filterKeys)

    let topFiltersToSearchParam = React.useMemo1(() => {
      let filterSearchParam =
        getTopLevelFilter
        ->Js.Dict.entries
        ->Belt.Array.keepMap(entry => {
          let (key, value) = entry
          if allFilterKeys->Js.Array2.includes(key) {
            switch value->Js.Json.classify {
            | JSONString(str) => `${key}=${str}`->Some
            | JSONNumber(num) => `${key}=${num->Js.String.make}`->Some
            | JSONArray(arr) => `${key}=[${arr->Js.String.make}]`->Some
            | _ => None
            }
          } else {
            None
          }
        })
        ->Js.Array2.joinWith("&")

      filterSearchParam
    }, [getTopLevelFilter])

    let filterValueFromUrl = React.useMemo1(() => {
      getTopLevelFilter
      ->Js.Dict.entries
      ->Belt.Array.keepMap(entries => {
        let (key, value) = entries
        filterKeys->Js.Array2.includes(key) ? Some((key, value)) : None
      })
      ->Js.Dict.fromArray
      ->Js.Json.object_
      ->Some
    }, [topFiltersToSearchParam])

    let startTimeFromUrl = React.useMemo1(() => {
      getTopLevelFilter->getString(startTimeFilterKey, "")
    }, [topFiltersToSearchParam])
    let endTimeFromUrl = React.useMemo1(() => {
      getTopLevelFilter->getString(endTimeFilterKey, "")
    }, [topFiltersToSearchParam])

    let parseData = json => {
      let data = json->getDictFromJsonObject
      let value = data->getJsonObjectFromDict("queryData")->getArrayFromJson([])
      value
    }

    let generateIDFromKeys = (keys, dict) => {
      keys
      ->Belt.Option.getWithDefault([])
      ->Js.Array2.map(key => {
        dict->Js.Dict.get(key)
      })
      ->Js.Array2.joinWith("")
    }

    open AnalyticsTypes
    let getUpdatedData = (data, weeklyData, cols) => {
      let dataArr = data->parseData
      let weeklyArr = weeklyData->parseData

      dataArr
      ->Js.Array2.map(item => {
        let dataDict = item->getDictFromJsonObject
        let dataKey = activeTab->generateIDFromKeys(dataDict)

        weeklyArr->Js.Array2.forEach(newItem => {
          let weekklyDataDict = newItem->getDictFromJsonObject
          let weekklyDataKey = activeTab->generateIDFromKeys(weekklyDataDict)

          if dataKey === weekklyDataKey {
            cols->Js.Array2.forEach(
              obj => {
                switch weekklyDataDict->Js.Dict.get(obj.refKey) {
                | Some(val) => dataDict->Js.Dict.set(obj.newKey, val)
                | _ => ()
                }
              },
            )
          }
        })
        dataDict->Js.Json.object_
      })
      ->Js.Json.array
      ->getTable
      ->Js.Array2.map(Js.Nullable.return)
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

    React.useEffect3(() => {
      setShowTable(_ => false)
      if startTimeFromUrl !== "" && endTimeFromUrl !== "" {
        let tableReqBody = AnalyticsUtils.generateTablePayload(
          ~startTimeFromUrl,
          ~endTimeFromUrl,
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

        fetchDetails(tableEntity.uri, tableReqBody, Post)
        ->thenResolve(json => {
          switch weeklyTableMetricsCols {
          | Some(cols) => getWeeklyData(json, cols)->ignore
          | _ => {
              let data = json->getDictFromJsonObject
              let value =
                data
                ->getJsonObjectFromDict("queryData")
                ->getTable
                ->Js.Array2.map(Js.Nullable.return)

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
    let newDefaultCols = React.useMemo1(() => {
      activeTab
      ->Belt.Option.getWithDefault([])
      ->Belt.Array.keepMap(item => {
        defaultColumns
        ->Belt.Array.keepMap(
          columnItem => {
            let val = columnItem->getHeading
            val.key === item ? Some(columnItem) : None
          },
        )
        ->Belt.Array.get(0)
      })
      ->Belt.Array.concat(allColumns)
    }, [activeTabStr])

    let newAllCols = React.useMemo1(() => {
      defaultColumns
      ->Belt.Array.keepMap(item => {
        let val = item->getHeading
        activeTab->Belt.Option.getWithDefault([])->Js.Array2.includes(val.key) ? Some(item) : None
      })
      ->Belt.Array.concat(allColumns)
    }, [activeTabStr])

    let transactionTableDefaultCols = React.useMemo2(() => {
      Recoil.atom(. `${moduleName}DefaultCols${activeTabStr}`, newDefaultCols)
    }, (newDefaultCols, `${moduleName}DefaultCols${activeTabStr}`))

    let timeRange =
      [
        ("startTime", startTimeFromUrl->Js.Json.string),
        ("endTime", endTimeFromUrl->Js.Json.string),
      ]->Js.Dict.fromArray

    let filters = filterValueFromUrl->Belt.Option.getWithDefault(Js.Dict.empty()->Js.Json.object_)

    let defaultFilters =
      [
        ("timeRange", timeRange->Js.Json.object_),
        ("filters", filters),
        ("source", "BATCH"->Js.Json.string),
      ]->Js.Dict.fromArray
    let dict =
      [
        (
          "activeTab",
          activeTab->Belt.Option.getWithDefault([])->Js.Array2.map(Js.Json.string)->Js.Json.array,
        ),
        ("filter", defaultFilters->Js.Json.object_),
      ]->Js.Dict.fromArray

    setDefaultFilter(._ => dict->Js.Json.object_->Js.Json.stringify)

    showTable
      ? <>
          <div
            className="flex border items-start border-blue-800 text-sm rounded-md gap-2 px-4 py-3 mt-7">
            <Icon name="info-vacent" className="text-blue-900 mt-1" size=18 />
            {"'Other' denotes those incomplete or failed payments with no assigned values for the corresponding parameters due to reasons like customer drop-offs, technical failures, etc."->React.string}
          </div>
          <div className="h-full -mx-4 overflow-scroll">
            <Form>
              <BaseTableComponent
                filters=(startTimeFromUrl, endTimeFromUrl)
                tableData
                tableDataLoading
                transactionTableDefaultCols
                defaultSort
                newDefaultCols
                newAllCols
                tableEntity
                colMapper
                tableGlobalFilter
                activeTab={activeTab->Belt.Option.getWithDefault([])}
              />
            </Form>
          </div>
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
    ~getTable: Js.Json.t => array<'t>,
    ~colMapper: 'colType => string,
    ~tableEntity: option<EntityType.entityType<'colType, 't>>,
    ~deltaMetrics: array<string>,
    ~deltaArray: array<string>,
    ~tableUpdatedHeading: option<
      (~item: option<'t>, ~dateObj: option<AnalyticsUtils.prevDates>, 'colType) => Table.header,
    >,
    ~tableGlobalFilter: option<(array<Js.Nullable.t<'t>>, Js.Json.t) => array<Js.Nullable.t<'t>>>,
    ~moduleName,
    ~updateUrl: Js.Dict.t<string> => unit,
    ~weeklyTableMetricsCols,
  ) => {
    open AnalyticsTypes
    let analyticsType = moduleName->getAnalyticsType

    let id =
      activeTab
      ->Belt.Option.getWithDefault(["tab"])
      ->Array.reduce("", (acc, tabName) => {acc->Js.String2.concat(tabName)})

    let isMobileView = MatchMedia.useMobileChecker()

    let wrapperClass = React.useMemo1(() =>
      switch analyticsType {
      | USER_JOURNEY => `h-auto basis-full mt-4 ${isMobileView ? "w-full" : "w-1/2"}`
      | _ => "bg-white border rounded p-8 mt-5 mb-7"
      }
    , [isMobileView])

    let tabTitleMapper = switch analyticsType {
    | USER_JOURNEY =>
      [
        ("browser_name", "browser"),
        ("component", "checkout_platform"),
        ("platform", "customer_device"),
      ]->Js.Dict.fromArray
    | _ => Js.Dict.empty()
    }

    let tab =
      <div className=wrapperClass>
        <DynamicChart
          entity=chartEntity
          selectedTab=activeTab
          chartId=moduleName
          updateUrl
          enableBottomChart=false
          tabTitleMapper
          showTableLegend=false
          showMarkers=true
          legendType=HighchartTimeSeriesChart.Points
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
          />
        | None => React.null
        }}
      </div>

    switch analyticsType {
    | USER_JOURNEY => tab
    | _ => <FramerMotion.TransitionComponent id={id}> {tab} </FramerMotion.TransitionComponent>
    }
  }
}

open AnalyticsTypes
@react.component
let make = (
  ~pageTitle="",
  ~pageSubTitle="",
  ~startTimeFilterKey: string,
  ~endTimeFilterKey: string,
  ~chartEntity: nestedEntityType,
  ~defaultSort: string,
  ~tabKeys: array<string>,
  ~tabValues: array<DynamicTabs.tab>,
  ~initialFilters: Js.Json.t => array<EntityType.initialFilters<'t>>,
  ~initialFixedFilters: Js.Json.t => array<EntityType.initialFilters<'t>>,
  ~options: Js.Json.t => array<EntityType.optionType<'t>>,
  ~getTable: Js.Json.t => array<'a>,
  ~colMapper: 'colType => string,
  ~tableEntity: option<EntityType.entityType<'colType, 't>>=?,
  ~deltaMetrics: array<string>,
  ~deltaArray: array<string>,
  ~singleStatEntity: DynamicSingleStat.entityType<'singleStatColType, 'b, 'b2>,
  ~filterUri,
  ~tableUpdatedHeading: option<
    (~item: option<'t>, ~dateObj: option<AnalyticsUtils.prevDates>, 'colType) => Table.header,
  >=?,
  ~tableGlobalFilter: option<(array<Js.Nullable.t<'t>>, Js.Json.t) => array<Js.Nullable.t<'t>>>=?,
  ~moduleName: string,
  ~weeklyTableMetricsCols=?,
) => {
  let {generateReport} = FeatureFlagUtils.featureFlagObject
  let analyticsType = moduleName->getAnalyticsType
  let {filterValue, updateExistingKeys} = React.useContext(
    AnalyticsUrlUpdaterContext.urlUpdaterContext,
  )
  let getModuleFilters = UrlUtils.useGetFilterDictFromUrl("")
  let (_totalVolume, setTotalVolume) = React.useState(_ => 0)
  let (reportModal, setReportModal) = React.useState(_ => false)
  let defaultFilters = [startTimeFilterKey, endTimeFilterKey]

  let (_filterAtom, setFilterAtom) = Recoil.useRecoilState(AnalyticsAtoms.customFilterAtom)
  React.useEffect0(() => {
    setFilterAtom(._ => "")
    None
  })
  let hyperswitchMixPanel = HSMixPanel.useSendEvent()
  let (filteredTabKeys, filteredTabVales) = (tabKeys, tabValues)
  let chartEntity1 = chartEntity.default // User Journey - SemiDonut (Payment Metrics), Others - Default Chart Entity
  let pieChartEntity = chartEntity.userPieChart // SemiDonut (User Metrics)
  let barChartEntity = chartEntity.userBarChart // HorizontalBar (User Metrics)
  let funnelChartEntity = chartEntity.userFunnelChart // Funnel (All Metrics)
  let chartEntity1 = switch chartEntity1 {
  | Some(chartEntity) => Some({...chartEntity, allFilterDimension: filteredTabKeys})
  | None => None
  }

  let getFilterData = AnalyticsHooks.useGetFiltersData()

  let (activeTav, setActiveTab) = React.useState(_ =>
    getModuleFilters->getStrArrayFromDict(
      `${moduleName}.tabName`,
      [filteredTabKeys->Belt.Array.get(0)->Belt.Option.getWithDefault("")],
    )
  )
  let setActiveTab = React.useMemo1(() => {
    (str: string) => {
      setActiveTab(_ => str->Js.String2.split(","))
    }
  }, [setActiveTab])

  let getModuleFilters = UrlUtils.useGetFilterDictFromUrl("")
  let startTimeVal = getModuleFilters->getString(startTimeFilterKey, "")

  let endTimeVal = getModuleFilters->getString(endTimeFilterKey, "")

  let updateComponentPrefrences = UrlUtils.useUpdateUrlWith(~prefix="")

  let updateUrlWithPrefix = React.useMemo1(() => {
    (chartType: string) => {
      (dict: Js.Dict.t<string>) => {
        let prev = filterValue

        let prevDictArr =
          prev
          ->Js.Dict.entries
          ->Belt.Array.keepMap(item => {
            let (key, _) = item
            switch dict->Js.Dict.get(key) {
            | Some(_) => None
            | None => Some(item)
            }
          })

        let currentDict =
          dict
          ->Js.Dict.entries
          ->Belt.Array.keepMap(item => {
            let (key, value) = item
            if value !== "" {
              Some((`${moduleName}${chartType}.${key}`, value))
            } else {
              None
            }
          })

        updateExistingKeys(Js.Array2.concat(prevDictArr, currentDict)->Js.Dict.fromArray)
      }
    }
  }, [updateExistingKeys])

  let setInitialFilters = HSwitchRemoteFilter.useSetInitialFilters(
    ~updateComponentPrefrences,
    ~updateExistingKeys,
    ~startTimeFilterKey,
    ~endTimeFilterKey,
  )

  React.useEffect0(() => {
    setInitialFilters()
    None
  })

  let url = RescriptReactRouter.useUrl()
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

  let activeTab = React.useMemo1(() => {
    Some(
      getModuleFilters
      ->getStrArrayFromDict(`${moduleName}.tabName`, activeTav)
      ->Js.Array2.filter(item => item !== ""),
    )
  }, [getModuleFilters])

  let isMobileView = MatchMedia.useMobileChecker()

  let tabDetailsClass = React.useMemo1(() => {
    isMobileView ? "flex flex-col gap-4 my-4" : "flex flex-row gap-4 my-4"
  }, [isMobileView])

  let hideFiltersDefaultValue =
    filterValue
    ->Js.Dict.keys
    ->Js.Array2.filter(item => tabKeys->Js.Array2.find(key => key == item)->Belt.Option.isSome)
    ->Js.Array2.length < 1

  let topFilterUi = switch filterDataOrig {
  | Some(filterData) => {
      let filterData = switch analyticsType {
      | USER_JOURNEY => {
          let filteredDims = ["payment_method", "payment_experience"]
          let queryData =
            filterData
            ->getDictFromJsonObject
            ->getJsonObjectFromDict("queryData")
            ->getArrayFromJson([])
            ->Js.Array2.filter(dimension => {
              let dim = dimension->getDictFromJsonObject->getString("dimension", "")
              filteredDims->Js.Array2.includes(dim)->not
            })
            ->Js.Json.array
          [("queryData", queryData)]->Js.Dict.fromArray->Js.Json.object_
        }
      | _ => filterData
      }
      <div className="flex flex-row">
        <DynamicFilter
          initialFilters={initialFilters(filterData)}
          options=[]
          popupFilterFields={options(filterData)}
          initialFixedFilters={initialFixedFilters(filterData)}
          defaultFilterKeys=defaultFilters
          tabNames=tabKeys
          updateUrlWith=updateExistingKeys
          key="0"
          filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
          showCustomFilter=false
          hideFiltersDefaultValue
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
        initialFixedFilters={initialFixedFilters(filterData)}
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

  <UIUtils.RenderIf condition={getModuleFilters->Js.Dict.entries->Js.Array2.length > 0}>
    {switch chartEntity1 {
    | Some(chartEntity) =>
      <div className="flex flex-col flex-1 overflow-scroll">
        <div className="flex items-center justify-between">
          <PageUtils.PageHeading title=pageTitle subTitle=pageSubTitle />
          <UIUtils.RenderIf condition={generateReport}>
            <Button
              text="Generate Reports"
              buttonType={Primary}
              customButtonStyle="!p-2"
              onClick={_ => {
                hyperswitchMixPanel(
                  ~eventName=Some(`${url.path->LogicUtils.getListHead}_generate_reports`),
                  (),
                )
                setReportModal(_ => true)
              }}
            />
          </UIUtils.RenderIf>
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
              setTotalVolume
              showPercentage=false
              statSentiment={singleStatEntity.statSentiment->Belt.Option.getWithDefault(
                Js.Dict.empty(),
              )}
            />
          </div>
          <div className="flex flex-row">
            {switch analyticsType {
            | USER_JOURNEY =>
              switch (pieChartEntity, barChartEntity, funnelChartEntity) {
              | (Some(pieChartEntity), Some(barChartEntity), Some(funnelChartEntity)) =>
                <div className="flex flex-col bg-transparent w-full h-max">
                  <div className={tabDetailsClass}>
                    <TabDetails
                      chartEntity={{...funnelChartEntity, moduleName: "UserJourneyFunnel"}}
                      activeTab={None}
                      defaultSort
                      getTable
                      colMapper
                      tableEntity
                      deltaMetrics
                      deltaArray
                      tableUpdatedHeading
                      tableGlobalFilter
                      moduleName={"UserJourneyFunnel"}
                      updateUrl={dict => {
                        let updateUrlWithPrefix = updateUrlWithPrefix("Funnel")
                        updateUrlWithPrefix(dict)
                      }}
                      weeklyTableMetricsCols
                    />
                  </div>
                  <div className={tabDetailsClass}>
                    <TabDetails
                      chartEntity={chartEntity}
                      activeTab={Some(["payment_method"])}
                      defaultSort
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
                    />
                    <TabDetails
                      chartEntity={{...barChartEntity, moduleName: "UserJourneyBar"}}
                      activeTab={Some(["browser_name"])}
                      defaultSort
                      getTable
                      colMapper
                      tableEntity
                      deltaMetrics
                      deltaArray
                      tableUpdatedHeading
                      tableGlobalFilter
                      moduleName={"UserJourneyBar"}
                      updateUrl={dict => {
                        let updateUrlWithPrefix = updateUrlWithPrefix("Bar")
                        updateUrlWithPrefix(dict)
                      }}
                      weeklyTableMetricsCols
                    />
                  </div>
                  <div className={tabDetailsClass}>
                    <TabDetails
                      chartEntity={pieChartEntity}
                      activeTab={Some(["platform"])}
                      defaultSort
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
                    />
                    <TabDetails
                      chartEntity={pieChartEntity}
                      activeTab={Some(["component"])}
                      defaultSort
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
                    />
                  </div>
                </div>
              | _ => React.null
              }
            | _ =>
              <div className="flex flex-col h-full overflow-scroll w-full">
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
                />
              </div>
            }}
          </div>
        </div>
      </div>
    | _ => React.null
    }}
    <UIUtils.RenderIf condition={reportModal}>
      <DownloadReportModal reportModal setReportModal />
    </UIUtils.RenderIf>
  </UIUtils.RenderIf>
}
