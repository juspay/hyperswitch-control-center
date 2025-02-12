@react.component
let make = () => {
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)
  let name = "stripe"
  <>
    <div> {"vault configuration"->React.string} </div>
    <Button
      text={`Connect ${name->LogicUtils.capitalizeString}`}
      onClick={_ => {
        setShowSideBar(_ => false)
        RescriptReactRouter.replace(
          GlobalVars.appendDashboardPath(~url=`/v2/vault/onboarding/new?name=${name}`),
        )
      }}
    />
  </>
}
