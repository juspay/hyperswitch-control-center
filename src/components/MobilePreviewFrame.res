@react.component
let make = (~children, ~screenWidth="280px", ~screenHeight="540px") =>
  <div
    className="relative w-full h-full rounded-2xl bg-nd_gray-25 overflow-hidden flex items-center justify-center p-2">
    <div
      className="absolute inset-0 pointer-events-none opacity-70"
      style={ReactDOM.Style.make(
        ~backgroundImage="radial-gradient(#d9dee7 1px, transparent 1px)",
        ~backgroundSize="16px 16px",
        (),
      )}
    />
    <div className="relative bg-black rounded-2-rem p-2 shadow-2xl max-h-full">
      <div className="absolute -left-3-px top-10-per w-3-px h-4-per bg-black rounded-l-sm" />
      <div className="absolute -left-3-px top-16-per w-3-px h-8-per bg-black rounded-l-sm" />
      <div className="absolute -left-3-px top-26-per w-3-px h-8-per bg-black rounded-l-sm" />
      <div className="absolute -right-3-px top-16-per w-3-px h-11-per bg-black rounded-r-sm" />
      <div
        className="max-h-full bg-white rounded-1.75-rem overflow-hidden"
        style={ReactDOM.Style.make(~width=screenWidth, ~height=screenHeight, ())}>
        {children}
      </div>
    </div>
  </div>
