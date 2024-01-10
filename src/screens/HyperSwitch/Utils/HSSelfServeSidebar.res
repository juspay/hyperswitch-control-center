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
    sidebarOptions->Array.filter(sidebarOption => sidebarOption.status === COMPLETED)

  let completedPercentage =
    (completedSteps->Array.length->Belt.Int.toFloat /.
    sidebarOptions->Array.length->Belt.Int.toFloat *. 100.0)->Belt.Float.toInt

  <div className="w-[288px] xl:w-[364px] h-screen bg-white shadow-sm shrink-0">
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
      let subOptionsArray = sidebarOption.subOptions->Belt.Option.getWithDefault([])
      <div
        key={i->string_of_int}
        className={`p-6 border-y border-gray-200 cursor-pointer ${background}`}
        onClick>
        <div
          key={i->Belt.Int.toString} className={`flex items-center ${textColor} font-medium gap-5`}>
          <span
            className={`${indexBackground} ${indexColor} rounded-sm w-1.1-rem h-1.1-rem flex justify-center items-center text-sm`}>
            {(i + 1)->Belt.Int.toString->React.string}
          </span>
          <div className="flex-1">
            <ToolTip
              description={sidebarOption.title}
              toolTipFor={<div
                className="w-40 xl:w-60 text-ellipsis overflow-hidden whitespace-nowrap">
                {sidebarOption.title->React.string}
              </div>}
            />
          </div>
          <Icon name=icon size=20 />
        </div>
        <UIUtils.RenderIf
          condition={sidebarOption.status === ONGOING && subOptionsArray->Array.length > 0}>
          <div className="my-4">
            {subOptionsArray
            ->Array.mapWithIndex((subOption, i) => {
              let (subIcon, subIconColor, subBackground, subFont) = switch subOption.status {
              | COMPLETED => ("check", "green", "", "text-gray-600")
              | PENDING => ("nonselected", "text-gray-100", "", "text-gray-400")
              | ONGOING => ("nonselected", "", "bg-gray-100", "font-semibold")
              }

              <div
                key={i->string_of_int}
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
