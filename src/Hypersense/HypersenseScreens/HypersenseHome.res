module FeatureBlock = {
  @react.component
  let make = (~iconName, ~iconClass, ~title, ~description) => {
    <div className="flex items-start gap-4">
      <div
        className={`flex h-8 w-8 shrink-0 items-center justify-center rounded-md ${iconClass}`}>
        <Icon name=iconName size=16 />
      </div>
      <div className="flex flex-col gap-0.5">
        <p className="text-fs-14 leading-5 font-semibold text-nd_gray-600">
          {title->React.string}
        </p>
        <p className="text-fs-14 leading-5 font-medium text-nd_gray-400">
          {description->React.string}
        </p>
      </div>
    </div>
  }
}

@react.component
let make = () => {
  open APIUtils
  open LogicUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let mixpanelEvent = MixpanelHook.useSendEvent()

  let onExploreClick = async () => {
    let hypersenseTokenUrl = getURL(
      ~entityName=V1(HYPERSENSE),
      ~methodType=Get,
      ~hypersenseType=#TOKEN,
    )
    let res = await fetchDetails(hypersenseTokenUrl)
    let token = res->getDictFromJsonObject->getString("token", "")
    mixpanelEvent(~eventName="cost_observability-redirect")
    let url = `${Window.env.hypersenseUrl}?auth_token=${token}`
    url->Window._open
  }

  <div className="min-h-screen w-full overflow-y-auto bg-white">
    <div className="mx-auto flex w-full max-w-[933px] flex-col items-center gap-16 px-4 py-12">
      <div className="flex w-full max-w-[877px] flex-col items-center gap-5">
        <object
          className="h-[360px] w-auto object-contain"
          type_="image/svg+xml"
          data="/assets/DefaultHomeHypersenseCard.svg"
          alt="hypersenseOnboarding"
        />
        <div className="flex w-full flex-col items-center gap-10">
          <div className="flex flex-col items-center gap-2.5 text-center">
            <p className="text-fs-24 font-semibold text-nd_gray-700">
              {"Gain Control & Optimize Payment Costs"->React.string}
            </p>
            <p className="text-fs-16 font-medium text-nd_gray-500">
              {"Reduce your payment processing costs by up to 10%"->React.string}
            </p>
          </div>
          <Button
            text="Explore Cost Observability"
            onClick={_ => {
              mixpanelEvent(~eventName="cost_observability_explore")
              onExploreClick()->ignore
            }}
            customTextPaddingClass="pr-0"
            rightIcon={CustomIcon(
              <Icon name="nd-angle-right" size=16 className="cursor-pointer" />,
            )}
            buttonType=Primary
            buttonSize=Medium
            buttonState=Normal
          />
        </div>
      </div>
      <div className="grid w-full max-w-[877px] grid-cols-1 gap-10 px-7 md:grid-cols-2">
        <FeatureBlock
          iconName="clock"
          iconClass="bg-orange-50 text-orange-600"
          title="Track Every Dollar"
          description="Access a unified, drill-down view of your payment costs. Compare costs across Providers, payment methods, regions and uncover what's driving your spend"
        />
        <FeatureBlock
          iconName="file-icon"
          iconClass="bg-purple-50 text-purple-600"
          title="Audit Your Invoices"
          description="Perform integrity check on your invoices seamlessly, verify your fee markups and contractual discounts with providers"
        />
        <FeatureBlock
          iconName="nd-piggy-bank"
          iconClass="bg-pink-50 text-pink-600"
          title="Optimize Your Payment Fees"
          description="Identify unexpected cost spikes and understand detailed root causes to take decisive actions and avoid unnecessary costs"
        />
        <FeatureBlock
          iconName="nd-analytics"
          iconClass="bg-teal-50 text-teal-600"
          title="Forecast Impact of Network Changes"
          description="Get clear insights into upcoming card network fee changes. Break down what's changing, how it affects your costs, and prepare your business accordingly"
        />
      </div>
    </div>
  </div>
}
