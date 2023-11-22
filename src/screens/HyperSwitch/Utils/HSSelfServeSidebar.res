@val @scope(("window", "location"))
external reload: unit => unit = "reload"

type status = COMPLETED | ONGOING | PENDING

type subOption = {
  title: string,
  status: status,
}

type sidebarOption = {
  title: string,
  status: status,
  link: string,
  subOptions?: array<subOption>,
}

@react.component
let make = (~heading, ~sidebarOptions: array<sidebarOption>=[]) => {
  let {setDashboardPageState} = React.useContext(GlobalProvider.defaultContext)
  let handleBackButton = _ => {
    setDashboardPageState(_ => #HOME)
    RescriptReactRouter.replace("/home")
  }

  let completedSteps =
    sidebarOptions->Js.Array2.filter(sidebarOption => sidebarOption.status === COMPLETED)

  let completedPercentage =
    (completedSteps->Js.Array2.length->Belt.Int.toFloat /.
    sidebarOptions->Js.Array2.length->Belt.Int.toFloat *. 100.0)->Belt.Float.toInt

  <div className="w-22.7-rem h-screen bg-white shadow-sm">
    <div className="p-6 flex flex-col gap-3">
      <div className="text-xl font-semibold"> {heading->React.string} </div>
      <div className="text-blue-700 flex gap-3 cursor-pointer" onClick={handleBackButton}>
        <Icon name="back-to-home-icon" />
        {"Exit to Homepage"->React.string}
      </div>
    </div>
    <div className="flex flex-col px-6 py-8 gap-2 border-y border-gray-200">
      <span> {`${completedPercentage->Belt.Int.toString}% Completed`->React.string} </span>
      <div className="h-2 bg-gray-200">
        <div
          className={"h-full bg-blue-700"}
          style={ReactDOMStyle.make(~width=`${completedPercentage->Belt.Int.toString}%`, ())}
        />
      </div>
    </div>
    {sidebarOptions
    ->Array.mapWithIndex((sidebarOption, i) => {
      let (icon, indexBackground, indexColor, background, textColor) = switch sidebarOption.status {
      | COMPLETED => ("green-check", "bg-blue-700", "text-white", "", "")
      | PENDING => ("lock-icon", "bg-blue-200", "text-blue-700", "bg-jp-gray-light_gray_bg", "")
      | ONGOING => ("", "bg-blue-700", "text-white", "", "text-blue-700")
      }

      let onClick = _ => {
        if sidebarOption.status === COMPLETED {
          RescriptReactRouter.replace(sidebarOption.link)
        }
      }

      <div className={`p-6 border-y border-gray-200 cursor-pointer ${background}`} onClick>
        <div
          key={i->Belt.Int.toString}
          className={`grid grid-cols-12 items-center  ${textColor} font-medium gap-5`}>
          <span
            className={`${indexBackground} ${indexColor} rounded-sm w-1.1-rem h-1.1-rem flex justify-center items-center col-span-1 text-sm`}>
            {(i + 1)->Belt.Int.toString->React.string}
          </span>
          <span className="col-span-10"> {sidebarOption.title->React.string} </span>
          <div className="justify-center flex">
            <Icon name=icon size=20 />
          </div>
        </div>
        <UIUtils.RenderIf
          condition={sidebarOption.status === ONGOING &&
            sidebarOption.subOptions->Belt.Option.isSome}>
          <div className="my-4">
            {sidebarOption.subOptions
            ->Belt.Option.getWithDefault([])
            ->Js.Array2.map(subOption => {
              let (subIcon, subIconColor, subBackground, subFont) = switch subOption.status {
              | COMPLETED => ("check", "green", "", "text-gray-600")
              | PENDING => ("nonselected", "text-gray-100", "", "text-gray-400")
              | ONGOING => ("nonselected", "", "bg-gray-100", "font-semibold")
              }

              <div
                className={`flex gap-1 items-center pl-6 py-2 rounded-md my-1 ${subBackground} ${subFont}`}>
                <Icon name=subIcon customIconColor=subIconColor customHeight="14" />
                <span className="flex-1"> {subOption.title->React.string} </span>
              </div>
            })
            ->React.array}
          </div>
        </UIUtils.RenderIf>
      </div>
    })
    ->React.array}
  </div>
}
