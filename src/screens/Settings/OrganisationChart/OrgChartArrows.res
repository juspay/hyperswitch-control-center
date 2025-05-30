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
    `M ${Float.toString(startX)} ${Float.toString(startY)}
     H ${Float.toString(preArcX)}
     A ${Float.toString(radius)} ${Float.toString(radius)} 0 0 ${arcSweep} ${Float.toString(
        elbowX,
      )} ${Float.toString(arcToY)}
     V ${Float.toString(preCurveY)}
     A ${Float.toString(radius)} ${Float.toString(radius)} 0 0 ${curveArcSweep} ${Float.toString(
        curveArcX,
      )} ${Float.toString(endY)}
     H ${Float.toString(endX)}`
  }
}

@react.component
let make = (~selectedOrg, ~selectedMerchant, ~selectedProfile) => {
  // Array of React elements representing SVG paths
  let (paths, setPaths) = React.useState(() => [])
  // SVG viewBox dimensions - updated to match container size
  let (svgViewBox, setSvgViewBox) = React.useState(() => "0 0 1200 600")

  let merchantList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.merchantListAtom)
  let profileList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.profileListAtom)

  // Helper to check if selectedProfile exists in current profileList
  let selectedProfileExists = profileList->Array.some(profile => profile.id == selectedProfile)

  let updatePaths = () => {
    let newPaths = []
    switch findElementById(`${selectedOrg}`) {
    | Some(selectedOrgEl) =>
      switch selectedOrgEl
      //getting parent container
      ->Webapi.Dom.Element.parentElement
      ->Belt.Option.flatMap(parent => parent->Webapi.Dom.Element.parentElement) {
      | Some(container) => {
          let containerRect = container->getBoundingClientRect
          // Helper to create org->merchant path
          let createOrgToMerchantPath = (~merchantId, ~color, ~strokeWidth, ~opacity) => {
            switch findElementById(`${merchantId}`) {
            | Some(merchantEl) =>
              switch (
                selectedOrgEl->getElementAnchor(#right),
                merchantEl->getElementAnchor(#left),
              ) {
              | (Some((orgX, orgY)), Some((merX, merY))) => {
                  let relOrgX = orgX -. containerRect.left
                  let relOrgY = orgY -. containerRect.top
                  let relMerX = merX -. containerRect.left
                  let relMerY = merY -. containerRect.top
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
                }
              | _ => ()
              }
            | None => ()
            }
          }

          // Draw all gray org->merchant paths first (non-selected)
          merchantList->Array.forEach(merchant => {
            if merchant.id != selectedMerchant {
              createOrgToMerchantPath(
                ~merchantId=merchant.id,
                ~color="#D1D5DB",
                ~strokeWidth="2",
                ~opacity="0.6",
              )
            }
          })

          // Draw the blue org->selectedMerchant path last (on top)
          createOrgToMerchantPath(
            ~merchantId=selectedMerchant,
            ~color="#2563EB",
            ~strokeWidth="2",
            ~opacity="1",
          )

          // Draw merchant->profile connections ONLY if profiles are loaded and selectedProfile exists
          if Array.length(profileList) > 0 && selectedProfileExists {
            switch findElementById(`${selectedMerchant}`) {
            | Some(selectedMerchantEl) =>
              // Helper to create merchant->profile path
              let createMerchantToProfilePath = (~profileId, ~color, ~strokeWidth, ~opacity) => {
                switch findElementById(`${profileId}`) {
                | Some(profileEl) =>
                  switch (
                    selectedMerchantEl->getElementAnchor(#right),
                    profileEl->getElementAnchor(#left),
                  ) {
                  | (Some((merX, merY)), Some((profX, profY))) => {
                      let relMerX = merX -. containerRect.left
                      let relMerY = merY -. containerRect.top
                      let relProfX = profX -. containerRect.left
                      let relProfY = profY -. containerRect.top

                      let path = createDynamicRoundedElbowPath(
                        (relMerX, relMerY),
                        (relProfX, relProfY),
                        32.0,
                        12.0,
                      )
                      newPaths->Array.push(
                        <path
                          key={`mer-prof-${profileId}`}
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
                | None => ()
                }
              }

              // Draw all gray merchant->profile paths first (non-selected)
              profileList->Array.forEach(profile => {
                if profile.id != selectedProfile {
                  createMerchantToProfilePath(
                    ~profileId=profile.id,
                    ~color="#D1D5DB",
                    ~strokeWidth="2",
                    ~opacity="0.6",
                  )
                }
              })

              // Draw the blue merchant->selectedProfile path last (on top)
              createMerchantToProfilePath(
                ~profileId=selectedProfile,
                ~color="#2563EB",
                ~strokeWidth="2",
                ~opacity="1",
              )
            | None => ()
            }
          }

          // Update SVG viewBox to match container size
          setSvgViewBox(_ =>
            `0 0 ${Float.toString(containerRect.width)} ${Float.toString(containerRect.height)}`
          )
        }
      | None => ()
      }
    | None => ()
    }

    setPaths(_ => newPaths)
  }
  // Enhanced retry mechanism that checks for data AND elements
  let updatePathsAfterLayout = () => {
    let retries = ref(0)
    let maxRetries = 12 // Increased retries
    let rec tryUpdate = () => {
      // Check if we have data
      let hasData = Array.length(merchantList) > 0 && Array.length(profileList) > 0

      // Check if required elements exist
      let selectedOrgExists = findElementById(`${selectedOrg}`)->Option.isSome
      let selectedMerchantExists = findElementById(`${selectedMerchant}`)->Option.isSome

      // For profiles, we need to be more flexible - either selectedProfile exists OR we have some profiles
      let profilesReady = if selectedProfileExists {
        findElementById(`${selectedProfile}`)->Option.isSome
      } else {
        // If selectedProfile doesn't exist in current list, just check if we have profiles
        Array.length(profileList) > 0
      }

      if hasData && selectedOrgExists && selectedMerchantExists && profilesReady {
        updatePaths()
      } else if retries.contents < maxRetries {
        retries.contents = retries.contents + 1
        // Progressive delay: longer waits for later retries
        let delay = if retries.contents > 8 {
          300
        } else if retries.contents > 4 {
          150
        } else if retries.contents > 2 {
          75
        } else {
          25
        }

        Js.Global.setTimeout(() => {
          requestAnimationFrame(_ => tryUpdate())
        }, delay)->ignore
      }
    }
    requestAnimationFrame(_ => tryUpdate())
  }

  // Effect for selection changes AND list changes
  React.useEffect(() => {
    updatePathsAfterLayout()
    None
  }, (
    selectedOrg,
    selectedMerchant,
    selectedProfile,
    Array.length(merchantList),
    Array.length(profileList),
    selectedProfileExists, // Add this dependency
  ))

  // Additional effect for initial data load with longer delay
  React.useEffect(() => {
    if Array.length(merchantList) > 0 && Array.length(profileList) > 0 {
      let timeoutId = Js.Global.setTimeout(() => {
        updatePathsAfterLayout()
      }, 500) // Longer delay for initial load
      Some(() => Js.Global.clearTimeout(timeoutId))
    } else {
      None
    }
  }, (Array.length(merchantList), Array.length(profileList)))

  // Window resize effect
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
