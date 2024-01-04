module PageHeading = {
  @react.component
  let make = (
    ~title,
    ~subTitle=?,
    ~customTitleStyle="",
    ~customSubTitleStyle="text-lg font-medium",
    ~isTag=false,
    ~tagText="",
    ~customTagStyle="bg-extra-light-grey border-light-grey",
    ~leftIcon=None,
  ) => {
    let headerTextStyle = HSwitchUtils.getTextClass(~textVariant=H1, ())
    <div className="py-2">
      {switch leftIcon {
      | Some(icon) => <Icon name={icon} size=56 />
      | None => React.null
      }}
      <div className="flex items-center gap-4">
        <div className={`${headerTextStyle} pt-2 ${customTitleStyle}`}> {title->React.string} </div>
        <UIUtils.RenderIf condition=isTag>
          <div
            className={`text-sm text-grey-700 font-semibold border  rounded-full px-2 py-1 ${customTagStyle}`}>
            {tagText->React.string}
          </div>
        </UIUtils.RenderIf>
      </div>
      {switch subTitle {
      | Some(text) =>
        <UIUtils.RenderIf condition={text->String.length > 0}>
          <div className={`opacity-50 mt-2 ${customSubTitleStyle}`}> {text->React.string} </div>
        </UIUtils.RenderIf>
      | None => React.null
      }}
    </div>
  }
}
