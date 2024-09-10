module PageHeading = {
  @react.component
  let make = (
    ~title,
    ~subTitle=?,
    ~customTitleStyle="",
    ~customSubTitleStyle="text-lg font-medium",
    ~customHeadingStyle="py-2",
    ~isTag=false,
    ~tagText="",
    ~customTagStyle="bg-extra-light-grey border-light-grey",
    ~leftIcon=None,
  ) => {
    let headerTextStyle = HSwitchUtils.getTextClass((H1, Optional))
    <div className={`${customHeadingStyle}`}>
      {switch leftIcon {
      | Some(icon) => <Icon name={icon} size=56 />
      | None => React.null
      }}
      <div className="flex items-center gap-4">
        <div className={`${headerTextStyle} ${customTitleStyle}`}> {title->React.string} </div>
        <RenderIf condition=isTag>
          <div
            className={`text-sm text-grey-700 font-semibold border  rounded-full px-2 py-1 ${customTagStyle}`}>
            {tagText->React.string}
          </div>
        </RenderIf>
      </div>
      {switch subTitle {
      | Some(text) =>
        <RenderIf condition={text->LogicUtils.isNonEmptyString}>
          <div className={`opacity-50 mt-2 ${customSubTitleStyle}`}> {text->React.string} </div>
        </RenderIf>
      | None => React.null
      }}
    </div>
  }
}
