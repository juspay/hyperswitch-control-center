open Typography

@react.component
let make = () => {
  open PageUtils

  <PageHeading
    title="Pipeline Details"
    subTitle="Manage your data pipelines and monitor their performance."
    customTitleStyle={`${heading.lg.semibold}`}
    customSubTitleStyle={`${body.lg.medium}`}
    customHeadingStyle="mb-6"
  />
}
