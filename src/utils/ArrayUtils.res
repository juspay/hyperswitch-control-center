let getUniqueStrArray = (arr: array<string>) => {
  arr
  ->Js.Array2.map(item => {
    (item, 0)
  })
  ->Js.Dict.fromArray
  ->Js.Dict.keys
}
