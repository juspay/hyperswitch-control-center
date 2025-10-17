type breadcrumb = {
  title: string,
  link: string,
  onClick?: ReactEvent.Mouse.t => unit,
  warning?: string,
  mixPanelCustomString?: string,
}
let arrowDivider =
  <span className="ml-2 mr-2">
    <Icon className="align-middle  text-jp-gray-930" size=8 name="chevron-right" />
  </span>
type dividerVal =
  | Slash
  | Arrow

@react.component
let make = (
  ~path: array<breadcrumb>=[],
  ~currentPageTitle="",
  ~is_reverse=false,
  ~cursorStyle="cursor-help",
  ~commonTextClass="",
  ~linkTextClass="text-nd_gray-400",
  ~customTextClass="",
  ~fontWeight="font-semibold",
  ~titleTextClass="text-nd_gray-700",
  ~titleTypography="",
  ~dividerVal=Slash,
  ~childGapClass="",
) => {
  open LogicUtils
  open Typography

  let prefix = LogicUtils.useUrlPrefix()
  let showPopUp = PopUpState.useShowPopUp()
  let pathLength = path->Array.length
  let divider = {
    switch dividerVal {
    | Slash => <span className="text-nd_gray-400 ml-2 mr-2"> {"/"->React.string} </span>
    | _ => arrowDivider
    }
  }
  let activeTitleTypography = titleTypography->isEmptyString ? body.md.semibold : titleTypography
  let parentGapClass = "gap-2"
  let flexDirection = is_reverse ? "flex-wrap flex-row-reverse" : "flex-wrap flex-row"

  <div className={`flex ${flexDirection} ${fontWeight} ${parentGapClass}  items-center w-fit`}>
    {path
    ->Array.mapWithIndex((crumb, index) => {
      let showCrumb = index <= 2 || index === pathLength - 1
      let collapse = index === 2 && pathLength > 3
      let onClick = switch crumb.onClick {
      | Some(fn) => fn
      | None =>
        _ =>
          showPopUp({
            popUpType: (Warning, WithIcon),
            heading: "Heads up!",
            description: {React.string(crumb.warning->Option.getOr(""))},
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
      }
      <RenderIf key={Int.toString(index)} condition=showCrumb>
        <div className={`flex ${flexDirection} ${childGapClass} items-center`}>
          {if collapse {
            <div
              className="flex flex-row gap-1 text-jp-2-gray-100 font-medium items-center justify-center">
              <span> {React.string("...")} </span>
              <Icon name="angle-down" size=12 />
            </div>
          } else {
            <AddDataAttributes attributes=[("data-breadcrumb", crumb.title)]>
              <div>
                {switch (crumb.warning, crumb.onClick) {
                | (None, None) =>
                  <Link
                    className={`${linkTextClass} ${commonTextClass}`}
                    to_={GlobalVars.appendDashboardPath(~url=`${prefix}${crumb.link}`)}>
                    {React.string(crumb.title)}
                  </Link>
                | _ =>
                  <a
                    className={`${cursorStyle} ${linkTextClass} ${commonTextClass}`}
                    onClick>
                    {React.string(crumb.title)}
                  </a>
                }}
              </div>
            </AddDataAttributes>
          }}
          divider
        </div>
      </RenderIf>
    })
    ->React.array}
    <AddDataAttributes attributes=[("data-breadcrumb", currentPageTitle)]>
      <div className={`${activeTitleTypography} ${titleTextClass} ${commonTextClass}`}>
        {React.string(currentPageTitle)}
      </div>
    </AddDataAttributes>
  </div>
}
