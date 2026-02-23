open VaultHomeTypes
open VerticalStepIndicatorTypes

module VaultActionItem = {
  @react.component
  let make = (~heading, ~img, ~action) => {
    let mixpanelEvent = MixpanelHook.useSendEvent()
    <div
      className="border rounded-xl p-3 flex items-center gap-4 group cursor-pointer justify-between py-3"
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
        </div>
      </div>
      <Icon name="nd-angle-right" size={16} className="group-hover:scale-125" />
    </div>
  }
}
let vaultActionArray = {
  [
    {
      heading: "If non PCI compliant, learn to tokenize using our Vault SDK",
      imgSrc: "/assets/VaultSdkImage.svg",
      action: ExternalLink({
        url: "https://docs.hyperswitch.io/about-hyperswitch/payments-modules/vault/vault-sdk-integration",
        trackingEvent: "vault-sdk-redirect",
      }),
    },
    {
      heading: "If PCI compliant, learn to tokenize directly from your server",
      imgSrc: "/assets/VaultServerImage.svg",
      action: ExternalLink({
        url: "https://docs.hyperswitch.io/about-hyperswitch/payments-modules/vault/server-to-server-vault-tokenization",
        trackingEvent: "vault-server-redirect",
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
let getSectionVariant = ({sectionId}) => {
  switch sectionId {
  | "AuthenticateProcessor" => #AuthenticateProcessor
  | "SetupPmts" => #SetupPmts
  | "SetupWebhook" => #SetupWebhook
  | "ReviewAndConnect" | _ => #ReviewAndConnect
  }
}
let getVaultMixPanelEvent = currentStep => {
  switch currentStep->getSectionVariant {
  | #AuthenticateProcessor => "vault_onboarding_step1"
  | #SetupPmts => "vault_onboarding_step2"
  | #SetupWebhook => "vault_onboarding_step3"
  | #ReviewAndConnect => "vault_onboarding_step4"
  }
}

let getVaultMixpanelEventName = (~isOrchestrationVault, ~eventName) => {
  isOrchestrationVault ? `orchestration_${eventName}` : eventName
}
