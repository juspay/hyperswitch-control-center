@react.component
let make = (
  ~entityName="",
  ~remainingPath,
  ~isAdminAccount=false,
  ~access: CommonAuthTypes.authorization=Access,
  ~renderList,
  ~renderNewForm=_ => React.null,
  ~renderShow=(_, _) => React.null,
  ~renderCustomWithOMP: (string, option<string>, option<string>, option<string>) => React.element=(
    _,
    _,
    _,
    _,
  ) => React.null,
) => {
  if access === NoAccess {
    <UnauthorizedPage />
  } else {
    switch remainingPath {
    | list{"new"} => renderNewForm()
    | list{id} => renderShow(id, None)
    | list{id, key} => renderShow(id, Some(key))
    | list{id, profileId, merchantId, orgId} =>
      renderCustomWithOMP(id, Some(profileId), Some(merchantId), Some(orgId))
    | list{} => renderList()
    | _ => <NotFoundPage />
    }
  }
}
