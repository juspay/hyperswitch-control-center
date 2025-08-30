@react.component
let make = () => {
  open Typography

  <div>
    <PageUtils.PageHeading
      title="Routing Distribution"
      subTitle="Get insights into the distribution of routing decisions across different processors and routing logics."
      customHeadingStyle="flex flex-col mb-6 "
      customTitleStyle={`!${body.lg.semibold} text-nd_gray-800`}
      customSubTitleStyle={`${body.md.medium} text-nd_gray-400 !opacity-100 !mt-1`}
    />
    <div className="grid xl:grid-cols-2 gap-2 grid-cols-1">
      <RoutingAnalyticsDistributionConnectorVolume />
      <RoutingAnalyticsDistributionRoutingApproach />
    </div>
  </div>
}
