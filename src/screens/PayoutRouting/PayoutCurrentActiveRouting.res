@react.component
let make = (~routingType: array<JSON.t>) => {
  <div className="mt-4 flex flex-col gap-6">
    {routingType
    ->Array.mapWithIndex((ele, i) => {
      let id = ele->LogicUtils.getDictFromJsonObject->LogicUtils.getString("id", "")
      <ActiveRouting.ActiveSection
        key={i->Int.toString}
        activeRouting={ele}
        activeRoutingId={id}
        onRedirectBaseUrl="payoutrouting"
      />
    })
    ->React.array}
  </div>
}
