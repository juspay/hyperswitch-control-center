@react.component
let make = () => {
  let (toggleState, setToggleState) = React.useState(_ => true)

  <div className="mt-10 flex flex-col gap-2">
    <div className="flex flex-row  justify-between items-center">
      <p className="font-semibold text-lg text-nd_gray-600">
        {"Network Tokenization"->React.string}
      </p>
      <BoolInput.BaseComponent
        isSelected=toggleState
        setIsSelected={_ => setToggleState(p => !p)}
        boolCustomClass="rounded-xl"
        toggleEnableColor="bg-primary"
        toggleHeight="20px"
        toggleWidth="36px"
        innerCircleHeight="16px"
        transformValue="18px"
        isDisabled=true
      />
    </div>
    <div className="font-medium text-nd_gray-400">
      {"Network Tokenization is enabled for your merchant account with Juspay as the token requestor, ensuring secure and seamless card storage for future transactions"->React.string}
    </div>
  </div>
}
