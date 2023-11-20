let convertIntoSec = timeArray => {
  if timeArray->Js.Array2.length > 0 {
    let hr =
      timeArray[0]
      ->Belt.Option.getWithDefault("00")
      ->Belt.Int.fromString
      ->Belt.Option.getWithDefault(0)
    let min =
      timeArray[1]
      ->Belt.Option.getWithDefault("00")
      ->Belt.Int.fromString
      ->Belt.Option.getWithDefault(0)
    hr * 60 * 60 + min * 60
  } else {
    0
  }
}

let getDateTimeInSec = dateValue => {
  let timeDateArray = dateValue->Js.String2.split("T")
  let timeArray = timeDateArray[1]->Belt.Option.getWithDefault("00:00")->Js.String2.split(":")
  convertIntoSec(timeArray)
}

let padZeroes2 = str => {
  if str->Js.String2.length == 0 {
    "00"
  } else if str->Js.String2.length == 1 {
    `0${str}`
  } else {
    str
  }
}
