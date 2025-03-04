open VaultHomeTypes
open VerticalStepIndicatorTypes

module VaultActionItem = {
  @react.component
  let make = (~heading, ~description, ~img, ~action) => {
    let mixpanelEvent = MixpanelHook.useSendEvent()
    <div
      className="border rounded-xl p-3 flex items-center gap-4 group cursor-pointer justify-between py-4"
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
          <p className="text-sm text-nd_gray-600 font-semibold"> {{heading}->React.string} </p>
          <p className="text-xs text-nd_gray-400 font-medium"> {{description}->React.string} </p>
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
      action: ExternalLink({
        url: "https://docs.hyperswitch.io/about-hyperswitch/payments-modules/vault",
        trackingEvent: "vault-server-redirect",
      }),
    },
    {
      heading: "Learn how to vault using our Vault SDK",
      description: "If you're not PCI compliant, securely store cards using our Vault SDK with Hyperswitch's Vault service.",
      imgSrc: "/assets/VaultSdkImage.svg",
      action: ExternalLink({
        url: "https://docs.hyperswitch.io/about-hyperswitch/payments-modules/vault",
        trackingEvent: "vault-sdk-redirect",
      }),
    },
  ]
}

let sections = [
  {
    id: (#authenticateProcessor: vaultSections :> string),
    name: "Authenticate your processor",
    icon: "nd-shield",
    subSections: None,
  },
  {
    id: (#setupPMTS: vaultSections :> string),
    name: "Setup Payment Methods",
    icon: "nd-webhook",
    subSections: None,
  },
  {
    id: (#setupWebhook: vaultSections :> string),
    name: "Setup Webhook",
    icon: "nd-webhook",
    subSections: None,
  },
  {
    id: (#reviewAndConnect: vaultSections :> string),
    name: "Review and Connect",
    icon: "nd-flag",
    subSections: None,
  },
]

let stringToSectionVariantMapper = string => {
  switch string {
  | "authenticateProcessor" => #authenticateProcessor
  | "setupPMTS" => #setupPMTS
  | "setupWebhook" => #setupWebhook
  | "reviewAndConnect" => #reviewAndConnect
  | _ => #authenticateProcessor
  }
}
