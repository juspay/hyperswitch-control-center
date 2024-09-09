@react.component
let make = () => {
  open NewAnalyticsUtils
  open NewAnalyticsTypes
  let url = RescriptReactRouter.useUrl()
  let (tabIndex, setTabIndex) = React.useState(_ => url->getPageIndex)

  React.useEffect(() => {
    let url = (getPageFromIndex(tabIndex) :> string)
    RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url))
    None
  }, [tabIndex])

  <div>
    <PageUtils.PageHeading title="Analytics" />
    <Tabs
      initialIndex={url->getPageIndex}
      tabs
      disableIndicationArrow=true
      showBorder=true
      includeMargin=false
      lightThemeColor="black"
      defaultClasses="font-ibm-plex w-max flex flex-auto flex-row items-center justify-center px-6 font-semibold text-body"
      onTitleClick={tabId => setTabIndex(_ => tabId)}
    />
  </div>
}
