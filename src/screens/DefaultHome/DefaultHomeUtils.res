open DefaultHomeTypes
module DefaultActionItem = {
  @react.component
  let make = (~heading, ~description, ~img, ~action) => {
    let mixpanelEvent = MixpanelHook.useSendEvent()
    <div
      className="border rounded-xl p-3 flex items-center gap-4 shadow-cardShadow group cursor-pointer w-full justify-between py-4"
      onClick={_ => {
        switch action {
        | ExternalLink({url, trackingEvent}) => {
            mixpanelEvent(~eventName=trackingEvent)
            url->Window._open
          }
        | _ => ()
        }
      }}>
      <div className="flex items-center gap-2">
        <img alt={heading} src={img} />
        <div className="flex flex-col gap-1">
          <p className="text-sm text-nd_gray-600 font-semibold"> {{heading}->React.string} </p>
          <p className="text-xs text-nd_gray-400 font-medium"> {{description}->React.string} </p>
        </div>
      </div>
      <Icon name="nd-angle-right" size={16} className="group-hover:scale-125" />
    </div>
  }
}
let defaultHomeActionArray = {
  [
    {
      heading: "Product and tech blog",
      description: "Learn about payments, payment orchestration and all the tech behind it.",
      imgSrc: "/assets/DefaultHomeTeam.svg",
      action: ExternalLink({
        url: "https://hyperswitch.io/blog",
        trackingEvent: "dev_docs",
      }),
    },
    {
      heading: "Developer Docs",
      description: "Dive into the dev docs and start building.",
      imgSrc: "/assets/VaultSdkImage.svg",
      action: ExternalLink({
        url: "https://hyperswitch.io/docs",
        trackingEvent: "dev_docs",
      }),
    },
  ]
}
