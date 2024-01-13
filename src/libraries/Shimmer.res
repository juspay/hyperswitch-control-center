type shimmerType = Small | Big
@module("react-shimmer-effect") @react.component
let make = (~styleClass="w-96 h-96", ~shimmerType: shimmerType=Small) => {
  let theme = ThemeProvider.useTheme()
  let shimmerClass = switch shimmerType {
  | Small => "animate-shimmer"
  | Big => "animate-shimmer-fast"
  }
  let background = switch theme {
  | Light => `linear-gradient(94.97deg, rgba(241, 242, 244, 0) 25.3%, #ebedf0 50.62%, rgba(241, 242, 244, 0) 74.27%)`
  | Dark => `linear-gradient(94.97deg, rgba(35, 36, 36, 0) 25.3%, #2c2d2d 50.62%, rgba(35, 36, 36, 0) 74.27%)`
  }

  <div
    className={`${shimmerClass}  border border-solid border-[#ccd2e259] dark:border-[#2e2f3980] dark:bg-black bg-white ${styleClass}`}
    style={ReactDOMStyle.make(~background, ())}
  />
}
