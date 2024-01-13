@react.component
let make = (~icons, ~size) => {
  let (isActive, setIsActive) = React.useState(_ => false)
  let ratingInput = ReactFinalForm.useField("rating").input
  let rating = ratingInput.value->LogicUtils.getIntFromJson(1)

  let handleClick = ratingNumber => {
    ratingInput.onChange(ratingNumber->Identity.anyTypeToReactEvent)
    setIsActive(_ => true)
  }

  <div className="flex flex-row justify-evenly py-5">
    {icons
    ->Array.mapWithIndex((icon, index) => {
      let iconRating = index + 1
      <Icon
        key={Belt.Int.toString(index)}
        className={isActive && rating === iconRating
          ? "rounded-full text-yellow-500"
          : "rounded-full text-gray-400 hover:text-yellow-500"}
        name=icon
        size
        onClick={_ => handleClick(iconRating)}
      />
    })
    ->React.array}
  </div>
}
