@react.component
let make = (
  ~dashboardName,
  ~viewMode: CustomDashboardTypes.dashboardViewMode,
  ~onBack,
  ~onEdit,
  ~onSave,
  ~onCancel,
  ~onAddWidget,
) => {
  <div className="flex items-center justify-between">
    <div className="flex items-center gap-3">
      <button
        className="flex items-center gap-1 text-sm text-blue-600 hover:text-blue-700"
        onClick={_ => onBack()}>
        <Icon name="arrow-left" size=14 />
        {React.string(
          switch viewMode {
          | View => "Back to My Dashboards"
          | Edit => "Back"
          },
        )}
      </button>
      <span className="text-grey-text"> {React.string("|")} </span>
      <p className="text-xl font-semibold text-jp-gray-900 dark:text-white">
        {React.string(dashboardName)}
        {switch viewMode {
        | Edit =>
          <span className="text-sm font-normal text-grey-text ml-2">
            {React.string("(Editing)")}
          </span>
        | View => React.null
        }}
      </p>
    </div>
    <div className="flex items-center gap-2">
      {switch viewMode {
      | View => <Button text="Edit" buttonType={Secondary} onClick={_ => onEdit()} />
      | Edit =>
        <>
          <Button text="+ Add Widget" buttonType={Primary} onClick={_ => onAddWidget()} />
          <Button text="Save" buttonType={Primary} onClick={_ => onSave()} />
          <Button text="Cancel" buttonType={Secondary} onClick={_ => onCancel()} />
        </>
      }}
    </div>
  </div>
}
