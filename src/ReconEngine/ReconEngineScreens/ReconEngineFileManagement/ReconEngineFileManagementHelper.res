open ReconEngineFileManagementTypes

module IngestionHistoryActionsComponent = {
  @react.component
  let make = () => {
    <div className="flex flex-row gap-4">
      <Icon name="nd-eye-on" size=16 />
      <Icon name="nd-download-down" size=16 />
      <Icon name="nd-graph-chart-gantt" size=16 />
    </div>
  }
}

module TransformationStats = {
  @react.component
  let make = (~stats: transformationData) => {
    <div className="flex flex-row items-center gap-2">
      <p className={`${Typography.body.md.semibold} text-nd_gray-600`}>
        {stats.transformed_count->Int.toString->React.string}
      </p>
      <span className="text-nd_gray-600"> {"/"->React.string} </span>
      <p className={`${Typography.body.md.semibold} text-nd_gray-600`}>
        {stats.ignored_count->Int.toString->React.string}
      </p>
      <span className="text-nd_gray-600"> {"/"->React.string} </span>
      <p className={`${Typography.body.md.semibold} text-nd_gray-600`}>
        {stats.errors->Array.length->Int.toString->React.string}
      </p>
    </div>
  }
}
