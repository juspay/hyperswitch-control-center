@react.component
let make = () => {
  open HomeUtils
  open PageUtils
  open Typography
  let greeting = getGreeting()

  <div className="w-full gap-8 flex flex-col">
    <PageHeading
      title={`${greeting}, it's great to see you!`}
      subTitle="Welcome to the home of your Payments Control Centre. It aims at providing your team with a 360-degree view of payments."
      customTitleStyle="!text-fs-24 !font-semibold"
      customSubTitleStyle={`text-nd_gray-400 !opacity-100 !mt-1 ${body.lg.medium}`}
    />
    <ControlCenter />
    <DevResources />
  </div>
}
