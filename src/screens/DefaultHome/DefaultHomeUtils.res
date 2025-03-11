open DefaultHomeTypes
module DefaultActionItem = {
  @react.component
  let make = (~heading, ~description, ~img, ~action) => {
    let mixpanelEvent = MixpanelHook.useSendEvent()
    <div
      className="border rounded-xl p-3 flex items-center gap-4 shadow-cardShadow group cursor-pointer w-334-px justify-between py-4"
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
module DefaultHomeCard = {
  @react.component
  let make = (~heading, ~description, ~img, ~action) => {
    let mixpanelEvent = MixpanelHook.useSendEvent()
    <div
      className="w-499-px p-3 gap-4 rounded-xl flex flex-col shadow-cardShadow border border-nd_br_gray-500">
      <img className="w-full h-195-px object-cover rounded-xl" src={img} />
      <div className="flex flex-col p-2 gap-1">
        <span className="text-fs-16 text-nd_gray-600 font-semibold leading-24">
          {heading->React.string}
        </span>
        <span className="text-fs-14 text-nd_gray-400 font-medium">
          {description->React.string}
        </span>
      </div>
      <Button
        text="Learn More"
        buttonType={Secondary}
        buttonSize={Medium}
        customButtonStyle="w-full"
        onClick={_ => {
          switch action {
          | InternalRoute(route) =>
            RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url=route))
          | ExternalLink({url, trackingEvent}) => {
              mixpanelEvent(~eventName=trackingEvent)
              url->Window._open
            }
          }
        }}
      />
    </div>
  }
}

let defaultHomeActionArray = {
  [
    {
      heading: "Set up API Keys",
      description: "Configure API keys and start integrating.",
      imgSrc: "/assets/VaultServerImage.svg",
      action: InternalRoute("developer-api-keys"),
    },
    {
      heading: "Invite your team",
      description: "Invite your team to collaborate.",
      imgSrc: "/assets/DefaultHomeTeam.svg",
      action: InternalRoute("users"),
    },
    {
      heading: "Developer Docs",
      description: "Dive into the dev docs and start building",
      imgSrc: "/assets/VaultSdkImage.svg",
      action: ExternalLink({
        url: "https://hyperswitch.io/docs",
        trackingEvent: "dev_docs",
      }),
    },
  ]
}
let defaultHomeCardsArray = {
  [
    {
      product: Orchestrator,
      heading: "Orchestrator",
      description: "Unified the diverse abstractions to connect with payment processors, payout processors, fraud management solutions, tax automation solutions, identity solutions and reporting systems",
      imgSrc: "/assets/DefaultHomeVaultCard.svg",
      action: InternalRoute("home"),
    },
    {
      product: Vault,
      heading: "Vault",
      description: "A modular solution designed to unify various abstractions, seamlessly connecting with payment processors, payout processors, fraud management, tax automation, identity solutions, and reporting systems.",
      imgSrc: "/assets/DefaultHomeVaultCard.svg",
      action: InternalRoute("v2/vault"),
    },
    {
      product: Recon,
      heading: "Recon",
      description: "A robust tool for efficient reconciliation, providing real-time matching and error detection across transactions, ensuring data consistency and accuracy in financial operations.",
      imgSrc: "/assets/DefaultHomeReconCard.svg",
      action: InternalRoute("v2/recon/onboarding"),
    },
    {
      product: Recovery,
      heading: "Recovery",
      description: "A resilient recovery system that ensures seamless restoration of critical data and transactions, safeguarding against unexpected disruptions and minimizing downtime.",
      imgSrc: "/assets/DefaultHomeRecoveryCard.svg",
      action: InternalRoute("v2/recovery"),
    },
  ]
}
