type styleObj
@get external style: Dom.element => styleObj = "style"

@val @scope(("navigator", "clipboard"))
external writeTextDoc: string => unit = "writeText"

@val external document: 'a = "document"
@set external setPosition: (styleObj, string) => unit = "position"
@set external setLeft: (styleObj, string) => unit = "left"
@send external select: (Dom.element, unit) => unit = "select"
@send external remove: (Dom.element, unit) => unit = "remove"
@val @scope(("window", "document", "body"))
external prepend: 'a => unit = "prepend"

@val @scope("document")
external execCommand: string => unit = "execCommand"

@val @scope("window")
external isSecureContext: bool = "isSecureContext"

let writeText = (str: string) => {
  try {
    if isSecureContext {
      writeTextDoc(str)
    } else {
      let textArea = document->DOMUtils.createElement("textarea")
      textArea->Webapi.Dom.Element.setInnerHTML(str)
      textArea->style->setPosition("absolute")
      textArea->style->setPosition("absolute")
      textArea->style->setLeft("-99999999px")
      textArea->prepend
      textArea->select()
      execCommand("copy")
      textArea->remove()
    }
  } catch {
  | _ => ()
  }
}

module Copy = {
  @react.component
  let make = (
    ~data,
    ~toolTipPosition: ToolTip.toolTipPosition=Left,
    ~copyElement=?,
    ~iconSize=15,
    ~outerPadding="p-2",
  ) => {
    let (tooltipText, setTooltipText) = React.useState(_ => "copy")
    let onCopyClick = ev => {
      ev->ReactEvent.Mouse.stopPropagation
      setTooltipText(_ => "copied")

      writeText([data]->Array.joinWith("\n"))
    }

    let iconClass = HSwitchGlobalVars.isHyperSwitchDashboard ? "text-gray-300" : "text-jp-gray-900"

    <div
      className={`flex justify-end ${outerPadding}`}
      onMouseOut={_ => {
        setTooltipText(_ => "copy")
      }}>
      <div onClick={onCopyClick}>
        <ToolTip
          tooltipWidthClass="w-fit"
          bgColor={tooltipText == "copy" ? "" : "bg-green-950 text-white"}
          arrowBgClass={tooltipText == "copy" ? "" : "#36AF47"}
          description=tooltipText
          toolTipFor={switch copyElement {
          | Some(element) => element
          | None =>
            <div className={`${iconClass} flex items-center cursor-pointer`}>
              <Icon name="copy" size=iconSize />
            </div>
          }}
          toolTipPosition
          tooltipPositioning=#absolute
        />
      </div>
    </div>
  }
}
