open LazyUtils

type props = {
  animationData: JSON.t,
  autoplay: bool,
  loop: bool,
  lottieRef?: React.ref<Nullable.t<Dom.element>>,
  initialSegment?: array<int>,
}

let make: props => React.element = reactLazy(.() => import_("lottie-react"))
