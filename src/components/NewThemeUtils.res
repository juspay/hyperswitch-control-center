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

    let headingColor = headingColor === "" ? "text-jp-gray-900" : headingColor
    let descriptionColor = descriptionColor === "" ? "text-jp-2-light-gray-1000" : descriptionColor

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

module Section = {
  @react.component
  let make = (
    ~heading,
    ~subheading,
    ~children,
    ~outerMargin="mt-8 mobile:mt-4",
    ~rightHeadingElement=?,
  ) => {
    let isMobileView = MatchMedia.useMobileChecker()

    let headingFontSize = isMobileView ? "text-fs-14" : "text-fs-20"
    let subHeadingFontSize = isMobileView ? "text-fs-12" : "text-fs-14"
    let outerPaddingClass = isMobileView ? "py-4" : "py-6"
    let paddingClass = isMobileView ? "px-3 pb-3" : "px-6 pb-6"
    let outerMargin = if outerMargin === "mt-8 mobile:mt-4" {
      "m-5"
    } else {
      outerMargin
    }

    <AddDataAttributes attributes=[("data-component", heading)]>
      <div
        className={`flex flex-col ${outerPaddingClass} ${outerMargin} border border-jp-gray-500 dark:border-jp-gray-960 bg-white dark:bg-jp-gray-lightgray_background rounded-md`}>
        <div
          className={`flex justify-between items-center ${paddingClass} border-b border-jp-gray-500 dark:border-jp-gray-960`}>
          <div className={`flex flex-col w-full gap-1`}>
            <div className={`font-semibold text-left ${headingFontSize}`}>
              {React.string(heading)}
            </div>
            <div
              className={`text-left ${subHeadingFontSize} text-gray-900 text-opacity-50 dark:text-jp-gray-text_darktheme dark:text-opacity-50`}>
              {React.string(subheading)}
            </div>
          </div>
          {switch rightHeadingElement {
          | Some(element) => element
          | None => React.null
          }}
        </div>
        children
      </div>
    </AddDataAttributes>
  }
}

module HeadlessSection = {
  @react.component
  let make = (~children) => {
    <div
      className="border border-jp-gray-500 dark:border-jp-gray-960 bg-white dark:bg-jp-gray-lightgray_background rounded-md m-5">
      children
    </div>
  }
}

module FloatingActions = {
  @react.component
  let make = (~children) => {
    let isMobileView = MatchMedia.useMobileChecker()
    if isMobileView {
      <FloatingElement.BottomRight> {children} </FloatingElement.BottomRight>
    } else {
      children
    }
  }
}

module Badge = {
  type color = Blue | Gray
  @react.component
  let make = (~number, ~color: color=Blue) => {
    let (badgeColor, textColor) = switch color {
    | Blue => ("bg-blue-800", " text-white")
    | Gray => ("bg-jp-2-light-gray-300", "text-jp-2-light-gray-1800")
    }
    <AddDataAttributes attributes=[("data-badge-value", string_of_int(number))]>
      <div className={`px-1.5 rounded-full ${badgeColor} ${textColor} font-semibold text-sm`}>
        {React.string(string_of_int(number))}
      </div>
    </AddDataAttributes>
  }
}
