type settings

@obj
external makeSettings: (
  ~minimum: float=?,
  ~easing: string=?,
  ~positionUsing: string=?,
  ~speed: int=?,
  ~trickle: bool=?,
  ~trickleRate: float=?,
  ~trickleSpeed: int=?,
  ~showSpinner: bool=?,
  ~barSelector: string=?,
  ~spinnerSelector: string=?,
  ~parent: string=? /* Dom.element */,
  ~template: string=?,
  unit,
) => settings = ""

@module("nprogress")
external configure: settings => unit = "configure"

let actuallyConfigure = () => {
  makeSettings(
    ~minimum=0.08,
    ~easing="linear",
    ~speed=200,
    ~trickle=true,
    ~trickleSpeed=200,
    ~showSpinner=false,
    (),
  )->configure
}

@module("nprogress")
external start: unit => unit = "start"

@module("nprogress")
external done: unit => unit = "done"
