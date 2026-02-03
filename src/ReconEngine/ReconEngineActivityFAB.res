@react.component
let make = () => {
  let (showDrawer, setShowDrawer) = React.useState(_ => false)

  let iconClass = showDrawer ? "right-500-px" : "right-0"

  <>
    <div
      className={`fixed top-120-px -translate-y-1/2 z-20 transition-all duration-300 ease-in-out ${iconClass}`}>
      <RenderIf condition={!showDrawer}>
        <div className="relative group cursor-pointer" onClick={_ => setShowDrawer(_ => true)}>
          <div
            className="flex items-center justify-center w-12 h-16 bg-nd_gray-700 rounded-l-xl shadow-lg hover:shadow-xl transition-all duration-300 hover:w-14 hover:bg-nd_gray-800">
            <Icon
              name="notification_bell"
              size=20
              className="text-white transition-transform duration-200 group-hover:scale-105"
            />
          </div>
        </div>
      </RenderIf>
      <RenderIf condition={showDrawer}>
        <div className="relative group cursor-pointer" onClick={_ => setShowDrawer(_ => false)}>
          <div
            className="flex items-center justify-center w-10 h-16 bg-nd_gray-700 rounded-l-xl shadow-lg hover:shadow-xl transition-all duration-300 hover:w-12 hover:bg-nd_gray-800">
            <Icon
              name="close"
              size=12
              className="text-white transition-transform duration-200 group-hover:scale-105"
            />
          </div>
        </div>
      </RenderIf>
    </div>
    <ReconEngineAuditLogDrawer showDrawer />
  </>
}
