@react.component
let make = () => {
  let screenState = PageLoaderWrapper.Success
  <PageLoaderWrapper screenState>
    <div className="routing-analytics-page">
      <PageUtils.PageHeading
        title="Routing Analytics"
        subTitle="Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt"
      />
      /* Stats Cards Row */
      <div className="stats-cards-row"> {React.null} </div>
      /* Distribution Section */
      <div className="distribution-section"> {React.null} </div>
      /* Summary Table Section */
      <div className="summary-table-section"> {React.null} </div>
      /* Time Series Section */
      <div className="time-series-section"> {React.null} </div>
    </div>
  </PageLoaderWrapper>
}
