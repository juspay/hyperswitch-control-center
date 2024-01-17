module ComingSoon = {
  @react.component
  let make = (~title) => {
    <div className="h-full w-full flex flex-col items-center justify-center">
      <div className="text-2xl text-gray-500 pb-4"> {React.string(title)} </div>
      <div> {React.string("Coming soon...")} </div>
    </div>
  }
}

module ShowPage = {
  @react.component
  let make = (~entityName, ~id) => {
    <div className="h-full w-fit flex flex-col m-12">
      <div className="text-2xl text-gray-500 pb-4">
        {React.string(`Show ${entityName} `)}
        <span className="text-sm"> {React.string(`#${id}`)} </span>
      </div>
      <div> {React.string("Coming soon...")} </div>
    </div>
  }
}

module UnauthorizedPage = {
  @react.component
  let make = (~entityName) => {
    <div className="h-full w-fit flex flex-col m-12">
      <div className="text-2xl text-gray-500 pb-4"> {React.string(entityName)} </div>
      <div> {React.string("You don't have access to this module. Contact admin for access")} </div>
    </div>
  }
}

@react.component
let make = (
  ~entityName="",
  ~remainingPath,
  ~isAdminAccount=false,
  ~access: AuthTypes.authorization=Access,
  ~renderList=_ => <ComingSoon title="List" />,
  ~renderNewForm=_ => <ComingSoon title="New Form" />,
  ~renderShow=?,
  ~renderOrder=?,
  ~renderEdit=_ => <ComingSoon title="Edit Form" />,
  ~renderEditWithMultiId=(_, _) => <ComingSoon title="Edit Form" />,
  ~renderClone=_ => <ComingSoon title="Clone Form" />,
) => {
  if access === NoAccess {
    <UnauthorizedPage entityName />
  } else {
    switch remainingPath {
    | list{"new"} =>
      switch access {
      | Access => renderNewForm()
      | NoAccess => <UnauthorizedPage entityName />
      }
    | list{id, "clone"} =>
      switch access {
      | Access => renderClone(id)
      | NoAccess => <UnauthorizedPage entityName />
      }
    | list{id} =>
      let page = switch renderShow {
      | Some(fn) => fn(id)
      | None => <ShowPage entityName id />
      }
      page
    | list{id, "edit"} =>
      switch access {
      | Access => renderEdit(id)
      | NoAccess => <UnauthorizedPage entityName />
      }
    | list{id1, id2, "edit"} =>
      switch access {
      | Access => renderEditWithMultiId(id1, id2)
      | NoAccess => <UnauthorizedPage entityName />
      }
    | list{"order", id} =>
      switch renderOrder {
      | Some(fn) => fn(id)
      | None => <NotFoundPage />
      }
    | list{} => renderList()
    | _ => <NotFoundPage />
    }
  }
}
