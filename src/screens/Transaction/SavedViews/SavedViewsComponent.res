open LogicUtils
open Typography
open SavedViewTypes

let defaultViewName = "Default View"

@react.component
let make = (
  ~version: UserInfoTypes.version=V1,
  ~savedViewDataVersion: UserInfoTypes.version=version,
  ~entity: SavedViewTypes.entity=Payment,
) => {
  let showToast = ToastAdapter.useShowToast()
  let {updateExistingKeys, filterValue, reset, setfilterKeys} = React.useContext(
    FilterContext.filterContext,
  )
  let (panelState, setPanelState) = React.useState(_ => NoActiveInteraction)
  let (savedViews: array<SavedViewTypes.savedView>, setSavedViews) = React.useState(_ => [])
  let (activeView: option<SavedViewTypes.savedView>, setActiveView) = React.useState(_ => None)
  let (isInternalUpdate, setIsInternalUpdate) = React.useState(_ => false)

  let fetchSavedViewsHook = SavedViewsHooks.useFetchSavedViews(~entity, ~version)
  let fetchSavedViews = async () => {
    await fetchSavedViewsHook(~setSavedViews)
  }

  React.useEffect(() => {
    setActiveView(_ => None)
    setPanelState(_ => NoActiveInteraction)
    setSavedViews(_ => [])
    fetchSavedViews()->ignore
    None
  }, (version, entity))

  React.useEffect(() => {
    if !isInternalUpdate {
      let currentFiltersDict = SavedViewsUtils.buildCurrentFiltersDict(filterValue)
      setActiveView(_ =>
        savedViews->isNonEmptyArray
          ? SavedViewsUtils.findMatchingView(~savedViews, ~currentFiltersDict, ~version)
          : None
      )
    }
    None
  }, (filterValue, savedViews, version, entity, isInternalUpdate))

  let showPopUp = PopUpState.useShowPopUp()

  let performDeleteHook = SavedViewsHooks.useDeleteSavedView(~entity, ~fetchSavedViews)
  let isActiveView = (view: SavedViewTypes.savedView) =>
    activeView->mapOptionOrDefault(false, active => active.view_id === view.view_id)

  let performDelete = async (view: SavedViewTypes.savedView) => {
    await performDeleteHook(view.view_id, view.view_name, ~onSuccess=() => {
      view->isActiveView ? setActiveView(_ => None) : ()
    })
  }

  let performRenameHook = SavedViewsHooks.useRenameSavedView(
    ~entity,
    ~savedViewDataVersion,
    ~fetchSavedViews,
  )
  let performRename = async (view: SavedViewTypes.savedView, newName) => {
    await performRenameHook(view, newName, ~onSuccess=() => {
      view->isActiveView ? setActiveView(_ => Some({...view, view_name: newName})) : ()
    })
  }

  let handleDelete = (view: SavedViewTypes.savedView, ev) => {
    ev->ReactEvent.Mouse.stopPropagation
    showPopUp({
      heading: `Delete '${view.view_name}'?`,
      description: "This saved view will be deleted permanently"->React.string,
      popUpType: (Danger, WithoutIcon),
      handleCancel: {text: "Cancel"},
      handleConfirm: {
        text: "Delete Saved View",
        onClick: _ => {
          performDelete(view)->ignore
        },
      },
    })
  }

  let handleSelect = viewName => {
    setIsInternalUpdate(_ => true)
    if viewName->isNonEmptyString {
      switch savedViews->Array.find(view => view.view_name === viewName) {
      | None =>
        showToast(~message=`Saved view '${viewName}' not found.`, ~toastType=ToastError)
        setIsInternalUpdate(_ => false)
      | Some(selectedView) =>
        setActiveView(_ => Some(selectedView))
        let filterDict = selectedView.filters->getDictFromJsonObject
        let (stringDict, uniqueDisplayKeys) = SavedViewsUtils.getApplyFilters(
          ~filterDict,
          ~filterValue,
          ~version,
        )

        setfilterKeys(_ => uniqueDisplayKeys)
        stringDict->updateExistingKeys
      }
    } else {
      reset()
    }
  }

  React.useEffect(() => {
    if isInternalUpdate {
      setIsInternalUpdate(_ => false)
    }
    None
  }, [filterValue])

  <div className="flex items-center gap-2">
    <Button
      text="Save Current View"
      buttonSize=Large
      buttonType=Secondary
      leftIcon={CustomIcon(<Icon name="bookmark-outline" size=16 />)}
      onClick={_ => setPanelState(_ => SaveViewModalOpen)}
      customBackColor="bg-white"
      customRoundedClass="rounded-lg"
      customButtonStyle="text-nd_gray-700 hover:bg-nd_gray-50 border"
    />
    <HeadlessUISelectBox
      options={SavedViewsUtils.buildViewOptions(
        ~savedViews,
        ~activeView,
        ~defaultViewName,
        ~panelState,
        ~setPanelState,
        ~performRename,
        ~handleDelete,
      )}
      setValue={handleSelect}
      value={HeadlessUI.String(activeView->mapOptionOrDefault("", view => view.view_name))}
      dropdownPosition=Right
      showTick=false
      dropDownClass="w-64">
      <div
        className={`flex items-center gap-3 px-4 py-2 border rounded-lg bg-white h-10 hover:bg-nd_gray-50 cursor-pointer text-nd_gray-700 ${body.md.medium}`}>
        <Icon name="eye-outline" size=16 className="opacity-70" />
        <div className="truncate max-w-24">
          {activeView->mapOptionOrDefault("Saved Views", view => view.view_name)->React.string}
        </div>
        <Icon name="chevron-down" size=14 className="opacity-50 ml-auto" />
      </div>
    </HeadlessUISelectBox>
    <SaveViewModalComp
      showModal={panelState === SaveViewModalOpen}
      setShowModal={updater =>
        setPanelState(prev =>
          updater(prev === SaveViewModalOpen) ? SaveViewModalOpen : NoActiveInteraction
        )}
      version
      savedViewDataVersion
      entity
      onViewsUpdated={(_res, name) => {
        let refreshViews = async () => {
          let views = await fetchSavedViewsHook(~setSavedViews)
          switch name {
          | Some(name) => setActiveView(_ => views->Array.find(view => view.view_name === name))
          | None => ()
          }
        }
        refreshViews()->ignore
      }}
    />
  </div>
}
