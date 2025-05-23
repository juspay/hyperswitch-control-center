// open React

// @react.component
// let make = (~selectedOrg, ~selectedMerchant, ~selectedProfile) => {
//   // Layout constants
//   let buttonHeight = 48
//   let gap = 16
//   let topOffset = 0
//   let orgX = 0
//   let merchantX = 400
//   let profileX = 800
//   let buttonWidth = 320 // matches w-80
//   let orgList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.orgListAtom)
//   let merchantList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.merchantListAtom)
//   let profileList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.profileListAtom)
//   // Find index of selected org/merchant
//   let orgIdx = orgList->Belt.Array.getIndexBy(org => org.id == selectedOrg)
//   let merchantIdx = merchantList->Belt.Array.getIndexBy(merchant => merchant.id == selectedMerchant)

//   // Helper to get center Y of a button
//   let getY = (idx: int) => topOffset + idx * (buttonHeight + gap) + buttonHeight / 2

//   // SVG paths for org -> merchants
//   let orgToMerchantPaths = switch orgIdx {
//   | Some(i) =>
//     merchantList->Belt.Array.mapWithIndex((j, merchant) => {
//       let startX = orgX + buttonWidth
//       let startY = getY(i)
//       let endX = merchantX
//       let endY = getY(j)
//       let isActive = merchant.id == selectedMerchant
//       let color = isActive ? "#2563EB" : "#E5E7EB"
//       let path =
//         "M " ++
//         Float.toString(startX) ++
//         " " ++
//         Float.toString(startY) ++
//         " C " ++
//         Float.toString(startX + 60.) ++
//         " " ++
//         Float.toString(startY) ++
//         ", " ++
//         Float.toString(endX - 60.) ++
//         " " ++
//         Float.toString(endY) ++
//         ", " ++
//         Float.toString(endX) ++
//         " " ++
//         Float.toString(endY)
//       <path d={path} stroke={color} strokeWidth="2" fill="none" key={merchant.id} />
//     })
//   | None => []
//   }

//   // SVG paths for merchant -> profiles
//   let merchantToProfilePaths = switch merchantIdx {
//   | Some(i) =>
//     profileList->Belt.Array.mapWithIndex((profile, k) => {
//       let startX = merchantX + buttonWidth
//       let startY = getY(i)
//       let endX = profileX
//       let endY = getY(k)
//       let isActive = profile.id == selectedProfile
//       let color = isActive ? "#2563EB" : "#E5E7EB"
//       let path =
//         "M " ++
//         Float.toString(startX) ++
//         " " ++
//         Float.toString(startY) ++
//         " C " ++
//         Float.toString(startX + 60.) ++
//         " " ++
//         Float.toString(startY) ++
//         ", " ++
//         Float.toString(endX - 60.) ++
//         " " ++
//         Float.toString(endY) ++
//         ", " ++
//         Float.toString(endX) ++
//         " " ++
//         Float.toString(endY)
//       <path d={path} stroke={color} strokeWidth="2" fill="none" key={profile.id} />
//     })
//   | None => []
//   }

//   <svg
//     className="absolute top-0 left-0 w-full h-full pointer-events-none"
//     style={ReactDOM.Style.make(~zIndex=0, ())}>
//     {orgToMerchantPaths->React.array}
//     {merchantToProfilePaths->React.array}
//   </svg>
// }

