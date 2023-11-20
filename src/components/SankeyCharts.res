%%raw(`require("./highcharts.css")`)

type sankeyEntity = {
  uri: string,
  groupByNames: option<array<string>>,
  filters: option<Js.Json.t>,
  sankeyMetrics: option<array<string>>,
  sankeyMetricsConfig: SankeyUtils.nodeConfigs,
  fetchData: bool,
  startNodeLable: string,
  endNodeLable: string,
  source: string,
}

let makeSankeyEntity = (
  ~uri: option<string>=?,
  ~groupByNames: option<array<string>>=?,
  ~filters: option<Js.Json.t>=?,
  ~sankeyMetrics: option<array<string>>=?,
  ~sankeyMetricsConfig: SankeyUtils.nodeConfigs,
  ~fetchData: bool=false,
  ~startNodeLable: string="Total Volume",
  ~endNodeLable: string="Status",
  ~source: string="BATCH",
  (),
) => {
  {
    uri: uri->Belt.Option.getWithDefault(""),
    groupByNames,
    filters,
    sankeyMetrics,
    sankeyMetricsConfig,
    fetchData,
    startNodeLable,
    endNodeLable,
    source,
  }
}

module SankeyWithOptions = {
  @react.component
  let make = (
    ~options: Js.Json.t,
    ~field=?,
    ~sankeyDataLoading,
    ~data,
    ~funnelName,
    ~tablLabels,
    ~loaderType: AnalyticsUtils.loaderType=SideLoader,
  ) => {
    let (sankeyKey, setSankeyKey) = React.useState(_ => sankeyDataLoading)

    React.useEffect1(() => {
      if sankeyDataLoading === false {
        setSankeyKey(prev => !prev)
      }
      None
    }, [sankeyDataLoading])

    let isDataPresent = data->Js.Array2.length > 0
    let tablLabels = isDataPresent ? tablLabels : []

    <AddDataAttributes attributes=[("data-highchart-sankey", "highchart sankey")]>
      {if sankeyDataLoading && loaderType === Shimmer {
        <Shimmer styleClass="w-1/1 h-96 dark:bg-black bg-white" shimmerType={Big} />
      } else {
        <div className="highchart-sankey m-4">
          <div>
            <div className="flex">
              <AddDataAttributes attributes=[("data-header-text", funnelName)]>
                <div
                  className="font-bold text-xl text-black text-opacity-75 dark:text-white dark:text-opacity-75 my-4">
                  {funnelName->React.string}
                </div>
              </AddDataAttributes>
              {if sankeyDataLoading && loaderType === SideLoader {
                <div className="animate-spin mb-4 p-4">
                  <Icon name="spinner" size=20 />
                </div>
              } else {
                <div className="mx-5 my-3">
                  {switch field {
                  | Some(fieldElement) => fieldElement
                  | None => React.null
                  }}
                </div>
              }}
            </div>
            <div
              className="font-bold text-base text-jp-gray-sankey_labels text-opacity-75  dark:text-opacity-75 flex justify-between">
              {tablLabels
              ->Js.Array2.mapi((item, index) =>
                <div className="flex  justify-start" key={index->Belt.Int.toString}>
                  {item->LogicUtils.snakeToTitle->React.string}
                </div>
              )
              ->React.array}
            </div>
            {if data->Js.Array2.length > 0 {
              <SankeyHighcharts.SankeyReact
                highcharts={SankeyHighcharts.highchartsModule} options key={sankeyKey ? "0" : "1"}
              />
            } else {
              <NoDataFound message="No Data Available" renderType=Painting />
            }}
          </div>
        </div>
      }}
    </AddDataAttributes>
  }
}
type sankeyLevelColorConfig = {
  id: string,
  color: string,
}

@react.component
let make = (
  ~data: array<Js.Json.t>,
  ~activeTab=[],
  ~tablLabels=?,
  ~sankeyDataLoading=false,
  ~sankeyConfig: SankeyUtils.nodeConfigs,
  ~lastStageAdd=true,
  ~startNodeLable="Total Volume",
  ~endNodeLable="Status",
  ~funnelName="Performance Sankey",
  ~sortingBasedOnNodesPreference=?,
  ~topN: int=5,
  ~field: React.element=React.null,
  ~sankeyLevelColorConfig: array<sankeyLevelColorConfig>=[],
  ~loaderType: AnalyticsUtils.loaderType=SideLoader,
) => {
  let tablLabels = switch tablLabels {
  | Some(arr) => arr
  | None => activeTab
  }
  let lastNodeArr = [
    (
      {
        id: "Success",
        color: "#71b76e",
        name: "Success",
        dataLabels: {"x": -65},
      }: SankeyHighcharts.node
    ),
    (
      {
        id: "Failure",
        color: "#d37b79",
        name: "Failure",
        dataLabels: {"x": -65},
      }: SankeyHighcharts.node
    ),
  ]
  let (data, nodes) = SankeyUtils.convertToSankeyFormat(
    ~arr=data,
    ~sankeyConfig,
    ~snakeyActiveTab=activeTab,
    ~topN,
    ~lastStageAdd,
  )
  let nodes = Belt.Array.concat(lastNodeArr, nodes)
  // for doing coloring based on pattern matched on the last node
  let nodes = nodes->Js.Array2.map(node => {
    let nodeId = node.id->Js.String2.toLowerCase

    switch sankeyLevelColorConfig
    ->Js.Array2.filter(item => {
      nodeId->Js.String2.includes(item.id->Js.String2.toLowerCase)
    })
    ->Belt.Array.get(0) {
    | Some(val) => {
        ...node,
        color: val.color,
      }
    | None => node
    }
  })
  let to_node = Js.Dict.empty()
  let from_node = Js.Dict.empty()
  React.useMemo1(() => {
    data->Belt.Array.forEachWithIndex((index, item) => {
      let (fromNode, toNode, _, _, _) = item

      switch Js.Dict.get(to_node, toNode) {
      | Some(_) => ()
      | None => to_node->Js.Dict.set(toNode, index)
      }
      switch Js.Dict.get(from_node, fromNode) {
      | Some(_) => ()
      | None => from_node->Js.Dict.set(fromNode, index)
      }
    })
  }, [data])

  let sortFirstNodeBasedOnSecondNode = (
    tuple1: (string, string, int, int, int),
    tuple2: (string, string, int, int, int),
  ) => {
    let (fromNode1, toNode1, _, _, _) = tuple1
    let (fromNode2, toNode2, _, _, _) = tuple2
    let fromNode1Index = to_node->Js.Dict.get(fromNode1)->Belt.Option.getWithDefault(-1)
    let fromNode2Index = to_node->Js.Dict.get(fromNode2)->Belt.Option.getWithDefault(-1)

    if fromNode1Index < fromNode2Index {
      switch sortingBasedOnNodesPreference {
      | Some(sortingBasedOnNodesPreference) =>
        sortingBasedOnNodesPreference((`"${fromNode1}"`, `"${toNode1}"`), (fromNode2, toNode2))
      | None => -1
      }
    } else if fromNode1Index > fromNode2Index {
      switch sortingBasedOnNodesPreference {
      | Some(sortingBasedOnNodesPreference) =>
        sortingBasedOnNodesPreference((`"${fromNode1}"`, `"${toNode1}"`), (fromNode2, toNode2))
      | None => 1
      }
    } else {
      switch sortingBasedOnNodesPreference {
      | Some(sortingBasedOnNodesPreference) =>
        sortingBasedOnNodesPreference((`"${fromNode1}"`, `"${toNode1}"`), (fromNode2, toNode2))
      | None => 0
      }
    }
  }

  let sortedDataBasedOnPreference =
    data->Js.Array2.copy->Js.Array2.sortInPlaceWith(sortFirstNodeBasedOnSecondNode)
  let options = SankeyHighcharts.init(sortedDataBasedOnPreference, nodes)

  let tablLabels = if tablLabels->Js.Array2.length > 0 {
    let tableLables = Belt.Array.concat([startNodeLable], tablLabels)
    if lastStageAdd {
      Belt.Array.concat(tableLables, [endNodeLable])
    } else {
      tableLables
    }
  } else {
    tablLabels
  }
  <SankeyWithOptions options field sankeyDataLoading data funnelName tablLabels loaderType />
}
