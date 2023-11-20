%%raw(`require("./DonutProgress.css")`)

@react.component
let make = (
  ~percent,
  ~children=?,
  ~displayText="",
  ~donutWidth=8,
  ~donutTitle="",
  ~donutCustomStyle=?,
) => {
  let children = switch children {
  | Some(children) => children
  | _ => React.null
  }
  <div
    className="bg-white dark:bg-jp-gray-lightgray_background border border-lightmode_steelgray dark:border-jp-gray-960 w-fit py-4 rounded-sm">
    <div
      className="font-semibold text-fs-16 text-black text-center text-opacity-75 dark:text-white dark:text-opacity-75 mb-6">
      {React.string(`${donutTitle}`)}
    </div>
    <div className="w-40 h-40 mx-20 mb-5">
      <BaseDonutProgress
        value=percent text=displayText strokeWidth=donutWidth styles=?donutCustomStyle>
        {children}
      </BaseDonutProgress>
    </div>
  </div>
}
