type transition = {
  duration?: float,
  repeat?: int,
  repeatType?: string,
  staggerChildren?: float,
  ease?: string,
  stiffness?: int,
  restDelta?: int,
  @as("type")
  _type?: string,
  delayChildren?: float,
  delay?: float,
}
type animate = {
  scale?: float,
  rotate?: array<int>,
  borderRadius?: array<string>,
  y?: int,
  x?: int,
  opacity?: int,
  backgroundPosition?: array<string>,
  height?: string,
  width?: string,
  background?: string,
  transition?: transition,
}

type style = {backgroundSize?: string, transformOrigin?: string}

module Motion = {
  @module("framer-motion") @react.component
  external make: unit => React.element = "motion"

  module Div = {
    @module("framer-motion") @scope("motion") @react.component
    external make: (
      ~key: string=?,
      ~animate: animate=?,
      ~className: string=?,
      ~layoutId: string=?,
      ~exit: animate=?,
      ~initial: animate=?,
      ~transition: transition=?,
      ~children: React.element=?,
      ~style: style=?,
      ~onAnimationComplete: unit => unit=?,
      ~onClick: unit => unit=?,
    ) => React.element = "div"
  }
}

module AnimatePresence = {
  @module("framer-motion") @react.component
  external make: (
    ~mode: string=?,
    ~children: React.element=?,
    ~initial: bool=?,
    ~custom: int=?,
  ) => React.element = "AnimatePresence"
}

module TransitionComponent = {
  @react.component
  let make = (~id, ~children, ~className="", ~duration=0.3) => {
    <AnimatePresence mode="wait">
      <Motion.Div
        key={id}
        initial={{y: 10, opacity: 0}}
        animate={{y: 0, opacity: 1}}
        exit={{y: -10, opacity: 0}}
        transition={{duration: duration}}
        className>
        {children}
      </Motion.Div>
    </AnimatePresence>
  }
}
