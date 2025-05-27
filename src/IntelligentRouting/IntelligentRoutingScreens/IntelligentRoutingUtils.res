open VerticalStepIndicatorTypes
open IntelligentRoutingTypes

let dataSource = [Historical, Realtime]

let fileTypes = [Sample, Upload]
let realtime = [StreamLive]

let dataTypeVariantToString = dataType =>
  switch dataType {
  | Historical => "Historical Data"
  | Realtime => "Realtime Data"
  }

let sections = [
  {
    id: "analyze",
    name: "Choose Your Data Source",
    icon: "nd-shield",
    subSections: None,
  },
  {
    id: "review",
    name: "Review Data Summary",
    icon: "nd-flag",
    subSections: None,
  },
]

let stringToSectionVariantMapper = string => {
  switch string {
  | "analyze" => #analyze
  | "review" => #review
  | _ => #analyze
  }
}

let getFileTypeHeading = fileType => {
  switch fileType {
  | Sample => "Try with Our Sample Data"
  | Upload => "Upload Your Transaction Data"
  }
}

let getFileTypeDescription = fileType => {
  switch fileType {
  | Sample => "Explore how it works using our pre-loaded transaction data (anonymized) to see potential auth uplift"
  | Upload => "Upload a day's transaction data to identify uplift opportunities by simulating payments via our router"
  }
}

let getFileTypeIconName = fileType => {
  switch fileType {
  | Sample => "SAMPLEFILE"
  | Upload => "UPLOADFILE"
  }
}

let getRealtimeHeading = realtime => {
  switch realtime {
  | StreamLive => "Stream Live Data via SDK"
  }
}

let getRealtimeDescription = realtime => {
  switch realtime {
  | StreamLive => "Integrate our SDK to passively observe insights on auth uplift using our simulator"
  }
}

let getRealtimeIconName = realtime => {
  switch realtime {
  | StreamLive => "STREAMLIVEDATA"
  }
}

module StepCard = {
  @react.component
  let make = (
    ~stepName,
    ~description,
    ~isSelected,
    ~onClick,
    ~iconName,
    ~isDisabled=false,
    ~showDemoLabel=false,
  ) => {
    let ringClass = switch isSelected {
    | true => "border-blue-811 ring-blue-811/20 ring-offset-0 ring-2"
    | false => "ring-grey-outline"
    }

    let tooltipText = isDisabled ? "Feature available only in production" : ""

    let icon = isSelected ? "blue-circle" : "hollow-circle"

    let stepComponent =
      <div
        key={stepName}
        className={`flex items-center gap-x-2.5 border ${ringClass} rounded-lg p-4 transition-shadow  ${isDisabled
            ? " opacity-50"
            : "cursor-pointer"} justify-between`}
        onClick={!isDisabled ? onClick : _ => ()}>
        <div className="flex items-center gap-x-2.5">
          <img alt={iconName} src={`/IntelligentRouting/${iconName}.svg`} className="w-8 h-8" />
          <div className="flex flex-col gap-1">
            <div className="flex items-center gap-2">
              <h3 className="font-medium text-grey-900"> {stepName->React.string} </h3>
              <RenderIf condition={showDemoLabel}>
                <span className="bg-nd_green-100 rounded-md">
                  <p className="text-nd_green-500 text-sm font-semibold px-2 py-0.5">
                    {"Demo"->React.string}
                  </p>
                </span>
              </RenderIf>
            </div>
            <p className="text-sm text-gray-500"> {description->React.string} </p>
          </div>
        </div>
        <Icon name=icon customHeight="20" />
      </div>

    <>
      <RenderIf condition={isDisabled}>
        <ToolTip
          description=tooltipText
          toolTipFor={stepComponent}
          justifyClass="justify-end"
          toolTipPosition=Right
        />
      </RenderIf>
      <RenderIf condition={!isDisabled}> {stepComponent} </RenderIf>
    </>
  }
}

open LogicUtils
let getStats = json => {
  let dict = json->getDictFromJsonObject
  {
    baseline: dict->getFloat("baseline", 0.0),
    model: dict->getFloat("model", 0.0),
  }
}

let mapTimeSeriesData = (arr: array<JSON.t>) => {
  arr->Array.map(item => {
    let dict = item->getDictFromJsonObject
    {
      time_stamp: dict->getString("time_stamp", ""),
      success_rate: dict->getJsonObjectFromDict("success_rate")->getStats,
      revenue: dict->getJsonObjectFromDict("revenue")->getStats,
      volume_distribution_as_per_sr: dict->getJsonObjectFromDict("volume_distribution_as_per_sr"),
    }
  })
}

let responseMapper = (response: JSON.t) => {
  let dict = response->getDictFromJsonObject

  {
    file_name: dict->getString("file_name", ""),
    overall_success_rate: dict->getJsonObjectFromDict("overall_success_rate")->getStats,
    total_failed_payments: dict->getJsonObjectFromDict("total_failed_payments")->getStats,
    total_revenue: dict->getJsonObjectFromDict("total_revenue")->getStats,
    faar: dict->getJsonObjectFromDict("faar")->getStats,
    time_series_data: dict->getArrayFromDict("time_series_data", [])->mapTimeSeriesData,
    overall_success_rate_improvement: dict->getFloat("overall_success_rate_improvement", 0.0),
  }
}

let getFileData = json => {
  let dict = json->getDictFromJsonObject
  let data = dict->getJsonObjectFromDict("data")
  let stats = dict->getDictfromDict("stats")

  {
    data: data->getUInt8ArrayFromJson(Js.TypedArray2.Uint8Array.make([])),
    stats: IntelligentRoutingReviewFieldsEntity.itemToObjMapper(stats),
  }
}

let getDisplayFileSize = fileSize =>
  if fileSize / 1024 / 1024 > 1 {
    `${(fileSize / 1024 / 1024)->Int.toString} MB`
  } else if fileSize / 1024 > 1 {
    ` ${(fileSize / 1024)->Int.toString}KB`
  } else {
    `${fileSize->Int.toString} B`
  }
