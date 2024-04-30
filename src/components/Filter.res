let makeFieldInfo = FormRenderer.makeFieldInfo

module ClearFilters = {
  @react.component
  let make = (
    ~filterButtonStyle,
    ~defaultFilterKeys=[],
    ~clearFilters=?,
    ~count,
    ~isCountRequired=true,
    ~outsidefilter=false,
  ) => {
    let {updateExistingKeys} = React.useContext(FilterContext.filterContext)
    let isMobileView = MatchMedia.useMobileChecker()
    let outerClass = if isMobileView {
      "flex items-center justify-end"
    } else {
      "mt-1 ml-10"
    }
    let textStyle = ""
    let leftIcon: Button.iconType = CustomIcon(<Icon name="clear_filter_img" size=14 />)

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

    let hasExtraFilters = React.useMemo2(() => {
      formState.initialValues
      ->JSON.Decode.object
      ->Option.getOr(Dict.make())
      ->Dict.toArray
      ->Array.filter(entry => {
        let (key, value) = entry
        let isEmptyValue = switch value->JSON.Classify.classify {
        | String(str) => str->LogicUtils.isEmptyString
        | Array(arr) => arr->Array.length === 0
        | Null => true
        | _ => false
        }

        !(defaultFilterKeys->Array.includes(key)) && !isEmptyValue
      })
      ->Array.length > 0
    }, (formState.initialValues, defaultFilterKeys))
    let text = isCountRequired ? `Clear ${count->Int.toString} Filters` : "Clear Filters"
    <UIUtils.RenderIf condition={hasExtraFilters || outsidefilter}>
      <div className={`${filterButtonStyle} ${outerClass}`}>
        <Button
          text showBorder=false textStyle leftIcon onClick=handleClearFilter buttonType=NonFilled
        />
      </div>
    </UIUtils.RenderIf>
  }
}

module AutoSubmitter = {
  @react.component
  let make = (~autoApply, ~submit, ~defaultFilterKeys) => {
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values", "dirtyFields"])->Nullable.make,
    )

    let values = formState.values

    React.useEffect1(() => {
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

module ApplyFilterButton = {
  @react.component
  let make = (
    ~autoApply,
    ~totalFilters,
    ~hideFilters,
    ~filterButtonStyle,
    ~defaultFilterKeys,
    ~selectedFiltersList: array<FormRenderer.fieldInfoType>,
  ) => {
    let defaultinputField = FormRenderer.makeInputFieldInfo(~name="-", ())
    let inputFieldsDict =
      selectedFiltersList
      ->Array.map(filter => {
        let inputFieldsArr = filter.inputFields
        let inputField = inputFieldsArr->LogicUtils.getValueFromArray(0, defaultinputField)
        (inputField.name, inputField)
      })
      ->Dict.fromArray

    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values", "dirtyFields", "initialValues"])->Nullable.make,
    )

    let formCurrentValues =
      formState.values
      ->LogicUtils.getDictFromJsonObject
      ->DictionaryUtils.deleteKeys(defaultFilterKeys)
    let formInitalValues =
      formState.initialValues
      ->LogicUtils.getDictFromJsonObject
      ->DictionaryUtils.deleteKeys(defaultFilterKeys)
    let dirtyFields = formState.dirtyFields->Dict.keysToArray

    let getFormattedDict = dict => {
      dict
      ->Dict.toArray
      ->Array.map(entry => {
        let (key, value) = entry
        let inputField = inputFieldsDict->Dict.get(key)->Option.getOr(defaultinputField)
        let formattor = inputField.format
        let value = switch formattor {
        | Some(fn) => fn(. ~value, ~name=key)
        | None => value
        }
        (key, value)
      })
      ->Dict.fromArray
    }

    let showApplyFilter = {
      let formattedInitialValues = formInitalValues->getFormattedDict
      let formattedCurrentValues = formCurrentValues->getFormattedDict

      let equalDictCheck = DictionaryUtils.checkEqualJsonDicts(
        formattedInitialValues,
        formattedCurrentValues,
        ~checkKeys=dirtyFields,
        ~ignoreKeys=["opt"],
      )

      let otherCheck =
        formattedCurrentValues
        ->Dict.toArray
        ->Array.reduce(true, (acc, item) => {
          let (_, value) = item
          switch value->JSON.Classify.classify {
          | String(str) => str->LogicUtils.isEmptyString
          | Array(arr) => arr->Array.length === 0
          | Object(dict) => dict->Dict.toArray->Array.length === 0
          | Null => true
          | _ => false
          } &&
          acc
        })
      !equalDictCheck && !otherCheck
    }

    // if all values are empty then don't show the apply filters let it be the clear filters visible

    if autoApply || totalFilters === 0 {
      React.null
    } else if !hideFilters && showApplyFilter {
      <div className={`flex justify-between items-center ${filterButtonStyle}`}>
        <FormRenderer.SubmitButton text="Apply Filters" icon={Button.FontAwesome("check")} />
      </div>
    } else {
      React.null
    }
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
  ~refreshFilters=true,
  ~remoteFilters: array<EntityType.initialFilters<'t>>,
  ~remoteOptions: array<EntityType.optionType<'t>>,
  ~localOptions as _: array<EntityType.optionType<'t>>,
  ~localFilters: array<EntityType.initialFilters<'t>>,
  ~mandatoryRemoteKeys=[],
  ~popupFilterFields: array<EntityType.optionType<'t>>=[],
  ~showRemoteOptions=false,
  ~tableName=?,
  ~autoApply=false,
  ~showExtraFiltersInline=false,
  ~addFilterStyle="",
  ~filterButtonStyle="",
  ~tooltipStyling="",
  ~showClearFilterButton=false,
  ~defaultFilterKeys=[],
  ~customRightView=React.null,
  ~customLeftView=React.null,
  ~updateUrlWith=?,
  ~clearFilters=?,
  ~showClearFilter=true,
  ~filterFieldsPortalName="",
  ~initalCount=0,
  ~showFiltersBtn=false,
  ~hideFiltersDefaultValue as _=?,
  ~showSelectFiltersSearch=false,
  ~disableURIdecode=false,
) => {
  let {query} = React.useContext(FilterContext.filterContext)
  let alreadySelectedFiltersUserpref = `remote_filters_selected_keys_${tableName->Option.getOr("")}`
  let {addConfig} = React.useContext(UserPrefContext.userPrefContext)

  let (selectedFiltersList, setSelectedFiltersList) = React.useState(_ =>
    remoteFilters->Array.map(item => item.field)
  )

  React.useEffect1(_ => {
    if remoteFilters->Array.length >= selectedFiltersList->Array.length {
      setSelectedFiltersList(_ => remoteFilters->Array.map(item => item.field))
    }
    None
  }, remoteFilters)

  let updatedSelectedList = React.useMemo1(() => {
    selectedFiltersList
    ->Array.map(item => {
      item.inputNames->Array.get(0)->Option.getOr("")
    })
    ->LogicUtils.getJsonFromArrayOfString
  }, [selectedFiltersList])

  React.useEffect1(() => {
    if remoteFilters->Array.length > 0 {
      addConfig(alreadySelectedFiltersUserpref, updatedSelectedList)
    }
    None
  }, [updatedSelectedList->JSON.stringify])

  let (checkedFilters, setCheckedFilters) = React.useState(_ => [])
  let (count, setCount) = React.useState(_ => initalCount)

  let searchParams = query->decodeURI

  let isMobileView = MatchMedia.useMobileChecker()

  let (initialValueJson, setInitialValueJson) = React.useState(_ => JSON.Encode.object(Dict.make()))

  let localFilterJson = RemoteFiltersUtils.getInitialValuesFromUrl(
    ~searchParams,
    ~initialFilters=localFilters,
    (),
  )
  let clearFilterJson =
    RemoteFiltersUtils.getInitialValuesFromUrl(
      ~searchParams,
      ~initialFilters=localFilters,
      ~options=remoteOptions,
      (),
    )
    ->LogicUtils.getDictFromJsonObject
    ->Dict.keysToArray
    ->Array.length

  let popupUrlKeyArr = popupFilterFields->Array.map(item => item.urlKey)

  React.useEffect1(() => {
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
        ->LogicUtils.getDictFromJsonObject
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
    | Some(dict) => {
        let localCheckedFilters = Array.map(checkedFilters, filter => {
          filter
        })

        let localSelectedFiltersList = Array.map(selectedFiltersList, filter => {
          filter
        })

        dict
        ->Dict.toArray
        ->Array.forEach(entry => {
          let (key, _value) = entry
          let keyIdx = checkedFilters->Array.findIndex(item => item === key)
          if keyIdx === -1 {
            let optionObjIdx = remoteOptions->Array.findIndex(
              option => {
                option.urlKey === key
              },
            )
            if optionObjIdx !== -1 {
              let defaultEntityOptionType: EntityType.optionType<
                't,
              > = EntityType.getDefaultEntityOptionType()
              let optionObj = remoteOptions[optionObjIdx]->Option.getOr(defaultEntityOptionType)
              let optionObjUrlKey = optionObj.urlKey
              if !(popupUrlKeyArr->Array.includes(optionObjUrlKey)) {
                Array.push(localSelectedFiltersList, optionObj.field)
                Array.push(localCheckedFilters, key)
              }
            }
          }
        })
        setCount(_prev => clearFilterJson + initalCount)
        setCheckedFilters(_prev => localCheckedFilters)
        setSelectedFiltersList(_prev => localSelectedFiltersList)
        let finalInitialValueJson =
          initialValues->JsonFlattenUtils.unflattenObject->JSON.Encode.object
        setInitialValueJson(_ => finalInitialValueJson)
      }

    | None => ()
    }
    None
  }, [searchParams])

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

  let verticalGap = !isMobileView ? "gap-y-3" : ""

  <Form onSubmit initialValues=initialValueJson>
    <AutoSubmitter autoApply submit=onSubmit defaultFilterKeys />
    {<AddDataAttributes attributes=[("data-filter", "remoteFilters")]>
      <div>
        <div className={`flex gap-3 items-center flex-wrap ${verticalGap}`}>
          {customLeftView}
          <UIUtils.RenderIf condition={fixedFilters->Array.length > 0}>
            <FormRenderer.FieldsRenderer
              fields={fixedFilters->Array.map(item => item.field)}
              labelClass="hidden"
              fieldWrapperClass="p-0"
            />
          </UIUtils.RenderIf>
          <FormRenderer.FieldsRenderer
            fields={selectedFiltersList} labelClass="hidden" fieldWrapperClass="p-0"
          />
          <UIUtils.RenderIf condition={count > 0}>
            <ClearFilters
              filterButtonStyle
              defaultFilterKeys
              ?clearFilters
              count
              outsidefilter={initalCount > 0}
            />
          </UIUtils.RenderIf>
        </div>
      </div>
    </AddDataAttributes>}
  </Form>
}
