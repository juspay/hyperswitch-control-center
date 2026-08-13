@react.component
let make = (~children) => {
  <div
    className="relative w-full h-full rounded-2xl bg-nd_gray-25 overflow-hidden flex items-center justify-center p-4">
    <div
      className="absolute inset-0 pointer-events-none opacity-70 bg-dot-pattern bg-dot-pattern-size"
    />
    <div className="relative overflow-hidden max-w-full w-749-px h-460-px">
      <div
        className="absolute top-0 left-0 bg-white rounded-xl shadow-2xl border border-nd_gray-200 overflow-hidden origin-top-left w-960-px h-590-px scale-78">
        <div className="h-50-px bg-nd_gray-50 border-b border-nd_gray-150 flex items-center px-6">
          <div className="flex items-center gap-2">
            <div className="h-3 w-3 rounded-full bg-nd_red-400" />
            <div className="h-3 w-3 rounded-full bg-nd_yellow-500" />
            <div className="h-3 w-3 rounded-full bg-nd_green-400" />
          </div>
        </div>
        <div className="bg-white overflow-hidden h-540-px"> {children} </div>
      </div>
    </div>
  </div>
}
