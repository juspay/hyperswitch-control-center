@react.component
let make = (
  ~entityName="",
  ~remainingPath,
  ~isAdminAccount=false,
  ~access: AuthTypes.authorization=Access,
  ~renderList,
  ~renderNewForm=?,
  ~renderShow=?,
) => {
  if access === NoAccess {
    <UnauthorizedPage />
  } else {
    switch remainingPath {
    | list{"new"} =>
      switch access {
      | Access =>
        switch renderNewForm {
        | Some(element) => element()
        | None => React.null
        }
      | NoAccess => <UnauthorizedPage />
      }
    | list{id} =>
      let page = switch renderShow {
      | Some(fn) => fn(id)
      | None => React.null
      }
      page
    | list{} => renderList()
    | _ => <NotFoundPage />
    }
  }
}
