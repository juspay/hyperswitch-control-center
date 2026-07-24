@react.component
let make = (
  ~children,
  ~viewportWidth="749px",
  ~viewportHeight="460px",
  ~screenWidth="960px",
  ~screenHeight="590px",
  ~contentHeight="540px",
  ~scale="0.78",
) => {
  <div
    className="relative w-full h-full rounded-2xl bg-nd_gray-25 overflow-hidden flex items-center justify-center p-4">
    <div
      className="absolute inset-0 pointer-events-none opacity-70 bg-dot-pattern bg-dot-pattern-size"
    />
    <div
      className="relative overflow-hidden max-w-full"
      style={ReactDOM.Style.make(~width=viewportWidth, ~height=viewportHeight, ())}>
      <div
        className="absolute top-0 left-0 bg-white rounded-xl shadow-2xl border border-nd_gray-200 overflow-hidden origin-top-left"
        style={ReactDOM.Style.make(
          ~width=screenWidth,
          ~height=screenHeight,
          ~transform=`scale(${scale})`,
          (),
        )}>
        <div className="h-50-px bg-nd_gray-50 border-b border-nd_gray-150 flex items-center px-6">
          <div className="flex items-center gap-2">
            <div className="h-3 w-3 rounded-full bg-nd_red-400" />
            <div className="h-3 w-3 rounded-full bg-nd_yellow-500" />
            <div className="h-3 w-3 rounded-full bg-nd_green-400" />
          </div>
        </div>
        <div
          className="bg-white overflow-hidden"
          style={ReactDOM.Style.make(~height=contentHeight, ())}>
          {children}
        </div>
      </div>
    </div>
  </div>
}
