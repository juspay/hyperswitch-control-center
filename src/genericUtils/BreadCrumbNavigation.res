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

@react.component
let make = (
  ~path: array<breadcrumb>=[],
  ~currentPageTitle="",
  ~is_reverse=false,
  ~cursorStyle="cursor-help",
  ~commonTextClass="",
  ~linkTextClass="",
) => {
  let prefix = LogicUtils.useUrlPrefix()
  let showPopUp = PopUpState.useShowPopUp()
  let pathLength = path->Array.length

  let divider = arrowDivider
  let fontWeight = "font-semibold"
  let textClass = "text-blue-800"
  let parentGapClass = "gap-2"
  let childGapClass = ""
  let flexDirection = is_reverse ? "flex-wrap flex-row-reverse" : "flex-wrap flex-row"
  let titleTextClass = "text-jp-gray-930"
  let marginClass = ""

  <div
    className={`flex ${flexDirection} ${fontWeight} ${parentGapClass} ${marginClass} items-center w-fit`}>
    {path
    ->Array.mapWithIndex((crumb, index) => {
      let showCrumb = index <= 2 || index === pathLength - 1
      let collapse = index === 2 && pathLength > 3
      let onClick = switch crumb.onClick {
      | Some(fn) => fn
      | None =>
        _ev =>
          showPopUp({
            popUpType: (Warning, WithIcon),
            heading: "Heads up!",
            description: {React.string(crumb.warning->Belt.Option.getWithDefault(""))},
            handleConfirm: {
              text: "Yes, go back",
              onClick: {
                _ => RescriptReactRouter.push(crumb.link)
              },
            },
            handleCancel: {
              text: "No, don't go back",
            },
          })
      }
      <UIUtils.RenderIf key={Belt.Int.toString(index)} condition=showCrumb>
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
                    className={`${textClass} ${linkTextClass} ${commonTextClass}`}
                    to_={`${prefix}${crumb.link}`}>
                    {React.string(crumb.title)}
                  </Link>
                | _ =>
                  <a
                    className={`${textClass} ${cursorStyle} ${linkTextClass} ${commonTextClass}`}
                    onClick>
                    {React.string(crumb.title)}
                  </a>
                }}
              </div>
            </AddDataAttributes>
          }}
          divider
        </div>
      </UIUtils.RenderIf>
    })
    ->React.array}
    <AddDataAttributes attributes=[("data-breadcrumb", currentPageTitle)]>
      <div className={`text-fs-14 ${titleTextClass} ${commonTextClass}`}>
        {React.string(currentPageTitle)}
      </div>
    </AddDataAttributes>
  </div>
}
