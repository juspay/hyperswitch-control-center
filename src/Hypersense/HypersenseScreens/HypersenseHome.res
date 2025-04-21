@react.component
let make = () => {
  open APIUtils
  open LogicUtils
  open PageUtils

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
    let url = `${Window.env.hypersenseUrl}/login?auth_token=${token}`
    url->Window._open
  }

  <div className="flex flex-1 flex-col gap-14 items-center justify-center w-full h-screen">
    <img alt="hypersenseOnboarding" src="/assets/DefaultHomeHypersenseCard.svg" />
    <div className="flex flex-col gap-8 items-center">
      <div
        className="border rounded-md text-nd_green-200 border-nd_green-200 font-semibold p-1.5 text-sm w-fit">
        {"Cost Observability"->React.string}
      </div>
      <PageHeading
        customHeadingStyle="gap-3 flex flex-col items-center"
        title="AI Ops tool built for Payments Cost Observability "
        customTitleStyle="text-2xl text-center font-bold text-nd_gray-700 font-500"
        customSubTitleStyle="text-fs-16 font-normal text-center max-w-700"
        subTitle="Audit, Observe and Optimize payment costs to uncover cost-saving opportunities"
      />
      <Button
        text="Explore Cost Observability"
        onClick={_ => {
          mixpanelEvent(~eventName="cost_observability_explore")
          onExploreClick()->ignore
        }}
        customTextPaddingClass="pr-0"
        rightIcon={CustomIcon(<Icon name="nd-angle-right" size=16 className="cursor-pointer" />)}
        buttonType=Primary
        buttonSize=Large
        buttonState=Normal
      />
    </div>
  </div>
}
