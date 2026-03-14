module Tabs = {
  open NewAnalyticsTypes
  @react.component
  let make = (
    ~option: optionType,
    ~setOption: optionType => unit,
    ~options: array<optionType>,
    ~showSingleTab=true,
  ) => {
    let getStyle = (value: string, index) => {
      let textStyle =
        value === option.value
          ? "bg-white text-grey-dark font-medium"
          : "bg-grey-light text-grey-medium"

      let borderStyle = index === 0 ? "" : "border-l"

      let borderRadius = if options->Array.length == 1 {
        "rounded-lg"
      } else if index === 0 {
        "rounded-l-lg"
      } else if index === options->Array.length - 1 {
        "rounded-r-lg"
      } else {
        ""
      }

      `${textStyle} ${borderStyle} ${borderRadius}`
    }

    <RenderIf condition={showSingleTab || options->Array.length > 1}>
      <div
        className="border border-gray-outline flex w-fit rounded-lg cursor-pointer text-sm h-fit">
        {options
        ->Array.mapWithIndex((tabValue, index) =>
          <div
            key={index->Int.toString}
            className={`px-3 py-2 ${tabValue.value->getStyle(index)} selection:bg-white`}
            onClick={_ => setOption(tabValue)}>
            {tabValue.label->React.string}
          </div>
        )
        ->React.array}
      </div>
    </RenderIf>
  }
}

module NoData = {
  @react.component
  let make = (~height="h-96", ~message="No entries in the selected time period.") => {
    <div
      className={`${height} border-2 flex justify-center items-center border-dashed opacity-70 rounded-lg p-5 m-7`}>
      {message->React.string}
    </div>
  }
}
