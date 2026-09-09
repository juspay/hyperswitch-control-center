module GlobalDateFilterBanner = {
  @react.component
  let make = () => {
    let businessProfile = ReconEngineAtoms.businessProfileAtom->Recoil.useRecoilValueFromAtom

    let dateRangeDescription = "Date range applies to each entry's effective date from the source record, not when the file was ingested."

    let description = switch businessProfile {
    | Some(profile) =>
      switch profile.timezone {
      | "" => dateRangeDescription
      | timezone =>
        `${dateRangeDescription} Timestamps are displayed in your profile timezone (${timezone}).`
      }
    | None => dateRangeDescription
    }

    <div className="my-3 w-full">
      <AlertV2Binding
        alertType=Primary
        slot={{slot: <Icon name="nd-toast-info" size=20 className="text-nd_primary_blue-450" />}}
        description
      />
    </div>
  }
}
