open Typography
open ReconEngineDataSourcesTypes
open ReconEngineDataSourcesUtils
open ReconEngineDataTypes
open ReconEngineDataUtils
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
        if data.value->LogicUtils.isNonEmptyString {
          <span className={`${body.md.medium} text-nd_gray-600`}>
            <TableUtils.DateCell timestamp={data.value} textAlign={Left} />
          </span>
        } else {
          <span className={`${body.md.medium} text-nd_gray-600`}> {"-"->React.string} </span>
        }
      | #status =>
        <StatusIndicator status={data.value->getStatusVariantFromString} value={data.value} />
      }}
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
    let statValues = [stats.transformed_count, stats.ignored_count, stats.failed_count]

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

module IngestionHistoryActionsComponent = {
  @react.component
  let make = (~ingestionHistory: ingestionHistoryType) => {
    open APIUtils

    let (showModal, setShowModal) = React.useState(_ => false)
    let getURL = useGetURL()
    let fetchApi = AuthHooks.useApiFetcher()
    let showToast = ToastAdapter.useShowToast()
    let {xFeatureRoute, forceCookies, sendV1DummyApiKeyHeader} =
      HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

    let onDownloadClick = async ev => {
      ev->ReactEvent.Mouse.stopPropagation
      try {
        let url = getURL(
          ~entityName=V1(HYPERSWITCH_RECON),
          ~hyperswitchReconType=#DOWNLOAD_INGESTION_HISTORY_FILE,
          ~methodType=Get,
          ~id=Some(ingestionHistory.id),
        )
        let res = await fetchApi(
          url,
          ~method_=Get,
          ~xFeatureRoute,
          ~forceCookies,
          ~sendV1DummyApiKeyHeader,
        )
        let csvContent = await res->Fetch.Response.blob
        DownloadUtils.download(
          ~fileName=ingestionHistory.file_name,
          ~content=csvContent,
          ~fileType="application/octet-stream",
        )
        showToast(~message="File downloaded successfully", ~toastType=ToastSuccess)
      } catch {
      | _ => showToast(~message="Failed to download file. Please try again.", ~toastType=ToastError)
      }
    }

    let ingestionHistoryIconActions = [
      {
        iconType: DownloadIcon,
        onClick: ev => onDownloadClick(ev)->ignore,
        disabled: false,
      },
      {
        iconType: ChartIcon,
        onClick: ev => {
          ev->ReactEvent.Mouse.stopPropagation
          setShowModal(_ => true)
        },
        disabled: false,
      },
    ]

    <div className="flex flex-row gap-4">
      <ReconEngineDataSourceFileTimeline
        showModal setShowModal ingestionHistoryId=ingestionHistory.ingestion_history_id
      />
      {ingestionHistoryIconActions
      ->Array.mapWithIndex((action, index) => {
        <Icon
          key={index->Int.toString}
          name={(action.iconType :> string)}
          size=16
          onClick={action.onClick}
          className={action.disabled ? "cursor-not-allowed" : "cursor-pointer"}
        />
      })
      ->React.array}
    </div>
  }
}
