@react.component
let make = () => {
  // open LogicUtils

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

  let (tabIndex, setTabIndex) = React.useState(_ => 0)
  let setCurrentTabName = Recoil.useSetRecoilState(HyperswitchAtom.currentTabNameRecoilAtom)

  let getTabName = index => index == 0 ? "All" : "Exceptions"

  React.useEffect(() => {
    setScreenState(_ => PageLoaderWrapper.Success)
    None
  }, [])

  let tabs: array<Tabs.tab> = React.useMemo(() => {
    open Tabs
    [
      {
        title: "All",
        renderContent: () => <ReconReportsList />,
      },
      {
        title: "Exceptions",
        renderContent: () => <ReconExceptionsList />,
      },
    ]
  }, [])

  <div className="flex flex-col space-y-2 justify-center relative">
    <div className="flex justify-between items-center">
      <p className="text-2xl font-semibold text-nd_gray-700">
        {"Reconciliation Reports"->React.string}
      </p>
      <div className="flex" />
    </div>
    <PageLoaderWrapper screenState>
      <div className="flex flex-col relative">
        <Tabs
          initialIndex={tabIndex >= 0 ? tabIndex : 0}
          tabs
          showBorder=false
          includeMargin=false
          lightThemeColor="black"
          defaultClasses="!w-max flex flex-auto flex-row items-center justify-center px-6 font-semibold text-body"
          onTitleClick={indx => {
            setTabIndex(_ => indx)
            setCurrentTabName(_ => getTabName(indx))
          }}
        />
      </div>
    </PageLoaderWrapper>
  </div>
}
