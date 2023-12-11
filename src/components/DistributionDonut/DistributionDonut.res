external objToJson: {..} => Js.Json.t = "%identity"

type dataPoint = {y: int, name: string}

module LegendField = {
  @react.component
  let make = (~data: dataPoint, ~valueSuffix: string, ~color: string) => {
    <div className="flex justify-between flex-row items-center">
      <div className="flex flex-row gap-1 items-center w-[250px]">
        <div
          className="rounded h-3 w-3 mr-px flex-shrink-0"
          style={ReactDOMStyle.make(~background=color, ())}
        />
        <ToolTip
          description={data.name}
          toolTipFor={<div className="text-ellipsis overflow-hidden whitespace-nowrap w-[200px]">
            {React.string(data.name)}
          </div>}
          toolTipPosition=Top
        />
      </div>
      <div> {React.string(`${Belt.Int.toString(data.y)}${valueSuffix}`)} </div>
    </div>
  }
}

@react.component
let make = (
  ~title: string,
  ~icon: React.element,
  ~description: string,
  ~colors: array<string>=[
    "#1316bc",
    "#5256bc",
    "#4e53e6",
    "#7478ea",
    "#a2a5f0",
    "#c3c5ff",
    "#b4bfcc",
    "#d9d9d9",
    "#e7e7e7",
  ],
  ~getSubtilteHtml: array<dataPoint> => string,
  ~tooltipTitle: string,
  ~tooltipSuffix: string="",
  ~groupByOptions: array<string>,
  ~getOptionsForSelectBox: array<string> => array<
    SelectBox.dropdownOption,
  >=Js.Array.map((data: string): SelectBox.dropdownOption => {label: data, value: data}, _),
  ~data: array<Js.Json.t>,
  ~getGroupBasedData: (array<Js.Json.t>, string) => array<dataPoint>,
) => {
  let (groupBy, setGroupBy) = React.useState(_ => "")
  let (groupBasedData, setGroupBasedData) = React.useState((_): array<dataPoint> => [])
  let getDonutOptions = (_): Js.Json.t => {
    {
      "title": {
        "text": Js.Json.null,
        "align": "center",
        "margin": 0,
      }->objToJson,
      "colors": colors,
      "credits": {
        "enabled": false,
      }->objToJson,
      "subtitle": {
        "useHTML": true,
        "text": getSubtilteHtml(groupBasedData),
        "floating": true,
        "verticalAlign": "middle",
        "y": 10,
      }->objToJson,
      "legend": {
        "enabled": false,
      }->objToJson,
      "chart": {
        "backgroundColor": Js.Json.null,
        "className": "h-60",
        "height": 260,
        "width": 260,
        "borderColor": Js.Json.null,
      }->objToJson,
      "tooltip": {
        "valueDecimals": 0,
        "valueSuffix": "",
      }->objToJson,
      "plotOptions": {
        "series": {
          "animation": {
            "duration": 0,
          }->objToJson,
          "borderWidth": 5,
          "colorByPoint": true,
          "type": "pie",
          "size": "100%",
          "innerSize": "60%",
          "dataLabels": {
            "enabled": false,
            "crop": false,
            "distance": "-10%",
            "style": {
              "fontWeight": "bold",
              "fontSize": "16px",
            }->objToJson,
            "connectorWidth": 0,
          }->objToJson,
        }->objToJson,
      }->objToJson,
      "series": [
        {
          "color": "black",
          "type": "pie",
          "name": tooltipTitle,
          "data": Js.Array.map(
            (d: dataPoint): Js.Json.t => {"y": d.y, "name": d.name}->objToJson,
            groupBasedData,
          ),
        }->objToJson,
      ],
    }->objToJson
  }
  React.useEffect1(() => {
    setGroupBy(_ =>
      switch getOptionsForSelectBox(groupByOptions)->Belt.Array.get(0) {
      | Some(groupOption) => groupOption.value
      | _ => ""
      }
    )
    setGroupBasedData((_: array<dataPoint>): array<dataPoint> => getGroupBasedData(data, groupBy))
    None
  }, [data])
  React.useEffect1(() => {
    setGroupBasedData((_: array<dataPoint>): array<dataPoint> => getGroupBasedData(data, groupBy))
    None
  }, [groupBy])
  <div
    className="rounded-lg"
    style={ReactDOMStyle.make(
      ~background="white",
      ~border="1px solid rgba(68, 68, 68, 0.1)",
      ~width="50%",
      ~maxWidth="644px",
      ~minWidth="644px",
      (),
    )}>
    // head starts
    <div
      className="flex justify-between flex-row h-14"
      style={ReactDOMStyle.make(~margin="24px 0px 0px 32px", ())}>
      <div className="flex justify-between flex-col h-full">
        <div className="flex flex-row text-neutral-800">
          icon
          {React.string(title)}
        </div>
        <div className="text-neutral-600"> {React.string(description)} </div>
      </div>
      <div className="mr-6">
        {
          let filterInput: ReactFinalForm.fieldRenderPropsInput = {
            name: "Get By",
            onBlur: _ev => (),
            onChange: ev => {setGroupBy(_ => ev->Identity.formReactEventToString)},
            onFocus: _ev => (),
            value: groupBy->Js.Json.string,
            checked: true,
          }
          <SelectBox
            input=filterInput
            options={getOptionsForSelectBox(groupByOptions)}
            buttonText={groupBy}
            showToolTip=true
            showNameAsToolTip=true
          />
        }
      </div>
    </div>
    // head ends
    // body starts
    <div className="flex flex-row gap-x-20">
      // left donut starts
      <div>
        <HighchartsDonut.RawDonutChart options={getDonutOptions()} />
      </div>
      // left donut ends
      // right legend starts
      <div
        className="flex items-center"
        style={ReactDOMStyle.make(
          ~margin="0px 24px 0px 0px",
          ~width="30%",
          ~minWidth="70px",
          ~maxWidth="250px",
          (),
        )}>
        <div className="w-full text-neutral-900 bg-white p-1">
          {groupBasedData
          ->Js.Array2.mapi((data, i) => {
            <LegendField
              data valueSuffix={tooltipSuffix} color={colors[i]->Belt.Option.getWithDefault("")}
            />
          })
          ->React.array}
        </div>
      </div>
      // right legend ends
    </div>
    // body ends
  </div>
}
