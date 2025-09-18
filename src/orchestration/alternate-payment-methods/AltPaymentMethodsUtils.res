open AltPaymentMethodsType
let alternatePaymentConfiguration = [
  {
    heading: "Enable Connectors & APMs",
    description: <span>
      {"Connect to your preferred payment providers and activate options like PayPal, Apple Pay, and other popular alternate payment methods."->React.string}
    </span>,
    buttonText: "Configure it",
    action: InternalRoute("/connectors"),
  },
  {
    heading: "Integrate Hyperwidgets: Dual Checkout Experience",
    description: <div className="flex flex-col gap-4">
      <ul className="list-disc pl-4 flex flex-col gap-2 mt-2">
        <li>
          <span className="font-bold"> {"Unified Checkout"->React.string} </span>
          {": Access all supported APMs through our standard integration within your checkout flow"->React.string}
        </li>
        <li>
          <span className="font-bold"> {"Express Checkout"->React.string} </span>
          {": Enable one-click purchasing with automatic shipping information retrieval before customers reach checkout"->React.string}
        </li>
      </ul>
    </div>,
    buttonText: "Learn More",
    action: ExternalLink({
      url: "https://docs.hyperswitch.io/explore-hyperswitch/merchant-controls/integration-guide/web/node-and-react",
      trackingEvent: "dev_docs",
    }),
  },
  {
    heading: "Customize SDK Integration",
    description: <span>
      {"Tailor the SDK to your specific needs and branding for a consistent user experience."->React.string}
    </span>,
    buttonText: "Customize SDK",
    action: ExternalLink({
      url: "https://docs.hyperswitch.io/explore-hyperswitch/merchant-controls/integration-guide/web/customization",
      trackingEvent: "dev_docs",
    }),
  },
  {
    heading: "Enable Automatic Tax Calculation",
    description: <span>
      {"Ensure accurate and dynamic tax collection for Express Checkout wallets using TaxJar."->React.string}
    </span>,
    buttonText: "Setup TaxJar",
    action: ExternalLink({
      url: "https://docs.hyperswitch.io/explore-hyperswitch/e-commerce-platform-plugins/automatic-tax-calculation-for-express-checkout-wallets",
      trackingEvent: "dev_docs",
    }),
  },
]
module APMConfigureStep = {
  @react.component
  let make = (~index, ~heading, ~description, ~action, ~buttonText) => {
    let mixpanelEvent = MixpanelHook.useSendEvent()
    <div
      className="flex flex-row gap-10 items-center justify-between p-4 rounded-xl shadow-cardShadow border border-nd_br_gray-500 cursor-pointer">
      <div className="flex flex-row gap-4 items-start w-3/4">
        <div
          className="w-6 h-6 rounded-full bg-nd_gray-150 flex items-center justify-center text-sm p-1 text-nd_gray-600 font-semibold">
          {(index + 1)->React.int}
        </div>
        <div className="w-full gap-4 ">
          <div className="flex flex-col gap-1">
            <span className="text-fs-16 text-nd_gray-700 font-semibold leading-24">
              {heading->React.string}
            </span>
            <span className="text-fs-14 text-nd_gray-500 font-medium"> {description} </span>
          </div>
        </div>
      </div>
      <Button
        text=buttonText
        buttonType={Secondary}
        buttonSize={Medium}
        customButtonStyle="w-44"
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
