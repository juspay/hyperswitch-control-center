open Highcharts
type domElement
open LogicUtils
open DictionaryUtils

type ele
external toElement: Dom.element => ele = "%identity"

@send
external querySelectorAll: (DOMUtils.document, string) => array<Js.Nullable.t<domElement>> =
  "querySelectorAll"

@send external addEventListener: ('a, string, unit => unit) => unit = "addEventListener"

module TooltipString = {
  @react.component
  let make = (~text, ~showTableBelow) => {
    let isMobileView = MatchMedia.useMobileChecker()
    let class = showTableBelow ? "w-fit" : "w-20"
    if text->String.length > 15 && !showTableBelow {
      <ToolTip
        contentAlign=Left
        description=text
        toolTipPosition={isMobileView ? TopRight : Top}
        tooltipWidthClass={isMobileView ? "w-fit" : ""}
        toolTipFor={<div className={`whitespace-pre text-ellipsis overflow-x-hidden w-15`}>
          <AddDataAttributes attributes=[("data-text", text)]>
            <div> {React.string(`${String.slice(~start=0, ~end=12, text)}...`)} </div>
          </AddDataAttributes>
        </div>}
      />
    } else {
      <div className={`whitespace-pre text-ellipsis ${class}`}>
        <AddDataAttributes attributes=[("data-text", text)]>
          <div> {React.string(text)} </div>
        </AddDataAttributes>
      </div>
    }
  }
}

type legendType = Table | Points
module LineChart1D = {
  open Identity
  @react.component
  let make = (
    ~class: string="",
    ~rawChartData: array<Js.Json.t>,
    ~selectedMetrics: LineChartUtils.metricsConfig,
    ~commonColorsArr: array<LineChartUtils.chartData<'a>>=[],
    ~chartPlace="",
    ~xAxis: string,
    ~groupKey: string,
    ~chartTitle: bool=false,
    ~chartTitleText: string="",
    ~showLegend: bool=false,
    ~chartType="area",
    ~showTableLegend: bool=true,
    ~legendType: legendType=Table,
    ~isMultiDimensional: bool=false,
    ~chartKey: string="0",
    ~legendData: array<Js.Json.t>=[],
    ~chartdataMaxRows: int=-1,
    ~selectedRow=None,
    ~showTableBelow: bool=false,
    ~gradient: bool=true,
    ~isPartners=false,
    ~showIndicator=false,
    ~showMarkers=false,
  ) => {
    let (theme, _setTheme) = React.useContext(ThemeProvider.themeContext)
    let (_, setLegendState) = React.useState(_ => [])
    let isMobileView = MatchMedia.useMobileChecker()
    let (hideLegend, setHideLegend) = React.useState(_ => isMobileView)

    let (fistLegend, secondLegend) = switch selectedMetrics {
    | {legendOption} =>
      legendData->Array.length > 0
        ? legendOption
        : LineChartUtils.legendTypeBasedOnMetric(selectedMetrics.metric_type)
    | _ => LineChartUtils.legendTypeBasedOnMetric(selectedMetrics.metric_type)
    }

    let (clickedRowNames, setClickedRowNamesOrig) = React.useState(_ => [])
    let (hoverOnRows, setHoverOnRows) = React.useState(_ => None)

    let chartHeight = isMobileView ? 250 : 400

    let setClickedRowNames = React.useMemo1(() => {
      (legendData: LineChartUtils.legendTableData) => {
        setClickedRowNamesOrig(prev => {
          prev->Array.includes(legendData.groupByName)
            ? prev->Array.filter(item => item !== legendData.groupByName)
            : [legendData.groupByName]
        })
      }
    }, [setClickedRowNamesOrig])

    let (chartData, xAxisMapInfo, chartDataOrig) = React.useMemo7(() => {
      let chartdata: array<
        LineChartUtils.timeSeriesDictWithSecondryMetrics<Js.Json.t>,
      > = LineChartUtils.timeSeriesDataMaker(
        ~data=rawChartData,
        ~groupKey,
        ~xAxis,
        ~metricsConfig=selectedMetrics,
        ~commonColors=commonColorsArr,
        (),
      )->Belt.Array.keepMap(item => {
        if (
          ["run_date", "run_month", "run_week"]->Array.includes(groupKey) && item.name === "Others"
        ) {
          None
        } else {
          Some({
            ...item,
            data: item.data->Array.map(
              dataItem => {
                let (xAxis, yAxis, xY) = dataItem

                let updatedXAxis = if "run_date" === groupKey {
                  `0${xAxis
                    ->Js.Date.fromFloat
                    ->DateTimeUtils.toUtc
                    ->Js.Date.getHours
                    ->Belt.Float.toString}:00`
                  ->String.sliceToEnd(~start=-5)
                  ->Js.Json.string
                } else if "run_month" === groupKey {
                  xAxis
                  ->Js.Date.fromFloat
                  ->DateTimeUtils.toUtc
                  ->Js.Date.getDate
                  ->Belt.Float.toString
                  ->Js.Json.string
                } else if "run_week" === groupKey {
                  switch DateTimeUtils.daysArr[
                    xAxis->Js.Date.fromFloat->DateTimeUtils.toUtc->Js.Date.getDay->Belt.Float.toInt
                  ] {
                  | Some(ele) => DateTimeUtils.dayMapper(ele)
                  | None => ""
                  }->Js.Json.string
                } else {
                  xAxis->Js.Json.number
                }

                (updatedXAxis, yAxis, xY)
              },
            ),
          })
        }
      })

      let chartDataOrig = chartdata

      let selectedChartData = switch selectedRow {
      | Some(data: LineChartUtils.chartData<Js.Json.t>) =>
        chartdata->Array.filter(item => data.name == item.name)
      | None =>
        clickedRowNames->Array.length > 0
          ? chartdata->Array.filter(item => clickedRowNames->Array.includes(item.name))
          : chartdata
      }

      let xAxisMapInfo = Dict.make()
      selectedChartData->Array.forEach(item => {
        item.data->Array.forEach(
          axes => {
            let (x, y, secondryMetrics) = axes
            xAxisMapInfo->LineChartUtils.appendToDictValue(
              ["run_date", "run_month", "run_week"]->Array.includes(groupKey)
                ? x->Js.Json.decodeString->Belt.Option.getWithDefault("")
                : x->Js.Json.stringify,
              (
                item.name,
                {
                  item.color->Belt.Option.getWithDefault("#000000")
                },
                y,
                secondryMetrics,
              ),
            )
          },
        )
      })

      let data = if clickedRowNames->Array.length === 0 {
        switch hoverOnRows {
        | Some(hoverOnRows) =>
          chartdata->Array.map(item => {
            let color = switch item.color {
            | Some(color) => Some(item.name !== hoverOnRows ? `${color}20` : color)
            | None => None
            }
            let fillColor = switch item.fillColor {
            | Some(color) =>
              Some(
                item.name !== hoverOnRows
                  ? {
                      let ((c1, f1), (c2, f2)) = color.stops

                      {
                        ...color,
                        stops: (
                          (c1, LineChartUtils.reduceOpacity(f1)),
                          (c2, LineChartUtils.reduceOpacity(f2)),
                        ),
                      }
                    }
                  : color,
              )
            | None => None
            }

            {
              ...item,
              color,
              ?fillColor,
            }
          })
        | None => selectedChartData
        }
      } else {
        selectedChartData
      }

      let chartData = data->Belt.Array.keepMap(chartDataItem => {
        let (fillColor, color) = (chartDataItem.fillColor, chartDataItem.color) // normal
        //always uses same color for same entity Upi live mode
        let val: option<seriesLine<Js.Json.t>> = if (
          !(clickedRowNames->Array.includes(chartDataItem.name)) &&
          clickedRowNames->Array.length > 0
        ) {
          None
        } else {
          let value: Highcharts.seriesLine<Js.Json.t> = {
            color,
            name: chartDataItem.name,
            data: chartDataItem.data->Array.map(
              item => {
                let (x, y, _) = item
                (x, y->Js.Nullable.return)
              },
            ),
            legendIndex: chartDataItem.legendIndex,
          }
          Some({...value, ?fillColor})
        }

        val
      })
      (chartData, xAxisMapInfo, chartDataOrig)
    }, (xAxis, selectedMetrics, rawChartData, groupKey, clickedRowNames, hoverOnRows, selectedRow))

    let chartData = if chartdataMaxRows !== -1 {
      chartData->Array.slice(~start=0, ~end=chartdataMaxRows)
    } else {
      chartData
    }

    let legendData = React.useMemo5(() => {
      let data = LineChartUtils.getLegendDataForCurrentMetrix(
        ~yAxis=selectedMetrics.metric_name_db,
        ~xAxis,
        ~timeSeriesData=rawChartData,
        ~groupedData=legendData,
        ~metrixType=selectedMetrics.metric_type,
        ~activeTab=groupKey,
      )->Belt.Array.keepMap(item => {
        if (
          ["run_date", "run_month", "run_week"]->Array.includes(groupKey) &&
            item.groupByName === "Others"
        ) {
          None
        } else {
          item->Some
        }
      })
      if chartdataMaxRows !== -1 {
        data->Array.slice(~start=0, ~end=chartdataMaxRows)
      } else {
        data
      }
    }, (selectedMetrics, rawChartData, groupKey, xAxis, legendData))

    let getCell = (
      transactionTable: LineChartUtils.legendTableData,
      colType: LineChartUtils.chartLegendStatsType,
    ): Table.cell => {
      let formatter = value => {
        LineChartUtils.formatStatsAccToMetrix(selectedMetrics.metric_type, value)
      }
      let colorOrig =
        chartDataOrig
        ->Belt.Array.keepMap(item => {
          switch item.color {
          | Some(color) => transactionTable.groupByName === item.name ? Some(color) : None
          | None => None
          }
        })
        ->Belt.Array.get(0)
        ->Belt.Option.getWithDefault("")
      let color =
        chartData
        ->Belt.Array.keepMap(item => {
          switch item.color {
          | Some(color) => transactionTable.groupByName === item.name ? Some(color) : None
          | None => None
          }
        })
        ->Belt.Array.get(0)
        ->Belt.Option.getWithDefault(`${colorOrig}`)

      let transformValue = num => {
        num->HSAnalyticsUtils.setPrecision()
      }
      let (nonSelectedClass, backgroundColor) =
        clickedRowNames->Array.length === 0 ||
          clickedRowNames->Array.includes(transactionTable.groupByName)
          ? ("", `${color}`)
          : ("opacity-40", `${color}50`)

      switch colType {
      | GroupBY =>
        CustomCell(
          <div className="flex items-stretch justify-start select-none">
            <span
              className={`flex h-3 w-3 rounded-full self-center mr-2`}
              style={ReactDOM.Style.make(~backgroundColor, ())}
            />
            <span className={`flex justify-self-start ${nonSelectedClass}`}>
              <TooltipString text=transactionTable.groupByName showTableBelow />
            </span>
          </div>,
          transactionTable.groupByName,
        )
      | Overall =>
        let value = transactionTable.overall->transformValue->formatter
        CustomCell(
          <AddDataAttributes attributes=[("data-numeric", value)]>
            <div className=nonSelectedClass> {React.string(value)} </div>
          </AddDataAttributes>,
          value,
        )
      | Average =>
        let value = transactionTable.average->transformValue->formatter
        CustomCell(
          <AddDataAttributes attributes=[("data-numeric", value)]>
            <div className=nonSelectedClass> {React.string(value)} </div>
          </AddDataAttributes>,
          value,
        )
      | Current =>
        let value = transactionTable.current->transformValue->formatter
        CustomCell(
          <AddDataAttributes attributes=[("data-numeric", value)]>
            <div className=nonSelectedClass> {React.string(value)} </div>
          </AddDataAttributes>,
          value,
        )
      | Emoji =>
        CustomCell(
          {
            if (
              !(transactionTable.groupByName->String.includes("Mid")) && isPartners && showIndicator
            ) {
              <div className="flex items-stretch justify-start">
                {if transactionTable.current < 20. {
                  <div className="flex items-stretch justify-start">
                    <Icon name="sad-tear" className="text-red-500" size=18 />
                  </div>
                } else if transactionTable.current < 40. {
                  <Icon name="sad-tear" className="text-red-300" size=18 />
                } else if transactionTable.current < 50. {
                  <Icon name="sad-tear" className="text-red-200" size=18 />
                } else if transactionTable.current < 60. {
                  <Icon name="smile" className="text-green-200" size=18 />
                } else if transactionTable.current < 90. {
                  <Icon name="smile" className="text-green-500" size=18 />
                } else {
                  <Icon name="smile" className="text-green-700" size=18 />
                }}
              </div>
            } else {
              React.null
            }
          },
          transactionTable.groupByName,
        )

      | NO_COL =>
        CustomCell(
          {
            React.null
          },
          transactionTable.groupByName,
        )
      }
    }

    let getHeading = (colType: LineChartUtils.chartLegendStatsType) => {
      switch colType {
      | GroupBY =>
        Table.makeHeaderInfo(
          ~key="groupByName",
          ~title=snakeToTitle(groupKey),
          ~dataType=LabelType,
          ~showSort={!isPartners},
          (),
        )

      | val =>
        Table.makeHeaderInfo(
          ~key=val->LineChartUtils.chartLegendTypeToStr->String.toLowerCase,
          ~title=val->LineChartUtils.chartLegendTypeToStr,
          ~dataType=NumericType,
          ~showSort={!isPartners},
          (),
        )
      }
    }

    let defaultSort: Table.sortedObject = {
      key: "index",
      order: Table.DEC,
    }
    open LineChartUtils
    let legendTableEntity = EntityType.makeEntity(
      ~defaultColumns=[GroupBY, fistLegend, secondLegend],
      ~allColumns=[GroupBY, fistLegend, secondLegend],
      ~getCell,
      ~getHeading,
      ~uri="",
      ~getObjects=_ => {[]},
      (),
    )
    let {isSidebarExpanded} = React.useContext(SidebarProvider.defaultContext)

    React.useEffect1(() => {
      Js.Global.setTimeout(_ => {
        DOMUtils.window->DOMUtils.dispatchEvent(DOMUtils.event("resize"))
      }, 150)->ignore
      None
    }, [isSidebarExpanded])
    let options = React.useMemo4(() => {
      let chartTitleStyle = chartTitleStyle(theme)
      let thresholdVal = selectedMetrics.thresholdVal
      let stepUpFromThreshold = selectedMetrics.step_up_threshold

      let legend = switch legendType {
      | Table =>
        {
          "enabled": {isMobileView ? false : showLegend},
        }->genericObjectOrRecordToJson
      | Points =>
        {
          "enabled": !isMultiDimensional,
          "itemStyle": legendItemStyle(theme, "IBM Plex Sans", "12px"),
          "itemHiddenStyle": legendHiddenStyle(theme),
          "itemHoverStyle": legendItemStyle(theme),
        }->genericObjectOrRecordToJson
      }

      let a: options<Js.Json.t> = {
        chart: {
          Some(
            {
              "type": chartType,
              "margin": None,
              "zoomType": "x",
              "backgroundColor": Js.Nullable.null,
              "height": Some(chartHeight),
              "events": {
                render: (
                  @this
                  (this: chartEventOnload) => {
                    let strokeColor = switch theme {
                    | Dark => "#2e2f39"
                    | Light => "#e6e6e6"
                    }
                    switch this.yAxis[0] {
                    | Some(ele) =>
                      Highcharts.objectEach(ele.ticks, tick => {
                        if Some(tick.pos) === thresholdVal {
                          tick.gridLine.attr(.
                            {
                              "stroke-width": "0",
                            }->genericObjectOrRecordToJson,
                          )
                        } else {
                          tick.gridLine.attr(.
                            {
                              "stroke": strokeColor,
                            }->genericObjectOrRecordToJson,
                          )
                        }
                      })
                    | None => ()
                    }
                  }
                )->Some,
              }->Some,
            }->genericObjectOrRecordToJson,
          )
        },
        title: {
          "text": chartTitle ? chartTitleText : "",
          "style": chartTitleStyle,
        }->genericObjectOrRecordToJson,
        credits: {
          "enabled": false,
        },
        legend,
        tooltip: {
          "shared": false,
          "enabled": true,
          "useHTML": true,
          "formatter": tooltipFormatter(selectedMetrics, xAxisMapInfo, groupKey)->Some,
          "hideDelay": 0,
          "outside": false,
          "shape": "square",
          "backgroundColor": theme === Light ? "rgba(25, 26, 26, 1)" : "rgba(247, 247, 250, 1)",
          "borderColor": theme === Light ? "rgba(25, 26, 26, 1)" : "rgba(247, 247, 250, 1)",
          "boxShadow": "",
          "style": {
            "color": theme === Light ? "rgba(246, 248, 249, 1)" : "rgba(25, 26, 26, 1)",
          },
        }->genericObjectOrRecordToJson,
        plotOptions: Some(
          {
            "area": {
              "pointStart": None,
              "fillColor": None,
              "fillOpacity": 0.,
              "states": {
                "hover": {
                  "lineWidth": 1.,
                },
              },
              "lineWidth": 1.2,
              "threshold": Js.Nullable.null,
            }->genericObjectOrRecordToJson,
            "line": {
              "pointStart": None,
              "fillColor": None,
              "fillOpacity": 0.,
              "states": {
                "hover": {
                  "lineWidth": 1.,
                },
              },
              "lineWidth": 1.2,
              "threshold": Js.Nullable.null,
            }->genericObjectOrRecordToJson,
            "boxplot": {
              "visible": false,
            },
            "series": {
              "marker": {
                "enabled": showMarkers->Some,
                "radius": (showMarkers ? 5 : 1)->Some,
                "symbol": Some("circle"),
              },
              "states": Some({
                "hover": Some({
                  "enabled": Some(true),
                  "halo": Some({
                    "size": Some(10),
                  }),
                }),
              }),
              "events": Some({
                "legendItemClick": Some(
                  @this
                  (s: legendItem, e: ReactEvent.Keyboard.t) => {
                    legendClickItem(s, e, setLegendState)
                  },
                ),
                "mouseOver": None,
              }),
            }->genericObjectOrRecordToJson,
          }->genericObjectOrRecordToJson,
        ),
        xAxis: {
          let defaultValue = {
            "type": "datetime",
          }->genericObjectOrRecordToJson
          let defaultValue = if ["run_date", "run_month", "run_week"]->Array.includes(groupKey) {
            {
              "type": "category",
              "tickWidth": 0,
            }->genericObjectOrRecordToJson
          } else {
            defaultValue
          }
          defaultValue
        },
        yAxis: {
          "gridLineWidth": 1,
          "tickWidth": 0,
          "min": 0.,
          "gridLineColor": "#DDE3EE",
          "gridLineDashStyle": "Dot",
          "tickPositioner": Some(
            @this
            param => {
              let positions = switch thresholdVal {
              | Some(threshold) => {
                  let upper_bound = param.dataMax
                  let lower_bound = 0.

                  let upper_bound =
                    upper_bound <= threshold
                      ? threshold +. stepUpFromThreshold->Belt.Option.getWithDefault(0.)
                      : upper_bound

                  let lower_bound =
                    lower_bound >= threshold
                      ? threshold -. stepUpFromThreshold->Belt.Option.getWithDefault(0.)
                      : lower_bound

                  let positions = NumericUtils.pretty([lower_bound, upper_bound], 5)

                  let positionArr =
                    Belt.Array.concat(positions, [threshold])->Js.Array2.sortInPlaceWith(
                      numericArraySortComperator,
                    )
                  positionArr
                }

              | None => NumericUtils.pretty([0., param.dataMax], 5)
              }

              //NOTE have to implment the NumericUtils.pretty perfactly to make it work

              positions
            },
          ),
          "plotLines": [
            {
              label: {
                align: "right"->Some,
                style: {
                  color: "blue"->Some,
                  fontWeight: "bold"->Some,
                  background: "red"->Some,
                }->Some,
              }->Some,
              dashStyle: "Dash"->Some,
              value: thresholdVal,
              width: 1->Some,
              color: "#ff0000"->Some,
            },
          ]->Some,
          "visible": true,
          "title": {
            "text": "",
            "style": chartTitleStyle,
          }->genericObjectOrRecordToJson,
          "labels": {
            let labelsValue = {
              "formatter": Some(
                @this
                param =>
                  formatLabels(selectedMetrics, param.value->Belt.Option.getWithDefault(0.0)),
              ),
              "enabled": true,
              "style": {
                "fontFamily": "Inter",
                "fontSize": "12px",
                "fontStyle": "normal",
                "fontWeight": 500,
                "lineHeight": "20px",
                "letterSpacing": "1px",
                "color": theme === Light ? "#4B5468" : "rgba(246, 248, 249, 0.25)",
              },
            }->genericObjectOrRecordToJson

            labelsValue->getDictFromJsonObject->deleteKey("style")->Js.Json.object_
          },
        }->genericObjectOrRecordToJson,
        series: chartData,
      }
      a
    }, (chartData, selectedMetrics, theme, isMobileView))

    let (offset, setOffset) = React.useState(_ => 0)
    let (flexClass, tableWidth, chartWidth) = if showTableBelow || isMobileView {
      ("flex flex-col", "w-full", "w-full")
    } else {
      ("flex flex-row", "w-1/5", "w-4/5")
    }

    if chartData->Array.length > 0 {
      <div className={isMobileView ? "w-full" : isMultiDimensional ? "w-1/3" : ""}>
        <div className={`${flexClass} ${class} px-4 pb-3`}>
          <AddDataAttributes attributes=[("data-chart", chartTitleText)]>
            <div className={showTableLegend ? chartWidth : "w-full"}>
              <HighchartsReact highcharts={highchartsModule} options key={chartKey} />
            </div>
          </AddDataAttributes>
          <UIUtils.RenderIf condition={showTableLegend && isMobileView}>
            <div
              className="flex flex-row items-center gap-2 w-fit self-end cursor-pointer mr-5 mb-2"
              onClick={_ => {setHideLegend(prev => !prev)}}>
              <Icon
                name={hideLegend ? "collpase-alt" : "expand-alt"}
                size=12
                className="text-neutral-400"
              />
            </div>
          </UIUtils.RenderIf>
          {if showTableLegend && !hideLegend {
            <div className={`${tableWidth}  pl-5 pt-0 min-w-max`}>
              <LoadedTable
                visibleColumns={isPartners
                  ? [GroupBY, fistLegend, secondLegend, Emoji]
                  : [GroupBY, fistLegend, secondLegend]}
                title="High Chart Time Series Chart"
                hideTitle=true
                actualData={legendData->Array.map(Js.Nullable.return)}
                entity=legendTableEntity
                resultsPerPage=15
                totalResults={legendData->Array.length}
                offset
                setOffset
                defaultSort
                showPagination=false
                currrentFetchCount={legendData->Array.length}
                onEntityClick={val => {
                  setClickedRowNames(val)
                }}
                onEntityDoubleClick={val => {
                  setClickedRowNamesOrig(_ => [])
                  clickedRowNames->Array.length > 0 ? setHoverOnRows(_ => None) : ()
                }}
                onMouseEnter={val => {
                  clickedRowNames->Array.length === 0
                    ? setHoverOnRows(_ => Some(val.groupByName))
                    : ()
                }}
                onMouseLeave={val => {
                  clickedRowNames->Array.length === 0 ? setHoverOnRows(_ => None) : ()
                }}
                isHighchartLegend=true
                showTableOnMobileView=true
              />
            </div>
          } else {
            React.null
          }}
        </div>
      </div>
    } else {
      React.null
    }
  }
}

module LegendItem = {
  @react.component
  let make = (
    ~chartNames,
    ~selectedRow: option<LineChartUtils.chartData<'a>>,
    ~setSelectedRow: (
      option<LineChartUtils.chartData<'a>> => option<LineChartUtils.chartData<'a>>
    ) => unit,
  ) => {
    let opacity = name =>
      switch selectedRow {
      | Some(val) => val.name !== name ? "opacity-40" : ""
      | None => ""
      }
    <div className="flex flex-row m-5 gap-6 font-inter-style mobile:flex-wrap">
      {LineChartUtils.removeDuplicates(chartNames)
      ->Array.map(legendItem => {
        let opacity = opacity(legendItem.name)
        <AddDataAttributes attributes=[("data-chart-legend", legendItem.name)]>
          <div
            className={`flex flex-row gap-2 justify-center items-center cursor-pointer ${opacity} select-none`}
            onDoubleClick={_ => selectedRow->Belt.Option.isSome ? setSelectedRow(_ => None) : ()}
            onClick={_ =>
              setSelectedRow(prev => {
                switch prev {
                | Some(val) => val.name === legendItem.name ? None : Some(legendItem)
                | None => Some(legendItem)
                }
              })}>
            <div
              className={`w-[0.9375rem] h-[0.9375rem] rounded`}
              style={ReactDOM.Style.make(~background=legendItem.color, ())}
            />
            <div className="font-medium text-fs-14 text-[#3B424F]">
              {React.string(legendItem.name)}
            </div>
          </div>
        </AddDataAttributes>
      })
      ->React.array}
    </div>
  }
}

module RenderMultiDimensionalChart = {
  type config = {
    chartDictData: Dict.t<Belt.Array.t<Js.Json.t>>,
    class: string,
    selectedMetrics: LineChartUtils.metricsConfig,
    groupBy: string,
    xAxis: string,
    chartKey: string,
    legendType: legendType,
    chartType: string,
  }
  @react.component
  let make = (~config: config) => {
    let (selectedRow, setSelectedRow) = React.useState(_ => None)
    let chartNames =
      config.chartDictData
      ->Dict.toArray
      ->Array.reduce([], (acc: array<LineChartUtils.chartData<Js.Json.t>>, (_, value)) => {
        let chartdata = LineChartUtils.timeSeriesDataMaker(
          ~data=value,
          ~groupKey=config.groupBy,
          ~xAxis=config.xAxis,
          ~metricsConfig=config.selectedMetrics,
          (),
        )
        chartdata
        ->Array.map(i =>
          acc->Array.push({
            data: i.data->Array.map(
              item => {
                let (val1, val2, val3) = item
                (val1->Js.Json.number, val2, val3)
              },
            ),
            legendIndex: i.legendIndex,
            name: i.name,
            color: i.color->Belt.Option.getWithDefault("#000000"),
          })
        )
        ->ignore
        acc
      })

    <div className="flex flex-col">
      <LegendItem chartNames selectedRow setSelectedRow />
      <div className="flex flex-wrap">
        {
          let chartArr = {
            config.chartDictData
            ->Dict.toArray
            ->Array.mapWithIndex((item, index) => {
              let (key, value) = item

              <LineChart1D
                key={index->Belt.Int.toString}
                class=config.class
                rawChartData=value
                commonColorsArr={LineChartUtils.removeDuplicates(chartNames)}
                selectedMetrics=config.selectedMetrics
                xAxis=config.xAxis
                groupKey=config.groupBy
                chartTitle=true
                chartTitleText=key
                showTableLegend=false
                showLegend=false
                legendType=config.legendType
                isMultiDimensional=true
                chartKey=config.chartKey
                selectedRow={selectedRow}
                chartType=config.chartType
              />
            })
          }
          chartArr->React.array
        }
      </div>
    </div>
  }
}

module LineChart2D = {
  @react.component
  let make = (
    ~groupBy: option<array<string>>,
    ~rawChartData: array<Js.Json.t>,
    ~selectedMetrics: LineChartUtils.metricsConfig,
    ~xAxis: string,
    ~legendType=Points,
    ~class="",
    ~chartKey: string="0",
    ~chartType: string="area",
  ) => {
    let (groupBy1, groupBy2) = switch groupBy {
    | Some(value) => (
        value->Belt.Array.get(0)->Belt.Option.getWithDefault(""),
        value->Belt.Array.get(1)->Belt.Option.getWithDefault(""),
      )
    | None => ("", "")
    }
    let (groupBy1, groupBy2) = (groupBy2, groupBy1)

    let chartDictData = Dict.make()
    rawChartData->Array.forEach(item => {
      let dict = item->getDictFromJsonObject
      let groupBy = dict->getString(groupBy1, "")
      let groupBy = groupBy === "" ? "NA" : groupBy

      chartDictData->LineChartUtils.appendToDictValue(groupBy, item)
    })

    let compProps: RenderMultiDimensionalChart.config = {
      chartDictData,
      class,
      selectedMetrics,
      groupBy: groupBy2,
      xAxis,
      chartKey,
      legendType,
      chartType,
    }

    <RenderMultiDimensionalChart config={compProps} />
  }
}

module LineChart3D = {
  @react.component
  let make = (
    ~groupBy: option<array<string>>,
    ~rawChartData: array<Js.Json.t>,
    ~selectedMetrics: LineChartUtils.metricsConfig,
    ~xAxis: string,
    ~legendType=Points,
    ~class="",
    ~chartKey: string="0",
    ~chartType: string="area",
  ) => {
    let (groupBy1, groupBy2, groupby3) = switch groupBy {
    | Some(value) => (
        value->Belt.Array.get(0)->Belt.Option.getWithDefault(""),
        value->Belt.Array.get(1)->Belt.Option.getWithDefault(""),
        value->Belt.Array.get(2)->Belt.Option.getWithDefault(""),
      )
    | None => ("", "", "")
    }
    let (groupBy1, groupBy2, groupby3) = (groupBy2, groupby3, groupBy1)

    let chartDictData = Dict.make()
    rawChartData->Array.forEach(item => {
      let dict = item->getDictFromJsonObject
      let groupBy1 = dict->getString(groupBy1, "")
      let groupBy1 = groupBy1 === "" ? "NA" : groupBy1
      let groupBy2 = dict->getString(groupBy2, "")
      let groupBy2 = groupBy2 === "" ? "NA" : groupBy2

      chartDictData->LineChartUtils.appendToDictValue(groupBy1 ++ " / " ++ groupBy2, item)
    })

    let compProps: RenderMultiDimensionalChart.config = {
      chartDictData,
      class,
      selectedMetrics,
      groupBy: groupby3,
      xAxis,
      chartKey,
      legendType,
      chartType,
    }

    <RenderMultiDimensionalChart config=compProps />
  }
}
