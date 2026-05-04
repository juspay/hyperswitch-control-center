open Typography
module PageHeading = {
  @react.component
  let make = (
    ~title,
    ~subTitle=?,
    ~customTitleStyle="",
    ~customSubTitleStyle=`${body.md.medium}`,
    ~customHeadingStyle="",
    ~isTag=false,
    ~tagText="",
    ~customTagStyle="bg-extra-light-grey border-light-grey",
    ~leftIcon=None,
    ~customTagComponent=?,
    ~customTitleSectionStyles="",
    ~showPermLink=true,
  ) => {
    <div className={customHeadingStyle}>
      {switch leftIcon {
      | Some(icon) => <Icon name={icon} size=56 />
      | None => React.null
      }}
      <div className="flex flex-col gap-spacing-xs">
        <div className={`flex items-center gap-spacing-xl ${customTitleSectionStyles}`}>
          <div className={`${heading.md.semibold} ${customTitleStyle}`}>
            {title->React.string}
          </div>
          <RenderIf condition=showPermLink>
            <OMPPermaLinkButton />
          </RenderIf>
          <RenderIf condition=isTag>
            <div
              className={`text-sm text-grey-700 font-semibold border rounded-full px-spacing-md py-spacing-xxs ${customTagStyle}`}>
              {tagText->React.string}
            </div>
          </RenderIf>
          <RenderIf condition={!isTag && customTagComponent->Option.isSome}>
            {customTagComponent->Option.getOr(React.null)}
          </RenderIf>
        </div>
        {switch subTitle {
        | Some(text) =>
          <RenderIf condition={text->LogicUtils.isNonEmptyString}>
            <div className={`opacity-50 ${customSubTitleStyle}`}> {text->React.string} </div>
          </RenderIf>
        | None => React.null
        }}
      </div>
    </div>
  }
}
