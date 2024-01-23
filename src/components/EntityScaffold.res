@react.component
let make = (
  ~entityName="",
  ~remainingPath,
  ~isAdminAccount=false,
  ~access: AuthTypes.authorization=Access,
  ~renderList,
  ~renderNewForm=_ => React.null,
  ~renderShow=_ => React.null,
) => {
  if access === NoAccess {
    <UnauthorizedPage />
  } else {
    switch remainingPath {
    | list{"new"} => renderNewForm()
    | list{id} => renderShow(id)
    | list{} => renderList()
    | _ => <NotFoundPage />
    }
  }
}
