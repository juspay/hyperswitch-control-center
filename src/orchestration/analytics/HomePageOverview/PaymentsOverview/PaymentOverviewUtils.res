open PaymentAnalyticsEntity
open HSAnalyticsUtils

let defaultColumns: array<DynamicSingleStat.columns<colT>> = [
  {
    sectionName: "",
    columns: [
      {
        colType: SuccessRate,
      },
    ],
  },
]

let getSingleStatEntity: ('a, string) => DynamicSingleStat.entityType<'colType, 't, 't2> = (
  metrics,
  uri,
) => {
  urlConfig: [
    {
      uri,
      metrics: metrics->getStringListFromArrayDict,
    },
  ],
  getObjects: itemToObjMapper,
  getTimeSeriesObject: timeSeriesObjMapper,
  defaultColumns,
  getData: getStatData,
  totalVolumeCol: None,
  matrixUriMapper: _ => uri,
}
