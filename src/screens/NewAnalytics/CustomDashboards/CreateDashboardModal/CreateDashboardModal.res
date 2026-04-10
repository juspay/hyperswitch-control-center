@react.component
let make = (~onClose, ~onSuccess) => {
  open LogicUtils
  open APIUtils
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()
  let (name, setName) = React.useState(_ => "")
  let (description, setDescription) = React.useState(_ => "")
  let (selectedTemplate, setSelectedTemplate) = React.useState(_ => 0)
  let (isSubmitting, setIsSubmitting) = React.useState(_ => false)

  let handleCreate = async () => {
    let trimmedName = name->String.trim
    if trimmedName->isNonEmptyString {
      try {
        setIsSubmitting(_ => true)
        let url = getURL(~entityName=V1(USERS), ~userType=#USER_DATA, ~methodType=Post)
        let template = CustomDashboardConstants.templates->Array.get(selectedTemplate)
        // Generate unique widget IDs to prevent collision across dashboards
        let widgets = template->Option.mapOr([], t =>
          t.widgets->Array.map(w => {
            ...w,
            widgetId: `${Date.now()->Float.toString}-${Math.random()->Float.toString}`,
          })
        )
        
        let data = Dict.make()
        data->Dict.set("dashboard_name", trimmedName->JSON.Encode.string)
        
        let trimmedDesc = description->String.trim
        if trimmedDesc->isNonEmptyString {
          data->Dict.set("description", trimmedDesc->JSON.Encode.string)
        }
        if widgets->Array.length > 0 {
          data->Dict.set("widgets", widgets->CustomDashboardUtils.serializeWidgets)
        }
        
        let body = CustomDashboardUtils.buildOperationBody(
          ~operationType="Create",
          ~data=data->JSON.Encode.object,
        )
        let _ = await updateDetails(url, body, Post)
        
        let now = Date.make()->Date.toISOString
        let newDashboard: CustomDashboardTypes.dashboard = {
          dashboardName: trimmedName,
          description: trimmedDesc->isNonEmptyString ? Some(trimmedDesc) : None,
          isDefault: false,
          widgets,
          createdAt: now,
          updatedAt: now,
        }
        showToast(~message="Dashboard created", ~toastType=ToastSuccess)
        onSuccess(newDashboard)
      } catch {
      | _ => {
          showToast(~message="Failed to create dashboard", ~toastType=ToastError)
          setIsSubmitting(_ => false)
        }
      }
    }
  }

  <div
    className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50"
    onClick={evt => {
      evt->JsxEvent.Mouse.stopPropagation
      onClose()
    }}>
    <div
      className="bg-white dark:bg-jp-gray-lightgray_background rounded-lg shadow-xl w-full max-w-lg mx-4"
      onClick={evt => evt->JsxEvent.Mouse.stopPropagation}>
      <div className="flex items-center justify-between p-5 border-b">
        <p className="text-lg font-semibold text-jp-gray-900 dark:text-white">
          {React.string("Create New Dashboard")}
        </p>
        <button
          className="p-1 rounded hover:bg-gray-100 dark:hover:bg-jp-gray-lightgray_background"
          onClick={_ => onClose()}>
          <Icon name="close" size=16 />
        </button>
      </div>
      <div className="p-5 flex flex-col gap-5">
        <div className="flex flex-col gap-1.5">
          <label className="text-sm font-medium text-jp-gray-900 dark:text-white">
            {React.string("Dashboard Name *")}
          </label>
          <input
            type_="text"
            value={name}
            onChange={evt => {
              let val = ReactEvent.Form.target(evt)["value"]
              setName(_ => val)
            }}
            placeholder="My Payment Overview"
            className="w-full px-3 py-2 border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 dark:bg-jp-gray-lightgray_background dark:text-white"
          />
        </div>
        <div className="flex flex-col gap-1.5">
          <label className="text-sm font-medium text-jp-gray-900 dark:text-white">
            {React.string("Description (optional)")}
          </label>
          <textarea
            value={description}
            onChange={evt => {
              let val = ReactEvent.Form.target(evt)["value"]
              setDescription(_ => val)
            }}
            placeholder="Daily payment monitoring dashboard"
            rows=2
            className="w-full px-3 py-2 border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 dark:bg-jp-gray-lightgray_background dark:text-white resize-none"
          />
        </div>
        <div className="flex flex-col gap-1.5">
          <label className="text-sm font-medium text-jp-gray-900 dark:text-white">
            {React.string("Start from")}
          </label>
          <div className="flex flex-col gap-2">
            {CustomDashboardConstants.templates
            ->Array.mapWithIndex((template, index) =>
              <label
                key={index->Int.toString}
                className={`flex items-center gap-3 p-3 border rounded-lg cursor-pointer transition-colors ${selectedTemplate ===
                    index
                    ? "border-blue-500 bg-blue-50 dark:bg-blue-900/20"
                    : "hover:bg-gray-50 dark:hover:bg-jp-gray-lightgray_background"}`}>
                <input
                  type_="radio"
                  name="template"
                  checked={selectedTemplate === index}
                  onChange={_ => setSelectedTemplate(_ => index)}
                  className="text-blue-600"
                />
                <div>
                  <p className="text-sm font-medium text-jp-gray-900 dark:text-white">
                    {React.string(template.label)}
                  </p>
                  <p className="text-xs text-grey-text">
                    {React.string(template.description)}
                  </p>
                </div>
              </label>
            )
            ->React.array}
          </div>
        </div>
      </div>
      <div className="flex items-center justify-end gap-3 p-5 border-t">
        <Button text="Cancel" buttonType={Secondary} onClick={_ => onClose()} />
        <Button
          text="Create"
          buttonType={Primary}
          onClick={_ => handleCreate()->ignore}
          buttonState={isSubmitting || name->String.trim->String.length === 0
            ? Disabled
            : Normal}
        />
      </div>
    </div>
  </div>
}
