@react.component
let make = (~gateway, ~className="w-14 h-14") => {
  let imagePath = `/Gateway`

  <img alt="image" className src={`${imagePath}/${gateway}.svg`} />
}
