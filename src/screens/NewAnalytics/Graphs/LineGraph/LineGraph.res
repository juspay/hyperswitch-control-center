@react.component
let make = (~entity) => {
  open NewAnalyticsTypes
  open NewAnalyticsUtils

  let options = JSON.Encode.string("")->entity.getObjects->entity.getChatOptions

  <div>
    <h2 className="font-600 text-xl text-jp-gray-900 pb-5"> {entity.title->React.string} </h2>
    <Card>
      <div className="mr-3 my-10">
        <Highcharts.Chart options highcharts={Highcharts.highcharts} />
      </div>
    </Card>
  </div>
}
