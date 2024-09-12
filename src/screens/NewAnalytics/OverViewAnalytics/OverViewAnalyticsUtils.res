let paymentsProcessedMapper = (_json): LineGraphTypes.lineGraphPayload => {
  open LineGraphTypes
  let categories = [
    "01 Aug",
    "02 Aug",
    "03 Aug",
    "04 Aug",
    "05 Aug",
    "06 Aug",
    "07 Aug",
    "08 Aug",
    "09 Aug",
    "10 Aug",
    "11 Aug",
  ]
  let data = {
    showInLegend: false,
    name: "Series 1",
    data: [3000, 5000, 7000, 5360, 4500, 6800, 5400, 3000, 0, 0],
    color: "#2f7ed8",
  }
  let title = {
    text: "USD",
  }
  {categories, data, title}
}
