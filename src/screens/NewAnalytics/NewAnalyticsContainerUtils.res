open NewAnalyticsTypes

let tabs: array<Tabs.tab> = [
  {
    title: "Payments",
    renderContent: () =>
      <div className="mt-5">
        <NewPaymentAnalytics />
      </div>,
  },
]

let getPageVariant = string => {
  switch string {
  | "new-analytics-payment" | _ => NewAnalyticsPayment
  }
}

let getPageIndex = (url: RescriptReactRouter.url) => {
  switch url.path->HSwitchUtils.urlPath {
  | list{"new-analytics-payment"} | _ => 0
  }
}

let getPageFromIndex = index => {
  switch index {
  | 1 | _ => NewAnalyticsPayment
  }
}
