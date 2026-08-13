@react.component
let make = () => {
  <div className="fixed top-180-px -translate-y-1/2 z-20 right-0">
    <div
      className="relative group cursor-pointer"
      title="How does my reconciliation setup work?"
      onClick={_ =>
        RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url="/v1/recon-engine/setup"))}>
      <div
        className="flex items-center justify-center w-12 h-14 bg-nd_gray-700 rounded-l-xl shadow-lg hover:shadow-xl transition-all duration-300 hover:w-14 hover:bg-nd_gray-800">
        <Icon
          name="nd-info-circle"
          size=20
          className="text-white transition-transform duration-200 group-hover:scale-105"
        />
      </div>
    </div>
  </div>
}
