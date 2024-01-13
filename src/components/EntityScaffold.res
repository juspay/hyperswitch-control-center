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
  ~access: AuthTypes.authorization=ReadWrite,
  ~renderList=() => <ComingSoon title="List" />,
  ~renderNewForm=() => <ComingSoon title="New Form" />,
  ~renderShow=?,
  ~renderOrder=?,
  ~renderEdit=_id => <ComingSoon title="Edit Form" />,
  ~renderEditWithMultiId=(_id1, _id2) => <ComingSoon title="Edit Form" />,
  ~renderClone=_id => <ComingSoon title="Clone Form" />,
) => {
  if access === NoAccess {
    <UnauthorizedPage entityName />
  } else {
    switch remainingPath {
    | list{"new"} =>
      switch access {
      | ReadWrite => renderNewForm()
      | Checker => isAdminAccount ? renderNewForm() : <UnauthorizedPage entityName />
      | _ => <UnauthorizedPage entityName />
      }
    | list{id, "clone"} =>
      switch access {
      | ReadWrite => renderClone(id)
      | _ => <UnauthorizedPage entityName />
      }
    | list{id} =>
      let page = switch renderShow {
      | Some(fn) => fn(id)
      | None => <ShowPage entityName id />
      }
      page
    | list{id, "edit"} =>
      switch access {
      | ReadWrite => renderEdit(id)
      | Checker => isAdminAccount ? renderEdit(id) : <UnauthorizedPage entityName />
      | _ => <UnauthorizedPage entityName />
      }
    | list{id1, id2, "edit"} =>
      switch access {
      | ReadWrite => renderEditWithMultiId(id1, id2)
      | Checker =>
        isAdminAccount ? renderEditWithMultiId(id1, id2) : <UnauthorizedPage entityName />
      | _ => <UnauthorizedPage entityName />
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
