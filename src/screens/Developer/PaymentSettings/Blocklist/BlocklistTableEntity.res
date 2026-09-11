open BlocklistTypes
open BlocklistUtils
open BlocklistHelper

let defaultColumns = [
  JobId,
  JobType,
  Status,
  TotalRows,
  SucceededRows,
  FailedRows,
  CreatedAt,
  UpdatedAt,
  Actions,
]

let getHeading = colType => {
  switch colType {
  | JobId => Table.makeHeaderInfo(~key="job_id", ~title="Job ID")
  | JobType => Table.makeHeaderInfo(~key="job_type", ~title="Type")
  | Status => Table.makeHeaderInfo(~key="status", ~title="Status", ~dataType=LabelType)
  | TotalRows => Table.makeHeaderInfo(~key="total_rows", ~title="Total Rows")
  | SucceededRows => Table.makeHeaderInfo(~key="succeeded_rows", ~title="Succeeded")
  | FailedRows => Table.makeHeaderInfo(~key="failed_rows", ~title="Failed")
  | CreatedAt => Table.makeHeaderInfo(~key="created_at", ~title="Created At")
  | UpdatedAt => Table.makeHeaderInfo(~key="updated_at", ~title="Updated At")
  | Actions => Table.makeHeaderInfo(~key="", ~title="")
  }
}

let getCell = (~onRefreshJob, ~onDownloadExport, job: blocklistBatchJob, colType): Table.cell => {
  switch colType {
  | JobId => DisplayCopyCell(job.job_id)
  | JobType => Text(job.job_type->blocklistJobTypeLabel)
  | Status => Label({title: job.status->normalizeStatus, color: job.status->statusLabelColor})
  | TotalRows => Text(job.total_rows->Int.toString)
  | SucceededRows => Text(job->isExportJob ? "-" : job.succeeded_rows->Int.toString)
  | FailedRows => Text(job->isExportJob ? "-" : job.failed_rows->Int.toString)
  | CreatedAt => Date(job.created_at)
  | UpdatedAt => Date(job.updated_at)
  | Actions =>
    Table.CustomCell(
      job->isExportJob && job.status->isTerminalStatus
        ? <ActionIcon
            iconName="nd-download-bar-down"
            description="Download"
            isDisabled={!job.downloadable}
            onClick={() => onDownloadExport(job.job_id)->ignore}
          />
        : <ActionIcon
            iconName="sync"
            description="Refresh"
            isDisabled={job.status->isTerminalStatus}
            onClick={() => onRefreshJob(job.job_id)->ignore}
          />,
      "",
    )
  }
}

let blocklistEntity = (~onRefreshJob, ~onDownloadExport) => {
  EntityType.makeEntity(
    ~uri=``,
    ~getObjects=_ => [],
    ~defaultColumns,
    ~getHeading,
    ~getCell={(job, colType) => getCell(~onRefreshJob, ~onDownloadExport, job, colType)},
    ~dataKey="",
  )
}
