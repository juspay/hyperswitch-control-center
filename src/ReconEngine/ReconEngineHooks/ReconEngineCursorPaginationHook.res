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
      version: cursorValueDict->getInt("version", 0),
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
  ~persistKey: option<string>=None,
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
      switch persistKey {
      | Some(key) =>
        sessionStorage.setItem(
          key,
          ({sortBy, direction}: persistedCursorState)->Identity.genericTypeToJson->JSON.stringify,
        )
      | None => ()
      }
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  let goToFirstPage = () => {
    let restored = hasRestoredRef.current
      ? None
      : persistKey->Option.flatMap(key => restorePersistedCursor(key))
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

type cursorLoadMoreResult<'item> = {
  items: array<'item>,
  hasMore: bool,
  screenState: PageLoaderWrapper.viewType,
  isLoadingMore: bool,
  loadFirstPage: unit => unit,
  loadMore: unit => unit,
}

let useCursorLoadMore = (~fetchPage: (~sortBy: cursor) => promise<cursorPage<'item>>) => {
  let showToast = ToastAdapter.useShowToast()
  let (items, setItems) = React.useState(_ => [])
  let (nextCursor, setNextCursor) = React.useState((_): option<cursor> => None)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (isLoadingMore, setIsLoadingMore) = React.useState(_ => false)

  let fetchFirstPage = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let page = await fetchPage(~sortBy=versionCursorSortBy)
      setItems(_ => page.items)
      setNextCursor(_ => page.cursors.next)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  let fetchNextPage = async cursor => {
    setIsLoadingMore(_ => true)
    try {
      let page = await fetchPage(~sortBy=cursor)
      setItems(prev => prev->Array.concat(page.items))
      setNextCursor(_ => page.cursors.next)
    } catch {
    | _ => showToast(~message="Failed to load older versions", ~toastType=ToastError)
    }
    setIsLoadingMore(_ => false)
  }

  {
    items,
    hasMore: nextCursor->Option.isSome,
    screenState,
    isLoadingMore,
    loadFirstPage: () => fetchFirstPage()->ignore,
    loadMore: () => nextCursor->Option.forEach(cursor => fetchNextPage(cursor)->ignore),
  }
}
