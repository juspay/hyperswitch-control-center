open APIUtils
open LogicUtils
open Typography

let defaultViewName = "Default View"

@react.component
let make = (~version: UserInfoTypes.version=V1, ~entity: string="payment_views") => {
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()
  let {updateExistingKeys, filterValueJson, reset, setfilterKeys} = React.useContext(
    FilterContext.filterContext,
  )
  let (showSaveModal, setShowSaveModal) = React.useState(_ => false)
  let (savedViews: array<SavedViewTypes.savedView>, setSavedViews) = React.useState(_ => [])
  let (activeViewName, setActiveViewName) = React.useState(_ => "")
  let (currentlyEditingIndex, setCurrentlyEditingIndex) = React.useState(_ => None)
  let isInternalUpdate = React.useRef(false)

  let postSavedViewsAction = async payload => {
    let url = getURL(~entityName=V1(USERS), ~userType=#USER_DATA, ~methodType=Post)
    let _ = await updateDetails(url, payload, Post)
  }

  let fetchSavedViews = async () => {
    try {
      let url = getURL(
        ~entityName=V1(USERS),
        ~userType=#USER_DATA,
        ~methodType=Get,
        ~queryParameters=Some(SavedViewsAPI.savedViewsQueryParam(entity)),
      )
      let res = await fetchDetails(url)
      let mappedRes = res->HSwitchOrderUtils.savedViewsResponseMapper
      setSavedViews(_ => mappedRes.views)
    } catch {
    | err =>
      Js.Console.error2("[SavedViews] fetchSavedViews failed", err)
      showToast(~message="Failed to load saved views. Please try again.", ~toastType=ToastError)
    }
  }

  React.useEffect(() => {
    fetchSavedViews()->ignore
    None
  }, [])

  let normalizeDict = dict => {
    let normalized = Dict.make()
    dict
    ->Dict.toArray
    ->Array.forEach(((key, value)) => {
      if (
        key->LogicUtils.isNonEmptyString &&
        value->LogicUtils.isNonEmptyString &&
        key !== "amount_option" &&
        key !== "amount"
      ) {
        normalized->Dict.set(key, value)
      }
    })
    normalized
  }

  React.useEffect(() => {
    if !isInternalUpdate.current && savedViews->Array.length > 0 {
      let currentFiltersStringDict = Dict.make()
      filterValueJson
      ->Dict.toArray
      ->Array.forEach(((key, value)) =>
        SavedViewsUtils.flattenToDict(currentFiltersStringDict, key, value)
      )

      let matchingView = savedViews->Array.find(view => {
        let savedFilters = view.filters->getDictFromJsonObject
        let savedFiltersStringDict = Dict.make()
        let tempCurrentFiltersStringDict = currentFiltersStringDict->Dict.copy

        savedFilters
        ->Dict.toArray
        ->Array.forEach(
          ((key, value)) => SavedViewsUtils.flattenToDict(savedFiltersStringDict, key, value),
        )

        let startTimeKey = OrderUIUtils.startTimeFilterKey(version)
        let endTimeKey = OrderUIUtils.endTimeFilterKey(version)

        if savedFiltersStringDict->Dict.get(startTimeKey)->Option.isNone {
          tempCurrentFiltersStringDict->Dict.delete(startTimeKey)
        }
        if savedFiltersStringDict->Dict.get(endTimeKey)->Option.isNone {
          tempCurrentFiltersStringDict->Dict.delete(endTimeKey)
        }

        let normalizedSaved = savedFiltersStringDict->normalizeDict
        let normalizedCurrent = tempCurrentFiltersStringDict->normalizeDict

        DictionaryUtils.equalDicts(normalizedSaved, normalizedCurrent)
      })

      switch matchingView {
      | Some(view) =>
        if activeViewName !== view.view_name {
          setActiveViewName(_ => view.view_name)
        }
      | None =>
        if activeViewName !== "" {
          setActiveViewName(_ => "")
        }
      }
    }
    None
  }, (filterValueJson, savedViews, version, activeViewName))

  let showPopUp = PopUpState.useShowPopUp()

  let performDelete = async (view_id, viewName) => {
    try {
      let _ = await postSavedViewsAction(SavedViewsAPI.buildDeletePayload(entity, view_id))
      showToast(
        ~message=`'${SavedViewsUtils.truncateName(viewName)}' has been deleted successfully!`,
        ~toastType=ToastSuccess,
      )
      fetchSavedViews()->ignore
    } catch {
    | err =>
      Js.Console.error2("[SavedViews] performDelete failed", err)
      showToast(
        ~message=`Failed to delete view '${SavedViewsUtils.truncateName(
            viewName,
          )}'. Please try again.`,
        ~toastType=ToastError,
      )
    }
  }

  let performRename = async (view: SavedViewTypes.savedView, newName) => {
    try {
      let _ = await postSavedViewsAction(SavedViewsAPI.buildRenamePayload(entity, view, newName))
      showToast(
        ~message=`View renamed to '${SavedViewsUtils.truncateName(newName)}' successfully!`,
        ~toastType=ToastSuccess,
      )
      fetchSavedViews()->ignore
      if activeViewName === view.view_name {
        setActiveViewName(_ => newName)
      }
    } catch {
    | err =>
      Js.Console.error2("[SavedViews] performRename failed", err)
      showToast(~message="Failed to rename view. Please try again.", ~toastType=ToastError)
    }
  }

  let handleDelete = (view: SavedViewTypes.savedView, ev) => {
    ev->ReactEvent.Mouse.stopPropagation
    showPopUp({
      heading: `Delete '${SavedViewsUtils.truncateName(view.view_name)}'?`,
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
    isInternalUpdate.current = true
    if viewName !== "" {
      switch savedViews->Array.find(view => view.view_name === viewName) {
      | None =>
        showToast(
          ~message=`Saved view '${SavedViewsUtils.truncateName(viewName)}' not found.`,
          ~toastType=ToastError,
        )
        isInternalUpdate.current = false
      | Some(selectedView) =>
        setActiveViewName(_ => viewName)
        let filterDict = selectedView.filters->getDictFromJsonObject
        let stringDict = Dict.make()

        // Extract saved view filters first so we can check if dates are included
        let newFiltersDict = Dict.make()
        filterDict
        ->Dict.toArray
        ->Array.forEach(((key, value)) => SavedViewsUtils.flattenToDict(newFiltersDict, key, value))

        // Check if saved view includes date keys
        let startTimeKey = OrderUIUtils.startTimeFilterKey(version)
        let endTimeKey = OrderUIUtils.endTimeFilterKey(version)
        let savedHasDates = newFiltersDict->Dict.get(startTimeKey)->Option.isSome

        // Clear currently active filters, but preserve dates if view doesn't include them
        filterValueJson
        ->Dict.keysToArray
        ->Array.forEach(key => {
          if !savedHasDates && (key === startTimeKey || key === endTimeKey) {
            () // preserve existing date range
          } else {
            stringDict->Dict.set(key, "")
          }
        })

        let rawKeys = newFiltersDict->Dict.keysToArray

        newFiltersDict
        ->Dict.toArray
        ->Array.forEach(((key, value)) => stringDict->Dict.set(key, value))

        // Map keys for UI display
        let displayKeys =
          rawKeys
          ->Array.map(key => {
            if ["amount_option", "start_amount", "end_amount"]->Array.includes(key) {
              "amount"
            } else {
              key
            }
          })
          ->Array.filter(key => {
            !(["start_time", "end_time", "created.gte", "created.lte"]->Array.includes(key))
          })

        let uniqueDisplayKeys = displayKeys->getUniqueArray

        // AmountFilter reads amount_option via stringRangetoTypeAmount which expects
        // variant constructor names (e.g. "InBetween"), NOT human-readable labels.
        // If the saved view didn't persist amount_option (older payload), reconstruct
        // it from start/end presence.
        let startAmountStr = stringDict->Dict.get("start_amount")->Option.getOr("")
        let endAmountStr = stringDict->Dict.get("end_amount")->Option.getOr("")
        let hasStart = startAmountStr->LogicUtils.isNonEmptyString
        let hasEnd = endAmountStr->LogicUtils.isNonEmptyString
        let hasAmountOption =
          stringDict
          ->Dict.get("amount_option")
          ->Option.getOr("")
          ->LogicUtils.isNonEmptyString

        if hasStart || hasEnd {
          if !hasAmountOption {
            let constructorName = switch (hasStart, hasEnd) {
            | (true, true) => startAmountStr === endAmountStr ? "EqualTo" : "InBetween"
            | (true, false) => "GreaterThanOrEqualTo"
            | (false, true) => "LessThanOrEqualTo"
            | (false, false) => ""
            }
            if constructorName->LogicUtils.isNonEmptyString {
              stringDict->Dict.set("amount_option", constructorName)
            }
          }

          if !(uniqueDisplayKeys->Array.includes("amount")) {
            uniqueDisplayKeys->Array.push("amount")->ignore
          }
        }

        setfilterKeys(_ => uniqueDisplayKeys)
        stringDict->updateExistingKeys
      }
    } else {
      reset()
    }
  }

  // Clear the guard flag as soon as the next filterValueJson update arrives.
  // This replaces a fragile 100ms timer and avoids races on slow propagation.
  React.useEffect(() => {
    if isInternalUpdate.current {
      isInternalUpdate.current = false
    }
    None
  }, [filterValueJson])

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
      options={
        let defaultOpt: HeadlessUISelectBox.updatedOptionWithIcons = {
          label: defaultViewName,
          value: "",
          isDisabled: false,
          leftIcon: activeViewName === "" ? CustomIcon(<Tick isSelected=true />) : NoIcon,
          customTextStyle: None,
          customIconStyle: None,
          rightIcon: NoIcon,
          description: None,
          customComponent: None,
        }
        let savedOptions = savedViews->Array.mapWithIndex((view, i) => {
          let name = view.view_name
          let opt: HeadlessUISelectBox.updatedOptionWithIcons = {
            label: name,
            value: name,
            isDisabled: false,
            leftIcon: name === activeViewName ? CustomIcon(<Tick isSelected=true />) : NoIcon,
            customTextStyle: None,
            customIconStyle: None,
            rightIcon: NoIcon,
            description: None,
            customComponent: Some(
              <InlineEditInput
                index=i
                labelText=name
                isUnderEdit={currentlyEditingIndex->Option.mapOr(false, index => index == i)}
                handleEdit={index => setCurrentlyEditingIndex(_ => index)}
                onSubmit={newName => performRename(view, newName)->ignore}
                showEditIcon={true}
                showEditIconOnHover={false}
                iconSize=18
                paddingClass="!p-0"
                bgClass="!bg-transparent !py-0"
                inputPaddingClass="!py-1 !px-2"
                customInputStyle="!py-1 !px-2 !bg-transparent text-nd_gray-700"
                customIconStyle="text-nd_gray-300 hover:text-black"
                customWidth="w-full"
                validateInput={newName => {
                  let errors = Dict.make()
                  if newName->LogicUtils.isEmptyString {
                    errors->Dict.set("view_name", "Name cannot be empty"->JSON.Encode.string)
                  }
                  errors
                }}
                customIconComponent={<div
                  className="text-nd_gray-300 hover:text-red-500 cursor-pointer ml-2"
                  onClick={ev => handleDelete(view, ev)}>
                  <Icon name="trash-outline" size=18 />
                </div>}
              />,
            ),
          }
          opt
        })
        [defaultOpt]->Array.concat(savedOptions)
      }
      setValue={handleSelect}
      value={HeadlessUI.String(activeViewName)}
      dropdownPosition=Right
      showTick=false
      dropDownClass="w-64">
      <div
        className={`flex items-center gap-3 px-4 py-2 border rounded-lg bg-white h-10 hover:bg-nd_gray-50 cursor-pointer text-nd_gray-700 ${body.md.medium}`}>
        <Icon name="eye-outline" size=16 className="opacity-70" />
        {(
          activeViewName->isEmptyString
            ? "Saved Views"
            : activeViewName->SavedViewsUtils.truncateName
        )->React.string}
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
