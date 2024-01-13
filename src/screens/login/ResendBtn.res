@react.component
let make = (~callBackFun) => {
  let (seconds, setSeconds) = React.useState(_ => 30)

  let isDisabled = seconds > 0

  let resendOTP = () => {
    callBackFun()
    setSeconds(_ => 30)
  }
  let disabledColor = isDisabled ? "text-jp-gray-700" : "text-blue-800"

  React.useEffect0(() => {
    let intervalId = Js.Global.setInterval(() => setSeconds(p => p > 0 ? p - 1 : p), 1000)
    let cleanup = () => {
      Js.Global.clearInterval(intervalId)
    }
    Some(cleanup)
  })

  <div className="flex w-full justify-center text-sm font-medium">
    <div className="text-dark_black opacity-80 mr-1">
      {"Didn't receive the mail?"->React.string}
    </div>
    <a
      className={`${disabledColor} cursor-pointer text-md !hover:${disabledColor} mr-2 underline underline-offset-4`}
      onClick={_ => {
        if !isDisabled {
          resendOTP()
        }
      }}>
      {"Send again."->React.string}
    </a>
    <UIUtils.RenderIf condition={isDisabled}>
      <div className="text-blue-700">
        {`(${mod(seconds, 60)->Belt.Int.toString}sec)`->React.string}
      </div>
    </UIUtils.RenderIf>
  </div>
}
