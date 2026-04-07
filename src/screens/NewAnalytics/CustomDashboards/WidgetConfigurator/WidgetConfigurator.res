@react.component
let make = (
  ~dashboardName: string,
  ~editingWidget: option<CustomDashboardTypes.widget>,
  ~onClose,
  ~onSuccess,
) => {
  open LogicUtils
  open APIUtils
  open WidgetConfiguratorUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()

  let isEditMode = editingWidget->Option.isSome

  // ── Form State ──
  let (widgetName, setWidgetName) = React.useState(_ =>
    switch editingWidget {
    | Some(w) => w.widgetName
    | None => ""
    }
  )
  let (description, setDescription) = React.useState(_ => "")
  let (domain, setDomain) = React.useState(_ =>
    switch editingWidget {
    | Some(w) => w.config.domain
    | None => CustomDashboardTypes.Payments
    }
  )
  let (chartType, setChartType) = React.useState(_ =>
    switch editingWidget {
    | Some(w) => w.chartType
    | None => CustomDashboardTypes.LineChart
    }
  )
  let (selectedMetrics, setSelectedMetrics) = React.useState(_ =>
    switch editingWidget {
    | Some(w) => w.config.metrics
    | None => []
    }
  )
  let (groupBy, setGroupBy) = React.useState(_ =>
    switch editingWidget {
    | Some(w) => w.config.groupBy->Array.get(0)->Option.getOr("")
    | None => ""
    }
  )
  let (granularity, setGranularity) = React.useState(_ =>
    switch editingWidget {
    | Some(w) => w.config.granularity->Option.getOr("G_ONEDAY")
    | None => "G_ONEDAY"
    }
  )
  let (widgetW, setWidgetW) = React.useState(_ =>
    switch editingWidget {
    | Some(w) => w.position.w
    | None => 6
    }
  )
  let (widgetH, setWidgetH) = React.useState(_ =>
    switch editingWidget {
    | Some(w) => w.position.h
    | None => 4
    }
  )
  let (isSubmitting, setIsSubmitting) = React.useState(_ => false)

  let availableMetrics = getMetricsForDomain(domain)
  let availableDimensions = getDimensionsForDomain(domain)

  let handleDomainChange = (newDomain: CustomDashboardTypes.analyticsDomain) => {
    setDomain(_ => newDomain)
    setSelectedMetrics(_ => [])
    setGroupBy(_ => "")
  }

  let toggleMetric = (metric: string) => {
    setSelectedMetrics(prev =>
      if prev->Array.includes(metric) {
        prev->Array.filter(m => m !== metric)
      } else {
        prev->Array.concat([metric])
      }
    )
  }

  let handleSubmit = async () => {
    if widgetName->String.trim->isNonEmptyString && selectedMetrics->Array.length > 0 {
      setIsSubmitting(_ => true)
      try {
        let url = getURL(~entityName=V1(USERS), ~userType=#USER_DATA, ~methodType=Post)

        let configDict = Dict.make()
        configDict->Dict.set(
          "domain",
          domain->CustomDashboardUtils.getDomainString->JSON.Encode.string,
        )
        configDict->Dict.set(
          "metrics",
          selectedMetrics->Array.map(JSON.Encode.string)->JSON.Encode.array,
        )
        configDict->Dict.set(
          "group_by",
          if groupBy->isNonEmptyString {
            [groupBy->JSON.Encode.string]->JSON.Encode.array
          } else {
            []->JSON.Encode.array
          },
        )
        configDict->Dict.set("filters", JSON.Encode.object(Dict.make()))
        configDict->Dict.set(
          "granularity",
          if needsTimeSeries(chartType) {
            granularity->JSON.Encode.string
          } else {
            JSON.Encode.null
          },
        )
        configDict->Dict.set("time_range_preset", JSON.Encode.null)

        let posDict = Dict.make()
        posDict->Dict.set("x", 0->JSON.Encode.int)
        posDict->Dict.set("y", 0->JSON.Encode.int)
        posDict->Dict.set("w", widgetW->JSON.Encode.int)
        posDict->Dict.set("h", widgetH->JSON.Encode.int)

        let widgetDict = Dict.make()
        widgetDict->Dict.set("widget_name", widgetName->String.trim->JSON.Encode.string)
        widgetDict->Dict.set("chart_type", (chartType :> string)->JSON.Encode.string)
        widgetDict->Dict.set("position", posDict->JSON.Encode.object)
        widgetDict->Dict.set("config", configDict->JSON.Encode.object)

        let data = Dict.make()
        data->Dict.set("dashboard_name", dashboardName->JSON.Encode.string)

        let operationType = switch editingWidget {
        | Some(w) => {
            widgetDict->Dict.set("widget_id", w.widgetId->JSON.Encode.string)
            data->Dict.set("widget_id", w.widgetId->JSON.Encode.string)
            data->Dict.set("widget", widgetDict->JSON.Encode.object)
            "UpdateWidget"
          }
        | None => {
            data->Dict.set("widget", widgetDict->JSON.Encode.object)
            "AddWidget"
          }
        }

        let body = CustomDashboardUtils.buildOperationBody(
          ~operationType,
          ~data=data->JSON.Encode.object,
        )
        let _ = await updateDetails(url, body, Post)
        showToast(
          ~message=isEditMode ? "Widget updated" : "Widget added",
          ~toastType=ToastSuccess,
        )
        onSuccess()
      } catch {
      | _ =>
        showToast(~message="Failed to save widget", ~toastType=ToastError)
        setIsSubmitting(_ => false)
      }
    }
  }

  let canSubmit =
    widgetName->String.trim->String.length > 0 && selectedMetrics->Array.length > 0 && !isSubmitting

  // ── Section helper ──
  let sectionTitle = (title: string, ~subtitle: string="") => {
    <div className="mb-3">
      <h3 className="text-sm font-semibold text-jp-gray-900 dark:text-white"> {React.string(title)} </h3>
      {if subtitle->isNonEmptyString {
        <p className="text-xs text-gray-400 mt-0.5"> {React.string(subtitle)} </p>
      } else {
        React.null
      }}
    </div>
  }

  <div
    className="fixed inset-0 z-50 flex items-stretch justify-end bg-black bg-opacity-40"
    onClick={evt => {
      evt->JsxEvent.Mouse.stopPropagation
      onClose()
    }}>
    // ── Slide-in panel from the right (Grafana-style) ──
    <div
      className="bg-white dark:bg-jp-gray-lightgray_background w-full max-w-xl shadow-2xl flex flex-col overflow-hidden"
      onClick={evt => evt->JsxEvent.Mouse.stopPropagation}>
      // ── Header ──
      <div className="flex items-center justify-between px-6 py-4 border-b bg-gray-50 dark:bg-jp-gray-950">
        <div>
          <h2 className="text-lg font-bold text-jp-gray-900 dark:text-white">
            {React.string(isEditMode ? "Edit Widget" : "Add Widget")}
          </h2>
          <p className="text-xs text-gray-400 mt-0.5">
            {React.string("Configure your chart visualization and data source")}
          </p>
        </div>
        <button className="p-2 rounded-lg hover:bg-gray-200 transition-colors" onClick={_ => onClose()}>
          <Icon name="nd-cross" size=18 />
        </button>
      </div>
      // ── Scrollable body ──
      <div className="flex-1 overflow-y-auto px-6 py-5 flex flex-col gap-8">
        // ═══════════════════════════════════════
        // SECTION 1: General
        // ═══════════════════════════════════════
        <div>
          {sectionTitle("General", ~subtitle="Basic widget information")}
          <div className="flex flex-col gap-4">
            <div>
              <label className="text-xs font-medium text-gray-600 mb-1 block">
                {React.string("Widget Name *")}
              </label>
              <input
                type_="text"
                value={widgetName}
                onChange={evt => setWidgetName(_ => ReactEvent.Form.target(evt)["value"])}
                placeholder="e.g. Payment Success Rate by Connector"
                className="w-full px-3 py-2.5 border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 dark:bg-jp-gray-950 dark:text-white dark:border-gray-700"
              />
            </div>
            <div>
              <label className="text-xs font-medium text-gray-600 mb-1 block">
                {React.string("Description (optional)")}
              </label>
              <input
                type_="text"
                value={description}
                onChange={evt => setDescription(_ => ReactEvent.Form.target(evt)["value"])}
                placeholder="Brief description of this widget"
                className="w-full px-3 py-2.5 border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 dark:bg-jp-gray-950 dark:text-white dark:border-gray-700"
              />
            </div>
          </div>
        </div>
        // ═══════════════════════════════════════
        // SECTION 2: Visualization
        // ═══════════════════════════════════════
        <div>
          {sectionTitle("Visualization", ~subtitle="Choose how to display your data")}
          <div className="grid grid-cols-3 gap-2">
            {chartTypeOptions
            ->Array.map(opt => {
              let isActive = chartType === opt.value
              <button
                key={opt.label}
                className={`flex flex-col items-center gap-1.5 p-3 rounded-lg border-2 transition-all ${isActive
                    ? "border-blue-500 bg-blue-50 dark:bg-blue-900/20 shadow-sm"
                    : "border-gray-200 dark:border-gray-700 hover:border-gray-300 hover:bg-gray-50"}`}
                onClick={_ => setChartType(_ => opt.value)}>
                {WidgetIcons.getChartIcon(opt.value, ~isActive)}
                <span
                  className={`text-xs font-medium ${isActive
                      ? "text-blue-700"
                      : "text-gray-600"}`}>
                  {React.string(opt.label)}
                </span>
                <span className="text-[10px] text-gray-400"> {React.string(opt.description)} </span>
              </button>
            })
            ->React.array}
          </div>
        </div>
        // ═══════════════════════════════════════
        // SECTION 3: Data Source
        // ═══════════════════════════════════════
        <div>
          {sectionTitle("Data Source", ~subtitle="Select the analytics domain")}
          <div className="grid grid-cols-2 gap-2">
            {domainOptions
            ->Array.map(opt => {
              let isActive = domain === opt.value
              <button
                key={opt.label}
                className={`flex items-center gap-3 p-3 rounded-lg border-2 text-left transition-all ${isActive
                    ? "border-blue-500 bg-blue-50 dark:bg-blue-900/20"
                    : "border-gray-200 dark:border-gray-700 hover:border-gray-300"}`}
                onClick={_ => handleDomainChange(opt.value)}>
                {WidgetIcons.getDomainIcon(opt.value, ~isActive)}
                <div>
                  <p
                    className={`text-sm font-medium ${isActive
                        ? "text-blue-700"
                        : "text-gray-700 dark:text-gray-300"}`}>
                    {React.string(opt.label)}
                  </p>
                  <p className="text-[10px] text-gray-400">
                    {React.string(
                      `${opt.description} \u2022 ${opt.metricsCount->Int.toString} metrics`,
                    )}
                  </p>
                </div>
              </button>
            })
            ->React.array}
          </div>
        </div>
        // ═══════════════════════════════════════
        // SECTION 4: Metrics
        // ═══════════════════════════════════════
        <div>
          {sectionTitle(
            "Metrics *",
            ~subtitle="Select one or more metrics to visualize",
          )}
          <div className="flex flex-col gap-1 max-h-64 overflow-y-auto border rounded-lg p-2 bg-gray-50 dark:bg-jp-gray-950">
            {availableMetrics
            ->Array.map(metric => {
              let isSelected = selectedMetrics->Array.includes(metric.value)
              <label
                key={metric.value}
                className={`flex items-start gap-3 p-2.5 rounded-md cursor-pointer transition-colors ${isSelected
                    ? "bg-blue-50 dark:bg-blue-900/20"
                    : "hover:bg-white dark:hover:bg-gray-800"}`}>
                <input
                  type_="checkbox"
                  checked={isSelected}
                  onChange={_ => toggleMetric(metric.value)}
                  className="mt-0.5 text-blue-600 rounded"
                />
                <div className="flex-1">
                  <div className="flex items-center gap-2">
                    <p
                      className={`text-sm ${isSelected
                          ? "text-blue-700 font-medium"
                          : "text-gray-700 dark:text-gray-300"}`}>
                      {React.string(metric.label)}
                    </p>
                    <span className="text-[9px] px-1.5 py-0.5 rounded bg-gray-200 dark:bg-gray-700 text-gray-500">
                      {React.string(metric.category)}
                    </span>
                  </div>
                  <p className="text-[10px] text-gray-400 mt-0.5">
                    {React.string(metric.description)}
                  </p>
                </div>
              </label>
            })
            ->React.array}
          </div>
          {if selectedMetrics->Array.length > 0 {
            <div className="flex flex-wrap gap-1.5 mt-2">
              {selectedMetrics
              ->Array.map(m => {
                let label =
                  availableMetrics
                  ->Array.find(opt => opt.value === m)
                  ->Option.map(opt => opt.label)
                  ->Option.getOr(m)
                <span
                  key={m}
                  className="inline-flex items-center gap-1 px-2 py-1 bg-blue-100 text-blue-700 text-xs rounded-full">
                  {React.string(label)}
                  <button
                    className="hover:text-blue-900"
                    onClick={_ => toggleMetric(m)}>
                    {React.string({`\u00d7`})}
                  </button>
                </span>
              })
              ->React.array}
            </div>
          } else {
            React.null
          }}
        </div>
        // ═══════════════════════════════════════
        // SECTION 5: Group By / Dimension
        // ═══════════════════════════════════════
        <div>
          {sectionTitle("Group By", ~subtitle="Split data by a dimension (optional)")}
          <select
            value={groupBy}
            onChange={evt => setGroupBy(_ => ReactEvent.Form.target(evt)["value"])}
            className="w-full px-3 py-2.5 border rounded-lg text-sm bg-white dark:bg-jp-gray-950 dark:text-white dark:border-gray-700 focus:outline-none focus:ring-2 focus:ring-blue-500">
            <option value=""> {React.string("None (aggregate)")} </option>
            {availableDimensions
            ->Array.map(dim =>
              <option key={dim.value} value={dim.value}> {React.string(dim.label)} </option>
            )
            ->React.array}
          </select>
        </div>
        // ═══════════════════════════════════════
        // SECTION 6: Time Granularity (for time-series charts)
        // ═══════════════════════════════════════
        {if needsTimeSeries(chartType) {
          <div>
            {sectionTitle("Time Granularity", ~subtitle="Data aggregation interval")}
            <div className="flex gap-2">
              {granularityOptions
              ->Array.map(opt => {
                let isActive = granularity === opt.value
                <button
                  key={opt.value}
                  className={`px-4 py-2 rounded-lg border-2 text-sm font-medium transition-all ${isActive
                      ? "border-blue-500 bg-blue-50 text-blue-700"
                      : "border-gray-200 text-gray-600 hover:border-gray-300"}`}
                  onClick={_ => setGranularity(_ => opt.value)}>
                  {React.string(opt.label)}
                </button>
              })
              ->React.array}
            </div>
          </div>
        } else {
          React.null
        }}
        // ═══════════════════════════════════════
        // SECTION 7: Size
        // ═══════════════════════════════════════
        <div>
          {sectionTitle("Widget Size", ~subtitle="Width (columns) and height")}
          <div className="flex flex-col gap-5">
            // Visual size preview
            {
              let previewWPct = Float.fromInt(widgetW) /. 12.0 *. 100.0
              let previewWStr = previewWPct->Js.Float.toFixedWithPrecision(~digits=1)
              let previewHPx = widgetH * 8 // Scaled down (80px / 10)
              <div className="bg-gray-100 dark:bg-jp-gray-950 rounded-lg p-3">
                <div className="bg-gray-50 dark:bg-gray-800 rounded border border-dashed border-gray-300 dark:border-gray-600 relative" style={ReactDOM.Style.make(~height="100px", ())}>
                  <div
                    className="bg-blue-100 dark:bg-blue-900/30 border-2 border-blue-400 rounded transition-all duration-200"
                    style={ReactDOM.Style.make(
                      ~width=`${previewWStr}%`,
                      ~height=`${previewHPx->Int.toString}px`,
                      ~minHeight="16px",
                      ~maxHeight="100px",
                      (),
                    )}
                  />
                </div>
                <div className="flex items-center justify-center gap-3 mt-2">
                  <span className="text-xs text-blue-600 font-semibold">
                    {React.string(`${widgetW->Int.toString}/12 wide`)}
                  </span>
                  <span className="text-xs text-gray-300"> {React.string("\u2022")} </span>
                  <span className="text-xs text-blue-600 font-semibold">
                    {React.string(`${widgetH->Int.toString}h tall (${(widgetH * 80)->Int.toString}px)`)}
                  </span>
                </div>
              </div>
            }
            // Width slider
            <div>
              <div className="flex items-center gap-2 mb-2">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#6b7280" strokeWidth="2" strokeLinecap="round">
                  <line x1="5" y1="12" x2="19" y2="12" />
                  <polyline points="5,8 1,12 5,16" />
                  <polyline points="19,8 23,12 19,16" />
                </svg>
                <span className="text-xs font-medium text-gray-600">
                  {React.string("Width")}
                </span>
                <span className="ml-auto text-xs text-blue-600 font-semibold">
                  {React.string(`${widgetW->Int.toString}/12`)}
                </span>
              </div>
              <input
                type_="range"
                min="2"
                max="12"
                step=1.0
                value={widgetW->Int.toString}
                onChange={evt => {
                  let v = ReactEvent.Form.target(evt)["value"]
                  setWidgetW(_ => v->Int.fromString->Option.getOr(6))
                }}
                className="w-full accent-blue-600"
              />
              <div className="flex justify-between text-[10px] text-gray-400 mt-1">
                <span> {React.string("2 cols")} </span>
                <span> {React.string("6 cols")} </span>
                <span> {React.string("12 cols")} </span>
              </div>
            </div>
            // Height slider
            <div>
              <div className="flex items-center gap-2 mb-2">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#6b7280" strokeWidth="2" strokeLinecap="round">
                  <line x1="12" y1="5" x2="12" y2="19" />
                  <polyline points="8,5 12,1 16,5" />
                  <polyline points="8,19 12,23 16,19" />
                </svg>
                <span className="text-xs font-medium text-gray-600">
                  {React.string("Height")}
                </span>
                <span className="ml-auto text-xs text-blue-600 font-semibold">
                  {React.string(`${widgetH->Int.toString} units (${(widgetH * 80)->Int.toString}px)`)}
                </span>
              </div>
              <input
                type_="range"
                min="2"
                max="10"
                step=1.0
                value={widgetH->Int.toString}
                onChange={evt => {
                  let v = ReactEvent.Form.target(evt)["value"]
                  setWidgetH(_ => v->Int.fromString->Option.getOr(4))
                }}
                className="w-full accent-blue-600"
              />
              <div className="flex justify-between text-[10px] text-gray-400 mt-1">
                <span> {React.string("2 (160px)")} </span>
                <span> {React.string("6 (480px)")} </span>
                <span> {React.string("10 (800px)")} </span>
              </div>
            </div>
          </div>
        </div>
        // ═══════════════════════════════════════
        // SECTION 8: Live Preview
        // ═══════════════════════════════════════
        {if selectedMetrics->Array.length > 0 {
          let previewWidget: CustomDashboardTypes.widget = {
            widgetId: "preview",
            widgetName: widgetName->isNonEmptyString ? widgetName : "Preview",
            chartType,
            position: {x: 0, y: 0, w: 12, h: 4},
            config: {
              domain,
              metrics: selectedMetrics,
              groupBy: groupBy->isNonEmptyString ? [groupBy] : [],
              filters: JSON.Encode.object(Dict.make()),
              granularity: if WidgetConfiguratorUtils.needsTimeSeries(chartType) {
                Some(granularity)
              } else {
                None
              },
              timeRangePreset: None,
            },
          }
          <div>
            {sectionTitle("Preview", ~subtitle="Live chart preview with current date range")}
            <div className="border rounded-lg bg-white dark:bg-jp-gray-950 overflow-hidden">
              <div className="p-3 border-b bg-gray-50 dark:bg-jp-gray-lightgray_background">
                <p className="text-xs font-medium text-gray-600 dark:text-gray-400">
                  {React.string(widgetName->isNonEmptyString ? widgetName : "Untitled Widget")}
                  <span className="text-gray-400 ml-2">
                    {React.string(
                      `\u2014 ${CustomDashboardUtils.getChartTypeLabel(chartType)} \u2022 ${CustomDashboardUtils.getDomainLabel(domain)}`,
                    )}
                  </span>
                </p>
              </div>
              <div className="p-2" style={ReactDOM.Style.make(~minHeight="250px", ())}>
                <GenericChartRenderer widget=previewWidget />
              </div>
            </div>
          </div>
        } else {
          <div>
            {sectionTitle("Preview")}
            <div
              className="border-2 border-dashed rounded-lg p-8 flex flex-col items-center justify-center text-gray-400"
              style={ReactDOM.Style.make(~minHeight="200px", ())}>
              <Icon name="chart-area" size=32 className="text-gray-300 mb-2" />
              <p className="text-sm"> {React.string("Select metrics to see preview")} </p>
            </div>
          </div>
        }}
        // ═══════════════════════════════════════
        // SECTION 9: Summary
        // ═══════════════════════════════════════
        <div className="bg-gray-50 dark:bg-jp-gray-950 rounded-lg p-4 border">
          {sectionTitle("Summary")}
          <div className="grid grid-cols-2 gap-3 text-xs">
            <div>
              <span className="text-gray-400"> {React.string("Chart: ")} </span>
              <span className="text-gray-700 dark:text-gray-300 font-medium">
                {React.string(CustomDashboardUtils.getChartTypeLabel(chartType))}
              </span>
            </div>
            <div>
              <span className="text-gray-400"> {React.string("Domain: ")} </span>
              <span className="text-gray-700 dark:text-gray-300 font-medium">
                {React.string(CustomDashboardUtils.getDomainLabel(domain))}
              </span>
            </div>
            <div>
              <span className="text-gray-400"> {React.string("Metrics: ")} </span>
              <span className="text-gray-700 dark:text-gray-300 font-medium">
                {React.string(selectedMetrics->Array.length->Int.toString ++ " selected")}
              </span>
            </div>
            <div>
              <span className="text-gray-400"> {React.string("Group By: ")} </span>
              <span className="text-gray-700 dark:text-gray-300 font-medium">
                {React.string(groupBy->isNonEmptyString ? groupBy : "None")}
              </span>
            </div>
            <div>
              <span className="text-gray-400"> {React.string("Size: ")} </span>
              <span className="text-gray-700 dark:text-gray-300 font-medium">
                {React.string(
                  `${widgetW->Int.toString}/12 \u00d7 ${widgetH->Int.toString}h`,
                )}
              </span>
            </div>
            {if needsTimeSeries(chartType) {
              <div>
                <span className="text-gray-400"> {React.string("Granularity: ")} </span>
                <span className="text-gray-700 dark:text-gray-300 font-medium">
                  {React.string(
                    granularityOptions
                    ->Array.find(g => g.value === granularity)
                    ->Option.map(g => g.label)
                    ->Option.getOr(granularity),
                  )}
                </span>
              </div>
            } else {
              React.null
            }}
          </div>
        </div>
      </div>
      // ── Footer ──
      <div className="flex items-center justify-between px-6 py-4 border-t bg-gray-50 dark:bg-jp-gray-950">
        <div className="text-xs text-gray-400">
          {if !canSubmit {
            React.string("Fill name and select at least one metric")
          } else {
            React.string("Ready to save")
          }}
        </div>
        <div className="flex items-center gap-3">
          <Button text="Cancel" buttonType={Secondary} onClick={_ => onClose()} />
          <Button
            text={isEditMode ? "Save Widget" : "Add Widget"}
            buttonType={Primary}
            onClick={_ => handleSubmit()->ignore}
            buttonState={canSubmit ? Normal : Disabled}
          />
        </div>
      </div>
    </div>
  </div>
}
