module ClearFilters = {
  @react.component
  let make = (
    ~defaultFilterKeys=[],
    ~clearFilters=?,
    ~isCountRequired=true,
    ~outsidefilter=false,
  ) => {
    let {updateExistingKeys} = React.useContext(FilterContext.filterContext)
    let textStyle = "text-red-900"
    let leftIcon: Button.iconType = CustomIcon(<Icon name="trash-outline" size=24 />)

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
        | String(str) => str->LogicUtils.isEmptyString
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

module AutoSubmitter = {
  @react.component
  let make = (~autoApply, ~submit, ~defaultFilterKeys, ~submitInputOnEnter) => {
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values", "dirtyFields"])->Nullable.make,
    )
    let form = ReactFinalForm.useForm()
    let values = formState.values
    React.useEffect(() => {
      let onKeyDown = ev => {
        let keyCode = ev->ReactEvent.Keyboard.keyCode
        if keyCode === 13 && submitInputOnEnter {
          form.submit()->ignore
        }
      }
      Window.addEventListener("keydown", onKeyDown)
      Some(() => Window.removeEventListener("keydown", onKeyDown))
    }, [])

    React.useEffect(() => {
      if formState.dirty {
        let defaultFieldsHaveChanged = defaultFilterKeys->Array.some(key => {
          formState.dirtyFields->Dict.get(key)->Option.getOr(false)
        })

        // if autoApply is false then still autoApply can work for the default filters
        if autoApply || defaultFieldsHaveChanged {
          submit(formState.values, 0)->ignore
        }
      }

      None
    }, [values])

    React.null
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
  ~updateUrlWith=?,
  ~clearFilters=?,
  ~showClearFilter=true,
  ~initalCount=0,
  ~showSelectFiltersSearch=false,
) => {
  open HeadlessUI
  open LogicUtils

  let isSmallScreen = MatchMedia.useScreenSizeChecker(~screenSize="1512")
  let {query, filterKeys, setfilterKeys} = React.useContext(FilterContext.filterContext)
  let (allFilters, setAllFilters) = React.useState(_ =>
    remoteFilters->Array.map(item => item.field)
  )
  let (initialValueJson, setInitialValueJson) = React.useState(_ => JSON.Encode.object(Dict.make()))
  let (filterList, setFilterList) = React.useState(_ => [])
  let (count, setCount) = React.useState(_ => initalCount)
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
    | Some(_) => {
        let selectedFilters = []
        let filtersUnseletced = []

        filterKeys->Array.forEach(key => {
          let item = remoteFilters->Array.find(
            item => {
              item.field.inputNames->Array.get(0)->Option.getOr("") === key
            },
          )

          switch item {
          | Some(val) => selectedFilters->Array.push(val.field)->ignore
          | _ => ()
          }
        })

        remoteFilters->Array.forEach(item => {
          if !(selectedFilters->Array.includes(item.field)) {
            filtersUnseletced->Array.push(item.field)->ignore
          }
        })

        setFilterList(_ => selectedFilters)
        setCount(_prev => clearFilterJson + initalCount)
        setAllFilters(_prev => filtersUnseletced)
        let finalInitialValueJson =
          initialValues->JsonFlattenUtils.unflattenObject->JSON.Encode.object
        setInitialValueJson(_ => finalInitialValueJson)
      }

    | None => ()
    }
    None
  }, (searchParams, filterKeys))

  let onSubmit = (values, _) => {
    let obj = values->JSON.Decode.object->Option.getOr(Dict.make())->Dict.toArray->Dict.fromArray

    let flattendDict = obj->JSON.Encode.object->JsonFlattenUtils.flattenObject(false)
    let localFilterDict = localFilterJson->JsonFlattenUtils.flattenObject(false)
    switch updateUrlWith {
    | Some(updateUrlWith) =>
      RemoteFiltersUtils.applyFilters(
        ~currentFilterDict=flattendDict,
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
        ~currentFilterDict=flattendDict,
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

  let allFiltersUI =
    <Menu \"as"="div" className="relative inline-block text-left">
      {_ =>
        <div>
          <Menu.Button
            className="flex items-center whitespace-pre leading-5 justify-center text-sm  px-4 py-2 font-medium rounded-lg h-10 hover:bg-opacity-80 bg-white border">
            {_ => {
              <>
                <Icon className={"mr-2"} name="plus" size=15 />
                {"Add Filters"->React.string}
              </>
            }}
          </Menu.Button>
          <Transition
            \"as"="span"
            enter="transition ease-out duration-100"
            enterFrom="transform opacity-0 scale-95"
            enterTo="transform opacity-100 scale-100"
            leave="transition ease-in duration-75"
            leaveFrom="transform opacity-100 scale-100"
            leaveTo="transform opacity-0 scale-95">
            <Menu.Items
              className="absolute left-0 w-fit z-50 mt-2 origin-top-right bg-white dark:bg-jp-gray-950 divide-y divide-gray-100 rounded-md shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none">
              {_ => {
                <>
                  <div className="px-1 py-1 overflow-y-auto max-h-96">
                    {allFilters
                    ->Array.mapWithIndex((option, i) =>
                      <Menu.Item key={i->Int.toString}>
                        {props =>
                          <div className="relative w-max">
                            <button
                              onClick={_ => addFilter(option)}
                              className={
                                let activeClasses = props["active"]
                                  ? "bg-gray-100 dark:bg-black"
                                  : ""
                                `group flex rounded-md items-center w-48 px-2 py-2 text-sm font-medium ${activeClasses}`
                              }>
                              <RenderIf condition={option.label->isNonEmptyString}>
                                <div className="mr-5 text-left">
                                  {option.label->snakeToTitle->React.string}
                                </div>
                              </RenderIf>
                              <RenderIf condition={option.label->isEmptyString}>
                                <div className="mr-5 text-left">
                                  {option.inputNames
                                  ->getValueFromArray(0, "")
                                  ->snakeToTitle
                                  ->React.string}
                                </div>
                              </RenderIf>
                            </button>
                          </div>}
                      </Menu.Item>
                    )
                    ->React.array}
                  </div>
                </>
              }}
            </Menu.Items>
          </Transition>
        </div>}
    </Menu>

  <Form onSubmit initialValues=initialValueJson>
    <AutoSubmitter autoApply submit=onSubmit defaultFilterKeys submitInputOnEnter />
    {<AddDataAttributes attributes=[("data-filter", "remoteFilters")]>
      {<>
        <div className="mb-4"> {customLeftView} </div>
        <div className="flex lg:flex-row flex-col justify-between items-center gap-4 mb-2">
          <div className="flex gap-2 flex-wrap items-center">
            <RenderIf condition={allFilters->Array.length > 0}> {allFiltersUI} </RenderIf>
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
            <ClearFilters defaultFilterKeys ?clearFilters outsidefilter={initalCount > 0} />
          </RenderIf>
        </div>
      </>}
    </AddDataAttributes>}
  </Form>
}
