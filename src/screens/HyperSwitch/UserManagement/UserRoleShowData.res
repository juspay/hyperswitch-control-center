@react.component
let make = () => {
  let url = RescriptReactRouter.useUrl()
  let stateName =
    url.search->LogicUtils.getDictFromUrlSearchParams->Dict.get("state")->Option.getOr("")

  <div className="flex flex-col overflow-scroll">
    {switch stateName->String.toLowerCase {
    | "user" => <ShowUserData />
    | _ => {
        RescriptReactRouter.replace("/users")
        <UserRoleEntry />
      }
    }}
  </div>
}
