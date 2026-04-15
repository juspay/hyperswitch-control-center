// Pure payload/url builders — no function args, so labeled-arg currying
// of the API hooks never leaks into this module's inferred types.

let savedViewsQueryParam = entity => `keys=${SavedViewsUtils.entityToKey(entity)}`

let buildActionPayload = (entity, actionType, dataDict) => {
  let keys = SavedViewsUtils.entityToKey(entity)
  let actionDict =
    [("type", actionType->JSON.Encode.string), ("data", dataDict->JSON.Encode.object)]
    ->Dict.fromArray
    ->JSON.Encode.object
  [(keys, actionDict)]
  ->Dict.fromArray
  ->JSON.Encode.object
}

let buildDeletePayload = (entity, viewId) => {
  let dataDict =
    [("entity", entity->JSON.Encode.string), ("view_id", viewId->JSON.Encode.string)]->Dict.fromArray
  buildActionPayload(entity, "Delete", dataDict)
}

let buildRenamePayload = (entity, view: SavedViewTypes.savedView, newName) => {
  let dataDict =
    [
      ("view_id", view.view_id->JSON.Encode.string),
      ("view_name", newName->JSON.Encode.string),
      ("filters", view.filters),
      ("entity", entity->JSON.Encode.string),
      ("version", "v1"->JSON.Encode.string),
    ]->Dict.fromArray
  buildActionPayload(entity, "Update", dataDict)
}

let buildSavePayload = (entity, actionType, name, filters: JSON.t, viewId: option<string>) => {
  let dataDict =
    [
      ("view_name", name->JSON.Encode.string),
      ("filters", filters),
      ("entity", entity->JSON.Encode.string),
      ("version", "v1"->JSON.Encode.string),
    ]->Dict.fromArray
  switch viewId {
  | Some(id) => dataDict->Dict.set("view_id", id->JSON.Encode.string)
  | None => ()
  }
  buildActionPayload(entity, actionType, dataDict)
}
