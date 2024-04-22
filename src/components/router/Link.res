@react.component
let make = (
  ~to_,
  ~children,
  ~openInNewTab=false,
  ~className=?,
  ~onClick=?,
  ~sendMixpanelEvents=false,
) => {
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let handleClick = React.useCallback1(ev => {
    ReactEvent.Mouse.stopPropagation(ev)
    ReactEvent.Mouse.preventDefault(ev)
    switch onClick {
    | Some(fn) => fn(to_)
    | None => ()
    }

    if sendMixpanelEvents {
      let eventName = to_->String.replaceRegExp(%re("/^\//"), "")
      mixpanelEvent(~eventName=`${eventName}`, ())
    }
    RescriptReactRouter.push(HSwitchGlobalVars.appendDashboardPath(~url=to_))
  }, [to_])
  if openInNewTab {
    if to_->String.trim->LogicUtils.isEmptyString {
      children
    } else {
      <a href=to_ onClick={ev => ev->ReactEvent.Mouse.stopPropagation} target="_blank" ?className>
        children
      </a>
    }
  } else {
    <a href=to_ onClick=handleClick ?className> children </a>
  }
}
