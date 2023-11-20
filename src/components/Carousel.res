@react.component
let make = (~imgArr) => {
  let (ind, setInd) = React.useState(_ => 0)
  let next = _ev => {
    setInd(ind => mod(ind + 1, imgArr->Js.Array2.length))
  }
  let prev = _ev => {
    setInd(ind => ind == 0 ? imgArr->Js.Array2.length - 1 : ind - 1)
  }

  <div className="flex flex-row w-full">
    <Icon name="angle-left" onClick=prev />
    {<> {imgArr->Belt.Array.get(ind)->Belt.Option.getWithDefault(React.null)} </>}
    <Icon name="angle-right" onClick=next />
  </div>
}
