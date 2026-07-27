type breadcrumb = {
  title: string,
  link: string,
  onClick?: ReactEvent.Mouse.t => unit,
  warning?: string,
  mixPanelCustomString?: string,
}

@react.component
let make = (~path: array<breadcrumb>=[], ~currentPageTitle="") => {
  let showPopUp = PopUpState.useShowPopUp()

  let pathItems = path->Array.map(crumb => {
    let handleClick = switch (crumb.warning, crumb.onClick) {
    | (_, Some(fn)) => fn
    | (Some(warning), None) =>
      _ =>
        showPopUp({
          popUpType: (Warning, WithIcon),
          heading: "Heads up!",
          description: {React.string(warning)},
          handleConfirm: {
            text: "Yes, go back",
            onClick: {
              _ => RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url=crumb.link))
            },
          },
          handleCancel: {
            text: "No, don't go back",
          },
        })
    | (None, None) => _ => RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url=crumb.link))
    }
    let item: BreadcrumbBinding.breadcrumbItemType = {
      label: crumb.title,
      href: GlobalVars.appendDashboardPath(~url=crumb.link),
      onClick: handleClick,
    }
    item
  })

  let currentItem: BreadcrumbBinding.breadcrumbItemType = {
    label: currentPageTitle,
    href: "",
  }

  let items = Array.concat(pathItems, [currentItem])
  <div className="-ml-2">
    <BreadcrumbBinding items />
  </div>
}
