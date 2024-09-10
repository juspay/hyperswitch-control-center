@react.component
let make = (~entity) => {
  open NewAnalyticsTypes
  open NewAnalyticsUtils
  open LineGraphUtils

  <div>
    <h2 className="font-[600] text-xl text-[#333333] pb-5"> {entity.title->React.string} </h2>
    <Card>
      <div className="mr-3 my-10">
        <Highcharts.Chart options highcharts={Highcharts.highcharts} />
      </div>
    </Card>
  </div>
}
