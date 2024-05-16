@react.component
let make = (~errorMessage, ~onClick, ~trasitionMessage) => {
  if errorMessage->String.length !== 0 {
    <CommonAuthError onClick />
  } else {
    <HSwitchUtils.BackgroundImageWrapper customPageCss="font-semibold md:text-3xl p-16">
      <div className="h-full w-full flex justify-center items-center text-white opacity-90">
        {trasitionMessage->React.string}
      </div>
    </HSwitchUtils.BackgroundImageWrapper>
  }
}
