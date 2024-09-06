let tabs: array<Tabs.tab> = [
  {
    title: "Overview",
    renderContent: () => <div className="mt-5"> {"Overview page"->React.string} </div>,
  },
  {
    title: "Payments",
    renderContent: () => <div className="mt-5"> {"Payments page"->React.string} </div>,
  },
]
