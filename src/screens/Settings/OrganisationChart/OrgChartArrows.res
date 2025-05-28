//  SVG Arrow Connections for Organization Chart

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
@val @scope("window")
external requestAnimationFrame: (unit => unit) => unit = "requestAnimationFrame"

//  Gets anchor point coordinates for an element based on specified position
let getElementAnchor = (element: Dom.element, anchor: [#left | #center | #right]): option<(
  float,
  float,
)> => {
  let rect = element->getBoundingClientRect
  // Calculate X coordinate based on anchor position
  let x = switch anchor {
  | #left => rect.left // Left edge
  | #center => rect.left +. rect.width /. 2.0 // Horizontal center
  | #right => rect.left +. rect.width // Right edge
  }
  // Y coordinate is always vertical center of element
  let y = rect.top +. rect.height /. 2.0
  Some((x, y))
}
// Gets center coordinates of an element (convenience function)
let getElementCenter = (element: Dom.element): option<(float, float)> => {
  let rect = element->getBoundingClientRect
  let x = rect.left +. rect.width /. 2.0
  let y = rect.top +. rect.height /. 2.0
  Some((x, y))
}
// finds DOM element by ID
let findElementById = (id: string): option<Dom.element> => {
  Webapi.Dom.document
  ->getElementById(id)
  ->Nullable.toOption
}

// Creates a dynamic elbow (step) path with a rounded (arc) corner, placing the elbow a fixed distance from both source and target
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
    "M " ++
    Float.toString(startX) ++
    " " ++
    Float.toString(startY) ++
    " H " ++
    Float.toString(elbowX) ++
    " V " ++
    Float.toString(endY) ++
    " H " ++
    Float.toString(endX)
  } else {
    // First arc (rounded elbow)
    let arcToX = elbowX
    let arcToY = startY +. verticalDir *. radius
    let preArcX = elbowX -. radius
    let arcSweep = if verticalDir > 0. {
      "1"
    } else {
      "0"
    }
    // Second arc (rounded corner before final horizontal line)
    // Adjust preCurveY depending on vertical direction:
    let preCurveY = if verticalDir > 0. {
      endY -. radius
    } else {
      endY +. radius
    }

    let curveArcX = elbowX +. horizontalDir *. radius

    // Arc sweep for second curve:
    // If going right and down => sweep 0
    // If going right and up => sweep 1
    // If going left and down => sweep 1
    // If going left and up => sweep 0
    let curveArcSweep = switch (horizontalDir, verticalDir) {
    | (1., 1.) => "0"
    | (1., -1.) => "1"
    | (-1., 1.) => "1"
    | (-1., -1.) => "0"
    | _ => "0" // fallback
    }

    "M " ++
    Float.toString(startX) ++
    " " ++
    Float.toString(startY) ++
    " H " ++
    Float.toString(preArcX) ++
    " A " ++
    Float.toString(radius) ++
    " " ++
    Float.toString(radius) ++
    " 0 0 " ++
    arcSweep ++
    " " ++
    Float.toString(arcToX) ++
    " " ++
    Float.toString(arcToY) ++
    " V " ++
    Float.toString(preCurveY) ++
    " A " ++
    Float.toString(radius) ++
    " " ++
    Float.toString(radius) ++
    " 0 0 " ++
    curveArcSweep ++
    " " ++
    Float.toString(curveArcX) ++
    " " ++
    Float.toString(endY) ++
    " H " ++
    Float.toString(endX)
  }
}

@react.component
let make = (
  ~selectedOrg, // Currently selected organization ID
  ~selectedMerchant, // Currently selected merchant ID
  ~selectedProfile, // Currently selected profile ID
  ~orgColumnRef, // Reference to organization column DOM element
  ~merchantColumnRef, // Reference to merchant column DOM element
  ~profileColumnRef,
) => {
  // Array of React elements representing SVG paths
  let (paths, setPaths) = React.useState(() => [])
  // SVG viewBox dimensions - updated to match container size
  let (svgViewBox, setSvgViewBox) = React.useState(() => "0 0 1200 600")
  // let orgList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.orgListAtom)
  let merchantList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.merchantListAtom)
  let profileList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.profileListAtom)
  //  Core function that calculates and updates all SVG connection paths
  let updatePaths = () => {
    let newPaths = []
    let containerRect = ref(None)
    switch orgColumnRef.contents->Nullable.toOption {
    | Some(orgCol) =>
      let parent = orgCol->Webapi.Dom.Element.parentElement
      switch parent {
      | Some(container) =>
        containerRect.contents = Some(container->getBoundingClientRect)
        switch (
          findElementById(`org-${selectedOrg}`),
          merchantColumnRef.contents->Nullable.toOption,
        ) {
        | (Some(selectedOrgEl), Some(_merchantCol)) =>
          // Helper to push org->merchant path
          let pushOrgToMerchantPath = (~merchantId, ~color, ~strokeWidth, ~opacity) => {
            switch findElementById(`merchant-${merchantId}`) {
            | Some(merchantEl) =>
              switch (
                selectedOrgEl->getElementAnchor(#right),
                merchantEl->getElementAnchor(#left),
                containerRect.contents,
              ) {
              | (Some((orgX, orgY)), Some((merX, merY)), Some(rect)) =>
                let relOrgX = orgX -. rect.left
                let relOrgY = orgY -. rect.top
                let relMerX = merX -. rect.left
                let relMerY = merY -. rect.top
                let path = createDynamicRoundedElbowPath(
                  (relOrgX, relOrgY),
                  (relMerX, relMerY),
                  32.0,
                  12.0,
                )
                newPaths->Array.push(
                  <path
                    key={`org-mer-${merchantId}`}
                    d={path}
                    stroke={color}
                    strokeWidth={strokeWidth}
                    opacity={opacity}
                    fill="none"
                    className="transition-all duration-300"
                  />,
                )
              | _ => ()
              }
            | None => ()
            }
          }
          // Draw all gray org->merchant paths first
          merchantList->Array.forEach(merchant => {
            if merchant.id != selectedMerchant {
              pushOrgToMerchantPath(
                ~merchantId=merchant.id,
                ~color="#D1D5DB",
                ~strokeWidth="2",
                ~opacity="0.6",
              )
            }
          })
          // Draw the blue org->selectedMerchant path last (on top)
          pushOrgToMerchantPath(
            ~merchantId=selectedMerchant,
            ~color="#2563EB",
            ~strokeWidth="2",
            ~opacity="1",
          )

        | _ => ()
        }

        switch (
          findElementById(`merchant-${selectedMerchant}`),
          profileColumnRef.contents->Nullable.toOption,
        ) {
        | (Some(selectedMerchantEl), Some(_profileCol)) =>
          profileList->Array.forEach(profile => {
            switch findElementById(`profile-${profile.id}`) {
            | Some(profileEl) =>
              switch (
                selectedMerchantEl->getElementAnchor(#right),
                profileEl->getElementAnchor(#left),
                containerRect.contents,
              ) {
              | (Some((merX, merY)), Some((profX, profY)), Some(rect)) =>
                let relMerX = merX -. rect.left
                let relMerY = merY -. rect.top
                let relProfX = profX -. rect.left
                let relProfY = profY -. rect.top
                let isSelected = profile.id == selectedProfile
                let color = isSelected ? "#2563EB" : "#D1D5DB" // Blue for selected, gray for others
                let strokeWidth = isSelected ? "2" : "2" // Thicker for selected
                let opacity = isSelected ? "1" : "0.6" // More opaque for selected

                let path = createDynamicRoundedElbowPath(
                  (relMerX, relMerY),
                  (relProfX, relProfY),
                  32.0,
                  12.0,
                )
                newPaths->Array.push(
                  <path
                    key={`mer-prof-${profile.id}`}
                    d={path}
                    stroke={color}
                    strokeWidth={strokeWidth}
                    opacity={opacity}
                    fill="none"
                    className={`transition-all duration-300 `} // Smooth transitions
                  />,
                )
              | _ => Js.log("Failed to get coordinates for profile")
              }
            | None => Js.log2("Profile element not found:", `profile-${profile.id}`)
            }
          })
        | _ => Js.log("Failed to find merchant element or profile column")
        }
        switch containerRect.contents {
        | Some(rect) =>
          setSvgViewBox(_ => `0 0 ${Float.toString(rect.width)} ${Float.toString(rect.height)}`)
        | None => ()
        }
      | None => ()
      }
    | None => ()
    }
    setPaths(_ => newPaths)
  }
  // Helper: Schedule updatePaths after layout using requestAnimationFrame, with up to 3 retries if elements are missing
  let updatePathsAfterLayout = () => {
    let retries = ref(0)
    let maxRetries = 3
    let rec tryUpdate = () => {
      let allOrgElementsExist = orgColumnRef.contents->Nullable.toOption != None
      let allMerchantElementsExist = merchantColumnRef.contents->Nullable.toOption != None
      let allProfileElementsExist = profileColumnRef.contents->Nullable.toOption != None
      if allOrgElementsExist && allMerchantElementsExist && allProfileElementsExist {
        updatePaths()
      } else if retries.contents < maxRetries {
        retries.contents = retries.contents + 1
        requestAnimationFrame(_ => tryUpdate())
      }
    }
    requestAnimationFrame(_ => tryUpdate())
  }

  React.useEffect(() => {
    updatePathsAfterLayout()
    None
  }, (selectedOrg, selectedMerchant, selectedProfile))

  React.useEffect(() => {
    updatePathsAfterLayout()
    None
  }, [Array.length(profileList)])

  React.useEffect(() => {
    let handleResize = (_event: Dom.event) => {
      updatePathsAfterLayout()
    }
    Webapi.Dom.Window.addEventListener(Webapi.Dom.window, "resize", handleResize)
    Some(() => Webapi.Dom.Window.removeEventListener(Webapi.Dom.window, "resize", handleResize))
  }, [])

  <svg
    className="absolute inset-0 w-full h-full pointer-events-none hidden lg:block"
    viewBox={svgViewBox}
    preserveAspectRatio="xMidYMid meet">
    {paths->React.array}
  </svg>
}
