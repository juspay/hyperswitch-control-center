open VaultHomeTypes
open VerticalStepIndicatorTypes
module VaultActionItem = {
  @react.component
  let make = (~heading, ~description, ~img, ~action) => {
    let mixpanelEvent = MixpanelHook.useSendEvent()
    <div
      className="border rounded-xl p-3 flex items-center gap-4 shadow-cardShadow group cursor-pointer justify-between py-4"
      onClick={_ => {
        switch action {
        | InternalRoute(route) =>
          RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url=route))
        | ExternalLink({url, trackingEvent}) => {
            mixpanelEvent(~eventName=trackingEvent)
            url->Window._open
          }
        }
      }}>
      <div className="flex items-center gap-2">
        <img alt={heading} src={img} />
        <div className="flex flex-col gap-1">
          <p className="text-sm text-gray-600 font-semibold"> {{heading}->React.string} </p>
          <p className="text-xs text-gray-400 font-medium"> {{description}->React.string} </p>
        </div>
      </div>
      <Icon name="nd-angle-right" size={16} className="group-hover:scale-125" />
    </div>
  }
}
let vaultActionArray = {
  [
    {
      heading: "Learn how to vault from your server",
      description: "If you're PCI compliant, you can vault cards directly to Hyperswitch's Vault service from your server.",
      imgSrc: "/assets/VaultServerImage.svg",
      action: InternalRoute("v2/vault/home"), //TODO: TO be updated once routing is confirmed
    },
    {
      heading: "Learn using Hyperswitch vault SDK",
      description: "If you're not PCI compliant, securely store cards using our Vault SDK with Hyperswitch's Vault service.",
      imgSrc: "/assets/VaultSdkImage.svg",
      action: InternalRoute("v2/vault/home"), //TODO: TO be updated once routing is confirmed
    },
  ]
}

let sections = [
  {
    id: "authenticate-processor",
    name: "Authenticate your processor",
    icon: "nd-shield",
    subSections: None,
  },
  {
    id: "setup-pmts",
    name: "Setup Payment Methods",
    icon: "nd-webhook",
    subSections: None,
  },
  {
    id: "setup-webhook",
    name: "Setup Webhook",
    icon: "nd-webhook",
    subSections: None,
  },
  {
    id: "review-and-connect",
    name: "Review and Connect",
    icon: "nd-flag",
    subSections: None,
  },
]
