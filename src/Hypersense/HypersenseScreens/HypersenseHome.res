open Typography
open HypersenseTypes

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

  <div className="flex flex-1 flex-col gap-6 items-center w-full">
    <object
      type_="image/svg+xml"
      data="/assets/CostObservabilityHomePreview.svg"
      className="w-full sm:w-4/5 rounded-2xl"
      ariaLabel="Cost Observability Dashboard Preview"
    />
    <div className="flex flex-col gap-4 items-center">
      <div className="flex flex-col gap-2 items-center">
        <p className={`${heading.md.bold} text-center text-nd_gray-700`}>
          {"Gain Control & Optimize Payment Costs"->React.string}
        </p>
        <p className={`${body.md.regular} text-center text-nd_gray-500 max-w-lg`}>
          {"Reduce your payment processing costs by up to 10%"->React.string}
        </p>
      </div>
      <Button
        text="Explore Cost Observability"
        onClick={_ => {
          mixpanelEvent(~eventName="cost_observability_explore")
          onExploreClick()->ignore
        }}
        buttonType=Primary
        buttonSize=Large
        buttonState=Normal
      />
    </div>
    <div className="grid grid-cols-1 md:grid-cols-2 gap-x-10 gap-y-6 w-full max-w-2xl mt-2">
      {HypersenseUtils.features
      ->Array.map(feature => {
        <div key=feature.title className="flex flex-row gap-3 items-start">
          <div
            className={`${feature.bgColor} rounded-xl w-12 h-12 flex-shrink-0 flex items-center justify-center`}>
            <Icon
              name=feature.icon
              size=28
              className=feature.iconColor
              parentClass="w-full h-full flex items-center justify-center"
            />
          </div>
          <div className="flex flex-col gap-0.5">
            <p className={`${body.md.semibold} text-nd_gray-700`}>
              {feature.title->React.string}
            </p>
            <p className={`${body.sm.regular} text-nd_gray-500`}>
              {feature.description->React.string}
            </p>
          </div>
        </div>
      })
      ->React.array}
    </div>
  </div>
}
