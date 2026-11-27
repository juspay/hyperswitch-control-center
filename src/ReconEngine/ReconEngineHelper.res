module GlobalDateFilterBanner = {
  @react.component
  let make = () => {
    let businessProfile = ReconEngineAtoms.businessProfileAtom->Recoil.useRecoilValueFromAtom

    let dateRangeDescription = "Date range applies to each entry's effective date from the source record, not when the file was ingested."

    let description = switch businessProfile {
    | Some(profile) =>
      profile.timezone->LogicUtils.isNonEmptyString
        ? `${dateRangeDescription} Timestamps are displayed in your profile timezone (${profile.timezone}).`
        : dateRangeDescription
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

module ShowOlderVersionsButton = {
  @react.component
  let make = (~hasMore, ~isLoadingMore, ~onLoadMore) => {
    <RenderIf condition=hasMore>
      <div className="flex justify-center mt-4">
        <Button
          text="Show older versions"
          buttonType=Secondary
          buttonState={isLoadingMore ? Loading : Normal}
          onClick={_ => onLoadMore()}
        />
      </div>
    </RenderIf>
  }
}
