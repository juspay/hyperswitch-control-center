open AuditTrailStepIndicatorTypes
open Typography
open LogicUtils

@react.component
let make = (~sections: array<section>) => {
  <div className="flex flex-col gap-y-6">
    <div className="w-full h-full p-2 md:p-6 bg-white rounded-xl border border-nd_gray-150">
      <div className="flex flex-col gap-y-12">
        {sections
        ->Array.mapWithIndex((section, sectionIndex) => {
          let hasReason = switch section.reasonText {
          | Some(reason) => reason->isNonEmptyString
          | None => false
          }

          let modifiedByName =
            section.modifiedBy->mapOptionOrDefault("", user =>
              user.name->isNonEmptyString
                ? user.name->stringReplaceAll(".", " ")->getFirstLetterCaps(~splitBy=" ")
                : user.email
            )
          let modifiedByEmail = section.modifiedBy->mapOptionOrDefault("", user => user.email)

          <React.Fragment key={randomString(~length=10)}>
            <div className="flex flex-row gap-8 items-start">
              <div key={section.id} className="flex gap-x-3 items-center relative">
                <div
                  className="flex items-center justify-center rounded-full w-10 h-10 border bg-nd_gray-50 relative z-10">
                  {section.id->React.string}
                </div>
                <RenderIf condition={sectionIndex != sections->Array.length - 1}>
                  <div className={`absolute top-8 left-5 border-l border-nd_gray-200 h-32`} />
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
                    className="flex items-center justify-center w-10 h-10 bg-nd_gray-50 relative z-10 rounded-full border border-nd_gray-200">
                    <Icon name="nd-pencil-edit-box" size=16 className="text-nd_gray-500" />
                  </div>
                  <div className="absolute top-8 left-5 border-l border-nd_gray-200 h-28" />
                </div>
                <div className="w-full rounded-lg p-5 bg-nd_gray-25 border border-nd_gray-200">
                  <p className={`${body.md.medium} text-nd_gray-600`}>
                    {section.reasonText->Option.getOr("")->React.string}
                  </p>
                  <RenderIf condition={modifiedByName->isNonEmptyString}>
                    <div className="flex flex-row items-center justify-end gap-1.5 mt-3">
                      <p className={`${body.sm.medium} text-nd_gray-400`}>
                        {"Modified by"->React.string}
                      </p>
                      <ToolTip
                        toolTipPosition=Top
                        description={modifiedByEmail}
                        toolTipFor={<div
                          className="flex flex-row items-center gap-1.5 cursor-default">
                          <div
                            className={`w-5 h-5 rounded-full border border-nd_gray-200 bg-nd_gray-100 flex items-center justify-center flex-shrink-0 ${body.xs.semibold} text-nd_gray-500`}>
                            {modifiedByName->String.charAt(0)->String.toUpperCase->React.string}
                          </div>
                          <span className={`${body.sm.semibold} text-nd_gray-600`}>
                            {modifiedByName->React.string}
                          </span>
                        </div>}
                      />
                    </div>
                  </RenderIf>
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
