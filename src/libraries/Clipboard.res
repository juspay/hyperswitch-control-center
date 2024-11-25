type styleObj
@get external style: Dom.element => styleObj = "style"

@val @scope(("navigator", "clipboard"))
external writeTextDoc: string => unit = "writeText"
external readTextDoc: unit => string = "readText"

@val external document: 'a = "document"
@set external setPosition: (styleObj, string) => unit = "position"
@set external setLeft: (styleObj, string) => unit = "left"
@send external select: (Dom.element, unit) => unit = "select"
@send external remove: (Dom.element, unit) => unit = "remove"
@val @scope(("window", "document", "body"))
external prepend: 'a => unit = "prepend"

@val @scope("document")
external execCommand: string => unit = "execCommand"

let readText = setData => {
  try {
    if Window.isSecureContext {
      // Webapi.Clipboard.readText()
      let data = readTextDoc()
      Js.log2("data", data)
      setData(_ => data)
    } else {
      // let textArea = document->DOMUtils.createElement("textarea")
      // textArea->Webapi.Dom.Element.setInnerHTML(str)
      // textArea->style->setPosition("absolute")
      // textArea->style->setPosition("absolute")
      // textArea->style->setLeft("-99999999px")
      // textArea->prepend
      // textArea->select()
      // execCommand("paste")
      // textArea->remove()
      Js.log2("", "")
      setData(_ => "failed")
    }
  } catch {
  | _ => ()
  }
}

let writeText = (str: string) => {
  try {
    if Window.isSecureContext {
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

      writeText([data]->Array.joinWithUnsafe("\n"))
    }

    let iconClass = GlobalVars.isHyperSwitchDashboard ? "text-gray-300" : "text-jp-gray-900"

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

module Paste = {
  @react.component
  let make = (
    ~setData,
    ~toolTipPosition: ToolTip.toolTipPosition=Left,
    ~pasteElement=?,
    ~iconSize=15,
    ~outerPadding="p-2",
  ) => {
    let (tooltipText, setTooltipText) = React.useState(_ => "paste")
    let onPasteClick = ev => {
      ev->ReactEvent.Mouse.stopPropagation
      setTooltipText(_ => "pasted")

      // setData(_ => "gitanjli")

      readText(setData)

      // let data =

      // readText([data]->Array.joinWithUnsafe("\n"))
    }

    let iconClass = GlobalVars.isHyperSwitchDashboard ? "text-gray-300" : "text-jp-gray-900"

    <div
      className={`flex justify-end ${outerPadding}`}
      onMouseOut={_ => {
        setTooltipText(_ => "paste")
      }}>
      <div onClick={onPasteClick}>
        <ToolTip
          tooltipWidthClass="w-fit"
          bgColor={tooltipText == "paste" ? "" : "bg-green-950 text-white"}
          arrowBgClass={tooltipText == "paste" ? "" : "#36AF47"}
          description=tooltipText
          toolTipFor={switch pasteElement {
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
