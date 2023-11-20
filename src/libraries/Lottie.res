open LazyUtils

type props = {
  animationData: Js.Json.t,
  autoplay: bool,
  loop: bool,
  lottieRef?: React.ref<Js.Nullable.t<Dom.element>>,
  initialSegment?: array<int>,
}

let make: props => React.element = reactLazy(.() => import_("lottie-react"))
