open Typography
open ReconEngineAccountsSourcesTypes
open ReconEngineAccountsSourcesUtils
open ReconEngineAccountsTypes
open ReconEngineAccountsUtils
open ReconEngineTypes

module StatusIndicator = {
  @react.component
  let make = (~status: status, ~value: string) => {
    let (bgColor, textColor) = switch status {
    | Active => ("bg-nd_green-300", "text-nd_gray-600")
    | Inactive => ("bg-nd_red-400", "text-nd_gray-600")
    | UnknownStatus => ("bg-nd_gray-400", "text-nd_gray-600")
    }

    <div className="flex items-center space-x-2">
      <span className="relative flex h-2 w-2">
        <span className={`absolute inline-flex h-full w-full rounded-full ${bgColor} opacity-75`} />
        <span className={`relative inline-flex rounded-full h-2 w-2 ${bgColor}`} />
      </span>
      <span className={`${body.md.medium} ${textColor} ml-2`}> {value->React.string} </span>
    </div>
  }
}

module SourceConfigItem = {
  @react.component
  let make = (~data: sourceConfigDataType) => {
    <div className="flex flex-col space-y-1">
      <span className={`${body.md.medium} text-nd_gray-500`}>
        {data.label->sourceConfigLabelToString->React.string}
      </span>
      {switch data.valueType {
      | #text =>
        <span className={`${body.md.medium} text-nd_gray-600`}> {data.value->React.string} </span>
      | #date =>
        <span className={`${body.md.medium} text-nd_gray-600`}>
          <TableUtils.DateCell timestamp={data.value} textAlign={Left} />
        </span>
      | #status =>
        <StatusIndicator status={data.value->getStatusVariantFromString} value={data.value} />
      }}
    </div>
  }
}

module IngestionHistoryActionsComponent = {
  @react.component
  let make = () => {
    let ingestionHistoryIconActions = [
      {
        iconType: ViewIcon,
        onClick: _ => (),
      },
      {
        iconType: DownloadIcon,
        onClick: _ => (),
      },
      {
        iconType: ChartIcon,
        onClick: _ => (),
      },
    ]

    <div className="flex flex-row gap-4">
      {ingestionHistoryIconActions
      ->Array.mapWithIndex((action, index) =>
        <Icon
          key={index->Int.toString}
          name={(action.iconType :> string)}
          size=16
          onClick={action.onClick}
        />
      )
      ->React.array}
    </div>
  }
}

module DisplayKeyValueParams = {
  @react.component
  let make = (
    ~showTitle: bool=true,
    ~heading: Table.header,
    ~value: Table.cell,
    ~wordBreak=true,
  ) => {
    let description = heading.description->Option.getOr("")

    {
      <AddDataAttributes attributes=[("data-label", heading.title)]>
        <div className="flex flex-col gap-2 py-4">
          <div
            className="flex flex-row text-fs-11 text-nd_gray-500 text-opacity-50 dark:text-nd_gray-500 dark:text-opacity-50">
            <div className={`text-nd_gray-500 ${body.md.medium}`}>
              {React.string(showTitle ? heading.title : " x")}
            </div>
            <RenderIf condition={description->LogicUtils.isNonEmptyString}>
              <div className="text-sm text-gray-500 mx-2 -mt-1">
                <ToolTip description={description} toolTipPosition={ToolTip.Top} />
              </div>
            </RenderIf>
          </div>
          <div className={`text-left text-nd_gray-600 ${body.md.semibold}`}>
            <Table.TableCell
              cell=value
              textAlign=Table.Left
              fontBold=true
              customMoneyStyle="!font-normal !text-sm"
              labelMargin="!py-0"
            />
          </div>
        </div>
      </AddDataAttributes>
    }
  }
}

module TransformationStats = {
  @react.component
  let make = (~stats: transformationData) => {
    let statValues = [stats.transformed_count, stats.ignored_count, stats.errors->Array.length]

    <div className="flex flex-row items-center gap-2">
      {statValues
      ->Array.mapWithIndex((stat, index) => {
        let isLast = index === Array.length(statValues) - 1
        <React.Fragment key={index->Int.toString}>
          <p className={`${body.md.semibold} text-nd_gray-600`}>
            {stat->Int.toString->React.string}
          </p>
          <RenderIf condition={!isLast}>
            <span className="text-nd_gray-600"> {"/"->React.string} </span>
          </RenderIf>
        </React.Fragment>
      })
      ->React.array}
    </div>
  }
}

module TransformationHistoryActionsComponent = {
  @react.component
  let make = () => {
    <div className="flex flex-row gap-4">
      <Icon name="nd-alert-triangle-outline" size=16 onClick={_ => ()} />
    </div>
  }
}
