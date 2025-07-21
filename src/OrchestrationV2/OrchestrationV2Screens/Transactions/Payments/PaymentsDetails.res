@react.component
let make = (~id, ~profileId, ~merchantId, ~orgId) => {
  Js.log4(id, profileId, merchantId, orgId)
  <div> {"Payments Details"->React.string} </div>
}
