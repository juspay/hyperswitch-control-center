type regexTest = {
  regex: Js.Re.t,
  weight: float,
}
type warningColor = Red | Yellow | Green
type warningMessage = {
  message: string,
  color: warningColor,
}

@react.component
let make = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder,
  ~displayStatus=true,
  ~leftIcon=?,
  (),
) => {
  let tests = [
    {
      regex: %re("/[0-9]/g"),
      weight: 1.0,
    },
    {
      regex: %re("/[a-z]/g"),
      weight: 1.0,
    },
    {
      regex: %re("/[A-Z]/g"),
      weight: 1.0,
    },
    {
      regex: %re("/[$@$!%*#?&]/g"),
      weight: 2.0,
    },
  ]
  let (passwordStatus, setPasswordStatus) = React.useState(() => {message: "", color: Red})

  let newInput = {
    ...input,
    onChange: ev => {
      input.onChange(ev)
      let strVal = ReactEvent.Form.target(ev)["value"]
      let (variety, score) = tests->Array.reduce((0, 0.0), (acc, test) => {
        let (accVariety, accScore) = acc
        let res = Js.Re.exec_(test.regex, strVal)
        let result = switch res {
        | Some(val) => Js.Re.captures(val)
        | None => []
        }
        let nonEmptyResult = result->Array.length != 0
        let localVariety = nonEmptyResult ? accVariety + 1 : 0
        let localScore =
          accScore +.
          (test.weight *. result->Array.length->Belt.Int.toFloat +.
          strVal->String.length->Belt.Int.toFloat *. 1.2)
        (localVariety, localScore)
      })

      let newPasswordStatus = if strVal->String.length <= 1 {
        {message: "", color: Red}
      } else if variety != 4 {
        {message: "Too Simple", color: Red}
      } else if score >= 90.0 {
        {message: "Strong", color: Green}
      } else if score >= 65.0 {
        {message: "Good", color: Green}
      } else if score >= 40.0 {
        {message: "Average", color: Yellow}
      } else {
        {message: "Bad", color: Red}
      }
      setPasswordStatus(_ => newPasswordStatus)
    },
  }
  let displayColor = if passwordStatus.color == Red {
    "text-red-500"
  } else if passwordStatus.color == Yellow {
    "text-yellow-500"
  } else {
    "text-green-800"
  }
  <div>
    <div>
      <TextInput input=newInput placeholder type_="password" ?leftIcon />
    </div>
    {displayStatus
      ? <div className=displayColor> {React.string(passwordStatus.message)} </div>
      : React.null}
  </div>
}
