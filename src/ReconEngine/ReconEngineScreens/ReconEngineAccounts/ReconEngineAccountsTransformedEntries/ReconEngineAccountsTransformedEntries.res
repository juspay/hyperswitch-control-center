open Typography

@react.component
let make = () => {
  <PageUtils.PageHeading
    title="Transformed Entries"
    customTitleStyle={`${heading.lg.semibold}`}
    customHeadingStyle="py-0"
  />
}
