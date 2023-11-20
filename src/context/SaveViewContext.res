open SaveViewEntity
open LogicUtils
type contextType = {
  savedViewList: array<saveView>,
  setSavedViewList: (array<saveView> => array<saveView>) => unit,
  isDefaultSaveViewPresent: bool,
  setIsDefaultSaveViewPresent: (bool => bool) => unit,
  refetchCounter: int,
  setRefetchCounter: (int => int) => unit,
  defaultSaveView: saveView,
  setDefaultSaveView: (saveView => saveView) => unit,
  appliedSaveView: saveView,
  setAppliedSaveView: (saveView => saveView) => unit,
  applySaveView: saveView => unit,
  moduleName: string,
}

let defaultValue = {
  savedViewList: [],
  setSavedViewList: _ => (),
  isDefaultSaveViewPresent: false,
  setIsDefaultSaveViewPresent: _ => (),
  refetchCounter: 0,
  setRefetchCounter: _ => (),
  defaultSaveView,
  setDefaultSaveView: _ => (),
  appliedSaveView: defaultSaveView,
  setAppliedSaveView: _ => (),
  applySaveView: _ => (),
  moduleName: "",
}

let defaultContext = React.createContext(defaultValue)

module Provider = {
  let make = React.Context.provider(defaultContext)
}
let (startTimeFilterKey, endTimeFilterKey, optFilterKey) = ("startTime", "endTime", "opt")
@react.component
let make = (~moduleName, ~children) => {
  let {reset, updateExistingKeys, filterValueJson} = React.useContext(
    AnalyticsUrlUpdaterContext.urlUpdaterContext,
  )
  // have default date when saved view is there without daterange
  let getDefaultDate = AnalyticsUtils.getDateCreatedObject()
  let defaultStateTimeValue = getDefaultDate->LogicUtils.getString(startTimeFilterKey, "")
  let defaultEndTime = getDefaultDate->LogicUtils.getString(endTimeFilterKey, "")
  let (startTime, endTime) = React.useMemo1(() => {
    (
      filterValueJson->getString(startTimeFilterKey, defaultStateTimeValue),
      filterValueJson->getString(endTimeFilterKey, defaultEndTime),
    )
  }, [filterValueJson])

  let dateFilterUrl = React.useMemo2(() => {
    if startTime !== "" && endTimeFilterKey !== "" {
      `&${startTimeFilterKey}=${startTime}&${endTimeFilterKey}=${endTime}`
    } else {
      ""
    }
  }, (startTime, endTime))
  let updateComponentPrefrences = UrlUtils.useUpdateUrlWith(~prefix="")
  let fetchSaveView = AnalyticsHooks.useSaveViewListFetcher()
  let (savedViewList, setSavedViewList) = React.useState(_ => [])
  let (isDefaultSaveViewPresent, setIsDefaultSaveViewPresent) = React.useState(_ => false)
  let (refetchCounter, setRefetchCounter) = React.useState(_ => 0)
  let (appliedSaveView, setAppliedSaveView) = React.useState(_ => defaultSaveView)
  let (defaultSaveView, setDefaultSaveView) = React.useState(_ => defaultSaveView)
  let (fetchedDone, setFectedDone) = React.useState(_ => false)
  let parseFn = json =>
    json->getSaveDetials->Js.Array2.filter(saveView => saveView.tab === moduleName)

  let applySaveView = saveView => {
    // when applying saved view without date range take the date range of the context
    let saveView = if saveView.includeDateRange {
      saveView
    } else {
      {...saveView, url: `${saveView.url}${dateFilterUrl}`}
    }
    let urlDict = getFilterDict(~url=saveView.url, ~prefix="", ())

    reset()
    updateExistingKeys(urlDict)
    setAppliedSaveView(_ => saveView)
  }

  let process = rows => {
    let fetchedSavedViewList = rows->parseFn
    let defaultSave =
      fetchedSavedViewList->Js.Array2.filter(saveView => saveView.isDefault)->Belt.Array.get(0)
    if defaultSave->Belt.Option.isSome {
      setIsDefaultSaveViewPresent(_ => defaultSave->Belt.Option.isSome)
      let defaultSave = defaultSave->Belt.Option.getWithDefault(defaultSaveView)
      let defaultSave = if defaultSaveView.includeDateRange {
        defaultSave
      } else {
        {...defaultSave, url: `${defaultSave.url}${dateFilterUrl}`}
      }

      setDefaultSaveView(_ => defaultSave)
      let urlDict = getFilterDict(~url=defaultSave.url, ~prefix="", ())
      updateComponentPrefrences(~dict=urlDict)
      setAppliedSaveView(_ => defaultSave)
    } else {
      setDefaultSaveView(_ => defaultSaveView)
      setIsDefaultSaveViewPresent(_ => false)
    }
    setFectedDone(_ => true)
    setSavedViewList(_ => rows->parseFn)
  }

  let fetch = () => {
    fetchSaveView(~process)
  }

  React.useEffect1(() => {
    fetch()
    None
  }, [refetchCounter])

  React.useEffect1(() => {
    savedViewList->Js.Array2.forEach(saveView => {
      if appliedSaveView.id === saveView.id {
        applySaveView(saveView)
      }
    })
    None
  }, [savedViewList])

  <Provider
    value={
      savedViewList,
      setSavedViewList,
      isDefaultSaveViewPresent,
      setIsDefaultSaveViewPresent,
      refetchCounter,
      setRefetchCounter,
      defaultSaveView,
      setDefaultSaveView,
      appliedSaveView,
      setAppliedSaveView,
      applySaveView,
      moduleName,
    }>
    {fetchedDone ? children : <Loader />}
  </Provider>
}
