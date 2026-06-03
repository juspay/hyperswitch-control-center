module LogDetailsSection = {
  open LogTypes
  open LogicUtils
  open LogUtils
  open Typography
  @react.component
  let make = (~logDetails, ~nameToURLMapper, ~pageType: LogTypes.pageType) => {
    let data = logDetails.data
    let logType = data->getLogType
    let statusCode = data->getStatusCodeString
    let title = data->getRowTitle(~nameToURLMapper)
    let method = data->getMethod
    let mappedName = data->getApiName(~nameToURLMapper)
    let urlPath = data->getUrlPath
    let path = urlPath->isNonEmptyString ? urlPath : mappedName

    let statusColor: TagBinding.tagColor = switch logType {
    | SDK =>
      switch statusCode {
      | "ERROR" => Error
      | "WARNING" => Warning
      | "INFO" => Primary
      | _ => Neutral
      }
    | API_EVENTS | CONNECTOR | ROUTING | WEBHOOKS =>
      switch statusCode {
      | "200" => Success
      | "500" => Error
      | "400" | "422" => Warning
      | _ => Neutral
      }
    }

    let isFailed = switch logType {
    | API_EVENTS | CONNECTOR | ROUTING => data->getInt("status_code", 200) >= 400
    | WEBHOOKS => data->getBool("is_error", false)
    | SDK => data->getString("log_type", "") === "ERROR"
    }

    let errorStr = data->getString("error", "")
    let errorDict =
      errorStr->isNonEmptyString ? errorStr->safeParse->getDictFromJsonObject : Dict.make()
    let nestedErrorDict = errorDict->getObj("error", errorDict)
    let pickString = (dict, keys) =>
      keys->Array.map(key => dict->getString(key, ""))->Array.find(isNonEmptyString)
    let errorMessage =
      nestedErrorDict
      ->pickString(["error_description", "message", "reason", "error_message", "description"])
      ->Option.getOr(errorStr)
    let errorCode =
      [
        nestedErrorDict->getString("code", ""),
        nestedErrorDict->getString("error_code", ""),
        nestedErrorDict->getString("type", ""),
        errorDict->getString("error", ""),
      ]->Array.find(isNonEmptyString)

    let isValidNonEmptyValue = value => {
      switch value->JSON.Classify.classify {
      | Bool(_) | String(_) | Number(_) | Object(_) => true
      | _ => false
      }
    }

    let auditLogScrollbar = `
  @supports (-webkit-appearance: none){
    pre {
        scrollbar-width: auto;
        scrollbar-color: #CACFD8;
      }
      
      pre::-webkit-scrollbar {
        display: block;
        overflow: scroll;
        height: 4px;
        width: 5px;
      }
      
      pre::-webkit-scrollbar-thumb {
        background-color: #CACFD8;
        border-radius: 3px;
      }
      
      pre::-webkit-scrollbar-track {
        display: none;
      }
}
  `

    <div className="flex flex-col gap-5 px-5 py-4">
      <div className="flex flex-col gap-2">
        <div className="flex items-center gap-2 flex-wrap">
          <TagBinding text=statusCode color=statusColor variant=Subtle shape=Squarical size=Sm />
          <p className={`${heading.sm.semibold} text-nd_gray-800 break-all`}>
            {title->React.string}
          </p>
        </div>
        <RenderIf condition={method->isNonEmptyString || path->isNonEmptyString}>
          <div className="flex items-center gap-2 min-w-0">
            <RenderIf condition={method->isNonEmptyString}>
              <span
                className={`flex-none border border-nd_gray-300 text-nd_gray-500 px-1.5 py-0.5 rounded ${code.sm.medium}`}>
                {method->String.toUpperCase->React.string}
              </span>
            </RenderIf>
            <RenderIf condition={path->isNonEmptyString}>
              <span className={`${code.md.medium} text-nd_gray-500 break-all`}>
                {path->React.string}
              </span>
            </RenderIf>
          </div>
        </RenderIf>
      </div>
      <RenderIf condition={isFailed && errorMessage->isNonEmptyString}>
        <AlertV2Binding
          alertType=Error
          heading={errorCode->mapOptionOrDefault("Request failed", code =>
            `Request failed · ${code}`
          )}
          description=errorMessage
        />
      </RenderIf>
      <div className="flex flex-col gap-3">
        <p className={`${body.xs.semibold} text-nd_gray-400 uppercase tracking-wide`}>
          {(pageType :> string)->React.string}
        </p>
        {data
        ->Dict.toArray
        ->Array.filter(((key, value)) =>
          !(LogUtils.detailsSectionFilterKeys->Array.includes(key)) && value->isValidNonEmptyValue
        )
        ->Array.map(((key, value)) =>
          <div key className="flex items-start gap-4">
            <span className={`${body.sm.medium} text-nd_gray-500 w-2/5 flex-none`}>
              {key->snakeToTitle->React.string}
            </span>
            <span className="w-3/5 min-w-0">
              {switch value->JSON.Classify.classify {
              | String(str) =>
                <p className={`${code.md.medium} text-nd_gray-800 break-all`}>
                  {str->React.string}
                </p>
              | Bool(_) | Number(_) =>
                <p className={`${code.md.medium} text-nd_gray-800 break-all`}>
                  {value->JSON.stringify->React.string}
                </p>
              | _ =>
                <span className="block overflow-scroll relative">
                  <style> {React.string(auditLogScrollbar)} </style>
                  <ReactSyntaxHighlighter.SyntaxHighlighter
                    wrapLines={true}
                    wrapLongLines=true
                    style={ReactSyntaxHighlighter.lightfair}
                    language="json"
                    showLineNumbers={false}
                    lineNumberContainerStyle={{
                      paddingLeft: "0px",
                      backgroundColor: "red",
                      padding: "0px",
                    }}
                    customStyle={{
                      backgroundColor: "transparent",
                      fontSize: "0.875rem",
                      padding: "0px 0px 6px 0px",
                    }}>
                    {value->JSON.stringify}
                  </ReactSyntaxHighlighter.SyntaxHighlighter>
                </span>
              }}
            </span>
          </div>
        )
        ->React.array}
      </div>
    </div>
  }
}

module TabDetails = {
  open LogTypes
  open LogUtils
  @react.component
  let make = (
    ~activeTab,
    ~moduleName="",
    ~logDetails,
    ~selectedOption,
    ~nameToURLMapper,
    ~pageType,
  ) => {
    open LogicUtils
    let id =
      activeTab
      ->Option.getOr(["tab"])
      ->Array.reduce("", (acc, tabName) => {acc->String.concat(tabName)})

    let currTab = activeTab->Option.getOr([])->Array.get(0)->Option.getOr("")

    let tab =
      <div>
        {switch currTab->getLogTypefromString {
        | Logdetails => <LogDetailsSection logDetails nameToURLMapper pageType />
        | Event
        | Request =>
          <div className="px-5 py-3">
            <RenderIf condition={logDetails.request->isNonEmptyString}>
              <div className="flex justify-end">
                <HelperComponents.CopyTextCustomComp
                  displayValue=Some("")
                  copyValue={Some(logDetails.request)}
                  customTextCss="text-nowrap"
                />
              </div>
              <PrettyPrintJson jsonToDisplay=logDetails.request />
            </RenderIf>
            <RenderIf condition={logDetails.request->isEmptyString}>
              <NoDataFound
                customCssClass={"my-6"} message="No Data Available" renderType=Painting
              />
            </RenderIf>
          </div>
        | Metadata
        | Response =>
          <div className="px-5 py-3">
            <RenderIf
              condition={logDetails.response->isNonEmptyString &&
                selectedOption.optionType !== WEBHOOKS}>
              <div className="flex justify-end">
                <HelperComponents.CopyTextCustomComp
                  displayValue=Some("")
                  copyValue={Some(logDetails.response)}
                  customTextCss="text-nowrap"
                />
              </div>
              <PrettyPrintJson jsonToDisplay={logDetails.response} />
            </RenderIf>
            <RenderIf
              condition={logDetails.response->isEmptyString ||
                selectedOption.optionType === WEBHOOKS}>
              <NoDataFound
                customCssClass={"my-6"} message="No Data Available" renderType=Painting
              />
            </RenderIf>
          </div>
        | _ => React.null
        }}
      </div>

    <FramerMotion.TransitionComponent id={id}> {tab} </FramerMotion.TransitionComponent>
  }
}

@react.component
let make = (~id, ~urls, ~logType: LogTypes.pageType) => {
  open LogicUtils
  open LogUtils
  open LogTypes
  open APIUtils
  open Typography
  let {merchantId} =
    CommonAuthHooks.useCommonAuthInfo()->Option.getOr(CommonAuthHooks.defaultAuthInfo)
  let urlMapper = nameToURLMapper(~id, ~merchantId)
  let fetchDetails = useGetMethod(~showErrorToast=false)
  let fetchPostDetails = useUpdateMethod()
  let (data, setData) = React.useState(_ => [])
  let isError = React.useMemo(() => {ref(false)}, [])
  let (logDetails, setLogDetails) = React.useState(_ => {
    response: "",
    request: "",
    data: Dict.make(),
  })
  let (selectedOption, setSelectedOption) = React.useState(_ => {
    value: 0,
    optionType: API_EVENTS,
  })
  let (selectedOrigin, setSelectedOrigin) = React.useState(_ => AllOrigins)
  let (selectedSdkFilter, setSelectedSdkFilter) = React.useState(_ => AllSdk)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

  let (activeTab, setActiveTab) = React.useState(_ => ["Log Details"])

  let tabKeys = tabkeys->Array.map(item => {
    item->getTabKeyName(selectedOption.optionType)
  })

  React.useEffect(_ => {
    setActiveTab(_ => ["Log Details"])
    None
  }, [logDetails])

  let activeTab = React.useMemo(() => {
    Some(activeTab)
  }, [activeTab])

  let setActiveTab = React.useMemo(() => {
    (str: string) => {
      setActiveTab(_ => str->String.split(","))
    }
  }, [setActiveTab])

  let getDetails = async () => {
    let logs = []

    if !(id->HSwitchOrderUtils.isTestData) {
      let promiseArr = urls->Array.map(url => {
        switch url.apiMethod {
        | Post => {
            let body = switch url.body {
            | Some(val) => val
            | _ => Dict.make()->JSON.Encode.object
            }
            fetchPostDetails(url.url, body, Post)
          }
        | _ => fetchDetails(url.url)
        }
      })
      let resArr = await PromiseUtils.allSettledPolyfill(promiseArr)

      resArr->Array.forEach(json => {
        // classify btw json value and error response
        switch JSON.Classify.classify(json) {
        | Array(arr) =>
          // add to the logs only if array is non empty
          switch arr->Array.get(0) {
          | Some(dict) =>
            switch dict->getDictFromJsonObject->getLogType {
            | SDK => logs->Array.pushMany(arr->parseSdkResponse)->ignore
            | CONNECTOR | API_EVENTS | WEBHOOKS | ROUTING => logs->Array.pushMany(arr)->ignore
            }
          | _ => ()
          }
        | String(_) => isError.contents = true
        | _ => ()
        }
      })

      if logs->Array.length === 0 && isError.contents {
        setScreenState(_ => PageLoaderWrapper.Error("Failed to Fetch!"))
      } else {
        setScreenState(_ => PageLoaderWrapper.Success)
        logs->Array.sort(sortByStartTime)
        let reorderedLogs = logs->reorderLogs
        setData(_ => reorderedLogs)
        switch reorderedLogs->Array.get(0) {
        | Some(value) => {
            let initialData = value->getDictFromJsonObject
            initialData->setDefaultValue(setLogDetails, setSelectedOption)
          }
        | _ => ()
        }
      }
    } else {
      setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  React.useEffect(() => {
    getDetails()->ignore
    None
  }, [])
  let prevLogType = ref("")

  let isSdkSelected = switch selectedOrigin {
  | SdkOrigin => true
  | _ => false
  }

  let visibleData = data->Array.filter(row => {
    let dict = row->getDictFromJsonObject
    selectedOrigin->rowMatchesOrigin(dict) && (
        isSdkSelected ? selectedSdkFilter->rowMatchesSdkFilter(dict) : true
      )
  })

  let presentOrigins =
    selectableOrigins->Array.filter(origin =>
      data->Array.some(row => origin->rowMatchesOrigin(row->getDictFromJsonObject))
    )

  let presentSdkFilters = selectableSdkFilters->Array.filter(filter =>
    data->Array.some(row => {
      let dict = row->getDictFromJsonObject
      SdkOrigin->rowMatchesOrigin(dict) && filter->rowMatchesSdkFilter(dict)
    })
  )

  let focusFirstRow = rows =>
    rows
    ->Array.get(0)
    ->Option.mapOr((), firstRow =>
      firstRow->getDictFromJsonObject->setDefaultValue(setLogDetails, setSelectedOption)
    )

  let originTabs =
    <TabsBinding
      value={selectedOrigin->originFilterLabel}
      onValueChange={label => {
        let origin = label->originFromLabel
        setSelectedOrigin(_ => origin)
        setSelectedSdkFilter(_ => AllSdk)
        data
        ->Array.filter(row => origin->rowMatchesOrigin(row->getDictFromJsonObject))
        ->focusFirstRow
      }}
      variant=Underline
      size=Md>
      <TabsBinding.List variant=Underline size=Md>
        {[AllOrigins]
        ->Array.concat(presentOrigins)
        ->Array.map(origin => {
          let label = origin->originFilterLabel
          <TabsBinding.Trigger
            key=label value=label variant=TabsBinding.Underline size=TabsBinding.Md>
            {label->React.string}
          </TabsBinding.Trigger>
        })
        ->React.array}
      </TabsBinding.List>
    </TabsBinding>

  let sdkSubTabs =
    <TabsBinding
      value={selectedSdkFilter->sdkFilterLabel}
      onValueChange={label => {
        let filter = label->sdkFilterFromLabel
        setSelectedSdkFilter(_ => filter)
        data
        ->Array.filter(row => {
          let dict = row->getDictFromJsonObject
          SdkOrigin->rowMatchesOrigin(dict) && filter->rowMatchesSdkFilter(dict)
        })
        ->focusFirstRow
      }}
      variant=Boxed
      size=Md>
      <TabsBinding.List variant=Boxed size=Md fitContent=true>
        {[AllSdk]
        ->Array.concat(presentSdkFilters)
        ->Array.map(filter => {
          let label = filter->sdkFilterLabel
          <TabsBinding.Trigger key=label value=label variant=Boxed size=Md>
            {label->React.string}
          </TabsBinding.Trigger>
        })
        ->React.array}
      </TabsBinding.List>
    </TabsBinding>

  let timeLine =
    <div className="flex flex-col w-3/5 overflow-y-scroll overflow-x-hidden no-scrollbar pl-5">
      <RenderIf condition={presentOrigins->Array.length > 1}>
        <div className="pb-3"> {originTabs} </div>
      </RenderIf>
      <RenderIf condition={isSdkSelected}>
        <div className="pb-4"> {sdkSubTabs} </div>
      </RenderIf>
      <div className="flex flex-col">
        {visibleData
        ->Array.mapWithIndex((detailsValue, index) => {
          let rowHeading = detailsValue->getDictFromJsonObject->getHeadingLabel
          let showLogType = prevLogType.contents !== rowHeading
          prevLogType := rowHeading

          <ApiDetailsComponent
            key={index->Int.toString}
            dataDict={detailsValue->getDictFromJsonObject}
            setLogDetails
            setSelectedOption
            selectedOption
            index
            logsDataLength={visibleData->Array.length - 1}
            getLogType
            nameToURLMapper={urlMapper}
            filteredKeys
            showLogType
          />
        })
        ->React.array}
      </div>
    </div>

  let codeBlock =
    <RenderIf
      condition={logDetails.response->isNonEmptyString || logDetails.request->isNonEmptyString}>
      <div
        className="flex flex-col gap-4 border-l-2 border-nd_gray-200 show-scrollbar scroll-smooth overflow-scroll w-3/5">
        <div className="sticky top-0 bg-white z-10 px-2">
          <TabsBinding
            value={activeTab
            ->Option.flatMap(arr => arr->Array.get(0))
            ->Option.getOr(tabKeys->getValueFromArray(0, ""))}
            onValueChange=setActiveTab
            variant=Underline
            size=Md>
            <TabsBinding.List variant=Underline size=Md>
              {tabKeys
              ->Array.map(tabKey =>
                <TabsBinding.Trigger key=tabKey value=tabKey variant=Underline size=Md>
                  {tabKey->React.string}
                </TabsBinding.Trigger>
              )
              ->React.array}
            </TabsBinding.List>
          </TabsBinding>
        </div>
        <TabDetails
          activeTab logDetails selectedOption nameToURLMapper=urlMapper pageType=logType
        />
      </div>
    </RenderIf>

  open OrderUtils
  <PageLoaderWrapper
    screenState
    customLoader={<p className={`text-center ${body.sm.regular} text-nd_gray-800 p-4`}>
      {"Crunching the latest data…"->React.string}
    </p>}
    customUI={<NoDataFound
      message={`No logs available for this ${(logType :> string)->String.toLowerCase}`}
    />}>
    {<>
      <RenderIf condition={id->HSwitchOrderUtils.isTestData || data->Array.length === 0}>
        <div
          className="flex items-center gap-2 bg-white w-full border-2 p-3 !opacity-100 rounded-lg">
          <Icon name="info-circle-unfilled" size=16 />
          <div className={`${heading.sm.medium} opacity-50`}>
            {`No logs available for this ${(logType :> string)->String.toLowerCase}`->React.string}
          </div>
        </div>
      </RenderIf>
      <RenderIf condition={!(id->HSwitchOrderUtils.isTestData || data->Array.length === 0)}>
        <Section
          customCssClass={`bg-white dark:bg-jp-gray-lightgray_background rounded-md pt-2 pb-4 flex gap-7 justify-between h-48-rem !max-h-50-rem !min-w-[55rem] max-w-[72rem] overflow-scroll`}>
          {timeLine}
          {codeBlock}
        </Section>
      </RenderIf>
    </>}
  </PageLoaderWrapper>
}
