@react.component
let make = (~currentRoute, ~markAsDone) => {
  open UserOnboardingTypes
  <div className="w-full h-full flex items-center justify-center">
    {switch currentRoute {
    | MigrateFromStripe
    | IntegrateFromScratch
    | SampleProjects =>
      <IntegrationDocsPage currentRoute markAsDone />
    | WooCommercePlugin => <IntegrationDocsPage currentRoute markAsDone languageSelection=false />
    | _ => React.null
    }}
  </div>
}
