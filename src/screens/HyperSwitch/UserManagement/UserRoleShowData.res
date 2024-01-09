@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  let stateName = url.search->String.split("=")->LogicUtils.getValueFromArray(1, "")

  <div className="flex flex-col overflow-scroll">
    {switch stateName->String.toLowerCase {
    | "user" => <ShowUserData />
    | _ => {
        RescriptReactRouter.replace("?state=user")
        <ShowUserData />
      }
    }}
  </div>
}
