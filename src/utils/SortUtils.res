let sortByArrOrder = (dict: Js.Dict.t<int>) => {
  let sortByOrderOderedArr = (a: (string, 'a), b: (string, 'a)) => {
    let (a, _) = a
    let (b, _) = b
    let positionInHeader = dict->Js.Dict.get(a)->Belt.Option.getWithDefault(0)
    let positionInHeading = dict->Js.Dict.get(b)->Belt.Option.getWithDefault(0)
    if positionInHeader < positionInHeading {
      -1
    } else if positionInHeader > positionInHeading {
      1
    } else {
      0
    }
  }
  sortByOrderOderedArr
}
