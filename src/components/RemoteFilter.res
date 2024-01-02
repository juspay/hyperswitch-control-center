let makeFieldInfo = FormRenderer.makeFieldInfo

@val @scope(("window", "location"))
external reload: unit => unit = "reload"
@val @scope(("window", "location"))
external replace: string => unit = "replace"

module ClearForm = {
  @react.component
  let make = () => {
    let form = ReactFinalForm.useForm()
    <div className="ml-2">
      <Button
        text="Clear Form"
        onClick={e => form.reset(Js.Json.object_(Js.Dict.empty())->Js.Nullable.return)}
      />
    </div>
  }
}

module ModalUI = {
  @react.component
  let make = (
    ~showModal,
    ~setShowModal,
    ~initialValueJson,
    ~fieldsFromOption,
    ~isButtonDisabled,
  ) => {
    let form = ReactFinalForm.useForm()

    let footerUi =
      <div
        className="flex flex-row justify-between p-4 border-t border-jp-gray-500 dark:border-jp-gray-960 items-center">
        <ClearForm />
        <div className="flex flex-row gap-2 place-content-end">
          <Button
            text="Cancel"
            buttonType=SecondaryFilled
            buttonSize=Small
            onClick={_ev => {
              form.reset(initialValueJson->Js.Nullable.return)
              setShowModal(_ => false)
            }}
          />
          <FormRenderer.SubmitButton text="Submit" disabledParamter=isButtonDisabled />
        </div>
      </div>

    <Modal
      modalHeading="Advanced Search"
      showModal
      setShowModal
      borderBottom=true
      childClass="p-2 m-2"
      modalClass="w-full md:w-2/3 mx-auto mt-0"
      onCloseClickCustomFun={_ev => {
        form.reset(initialValueJson->Js.Nullable.return)
        setShowModal(_ => false)
      }}
      modalFooter=footerUi>
      <AddDataAttributes attributes=[("data-filter", "advanceFilters")]>
        <div
          className="overflow-auto"
          style={ReactDOMStyle.make(~maxHeight="calc(100vh - 15rem)", ())}>
          <div className="flex flex-wrap h-fit">
            {switch fieldsFromOption->Belt.Array.get(0) {
            | Some(field) =>
              <FormRenderer.FieldRenderer
                field fieldWrapperClass="w-full !min-w-[200px] p-4 -my-4"
              />
            | None => React.null
            }}
          </div>
          <div className="flex flex-wrap h-fit ">
            {switch fieldsFromOption->Belt.Array.get(1) {
            | Some(field) =>
              <FormRenderer.FieldRenderer
                field fieldWrapperClass="w-full !min-w-[200px] p-4 -my-4"
              />
            | None => React.null
            }}
            {switch fieldsFromOption->Belt.Array.get(3) {
            | Some(field) =>
              <FormRenderer.FieldRenderer
                field fieldWrapperClass="w-full !min-w-[200px] p-4 -my-4"
              />
            | None => React.null
            }}
          </div>
          <div className="flex flex-wrap h-fit mb-10">
            {switch fieldsFromOption->Belt.Array.get(2) {
            | Some(field) =>
              <FormRenderer.FieldRenderer
                field fieldWrapperClass="w-full !min-w-[200px] p-4 -my-4"
              />
            | None => React.null
            }}
            <FormRenderer.FieldsRenderer
              fields={fieldsFromOption->Js.Array2.sliceFrom(4)}
              fieldWrapperClass="w-1/3 !min-w-[200px] p-4 -my-4"
            />
          </div>
        </div>
      </AddDataAttributes>
    </Modal>
  }
}

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
    let url = RescriptReactRouter.useUrl()
    let isMobileView = MatchMedia.useMobileChecker()
    let outerClass = if isMobileView {
      "flex items-center justify-end"
    } else {
      "mt-1 ml-10"
    }
    let textStyle = ""
    let leftIcon: Button.iconType = CustomIcon(<Icon name="clear_filter_img" size=14 />)

    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values", "initialValues"])->Js.Nullable.return,
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
          ->Js.Json.decodeObject
          ->Belt.Option.getWithDefault(Js.Dict.empty())
          ->Js.Dict.entries
          ->Belt.Array.keepMap(entry => {
            let (key, value) = entry
            switch defaultFilterKeys->Js.Array2.includes(key) {
            | true =>
              switch value->Js.Json.classify {
              | JSONString(str) => `${key}=${str}`->Some
              | JSONNumber(num) => `${key}=${num->Js.String.make}`->Some
              | JSONArray(arr) => `${key}=[${arr->Js.String.make}]`->Some
              | _ => None
              }
            | false => None
            }
          })
          ->Js.Array2.joinWith("&")

        let path = url.path->Belt.List.toArray->Js.Array2.joinWith("/")
        RescriptReactRouter.replace(`/${path}?${searchStr}`)
      }
    }

    let hasExtraFilters = React.useMemo2(() => {
      formState.initialValues
      ->Js.Json.decodeObject
      ->Belt.Option.getWithDefault(Js.Dict.empty())
      ->Js.Dict.entries
      ->Js.Array2.filter(entry => {
        let (key, value) = entry
        let isEmptyValue = switch value->Js.Json.classify {
        | JSONString(str) => str === ""
        | JSONArray(arr) => arr->Js.Array2.length === 0
        | JSONNull => true
        | _ => false
        }

        !(defaultFilterKeys->Js.Array2.includes(key)) && !isEmptyValue
      })
      ->Js.Array2.length > 0
    }, (formState.initialValues, defaultFilterKeys))
    let text = isCountRequired ? `Clear ${count->Belt.Int.toString} Filters` : "Clear Filters"
    <UIUtils.RenderIf condition={hasExtraFilters || outsidefilter}>
      <div className={`${filterButtonStyle} ${outerClass}`}>
        <Button
          text showBorder=false textStyle leftIcon onClick=handleClearFilter buttonType=NonFilled
        />
      </div>
    </UIUtils.RenderIf>
  }
}

module AnalyticsClearFilters = {
  @react.component
  let make = (~defaultFilterKeys=[], ~clearFilters=?, ~outsidefilter=false) => {
    let url = RescriptReactRouter.useUrl()
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values", "initialValues"])->Js.Nullable.return,
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
          ->Js.Json.decodeObject
          ->Belt.Option.getWithDefault(Js.Dict.empty())
          ->Js.Dict.entries
          ->Belt.Array.keepMap(entry => {
            let (key, value) = entry
            switch defaultFilterKeys->Js.Array2.includes(key) {
            | true =>
              switch value->Js.Json.classify {
              | JSONString(str) => `${key}=${str}`->Some
              | JSONNumber(num) => `${key}=${num->Js.String.make}`->Some
              | JSONArray(arr) => `${key}=[${arr->Js.String.make}]`->Some
              | _ => None
              }
            | false => None
            }
          })
          ->Js.Array2.joinWith("&")

        let path = url.path->Belt.List.toArray->Js.Array2.joinWith("/")
        RescriptReactRouter.replace(`/${path}?${searchStr}`)
      }
    }

    let hasExtraFilters = React.useMemo2(() => {
      formState.initialValues
      ->Js.Json.decodeObject
      ->Belt.Option.getWithDefault(Js.Dict.empty())
      ->Js.Dict.entries
      ->Js.Array2.filter(entry => {
        let (key, value) = entry
        let isEmptyValue = switch value->Js.Json.classify {
        | JSONString(str) => str === ""
        | JSONArray(arr) => arr->Js.Array2.length === 0
        | JSONNull => true
        | _ => false
        }

        !(defaultFilterKeys->Js.Array2.includes(key)) && !isEmptyValue
      })
      ->Js.Array2.length > 0
    }, (formState.initialValues, defaultFilterKeys))

    <UIUtils.RenderIf condition={hasExtraFilters || outsidefilter}>
      <div className="absolute -top-2 -right-2">
        <ToolTip
          description="Clear Filters"
          tooltipWidthClass="w-24"
          toolTipFor={<Icon
            name="filters-close" size=20 className="mx-1" onClick=handleClearFilter
          />}
        />
      </div>
    </UIUtils.RenderIf>
  }
}

module CheckCustomFilters = {
  @react.component
  let make = (
    ~options: array<EntityType.optionType<'t>>,
    ~checkedFilters,
    ~removeFilters,
    ~addFilters,
    ~showAddFilter,
    ~showSelectFiltersSearch,
  ) => {
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Js.Nullable.return,
    )
    let values = formState.values

    let onChangeSelect = ev => {
      let fieldNameArr = ev->Identity.formReactEventToArrayOfString
      let newlyAdded = Js.Array2.filter(fieldNameArr, newVal =>
        !Js.Array2.includes(checkedFilters, newVal)
      )

      if Js.Array2.length(newlyAdded) > 0 {
        addFilters(newlyAdded)
      } else {
        removeFilters(fieldNameArr, values)
      }
    }

    let selectOptions = options->Js.Array2.map(obj => obj.urlKey)

    <div className="md:justify-between flex p-1 items-center flex-wrap">
      {if Js.Array.length(options) > 0 && showAddFilter {
        <div className="flex flex-wrap">
          <CustomInputSelectBox
            onChange=onChangeSelect
            options={selectOptions->Js.Array2.map(item => {
              {
                SelectBox.label: LogicUtils.snakeToTitle(item),
                SelectBox.value: item,
              }
            })}
            allowMultiSelect=true
            buttonText="Add Filters"
            isDropDown=true
            hideMultiSelectButtons=true
            buttonType=Button.FilterAdd
            value={checkedFilters->Js.Array.map(Js.Json.string, _)->Js.Json.array}
            searchable=showSelectFiltersSearch
          />
        </div>
      } else {
        React.null
      }}
    </div>
  }
}

let defaultAutoApply = false

module AutoSubmitter = {
  @react.component
  let make = (~showModal, ~autoApply, ~submit, ~defaultFilterKeys) => {
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values", "dirtyFields"])->Js.Nullable.return,
    )

    let values = formState.values

    React.useEffect1(() => {
      if formState.dirty {
        let defaultFieldsHaveChanged = defaultFilterKeys->Js.Array2.some(key => {
          formState.dirtyFields->Js.Dict.get(key)->Belt.Option.getWithDefault(false)
        })

        // if autoApply is false then still autoApply can work for the default filters
        if !showModal && (autoApply || defaultFieldsHaveChanged) {
          submit(formState.values, 0)->ignore
        }
      }

      None
    }, [values])

    React.null
  }
}

let getStrFromJson = (key, val) => {
  switch val->Js.Json.classify {
  | JSONString(str) => str
  | JSONArray(array) => array->Js.Array2.length > 0 ? `[${array->Js.Array2.joinWith(",")}]` : ""
  | JSONNumber(num) => key === "offset" ? "0" : num->Belt.Float.toInt->string_of_int
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
      ->Js.Array2.map(filter => {
        let inputFieldsArr = filter.inputFields
        let inputField = inputFieldsArr->LogicUtils.getValueFromArray(0, defaultinputField)
        (inputField.name, inputField)
      })
      ->Js.Dict.fromArray

    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription([
        "values",
        "dirtyFields",
        "initialValues",
      ])->Js.Nullable.return,
    )

    let formCurrentValues =
      formState.values
      ->LogicUtils.getDictFromJsonObject
      ->DictionaryUtils.deleteKeys(defaultFilterKeys)
    let formInitalValues =
      formState.initialValues
      ->LogicUtils.getDictFromJsonObject
      ->DictionaryUtils.deleteKeys(defaultFilterKeys)
    let dirtyFields = formState.dirtyFields->Js.Dict.keys

    let getFormattedDict = dict => {
      dict
      ->Js.Dict.entries
      ->Js.Array2.map(entry => {
        let (key, value) = entry
        let inputField =
          inputFieldsDict->Js.Dict.get(key)->Belt.Option.getWithDefault(defaultinputField)
        let formattor = inputField.format
        let value = switch formattor {
        | Some(fn) => fn(. ~value, ~name=key)
        | None => value
        }
        (key, value)
      })
      ->Js.Dict.fromArray
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

      let otherCheck = formattedCurrentValues->Js.Dict.entries->Js.Array2.reduce((acc, item) => {
          let (_, value) = item
          switch value->Js.Json.classify {
          | JSONString(str) => str === ""
          | JSONArray(arr) => arr->Js.Array2.length === 0
          | JSONObject(dict) => dict->Js.Dict.entries->Js.Array2.length === 0
          | JSONNull => true
          | _ => false
          } &&
          acc
        }, true)
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

module FilterModal = {
  @react.component
  let make = (~selectedFiltersList: Js.Array2.t<FormRenderer.fieldInfoType>, ~showAllFilter) => {
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values", "dirtyFields"])->Js.Nullable.return,
    )

    let formCurrentValues = formState.values->LogicUtils.getDictFromJsonObject
    let sortedSelectedFiltersList = React.useMemo1(_ => {
      let selectedFiltersListWithVal = selectedFiltersList->Js.Array2.filter(item => {
        let inputName = item.inputNames->Belt.Array.get(0)->Belt.Option.getWithDefault("")
        let selectedNo =
          formCurrentValues->LogicUtils.getStrArray(inputName)->Js.Array2.length->Belt.Int.toString
        selectedNo !== "0"
      })
      let selectedFiltersListWithoutVal = selectedFiltersList->Js.Array2.filter(item => {
        !(selectedFiltersListWithVal->Js.Array2.includes(item))
      })

      selectedFiltersListWithVal->Js.Array2.concat(selectedFiltersListWithoutVal)
    }, selectedFiltersList)

    <div className="flex flex-col gap-4.5">
      {sortedSelectedFiltersList
      ->Js.Array2.mapi((item, i) => {
        let inputName = item.inputNames->Belt.Array.get(0)->Belt.Option.getWithDefault("")
        let selectedNo =
          formCurrentValues->LogicUtils.getStrArray(inputName)->Js.Array2.length->Belt.Int.toString
        let textcolor =
          selectedNo !== "0" ? "text-jp-2-light-gray-2000" : "text-jp-2-light-gray-1000"
        <UIUtils.RenderIf condition={showAllFilter || i < 10}>
          <div
            className={`font-medium flex flex-row items-center justify-between px-4 py-2.5 text-fs-14`}>
            <span className={`flex gap-2 items-center ${textcolor}`}>
              {React.string(inputName->LogicUtils.snakeToTitle)}
              <UIUtils.RenderIf condition={selectedNo !== "0"}>
                <AddDataAttributes attributes=[("data-badge-value", selectedNo)]>
                  <span
                    className={`bg-jp-2-light-primary-600 font-medium text-white text-fs-12 px-1.5 py-0.5 w-fit rounded`}>
                    {React.string(selectedNo)}
                  </span>
                </AddDataAttributes>
              </UIUtils.RenderIf>
            </span>
            <FormRenderer.FieldRenderer
              field={item} fieldWrapperClass="flex flex-col" labelClass="hidden" labelPadding="pb-2"
            />
          </div>
        </UIUtils.RenderIf>
      })
      ->React.array}
    </div>
  }
}

@react.component
let make = (
  ~defaultFilters,
  ~fixedFilters: array<EntityType.initialFilters<'t>>=[],
  ~requiredSearchFieldsList,
  ~setOffset=?,
  ~title="",
  ~path="",
  ~refreshFilters=true,
  ~remoteFilters: array<EntityType.initialFilters<'t>>,
  ~remoteOptions: array<EntityType.optionType<'t>>,
  ~localOptions: array<EntityType.optionType<'t>>,
  ~localFilters: array<EntityType.initialFilters<'t>>,
  ~mandatoryRemoteKeys=[],
  ~popupFilterFields: array<EntityType.optionType<'t>>=[],
  ~showRemoteOptions=false,
  ~tableName=?,
  ~autoApply=defaultAutoApply,
  ~showExtraFiltersInline=false,
  ~addFilterStyle="",
  ~filterButtonStyle="",
  ~tooltipStyling="",
  ~showClearFilterButton=false,
  ~defaultFilterKeys=[],
  ~customView=React.null,
  ~customViewTop=React.null,
  ~updateUrlWith=?,
  ~clearFilters=?,
  ~showClearFilter=true,
  ~filterFieldsPortalName="",
  ~initalCount=0,
  ~showFiltersBtn=false,
  ~hideFiltersDefaultValue=?,
  ~showSelectFiltersSearch=false,
  ~disableURIdecode=false,
  ~revampedFilter=false,
) => {
  let alreadySelectedFiltersUserpref = `remote_filters_selected_keys_${tableName->Belt.Option.getWithDefault(
      "",
    )}`
  let {addConfig} = React.useContext(UserPrefContext.userPrefContext)
  let syncIcon = "sync"

  let (selectedFiltersList, setSelectedFiltersList) = React.useState(_ =>
    remoteFilters->Js.Array2.map(item => item.field)
  )

  React.useEffect1(_ => {
    if remoteFilters->Js.Array2.length >= selectedFiltersList->Js.Array2.length {
      setSelectedFiltersList(_ => remoteFilters->Js.Array2.map(item => item.field))
    }
    None
  }, remoteFilters)

  let updatedSelectedList = React.useMemo1(() => {
    selectedFiltersList
    ->Js.Array2.map(item => {
      item.inputNames->Belt.Array.get(0)->Belt.Option.getWithDefault("")
    })
    ->Js.Json.stringArray
  }, [selectedFiltersList])

  React.useEffect1(() => {
    if remoteFilters->Js.Array2.length > 0 {
      addConfig(alreadySelectedFiltersUserpref, updatedSelectedList)
    }
    None
  }, [updatedSelectedList->Js.Json.stringify])

  let getNewQuery = DateRefreshHooks.useConstructQueryOnBasisOfOpt()
  let url = RescriptReactRouter.useUrl()
  let (isButtonDisabled, setIsButtonDisabled) = React.useState(_ => false)
  let queryStr = url.search

  let totalFilters = selectedFiltersList->Js.Array2.length + localOptions->Js.Array2.length
  let (checkedFilters, setCheckedFilters) = React.useState(_ => [])
  let (clearFilterAfterRefresh, setClearFilterAfterRefresh) = React.useState(_ => false)
  let (count, setCount) = React.useState(_ => initalCount)

  let url = RescriptReactRouter.useUrl()
  let searchParams = disableURIdecode ? url.search : url.search->Js.Global.decodeURI

  let isMobileView = MatchMedia.useMobileChecker()

  let (initialValueJson, setInitialValueJson) = React.useState(_ =>
    Js.Json.object_(Js.Dict.empty())
  )

  let countSelectedFilters = React.useMemo1(() => {
    Js.Dict.keys(
      initialValueJson->Js.Json.decodeObject->Belt.Option.getWithDefault(Js.Dict.empty()),
    )->Js.Array2.length
  }, [initialValueJson])

  let hideFiltersInit = switch hideFiltersDefaultValue {
  | Some(value) => value
  | _ => true
  }

  let (showModal, setShowModal) = React.useState(_ => false)
  let (hideFilters, setHideFilters) = React.useState(_ => hideFiltersInit)
  let (showFiltersModal, setShowFiltersModal) = React.useState(_ => false)
  let (showAllFilter, setShowAllFilter) = React.useState(_ => false)
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
    ->Js.Dict.keys
    ->Js.Array2.length

  let popupUrlKeyArr = popupFilterFields->Js.Array2.map(item => item.urlKey)

  React.useEffect1(() => {
    let initialValues = RemoteFiltersUtils.getInitialValuesFromUrl(
      ~searchParams,
      ~initialFilters={Js.Array.concat(remoteFilters, fixedFilters)},
      ~mandatoryRemoteKeys,
      ~options=remoteOptions,
      (),
    )
    switch updateUrlWith {
    | Some(fn) =>
      fn(
        initialValues
        ->LogicUtils.getDictFromJsonObject
        ->Js.Dict.entries
        ->Js.Array2.map(item => {
          let (key, value) = item
          (key, getStrFromJson(key, value))
        })
        ->Js.Dict.fromArray,
      )
    | None => ()
    }

    switch initialValues->Js.Json.decodeObject {
    | Some(dict) => {
        let localCheckedFilters = Js.Array2.map(checkedFilters, filter => {
          filter
        })

        let localSelectedFiltersList = Js.Array2.map(selectedFiltersList, filter => {
          filter
        })

        dict
        ->Js.Dict.entries
        ->Js.Array2.forEach(entry => {
          let (key, _value) = entry
          let keyIdx = checkedFilters->Js.Array2.findIndex(item => item === key)
          if keyIdx === -1 {
            let optionObjIdx = remoteOptions->Js.Array2.findIndex(
              option => {
                option.urlKey === key
              },
            )
            if optionObjIdx !== -1 {
              let defaultEntityOptionType: EntityType.optionType<
                't,
              > = EntityType.getDefaultEntityOptionType()
              let optionObj =
                remoteOptions[optionObjIdx]->Belt.Option.getWithDefault(defaultEntityOptionType)
              let optionObjUrlKey = optionObj.urlKey
              if !(popupUrlKeyArr->Js.Array2.includes(optionObjUrlKey)) {
                Js.Array.push(optionObj.field, localSelectedFiltersList)->ignore
                Js.Array.push(key, localCheckedFilters)->ignore
              }
            }
          }
        })
        setCount(_prev => clearFilterJson + initalCount)
        setCheckedFilters(_prev => localCheckedFilters)
        setSelectedFiltersList(_prev => localSelectedFiltersList)
        let finalInitialValueJson = initialValues->JsonFlattenUtils.unflattenObject->Js.Json.object_
        setInitialValueJson(_ => finalInitialValueJson)
      }

    | None => ()
    }
    None
  }, [searchParams])

  let onSubmit = (values, _) => {
    let obj =
      values
      ->Js.Json.decodeObject
      ->Belt.Option.getWithDefault(Js.Dict.empty())
      ->Js.Dict.entries
      ->Js.Dict.fromArray

    let flattendDict = obj->Js.Json.object_->JsonFlattenUtils.flattenObject(false)
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
    setShowFiltersModal(_ => false)
    setShowModal(_ => false)
    Js.Nullable.null->resolve
  }

  let addFilters = newlyAdded => {
    let localCheckedFilters = Js.Array2.map(checkedFilters, checkedStr => {
      checkedStr
    })
    let localSelectedFiltersList = Js.Array2.map(selectedFiltersList, filter => {
      filter
    })
    newlyAdded->Js.Array2.forEach(value => {
      let optionObjArry = remoteOptions->Js.Array2.filter(option => option.urlKey === value)
      let defaultEntityOptionType: EntityType.optionType<
        't,
      > = EntityType.getDefaultEntityOptionType()
      let optionObj = optionObjArry[0]->Belt.Option.getWithDefault(defaultEntityOptionType)
      let _ = Js.Array2.push(localSelectedFiltersList, optionObj.field)
      let _a = Js.Array2.push(localCheckedFilters, value)
    })
    setCheckedFilters(_prev => localCheckedFilters)
    setSelectedFiltersList(_prev => localSelectedFiltersList)
  }

  let removeFilters = (fieldNameArr, values) => {
    let toBeRemoved =
      checkedFilters->Js.Array2.filter(oldVal => !Js.Array.includes(oldVal, fieldNameArr))
    switch values->Js.Json.decodeObject {
    | Some(dict) =>
      dict
      ->Js.Dict.entries
      ->Js.Array2.forEach(entry => {
        let (key, _val) = entry

        if toBeRemoved->Js.Array2.includes(key) {
          dict->Js.Dict.set(key, Js.Json.string(""))
        }
      })
    | None => ()
    }

    let finalFieldList = selectedFiltersList->Js.Array2.filter(val => {
      val.inputNames
      ->Belt.Array.get(0)
      ->Belt.Option.map(name => !Js.Array2.includes(toBeRemoved, name))
      ->Belt.Option.getWithDefault(false)
    })
    let filtersAfterRemoving =
      checkedFilters->Js.Array2.filter(val => !Js.Array2.includes(toBeRemoved, val))

    let newValueJson =
      initialValueJson
      ->Js.Json.decodeObject
      ->Belt.Option.map(Js.Dict.entries)
      ->Belt.Option.getWithDefault([])
      ->Js.Array2.filter(entry => {
        let (key, _value) = entry
        !Js.Array2.includes(toBeRemoved, key)
      })
      ->Js.Dict.fromArray
      ->Js.Json.object_

    setInitialValueJson(_ => newValueJson)
    setCheckedFilters(_prev => filtersAfterRemoving)
    setSelectedFiltersList(_prev => finalFieldList)
  }

  let validate = values => {
    let valuesDict = values->JsonFlattenUtils.flattenObject(false)
    let errors = Js.Dict.empty()

    requiredSearchFieldsList->Js.Array2.forEach(key => {
      if Js.Dict.get(valuesDict, key)->Js.Option.isNone {
        let key = if key == "filters.dateCreated.lte" || key == "filters.dateCreated.gte" {
          "Date Range"
        } else {
          key
        }
        Js.Dict.set(errors, key, "Required"->Js.Json.string)
      }
    })
    if errors->Js.Dict.entries->Js.Array2.length > 0 {
      setIsButtonDisabled(_ => true)
    } else {
      setIsButtonDisabled(_ => false)
    }
    errors->Js.Json.object_
  }

  let fieldsFromOption = popupFilterFields->Js.Array2.map(option => {option.field})

  let handleRefresh = _ => {
    let newQueryStr = getNewQuery(
      ~queryString=queryStr,
      ~disableFutureDates=true,
      ~disablePastDates=false,
      ~startKey="startTime",
      ~endKey="endTime",
      ~optKey="opt",
    )
    let urlValue = `${path}?${newQueryStr}`
    setClearFilterAfterRefresh(_ => true)
    setInitialValueJson(_ => Js.Dict.empty()->Js.Json.object_)
    replace(urlValue)
  }

  let refreshFilterUi = {
    if refreshFilters {
      <ToolTip
        description={"Refresh the dashboard with applied settings"}
        toolTipFor={<div className={`my-1 mx-2 ${tooltipStyling} syncButton`}>
          <Button
            buttonType={SecondaryFilled}
            buttonSize=Small
            text="Refresh"
            rightIcon={FontAwesome(syncIcon)}
            onClick=handleRefresh
          />
        </div>}
        toolTipPosition=Bottom
        height="h-fit"
      />
    } else {
      React.null
    }
  }
  let (text, iconName) = if !showAllFilter {
    (
      `View ${(selectedFiltersList->Js.Array2.length - 10)->Belt.Int.toString} more filters`,
      "new-chevron-down",
    )
  } else {
    ("Show Less", "new-chevron-up")
  }
  let isFilterSection = React.useContext(TableFilterSectionContext.filterSectionContext)
  let advancedSearchByttonType: Button.buttonType = SecondaryFilled
  let advancedSearchMargin = !isMobileView ? "ml-1" : "ml-1 mt-1"
  let verticalGap = !isMobileView ? "gap-y-2" : ""
  let filterWidth = ""
  let (filterHovered, setFilterHovered) = React.useState(_ => false)
  let badge: Button.badge = {value: countSelectedFilters->Belt.Int.toString, color: BadgeBlue}

  let advacedAndClearButtons =
    <>
      <UIUtils.RenderIf
        condition={fieldsFromOption->Js.Array.length > 0 &&
        !showExtraFiltersInline &&
        !showRemoteOptions}>
        <Portal to={`tableFilterTopRight-${title}`}>
          <div className=advancedSearchMargin>
            <Button
              text="Advanced Search"
              leftIcon=NoIcon
              buttonType=advancedSearchByttonType
              buttonSize=Small
              onClick={_ev => setShowModal(_ => true)}
              badge={countSelectedFilters > 0
                ? badge
                : {
                    value: 1->Belt.Int.toString,
                    color: NoBadge,
                  }}
            />
          </div>
        </Portal>
      </UIUtils.RenderIf>
      <UIUtils.RenderIf
        condition={!hideFilters && fixedFilters->Js.Array2.length === 0 && showClearFilter}>
        <ClearFilters
          filterButtonStyle
          defaultFilterKeys
          ?clearFilters
          count
          isCountRequired=false
          outsidefilter={initalCount > 0}
        />
      </UIUtils.RenderIf>
    </>
  let fieldWrapperClass = None
  <div className="rounded-lg">
    <Form onSubmit initialValues=initialValueJson>
      <AutoSubmitter showModal autoApply submit=onSubmit defaultFilterKeys />
      {<AddDataAttributes attributes=[("data-filter", "remoteFilters")]>
        <div>
          <div className={`flex flex-wrap flex-1 ${verticalGap}`}>
            {fixedFilters->Js.Array2.length > 0
              ? <>
                  <FormRenderer.FieldsRenderer
                    fields={fixedFilters->Js.Array2.map(item => item.field)}
                    labelClass="hidden"
                    labelPadding="pb-2"
                    ?fieldWrapperClass
                  />
                </>
              : React.null}
            <UIUtils.RenderIf condition={hideFilters && isFilterSection}>
              <PortalCapture key={`customizedColumn-${title}`} name={`customizedColumn-${title}`} />
            </UIUtils.RenderIf>
            {customViewTop}
            {if showFiltersBtn {
              if !revampedFilter {
                <ToolTip
                  description={!hideFilters
                    ? "Hide filters control panel(this will not clear the filters)"
                    : "Apply filters from exhaustive list of dimensions"}
                  toolTipFor={<div className={`my-1 mx-2 ${tooltipStyling} showFilterButton`}>
                    <Button
                      text={isMobileView ? "" : hideFilters ? "Show Filters" : "Hide Filters"}
                      buttonType=SecondaryFilled
                      buttonSize=Small
                      leftIcon=CustomIcon(
                        <Icon
                          name={hideFilters ? "show-filters" : "minus"}
                          size=14
                          className={isMobileView ? "mr-0.75" : "ml-1.5 mr-1"}
                        />,
                      )
                      onClick={_ => {
                        setHideFilters(_ => !hideFilters)
                      }}
                    />
                  </div>}
                  toolTipPosition={isMobileView ? BottomLeft : Right}
                />
              } else {
                <>
                  <PortalCapture key="savedView" name="savedView" customStyle="flex items-center" />
                  <Portal to="filter">
                    <div
                      className={`my-1 showFilterButton relative`}
                      onMouseOver={_ => setFilterHovered(_ => true)}
                      onMouseOut={_ => setFilterHovered(_ => false)}>
                      <Button
                        text={isMobileView ? "" : "Filters"}
                        buttonType=Dropdown
                        isDropdownOpen={!hideFilters}
                        buttonSize=Small
                        leftIcon=CustomIcon(<Icon name="filter-funnel" size=20 />)
                        badge={
                          value: count->Belt.Int.toString,
                          color: count > 0 ? BadgeBlue : NoBadge,
                        }
                        onClick={_ => {
                          setShowFiltersModal(_ => true)
                        }}
                      />
                      <UIUtils.RenderIf condition={count > 0 && filterHovered}>
                        <AnalyticsClearFilters
                          defaultFilterKeys ?clearFilters outsidefilter={initalCount > 0}
                        />
                      </UIUtils.RenderIf>
                    </div>
                    <Modal
                      modalHeading="Analytics Filters"
                      showModal=showFiltersModal
                      setShowModal=setShowFiltersModal
                      paddingClass=""
                      closeOnOutsideClick=false
                      modalClass="w-100 h-screen overflow-hidden float-right !bg-white dark:!bg-jp-gray-lightgray_background"
                      headingClass="py-6 px-2.5 h-24 border-b border-solid flex flex-col justify-center !bg-white dark:!bg-black border-slate-300"
                      headerTextClass="font-bold text-fs-24 leading-8"
                      childClass="m-0 p-0"
                      noBackDrop=true>
                      {<div
                        className="px-4 pt-6"
                        style={ReactDOMStyle.make(~height="calc(100vh - 12rem)", ())}>
                        <div
                          className="overflow-auto pb-10 gap-8"
                          style={ReactDOMStyle.make(~height="calc(100vh - 14rem)", ())}>
                          {if selectedFiltersList->Js.Array2.length > 0 {
                            <div className="flex flex-col gap-6">
                              <FilterModal selectedFiltersList showAllFilter />
                              <div
                                className="rounded-full bg-jp-2-light-gray-100 font-medium cursor-pointer flex flex-row gap-2 items-center justify-center mx-auto py-0.5 px-2 w-fit"
                                onClick={_ => setShowAllFilter(prev => !prev)}>
                                {React.string(text)}
                                <Icon name=iconName size=12 />
                              </div>
                            </div>
                          } else {
                            <div className="flex justify-center items-center">
                              {React.string("No filters found")}
                            </div>
                          }}
                        </div>
                        <FormRenderer.SubmitButton
                          text="Apply Filters" customSumbitButtonStyle="w-full mt-4"
                        />
                      </div>}
                    </Modal>
                    {customView}
                  </Portal>
                </>
              }
            } else {
              React.null
            }}
            {if !clearFilterAfterRefresh && hideFilters && count > 0 && !revampedFilter {
              <ClearFilters
                filterButtonStyle
                defaultFilterKeys
                ?clearFilters
                count
                outsidefilter={initalCount > 0}
              />
            } else {
              React.null
            }}
          </div>
          <div className="flex items-center">
            <Portal to=filterFieldsPortalName>
              <div
                className={`flex ${isMobileView
                    ? "flex-wrap"
                    : "flex-row justify-between"} w-full items-center gap-2`}>
                <div
                  className={`md:justify-between flex items-center flex-wrap ${filterWidth} ${addFilterStyle}`}>
                  {if hideFilters {
                    React.null
                  } else {
                    <div className={`flex ${!isMobileView ? "w-full" : "flex-wrap"}`}>
                      <div
                        className={`flex flex-wrap ${!isMobileView
                            ? "items-center flex-1 gap-y-2 gap-x-3 w-full"
                            : ""}`}>
                        <FormRenderer.FieldsRenderer
                          fields={selectedFiltersList} labelClass="hidden" labelPadding="pb-2"
                        />
                        {fixedFilters->Js.Array2.length === 0 ? refreshFilterUi : React.null}
                        advacedAndClearButtons
                        <UIUtils.RenderIf condition={!hideFilters}>
                          <PortalCapture
                            key={`customizedColumn-${title}`} name={`customizedColumn-${title}`}
                          />
                        </UIUtils.RenderIf>
                      </div>
                    </div>
                  }}
                </div>
                <div className={`flex items-center justify-end flex-wrap`}>
                  <div>
                    {if showExtraFiltersInline || showRemoteOptions {
                      if !hideFilters {
                        <div>
                          <CheckCustomFilters
                            options={remoteOptions}
                            checkedFilters
                            addFilters
                            removeFilters
                            showAddFilter={fieldsFromOption->Js.Array2.length > 0 ||
                              (showRemoteOptions && remoteOptions->Js.Array2.length > 0)}
                            showSelectFiltersSearch
                          />
                        </div>
                      } else {
                        React.null
                      }
                    } else {
                      React.null
                    }}
                  </div>
                  {!hideFilters ? customView : React.null}
                  <ApplyFilterButton
                    autoApply
                    totalFilters
                    hideFilters
                    filterButtonStyle
                    defaultFilterKeys
                    selectedFiltersList
                  />
                  {if showClearFilterButton && !hideFilters && count > 0 {
                    <ClearFilters
                      filterButtonStyle
                      defaultFilterKeys
                      ?clearFilters
                      count
                      outsidefilter={initalCount > 0}
                    />
                  } else {
                    React.null
                  }}
                </div>
              </div>
            </Portal>
          </div>
        </div>
      </AddDataAttributes>}
    </Form>
    <LabelVisibilityContext showLabel=true>
      <TableFilterSectionContext isFilterSection=false>
        <Form onSubmit validate initialValues=initialValueJson>
          <ModalUI showModal setShowModal initialValueJson fieldsFromOption isButtonDisabled />
        </Form>
      </TableFilterSectionContext>
    </LabelVisibilityContext>
  </div>
}
