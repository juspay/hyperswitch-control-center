let getUniqueStrArray = (arr: array<string>) => {
  arr
  ->Js.Array2.map(item => {
    (item, 0)
  })
  ->Js.Dict.fromArray
  ->Js.Dict.keys
}

let getUniqueIntArr = (arr: array<int>) => {
  arr
  ->Js.Array2.map(item => {
    (item->Belt.Int.toString, 0)
  })
  ->Js.Dict.fromArray
  ->Js.Dict.keys
  ->Js.Array2.map(item => item->Belt.Int.fromString->Belt.Option.getWithDefault(0))
}

let getUniqueFloatArr = (arr: array<float>) => {
  arr
  ->Js.Array2.map(item => {
    (item->Belt.Float.toString, 0)
  })
  ->Js.Dict.fromArray
  ->Js.Dict.keys
  ->Js.Array2.map(item => item->Belt.Float.fromString->Belt.Option.getWithDefault(0.))
}

let arrayDiff = (arra, arrb) => {
  arra->Js.Array2.copy->Js.Array2.filter(item => !(arrb->Js.Array2.includes(item)))
}
