type headingSize = XSmall | Small | Medium | Large

module NewThemeHeading = {
  @react.component
  let make = (
    ~heading,
    ~description=?,
    ~headingColor="",
    ~descriptionColor="",
    ~headingSize=Large,
    ~rightActions=?,
    ~headingRightElemnt=?,
    ~alignItems="items-end",
    ~outerMargin="desktop:mb-6 mb-4",
  ) => {
    let descriptionSize = switch headingSize {
    | XSmall => "text-fs-12"
    | _ => "text-fs-14"
    }

    let headingSize = switch headingSize {
    | Large => "text-fs-24"
    | Medium => "text-fs-20"
    | Small => "text-fs-18"
    | XSmall => "text-fs-14"
    }

    let headingColor = headingColor->LogicUtils.isEmptyString ? "text-jp-gray-900" : headingColor
    let descriptionColor =
      descriptionColor->LogicUtils.isEmptyString ? "text-jp-2-light-gray-1000" : descriptionColor

    <div className={`flex flex-col ${outerMargin} w-full items-start`}>
      <div className={`flex w-full justify-between ${alignItems} gap-10`}>
        <div className="flex flex-col flex-1 gap-1">
          <AddDataAttributes attributes=[("data-header-text", heading)]>
            <div
              className={`flex items-center ${headingSize} mobile:text-fs-16 font-semibold ${headingColor} dark:text-white`}>
              {heading->React.string}
              {switch headingRightElemnt {
              | Some(ele) => ele
              | None => React.null
              }}
            </div>
          </AddDataAttributes>
          {switch description {
          | Some(desc) =>
            <AddDataAttributes attributes=[("data-description-text", desc)]>
              <div className={`${descriptionSize} font-normal ${descriptionColor}`}>
                {desc->React.string}
              </div>
            </AddDataAttributes>

          | None => React.null
          }}
        </div>
        {switch rightActions {
        | Some(actions) => actions
        | None => React.null
        }}
      </div>
    </div>
  }
}

module Badge = {
  type color = Blue | Gray
  @react.component
  let make = (~number, ~color: color=Blue) => {
    let (badgeColor, textColor) = switch color {
    | Blue => ("bg-primary", " text-white/90")
    | Gray => ("bg-jp-2-light-gray-300", "text-jp-2-light-gray-1800")
    }
    <AddDataAttributes attributes=[("data-badge-value", Int.toString(number))]>
      <div
        className={`w-4 h-4 flex justify-center items-center rounded-full ${badgeColor} ${textColor} font-medium text-xs`}>
        {React.string(Int.toString(number))}
      </div>
    </AddDataAttributes>
  }
}
