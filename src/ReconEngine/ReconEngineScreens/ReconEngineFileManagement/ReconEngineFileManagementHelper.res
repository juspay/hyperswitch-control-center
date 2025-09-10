open ReconEngineFileManagementTypes
open Typography

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
