@react.component
let make = () => {
  let isMobileView = MatchMedia.useMatchMedia("(max-width: 830px)")

  <div
    className={`flex justify-center items-center bg-white gap-2 ${isMobileView
        ? "flex-wrap"
        : "h-14"}`}>
    <HSwitchFilterTab tabName=CustomerLocation />
    <HSwitchFilterTab tabName=Size />
    <HSwitchFilterTab tabName=Theme />
    <HSwitchFilterTab tabName=Layout />
  </div>
}
