let useRemoteFilter = (~searchParams, ~remoteFilters, ~remoteOptions, ~mandatoryRemoteKeys) => {
  let (remoteFiltersFromUrl, setRemoteFiltersFromUrl) = React.useState(() =>
    JSON.Encode.object(Dict.make())
  )

  let remoteFiltersFromUrlTemp = React.useMemo1(() => {
    RemoteFiltersUtils.getInitialValuesFromUrl(
      ~searchParams,
      ~initialFilters=remoteFilters,
      ~options=remoteOptions,
      ~mandatoryRemoteKeys,
      (),
    )
  }, [searchParams])
  if remoteFiltersFromUrlTemp->JSON.stringify !== remoteFiltersFromUrl->JSON.stringify {
    setRemoteFiltersFromUrl(_prev => remoteFiltersFromUrlTemp)
  }
  remoteFiltersFromUrl
}

@react.component
let make = (
  ~entity: EntityType.entityType<'colType, 't>,
  ~title,
  ~titleSize: NewThemeUtils.headingSize=Large,
  ~hideTitle=false,
  ~description=?,
  ~hideFiltersOnNoData=false,
  ~showSerialNumber=false,
  ~tableActions=?,
  ~isTableActionBesideFilters=false,
  ~hideFilterTopPortals=true,
  ~bottomActions=?,
  ~resultsPerPage=15,
  ~onEntityClick=?,
  ~method: Fetch.requestMethod=Fetch.Post,
  ~path=?,
  ~downloadCsv=?,
  ~prefixAddition=?,
  ~ignoreUrlUpdate=false,
  ~advancedSearchComponent=?,
  ~body=?,
  ~isFiltersInPortal=true,
  ~defaultSort=?,
  ~dataNotFoundComponent=?,
  ~visibleColumns as visibleColumnsProp=?,
  ~activeColumnsAtom=?,
  ~customizedColumnsStyle="",
  ~renderCard=?,
  ~getCustomUriForOrder=?,
  ~portalKey="desktopNavbarLeft",
  ~isEulerOrderEntity=false,
  ~tableLocalFilter=false,
  ~dropdownSearchKeyValueNames=[],
  ~searchkeysDict=Dict.make(),
  ~mandatoryRemoteKeys=[],
  ~isSearchKeyArray=false,
  ~forcePreventConcatData=false,
  ~collapseTableRow=false,
  ~showRefreshFilter=true,
  ~showRemoteOptions=false,
  ~filterButtonStyle="",
  ~getRowDetails=_ => React.null,
  ~onMouseEnter=?,
  ~onMouseLeave=?,
  ~customFilterStyle="",
  ~reactWindow=false,
  ~frozenUpto=?,
  ~heightHeadingClass=?,
  ~rowHeightClass="",
  ~titleTooltip=false,
  ~rowCustomClass="",
  ~requireDateFormatting=false,
  ~autoApply=?,
  ~showClearFilter=true,
  ~addDataLoading=false,
  ~filterObj=?,
  ~setFilterObj=?,
  ~filterCols=?,
  ~filterIcon=?,
  ~applyFilters=false,
  ~errorButtonType: Button.buttonType=Primary,
  ~maxTableHeight="",
  ~tableheadingClass="",
  ~ignoreHeaderBg=false,
  ~customLocalFilterStyle="",
  ~showFiltersSearch=false,
  ~showFilterBorder=false,
  ~headBottomMargin="mb-6 mobile:mb-4",
  ~noDataMsg="No Data Available",
  ~checkBoxProps=?,
  ~tableBorderClass=?,
  ~paginationClass=?,
  ~tableDataBorderClass=?,
  ~tableActionBorder=?,
  ~disableURIdecode=false,
  ~mergeBodytoRemoteFilterDict=false,
  ~defaultKeysAllowed=?,
  ~urlKeyTypeDict: Dict.t<RemoteFiltersUtils.urlKEyType>=Dict.make(),
) => {
  open LogicUtils
  let {
    getObjects,
    dataKey,
    summaryKey,
    initialFilters,
    options,
    headers,
    uri,
    getSummary,
    searchValueDict,
    getNewUrl,
    defaultColumns,
    popupFilterFields,
    dateRangeFilterDict,
    filterCheck,
    filterForRow,
  } = entity
  let tableName =
    prefixAddition->Option.getOr(false)
      ? title->String.replaceRegExp(_, %re("/ /g"), "-")->String.toLowerCase->Some
      : None
  let (defaultFilters, setDefaultFilters) = React.useState(() => entity.defaultFilters)
  let defaultSummary: EntityType.summary = {totalCount: 0, count: 0}
  let (summary, setSummary) = React.useState(() => defaultSummary)
  let (data, setData) = React.useState(() => None)
  let (tableDataLoading, setTableDataLoading) = React.useState(() => false)
  let fetchApi = AuthHooks.useApiFetcher()
  let url = RescriptReactRouter.useUrl()
  let searchParams = disableURIdecode ? url.search : url.search->decodeURI
  let (refreshData, _setRefreshData) = React.useContext(RefreshStateContext.refreshStateContext)
  let (offset, setOffset) = React.useState(() => 0)
  let remoteFilters = initialFilters->Array.filter(item => item.localFilter->Option.isNone)
  let filtersFromUrl = getDictFromUrlSearchParams(searchParams)
  let localFilters = initialFilters->Array.filter(item => item.localFilter->Option.isSome)
  let showToast = ToastState.useShowToast()

  let localOptions =
    Array.concat(options, popupFilterFields)->Array.filter(item => item.localFilter->Option.isSome)
  let remoteOptions =
    Array.concat(options, popupFilterFields)->Array.filter(item => item.localFilter->Option.isNone)
  let remoteFiltersFromUrl = useRemoteFilter(
    ~searchParams,
    ~remoteFilters,
    ~remoteOptions,
    ~mandatoryRemoteKeys,
  )
  let isMobileView = MatchMedia.useMobileChecker()
  let resultsPerPage = isMobileView ? 10 : resultsPerPage
  let (fetchSuccess, setFetchSuccess) = React.useState(() => true)
  let (refetchCounter, setRefetchCounter) = React.useState(() => 0)
  let (showColumnSelector, setShowColumnSelector) = React.useState(() => false)

  let (finalData, setFinalData) = React.useState(_ => None)
  React.useEffect1(() => {
    setDefaultFilters(_ => entity.defaultFilters)
    None
  }, [entity.defaultFilters])
  React.useEffect5(() => {
    let remoteFilterDict = RemoteFiltersUtils.getFinalDict(
      ~filterJson=defaultFilters,
      ~filtersFromUrl=remoteFiltersFromUrl,
      ~options=remoteOptions->Array.concat(popupFilterFields),
      ~isEulerOrderEntity,
      ~dropdownSearchKeyValueNames,
      ~searchkeysDict,
      ~isSearchKeyArray,
      ~defaultKeysAllowed?,
      ~urlKeyTypeDict,
      (),
    )

    open Promise
    let finalJson = switch body {
    | Some(b) =>
      let remoteFilterDict = remoteFilterDict->getDictFromJsonObject
      if mergeBodytoRemoteFilterDict {
        DictionaryUtils.mergeDicts([b->getDictFromJsonObject, remoteFilterDict])->JSON.Encode.object
      } else {
        b
      }
    | None => remoteFilterDict
    }

    let clearData = () => {
      setData(_ => Some([]))
    }

    let setNewData = sampleRes => {
      if (
        (remoteFiltersFromUrl->getDictFromJsonObject != Dict.make() && offset == 0) ||
          forcePreventConcatData
      ) {
        clearData()
      }

      setData(prevData => {
        let newData = prevData->Option.getOr([])->Array.concat(sampleRes)
        Some(newData)
      })
    }

    let getCustomUri = (uri, searchValueDict) => {
      let uriList = Dict.keysToArray(searchValueDict)->Array.map(val => {
        let defaultFilterOffset = defaultFilters->getDictFromJsonObject->getInt("offset", 0)
        let dictValue = if val === "offset" {
          defaultFilterOffset->Int.toString
        } else {
          let x =
            filtersFromUrl
            ->Dict.get(val)
            ->Option.getOr(searchValueDict->Dict.get(val)->Option.getOr(""))
          if requireDateFormatting && (val == "startTime" || val == "endTime") {
            (x->DayJs.getDayJsForString).format(. "YYYY-MM-DD+HH:mm:ss")
          } else if requireDateFormatting && (val == "start_date" || val == "end_date") {
            (x->DayJs.getDayJsForString).format(. "YYYY-MM-DD HH:mm:ss")
          } else {
            x
          }
        }
        let urii = dictValue->isEmptyString || dictValue == "NA" ? "" : `${val}=${dictValue}`

        urii
      })
      let uri =
        uri ++ "?" ++ uriList->Array.filter(val => val->isNonEmptyString)->Array.joinWith("&")
      uri
    }

    let uri = switch searchValueDict {
    | Some(searchValueDict) => getCustomUri(uri, searchValueDict)
    | None => uri
    }
    let uri = switch getCustomUriForOrder {
    | Some(getCustomUri) => getCustomUri(uri, ~filtersJson=remoteFiltersFromUrl, ~finalJson)
    | None => uri
    }
    let uri = uri ++ getNewUrl(defaultFilters)
    setTableDataLoading(_ => true)
    fetchApi(uri, ~bodyStr=JSON.stringify(finalJson), ~headers, ~method_=method, ())
    ->then(resp => {
      let status = resp->Fetch.Response.status
      if status >= 300 {
        setFetchSuccess(_ => false)
        setTableDataLoading(_ => false)
      }

      Fetch.Response.json(resp)
    })
    ->then(json => {
      switch json->JSON.Classify.classify {
      | Array(_arr) => json->getObjects->Array.map(obj => obj->Nullable.make)->setNewData
      | Object(dict) => {
          let flattenedObject = JsonFlattenUtils.flattenObject(json, false)
          switch Dict.get(flattenedObject, dataKey) {
          | Some(x) => x->getObjects->Array.map(obj => obj->Nullable.make)->setNewData
          | None => ()
          }
          let summary = switch Dict.get(dict, summaryKey) {
          | Some(x) => x->getSummary
          | None => dict->JSON.Encode.object->getSummary
          }
          setSummary(_ => summary)
        }

      | _ =>
        showToast(
          ~message="Response was not a JSON object",
          ~toastType=ToastError,
          ~autoClose=true,
          (),
        )
      }
      setTableDataLoading(_ => false)
      resolve()
    })
    ->catch(_ => {
      resolve()
    })
    ->ignore

    None
  }, (remoteFiltersFromUrl, defaultFilters, fetchApi, refreshData, uri))

  React.useEffect1(() => {
    if refetchCounter > 0 {
      Window.Location.reload()
    }
    None
  }, [refetchCounter])

  let refetch = React.useCallback1(() => {
    setRefetchCounter(p => p + 1)
  }, [setRefetchCounter])

  let visibleColumns = visibleColumnsProp->Option.getOr(defaultColumns)
  let handleRefetch = () => {
    let rowFetched = data->Option.getOr([])->Array.length
    if rowFetched !== summary.totalCount {
      setTableDataLoading(_ => true)
      let newDefaultFilter =
        defaultFilters->JSON.Decode.object->Option.getOr(Dict.make())->Dict.toArray->Dict.fromArray

      Dict.set(newDefaultFilter, "offset", rowFetched->Int.toFloat->JSON.Encode.float)
      setDefaultFilters(_ => newDefaultFilter->JSON.Encode.object)
    }
  }

  let showLocalFilter =
    (localFilters->Array.length > 0 || localOptions->Array.length > 0) &&
      (applyFilters ? finalData : data)->Option.getOr([])->Array.length > 0
  let showRemoteFilter = remoteFilters->Array.length > 0 || remoteOptions->Array.length > 0

  let filters = {
    if (
      (Array.length(initialFilters) > 0 || Array.length(options) > 0) &&
      (showLocalFilter || showRemoteFilter) &&
      (!hideFiltersOnNoData || data->Option.getOr([])->Array.length > 0)
    ) {
      let children =
        <div className={`flex-1 ${customFilterStyle}`}>
          {if showLocalFilter {
            <LabelVisibilityContext showLabel=false>
              <LocalFilters
                entity
                setOffset
                ?path
                remoteFilters
                localFilters
                mandatoryRemoteKeys
                remoteOptions
                localOptions
                ?tableName
                customLocalFilterStyle
                showSelectFiltersSearch=showFiltersSearch
                disableURIdecode
              />
            </LabelVisibilityContext>
          } else {
            React.null
          }}
          <UIUtils.RenderIf condition=showRemoteFilter>
            <LabelVisibilityContext showLabel=false>
              <RemoteFilter
                defaultFilters=entity.defaultFilters
                requiredSearchFieldsList=entity.requiredSearchFieldsList
                setOffset
                refreshFilters=showRefreshFilter
                filterButtonStyle
                showRemoteOptions
                ?path
                title
                remoteFilters
                localFilters
                mandatoryRemoteKeys
                remoteOptions
                localOptions
                popupFilterFields
                ?tableName
                ?autoApply
                showClearFilter
                showSelectFiltersSearch=showFiltersSearch
                disableURIdecode
              />
            </LabelVisibilityContext>
          </UIUtils.RenderIf>
        </div>
      if isFiltersInPortal {
        <Portal to=portalKey> {children} </Portal>
      } else {
        children
      }
    } else {
      React.null
    }
  }

  React.useEffect1(() => {
    let temp = switch filterObj {
    | Some(obj) =>
      switch filterCols {
      | Some(cols) =>
        let _ = cols->Array.map(key => {
          obj[key] = filterForRow(data, key)
        })
        obj
      | _ => []
      }
    | _ => []
    }
    switch setFilterObj {
    | Some(fn) => fn(_ => temp)
    | _ => ()
    }
    None
  }, [data])
  let checkLength = ref(true)
  React.useEffect2(() => {
    let findVal = (accumulator, item: TableUtils.filterObject) =>
      Array.concat(accumulator, item.selected)
    let keys = switch filterObj {
    | Some(obj) => obj->Array.reduce([], findVal)
    | None => []
    }

    switch filterObj {
    | Some(obj) =>
      switch filterCols {
      | Some(cols) =>
        for i in 0 to cols->Array.length - 1 {
          checkLength :=
            checkLength.contents &&
            switch obj[cols[i]->Option.getOr(0)] {
            | Some(ele) => Array.length(ele.selected) > 0
            | None => false
            }
        }
      | _ => ()
      }
      if checkLength.contents {
        let newData = switch data {
        | Some(data) =>
          data->Array.filter(item => {
            switch item->Nullable.toOption {
            | Some(val) => filterCheck(val, keys)
            | _ => false
            }
          })
        | None => []
        }
        setFinalData(_ => Some(newData))
      } else {
        setFinalData(_ => data)
      }
    | _ => ()
    }
    None
  }, (filterObj, data))

  let dataLoading = addDataLoading ? tableDataLoading : false
  let customizeColumnButtonType: Button.buttonType = SecondaryFilled
  switch applyFilters ? finalData : data {
  | Some(actualData) => {
      let localFilteredData =
        localFilters->Array.length > 0 || localOptions->Array.length > 0
          ? RemoteFiltersUtils.getLocalFiltersData(
              ~resArr=actualData,
              ~dateRangeFilterDict,
              ~searchParams,
              ~initialFilters=localFilters,
              ~options=localOptions,
              (),
            )
          : actualData
      let currrentFetchCount = localFilteredData->Array.length

      open DynamicTableUtils
      let totalResults = if actualData->Array.length < summary.totalCount {
        summary.totalCount
      } else {
        currrentFetchCount
      }
      let customizeColumn = if (
        activeColumnsAtom->Option.isSome && entity.allColumns->Option.isSome && totalResults > 0
      ) {
        <Button
          text="Customize Columns"
          leftIcon=Button.CustomIcon(<Icon name="vertical_slider" size=15 className="mr-1" />)
          buttonType=customizeColumnButtonType
          buttonSize=XSmall
          onClick={_ => setShowColumnSelector(_ => true)}
          customButtonStyle=customizedColumnsStyle
          showBorder={true}
        />
      } else {
        React.null
      }

      let chooseCols = if customizeColumn === React.null {
        React.null
      } else {
        <ChooseColumnsWrapper
          entity
          totalResults
          defaultColumns
          activeColumnsAtom
          setShowColumnSelector
          showColumnSelector
        />
      }
      let filt =
        <div className={`flex flex-row gap-4`}>
          {filters}
          {chooseCols}
        </div>
      <RefetchContextProvider value=refetch>
        {if reactWindow {
          <ReactWindowTable
            visibleColumns
            entity
            actualData=localFilteredData
            title
            hideTitle
            ?description
            rightTitleElement=customizeColumn
            ?tableActions
            showSerialNumber
            totalResults
            ?onEntityClick
            ?downloadCsv
            tableDataLoading
            ?dataNotFoundComponent
            ?bottomActions
            ?defaultSort
            tableLocalFilter
            collapseTableRow
            getRowDetails
            ?onMouseEnter
            ?onMouseLeave
          />
        } else {
          <LoadedTable
            visibleColumns
            entity
            actualData=localFilteredData
            title
            titleSize
            hideTitle
            ?description
            rightTitleElement={customizeColumn}
            ?tableActions
            isTableActionBesideFilters
            hideFilterTopPortals
            showSerialNumber
            totalResults
            currrentFetchCount
            offset
            resultsPerPage
            setOffset
            ignoreHeaderBg
            handleRefetch
            ?onEntityClick
            ?downloadCsv
            filters=filt
            showFilterBorder
            headBottomMargin
            tableDataLoading
            dataLoading
            ignoreUrlUpdate
            ?advancedSearchComponent
            setData
            setSummary
            ?dataNotFoundComponent
            ?bottomActions
            ?renderCard
            ?defaultSort
            tableLocalFilter
            collapseTableRow
            ?frozenUpto
            ?heightHeadingClass
            getRowDetails
            ?onMouseEnter
            ?onMouseLeave
            rowHeightClass
            titleTooltip
            rowCustomClass
            ?filterObj
            ?setFilterObj
            ?filterIcon
            maxTableHeight
            tableheadingClass
            noDataMsg
            ?checkBoxProps
            ?tableBorderClass
            ?paginationClass
            ?tableDataBorderClass
            ?tableActionBorder
          />
        }}
      </RefetchContextProvider>
    }

  | None =>
    <DynamicTableUtils.TableLoadingErrorIndicator
      title titleSize showFilterBorder fetchSuccess filters buttonType=errorButtonType hideTitle
    />
  }
}
