open LogicUtils
open LogTypes
open LogUtils
open Typography
@react.component
let make = (
  ~dataDict,
  ~setLogDetails,
  ~selectedOption,
  ~setSelectedOption,
  ~index,
  ~logsDataLength,
  ~getLogType,
  ~nameToURLMapper,
  ~filteredKeys=[],
  ~showLogType=true,
) => {
  let {globalUIConfig: {border: {borderColor}}} = React.useContext(ThemeProvider.themeContext)
  let logType = dataDict->getLogType
  let startTime = {
    let endMs = dataDict->getString("created_at", "")->Date.fromString->Date.getTime
    let latencyMs = dataDict->getFloat("latency", 0.0)
    (endMs -. latencyMs)->Date.fromTime->Date.toISOString
  }
  let requestObject = dataDict->getRequestObject(~logType, ~filteredKeys)
  let eventCode = requestObject->getEventCode(~logType)
  let responseObject = dataDict->getResponseObject(~logType)
  let statusCode = dataDict->getStatusCodeString
  let method = dataDict->getMethod
  let statusCodeTextColor = getStatusCodeTextColor(logType, statusCode)
  let statusCodeBg = getStatusCodeBg(logType, statusCode)
  let isSelected = selectedOption.value === index
  let stepperColor = isSelected ? getStepperColor(logType, statusCode) : "nd_gray-200"
  let stepperBorderColor = isSelected ? getStepperBorderColor(logType, statusCode) : "nd_gray-200"
  let statusCodeBorderColor = getStatusCodeBorderColor(
    logType,
    statusCode,
    ~primaryBorder=borderColor.primaryNormal,
  )
  let borderClass = isSelected ? `${statusCodeBorderColor} rounded-md` : "border border-transparent"
  let rowOrigin = dataDict->getRowOrigin
  let originLabel = rowOrigin->getOriginLabel
  let originIcon = rowOrigin->getOriginIcon
  let webhookDirection = dataDict->getWebhookDirection(~logType)
  let urlPath = dataDict->getUrlPath
  let sdkCategoryLabel = dataDict->getSdkCategoryLabel(~logType)
  let latencyText = dataDict->getLatencyText(~logType)
  let isFailed = dataDict->getIsFailed(~logType)
  let title = dataDict->getRowTitle(~nameToURLMapper)

  let (qualifierLabel, qualifierIcon) = switch webhookDirection {
  | Incoming => ("Incoming", "arrow-down")
  | Outgoing => ("Outgoing", "arrow-up")
  | NoDirection =>
    sdkCategoryLabel->isNonEmptyString
      ? (sdkCategoryLabel, sdkCategoryLabel === "API Call" ? "api-icon" : "user")
      : ("", "")
  }

  <div className="flex items-start gap-4">
    <div className="flex flex-col items-center h-full my-4 relative">
      <RenderIf condition={showLogType}>
        <Icon name={dataDict->getHeadingIcon} size=12 className="text-nd_gray-800" />
        <div
          className={`h-full border-${stepperBorderColor} border-dashed rounded  divide-x-2 border-2 my-1`}
        />
      </RenderIf>
      <div className={`w-fit h-fit p-1  border rounded-md bg-${stepperColor} border-nd_gray-300`} />
      <div
        className={`h-full border-${stepperBorderColor} border-dashed rounded  divide-x-2 border-2 my-1`}
      />
      <RenderIf condition={index === logsDataLength}>
        <div
          className={`w-fit h-fit p-1  border rounded-md bg-${stepperColor} border-nd_gray-300`}
        />
      </RenderIf>
    </div>
    <div className="flex flex-col gap-3 w-full min-w-0">
      <RenderIf condition={showLogType}>
        <span className={`${body.lg.bold} break-all flex gap-1 leading-none my-4 text-nd_gray-800`}>
          {dataDict->getHeadingLabel->React.string}
        </span>
      </RenderIf>
      <div
        className={`flex gap-6 items-start w-full py-3 px-3 cursor-pointer ${borderClass} mb-6
        `}
        key={selectedOption.value->Int.toString}
        onClick={_ => {
          setLogDetails(_ => {
            response: responseObject,
            request: requestObject,
            data: dataDict,
          })
          setSelectedOption(_ => {
            value: index,
            optionType: logType,
          })
        }}>
        <div className="flex flex-col gap-1.5 w-full min-w-0">
          <div className="flex items-start justify-between gap-3 w-full">
            <div className="flex items-center gap-2 flex-wrap">
              <div className={`bg-${statusCodeBg} h-fit w-fit px-2 py-0.5 rounded-md`}>
                <p className={`text-${statusCodeTextColor} ${body.md.bold}`}>
                  {statusCode->React.string}
                </p>
              </div>
              <p
                className={`${body.md.semibold} text-nd_gray-800 break-all ${isSelected
                    ? ""
                    : "opacity-90"}`}>
                {title->React.string}
              </p>
            </div>
            <RenderIf condition={latencyText->isNonEmptyString}>
              <p
                className={`${code.md.regular} whitespace-nowrap pt-1 ${isFailed
                    ? `text-${statusCodeTextColor}`
                    : "text-nd_gray-400"}`}>
                {latencyText->React.string}
              </p>
            </RenderIf>
          </div>
          <RenderIf condition={method->isNonEmptyString || urlPath->isNonEmptyString}>
            <div className="flex items-center gap-2 w-full min-w-0">
              <RenderIf condition={method->isNonEmptyString}>
                <span
                  className={`flex-none border border-nd_gray-300 text-nd_gray-500 px-1 py-0.5 rounded ${code.md.regular}`}>
                  {method->String.toUpperCase->React.string}
                </span>
              </RenderIf>
              <RenderIf condition={urlPath->isNonEmptyString}>
                <div className="min-w-0 overflow-hidden">
                  <ToolTipBinding
                    side=ToolTipBinding.Top
                    content={<span className={`${code.md.regular} break-all`}>
                      {urlPath->React.string}
                    </span>}>
                    <span
                      className={`inline-block max-w-full align-middle truncate ${code.md.regular} text-nd_gray-600 bg-nd_gray-50 border border-nd_gray-200 px-1.5 py-0.5 rounded cursor-default`}>
                      {urlPath->React.string}
                    </span>
                  </ToolTipBinding>
                </div>
              </RenderIf>
            </div>
          </RenderIf>
          <div
            className={`flex items-center flex-wrap gap-y-1 gap-x-1.5 ${body.sm.medium} text-nd_gray-500`}>
            <RenderIf condition={eventCode->isNonEmptyString}>
              <span
                className={`inline-flex items-center border border-nd_gray-300 text-nd_gray-600 px-1.5 py-0.5 rounded ${code.md.regular}`}>
                {eventCode->React.string}
              </span>
              <span className="text-nd_gray-300"> {"·"->React.string} </span>
            </RenderIf>
            <RenderIf condition={originLabel->isNonEmptyString}>
              <span className="inline-flex items-center gap-1">
                <Icon name=originIcon size=12 className="text-nd_gray-400" />
                {originLabel->React.string}
              </span>
            </RenderIf>
            <RenderIf condition={qualifierLabel->isNonEmptyString}>
              <span className="text-nd_gray-300"> {"·"->React.string} </span>
              <span className="inline-flex items-center gap-1">
                <Icon name=qualifierIcon size=12 className="text-nd_gray-400" />
                {qualifierLabel->React.string}
              </span>
            </RenderIf>
            <span className="text-nd_gray-300"> {"·"->React.string} </span>
            <TableUtils.DateCell timestamp=startTime />
          </div>
        </div>
      </div>
    </div>
  </div>
}
