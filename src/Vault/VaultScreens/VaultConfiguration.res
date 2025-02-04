@react.component
let make = () => {
  let name = "stripe"
  <>
    <div> {"vault configuration"->React.string} </div>
    <Button
      text={`Connect ${name->LogicUtils.capitalizeString}`}
      onClick={_ => {
        RescriptReactRouter.replace(
          GlobalVars.appendDashboardPath(~url=`/v2/vault/onboarding/new?name=${name}`),
        )
      }}
    />
  </>
}
