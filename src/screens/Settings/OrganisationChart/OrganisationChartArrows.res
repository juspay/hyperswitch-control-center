open OrganisationChartArrowUtils
@val @scope("window")
external requestAnimationFrame: (unit => unit) => unit = "requestAnimationFrame"

@react.component
let make = (~selectedOrg, ~selectedMerchant, ~selectedProfile) => {
  // Array of React elements representing SVG paths
  let (paths, setPaths) = React.useState(() => [])
  // SVG viewBox dimensions - updated to match container size
  let (svgViewBox, setSvgViewBox) = React.useState(() => "0 0 1200 600")
  let merchantList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.merchantListAtom)
  let profileList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.profileListAtom)
  let selectedProfileExists = profileList->Array.some(profile => profile.id == selectedProfile)
  let svgColorSelected = "#2563EB" // Blue color for selected paths
  let svgColorDefault = "#D1D5DB" // Gray color for default paths
  let updatePaths = () => {
    let newPaths = []
    switch getElementById(`${selectedOrg}`) {
    | Some(selectedOrgEl) =>
      switch selectedOrgEl
      //getting parent container
      ->Webapi.Dom.Element.parentElement
      ->Belt.Option.flatMap(parent => parent->Webapi.Dom.Element.parentElement) {
      | Some(container) => {
          let containerRect = container->getBoundingClientRect
          //all gray org->merchant paths first (non-selected)
          merchantList->Array.forEach(merchant => {
            if merchant.id != selectedMerchant {
              createConnectionPath(
                ~startId=`${selectedOrg}`,
                ~endId=merchant.id,
                ~startAnchor=#right,
                ~endAnchor=#left,
                ~color=svgColorDefault,
                ~strokeWidth="2",
                ~opacity="0.6",
                ~keyPrefix="org-mer",
                ~containerRect,
                ~createDynamicRoundedElbowPath,
                newPaths,
              )
            }
          })
          // Draw the blue org->selectedMerchant path last (on top)
          createConnectionPath(
            ~startId=`${selectedOrg}`,
            ~endId=selectedMerchant,
            ~startAnchor=#right,
            ~endAnchor=#left,
            ~color=svgColorSelected,
            ~strokeWidth="2",
            ~opacity="1",
            ~keyPrefix="org-mer",
            ~containerRect,
            ~createDynamicRoundedElbowPath,
            newPaths,
          )

          // Draw merchant->profile connections ONLY if profiles are loaded and selectedProfile exists
          if Array.length(profileList) > 0 && selectedProfileExists {
            // Draw all gray merchant->profile paths first (non-selected)
            profileList->Array.forEach(profile => {
              if profile.id != selectedProfile {
                createConnectionPath(
                  ~startId=`${selectedMerchant}`,
                  ~endId=profile.id,
                  ~startAnchor=#right,
                  ~endAnchor=#left,
                  ~color=svgColorDefault,
                  ~strokeWidth="2",
                  ~opacity="0.6",
                  ~keyPrefix="mer-prof",
                  ~containerRect,
                  ~createDynamicRoundedElbowPath,
                  newPaths,
                )
              }
            })
            // Draw the blue merchant->selectedProfile path last (on top)
            createConnectionPath(
              ~startId=`${selectedMerchant}`,
              ~endId=selectedProfile,
              ~startAnchor=#right,
              ~endAnchor=#left,
              ~color=svgColorSelected,
              ~strokeWidth="2",
              ~opacity="1",
              ~keyPrefix="mer-prof",
              ~containerRect,
              ~createDynamicRoundedElbowPath,
              newPaths,
            )
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
      let selectedOrgExists = getElementById(`${selectedOrg}`)->Option.isSome
      let selectedMerchantExists = getElementById(`${selectedMerchant}`)->Option.isSome
      let profilesReady = if selectedProfileExists {
        getElementById(`${selectedProfile}`)->Option.isSome
      } else {
        // If selectedProfile doesn't exist in current list, just check if we have profiles
        Array.length(profileList) > 0
      }

      if hasData && selectedOrgExists && selectedMerchantExists && profilesReady {
        updatePaths()
      } else if retries.contents < maxRetries {
        retries.contents = retries.contents + 1
        let delay = if retries.contents > 8 {
          300
        } else if retries.contents > 4 {
          150
        } else if retries.contents > 2 {
          75
        } else {
          25
        }
        let _ = setTimeout(() => {
          requestAnimationFrame(_ => tryUpdate())
        }, delay)
      }
    }
    requestAnimationFrame(_ => tryUpdate())
  }

  React.useEffect(() => {
    let hasData = Array.length(merchantList) > 0 && Array.length(profileList) > 0
    if hasData {
      // Use longer delay for initial load when data first becomes available
      let isInitialLoad = paths->Array.length == 0
      let delay = if isInitialLoad {
        500
      } else {
        0
      }
      let timeoutId = setTimeout(() => {
        updatePathsAfterLayout()
      }, delay)
      Some(() => clearTimeout(timeoutId))
    } else {
      // Clear paths when no data
      setPaths(_ => [])
      None
    }
  }, (
    selectedOrg,
    selectedMerchant,
    selectedProfile,
    Array.length(merchantList),
    Array.length(profileList),
    selectedProfileExists,
  ))

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
