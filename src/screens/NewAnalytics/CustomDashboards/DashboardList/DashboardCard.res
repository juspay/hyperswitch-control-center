@react.component
let make = (
  ~dashboard: CustomDashboardTypes.dashboard,
  ~onOpen,
  ~onDelete,
  ~onSetDefault,
  ~onRename,
  ~onDuplicate,
) => {
  let widgetCount = dashboard.widgets->Array.length
  let updatedText = CustomDashboardUtils.formatUpdatedAt(dashboard.updatedAt)
  let showPopUp = PopUpState.useShowPopUp()
  let (showMenu, setShowMenu) = React.useState(_ => false)
  let (isRenaming, setIsRenaming) = React.useState(_ => false)
  let (renameValue, setRenameValue) = React.useState(_ => dashboard.dashboardName)

  let menuRef = React.useRef(Nullable.null)

  // Close menu on outside click — delay so menu item clicks fire first
  React.useEffect(() => {
    if showMenu {
      let handleClickOutside = (_evt: Dom.mouseEvent) => {
        setShowMenu(_ => false)
      }
      let timerId = Js.Global.setTimeout(() => {
        Webapi.Dom.document->Webapi.Dom.Document.addClickEventListener(handleClickOutside)
      }, 10)
      Some(
        () => {
          Js.Global.clearTimeout(timerId)
          Webapi.Dom.document->Webapi.Dom.Document.removeClickEventListener(handleClickOutside)
        },
      )
    } else {
      None
    }
  }, [showMenu])

  let handleRenameSubmit = () => {
    let trimmed = renameValue->String.trim
    if trimmed->LogicUtils.isNonEmptyString && trimmed !== dashboard.dashboardName {
      onRename(trimmed)
    }
    setIsRenaming(_ => false)
  }

  <div
    className="border rounded-lg bg-white dark:bg-jp-gray-lightgray_background overflow-visible hover:shadow-md transition-shadow h-full">
    <div className="p-5 flex flex-col gap-3 h-full min-h-[180px]">
      // Header
      <div className="flex items-start justify-between">
        <div className="flex items-center gap-2 flex-1 min-w-0">
          {if dashboard.isDefault {
            <Icon name="star" size=16 className="text-yellow-500 shrink-0" />
          } else {
            React.null
          }}
          {if isRenaming {
            <input
              autoFocus=true
              type_="text"
              value={renameValue}
              onChange={evt => setRenameValue(_ => ReactEvent.Form.target(evt)["value"])}
              onBlur={_ => handleRenameSubmit()}
              onKeyDown={evt => {
                if ReactEvent.Keyboard.key(evt) === "Enter" {
                  handleRenameSubmit()
                } else if ReactEvent.Keyboard.key(evt) === "Escape" {
                  setIsRenaming(_ => false)
                  setRenameValue(_ => dashboard.dashboardName)
                }
              }}
              className="text-lg font-bold text-jp-gray-900 dark:text-white bg-transparent border-b-2 border-blue-500 outline-none w-full"
            />
          } else {
            <p className="text-lg font-bold text-jp-gray-900 dark:text-white truncate">
              {React.string(dashboard.dashboardName)}
            </p>
          }}
        </div>
        <div className="relative shrink-0 ml-2" ref={menuRef->ReactDOM.Ref.domRef}>
          <button
            className="p-1.5 rounded-md hover:bg-gray-100 dark:hover:bg-jp-gray-lightgray_background text-gray-400 hover:text-gray-600"
            onClick={evt => {
              evt->JsxEvent.Mouse.stopPropagation
              setShowMenu(prev => !prev)
            }}>
            <Icon name="ellipsis-v" size=16 />
          </button>
          {if showMenu {
            <div
              className="absolute right-0 mt-1 w-48 bg-white dark:bg-jp-gray-lightgray_background border rounded-lg shadow-lg z-20 py-1"
              onClick={evt => evt->JsxEvent.Mouse.stopPropagation}>
              // Rename
              <button
                className="w-full text-left px-4 py-2.5 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-800 flex items-center gap-2.5"
                onClick={_ => {
                  setShowMenu(_ => false)
                  setRenameValue(_ => dashboard.dashboardName)
                  setIsRenaming(_ => true)
                }}>
                <Icon name="pencil-alt" size=14 />
                {React.string("Rename")}
              </button>
              // Set as Default
              <button
                className="w-full text-left px-4 py-2.5 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-800 flex items-center gap-2.5"
                onClick={_ => {
                  setShowMenu(_ => false)
                  onSetDefault()
                }}>
                <Icon name="star" size=14 />
                {React.string(dashboard.isDefault ? "Unset Default" : "Set as Default")}
              </button>
              // Duplicate
              <button
                className="w-full text-left px-4 py-2.5 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-800 flex items-center gap-2.5"
                onClick={_ => {
                  setShowMenu(_ => false)
                  onDuplicate()
                }}>
                <Icon name="nd-copy" size=14 />
                {React.string("Duplicate")}
              </button>
              <div className="border-t my-1" />
              // Delete
              <button
                className="w-full text-left px-4 py-2.5 text-sm text-red-500 hover:bg-red-50 dark:hover:bg-red-900/20 flex items-center gap-2.5"
                onClick={_ => {
                  setShowMenu(_ => false)
                  showPopUp({
                    popUpType: (Danger, WithoutIcon),
                    heading: `Delete '${dashboard.dashboardName}'?`,
                    description: "This dashboard will be deleted permanently"->React.string,
                    handleCancel: {text: "Cancel"},
                    handleConfirm: {
                      text: "Delete Dashboard",
                      onClick: _ => onDelete(),
                    },
                  })
                }}>
                <Icon name="nd-delete-dustbin" size=14 />
                {React.string("Delete")}
              </button>
            </div>
          } else {
            React.null
          }}
        </div>
      </div>
      // Description
      {switch dashboard.description {
      | Some(desc) if desc->LogicUtils.isNonEmptyString =>
        <p className="text-sm text-gray-500 dark:text-gray-400 line-clamp-2">
          {React.string(desc)}
        </p>
      | _ => React.null
      }}
      // Footer
      <div className="mt-auto flex items-center justify-between pt-2 border-t border-gray-100">
        <div className="flex items-center gap-4 text-xs text-gray-400">
          <span>
            {React.string(`${widgetCount->Int.toString} widget${widgetCount !== 1 ? "s" : ""}`)}
          </span>
          {if updatedText->LogicUtils.isNonEmptyString {
            <span> {React.string(`Updated: ${updatedText}`)} </span>
          } else {
            React.null
          }}
        </div>
        <Button text="Open" buttonType={Secondary} buttonSize=Small onClick={_ => onOpen()} />
      </div>
    </div>
  </div>
}
