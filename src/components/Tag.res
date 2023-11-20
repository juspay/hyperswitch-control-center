type iconType =
  | FontAwesome(string)
  | CustomIcon(React.element)
  | CustomRightIcon(React.element)
  | Euler(string)
  | NoIcon

type labelColor =
  | LabelGreen
  | LabelRed
  | LabelBlue
  | LabelGray
  | LabelOrange
  | LabelYellow
  | LabelMagenta
  | LabelTeal
  | LabelCyan

type labelSize =
  | Small
  | Medium
  | Large

@react.component
let make = (
  ~labelText="",
  ~iconLeft: iconType=NoIcon,
  ~iconRight: iconType=NoIcon,
  ~labelColor: labelColor,
  ~labelSize: labelSize=Small,
  ~iconType="euler",
  ~iconSize=6,
  ~isFill=false,
  ~customCss="",
) => {
  let color = switch labelColor {
  | LabelGreen => "bg-jp-2-light-green-100 text-jp-2-light-green-700"
  | LabelRed => "bg-jp-2-light-red-100 text-jp-2-light-red-700"
  | LabelBlue => "bg-jp-2-light-primary-100 text-jp-2-light-primary-700 "
  | LabelGray => "bg-jp-2-light-gray-200 text-jp-2-light-gray-1700"
  | LabelOrange => "bg-jp-2-light-orange-100 text-jp-2-light-orange-700"
  | LabelYellow => "bg-jp-2-light-yellow-100 text-jp-2-light-yellow-900"
  | LabelMagenta => "bg-jp-2-light-magenta-100 text-jp-2-light-magenta-700"
  | LabelTeal => "bg-jp-2-light-teal-100 text-jp-2-light-teal-700"
  | LabelCyan => "bg-jp-2-light-cyan-100 text-jp-2-light-cyan-700"
  }

  let iconColor = switch labelColor {
  | LabelGreen => "text-jp-2-light-green-600"
  | LabelRed => "text-jp-2-light-red-600"
  | LabelBlue => "text-jp-2-light-primary-600 "
  | LabelGray => "text-jp-2-light-gray-1200"
  | LabelOrange => "text-jp-2-light-orange-600"
  | LabelYellow => "text-jp-2-light-yellow-800"
  | LabelMagenta => "text-jp-2-light-magenta-600"
  | LabelTeal => "text-jp-2-light-teal-600"
  | LabelCyan => "text-jp-2-light-cyan-600"
  }

  let strokeColor = switch labelColor {
  | LabelGreen => "stroke-jp-2-light-green-600"
  | LabelRed => "stroke-jp-2-light-red-600"
  | LabelBlue => "stroke-jp-2-light-primary-600 "
  | LabelGray => "stroke-jp-2-light-gray-1200"
  | LabelOrange => "stroke-jp-2-light-orange-600"
  | LabelYellow => "stroke-jp-2-light-yellow-800"
  | LabelMagenta => "stroke-jp-2-light-magenta-600"
  | LabelTeal => "stroke-jp-2-light-teal-600"
  | LabelCyan => "stroke-jp-2-light-cyan-600"
  }

  let fillColor = switch labelColor {
  | LabelGreen => "fill-jp-2-light-green-600"
  | LabelRed => "fill-jp-2-light-red-600"
  | LabelBlue => "fill-blue-950"
  | LabelGray => "fill-jp-2-light-gray-1200"
  | LabelOrange => "fill-jp-2-light-orange-600"
  | LabelYellow => "fill-jp-2-light-yellow-800"
  | LabelMagenta => "fill-jp-2-light-magenta-600"
  | LabelTeal => "fill-jp-2-light-teal-600"
  | LabelCyan => "fill-jp-2-light-cyan-600"
  }

  let colorCss = isFill ? fillColor : strokeColor

  let textSize = switch labelSize {
  | Small => "text-fs-12"
  | Medium => "text-fs-14"
  | Large => "text-fs-14"
  }

  let labelHeight = switch labelSize {
  | Small => "h-5.5"
  | Medium => "h-6"
  | Large => "h-7"
  }

  let padding = switch labelSize {
  | Small =>
    if iconLeft !== NoIcon {
      "pr-2 pl-1.5 py-0.5 gap-1.5"
    } else if iconRight !== NoIcon {
      "pr-1.5 pl-2 py-0.5 gap-1.5"
    } else {
      "px-2 py-0.5 gap-1.5"
    }
  | Medium =>
    if iconLeft !== NoIcon {
      "pr-2.5 pl-2 py-0.5 gap-1.5"
    } else if iconRight !== NoIcon {
      "pr-2 pl-2.5 py-0.5 gap-1.5"
    } else {
      "px-2.5 py-0.5 gap-1.5"
    }
  | Large =>
    if iconLeft !== NoIcon {
      "pr-3 pl-2.5 py-1 gap-1.5"
    } else if iconRight !== NoIcon {
      "pr-2.5 pl-3 py-1 gap-1.5"
    } else {
      "px-3 py-1 gap-1.5"
    }
  }

  let iconPadding = switch labelSize {
  | Small => "p-1"
  | Medium => "p-1.5"
  | Large => "p-2"
  }

  let paddingCss = labelText !== "" ? padding : iconPadding

  <div className="flex-initial w-fit">
    <div className={`rounded-full ${color}`}>
      <div
        className={`flex flex-row ${paddingCss} ${textSize} ${labelHeight} font-medium items-center justify-center ${customCss}`}>
        {switch iconLeft {
        | FontAwesome(iconName) =>
          <Icon className={`align-middle ${iconColor}`} size=iconSize name=iconName />
        | Euler(iconName) =>
          <Icon className={`align-middle ${colorCss}`} size=iconSize name=iconName />
        | CustomIcon(element) => <span className=""> {element} </span>
        | _ => React.null
        }}
        <AddDataAttributes attributes=[("data-label", labelText)]>
          <div className="whitespace-pre"> {React.string(labelText)} </div>
        </AddDataAttributes>
        {switch iconRight {
        | FontAwesome(iconName) =>
          <Icon className={`align-middle ${iconColor}`} size=iconSize name=iconName />
        | Euler(iconName) =>
          <Icon className={`align-middle ${colorCss}`} size=iconSize name=iconName />
        | CustomIcon(element) => element
        | _ => React.null
        }}
      </div>
    </div>
  </div>
}
