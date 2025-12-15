module OverlappingCircles = {
  @react.component
  let make = (~colorA: string, ~colorB: string) => {
    <div className="relative w-9 h-6 flex items-center">
      <div
        className={`absolute left-0 w-6 h-6 rounded-full border border-nd_gray-50 shadow-md bg-[${colorA}]`}
      />
      <div
        className={`absolute left-4 w-6 h-6 rounded-full border border-nd_gray-50 shadow-md bg-[${colorB}]`}
      />
    </div>
  }
}
