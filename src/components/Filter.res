open Typography
open LogicUtils
module ClearFilters = {
  @react.component
  let make = (
    ~defaultFilterKeys=[],
    ~clearFilters=?,
    ~isCountRequired=true,
    ~outsidefilter=false,
  ) => {
    let {updateExistingKeys} = React.useContext(FilterContext.filterContext)
    let textStyle = "text-nd_red-500"
    let leftIcon: Button.iconType = CustomIcon(
      <Icon name="trash-outline" size=24 className="text-nd_red-500" />,
    )

    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values", "initialValues"])->Nullable.make,
    )

    let handleClearFilter = switch clearFilters {
    | Some(fn) =>
      _ => {
        fn()

        // fn()
      }
    | None =>
      _ => {
        let searchStr =
          formState.values
          ->JSON.Decode.object
          ->Option.getOr(Dict.make())
          ->Dict.toArray
          ->Belt.Array.keepMap(entry => {
            let (key, value) = entry
            switch defaultFilterKeys->Array.includes(key) {
            | true =>
              switch value->JSON.Classify.classify {
              | String(str) => `${key}=${str}`->Some
              | Number(num) => `${key}=${num->String.make}`->Some
              | Array(arr) => `${key}=[${arr->String.make}]`->Some
              | _ => None
              }
            | false => None
            }
          })
          ->Array.joinWith("&")

        searchStr->FilterUtils.parseFilterString->updateExistingKeys
      }
    }

    let hasExtraFilters = React.useMemo(() => {
      formState.initialValues
      ->JSON.Decode.object
      ->Option.getOr(Dict.make())
      ->Dict.toArray
      ->Array.filter(entry => {
        let (_, value) = entry
        let isEmptyValue = switch value->JSON.Classify.classify {
        | String(str) => str->isEmptyString
        | Array(arr) => arr->Array.length === 0
        | Null => true
        | _ => false
        }
        !isEmptyValue
      })
      ->Array.length > 0
    }, (formState.initialValues, defaultFilterKeys))
    let text = "Clear All"
    <RenderIf condition={hasExtraFilters || outsidefilter}>
      <Button
        text
        customButtonStyle="!h-10"
        showBorder=true
        textStyle
        leftIcon
        onClick=handleClearFilter
        buttonType={Secondary}
        customIconMargin="-mr-1"
      />
    </RenderIf>
  }
}

let getStrFromJson = (key, val) => {
  switch val->JSON.Classify.classify {
  | String(str) => str
  | Array(array) => array->Array.length > 0 ? `[${array->Array.joinWithUnsafe(",")}]` : ""
  | Number(num) => key === "offset" ? "0" : num->Float.toInt->Int.toString
  | _ => ""
  }
}

@react.component
let make = (
  ~defaultFilters,
  ~fixedFilters: array<EntityType.initialFilters<'t>>=[],
  ~requiredSearchFieldsList as _,
  ~setOffset=?,
  ~title="",
  ~path="",
  ~remoteFilters: array<EntityType.initialFilters<'t>>,
  ~remoteOptions: array<EntityType.optionType<'t>>,
  ~localOptions as _,
  ~localFilters: array<EntityType.initialFilters<'t>>,
  ~mandatoryRemoteKeys=[],
  ~popupFilterFields: array<EntityType.optionType<'t>>=[],
  ~tableName=?,
  ~autoApply=false,
  ~submitInputOnEnter=false,
  ~addFilterStyle="",
  ~filterButtonStyle="",
  ~defaultFilterKeys=[],
  ~customRightView=React.null,
  ~customLeftView=React.null,
  ~customFilterActions=React.null,
  ~updateUrlWith=?,
  ~clearFilters=?,
  ~showClearFilter=true,
  ~initialCount=0,
  ~showSelectFiltersSearch=false,
) => {
  let isSmallScreen = MatchMedia.useScreenSizeChecker(~screenSize="1512")
  let {query, filterKeys, setfilterKeys} = React.useContext(FilterContext.filterContext)
  let (allFilters, setAllFilters) = React.useState(_ =>
    remoteFilters->Array.map(item => item.field)
  )
  let (initialValueJson, setInitialValueJson) = React.useState(_ => JSON.Encode.object(Dict.make()))
  let (filterList, setFilterList) = React.useState(_ => [])
  let (count, setCount) = React.useState(_ => initialCount)
  let searchParams = query->decodeURI

  let localFilterJson = RemoteFiltersUtils.getInitialValuesFromUrl(
    ~searchParams,
    ~initialFilters={Array.concat(localFilters, fixedFilters)},
    (),
  )

  let clearFilterJson =
    RemoteFiltersUtils.getInitialValuesFromUrl(
      ~searchParams,
      ~initialFilters={localFilters},
      ~options=remoteOptions,
      (),
    )
    ->getDictFromJsonObject
    ->Dict.keysToArray
    ->Array.length

  React.useEffect(() => {
    let initialValues = RemoteFiltersUtils.getInitialValuesFromUrl(
      ~searchParams,
      ~initialFilters={Array.concat(remoteFilters, fixedFilters)},
      ~mandatoryRemoteKeys,
      ~options=remoteOptions,
      (),
    )
    switch updateUrlWith {
    | Some(fn) =>
      fn(
        initialValues
        ->getDictFromJsonObject
        ->Dict.toArray
        ->Array.map(item => {
          let (key, value) = item
          (key, getStrFromJson(key, value))
        })
        ->Dict.fromArray,
      )
    | None => ()
    }

    switch initialValues->JSON.Decode.object {
    | Some(_) =>
      let finalInitialValueJson =
        initialValues->JsonFlattenUtils.unflattenObject->JSON.Encode.object
      setInitialValueJson(_ => finalInitialValueJson)
    | None => ()
    }
    None
  }, (searchParams, remoteFilters->Array.length, remoteOptions->Array.length))

  React.useEffect(() => {
    let selectedFilters = filterKeys->Array.filterMap(key => {
      remoteFilters
      ->Array.find(item => item.field.inputNames->getValueFromArray(0, "") === key)
      ->Option.map(val => val.field)
    })

    let filtersUnselected = remoteFilters->Array.filterMap(item => {
      !(selectedFilters->Array.includes(item.field)) ? Some(item.field) : None
    })

    setFilterList(_ => selectedFilters)
    setCount(_prev => clearFilterJson + initialCount)
    setAllFilters(_prev => filtersUnselected)
    None
  }, (filterKeys, remoteFilters->Array.length, searchParams))

  let onSubmit = (values, _) => {
    let obj = values->JSON.Decode.object->Option.getOr(Dict.make())->Dict.toArray->Dict.fromArray

    let flattenedDict = obj->JSON.Encode.object->JsonFlattenUtils.flattenObject(false)
    let localFilterDict = localFilterJson->JsonFlattenUtils.flattenObject(false)
    switch updateUrlWith {
    | Some(updateUrlWith) =>
      RemoteFiltersUtils.applyFilters(
        ~currentFilterDict=flattenedDict,
        ~options=remoteOptions,
        ~defaultFilters,
        ~setOffset,
        ~path,
        ~existingFilterDict=localFilterDict,
        ~tableName,
        ~updateUrlWith,
        (),
      )
    | None =>
      RemoteFiltersUtils.applyFilters(
        ~currentFilterDict=flattenedDict,
        ~options=remoteOptions,
        ~defaultFilters,
        ~setOffset,
        ~path,
        ~existingFilterDict=localFilterDict,
        ~tableName,
        (),
      )
    }

    open Promise

    Nullable.null->resolve
  }

  let addFilter = option => {
    let updatedFilters = filterList->Array.concat([option])

    let keys = []
    updatedFilters->Array.forEach(item =>
      switch item.inputNames->Array.get(0) {
      | Some(val) => keys->Array.push(val)->ignore
      | _ => ()
      }
    )
    setfilterKeys(_ => keys)
  }

  let filterOptions: array<SelectBox.dropdownOption> = allFilters->Array.map(option => {
    let label = if option.label->isNonEmptyString {
      option.label->snakeToTitle
    } else {
      option.inputNames->getValueFromArray(0, "")->snakeToTitle
    }
    let value = option.inputNames->getValueFromArray(0, "")
    switch option.labelRightComponent {
    | Some(labelRightComponent) => {
        SelectBox.label,
        value,
        icon: Button.CustomRightIcon(<div className="ml-2"> {labelRightComponent} </div>),
      }
    | None => {SelectBox.label, value}
    }
  })

  let filterPickerInput: ReactFinalForm.fieldRenderPropsInput = {
    name: "addFilter",
    value: JSON.Encode.string(""),
    onBlur: _ => (),
    onFocus: _ => (),
    checked: false,
    onChange: ev => {
      let value = ev->Identity.formReactEventToString
      let matchedOption =
        allFilters->Array.find(opt => opt.inputNames->getValueFromArray(0, "") === value)
      switch matchedOption {
      | Some(opt) => addFilter(opt)
      | None => ()
      }
    },
  }

  let addFilterTrigger =
    <button
      type_="button"
      className={`flex items-center gap-2 ${body.md.medium} text-nd_gray-700 border border-nd_gray-200 rounded-10-px px-3.5 h-9 bg-white`}>
      <Icon name="plus" size=15 />
      {"Add Filters"->React.string}
    </button>

  let allFiltersUI =
    <SelectBoxAdapter.BaseDropdown
      buttonText="Add Filters"
      allowMultiSelect=false
      input=filterPickerInput
      options=filterOptions
      hideMultiSelectButtons=false
      baseComponent=addFilterTrigger
      minMenuWidth=200
    />

  <Form onSubmit initialValues=initialValueJson>
    <HelperComponents.AutoSubmitter
      autoApply submit=onSubmit defaultFilterKeys submitInputOnEnter
    />
    {<AddDataAttributes attributes=[("data-filter", "remoteFilters")]>
      {<>
        <div className="mb-4"> {customLeftView} </div>
        <div className="flex lg:flex-row flex-col justify-between items-center gap-4 mb-2">
          <div className="flex gap-2 flex-wrap items-center">
            <RenderIf condition={allFilters->Array.length > 0}> {allFiltersUI} </RenderIf>
            {customFilterActions}
            <RenderIf condition={isSmallScreen}>
              <PortalCapture key={`${title}OMPView`} name={`${title}OMPView`} />
            </RenderIf>
          </div>
          <div className="flex gap-2 items-center">
            <RenderIf condition={fixedFilters->Array.length > 0}>
              <FormRenderer.FieldsRenderer
                fields={fixedFilters->Array.map(item => item.field)}
                labelClass="hidden"
                fieldWrapperClass="p-0"
              />
            </RenderIf>
            <RenderIf condition={!isSmallScreen}>
              <PortalCapture key={`${title}OMPView`} name={`${title}OMPView`} />
            </RenderIf>
            <PortalCapture key={`${title}CustomizeColumn`} name={`${title}CustomizeColumn`} />
          </div>
        </div>
        <div className="flex gap-2 flex-wrap items-center">
          <FormRenderer.FieldsRenderer
            fields={filterList} labelClass="hidden" fieldWrapperClass="p-0"
          />
          <RenderIf condition={count > 0}>
            <ClearFilters defaultFilterKeys ?clearFilters outsidefilter={initialCount > 0} />
          </RenderIf>
        </div>
      </>}
    </AddDataAttributes>}
  </Form>
}
