open APIUtils
open LogicUtils
open Typography

let defaultViewName = "Default View"

@react.component
let make = (~version: UserInfoTypes.version=V1, ~entity: string="payments") => {
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
  let isInternalUpdate = React.useRef(false)

  let fetchSavedViews = async () => {
    try {
      let url = getURL(
        ~entityName=V1(SAVED_VIEWS),
        ~methodType=Get,
        ~queryParameters=Some(`entity=${entity}`),
      )
      let res = await fetchDetails(url)
      let mappedRes = res->HSwitchOrderUtils.savedViewsResponseMapper
      setSavedViews(_ => mappedRes.views)
    } catch {
    | _ => ()
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
      ->Array.forEach(item => {
        let (key, value) = item
        SavedViewsUtils.flattenToDict(currentFiltersStringDict, key, value)
      })

      let matchingView = savedViews->Array.find(view => {
        let savedFilters = view.filters->getDictFromJsonObject
        let savedFiltersStringDict = Dict.make()
        let tempCurrentFiltersStringDict = currentFiltersStringDict->Dict.copy

        savedFilters
        ->Dict.toArray
        ->Array.forEach(
          item => {
            let (key, value) = item
            SavedViewsUtils.flattenToDict(savedFiltersStringDict, key, value)
          },
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
  }, (filterValueJson, savedViews, version))

  let showPopUp = PopUpState.useShowPopUp()

  let performDelete = async viewName => {
    try {
      let url = getURL(~entityName=V1(SAVED_VIEWS), ~methodType=Delete)
      let payload =
        [("view_name", viewName->JSON.Encode.string), ("entity", entity->JSON.Encode.string)]
        ->Dict.fromArray
        ->JSON.Encode.object
      let _ = await updateDetails(url, payload, Delete)
      showToast(
        ~message=`'${viewName}' has been deleted successfully!`,
        ~toastType=ToastSuccess,
        ~toastElement={
          <div
            className="border-l-green-status rounded-lg shadow-sm bg-white border border-l-4 p-4 flex items-center">
            <Icon name="trash-outline" size=20 className="text-green-status mr-3" />
            <div className={`${body.md.medium} text-gray-800 flex items-center gap-1`}>
              {"'"->React.string}
              <HelperComponents.EllipsisText
                displayValue=viewName endValue=15 showCopy=false expandText=false
              />
              {"' has been deleted successfully!"->React.string}
            </div>
          </div>
        },
      )
      fetchSavedViews()->ignore
    } catch {
    | _ =>
      showToast(
        ~message=`Failed to delete view '${viewName}'. Please try again.`,
        ~toastType=ToastError,
      )
    }
  }

  let handleDelete = (viewName, ev) => {
    ev->ReactEvent.Mouse.stopPropagation
    showPopUp({
      heading: `Delete '${SavedViewsUtils.truncateName(viewName)}'?`,
      description: "This saved view will be deleted permanently"->React.string,
      popUpType: (Danger, WithoutIcon),
      handleCancel: {text: "Cancel"},
      handleConfirm: {
        text: "Delete Saved View",
        onClick: _ => {
          performDelete(viewName)->ignore
        },
      },
    })
  }

  let handleSelect = viewName => {
    isInternalUpdate.current = true
    setActiveViewName(_ => viewName)
    if viewName !== "" {
      let selectedView =
        savedViews
        ->Array.find(view => view.view_name === viewName)
        ->Option.getOr({
          view_name: "",
          entity,
          filters: JSON.Encode.object(Dict.make()),
          created_at: "",
          updated_at: "",
        })

      let filterDict = selectedView.filters->getDictFromJsonObject
      let stringDict = Dict.make()

      // Extract saved view filters first so we can check if dates are included
      let newFiltersDict = Dict.make()
      filterDict
      ->Dict.toArray
      ->Array.forEach(item => {
        let (key, value) = item
        SavedViewsUtils.flattenToDict(newFiltersDict, key, value)
      })

      // Check if saved view includes date keys
      let startTimeKey = OrderUIUtils.startTimeFilterKey(version)
      let endTimeKey = OrderUIUtils.endTimeFilterKey(version)
      let savedHasDates = newFiltersDict->Dict.get(startTimeKey)->Option.isSome

      // Clear currently active filters, but preserve dates if view doesn't include them
      filterValueJson
      ->Dict.toArray
      ->Array.forEach(item => {
        let (key, _) = item
        if !savedHasDates && (key === startTimeKey || key === endTimeKey) {
          () // preserve existing date range
        } else {
          stringDict->Dict.set(key, "")
        }
      })

      let rawKeys = newFiltersDict->Dict.keysToArray

      newFiltersDict
      ->Dict.toArray
      ->Array.forEach(item => {
        let (key, value) = item
        stringDict->Dict.set(key, value)
      })

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

      let uniqueDisplayKeys = []
      displayKeys->Array.forEach(key => {
        if !(uniqueDisplayKeys->Array.includes(key)) {
          uniqueDisplayKeys->Array.push(key)->ignore
        }
      })

      // reconstruct amount_option from start/end amounts
      let startAmountStr = stringDict->Dict.get("start_amount")->Option.getOr("")
      let endAmountStr = stringDict->Dict.get("end_amount")->Option.getOr("")

      if startAmountStr->LogicUtils.isNonEmptyString || endAmountStr->LogicUtils.isNonEmptyString {
        if (
          startAmountStr->LogicUtils.isNonEmptyString && endAmountStr->LogicUtils.isNonEmptyString
        ) {
          if startAmountStr === endAmountStr {
            stringDict->Dict.set("amount_option", "EqualTo")
          } else {
            stringDict->Dict.set("amount_option", "InBetween")
          }
        } else if startAmountStr->LogicUtils.isNonEmptyString {
          stringDict->Dict.set("amount_option", "GreaterThanOrEqualTo")
        } else if endAmountStr->LogicUtils.isNonEmptyString {
          stringDict->Dict.set("amount_option", "LessThanOrEqualTo")
        }

        if !(uniqueDisplayKeys->Array.includes("amount")) {
          uniqueDisplayKeys->Array.push("amount")->ignore
        }
      }

      setfilterKeys(_ => uniqueDisplayKeys)
      stringDict->updateExistingKeys
    } else {
      reset()
    }

    let _ = Js.Global.setTimeout(() => {
      isInternalUpdate.current = false
    }, 100)
  }

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
        }
        let savedOptions = savedViews->Array.map(view => {
          let name = view.view_name
          let opt: HeadlessUISelectBox.updatedOptionWithIcons = {
            label: SavedViewsUtils.truncateName(name),
            value: name,
            isDisabled: false,
            leftIcon: name === activeViewName ? CustomIcon(<Tick isSelected=true />) : NoIcon,
            customTextStyle: None,
            customIconStyle: None,
            rightIcon: CustomIcon(
              <div
                className="text-nd_gray-300 hover:text-red-500 cursor-pointer"
                onClick={ev => handleDelete(name, ev)}>
                <Icon name="trash-outline" size=20 />
              </div>,
            ),
            description: None,
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
      onViewsUpdated={(res, name) => {
        let mappedRes = res->HSwitchOrderUtils.savedViewsResponseMapper
        setSavedViews(_ => mappedRes.views)
        switch name {
        | Some(n) => setActiveViewName(_ => n)
        | None => ()
        }
      }}
    />
  </div>
}
