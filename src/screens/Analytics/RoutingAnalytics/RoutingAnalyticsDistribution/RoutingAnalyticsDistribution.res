@react.component
let make = () => {
  <div>
    <PageUtils.PageHeading
      title="Distribution"
      customHeadingStyle="flex flex-col mb-6 "
      customTitleStyle="!text-fs-16 font-semibold text-nd_gray-800 "
    />
    <div className="grid xl:grid-cols-2 gap-2 grid-cols-1">
      <RoutingAnalyticsDistributionConnectorVolume />
      <RoutingAnalyticsDistributionRoutingApproach />
    </div>
  </div>
}
