type breadcrumb = {
  title: string,
  link: string,
  onClick?: ReactEvent.Mouse.t => unit,
  warning?: string,
  mixPanelCustomString?: string,
}

type dividerVal =
  | Slash
  | Arrow

@react.component
let make = (
  ~path: array<breadcrumb>=[],
  ~currentPageTitle="",
  ~cursorStyle="cursor-help",
  ~customTextClass="",
  ~fontWeight="font-semibold",
  ~titleTextClass="text-jp-gray-930",
  ~dividerVal=Arrow,
  ~childGapClass="",
) => {
  let prefix = LogicUtils.useUrlPrefix()
  let showPopUp = PopUpState.useShowPopUp()

  let blendItems = path->Array.map(crumb => {
    let onClick: option<JsxEventU.Mouse.t => unit> = switch (crumb.warning, crumb.onClick) {
    | (Some(warningText), _) =>
      Some(
        _ =>
          showPopUp({
            popUpType: (Warning, WithIcon),
            heading: "Heads up!",
            description: React.string(warningText),
            handleConfirm: {
              text: "Yes, go back",
              onClick: _ =>
                RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url=crumb.link)),
            },
            handleCancel: {text: "No, don't go back"},
          }),
      )
    | (None, Some(fn)) => Some(e => fn(e->Obj.magic))
    | (None, None) =>
      Some(
        e => {
          e->JsxEventU.Mouse.preventDefault
          RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url=`${prefix}${crumb.link}`))
        },
      )
    }
    {
      BlendBreadcrumb.label: crumb.title,
      href: GlobalVars.appendDashboardPath(~url=`${prefix}${crumb.link}`),
      ?onClick,
    }
  })

  let currentItem: BlendBreadcrumb.breadcrumbItem = {
    label: currentPageTitle,
    href: "",
  }

  let allItems = Array.concat(blendItems, [currentItem])
  <div>
    <BlendBreadcrumb items=allItems />
  </div>
}
