module MetricsState = {
  @react.component
  let make = (
    ~singleStatEntity,
    ~filterKeys,
    ~startTimeFilterKey,
    ~endTimeFilterKey,
    ~moduleName,
    ~heading,
    ~formaPayload: option<DynamicSingleStat.singleStatBodyEntity => string>=?,
  ) => {
    <div>
      <h2 className="font-bold text-xl text-black text-opacity-80"> {heading->React.string} </h2>
      <DynamicSingleStat
        entity=singleStatEntity
        startTimeFilterKey
        endTimeFilterKey
        filterKeys
        moduleName
        showPercentage=false
        statSentiment={singleStatEntity.statSentiment->Option.getOr(Dict.make())}
        ?formaPayload
      />
    </div>
  }
}

module TableWrapper = {
  open LogicUtils
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

    let updateTableData = json => {
      switch weeklyTableMetricsCols {
      | Some(cols) => getWeeklyData(json, cols)->ignore
      | None => {
          let data = json->getDictFromJsonObject
          let value = data->getJsonObjectFromDict("queryData")->getTable->Array.map(Nullable.make)

          setTableData(_ => value)
          setTableDataLoading(_ => false)
          setShowTable(_ => true)
        }
      }
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
        ->thenResolve(json => json->updateTableData)
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
              <Analytics.BaseTableComponent
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
      (~item: option<'t>, ~dateObj: option<AnalyticsUtils.prevDates>, 'colType) => Table.header,
    >,
    ~tableGlobalFilter: option<(array<Nullable.t<'t>>, JSON.t) => array<Nullable.t<'t>>>,
    ~moduleName,
    ~updateUrl: Dict.t<string> => unit,
    ~weeklyTableMetricsCols,
    ~formatData=None,
  ) => {
    let wrapperClass = "bg-white border rounded-lg p-8 mt-3 mb-7"

    let tabTitleMapper = Dict.make()

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
          comparitionWidget=true
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

    {tab}
  }
}

module OverallSummary = {
  open LogicUtils
  @react.component
  let make = (
    ~filteredTabVales,
    ~moduleName,
    ~filteredTabKeys,
    ~chartEntity: DynamicChart.entity,
    ~defaultSort,
    ~getTable,
    ~colMapper,
    ~distributionArray=None,
    ~tableEntity,
    ~deltaMetrics: array<string>,
    ~deltaArray: array<string>,
    ~tableUpdatedHeading: option<
      (~item: option<'t>, ~dateObj: option<AnalyticsUtils.prevDates>, 'colType) => Table.header,
    >=?,
    ~tableGlobalFilter: option<(array<Nullable.t<'t>>, JSON.t) => array<Nullable.t<'t>>>=?,
    ~weeklyTableMetricsCols=?,
    ~formatData=None,
    ~startTimeFilterKey,
    ~endTimeFilterKey,
    ~heading,
  ) => {
    let {filterValue, filterValueJson, updateExistingKeys} = React.useContext(
      FilterContext.filterContext,
    )

    let initTab = switch filteredTabKeys->Array.get(0) {
    | Some(val) => [val]
    | None => filteredTabKeys
    }
    let (activeTav, setActiveTab) = React.useState(_ =>
      filterValueJson->getStrArrayFromDict(`${moduleName}.tabName`, initTab)
    )

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

    let activeTab = React.useMemo(() => {
      Some(
        filterValueJson
        ->getStrArrayFromDict(`${moduleName}.tabName`, activeTav)
        ->Array.filter(item => item->LogicUtils.isNonEmptyString),
      )
    }, [filterValueJson])

    let setActiveTab = React.useMemo(() => {
      (str: string) => {
        setActiveTab(_ => str->String.split(","))
      }
    }, [setActiveTab])

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

    <div>
      <h2 className="font-bold text-xl text-black text-opacity-80"> {heading->React.string} </h2>
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
  }
}
