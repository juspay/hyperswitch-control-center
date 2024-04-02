module LogDetailsSection = {
  open LogTypes
  open LogicUtils
  @react.component
  let make = (~logDetails) => {
    let isValidNonEmptyValue = value => {
      switch value->JSON.Classify.classify {
      | Bool(_) | String(_) | Number(_) | Object(_) => true
      | _ => false
      }
    }

    <div className="border-b-1 border-border-light-grey pb-3">
      {logDetails.data
      ->Dict.toArray
      ->Array.filter(item => {
        let (key, value) = item
        !(LogUtils.detailsSectionFilterKeys->Array.includes(key)) && value->isValidNonEmptyValue
      })
      ->Array.map(item => {
        let (key, value) = item
        <div className="text-sm font-medium text-gray-700 flex">
          <span className="w-2/5"> {key->snakeToTitle->React.string} </span>
          <span
            className="w-3/5 overflow-scroll cursor-pointer relative hover:bg-gray-50 p-1 rounded">
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
                padding: "0px",
              }}>
              {value->JSON.stringify}
            </ReactSyntaxHighlighter.SyntaxHighlighter>
          </span>
        </div>
      })
      ->React.array}
    </div>
  }
}

@react.component
let make = (~id, ~urls, ~logType: LogTypes.pageType) => {
  open LogicUtils
  open LogUtils
  open LogTypes
  open APIUtils
  let fetchDetails = useGetMethod(~showErrorToast=false, ())
  let fetchPostDetils = useUpdateMethod()
  let (data, setData) = React.useState(_ => [])
  let isError = React.useMemo0(() => {ref(false)})
  let (logDetails, setLogDetails) = React.useState(_ => {
    response: "",
    request: "",
    data: Dict.make(),
  })
  let (selectedOption, setSelectedOption) = React.useState(_ => {
    value: 0,
    optionType: API_EVENTS,
  })
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

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
            fetchPostDetils(url.url, body, Post, ())
          }
        | _ => fetchDetails(url.url)
        }
      })
      let resArr = await PromiseUtils.allSettledPolyfill(promiseArr)

      resArr->Array.forEach(json => {
        // clasify btw json value and error response
        switch JSON.Classify.classify(json) {
        | Array(arr) =>
          // add to the logs only if array is non empty
          switch arr->Array.get(0) {
          | Some(dict) =>
            switch dict->getDictFromJsonObject->getLogType {
            | SDK => logs->Array.pushMany(arr->parseSdkResponse)->ignore
            | CONNECTOR | API_EVENTS => logs->Array.pushMany(arr)->ignore
            | WEBHOOKS => logs->Array.pushMany([dict])->ignore
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
        logs->Array.sort(sortByCreatedAt)
        setData(_ => logs)
        switch logs->Array.get(0) {
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

  React.useEffect0(() => {
    getDetails()->ignore
    None
  })

  let headerText = switch selectedOption.optionType {
  | API_EVENTS | CONNECTOR => "Response body"
  | WEBHOOKS => "Request body"
  | SDK => "Metadata"
  }->Some

  let timeLine =
    <div className="flex flex-col w-2/5 overflow-y-scroll pt-7 pl-5">
      <div className="flex flex-col">
        {data
        ->Array.mapWithIndex((detailsValue, index) => {
          <ApiDetailsComponent
            key={index->Int.toString}
            dataDict={detailsValue->getDictFromJsonObject}
            setLogDetails
            setSelectedOption
            currentSelected=selectedOption.value
            index
            logsDataLength={data->Array.length - 1}
            getLogType
            nameToURLMapper={nameToURLMapper(~id={id})}
            filteredKeys
          />
        })
        ->React.array}
      </div>
    </div>

  let requestHeader = switch selectedOption.optionType {
  | API_EVENTS | CONNECTOR => "Request body"
  | SDK => "Event"
  | WEBHOOKS => ""
  }

  let codeBlock =
    <UIUtils.RenderIf
      condition={logDetails.response->isNonEmptyString || logDetails.request->isNonEmptyString}>
      <div
        className="flex flex-col gap-4 border-l-1 border-border-light-grey show-scrollbar scroll-smooth overflow-scroll px-5 py-3 w-3/5">
        <LogDetailsSection logDetails />
        <UIUtils.RenderIf
          condition={logDetails.request->isNonEmptyString &&
            selectedOption.optionType !== WEBHOOKS}>
          <PrettyPrintJson
            jsonToDisplay=logDetails.request
            headerText={requestHeader->Some}
            maxHeightClass={logDetails.response->String.length > 0 ? "max-h-25-rem" : ""}
          />
        </UIUtils.RenderIf>
        <UIUtils.RenderIf condition={logDetails.response->isNonEmptyString}>
          <PrettyPrintJson jsonToDisplay={logDetails.response} headerText />
        </UIUtils.RenderIf>
      </div>
    </UIUtils.RenderIf>

  open OrderUtils
  <PageLoaderWrapper
    screenState
    customUI={<NoDataFound
      message={`No logs available for this ${(logType :> string)->String.toLowerCase}`}
    />}>
    <UIUtils.RenderIf condition={id->HSwitchOrderUtils.isTestData || data->Array.length === 0}>
      <div
        className="flex items-center gap-2 bg-white w-full border-2 p-3 !opacity-100 rounded-lg text-md font-medium">
        <Icon name="info-circle-unfilled" size=16 />
        <div className={`text-lg font-medium opacity-50`}>
          {`No logs available for this ${(logType :> string)->String.toLowerCase}`->React.string}
        </div>
      </div>
    </UIUtils.RenderIf>
    <UIUtils.RenderIf condition={!(id->HSwitchOrderUtils.isTestData || data->Array.length === 0)}>
      <Section
        customCssClass={`bg-white dark:bg-jp-gray-lightgray_background rounded-md pt-2 pb-4 flex gap-7 justify-between h-48-rem !max-h-50-rem !min-w-[55rem] max-w-[72rem] overflow-scroll`}>
        {timeLine}
        {codeBlock}
      </Section>
    </UIUtils.RenderIf>
  </PageLoaderWrapper>
}
