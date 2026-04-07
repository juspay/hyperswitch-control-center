@react.component
let make = (~onOpenDashboard) => {
  open APIUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (dashboards, setDashboards) = React.useState(_ => [])
  let (showCreateModal, setShowCreateModal) = React.useState(_ => false)

  let fetchDashboards = async () => {
    try {
      setScreenState(_ => Loading)
      let url = getURL(
        ~entityName=V1(USERS),
        ~userType=#USER_DATA,
        ~methodType=Get,
        ~queryParameters=Some("keys=CustomDashboards"),
      )
      let response = await fetchDetails(url)
      let parsed = CustomDashboardUtils.parseDashboards(response)
      setDashboards(_ => parsed)
      setScreenState(_ => Success)
    } catch {
    | _ =>
      setDashboards(_ => [])
      setScreenState(_ => Success)
    }
  }

  React.useEffect(() => {
    fetchDashboards()->ignore
    None
  }, [])

  let handleDelete = async (dashboardName: string) => {
    try {
      let url = getURL(~entityName=V1(USERS), ~userType=#USER_DATA, ~methodType=Post)
      let data = Dict.make()
      data->Dict.set("dashboard_name", dashboardName->JSON.Encode.string)
      let body = CustomDashboardUtils.buildOperationBody(
        ~operationType="Delete",
        ~data=data->JSON.Encode.object,
      )
      let _ = await updateDetails(url, body, Post)
      showToast(~message="Dashboard deleted", ~toastType=ToastSuccess)
      fetchDashboards()->ignore
    } catch {
    | _ => showToast(~message="Failed to delete dashboard", ~toastType=ToastError)
    }
  }

  let handleSetDefault = async (dashboardName: string) => {
    try {
      let url = getURL(~entityName=V1(USERS), ~userType=#USER_DATA, ~methodType=Post)
      let data = Dict.make()
      data->Dict.set("dashboard_name", dashboardName->JSON.Encode.string)
      data->Dict.set("is_default", true->JSON.Encode.bool)
      let body = CustomDashboardUtils.buildOperationBody(
        ~operationType="Update",
        ~data=data->JSON.Encode.object,
      )
      let _ = await updateDetails(url, body, Post)
      showToast(~message="Default updated", ~toastType=ToastSuccess)
      fetchDashboards()->ignore
    } catch {
    | _ => showToast(~message="Failed to update dashboard", ~toastType=ToastError)
    }
  }

  let handleRename = async (dashboardName: string, newName: string) => {
    try {
      let url = getURL(~entityName=V1(USERS), ~userType=#USER_DATA, ~methodType=Post)
      let data = Dict.make()
      data->Dict.set("dashboard_name", dashboardName->JSON.Encode.string)
      data->Dict.set("new_dashboard_name", newName->JSON.Encode.string)
      let body = CustomDashboardUtils.buildOperationBody(
        ~operationType="Update",
        ~data=data->JSON.Encode.object,
      )
      let _ = await updateDetails(url, body, Post)
      showToast(~message="Dashboard renamed", ~toastType=ToastSuccess)
      fetchDashboards()->ignore
    } catch {
    | _ => showToast(~message="Failed to rename dashboard", ~toastType=ToastError)
    }
  }

  let handleDuplicate = async (dashboardName: string) => {
    try {
      let url = getURL(~entityName=V1(USERS), ~userType=#USER_DATA, ~methodType=Post)
      // Find the source dashboard to copy its widgets
      let sourceDashboard = dashboards->Array.find(d => d.dashboardName === dashboardName)
      let widgets = switch sourceDashboard {
      | Some(d) => d.widgets
      | None => []
      }
      let data = Dict.make()
      data->Dict.set(
        "dashboard_name",
        `${dashboardName} (Copy)`->JSON.Encode.string,
      )
      data->Dict.set("description", `Duplicated from ${dashboardName}`->JSON.Encode.string)
      if widgets->Array.length > 0 {
        data->Dict.set("widgets", widgets->Identity.genericTypeToJson)
      }
      let body = CustomDashboardUtils.buildOperationBody(
        ~operationType="Create",
        ~data=data->JSON.Encode.object,
      )
      let _ = await updateDetails(url, body, Post)
      showToast(~message="Dashboard duplicated", ~toastType=ToastSuccess)
      fetchDashboards()->ignore
    } catch {
    | _ => showToast(~message="Failed to duplicate dashboard", ~toastType=ToastError)
    }
  }

  let handleCreateSuccess = (dashboard: CustomDashboardTypes.dashboard) => {
    setShowCreateModal(_ => false)
    fetchDashboards()->ignore
    onOpenDashboard(dashboard)
  }

  <PageLoaderWrapper screenState>
    <div className="mt-5 flex flex-col gap-6">
      <div className="flex items-center justify-between">
        <p className="text-xl font-semibold text-jp-gray-900 dark:text-white">
          {React.string("My Dashboards")}
        </p>
        {if dashboards->Array.length > 0 {
          <Button
            text="+ Create Dashboard"
            buttonType={Primary}
            onClick={_ => setShowCreateModal(_ => true)}
          />
        } else {
          React.null
        }}
      </div>
      {if dashboards->Array.length === 0 {
        <DashboardEmptyState onCreateClick={() => setShowCreateModal(_ => true)} />
      } else {
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {dashboards
          ->Array.mapWithIndex((dashboard, index) =>
            <DashboardCard
              key={index->Int.toString}
              dashboard
              onOpen={() => onOpenDashboard(dashboard)}
              onDelete={() => handleDelete(dashboard.dashboardName)->ignore}
              onSetDefault={() => handleSetDefault(dashboard.dashboardName)->ignore}
              onRename={newName => handleRename(dashboard.dashboardName, newName)->ignore}
              onDuplicate={() => handleDuplicate(dashboard.dashboardName)->ignore}
            />
          )
          ->React.array}
          {if dashboards->Array.length < CustomDashboardConstants.maxDashboards {
            <div
              className="border-2 border-dashed border-blue-300 rounded-lg bg-blue-50/30 dark:bg-blue-900/10 flex flex-col items-center justify-center gap-3 min-h-[180px] cursor-pointer hover:bg-blue-50 dark:hover:bg-blue-900/20 transition-colors"
              onClick={_ => setShowCreateModal(_ => true)}>
              <Icon name="nd-plus" size=20 className="text-blue-500" />
              <span className="text-sm font-medium text-blue-600">
                {React.string("Create Dashboard")}
              </span>
              <span className="text-xs text-gray-400 text-center">
                {React.string("Start building your")}
                <br />
                {React.string("custom analytics view")}
              </span>
            </div>
          } else {
            React.null
          }}
        </div>
      }}
      {if showCreateModal {
        <CreateDashboardModal
          onClose={() => setShowCreateModal(_ => false)} onSuccess={handleCreateSuccess}
        />
      } else {
        React.null
      }}
    </div>
  </PageLoaderWrapper>
}
