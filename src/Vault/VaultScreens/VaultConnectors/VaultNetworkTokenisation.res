@react.component
let make = () => {
  let (toggleState, setToggleState) = React.useState(_ => false)

  <div className="mt-10 flex flex-col gap-2">
    <div className="flex flex-row  justify-between items-center">
      <p className="font-semibold text-lg text-nd_gray-600">
        {"Network Tokenization"->React.string}
      </p>
      <BoolInput.BaseComponent
        isSelected=toggleState
        setIsSelected={_ => setToggleState(prev => !prev)}
        boolCustomClass="rounded-xl"
        toggleEnableColor="bg-primary"
        customToggleHeight="20px"
        customToggleWidth="36px"
        customInnerCircleHeight="16px"
        transformValue="18px"
        isDisabled=true
      />
    </div>
    <div className="font-medium text-nd_gray-400 w-3/4">
      {"Network Tokenization enables secure card storage and seamless future transactions, with Juspay as the Token Requestor–Token Service Provider (TR-TSP). To enable this feature for your merchant account, please reach out to us on "->React.string}
      <a
        href="https://hyperswitch-io.slack.com/?redir=%2Fssb%2Fredirect"
        className="text-primary hover:cursor-pointer hover:underline"
        target="_blank">
        {"Slack"->React.string}
      </a>
    </div>
  </div>
}
