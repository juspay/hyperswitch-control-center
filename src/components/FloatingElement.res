module BottomRight = {
  @react.component
  let make = (~children: React.element) => {
    <div className="bottom-0 right-0 fixed items-end pr-4 pb-4"> children </div>
  }
}
