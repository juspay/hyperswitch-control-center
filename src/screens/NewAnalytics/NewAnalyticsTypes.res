type analyticsPages = Overview | Payment

type analyticsPagesRoutes =
  | @as("new-analytics-overview") NewAnalyticsOverview
  | @as("new-analytics-payment") NewAnalyticsPayment

let getPageIndex = (url: RescriptReactRouter.url) => {
  switch url.path->HSwitchUtils.urlPath {
  | list{"new-analytics-payment"} => 1
  | _ => 0
  }
}

let getPageFromIndex = index => {
  switch index {
  | 1 => NewAnalyticsPayment
  | _ => NewAnalyticsOverview
  }
}
