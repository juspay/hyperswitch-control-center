@react.component
let make = (
  ~name,
  ~size=20,
  ~className=?,
  ~themeBased=false,
  ~onClick=?,
  ~parentClass=?,
  ~customIconColor="",
  ~customWidth=?,
  ~customHeight=?,
) => {
  let urlPrefix = ""

  let useUrl = <use fill=customIconColor xlinkHref={`${urlPrefix}/icons/solid.svg#${name}`} />

  let otherClasses = switch className {
  | Some(str) => str
  | None => ""
  }
  let handleClick = ev => {
    switch onClick {
    | Some(fn) => fn(ev)
    | None => ()
    }
  }
  <AddDataAttributes attributes=[("data-icon", name)]>
    <div
      className={switch parentClass {
      | Some(class) => class
      | None => "flex flex-col justify-center"
      }}>
      <svg
        onClick=handleClick
        fill=customIconColor
        className={`fill-current ${otherClasses}`}
        width={{
          customWidth->Belt.Option.isSome
            ? customWidth->Belt.Option.getWithDefault("")
            : string_of_int(size)
        } ++ "px"}
        height={{
          customHeight->Belt.Option.isSome
            ? customHeight->Belt.Option.getWithDefault("")
            : string_of_int(size)
        } ++ "px"}>
        useUrl
      </svg>
    </div>
  </AddDataAttributes>
}
