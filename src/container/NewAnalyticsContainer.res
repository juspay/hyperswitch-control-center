@react.component
let make = () => {
  open NewAnalyticsUtils
  let (_tabIndex, setTabIndex) = React.useState(_ => 0)

  <div>
    <PageUtils.PageHeading title="Analytics" />
    <Tabs
      tabs
      disableIndicationArrow=true
      showBorder=false
      includeMargin=false
      lightThemeColor="black"
      defaultClasses="font-ibm-plex w-max flex flex-auto flex-row items-center justify-center px-6 font-semibold text-body"
      onTitleClick={tabId => setTabIndex(_ => tabId)}
    />
  </div>
}
