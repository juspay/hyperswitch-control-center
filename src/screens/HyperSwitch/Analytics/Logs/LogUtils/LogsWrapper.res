module EventLogMobileView = {
  @react.component
  let make = (~wrapperFor: LogTypes.pageType) => {
    <>
      <div className="font-bold text-lg mb-5"> {"Events and logs"->React.string} </div>
      <div
        className="flex items-center gap-2 bg-white w-fit border-2 p-3 !opacity-100 rounded-lg text-md font-medium">
        <Icon name="info-circle-unfilled" size=16 />
        <div className={`text-lg font-medium opacity-50`}>
          {`To view logs for this ${(wrapperFor :> string)->String.toLowerCase} please switch to desktop mode`->React.string}
        </div>
      </div>
    </>
  }
}

@react.component
let make = (~wrapperFor, ~children) => {
  let {auditTrail} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let isSmallDevice = MatchMedia.useMatchMedia("(max-width: 700px)")

  <div className="overflow-x-scroll">
    <UIUtils.RenderIf condition={isSmallDevice}>
      <EventLogMobileView wrapperFor />
    </UIUtils.RenderIf>
    <UIUtils.RenderIf condition={!isSmallDevice && auditTrail}> {children} </UIUtils.RenderIf>
  </div>
}
