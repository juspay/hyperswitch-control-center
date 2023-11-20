@react.component
let make = (~addParam="", ~getDateCreatedObject=?, ~children) => {
  let urlUpdated = AnalyticsUtils.useFilterUrlUpdater(~addParam, ~getDateCreatedObject?, ())

  if urlUpdated {
    children
  } else {
    <Loader />
  }
}
