open LazyUtils

type style = {
  width?: int,
  height?: int,
  transform?: string,
}

type props = {
  animationData: JSON.t,
  autoplay: bool,
  loop: bool,
  lottieRef?: React.ref<Nullable.t<Dom.element>>,
  initialSegment?: array<int>,
  style?: style,
}

let make: props => React.element = reactLazy(() => import_("lottie-react"))
