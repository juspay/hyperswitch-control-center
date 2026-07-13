open ReconEngineTypes
open LogicUtils

type persistedCursorState = {
  sortBy: cursor,
  direction: cursorDirection,
}

let cursorFromPersistedDict = (dict): cursor => {
  let cursorValue =
    dict
    ->getOptionValFromDict("cursor_value")
    ->Option.filter(json => json->JSON.Classify.classify != Null)
    ->Option.map(json => {
      let cursorValueDict = json->getDictFromJsonObject

      (
        {
          effectiveAt: cursorValueDict->getString("effective_at", ""),
          cursorId: cursorValueDict->getString("id", ""),
        }: cursorValue
      )
    })
  {
    sortField: dict->getString("sort_field", "effective_at"),
    cursorValue,
  }
}

let restorePersistedCursor = (persistKey): option<(cursor, cursorDirection)> => {
  open SessionStorage
  switch sessionStorage.getItem(persistKey)->Nullable.toOption {
  | None => None
  | Some(value) =>
    switch value->safeParseOpt {
    | None => None
    | Some(json) =>
      let dict = json->getDictFromJsonObject
      let sortBy = dict->getDictfromDict("sortBy")->cursorFromPersistedDict
      let direction: cursorDirection =
        dict->getString("direction", "next") === "previous" ? #previous : #next
      Some((sortBy, direction))
    }
  }
}

let useCursorPagination = (
  ~fetchPage: (~sortBy: cursor, ~direction: cursorDirection) => promise<cursorPage<'item>>,
  ~persistKey: string,
) => {
  open SessionStorage

  let (items, setItems) = React.useState((_): array<'item> => [])
  let (cursors, setCursors) = React.useState((_): cursors => {next: None, prev: None})
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let hasRestoredRef = React.useRef(false)

  let goTo = async (~sortBy, ~direction) => {
    if screenState !== PageLoaderWrapper.Success {
      setScreenState(_ => PageLoaderWrapper.Loading)
    }
    try {
      let page = await fetchPage(~sortBy, ~direction)
      setItems(_ => page.items)
      setCursors(_ => page.cursors)
      sessionStorage.setItem(
        persistKey,
        ({sortBy, direction}: persistedCursorState)->Identity.genericTypeToJson->JSON.stringify,
      )
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  let goToFirstPage = () => {
    let restored = hasRestoredRef.current ? None : restorePersistedCursor(persistKey)
    hasRestoredRef.current = true
    switch restored {
    | Some((sortBy, direction)) => goTo(~sortBy, ~direction)->ignore
    | None => goTo(~sortBy=ReconEngineUtils.defaultCursorSortBy, ~direction=#next)->ignore
    }
  }

  let goToNextPage = () =>
    cursors.next->mapOptionOrDefault((), cursor => goTo(~sortBy=cursor, ~direction=#next)->ignore)

  let goToPrevPage = () =>
    cursors.prev->mapOptionOrDefault((), cursor =>
      goTo(~sortBy=cursor, ~direction=#previous)->ignore
    )

  (items, cursors, screenState, goToFirstPage, goToNextPage, goToPrevPage)
}
