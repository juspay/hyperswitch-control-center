@react.component
let make = () => {
  open GlobalSearchBarUtils

  React.useEffect0(() => {
    Js.log2(">>", sessionStorage.getItem(. "results"))
    None
  })

  <div>
    <PageUtils.PageHeading title="Search results" />
    {"Search results"->React.string}
  </div>
}
