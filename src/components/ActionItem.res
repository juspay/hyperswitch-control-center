open Typography

@react.component
let make = (~heading, ~description="", ~leftElement, ~onClick, ~customClass="") => {
  <div
    className={`border rounded-xl p-3 flex items-center gap-4 group cursor-pointer justify-between ${customClass}`}
    onClick>
    <div className="flex items-center gap-2">
      leftElement
      <div className="flex flex-col gap-1">
        <p className={`${body.md.semibold} text-nd_gray-600`}> {heading->React.string} </p>
        <RenderIf condition={description->LogicUtils.isNonEmptyString}>
          <p className={`${body.sm.medium} text-nd_gray-400`}> {description->React.string} </p>
        </RenderIf>
      </div>
    </div>
    <Icon name="nd-angle-right" size=16 className="group-hover:scale-125" />
  </div>
}
