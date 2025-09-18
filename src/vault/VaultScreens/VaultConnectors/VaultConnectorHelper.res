module VaultRequestProcessorCard = {
  @react.component
  let make = () => {
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let handleClick = () => {
      mixpanelEvent(~eventName="vault_request_processor")
      "https://hyperswitch-io.slack.com/?redir=%2Fssb%2Fredirect"->Window._open
    }
    <div
      className="border p-4 bg-white rounded-lg flex flex-col gap-2 h-9.5-rem hover:bg-gray-50 hover:cursor-pointer"
      onClick={_ => handleClick()}>
      <p className={`font-semibold text-fs-16 text-nd_gray-600 break-all`}>
        {"Request a Processor"->React.string}
      </p>
      <div className="flex mt-3 ">
        <p className="overflow-hidden text-nd_gray-400  ">
          {"To enable psp tokenisation through other processors , Click here "->React.string}
        </p>
      </div>
    </div>
  }
}
