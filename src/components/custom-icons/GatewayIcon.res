@react.component
let make = (~gateway, ~className="w-14 h-14") => {
  let imagePath = `/assets/Gateway`

  <img alt={`${gateway}`} className src={`${imagePath}/${gateway}.svg`} />
}
