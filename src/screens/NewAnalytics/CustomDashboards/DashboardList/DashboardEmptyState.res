@react.component
let make = (~onCreateClick) => {
  <div className="flex flex-col items-center justify-center py-20 gap-6">
    <div className="flex flex-col items-center gap-2">
      <div
        className="w-20 h-20 rounded-xl bg-blue-50 dark:bg-jp-gray-lightgray_background flex items-center justify-center">
        <Icon name="graph-dark" size=32 />
      </div>
    </div>
    <div className="flex flex-col items-center gap-2 text-center">
      <p className="text-xl font-semibold text-jp-gray-900 dark:text-white">
        {React.string("Build Your Custom Dashboard")}
      </p>
      <p className="text-sm text-grey-text max-w-md">
        {React.string(
          "Combine charts from payments, refunds, and disputes into a single view tailored to your business needs.",
        )}
      </p>
    </div>
    <Button
      text="+ Create Dashboard"
      buttonType={Primary}
      onClick={_ => onCreateClick()}
    />
  </div>
}
