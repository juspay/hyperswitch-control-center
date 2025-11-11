open AuditTrailStepIndicatorTypes

@react.component
let make = (~sections: array<section>) => {
  <div className="flex flex-col gap-y-6">
    <div className="w-full h-full p-2 md:p-6 bg-white rounded-lg border border-nd_gray-150">
      <div className="flex flex-col gap-y-12">
        {sections
        ->Array.mapWithIndex((section, sectionIndex) => {
          let hasReason = switch section.reasonText {
          | Some(reason) => reason->LogicUtils.isNonEmptyString
          | None => false
          }

          <React.Fragment key={LogicUtils.randomString(~length=10)}>
            <div className="flex flex-row gap-8 items-start">
              <div key={section.id} className="flex gap-x-3 items-center relative">
                <div
                  className="flex items-center justify-center rounded-full w-10 h-10 border bg-nd_gray-50 relative z-10">
                  {section.id->React.string}
                </div>
                <RenderIf condition={sectionIndex != sections->Array.length - 1}>
                  <div className={`absolute top-8 left-5 border-l border-gray-150 h-32`} />
                </RenderIf>
              </div>
              <div
                className="w-full cursor-pointer hover:scale-[1.002] transition-transform hover:shadow-sm rounded-lg"
                onClick={section.onClick}>
                {switch section.customComponent {
                | Some(customComponent) => customComponent
                | None => React.null
                }}
              </div>
            </div>
            <RenderIf condition={hasReason && sectionIndex != sections->Array.length - 1}>
              <div className="flex flex-row gap-8 items-start ">
                <div className="flex gap-x-3 items-center relative">
                  <div
                    className="flex items-center justify-center w-10 h-10 bg-nd_gray-50 relative z-10 rounded-full border border-nd_gray-300">
                    <Icon name="nd-pencil-edit-box" size=16 className="text-nd_gray-500" />
                  </div>
                  <div className="absolute top-8 left-5 border-l border-gray-150 h-32" />
                </div>
                <div className="w-full rounded-lg p-5 bg-nd_gray-25 border border-nd_gray-150">
                  <p className="text-sm text-nd_gray-600">
                    {section.reasonText->Option.getOr("")->React.string}
                  </p>
                </div>
              </div>
            </RenderIf>
          </React.Fragment>
        })
        ->React.array}
      </div>
    </div>
  </div>
}
