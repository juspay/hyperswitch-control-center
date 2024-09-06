let options = {
  "chart": {
    "type": "line",
    "spacingLeft": 20,
    "spacingRight": 20,
  },
  "title": {
    "text": "",
  },
  "xAxis": {
    "categories": [
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
    ],
    "crosshair": true,
    "lineWidth": 1, // Keep a minimal axis line width
    "tickWidth": 1, // Keep the ticks on the line
    "labels": {
      "align": "center", // Align labels with the grid lines
      "style": {
        "color": "#666", // Label color as per the example
      },
      "y": 35,
    },
    "gridLineWidth": 1, // Solid grid line for x-axis
    "gridLineColor": "#e6e6e6", // Lighter grid lines
    "tickmarkPlacement": "on", // Ensure tick marks and labels are aligned
    "endOnTick": false, // Allow the axis to end in an open format
    "startOnTick": false, // Avoid a boxed-in look
  },
  "yAxis": {
    "title": {
      "text": "USD",
    },
    // "labels": {
    //     formatter: function () {
    //         return this.value.toLocaleString(); // Format the value in thousands with commas
    //     },
    //     style: {
    //         color: '#999' // Label color similar to image
    //     }
    // },
    "gridLineWidth": 1,
    "gridLineColor": "#e6e6e6",
    "gridLineDashStyle": "Dash", // Dashed grid lines for y-axis
    "min": 0,
  },
  // tooltip: {
  //     useHTML: true,
  //     shared: true,
  //     borderWidth: 0,
  //     shadow: false,
  //     backgroundColor: 'white',
  //     style: {
  //         color: '#333',
  //         fontSize: '12px'
  //     },
  //     formatter: function () {
  //         let amount = this.points[0].y.toLocaleString(); // Formatted value with commas
  //         let change = '+20%'; // Customize as needed or calculate dynamically
  //         return `
  //             <div style="padding: 10px;">
  //                 <b>Amount Processed: <span style="font-size: 16px;">${amount} USD</span></b><br>
  //                 <span style="color: green;">${change} from previous day</span><br>
  //                 ${Highcharts.dateFormat('%d %b %Y', this.x)}
  //             </div>
  //         `;
  //     }
  // },
  "plotOptions": {
    "line": {
      "marker": {
        "enabled": false, // Disable point markers on lines
      },
    },
  },
  "series": [
    {
      "showInLegend": false, // Hide the legend
      "name": "Series 1",
      "data": [2, 4, 3, 6, 5, 7, 3, 4, 6, 8, 5],
      "color": "#2f7ed8",
    },
    {
      "showInLegend": false, // Hide the legend
      "name": "Series 2",
      "data": [3, 2, 5, 4, 7, 5, 6, 7, 4, 6, 7],
      "color": "#8bbc21",
    },
  ],
  "credits": {
    "enabled": false, // Hide Highcharts credits
  },
}->Identity.genericObjectOrRecordToJson
