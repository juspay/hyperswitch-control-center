@react.component
let make = () => {
  <>
    <div> {"vault configuration"->React.string} </div>
    <Button
      text="onboarding"
      onClick={_ => {
        RescriptReactRouter.replace(
          GlobalVars.appendDashboardPath(~url="/v2/vault/onboarding/new?name=stripe"),
        )
      }}
    />
  </>
}
