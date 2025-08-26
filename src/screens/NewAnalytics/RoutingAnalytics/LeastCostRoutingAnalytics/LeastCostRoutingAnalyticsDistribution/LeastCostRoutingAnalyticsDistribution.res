@react.component
let make = () => {

  open Typography

  <div className="mt-4">
    <PageUtils.PageHeading
      title="Distribution"
      subTitle="View payment distributions to quickly identify trends."
      customHeadingStyle="flex flex-col mb-6 "
      customTitleStyle={`!${body.lg.semibold} text-nd_gray-800`}
      customSubTitleStyle={`${body.md.medium} text-nd_gray-400 !opacity-100 !mt-1`}
    />
    <div className="grid gap-2 grid-cols-2">
      <LeastCostRoutingAnalyticsDistributionPieGraph />
      <LeastCostRoutingAnalyticsSavingsOverTime />
    </div>
  </div>
}
