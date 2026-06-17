open Typography
open LogicUtils

module PageHeading = {
  @react.component
  let make = (~title, ~subTitle=?) => {
    let isMiniLaptopView = MatchMedia.useScreenSizeChecker(~screenSize="1300")

    let titleClass = isMiniLaptopView ? heading.sm.semibold : heading.md.semibold

    <div className="flex flex-col gap-1.5">
      <div className="flex items-center gap-4">
        <div className={`${titleClass} text-nd_gray-800`}> {title->React.string} </div>
        <OMPPermaLinkButton />
      </div>
      {switch subTitle {
      | Some(text) =>
        <RenderIf condition={text->isNonEmptyString}>
          <div className={`${body.md.regular} text-nd_gray-600`}> {text->React.string} </div>
        </RenderIf>
      | None => React.null
      }}
    </div>
  }
}
