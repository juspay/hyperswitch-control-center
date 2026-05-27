/* Tiny inline-SVG sparkline. Used in KPI cards and per-rule cards.
 No external chart lib — keeps the page light and renders crisp at any zoom. */

@react.component
let make = (
  ~data: array<float>,
  ~stroke: string="#2B6FFF",
  ~fill: string="",
  ~width: int=120,
  ~height: int=32,
  ~strokeWidth: float=1.5,
) => {
  let hasFill = fill !== ""
  let n = data->Array.length
  if n < 2 {
    <svg width={width->Int.toString} height={height->Int.toString} />
  } else {
    let max = data->Array.reduce(neg_infinity, Math.max)
    let min = data->Array.reduce(infinity, Math.min)
    let range = max -. min
    let safeRange = range === 0.0 ? 1.0 : range
    let padX = 2.0
    let padY = 3.0
    let plotW = width->Int.toFloat -. padX *. 2.0
    let plotH = height->Int.toFloat -. padY *. 2.0
    let step = plotW /. (n - 1)->Int.toFloat

    let pointFor = (i, v) => {
      let x = padX +. i->Int.toFloat *. step
      let y = padY +. plotH -. (v -. min) /. safeRange *. plotH
      (x, y)
    }

    let points =
      data
      ->Array.mapWithIndex((v, i) => {
        let (x, y) = pointFor(i, v)
        `${x->Float.toString},${y->Float.toString}`
      })
      ->Array.joinWith(" ")

    let areaPath = if hasFill {
      let head =
        data
        ->Array.mapWithIndex((v, i) => {
          let (x, y) = pointFor(i, v)
          let cmd = i === 0 ? "M" : "L"
          `${cmd}${x->Float.toString},${y->Float.toString}`
        })
        ->Array.joinWith(" ")
      let lastX = padX +. (n - 1)->Int.toFloat *. step
      let baseY = padY +. plotH
      `${head} L${lastX->Float.toString},${baseY->Float.toString} L${padX->Float.toString},${baseY->Float.toString} Z`
    } else {
      ""
    }

    <svg
      width={width->Int.toString}
      height={height->Int.toString}
      viewBox={`0 0 ${width->Int.toString} ${height->Int.toString}`}
      className="block"
      preserveAspectRatio="none">
      {hasFill ? <path d={areaPath} fill stroke="none" /> : React.null}
      <polyline
        points
        fill="none"
        stroke
        strokeWidth={strokeWidth->Float.toString}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  }
}
