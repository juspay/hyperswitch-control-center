let tabs: array<Tabs.tab> = [
  {
    title: "Overview",
    renderContent: () => <OverViewAnalytics />,
  },
  {
    title: "Payments",
    renderContent: () => <div className="mt-5"> {"Payments page"->React.string} </div>,
  },
]
