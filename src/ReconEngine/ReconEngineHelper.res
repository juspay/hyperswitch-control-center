module GlobalDateFilterBanner = {
  @react.component
  let make = () => {
    <div className="my-3 w-full">
      <AlertV2Binding
        alertType=Primary
        slot={{slot: <Icon name="nd-toast-info" size=20 className="text-nd_primary_blue-450" />}}
        description="Date range applies to each entry's effective date from the source record, not when the file was ingested."
      />
    </div>
  }
}
