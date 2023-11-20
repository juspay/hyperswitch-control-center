type styleProp

@module("react-circular-progressbar") @react.component
external make: (
  ~value: int,
  ~text: string,
  ~strokeWidth: int=?,
  ~styles: styleProp=?,
  ~children: React.element=?,
) => React.element = "CircularProgressbarWithChildren"

type buildStyleArg = {
  pathColor?: string,
  pathTransitionDuration?: float,
  trailColor?: string,
  strokeLinecap?: string,
}

@module("react-circular-progressbar")
external buildStyles: buildStyleArg => styleProp = "buildStyles"
