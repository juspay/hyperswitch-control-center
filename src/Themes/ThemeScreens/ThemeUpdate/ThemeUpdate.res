@react.component
let make = (~themeId="") => {
  open Typography
  <PageUtils.PageHeading
    title="Update Theme"
    subTitle="Personalize your dashboard look with a live preview."
    customSubTitleStyle={`${body.lg.medium} text-nd_gray-400`}
  />
}
