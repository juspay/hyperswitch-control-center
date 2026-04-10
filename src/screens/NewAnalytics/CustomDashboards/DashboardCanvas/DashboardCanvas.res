let reorder = (list, startIndex, endIndex) => {
  switch (list[startIndex], startIndex === endIndex) {
  | (None, _) | (_, true) => list
  | (Some(item), false) => {
      let without = list->Array.filterWithIndex((_, i) => i !== startIndex)
      let before = without->Array.slice(~start=0, ~end=endIndex)
      let after = without->Array.slice(~start=endIndex, ~end=without->Array.length)
      before->Array.concat([item])->Array.concat(after)
    }
  }
}

@react.component
let make = (~dashboard: CustomDashboardTypes.dashboard, ~onBack) => {
  open APIUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()
  let (viewMode, setViewMode) = React.useState(_ => CustomDashboardTypes.View)
  let (widgets, setWidgets) = React.useState(_ => dashboard.widgets)
  let (showConfigurator, setShowConfigurator) = React.useState(_ => false)
  let (editingWidget, setEditingWidget) = React.useState(
    (): option<CustomDashboardTypes.widget> => None,
  )

  // Refetch dashboard widgets from API to get fresh data after add/edit/remove
  let refetchWidgets = async () => {
    try {
      let url = getURL(
        ~entityName=V1(USERS),
        ~userType=#USER_DATA,
        ~methodType=Get,
        ~queryParameters=Some("keys=CustomDashboards"),
      )
      let response = await fetchDetails(url)
      let dashboards = CustomDashboardUtils.parseDashboards(response)
      let updated = dashboards->Array.find(d => d.dashboardName === dashboard.dashboardName)
      switch updated {
      | Some(d) => setWidgets(_ => d.widgets)
      | None => ()
      }
    } catch {
    | _ => showToast(~message="Failed to refresh widgets", ~toastType=ToastError)
    }
  }

  let handleRemoveWidget = async (widgetId: string) => {
    try {
      let url = getURL(~entityName=V1(USERS), ~userType=#USER_DATA, ~methodType=Post)
      let data = Dict.fromArray([
        ("dashboard_name", dashboard.dashboardName->JSON.Encode.string),
        ("widget_id", widgetId->JSON.Encode.string),
      ])
      let body = CustomDashboardUtils.buildOperationBody(
        ~operationType="RemoveWidget",
        ~data=data->JSON.Encode.object,
      )
      let _ = await updateDetails(url, body, Post)
      setWidgets(prev => prev->Array.filter(w => w.widgetId !== widgetId))
      showToast(~message="Widget removed", ~toastType=ToastSuccess)
    } catch {
    | _ => showToast(~message="Failed to remove widget", ~toastType=ToastError)
    }
  }

  let handleSave = async () => {
    try {
      let url = getURL(~entityName=V1(USERS), ~userType=#USER_DATA, ~methodType=Post)
      let layoutData = widgets->Array.map(widget => {
        let pos = widget.position
        let position = Dict.fromArray([
          ("x", pos.x->JSON.Encode.int),
          ("y", pos.y->JSON.Encode.int),
          ("w", pos.w->JSON.Encode.int),
          ("h", pos.h->JSON.Encode.int),
        ])
        Dict.fromArray([
          ("widget_id", widget.widgetId->JSON.Encode.string),
          ("position", position->JSON.Encode.object),
        ])->JSON.Encode.object
      })
      let data = Dict.fromArray([
        ("dashboard_name", dashboard.dashboardName->JSON.Encode.string),
        ("layout", layoutData->JSON.Encode.array),
      ])
      let body = CustomDashboardUtils.buildOperationBody(
        ~operationType="UpdateLayout",
        ~data=data->JSON.Encode.object,
      )
      let _ = await updateDetails(url, body, Post)
      showToast(~message="Dashboard saved", ~toastType=ToastSuccess)
      setViewMode(_ => View)
    } catch {
    | _ => showToast(~message="Failed to save layout", ~toastType=ToastError)
    }
  }

  let handleCancel = () => {
    setWidgets(_ => dashboard.widgets)
    setViewMode(_ => View)
  }

  let openAddWidget = () => {
    // FIX: Enforce widget limit before opening configurator
    if widgets->Array.length >= CustomDashboardConstants.maxWidgetsPerDashboard {
      showToast(
        ~message=`Maximum ${CustomDashboardConstants.maxWidgetsPerDashboard->Int.toString} widgets allowed per dashboard`,
        ~toastType=ToastWarning,
      )
    } else {
      setEditingWidget(_ => None)
      setShowConfigurator(_ => true)
    }
  }

  let openEditWidget = (widget: CustomDashboardTypes.widget) => {
    setEditingWidget(_ => Some(widget))
    setShowConfigurator(_ => true)
  }

  let handleConfiguratorSuccess = () => {
    setShowConfigurator(_ => false)
    setEditingWidget(_ => None)
    refetchWidgets()->ignore
  }

  let isEditMode = viewMode === Edit

  // All 12 literal classes so Tailwind won't purge any
  let getColSpanClass = (w: int) => {
    switch w {
    | 1 => "col-span-1"
    | 2 => "col-span-2"
    | 3 => "col-span-3"
    | 4 => "col-span-4"
    | 5 => "col-span-5"
    | 6 => "col-span-6"
    | 7 => "col-span-7"
    | 8 => "col-span-8"
    | 9 => "col-span-9"
    | 10 => "col-span-10"
    | 11 => "col-span-11"
    | _ => "col-span-12"
    }
  }

  let updateWidgetSize = (widgetId: string, ~w: int, ~h: int) => {
    setWidgets(prev =>
      prev->Array.map(widget =>
        if widget.widgetId === widgetId {
          {
            ...widget,
            position: {
              ...widget.position,
              w,
              h,
            },
          }
        } else {
          widget
        }
      )
    )
  }

  let onDragEnd = result => {
    let dest = Nullable.toOption(result["destination"])
    switch dest {
    | Some(destination) => {
        let sourceIndex = result["source"]["index"]
        let destIndex = destination["index"]
        if sourceIndex !== destIndex {
          setWidgets(prev => reorder(prev, sourceIndex, destIndex))
        }
      }
    | None => ()
    }
  }

  let renderWidgetGrid = () => {
    if widgets->Array.length > 0 {
      if isEditMode {
        <ReactBeautifulDND.DragDropContext onDragEnd>
          <ReactBeautifulDND.Droppable droppableId="dashboard-widgets" direction="vertical">
            {(droppableProvided, _snapshot) =>
              React.cloneElement(
                <div ref={droppableProvided["innerRef"]} className="dashboard-grid grid grid-cols-12 gap-4">
                  {widgets
                  ->Array.mapWithIndex((widget, index) =>
                    <ReactBeautifulDND.Draggable
                      key={widget.widgetId} draggableId={widget.widgetId} index>
                      {(draggableProvided, _dragSnapshot) =>
                        React.cloneElement(
                          <div
                            ref={draggableProvided["innerRef"]}
                            className={getColSpanClass(widget.position.w)}>
                            <WidgetCard
                              widget
                              isEditMode=true
                              onEdit={() => openEditWidget(widget)}
                              onRemove={() => handleRemoveWidget(widget.widgetId)->ignore}
                              onResize={(~w, ~h) => updateWidgetSize(widget.widgetId, ~w, ~h)}
                              dragHandleProps={draggableProvided["dragHandleProps"]}
                            />
                          </div>,
                          draggableProvided["draggableProps"],
                        )}
                    </ReactBeautifulDND.Draggable>
                  )
                  ->React.array}
                  {droppableProvided["placeholder"]}
                </div>,
                droppableProvided["droppableProps"],
              )}
          </ReactBeautifulDND.Droppable>
        </ReactBeautifulDND.DragDropContext>
      } else {
        <div className="dashboard-grid grid grid-cols-12 gap-4">
          {widgets
          ->Array.map(widget =>
            <div key={widget.widgetId} className={getColSpanClass(widget.position.w)}>
              <WidgetCard widget isEditMode=false />
            </div>
          )
          ->React.array}
        </div>
      }
    } else {
      <div
        className="flex flex-col items-center justify-center py-16 border-2 border-dashed rounded-lg text-grey-text cursor-pointer hover:bg-gray-50 transition-colors"
        onClick={_ =>
          if isEditMode {
            openAddWidget()
          }}>
        <Icon name="nd-plus" size=24 className="text-gray-400 mb-2" />
        <p className="text-lg font-medium"> {React.string("No widgets yet")} </p>
        <p className="text-sm mt-1">
          {React.string(
            isEditMode
              ? "Click here or use + Add Widget to get started"
              : "Click Edit and add widgets to build your dashboard",
          )}
        </p>
      </div>
    }
  }

  <div className="mt-5 flex flex-col gap-4">
    <DashboardToolbar
      dashboardName={dashboard.dashboardName}
      viewMode
      onBack
      onEdit={() => setViewMode(_ => Edit)}
      onSave={() => handleSave()->ignore}
      onCancel={handleCancel}
      onAddWidget={openAddWidget}
    />
    {if isEditMode {
      <p className="text-xs text-gray-400">
        {React.string("Drag widgets to reorder \u2022 Click size buttons to resize")}
      </p>
    } else {
      React.null
    }}
    {renderWidgetGrid()}
    {if isEditMode && widgets->Array.length > 0 {
      <div
        className="border-2 border-dashed border-gray-300 rounded-lg bg-gray-50 dark:bg-gray-800 flex flex-col items-center justify-center py-10 cursor-pointer hover:bg-gray-100 hover:border-blue-300 transition-colors"
        onClick={_ => openAddWidget()}>
        <Icon name="nd-plus" size=20 className="text-gray-400" />
        <span className="text-sm text-gray-400 mt-2"> {React.string("Add Widget")} </span>
        <span className="text-xs text-gray-300 mt-0.5">
          {React.string("Click to add a new chart")}
        </span>
      </div>
    } else {
      React.null
    }}
    {if showConfigurator {
      <WidgetConfigurator
        dashboardName={dashboard.dashboardName}
        editingWidget
        onClose={() => {
          setShowConfigurator(_ => false)
          setEditingWidget(_ => None)
        }}
        onSuccess={handleConfiguratorSuccess}
      />
    } else {
      React.null
    }}
  </div>
}
