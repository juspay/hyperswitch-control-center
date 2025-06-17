type featureProps = {
  title: string,
  description: string,
  iconSrc: string,
  bgColor: string,
  altText: string,
}

module FeatureCard = {
  @react.component
  let make = (~props: featureProps) => {
    <div className="flex gap-5 items-center text-center">
      <div className={props.bgColor ++ " px-2.5 py-2 rounded-lg -mt-3"}>
        <img className="h-6 w-6" src={props.iconSrc} alt={props.altText} />
      </div>
      <div className="flex flex-col">
        <h3 className="text-lg font-semibold mt-4 text-start"> {props.title->React.string} </h3>
        <p className="text-gray-500 text-start"> {props.description->React.string} </p>
      </div>
    </div>
  }
}

let features = [
  {
    title: "ML-Powered Retry Engine",
    description: "Minimizes recurring payment failures using data and machine learning for optimized retries.",
    iconSrc: "/icons/ml-powered-retry-icon.svg",
    bgColor: "bg-nd_orange-50",
    altText: "ML-Powered Retry Engine",
  },
  {
    title: "Reduce Involuntary Churn",
    description: "Improves retention by recovering failed payments that would otherwise lead to churn.",
    iconSrc: "/icons/reduce-churn-icon.svg",
    bgColor: "bg-nd_purple-50",
    altText: "Reduce Involuntary Churn",
  },
  {
    title: "Configurable Retry Strategies",
    description: "Customize recovery plans via dashboard with 20+ parameters.",
    iconSrc: "/icons/configurable-strategies-icon.svg",
    bgColor: "bg-nd_purple-50",
    altText: "Configurable Retry Strategies",
  },
  {
    title: "Smart Retry Optimization",
    description: "Targets specific errors and subscription types for maximum success.",
    iconSrc: "/icons/smart-optimization-icon.svg",
    bgColor: "bg-nd_green-10",
    altText: "Smart Retry Optimization",
  },
]

@react.component
let make = () => {
  open PageUtils
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let {setCreateNewMerchant} = React.useContext(ProductSelectionProvider.defaultContext)
  let userHasCreateMerchantAccess = OMPCreateAccessHook.useOMPCreateAccessHook([
    #tenant_admin,
    #org_admin,
  ])

  <div className="flex flex-1 flex-col gap-14 items-center justify-center w-full h-=fit">
    <img className="h-80 mt-12" alt="recoveryOnboarging" src="/assets/recovery-intro.png" />
    <div className="flex flex-col gap-7 items-center">
      <PageHeading
        customHeadingStyle="flex flex-col items-center -mt-5"
        title="Recover Lost Revenue & Minimize Churn"
        customTitleStyle="text-2xl text-center font-bold"
        customSubTitleStyle="text-fs-16 font-normal text-center max-w-700"
        subTitle="Harness smart retry strategies to automatically recover failed payments and protect your subscription revenue."
      />
      <ACLButton
        authorization={userHasCreateMerchantAccess}
        text={"Explore Recovery"}
        onClick={_ => {
          mixpanelEvent(~eventName="recovery_get_started_new_merchant")
          setCreateNewMerchant(ProductTypes.Recovery)
        }}
        buttonType=Primary
        buttonSize=Large
        buttonState=Normal
      />
      <div className="grid grid-cols-2 gap-10 mt-5 px-16">
        {features->Array.map(feature => <FeatureCard props=feature />)->React.array}
      </div>
    </div>
  </div>
}
