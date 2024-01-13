@react.component
let make = (~to_, ~children, ~openInNewTab=false, ~className=?, ~onClick=?) => {
  let handleClick = React.useCallback1(ev => {
    ReactEvent.Mouse.stopPropagation(ev)
    ReactEvent.Mouse.preventDefault(ev)
    switch onClick {
    | Some(fn) => fn(to_)
    | None => ()
    }

    RescriptReactRouter.push(to_)
  }, [to_])
  if openInNewTab {
    if to_->String.trim === "" {
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
