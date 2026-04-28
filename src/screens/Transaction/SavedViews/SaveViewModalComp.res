open APIUtils
open LogicUtils
open Typography
open SavedViewTypes

module IncludeDateCheckbox = {
  @react.component
  let make = (~includeDate, ~setIncludeDate, ~dateRangeText) => {
    <div className="flex flex-col gap-2">
      <div
        className="flex items-center gap-3 cursor-pointer"
        onClick={_ => setIncludeDate(prev => !prev)}>
        <CheckBoxIcon
          isSelected=includeDate
          setIsSelected={val => setIncludeDate(_ => val)}
          isCheckboxSelectedClass=true
          checkboxDimension="w-3.5 h-3.5"
          stopPropagationNeeded=true
        />
        <div className={`${body.md.medium} text-nd_gray-600`}>
          {(
            dateRangeText->isNonEmptyString
              ? `Include date range ${dateRangeText}`
              : "Include Date Range"
          )->React.string}
        </div>
      </div>
    </div>
  }
}

module CreateTab = {
  @react.component
  let make = (
    ~viewName,
    ~setViewName,
    ~viewNameExists,
    ~viewLimitReached,
    ~includeDate,
    ~setIncludeDate,
    ~dateRangeText,
    ~handleCreate,
    ~setShowModal,
  ) => {
    let trimmedViewName = viewName->String.trim
    <div className="flex flex-col gap-6">
      <div className={`flex flex-col gap-1`}>
        <div className={`${body.md.medium} text-nd_gray-400`}>
          {"View Name"->React.string}
          <span className="text-nd_red-400"> {"*"->React.string} </span>
        </div>
        <TextInput
          input={
            name: "viewName",
            onBlur: _ => (),
            onFocus: _ => (),
            onChange: ev => setViewName(_ => ReactEvent.Form.target(ev)["value"]),
            value: viewName->JSON.Encode.string,
            checked: false,
          }
          placeholder="Enter view name"
          customPaddingClass="px-4"
          customStyle={viewNameExists ? "border-nd_red-400 focus:border-nd_red-400" : ""}
        />
        <RenderIf condition=viewNameExists>
          <div className="text-nd_red-400 text-xs mt-1">
            {"This view already exists. Please choose a different name."->React.string}
          </div>
        </RenderIf>
        <RenderIf condition={viewLimitReached && !viewNameExists}>
          <div className="text-nd_red-400 text-xs mt-1">
            {`Maximum ${SavedViewsUtils.maxViews->Int.toString} views allowed. Please update or delete an existing view.`->React.string}
          </div>
        </RenderIf>
      </div>
      <IncludeDateCheckbox includeDate setIncludeDate dateRangeText />
      <div className="flex justify-end gap-3 mt-2">
        <Button text="Cancel" onClick={_ => setShowModal(_ => false)} buttonType=Secondary />
        <Button
          text="Save New View"
          onClick={_ => handleCreate()->ignore}
          buttonState={trimmedViewName->isEmptyString || viewNameExists || viewLimitReached
            ? Disabled
            : Normal}
          buttonType=Primary
        />
      </div>
    </div>
  }
}

module OverwriteTab = {
  @react.component
  let make = (
    ~savedViews: array<SavedViewTypes.savedView>,
    ~selectedViewToOverwrite,
    ~setSelectedViewToOverwrite,
    ~includeDate,
    ~setIncludeDate,
    ~dateRangeText,
    ~handleOverwrite,
    ~setShowModal,
  ) => {
    <div className="flex flex-col gap-6">
      <div className="flex flex-col gap-1">
        <div className={`${body.md.medium} text-nd_gray-400`}>
          {"Search View Name to Overwrite"->React.string}
          <span className="text-nd_red-400"> {"*"->React.string} </span>
        </div>
        <SelectBox.BaseDropdown
          allowMultiSelect=false
          hideMultiSelectButtons=true
          buttonText="Select View"
          options={savedViews->Array.map(view => {
            let opt: SelectBox.dropdownOption = {label: view.view_name, value: view.view_name}
            opt
          })}
          input={
            name: "selectedViewToOverwrite",
            onBlur: _ => (),
            onFocus: _ => (),
            onChange: ev => {
              let value = ev->Identity.formReactEventToString
              setSelectedViewToOverwrite(_ => value)
            },
            value: selectedViewToOverwrite->JSON.Encode.string,
            checked: false,
          }
          searchable=false
          fullLength=true
          dropdownCustomWidth="w-full"
          baseComponentMethod={_isOpen => {
            <div
              className={`flex items-center justify-between w-full h-10 px-4 border border-nd_gray-300 rounded bg-white cursor-pointer hover:border-nd_gray-400 overflow-hidden ${body.md.regular}`}>
              <span
                className={`truncate ${selectedViewToOverwrite->isEmptyString
                    ? "text-nd_gray-400"
                    : "text-nd_gray-800"}`}>
                {(
                  selectedViewToOverwrite->isEmptyString ? "Select View" : selectedViewToOverwrite
                )->React.string}
              </span>
              <Icon name="chevron-down" size=14 className="text-nd_gray-400 flex-shrink-0 ml-2" />
            </div>
          }}
        />
      </div>
      <IncludeDateCheckbox includeDate setIncludeDate dateRangeText />
      <div className="flex justify-end gap-3 mt-2">
        <Button text="Cancel" onClick={_ => setShowModal(_ => false)} buttonType=Secondary />
        <Button
          text="Overwrite Existing View"
          onClick={_ => handleOverwrite(selectedViewToOverwrite)->ignore}
          buttonState={selectedViewToOverwrite->isEmptyString ? Disabled : Normal}
          buttonType=Primary
        />
      </div>
    </div>
  }
}

@react.component
let make = (
  ~showModal,
  ~setShowModal,
  ~onViewsUpdated: (JSON.t, option<string>) => unit,
  ~version: UserInfoTypes.version=V1,
  ~entity: SavedViewTypes.entity,
) => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()
  let (viewName, setViewName) = React.useState(_ => "")
  let (selectedViewToOverwrite, setSelectedViewToOverwrite) = React.useState(_ => "")
  let (includeDate, setIncludeDate) = React.useState(_ => false)
  let (savedViews: array<SavedViewTypes.savedView>, setSavedViews) = React.useState(_ => [])
  let (viewCount, setViewCount) = React.useState(_ => 0)
  let fetchDetails = useGetMethod()

  let {filterValueJson} = React.useContext(FilterContext.filterContext)
  let {values: formValues} = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )

  let mergedFilters = React.useMemo(() => {
    let merged = DictionaryUtils.mergeDicts([filterValueJson, formValues->getDictFromJsonObject])

    let startTimeKey = OrderUIUtils.startTimeFilterKey(version)
    let endTimeKey = OrderUIUtils.endTimeFilterKey(version)
    let defaultDates = HSwitchRemoteFilter.getDateFilteredObject(~range=30)

    let start = merged->getString(startTimeKey, "")
    if start->isEmptyString || start->String.toLowerCase === "now" {
      merged->Dict.set(startTimeKey, defaultDates.start_time->JSON.Encode.string)
    }
    let end = merged->getString(endTimeKey, "")
    if end->isEmptyString || end->String.toLowerCase === "now" {
      merged->Dict.set(endTimeKey, defaultDates.end_time->JSON.Encode.string)
    }
    merged
  }, (filterValueJson, formValues, version))

  let dateRangeText = React.useMemo(() => {
    let start = mergedFilters->getString(OrderUIUtils.startTimeFilterKey(version), "")
    let end = mergedFilters->getString(OrderUIUtils.endTimeFilterKey(version), "")
    let format = isoStr =>
      if isoStr->isNonEmptyString {
        (isoStr->DayJs.getDayJsForString).format("MMM D, YYYY HH:mm")
      } else {
        ""
      }
    if start->isNonEmptyString && end->isNonEmptyString {
      `from ${format(start)} to ${format(end)}`
    } else {
      ""
    }
  }, (mergedFilters, version))

  let fetchSavedViews = async () => {
    try {
      let url = getURL(
        ~entityName=V1(USERS),
        ~userType=#USER_DATA,
        ~methodType=Get,
        ~queryParameters=Some(SavedViewsUtils.savedViewsQueryParam(entity)),
      )
      let res = await fetchDetails(url)
      let mappedRes = res->SavedViewsUtils.savedViewsResponseMapper(entity)
      setViewCount(_ => mappedRes.count)
      setSavedViews(_ => mappedRes.views)
    } catch {
    | err =>
      Js.log2("FAILED TO LOAD SAVED VIEWS", err)
      showToast(~message="Failed to load saved views. Please try again.", ~toastType=ToastError)
    }
  }

  React.useEffect(() => {
    if showModal {
      setViewName(_ => "")
      setSelectedViewToOverwrite(_ => "")
      fetchSavedViews()->ignore
    }
    None
  }, [showModal])

  let buildFilters = () => {
    let filtersDict = mergedFilters->Dict.copy
    // Pagination is per-session state, never part of a saved view.
    filtersDict->Dict.delete("limit")
    filtersDict->Dict.delete("offset")
    if !includeDate {
      filtersDict->Dict.delete(OrderUIUtils.startTimeFilterKey(version))
      filtersDict->Dict.delete(OrderUIUtils.endTimeFilterKey(version))
    }
    SavedViewsUtils.foldAmountOption(filtersDict)
    filtersDict->JSON.Encode.object
  }

  let handleCreate = async _ => {
    try {
      let filters = buildFilters()
      let payload = SavedViewsUtils.buildSavePayload(entity, Create, viewName, filters, None)
      let url = getURL(~entityName=V1(USERS), ~userType=#USER_DATA, ~methodType=Post)
      let res = await updateDetails(url, payload, Post)
      onViewsUpdated(res, Some(viewName))
      showToast(~message=`New View '${viewName}' created successfully!`, ~toastType=ToastSuccess)
      setShowModal(_ => false)
    } catch {
    | err =>
      Js.log2("FAILED TO CREATE SAVED VIEW", err)
      showToast(
        ~message=`Failed to create view '${viewName}'. Please try again.`,
        ~toastType=ToastError,
      )
    }
  }

  let handleOverwrite = async name => {
    try {
      let viewToOverwrite = name->isNonEmptyString ? name : selectedViewToOverwrite
      if viewToOverwrite->isNonEmptyString {
        let viewId =
          savedViews
          ->Array.find(view => view.view_name === viewToOverwrite)
          ->Option.map(v => v.view_id)
        let filters = buildFilters()
        let payload = SavedViewsUtils.buildSavePayload(
          entity,
          Update,
          viewToOverwrite,
          filters,
          viewId,
        )
        let url = getURL(~entityName=V1(USERS), ~userType=#USER_DATA, ~methodType=Post)
        let res = await updateDetails(url, payload, Post)
        onViewsUpdated(res, Some(viewToOverwrite))
        showToast(
          ~message=`'${viewToOverwrite}' has been overwritten successfully!`,
          ~toastType=ToastSuccess,
        )
        setShowModal(_ => false)
      }
    } catch {
    | err =>
      Js.log2("FAILED TO OVERWRITE SAVED VIEW", err)
      showToast(~message="Failed to overwrite view. Please try again.", ~toastType=ToastError)
    }
  }

  let trimmedViewName = viewName->String.trim
  let viewNameExists =
    trimmedViewName->isNonEmptyString &&
      savedViews->Array.some(view => view.view_name === trimmedViewName)
  let viewLimitReached = viewCount >= SavedViewsUtils.maxViews

  let tabs = [
    {
      title: "Create New View",
      render: () =>
        <CreateTab
          viewName
          setViewName
          viewNameExists
          viewLimitReached
          includeDate
          setIncludeDate
          dateRangeText
          handleCreate
          setShowModal
        />,
    },
    {
      title: "Overwrite Existing View",
      render: () =>
        <OverwriteTab
          savedViews
          selectedViewToOverwrite
          setSelectedViewToOverwrite
          includeDate
          setIncludeDate
          dateRangeText
          handleOverwrite
          setShowModal
        />,
    },
  ]
  let (selectedTabIndex, setSelectedTabIndex) = React.useState(_ => 0)

  <Modal
    showModal
    setShowModal
    modalHeading="Save View"
    modalClass="w-full max-w-lg h-fit"
    alignModal="items-center justify-center">
    <div className="flex flex-col gap-4">
      <div className="relative flex bg-nd_gray-50 p-1 rounded-lg mx-6 mt-4">
        <div
          className="absolute top-1 bottom-1 left-1 bg-white shadow-sm rounded-md transition-all duration-300 ease-in-out"
          style={ReactDOM.Style.make(
            ~width="calc(50% - 4px)",
            ~transform={`translateX(${selectedTabIndex === 0 ? "0%" : "100%"})`},
            (),
          )}
        />
        {tabs
        ->Array.mapWithIndex((tabItem, index) => {
          let isSelected = selectedTabIndex === index
          <div
            key={tabItem.title}
            onClick={_ => setSelectedTabIndex(_ => index)}
            className={`relative z-10 flex-1 py-2 text-center cursor-pointer transition-colors duration-200 ${body.md.medium} ${isSelected
                ? "text-nd_gray-700"
                : "text-nd_gray-400 hover:text-nd_gray-600"}`}>
            {tabItem.title->React.string}
          </div>
        })
        ->React.array}
      </div>
      <div
        key={selectedTabIndex->Int.toString}
        className="p-6 pt-2 pb-8 min-h-[160px] animate-fadeIn animate-slideUp">
        {switch tabs->Array.get(selectedTabIndex) {
        | Some(tabItem) => tabItem.render()
        | None => React.null
        }}
      </div>
    </div>
  </Modal>
}
