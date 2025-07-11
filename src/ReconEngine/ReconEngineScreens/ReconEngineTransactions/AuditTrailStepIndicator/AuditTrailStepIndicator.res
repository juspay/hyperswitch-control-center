open AuditTrailStepIndicatorTypes

@react.component
let make = (~sections: array<section>) => {
  <div className="flex flex-col gap-y-6">
    <div className="w-full h-full p-2 md:p-6">
      <div className="flex flex-col gap-y-12">
        {sections
        ->Array.mapWithIndex((section, sectionIndex) => {
          <div key={sectionIndex->Int.toString} className="flex flex-row gap-8 items-start">
            <div key={section.id} className="flex gap-x-3 items-center relative z-10">
              <div className="flex items-center justify-center rounded-full w-8 h-8 border">
                {section.id->React.string}
              </div>
              <RenderIf condition={sectionIndex != sections->Array.length - 1}>
                <div className="absolute top-8 left-4 border-l border-gray-150 z-0 h-28" />
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
        })
        ->React.array}
      </div>
    </div>
  </div>
}
