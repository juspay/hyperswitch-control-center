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

let getData = {
  "queryData": [
    {"count": 24, "amount": 952, "currency": "USD", "time_bucket": "2024-08-13 18:30:00"},
    {"count": 28, "amount": 1020, "currency": "USD", "time_bucket": "2024-08-14 18:30:00"},
    {"count": 35, "amount": 1450, "currency": "USD", "time_bucket": "2024-08-15 18:30:00"},
    {"count": 30, "amount": 1150, "currency": "USD", "time_bucket": "2024-08-16 18:30:00"},
    {"count": 40, "amount": 1600, "currency": "USD", "time_bucket": "2024-08-17 18:30:00"},
    {"count": 29, "amount": 1200, "currency": "USD", "time_bucket": "2024-08-18 18:30:00"},
    {"count": 31, "amount": 1300, "currency": "USD", "time_bucket": "2024-08-19 18:30:00"},
    {"count": 56, "amount": 3925, "currency": "EUR", "time_bucket": "2024-08-13 18:30:00"},
    {"count": 50, "amount": 3750, "currency": "EUR", "time_bucket": "2024-08-14 18:30:00"},
    {"count": 42, "amount": 3150, "currency": "EUR", "time_bucket": "2024-08-15 18:30:00"},
    {"count": 38, "amount": 2900, "currency": "EUR", "time_bucket": "2024-08-16 18:30:00"},
    {"count": 44, "amount": 3300, "currency": "EUR", "time_bucket": "2024-08-17 18:30:00"},
    {"count": 50, "amount": 3750, "currency": "EUR", "time_bucket": "2024-08-18 18:30:00"},
    {"count": 60, "amount": 4500, "currency": "EUR", "time_bucket": "2024-08-19 18:30:00"},
    {"count": 48, "amount": 3600, "currency": "GBP", "time_bucket": "2024-08-13 18:30:00"},
    {"count": 45, "amount": 3400, "currency": "GBP", "time_bucket": "2024-08-14 18:30:00"},
    {"count": 40, "amount": 3000, "currency": "GBP", "time_bucket": "2024-08-15 18:30:00"},
    {"count": 43, "amount": 3200, "currency": "GBP", "time_bucket": "2024-08-16 18:30:00"},
    {"count": 46, "amount": 3500, "currency": "GBP", "time_bucket": "2024-08-17 18:30:00"},
    {"count": 50, "amount": 3800, "currency": "GBP", "time_bucket": "2024-08-18 18:30:00"},
    {"count": 52, "amount": 4000, "currency": "GBP", "time_bucket": "2024-08-19 18:30:00"},
  ],
  "metaData": [
    {"count": 217, "amount": 8672, "currency": "USD"},
    {"count": 340, "amount": 25575, "currency": "EUR"},
    {"count": 324, "amount": 24500, "currency": "GBP"},
  ],
}->Identity.genericObjectOrRecordToJson

let getData2 = {
  "queryData": [
    {"count": 24, "amount": 952, "time_bucket": "2024-08-13 18:30:00"},
    {"count": 28, "amount": 1020, "time_bucket": "2024-08-14 18:30:00"},
    {"count": 35, "amount": 1450, "time_bucket": "2024-08-15 18:30:00"},
    {"count": 30, "amount": 1150, "time_bucket": "2024-08-16 18:30:00"},
    {"count": 40, "amount": 1600, "time_bucket": "2024-08-17 18:30:00"},
    {"count": 29, "amount": 1200, "time_bucket": "2024-08-18 18:30:00"},
    {"count": 31, "amount": 1300, "time_bucket": "2024-08-19 18:30:00"},
  ],
  "metaData": [{"count": 217, "amount": 8672, "currency": "USD"}],
}->Identity.genericObjectOrRecordToJson
