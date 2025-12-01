module OverlappingCircles = {
  @react.component
  let make = (~colorA: string, ~colorB: string) => {
    <div className="relative w-9 h-6 flex items-center">
      <div
        className="absolute left-0 w-6 h-6 rounded-full border border-nd_gray-50 shadow-md"
        style={ReactDOM.Style.make(~backgroundColor=colorA, ())}
      />
      <div
        className="absolute left-4 w-6 h-6 rounded-full border border-nd_gray-50 shadow-md"
        style={ReactDOM.Style.make(~backgroundColor=colorB, ())}
      />
    </div>
  }
}

module CreateNewThemeButton = {
  @react.component
  let make = () => {
    open Typography
    open SessionStorage
    open LogicUtils

    let sessionModalValue =
      sessionStorage.getItem("themeLineageModal")
      ->Nullable.toOption
      ->Option.getOr("")
      ->getBoolFromString(false)
    let (showModal, setShowModal) = React.useState(_ => sessionModalValue)
    <>
      <Button
        text="Create Theme"
        buttonType=Primary
        buttonState=Normal
        buttonSize=Small
        customButtonStyle={`${body.md.semibold} py-4`}
        onClick={_ => {
          setShowModal(_ => true)
        }}
      />
      <ThemeLineageModal showModal setShowModal />
    </>
  }
}
