open LogicUtils
open Typography
open SavedViewTypes

let defaultViewName = "Default View"

@react.component
let make = (~version: UserInfoTypes.version=V1, ~entity: SavedViewTypes.entity=Payment) => {
  let showToast = ToastAdapter.useShowToast()
  let {updateExistingKeys, filterValue, reset, setfilterKeys} = React.useContext(
    FilterContext.filterContext,
  )
  let (showSaveModal, setShowSaveModal) = React.useState(_ => false)
  let (savedViews: array<SavedViewTypes.savedView>, setSavedViews) = React.useState(_ => [])
  let (activeViewName, setActiveViewName) = React.useState(_ => "")
  let (currentlyEditingIndex, setCurrentlyEditingIndex) = React.useState(_ => None)
  let (isInternalUpdate, setIsInternalUpdate) = React.useState(_ => false)

  let fetchSavedViewsHook = SavedViewsHooks.useFetchSavedViews(~entity, ~version)
  let fetchSavedViews = async () => {
    await fetchSavedViewsHook(~setSavedViews)
  }

  React.useEffect(() => {
    fetchSavedViews()->ignore
    None
  }, [])

  React.useEffect(() => {
    if !isInternalUpdate && savedViews->Array.length > 0 {
      let currentFiltersDict = SavedViewsUtils.buildCurrentFiltersDict(filterValue)
      let matchingView = SavedViewsUtils.findMatchingView(
        ~savedViews,
        ~currentFiltersDict,
        ~version,
      )
      switch matchingView {
      | Some(view) =>
        if activeViewName !== view.view_name {
          setActiveViewName(_ => view.view_name)
        }
      | None =>
        if activeViewName->isNonEmptyString {
          setActiveViewName(_ => "")
        }
      }
    }
    None
  }, (filterValue, savedViews, version, isInternalUpdate))

  let showPopUp = PopUpState.useShowPopUp()

  let performDeleteHook = SavedViewsHooks.useDeleteSavedView(~entity, ~fetchSavedViews)
  let performDelete = async (view_id, viewName) => {
    await performDeleteHook(view_id, viewName, ~onSuccess=() => {
      activeViewName === viewName ? setActiveViewName(_ => "") : ()
    })
  }

  let performRenameHook = SavedViewsHooks.useRenameSavedView(~entity, ~version, ~fetchSavedViews)
  let performRename = async (view: SavedViewTypes.savedView, newName) => {
    await performRenameHook(view, newName, ~onSuccess=() => {
      activeViewName === view.view_name ? setActiveViewName(_ => newName) : ()
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
          performDelete(view.view_id, view.view_name)->ignore
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
        setActiveViewName(_ => viewName)
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
      onClick={_ => setShowSaveModal(_ => true)}
      customBackColor="bg-white"
      customRoundedClass="rounded-lg"
      customButtonStyle="text-nd_gray-700 hover:bg-nd_gray-50 border"
    />
    <HeadlessUISelectBox
      options={SavedViewsUtils.buildViewOptions(
        ~savedViews,
        ~activeViewName,
        ~defaultViewName,
        ~currentlyEditingIndex,
        ~setCurrentlyEditingIndex,
        ~performRename,
        ~handleDelete,
      )}
      setValue={handleSelect}
      value={HeadlessUI.String(activeViewName)}
      dropdownPosition=Right
      showTick=false
      dropDownClass="w-64">
      <div
        className={`flex items-center gap-3 px-4 py-2 border rounded-lg bg-white h-10 hover:bg-nd_gray-50 cursor-pointer text-nd_gray-700 ${body.md.medium}`}>
        <Icon name="eye-outline" size=16 className="opacity-70" />
        <div className="truncate max-w-24">
          {(activeViewName->isEmptyString ? "Saved Views" : activeViewName)->React.string}
        </div>
        <Icon name="chevron-down" size=14 className="opacity-50 ml-auto" />
      </div>
    </HeadlessUISelectBox>
    <SaveViewModalComp
      showModal=showSaveModal
      setShowModal=setShowSaveModal
      version
      entity
      onViewsUpdated={(_res, name) => {
        fetchSavedViews()->ignore
        switch name {
        | Some(n) => setActiveViewName(_ => n)
        | None => ()
        }
      }}
    />
  </div>
}
