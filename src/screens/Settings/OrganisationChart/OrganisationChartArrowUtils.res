type domRect = {
  left: float, // X position relative to viewport
  top: float, // Y position relative to viewport
  right: float, // Right edge X position
  bottom: float, // Bottom edge Y position
  width: float, // Element width
  height: float, // Element height
}

@send external getBoundingClientRect: Dom.element => domRect = "getBoundingClientRect"
@send external getElementById: (Dom.document, string) => Nullable.t<Dom.element> = "getElementById"

// Gets anchor point coordinates for an element based on specified position
let getElementAnchor = (element: Dom.element, anchor: [#left | #center | #right]): option<(
  float,
  float,
)> => {
  let rect = element->getBoundingClientRect
  // Calculate X coordinate based on anchor position
  let x = switch anchor {
  | #left => rect.left
  | #center => rect.left +. rect.width /. 2.0
  | #right => rect.left +. rect.width
  }
  // Y coordinate is always vertical center of element
  let y = rect.top +. rect.height /. 2.0
  Some((x, y))
}

// finds DOM element by ID
let findElementById = (id: string): option<Dom.element> => {
  Webapi.Dom.document
  ->getElementById(id)
  ->Nullable.toOption
}

// helper to create a connection path between two elements
let createConnectionPath = (
  ~startId: string,
  ~endId: string,
  ~startAnchor: [#left | #center | #right],
  ~endAnchor: [#left | #center | #right],
  ~color: string,
  ~strokeWidth: string,
  ~opacity: string,
  ~keyPrefix: string,
  ~containerRect: domRect,
  ~createDynamicRoundedElbowPath: ((float, float), (float, float), float, float) => string,
  newPaths: array<React.element>,
) => {
  switch (findElementById(startId), findElementById(endId)) {
  | (Some(startEl), Some(endEl)) =>
    switch (getElementAnchor(startEl, startAnchor), getElementAnchor(endEl, endAnchor)) {
    | (Some((startX, startY)), Some((endX, endY))) => {
        let relStartX = startX -. containerRect.left
        let relStartY = startY -. containerRect.top
        let relEndX = endX -. containerRect.left
        let relEndY = endY -. containerRect.top
        let path = createDynamicRoundedElbowPath(
          (relStartX, relStartY),
          (relEndX, relEndY),
          32.0,
          12.0,
        )
        newPaths->Array.push(
          <path
            key={`${keyPrefix}-${endId}`}
            d={path}
            stroke={color}
            strokeWidth={strokeWidth}
            opacity={opacity}
            fill="none"
            className="transition-all duration-300"
          />,
        )
      }
    | _ => ()
    }
  | _ => ()
  }
}

// Creates a dynamic elbow (step) path with a rounded (arc) corner
let createDynamicRoundedElbowPath = (
  (startX, startY): (float, float),
  (endX, endY): (float, float),
  elbowPad: float,
  desiredRadius: float,
): string => {
  let elbowStartX = startX +. elbowPad
  let elbowEndX = endX -. elbowPad
  let elbowX = Js.Math.min_float(elbowStartX, elbowEndX)
  let dx = Js.Math.abs_float(elbowX -. startX)
  let dy = Js.Math.abs_float(endY -. startY)
  let radius = Js.Math.min_float(Js.Math.min_float(desiredRadius, dx), dy)
  let horizontalDir = if endX > elbowX {
    1.
  } else {
    -1.
  }
  let verticalDir = if endY > startY {
    1.
  } else {
    -1.
  }
  if radius < 1.0 {
    `M ${Float.toString(startX)} ${Float.toString(startY)} H ${Float.toString(
        elbowX,
      )} V ${Float.toString(endY)} H ${Float.toString(endX)}`
  } else {
    let arcToY = startY +. verticalDir *. radius
    let preArcX = elbowX -. radius
    let arcSweep = if verticalDir > 0. {
      "1"
    } else {
      "0"
    }
    let preCurveY = endY -. verticalDir *. radius
    let curveArcX = elbowX +. horizontalDir *. radius
    let curveArcSweep = switch (horizontalDir, verticalDir) {
    | (1., 1.) | (-1., -1.) => "0"
    | _ => "1"
    }
    [
      `M ${Float.toString(startX)} ${Float.toString(startY)}`,
      `H ${Float.toString(preArcX)}`,
      `A ${Float.toString(radius)} ${Float.toString(radius)} 0 0 ${arcSweep} ${Float.toString(
          elbowX,
        )} ${Float.toString(arcToY)}`,
      `V ${Float.toString(preCurveY)}`,
      `A ${Float.toString(radius)} ${Float.toString(radius)} 0 0 ${curveArcSweep} ${Float.toString(
          curveArcX,
        )} ${Float.toString(endY)}`,
      `H ${Float.toString(endX)}`,
    ]->Array.joinWith("")
  }
}
