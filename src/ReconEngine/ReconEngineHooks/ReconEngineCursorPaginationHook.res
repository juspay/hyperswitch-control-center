open ReconEngineTypes
open LogicUtils
open ReconEngineUtils

type persistedCursorState = {
  sortBy: cursor,
  direction: cursorDirection,
}

type cursorPaginationResult<'item> = {
  items: array<'item>,
  cursors: cursors,
  screenState: PageLoaderWrapper.viewType,
  goToFirstPage: unit => unit,
  goToNextPage: unit => unit,
  goToPrevPage: unit => unit,
}

let cursorFromPersistedDict = (dict): cursor => {
  let cursorValue =
    dict
    ->getOptionObj("cursor_value")
    ->Option.map((cursorValueDict): cursorValue => {
      effectiveAt: cursorValueDict->getString("effective_at", ""),
      cursorId: cursorValueDict->getString("id", ""),
    })
  {
    sortField: dict->getString("sort_field", "effective_at"),
    cursorValue,
  }
}

let restorePersistedCursor = (persistKey): option<(cursor, cursorDirection)> => {
  open SessionStorage

  sessionStorage.getItem(persistKey)
  ->Nullable.toOption
  ->mapOptionOrDefault(None, value => {
    value
    ->safeParseOpt
    ->mapOptionOrDefault(None, json => {
      let dict = json->getDictFromJsonObject
      let sortBy = dict->getDictfromDict("sortBy")->cursorFromPersistedDict
      let direction: cursorDirection =
        dict->getString("direction", "next") === "previous" ? #previous : #next
      Some((sortBy, direction))
    })
  })
}

let useCursorPagination = (
  ~fetchPage: (~sortBy: cursor, ~direction: cursorDirection) => promise<cursorPage<'item>>,
  ~persistKey: string,
) => {
  open SessionStorage

  let (items, setItems) = React.useState(_ => [])
  let (cursors, setCursors) = React.useState((_): cursors => {next: None, prev: None})
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let hasRestoredRef = React.useRef(false)

  let goTo = async (~sortBy, ~direction) => {
    setScreenState(_ => PageLoaderWrapper.Loading)
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
    | Some(sortBy, direction) => goTo(~sortBy, ~direction)->ignore
    | None => goTo(~sortBy=defaultCursorSortBy, ~direction=#next)->ignore
    }
  }

  let goToNextPage = () =>
    switch cursors.next {
    | Some(cursor) => goTo(~sortBy=cursor, ~direction=#next)->ignore
    | None => ()
    }

  let goToPrevPage = () =>
    switch cursors.prev {
    | Some(cursor) => goTo(~sortBy=cursor, ~direction=#previous)->ignore
    | None => ()
    }

  {items, cursors, screenState, goToFirstPage, goToNextPage, goToPrevPage}
}
