type timerId
@val external setInterval: (unit => unit, int) => int = "setInterval"
@val external clearInterval: int => unit = "clearInterval"

@react.component
let make = (~initialTime) => {
  let (_, setIsTimeOver) = React.useState(_ => false)
  let (timer, setTimer) = React.useState(_ => initialTime)
  let (intervalId, setIntervalId) = React.useState(_ => 0)
  let countdown = _ => {
    setTimer(timer => timer - 1)
  }
  React.useEffect1(() => {
    if timer == 0 {
      clearInterval(intervalId)
      setIsTimeOver(_ => true)
      setTimer(_ => 0)
    } else {
      setTimer(_ => initialTime)
      let intervalid = setInterval(() => countdown(timer), 1000)
      setIntervalId(_ => intervalid)
    }
    None
  }, [])

  <div className="mx-2"> {timer->Belt.Int.toString->React.string} </div>
}
