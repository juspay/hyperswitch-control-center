@react.component
let make = (~currentRoute, ~markAsDone, ~onClickBackHandler=?) => {
  open UserOnboardingTypes
  <>
    {switch currentRoute {
    | MigrateFromStripe
    | IntegrateFromScratch
    | SampleProjects =>
      switch onClickBackHandler {
      | Some(_) => <IntegrationDocsPage currentRoute markAsDone />
      | None => <IntegrationDocsPage currentRoute markAsDone />
      }

    | WooCommercePlugin =>
      switch onClickBackHandler {
      | Some(_) => <IntegrationDocsPage currentRoute markAsDone languageSelection=false />
      | None => <IntegrationDocsPage currentRoute markAsDone languageSelection=false />
      }

    | _ => React.null
    }}
  </>
}
