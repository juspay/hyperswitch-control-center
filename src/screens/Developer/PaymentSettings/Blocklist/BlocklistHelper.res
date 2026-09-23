module ActionIcon = {
  @react.component
  let make = (~iconName, ~description, ~isDisabled, ~onClick) => {
    <ToolTip
      description
      toolTipPosition=Top
      toolTipFor={<Icon
        name=iconName
        size=16
        onClick={_ => isDisabled ? () : onClick()}
        className={isDisabled
          ? "cursor-not-allowed text-nd_gray-300"
          : "cursor-pointer text-nd_gray-600"}
      />}
    />
  }
}

module CloneTargetsCell = {
  @react.component
  let make = (
    ~targets: array<BlocklistTypes.cloneTargetMetadata>,
    ~profileList: array<OMPSwitchTypes.ompListTypes>,
  ) => {
    open Typography
    open BlocklistUtils

    let targetDetails =
      <div className="flex flex-col gap-2">
        {targets
        ->Array.map(target =>
          <div key={target.profile_id} className="flex flex-col">
            <span className={body.sm.semibold}>
              {OMPSwitchUtils.currentOMPName(profileList, target.profile_id)->React.string}
            </span>
            <span className={body.xs.regular}>
              {`${target.status->normalizeStatus} · ${target.processed_rows->Int.toString} entries copied`->React.string}
            </span>
            {target.error_message->LogicUtils.mapOptionOrDefault(React.null, errorMessage =>
              <span className={`${body.xs.regular} text-nd_red-400 break-words`}>
                {errorMessage->React.string}
              </span>
            )}
          </div>
        )
        ->React.array}
      </div>

    <ToolTip
      descriptionComponent=targetDetails
      toolTipPosition=Top
      toolTipFor={<span
        className={`${body.md.medium} text-nd_gray-600 cursor-pointer underline decoration-dotted`}>
        {targets->getCloneTargetsSummary->React.string}
      </span>}
    />
  }
}
