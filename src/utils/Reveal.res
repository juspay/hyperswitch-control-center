type postion = Top | Bottom | Left | Right | Center

@react.component
let make = (~children, ~showReveal, ~duration="duration-500", ~revealFrom=Top) => {
  open HeadlessUI

  let translateFrom = switch revealFrom {
  | Top => "-translate-y-full scale-100"
  | Bottom => "translate-y-full scale-100"
  | Left => "translate-x-full scale-100"
  | Right => "-translate-x-full scale-100"
  | Center => "scale-50"
  }
  let translateTo = switch revealFrom {
  | Top => "translate-y-0 scale-100"
  | Bottom => "-translate-y-0 scale-100"
  | Left => "translate-x-0 scale-100"
  | Right => "-translate-x-0 scale-100"
  | Center => "scale-100 "
  }

  <Transition
    \"as"="div"
    show=showReveal
    enter={`transition-all transition ${duration} ease-out`}
    enterFrom={` transition-all transform  opacity-0 ${translateFrom}`}
    enterTo={`transition-all transform  opacity-100 ${translateTo}`}
    leave={`transition-all transition ${duration} ease-in-out`}
    leaveFrom={`transition-all transform  opacity-100 ${translateFrom}`}
    leaveTo={`transition-all transform  opacity-0 ${translateTo}`}>
    children
  </Transition>
}
