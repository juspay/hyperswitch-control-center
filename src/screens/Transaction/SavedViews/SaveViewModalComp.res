open APIUtils
open LogicUtils
open Typography

@react.component
let make = (
  ~showModal,
  ~setShowModal,
  ~onViewsUpdated: (JSON.t, option<string>) => unit,
  ~version: UserInfoTypes.version=V1,
  ~entity: string,
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
    let merged = Dict.make()
    filterValueJson
    ->Dict.toArray
    ->Array.forEach(((key, value)) => {
      merged->Dict.set(key, value)
    })
    formValues
    ->getDictFromJsonObject
    ->Dict.toArray
    ->Array.forEach(((key, value)) => {
      merged->Dict.set(key, value)
    })

    let startTimeKey = OrderUIUtils.startTimeFilterKey(version)
    let endTimeKey = OrderUIUtils.endTimeFilterKey(version)

    let start = merged->getString(startTimeKey, "")
    let end = merged->getString(endTimeKey, "")

    let defaultDates = HSwitchRemoteFilter.getDateFilteredObject(~range=30)

    if start->isEmptyString || start->String.toLowerCase === "now" {
      merged->Dict.set(startTimeKey, defaultDates.start_time->JSON.Encode.string)
    }
    if end->isEmptyString || end->String.toLowerCase === "now" {
      merged->Dict.set(endTimeKey, defaultDates.end_time->JSON.Encode.string)
    }

    merged
  }, (filterValueJson, formValues, version))

  let dateRangeText = React.useMemo(() => {
    let start = mergedFilters->getString(OrderUIUtils.startTimeFilterKey(version), "")
    let end = mergedFilters->getString(OrderUIUtils.endTimeFilterKey(version), "")

    let format = isoStr => {
      if isoStr->isNonEmptyString {
        let dayjs: DayJs.dayJs = isoStr->DayJs.getDayJsForString
        dayjs.format("MMM D, YYYY HH:mm")
      } else {
        ""
      }
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
        ~entityName=V1(SAVED_VIEWS),
        ~methodType=Get,
        ~queryParameters=Some(`entity=${entity}`),
      )
      let res = await fetchDetails(url)
      let mappedRes = res->HSwitchOrderUtils.savedViewsResponseMapper
      setViewCount(_ => mappedRes.count)
      setSavedViews(_ => mappedRes.views)
    } catch {
    | _ => ()
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

  let getPayload = name => {
    let filtersDict = mergedFilters->Dict.copy
    if !includeDate {
      filtersDict->Dict.delete(OrderUIUtils.startTimeFilterKey(version))
      filtersDict->Dict.delete(OrderUIUtils.endTimeFilterKey(version))
    }
    let getStrFromDict = (dict, key) => {
      let val = dict->Dict.get(key)
      switch val {
      | Some(json) =>
        switch json->JSON.Classify.classify {
        | String(s) => s
        | Array(arr) =>
          switch arr->Array.get(0) {
          | Some(ele) =>
            switch ele->JSON.Classify.classify {
            | String(s) => s
            | Number(n) => n->Float.toString
            | _ => ""
            }
          | None => ""
          }
        | Number(n) => n->Float.toString
        | _ => ""
        }
      | None => ""
      }
    }

    let amountOption = getStrFromDict(filtersDict, "amount_option")
    let startAmountStr = getStrFromDict(filtersDict, "start_amount")
    let endAmountStr = getStrFromDict(filtersDict, "end_amount")

    if amountOption->LogicUtils.isNonEmptyString {
      filtersDict->Dict.delete("amount_option")
      filtersDict->Dict.delete("start_amount")
      filtersDict->Dict.delete("end_amount")

      let amountFilterDict = Dict.make()

      let getAmountNum = str => {
        let parsed = Float.fromString(str)
        switch parsed {
        | Some(num) => Some(num)
        | None => None
        }
      }

      let startAmount = getAmountNum(startAmountStr)
      let endAmount = getAmountNum(endAmountStr)

      if amountOption === "GreaterThanOrEqualTo" {
        switch startAmount {
        | Some(num) => amountFilterDict->Dict.set("start_amount", num->JSON.Encode.float)
        | None => ()
        }
      } else if amountOption === "LessThanOrEqualTo" {
        switch endAmount {
        | Some(num) => amountFilterDict->Dict.set("end_amount", num->JSON.Encode.float)
        | None => ()
        }
      } else if amountOption === "EqualTo" {
        switch startAmount {
        | Some(num) => {
            amountFilterDict->Dict.set("start_amount", num->JSON.Encode.float)
            amountFilterDict->Dict.set("end_amount", num->JSON.Encode.float)
          }
        | None => ()
        }
      } else if amountOption === "Between" {
        switch startAmount {
        | Some(num) => amountFilterDict->Dict.set("start_amount", num->JSON.Encode.float)
        | None => ()
        }
        switch endAmount {
        | Some(num) => amountFilterDict->Dict.set("end_amount", num->JSON.Encode.float)
        | None => ()
        }
      }

      if amountFilterDict->Dict.keysToArray->Array.length > 0 {
        filtersDict->Dict.set("amount_filter", amountFilterDict->JSON.Encode.object)
      }
    }

    [
      ("view_name", name->JSON.Encode.string),
      ("filters", filtersDict->JSON.Encode.object),
      ("entity", entity->JSON.Encode.string),
    ]
    ->Dict.fromArray
    ->JSON.Encode.object
  }

  let handleCreate = async _ => {
    try {
      let url = getURL(~entityName=V1(SAVED_VIEWS), ~methodType=Post)
      let payload = getPayload(viewName)
      let res = await updateDetails(url, payload, Post)
      onViewsUpdated(res, Some(viewName))
      showToast(
        ~message=`New View '${SavedViewsUtils.truncateName(viewName)}' created successfully!`,
        ~toastType=ToastSuccess,
        ~toastElement={
          <div
            className="border-l-green-status rounded-lg shadow-sm bg-white border border-l-4 p-4 flex items-center">
            <Icon name="nd-toast-success" size=20 className="text-green-status mr-3" />
            <div className={`${body.md.medium} text-gray-800 flex items-center gap-1`}>
              {"New View '"->React.string}
              <HelperComponents.EllipsisText
                displayValue=viewName endValue=15 showCopy=false expandText=false
              />
              {"' created successfully!"->React.string}
            </div>
          </div>
        },
      )
      setShowModal(_ => false)
    } catch {
    | _ =>
      showToast(
        ~message=`Failed to create view '${SavedViewsUtils.truncateName(
            viewName,
          )}'. Please try again.`,
        ~toastType=ToastError,
        ~toastElement={
          <div
            className="border-l-red-900 rounded-lg shadow-sm bg-white border border-l-4 p-4 flex items-center">
            <Icon name="nd-toast-error" size=20 className="text-red-900 mr-3" />
            <div className={`${body.md.medium} text-gray-800 flex items-center gap-1 text-wrap`}>
              {"Failed to create view '"->React.string}
              <HelperComponents.EllipsisText
                displayValue=viewName endValue=15 showCopy=false expandText=false
              />
              {"'. Please try again."->React.string}
            </div>
          </div>
        },
      )
    }
  }

  let handleOverwrite = async name => {
    try {
      let viewToOverwrite = name->LogicUtils.isNonEmptyString ? name : selectedViewToOverwrite
      if viewToOverwrite->LogicUtils.isNonEmptyString {
        let url = getURL(~entityName=V1(SAVED_VIEWS), ~methodType=Put)
        let payload = getPayload(viewToOverwrite)
        let res = await updateDetails(url, payload, Put)
        onViewsUpdated(res, Some(viewToOverwrite))
        showToast(
          ~message=`'${SavedViewsUtils.truncateName(
              viewToOverwrite,
            )}' has been overwritten successfully!`,
          ~toastType=ToastSuccess,
          ~toastElement={
            <div
              className="border-l-green-status rounded-lg shadow-sm bg-white border border-l-4 p-4 flex items-center">
              <Icon name="nd-toast-success" size=20 className="text-green-status mr-3" />
              <div className={`${body.md.medium} text-gray-800 flex items-center gap-1`}>
                {"'"->React.string}
                <HelperComponents.EllipsisText
                  displayValue=viewToOverwrite endValue=15 showCopy=false expandText=false
                />
                {"' has been overwritten successfully!"->React.string}
              </div>
            </div>
          },
        )
        setShowModal(_ => false)
      }
    } catch {
    | _ => showToast(~message=`Failed to overwrite view. Please try again.`, ~toastType=ToastError)
    }
  }

  let trimmedViewName = viewName->String.trim

  let viewNameExists =
    trimmedViewName->isNonEmptyString &&
      savedViews->Array.some(view =>
        view.view_name->String.toLowerCase === trimmedViewName->String.toLowerCase
      )

  let viewLimitReached = viewCount >= 5

  let tabs: array<Tabs.tab> = [
    {
      title: "Create New View",
      renderContent: () => {
        <div className="flex flex-col gap-6">
          <div className={`flex flex-col gap-1`}>
            <div className={`${body.md.medium} text-nd_gray-400`}>
              {"View Name"->React.string}
              <span className="text-red-500"> {"*"->React.string} </span>
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
              customStyle={viewNameExists ? "border-red-500 focus:border-red-500" : ""}
            />
            <RenderIf condition=viewNameExists>
              <div className="text-red-500 text-xs mt-1">
                {"This view already exists. Please choose a different name."->React.string}
              </div>
            </RenderIf>
            <RenderIf condition={viewLimitReached && !viewNameExists}>
              <div className="text-red-500 text-xs mt-1">
                {"Maximum 5 views allowed. Please update or delete an existing view."->React.string}
              </div>
            </RenderIf>
          </div>
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
                  dateRangeText->LogicUtils.isNonEmptyString
                    ? `Include date range ${dateRangeText}`
                    : "Include Date Range"
                )->React.string}
              </div>
            </div>
          </div>
          <div className="flex justify-end gap-3 mt-2">
            <Button text="Cancel" onClick={_ => setShowModal(_ => false)} buttonType=Secondary />
            <Button
              text="Save New View"
              onClick={_ => {
                let _ = handleCreate()
              }}
              buttonState={trimmedViewName->isEmptyString || viewNameExists || viewLimitReached
                ? Disabled
                : Normal}
              buttonType=Primary
            />
          </div>
        </div>
      },
    },
    {
      title: "Overwrite Existing View",
      renderContent: () => {
        <div className="flex flex-col gap-6">
          <div className="flex flex-col gap-1">
            <div className={`${body.md.medium} text-nd_gray-400`}>
              {"Search View Name to Overwrite"->React.string}
              <span className="text-red-500"> {"*"->React.string} </span>
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
                  className={`flex items-center justify-between w-full h-10 px-4 border border-jp-gray-lightmode_steelgray border-opacity-75 rounded bg-white cursor-pointer hover:border-opacity-100 overflow-hidden ${body.md.regular}`}>
                  <span
                    className={`truncate ${selectedViewToOverwrite->isEmptyString
                        ? "text-nd_gray-400"
                        : "text-nd_gray-800"}`}>
                    {(
                      selectedViewToOverwrite->isEmptyString
                        ? "Select View"
                        : selectedViewToOverwrite
                    )->React.string}
                  </span>
                  <Icon
                    name="chevron-down" size=14 className="text-nd_gray-400 flex-shrink-0 ml-2"
                  />
                </div>
              }}
            />
          </div>
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
                  dateRangeText->LogicUtils.isNonEmptyString
                    ? `Include date range ${dateRangeText}`
                    : "Include Date Range"
                )->React.string}
              </div>
            </div>
          </div>
          <div className="flex justify-end gap-3 mt-2">
            <Button text="Cancel" onClick={_ => setShowModal(_ => false)} buttonType=Secondary />
            <Button
              text="Overwrite Existing View"
              onClick={_ => {
                let _ = handleOverwrite(selectedViewToOverwrite)
              }}
              buttonState={selectedViewToOverwrite->isEmptyString ? Disabled : Normal}
              buttonType=Primary
            />
          </div>
        </div>
      },
    },
  ]

  let (selectedTabIndex, setSelectedTabIndex) = React.useState(_ => 0)

  let tabsList = ["Create New View", "Overwrite Existing View"]

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
        {tabsList
        ->Array.mapWithIndex((tabTitle, index) => {
          let isSelected = selectedTabIndex === index
          <div
            key={tabTitle}
            onClick={_ => setSelectedTabIndex(_ => index)}
            className={`relative z-10 flex-1 py-2 text-center cursor-pointer transition-colors duration-200 ${body.md.medium} ${isSelected
                ? "text-nd_gray-700"
                : "text-nd_gray-400 hover:text-nd_gray-600"}`}>
            {tabTitle->React.string}
          </div>
        })
        ->React.array}
      </div>
      <div
        key={selectedTabIndex->Int.toString}
        className="p-6 pt-2 pb-8 min-h-[160px] animate-fadeIn animate-slideUp">
        {switch tabs->Array.get(selectedTabIndex) {
        | Some(tab) => tab.renderContent()
        | None => React.null
        }}
      </div>
    </div>
  </Modal>
}
