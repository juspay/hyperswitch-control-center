type productDetailCards = {
  product: ProductTypes.productTypes,
  heading: string,
  description: string,
  imgSrc: string,
  route: string,
}
type defaultActionCards = {
  heading: string,
  description: string,
  imgSrc: string,
}
module DefaultActionItem = {
  @react.component
  let make = (~heading, ~description, ~img) => {
    <div
      className="border rounded-xl p-3 flex items-center gap-4 shadow-cardShadow group cursor-pointer w-334-px justify-between py-4">
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
  let make = (~heading, ~description, ~img, ~route) => {
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
          RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url={route}))
        }}
      />
    </div>
  }
}

let defaultHomeActionArray: array<defaultActionCards> = {
  [
    {
      heading: "Set up API Keys",
      description: "One Liner about this task",
      imgSrc: "/assets/VaultServerImage.svg",
    },
    {
      heading: "Invite your team",
      description: "One Liner about this task",
      imgSrc: "/assets/DefaultHomeTeam.svg",
    },
    {
      heading: "Developer Docs",
      description: "One Liner about this task",
      imgSrc: "/assets/VaultSdkImage.svg",
    },
  ]
}
let defaultHomeCardsArray = {
  [
    {
      product: Vault,
      heading: "Vault",
      description: "A modular solution designed to unify various abstractions, seamlessly connecting with payment processors, payout processors, fraud management, tax automation, identity solutions, and reporting systems.",
      imgSrc: "/assets/DefaultHomeVaultCard.svg",
      route: "v2/vault/configuration",
    },
    {
      product: Recon,
      heading: "Recon",
      description: "A robust tool for efficient reconciliation, providing real-time matching and error detection across transactions, ensuring data consistency and accuracy in financial operations.",
      imgSrc: "/assets/DefaultHomeReconCard.svg",
      route: "v2/recon/onboarding",
    },
    {
      product: Orchestrator,
      heading: "Orchestrator",
      description: "Unified the divers abstractions to connect with payment processors, payout processors, fraud management solutions, tax automation solutions, identity solutions and reporting systems",
      imgSrc: "/assets/DefaultHomeVaultCard.svg",
      route: "dashboard/home",
    },
    {
      product: Recovery,
      heading: "Recovery",
      description: "A resilient recovery system that ensures seamless restoration of critical data and transactions, safeguarding against unexpected disruptions and minimizing downtime.",
      imgSrc: "/assets/DefaultHomeRecoveryCard.svg",
      route: "v2/recovery",
    },
  ]
}
