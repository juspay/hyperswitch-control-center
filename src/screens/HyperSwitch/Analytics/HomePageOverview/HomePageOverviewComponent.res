open HomeUtils

module ConnectorOverview = {
  @react.component
  let make = () => {
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
    let (configuredConnectors, setConfiguredConnectors) = React.useState(_ => [])
    let fetchConnectorListResponse = ConnectorUtils.useFetchConnectorList()

    let getConnectorList = async () => {
      open LogicUtils
      try {
        let response = await fetchConnectorListResponse()
        let connectorsList =
          response->HSwitchUtils.getProcessorsListFromJson(
            ~removeFromList=HSwitchUtils.FRMPlayer,
            (),
          )

        let arr =
          connectorsList->Array.map(paymentMethod =>
            paymentMethod
            ->getString("connector_name", "")
            ->ConnectorUtils.getConnectorNameTypeFromString
          )
        setConfiguredConnectors(_ => arr)
        setScreenState(_ => Success)
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
      }
    }

    React.useEffect0(() => {
      getConnectorList()->ignore
      None
    })

    let getConnectorIconsList = () => {
      let icons =
        configuredConnectors
        ->Array.filterWithIndex((_, i) => i <= 2)
        ->Array.mapWithIndex((connector, index) => {
          let iconStyle = `${index === 0 ? "" : "-ml-4"} z-${(30 - index * 10)->Js.Int.toString}`
          <GatewayIcon
            gateway={connector->ConnectorUtils.getConnectorNameString->String.toUpperCase}
            className={`w-12 h-12 rounded-full border-3 border-white  ${iconStyle} bg-white`}
          />
        })

      let icons =
        configuredConnectors->Array.length > 3
          ? icons->Array.concat([
              <div
                className={`w-12 h-12 flex items-center justify-center text-white font-medium rounded-full border-3 border-white -ml-3 z-0 bg-blue-900`}>
                {`+${(configuredConnectors->Array.length - 3)->Js.Int.toString}`->React.string}
              </div>,
            ])
          : icons

      <div className="flex"> {icons->React.array} </div>
    }

    <UIUtils.RenderIf condition={configuredConnectors->Array.length > 0}>
      <PageLoaderWrapper screenState customLoader={<Shimmer styleClass="w-full h-full" />}>
        <div className=boxCss>
          {getConnectorIconsList()}
          <div className="flex items-center gap-2">
            <p className=cardHeaderTextStyle>
              {`${configuredConnectors
                ->Array.length
                ->Js.Int.toString} Active Processors`->React.string}
            </p>
          </div>
          <Button
            text="+ Add More"
            buttonType={PrimaryOutline}
            customButtonStyle="w-10 !px-3"
            buttonSize={Small}
            onClick={_ => {
              "/connectors"->RescriptReactRouter.push
            }}
          />
        </div>
      </PageLoaderWrapper>
    </UIUtils.RenderIf>
  }
}

module SystemMetricsInsights = {
  open DynamicSingleStat
  open SystemMetricsAnalyticsUtils
  open HSAnalyticsUtils
  open AnalyticsTypes
  @react.component
  let make = () => {
    let (_totalVolume, setTotalVolume) = React.useState(_ => 0)

    let getStatData = (
      singleStatData: systemMetricsObjectType,
      timeSeriesData: array<systemMetricsSingleStateSeries>,
      deltaTimestampData: DynamicSingleStat.deltaRange,
      colType,
      _mode,
    ) => {
      switch colType {
      | Latency | _ => {
          title: "Payments Confirm Latency",
          tooltipText: "Average time taken for the entire Payments Confirm API call.",
          deltaTooltipComponent: AnalyticsUtils.singlestatDeltaTooltipFormat(
            singleStatData.latency,
            deltaTimestampData.currentSr,
          ),
          value: singleStatData.latency /. 1000.0,
          delta: {
            singleStatData.latency
          },
          data: constructData("latency", timeSeriesData),
          statType: "LatencyMs",
          showDelta: false,
        }
      }
    }

    let defaultColumns: array<DynamicSingleStat.columns<systemMetricsSingleStateMetrics>> = [
      {
        sectionName: "",
        columns: [Latency],
      },
    ]

    let singleStatBodyMake = (singleStatBodyEntity: singleStatBodyEntity) => {
      let filters =
        [
          ("api_name", ["PaymentsConfirm"->Js.Json.string]->Js.Json.array),
          ("status_code", [200.0->Js.Json.number]->Js.Json.array),
          ("flow_type", ["Payment"->Js.Json.string]->Js.Json.array),
        ]
        ->Dict.fromArray
        ->Js.Json.object_

      [
        AnalyticsUtils.getFilterRequestBody(
          ~filter=filters->Some,
          ~metrics=singleStatBodyEntity.metrics,
          ~delta=?singleStatBodyEntity.delta,
          ~startDateTime=singleStatBodyEntity.startDateTime,
          ~endDateTime=singleStatBodyEntity.endDateTime,
          ~mode=singleStatBodyEntity.mode,
          ~customFilter=?singleStatBodyEntity.customFilter,
          ~source=?singleStatBodyEntity.source,
          ~granularity=singleStatBodyEntity.granularity,
          ~prefix=singleStatBodyEntity.prefix,
          (),
        )->Js.Json.object_,
      ]
      ->Js.Json.array
      ->Js.Json.stringify
    }

    let getStatEntity: 'a => DynamicSingleStat.entityType<'colType, 't, 't2> = metrics => {
      urlConfig: [
        {
          uri: `${HSwitchGlobalVars.hyperSwitchApiPrefix}/analytics/v1/metrics/${domain}`,
          metrics: metrics->getStringListFromArrayDict,
          singleStatBody: singleStatBodyMake,
          singleStatTimeSeriesBody: singleStatBodyMake,
        },
      ],
      getObjects: itemToObjMapper,
      getTimeSeriesObject: timeSeriesObjMapper,
      defaultColumns,
      getData: getStatData,
      totalVolumeCol: None,
      matrixUriMapper: _ =>
        `${HSwitchGlobalVars.hyperSwitchApiPrefix}/analytics/v1/metrics/${domain}`,
    }

    let metrics = ["latency"]->Array.map(key => {
      [("name", key->Js.Json.string)]->Dict.fromArray->Js.Json.object_
    })

    let singleStatEntity = getStatEntity(metrics)
    let dateDict = HSwitchRemoteFilter.getDateFilteredObject()

    <DynamicSingleStat
      entity={singleStatEntity}
      startTimeFilterKey
      endTimeFilterKey
      filterKeys=["api_name", "status_code"]
      moduleName="SystemMetrics"
      defaultStartDate={dateDict.start_time}
      defaultEndDate={dateDict.end_time}
      setTotalVolume
      showPercentage=false
      isHomePage=true
      wrapperClass="flex flex-wrap w-full h-full"
      statSentiment={singleStatEntity.statSentiment->Belt.Option.getWithDefault(Dict.make())}
    />
  }
}

module OverviewInfo = {
  open APIUtils
  @react.component
  let make = () => {
    let {sampleData} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
    let updateDetails = useUpdateMethod()
    let showToast = ToastState.useShowToast()

    let generateSampleData = async () => {
      try {
        let generateSampleDataUrl = getURL(~entityName=GENERATE_SAMPLE_DATA, ~methodType=Post, ())
        let _ = await updateDetails(
          generateSampleDataUrl,
          [("record", 50.0->Js.Json.number)]->Dict.fromArray->Js.Json.object_,
          Post,
        )
        showToast(~message="Sample data generated successfully.", ~toastType=ToastSuccess, ())
        Window.Location.reload()
      } catch {
      | _ => ()
      }
    }

    <UIUtils.RenderIf condition={sampleData}>
      <div className="flex bg-white border rounded-md gap-2 px-9 py-3">
        <Icon name="info-vacent" className="text-blue-900" size=20 />
        <span>
          {"To view more points on the above graph, you need to make payments or"->React.string}
        </span>
        <span
          className="underline  cursor-pointer -mx-1 font-medium underline-offset-2"
          onClick={_ => generateSampleData()->ignore}>
          {"generate"->React.string}
        </span>
        <span> {"sample data"->React.string} </span>
      </div>
    </UIUtils.RenderIf>
  }
}

@react.component
let make = () => {
  let {systemMetrics} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  <div className="flex flex-col gap-4">
    <p className=headingStyle> {"Overview"->React.string} </p>
    <div className="grid grid-cols-1 md:grid-cols-3 w-full gap-4">
      <ConnectorOverview />
      <PaymentOverview />
      <UIUtils.RenderIf condition={systemMetrics}>
        <SystemMetricsInsights />
      </UIUtils.RenderIf>
    </div>
    <OverviewInfo />
  </div>
}
