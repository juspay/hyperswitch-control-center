module NoThemesFound = {
  @react.component
  let make = (~themeListArray) => {
    open Typography
    let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()

    <RenderIf condition={themeListArray->Array.length == 0}>
      <div className="flex flex-col items-center justify-center text-center mt-300-px">
        <div className="flex flex-col items-center gap-2 ">
          <p className={`${heading.sm.semibold}`}> {"No Themes Available"->React.string} </p>
          <p className={`${body.md.regular} text-nd_gray-500 mb-6`}>
            {"Create your first theme, Make your dashboard for your personalized look."->React.string}
          </p>
        </div>
        <ACLButton
          text="Create Theme"
          buttonType=Primary
          buttonSize=Small
          customButtonStyle={`${body.md.semibold} `}
          authorization={userHasAccess(~groupAccess=ThemeManage)}
        />
      </div>
    </RenderIf>
  }
}
module RenderEntityRow = {
  @react.component
  let make = (~label, ~value, ~entityType, ~getNameForId) => {
    <React.Fragment key={label}>
      <div className="text-nd_gray-500"> {label->React.string} </div>
      <div>
        {value->String.toLowerCase != "all"
          ? getNameForId(entityType)->React.string
          : `All ${label}s`->React.string}
      </div>
    </React.Fragment>
  }
}

module CurrentThemeCard = {
  @react.component
  let make = (~currentTheme, ~getNameForId) => {
    open Typography

    {
      switch currentTheme {
      | None =>
        <div className="flex flex-col gap-2 my-4">
          <span className={`${body.lg.semibold} text-nd_gray-800`}>
            {"Current Theme"->React.string}
          </span>
          <div className={`text-nd_gray-500 ${body.lg.regular}`}>
            {"No active theme exists for this lineage. Please create a new theme to proceed."->React.string}
          </div>
        </div>
      | Some(themeObj) =>
        let themeData = ThemeListUtils.extractThemeData(themeObj)

        let entityLevelLabelEntity: UserInfoTypes.entity =
          themeData.entityType->UserInfoUtils.entityMapper

        <div className="flex flex-col gap-4 mt-4 w-1/2">
          <span className={`${body.lg.semibold} text-nd_gray-800`}>
            {"Current Theme"->React.string}
          </span>
          <div className="rounded-xl border border-gray-200 p-4 mb-8 flex flex-col gap-6 ">
            <div className="flex items-center gap-4">
              <span className={`${body.md.semibold}`}> {themeData.themeName->React.string} </span>
              <span
                className={`px-3 py-1 rounded-full bg-purple-100 text-purple-700 ${body.xs.semibold}`}>
                {`${(entityLevelLabelEntity :> string)} level`->React.string}
              </span>
            </div>
            <div className={`grid grid-cols-2  text-nd_gray-600 ${body.md.medium}`}>
              {ThemeListUtils.entityConfig(themeData)
              ->Array.map(((label, value, entityType)) => {
                <RenderEntityRow label value entityType getNameForId />
              })
              ->React.array}
            </div>
            <ThemeHelper.OverlappingCircles
              colorA={themeData.primaryColor} colorB={themeData.sidebarColor}
            />
          </div>
        </div>
      }
    }
  }
}
