@react.component
let make = () => {
  open ApexCharts

  let data = {
    name: "Desktops",
    data: [10, 41, 35, 51, 49, 62, 69, 91, 148],
  }

  let options = {
    chart: {
      height: 350,
      \"type": "line",
      zoom: {
        enabled: false,
      },
    },
    dataLabels: {
      enabled: false,
    },
    stroke: {
      curve: "straight",
    },
    title: {
      text: "Product Trends by Month",
      align: "left",
    },
  }

  <ReactApexChart options series={[data]} \"type"="bar" height={350.0} />
}
