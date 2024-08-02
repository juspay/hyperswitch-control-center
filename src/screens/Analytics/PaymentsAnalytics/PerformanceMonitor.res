@react.component
let make = () => {
  open APIUtils
  open LogicUtils
  open AnalyticsTypes
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()

  let (barSeries, setBarSeries) = React.useState(_ => ([], []))
  let barOption: JSON.t = React.useMemo(() => {
    let (categories, series) = barSeries
    let barOption: JSON.t = {
      "chart": {
        "type": `column`,
      },
      "colors": ["red", "green"],
      "title": {
        "text": `Major trophies for some English teams`,
        "align": "left",
      },
      "xAxis": {
        "categories": categories,
      },
      "yAxis": {
        "min": 0,
        "title": {
          "text": "Count trophies",
        },
        "stackLabels": {
          "enabled": true,
        },
      },
      "legend": {
        "align": "left",
        "x": 70,
        "verticalAlign": "top",
        "y": 70,
        "floating": true,
        "backgroundColor": "white",
        "borderColor": "#CCC",
        "borderWidth": 1,
        "shadow": false,
      },
      "tooltip": {
        "headerFormat": "<b>{point.x}</b><br/>",
        "pointFormat": "{series.name}: {point.y}<br/>Total: {point.stackTotal}",
      },
      "plotOptions": {
        "column": {
          "stacking": "normal",
          "dataLabels": {
            "enabled": true,
          },
        },
      },
      "series": series,
    }->Identity.genericObjectOrRecordToJson
    barOption
  }, [barSeries])
  let chartFetch = async () => {
    try {
      // let url = getURL(~entityName=ANALYTICS_PAYMENTS, ~methodType=Get, ~id=Some("payments"), ())
      let url = "https://sandbox.hyperswitch.io/analytics/v1/metrics/payments"
      let body = [
        {
          "timeRange": {
            "startTime": "2024-07-24T18:30:00Z",
            "endTime": "2024-08-01T09:22:00Z",
          },
          "groupByNames": ["connector", "status"],
          "filters": {
            "status": ["failure", "charged"],
            "connector": [
              "paypal",
              "stripe",
              "trustpay",
              "volt",
              "checkout",
              "cybersource",
              "adyen",
              "billwerk",
              "bankofamerica",
              "klarna",
              "cashtocode",
              "bluesnap",
              "braintree",
            ],
          },
          "metrics": ["payment_count"],
        },
      ]->Identity.genericTypeToJson
      let res = await updateDetails(url, body, Post, ())
      let mappedResponse = res->PaymentAnalyticsEntity.paymentDistributionObjMapper

      let groupedData = mappedResponse->Array.reduce(Dict.make(), (acc, curr) => {
        let d = acc->getArrayFromDict(curr.status, [])
        let _ = d->Array.push(curr->Identity.genericTypeToJson)
        acc->Dict.set(curr.status, d->JSON.Encode.array)
        acc
      })
      let charged =
        groupedData
        ->getArrayFromDict("charged", [])
        ->Array.map(dict => dict->PaymentAnalyticsEntity.distributionObjMapper)
      let failure =
        groupedData
        ->getArrayFromDict("failure", [])
        ->Array.map(dict => dict->PaymentAnalyticsEntity.distributionObjMapper)

      let missingInFailure =
        charged
        ->Array.filter(c => !(failure->Array.some(f => f.connector === c.connector)))
        ->Array.map(c => {payment_count: 0, status: "failure", connector: c.connector})

      let missingInCharged =
        failure
        ->Array.filter(c => !(charged->Array.some(f => f.connector === c.connector)))
        ->Array.map(c => {payment_count: 0, status: "charged", connector: c.connector})

      while failure->Array.length < charged->Array.length && missingInFailure->Array.length > 0 {
        let shift =
          missingInFailure
          ->Array.shift
          ->Option.getOr(PaymentAnalyticsEntity.paymentDistributionInitialValue)
        let _ = failure->Array.push(shift)
      }
      while charged->Array.length < failure->Array.length && missingInCharged->Array.length > 0 {
        let shift =
          missingInCharged
          ->Array.shift
          ->Option.getOr(PaymentAnalyticsEntity.paymentDistributionInitialValue)
        let _ = charged->Array.push(shift)
      }
      let d = (
        charged->Array.map(v => v.connector),
        [
          {
            "name": "Success",
            "data": charged->Array.map(v => v.payment_count),
          },
          {
            "name": "Failed",
            "data": failure->Array.map(v => v.payment_count),
          },
        ],
      )
      setBarSeries(_ => d)
    } catch {
    | _ => ()
    }
  }
  React.useEffect(() => {
    chartFetch()->ignore
    None
  }, [])
  <>
    <HighchartBarChart.RawBarChart options={barOption} />
  </>
}
