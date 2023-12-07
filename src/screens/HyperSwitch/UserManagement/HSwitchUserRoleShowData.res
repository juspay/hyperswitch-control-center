@react.component
let make = (~id as _) => {
  let url = RescriptReactRouter.useUrl()
  let stateName = url.search->Js.String2.split("=")->LogicUtils.getValueFromArray(1, "")

  <div className="flex flex-col overflow-scroll">
    {switch stateName->Js.String2.toLowerCase {
    | "user" => <HSwitchShowUserData />
    | _ => {
        RescriptReactRouter.replace("?state=user")
        <HSwitchShowUserData />
      }
    }}
  </div>
}
