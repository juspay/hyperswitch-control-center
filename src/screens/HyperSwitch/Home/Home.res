@react.component
let make = () => {
  open HomeUtils
  open PageUtils
  let greeting = getGreeting()

  <div className="w-full gap-3 flex flex-col">
    <PageHeading
      title={`${greeting}, it's great to see you!`}
      subTitle="Welcome to the home of your Payments Control Centre. It aims at providing your team with a 360-degree view of payments."
    />
    <ControlCenter />
    <DevResources />
  </div>
}
