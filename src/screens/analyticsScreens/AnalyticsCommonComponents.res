external toString: option<Js.Json.t> => string = "%identity"
external convertToStrDict: 't => Js.Json.t = "%identity"
external objToJson: {..} => Js.Json.t = "%identity"
external toJson: exn => Js.Json.t = "%identity"
external toRespJson: Fetch.Response.t => Js.Json.t = "%identity"
@get external keyCode: 'a => int = "keyCode"

type window
@val external window: window = "window"
@scope("window") @val external parent: window = "parent"

open LogicUtils
open Promise
type modalView = SavedList | SaveNew
module SavedViewTable = {
  @react.component
  let make = (~actualData, ~modifiedTableEntity) => {
    let (offset, setOffset) = React.useState(_ => 0)
    let searchText = ReactFinalForm.useField("searchTable").input.value
    let search_class = "text-gray-400 dark:text-gray-600"
    let searchTable = FormRenderer.makeFieldInfo(
      ~label="",
      ~name="searchTable",
      ~placeholder="Search ",
      ~customInput=InputFields.textInput(
        ~customStyle="w-64",
        ~autoComplete="off",
        ~leftIcon=<Icon size=16 className=search_class name="search" />,
        (),
      ),
      (),
    )

    let actualData = React.useMemo2(() => {
      actualData->SaveViewEntity.filterBySearchText(searchText)
    }, (searchText, actualData))
    <>
      <FormRenderer.FieldRenderer field=searchTable fieldWrapperClass="w-64 sm:ml-0 ml-2" />
      <LoadedTable
        actualData
        title="Saved Filters"
        entity=modifiedTableEntity
        hideTitle=true
        offset
        setOffset
        currrentFetchCount={actualData->Js.Array2.length}
        totalResults={actualData->Js.Array2.length}
        resultsPerPage=15
        ignoreHeaderBg=true
      />
    </>
  }
}

module AnalyticsSaveViewNew = {
  @react.component
  let make = (
    ~moduleName: string,
    ~tabNames: array<string>,
    ~startTimeFilterKey,
    ~endTimeFilterKey,
  ) => {
    let isMobileView = MatchMedia.useMobileChecker()
    let {updateExistingKeys} = React.useContext(AnalyticsUrlUpdaterContext.urlUpdaterContext)
    let deleteSaveView = AnalyticsHooks.useDeleteSaveView()

    let {
      savedViewList,
      setRefetchCounter,
      isDefaultSaveViewPresent,
      defaultSaveView,
      appliedSaveView,
      applySaveView,
      setAppliedSaveView,
    } = React.useContext(SaveViewContext.defaultContext)
    let urlDict = UrlUtils.useGetFilterDictFromUrl("")
    let url = RescriptReactRouter.useUrl()
    let showToast = ToastState.useShowToast()
    let saveView = AnalyticsHooks.useSaveView()
    let updateSaveView = AnalyticsHooks.useUpdateSaveView()
    let (showModal, setShowModal) = React.useState(_ => false)
    let (selectedView, setSelectedView) = React.useState(_ => "")
    let (editView, setEditView) = React.useState(_ => appliedSaveView)
    let filterDict = Js.Dict.empty()
    tabNames->Js.Array2.forEach(key => {
      filterDict->Js.Dict.set(key, "")
    })
    let dateCreatedObject =
      AnalyticsUtils.getDateCreatedObject()
      ->Js.Dict.entries
      ->Js.Array2.map(entry => {
        let (key, value) = entry
        let value = value->getStringFromJson("")
        (key, value)
      })
      ->Js.Dict.fromArray

    let defaultSearchDict = DictionaryUtils.mergeDicts([dateCreatedObject, filterDict])

    let disableSaveButton = React.useMemo2(() => {
      let excludeKeys = appliedSaveView.includeDateRange
        ? []
        : [startTimeFilterKey, endTimeFilterKey]
      let dict1 = SaveViewEntity.getFilterDict(
        ~url=appliedSaveView.url,
        ~prefix="",
        ~excludeKeys,
        (),
      )
      let dict2 = SaveViewEntity.getFilterDict(
        ~url=url.search->Js.Global.decodeURI,
        ~prefix="",
        ~excludeKeys,
        (),
      )

      DictionaryUtils.equalDicts(dict1, dict2)
    }, (url.search, appliedSaveView))

    let options = React.useMemo1(() => {
      [
        {
          let opt: SelectBox.dropdownOption = {
            label: "Base View",
            value: "baseView",
            icon: CustomRightIcon(
              <Button
                text=""
                leftIcon={CustomIcon(<Icon name="new-edit" size=16 />)}
                showBorder=false
                customButtonStyle="invisible"
                buttonType={NonFilled}
                buttonSize={XSmall}
                buttonVariant=Rounded
              />,
            ),
          }
          opt
        },
      ]->Js.Array2.concat(
        savedViewList->Js.Array2.map(ele => {
          let opt: SelectBox.dropdownOption = {
            label: ele.name,
            value: ele.name,
            textColor: "group",
            icon: CustomRightIcon(
              <Button
                text=""
                leftIcon={CustomIcon(<Icon name="new-edit" size=16 />)}
                showBorder=false
                customButtonStyle="invisible group-hover:visible p-2"
                onClick={ev => {
                  ev->ReactEvent.Mouse.stopPropagation
                  ev->ReactEvent.Mouse.preventDefault
                  setEditView(_ => ele)
                  setShowModal(_ => true)
                }}
                buttonType={NonFilled}
                buttonSize={XSmall}
                buttonVariant=Rounded
              />,
            ),
          }
          opt
        }),
      )
    }, [savedViewList->Array.joinWith(",")])

    let modalHeading = "Save Dashboard View"
    let modalHeadingDescription = ""
    let submitButtonText = editView.id === "" ? "Save Dashboard View" : "Update Dashboard View"
    let submitButtonIcon = "new-save"
    let loadingText = "Saving..."

    let saveView = bodyDict => {
      let name = bodyDict->getString("name", "Default View")
      if name === appliedSaveView.name {
        updateSaveView(
          ~bodyStr=bodyDict->Js.Json.object_->Js.Json.stringify,
          ~id=appliedSaveView.id,
        )
      } else {
        saveView(~bodyStr=bodyDict->Js.Json.object_->Js.Json.stringify)
      }
      ->then(response => {
        switch response {
        | Success => {
            showToast(~message="Saved Successfully", ~toastType=ToastSuccess, ())
            setRefetchCounter(prev => prev + 1)
            setShowModal(_ => false)
          }

        | Error(errorMessage) => {
            let errorMessage = errorMessage->Belt.Option.getWithDefault("")
            showToast(~message=errorMessage, ~toastType=ToastError, ())
          }
        }
        Js.Nullable.null->resolve
      })
      ->catch(_err => {
        Js.Nullable.null->resolve
      })
    }

    let saveViewFn = bodyDict => {
      if isDefaultSaveViewPresent {
        let bodyStr =
          [("isDefault", false->Js.Json.boolean)]
          ->Js.Dict.fromArray
          ->Js.Json.object_
          ->Js.Json.stringify
        updateSaveView(~bodyStr, ~id=defaultSaveView.id)
        ->then(response => {
          switch response {
          | Success => saveView(bodyDict)
          | Error(errorMessage) => {
              let errorMessage = errorMessage->Belt.Option.getWithDefault("")
              showToast(~message=errorMessage, ~toastType=ToastError, ())
              Js.Nullable.null->resolve
            }
          }
        })
        ->catch(_err => {
          Js.Nullable.null->resolve
        })
      } else {
        saveView(bodyDict)
      }
    }

    let initialValues = React.useMemo1(() => {
      if editView.id === "" {
        Js.Json.null
      } else {
        let selectors = []
        if editView.includeDateRange {
          selectors->Js.Array2.push("Save with current timestamp"->Js.Json.string)->ignore
        }
        if editView.isDefault {
          selectors->Js.Array2.push("Make this view Default"->Js.Json.string)->ignore
        }
        let initialValues =
          [
            ("name", editView.name->Js.Json.string),
            ("description", editView.description->Js.Json.string),
            ("selectors", selectors->Js.Json.array),
          ]
          ->Js.Dict.fromArray
          ->Js.Json.object_
        initialValues
      }
    }, [editView])

    let validate = (values: Js.Json.t) => {
      let errors = Js.Dict.empty()
      let valuesDict = values->getDictFromJsonObject

      ["name"]->Js.Array2.forEach(key => {
        let value = valuesDict->getString(key, "")
        if value == "" {
          errors->Js.Dict.set(key, `${key->capitalizeString} Required`->Js.Json.string)
        }
        if (
          savedViewList->Js.Array2.map(ele => ele.name)->Js.Array2.includes(value) &&
            editView.id === ""
        ) {
          errors->Js.Dict.set(key, `${key->capitalizeString} already exits`->Js.Json.string)
        }
      })

      errors->Js.Json.object_
    }

    let onSubmit = (values, _) => {
      let valuesDict = values->getDictFromJsonObject

      let name = valuesDict->getString("name", "")
      let description = valuesDict->getString("description", "")
      let selectors = valuesDict->getStrArrayFromDict("selectors", [])
      let isDefault = selectors->Js.Array2.includes("Make this view Default")
      let includeDateRange = selectors->Js.Array2.includes("Save with current timestamp")
      let url = {
        urlDict
        ->Js.Dict.entries
        ->Belt.Array.keepMap(entry => {
          let (key, value) = entry
          let value = switch value->Js.Json.classify {
          | JSONFalse => "false"
          | JSONTrue => "true"
          | JSONNull => ""
          | JSONString(string) => string
          | JSONNumber(float) => float->Belt.Float.toString
          | JSONObject(_) => ""
          | JSONArray(array) => `[${array->Js.Array2.toString}]`
          }
          if (key !== "startTime" && key !== "endTime") || includeDateRange {
            Some(`${key}=${value}`)
          } else {
            None
          }
        })
        ->Js.Array2.joinWith("&")
      }

      let bodyDict = Js.Dict.empty()
      bodyDict->Js.Dict.set("tab", moduleName->Js.Json.string)
      bodyDict->Js.Dict.set("url", url->Js.Json.string)
      bodyDict->Js.Dict.set("name", name->Js.Json.string)
      bodyDict->Js.Dict.set("description", description->Js.Json.string)
      if includeDateRange {
        bodyDict->Js.Dict.set("includeDateRange", includeDateRange->Js.Json.boolean)
      }
      if isDefault {
        bodyDict->Js.Dict.set("isDefault", isDefault->Js.Json.boolean)
      }
      saveViewFn(bodyDict)
    }

    let handleDelete = () => {
      deleteSaveView(~id=editView.id)
      ->then(response => {
        switch response {
        | Success => {
            showToast(~message=`${editView.name} deleted Successfully`, ~toastType=ToastSuccess, ())
            setEditView(_ => defaultSaveView)
            setRefetchCounter(prev => prev + 1)
            setShowModal(_ => false)
          }

        | Error(errorMessage) => {
            let errorMessage = errorMessage->Belt.Option.getWithDefault("")
            showToast(~message=errorMessage, ~toastType=ToastError, ())
          }
        }
        Js.Nullable.null->resolve
      })
      ->catch(_err => {
        Js.Nullable.null->resolve
      })
      ->ignore
    }

    let modalWidth = "sm:w-128"

    let savedViewInput: ReactFinalForm.fieldRenderPropsInput = {
      name: "savedView",
      onBlur: _ev => (),
      onChange: ev => {
        let appliedVal = ev->Identity.formReactEventToString
        if appliedVal === "baseView" {
          updateExistingKeys(defaultSearchDict)
          setAppliedSaveView(_ => SaveViewEntity.defaultSaveView)
        } else {
          switch savedViewList->Js.Array2.find(ele => ele.name === appliedVal) {
          | Some(view) => applySaveView(view)
          | None => ()
          }
        }
        setSelectedView(_ => appliedVal)
      },
      onFocus: _ev => (),
      value: selectedView->Js.Json.string,
      checked: true,
    }
    let saveViewButton = {
      <Button
        text={isMobileView ? "" : "Save View"}
        leftIcon=FontAwesome("new-save")
        buttonState={disableSaveButton ? Disabled : Normal}
        buttonType={Dropdown}
        onClick={_ => {
          setShowModal(_ => true)
        }}
        customIconMargin={isMobileView ? "mr-1" : "ml-1"}
      />
    }
    <div>
      <Portal to="savedView">
        <div className="flex gap-2">
          {if savedViewList->Js.Array2.length > 0 {
            <SelectBox.BaseDropdown
              allowMultiSelect=false
              hideMultiSelectButtons=true
              buttonText="Analytics View"
              defaultLeftIcon=FontAwesome("new-save")
              input={savedViewInput}
              options
              deselectDisable=true
              fullLength=true
              showCustomBtnAtEnd=true
              customButtonStyle="w-46 justify-between"
              customButton={<Button
                text={"Create new view"}
                leftIcon=CustomIcon(
                  <Icon name="new-save" className="stroke-jp-2-light-primary-600" size=16 />,
                )
                buttonState={disableSaveButton ? Disabled : Normal}
                buttonType={FilterAdd}
                onClick={_ => {
                  setEditView(_ => defaultSaveView)
                  setShowModal(_ => true)
                }}
                customButtonStyle="w-full"
                customIconMargin={isMobileView ? "mr-1" : "ml-1"}
              />}
            />
          } else {
            saveViewButton
          }}
        </div>
        <Modal
          modalHeading
          modalHeadingDescription
          showModal
          closeOnOutsideClick=true
          setShowModal
          modalHeadingClass="text-jp-2-light-gray-2000"
          modalClass={`w-full ${modalWidth} overflow-auto p mx-auto`}
          childClass="p-6">
          <Form
            onSubmit
            validate
            initialValues
            formClass="flex flex-col gap-4 w-full relative overflow-auto">
            {<>
              <FormRenderer.FieldRenderer
                field={AnalyticsUtils.nameViewField(~isDisabled={editView.id !== ""})}
              />
              <FormRenderer.FieldRenderer field=AnalyticsUtils.descriptionField />
              <FormRenderer.FieldRenderer
                field={AnalyticsUtils.selectorsField(~isHorizontal=true)} labelClass="hidden"
              />
            </>}
            <div className="border-t">
              <div className={`flex flex-row justify-end pt-6 gap-2`}>
                <UIUtils.RenderIf condition={editView.id !== ""}>
                  <Button
                    buttonType=SecondaryFilled
                    buttonSize=Small
                    text=""
                    rightIcon={FontAwesome("new-trash")}
                    onClick={_ => handleDelete()}
                  />
                </UIUtils.RenderIf>
                <FormRenderer.SubmitButton
                  text=submitButtonText
                  loadingText
                  buttonType=Primary
                  icon=FontAwesome(submitButtonIcon)
                  buttonSize={isMobileView ? XSmall : Small}
                />
              </div>
            </div>
          </Form>
        </Modal>
      </Portal>
      <PortalCapture key="filter" name="filter" customStyle="flex items-center" />
    </div>
  }
}

module AnalyticsSaveView = {
  @react.component
  let make = (
    ~moduleName: string,
    ~tabNames: array<string>,
    ~startTimeFilterKey,
    ~endTimeFilterKey,
  ) => {
    let isMobileView = MatchMedia.useMobileChecker()
    let {updateExistingKeys, filterValueJson} = React.useContext(
      AnalyticsUrlUpdaterContext.urlUpdaterContext,
    )

    let (startTime, endTime) = React.useMemo1(() => {
      (
        filterValueJson->getString(startTimeFilterKey, ""),
        filterValueJson->getString(endTimeFilterKey, ""),
      )
    }, [filterValueJson])

    let dateFilterUrl = React.useMemo2(() => {
      `&${startTimeFilterKey}=${startTime}&${endTimeFilterKey}=${endTime}`
    }, (startTime, endTime))

    let {
      savedViewList,
      refetchCounter,
      setRefetchCounter,
      isDefaultSaveViewPresent,
      defaultSaveView,
      appliedSaveView,
      applySaveView,
      setAppliedSaveView,
    } = React.useContext(SaveViewContext.defaultContext)
    let urlDict = UrlUtils.useGetFilterDictFromUrl("")
    let url = RescriptReactRouter.useUrl()
    let showToast = ToastState.useShowToast()
    let saveView = AnalyticsHooks.useSaveView()
    let updateSaveView = AnalyticsHooks.useUpdateSaveView()
    let (showModal, setShowModal) = React.useState(_ => false)
    let (newSave, setNewSave) = React.useState(_ => true)
    let (modalView, setModalView) = React.useState(_ => SavedList)
    let filterDict = Js.Dict.empty()
    tabNames->Js.Array2.forEach(key => {
      filterDict->Js.Dict.set(key, "")
    })
    let dateCreatedObject =
      AnalyticsUtils.getDateCreatedObject()
      ->Js.Dict.entries
      ->Js.Array2.map(entry => {
        let (key, value) = entry
        let value = value->getStringFromJson("")
        (key, value)
      })
      ->Js.Dict.fromArray

    let defaultSearchDict = DictionaryUtils.mergeDicts([dateCreatedObject, filterDict])

    let disableSaveButton = React.useMemo2(() => {
      let excludeKeys = appliedSaveView.includeDateRange
        ? []
        : [startTimeFilterKey, endTimeFilterKey]
      let dict1 = SaveViewEntity.getFilterDict(
        ~url=appliedSaveView.url,
        ~prefix="",
        ~excludeKeys,
        (),
      )
      let dict2 = SaveViewEntity.getFilterDict(
        ~url=url.search->Js.Global.decodeURI,
        ~prefix="",
        ~excludeKeys,
        (),
      )

      DictionaryUtils.equalDicts(dict1, dict2)
    }, (url.search, appliedSaveView))

    let saveViewName = React.useMemo1(() => {
      appliedSaveView.name
    }, [appliedSaveView])

    let actualData = React.useMemo1(() => {
      savedViewList->Js.Array2.map(Js.Nullable.return)
    }, [savedViewList])

    let modifiedTableEntity = React.useMemo4(() => {
      ...SaveViewEntity.saveFilterListEntity,
      getCell: SaveViewEntity.getCell(
        dateFilterUrl,
        setRefetchCounter,
        isDefaultSaveViewPresent,
        defaultSaveView,
        setShowModal,
        applySaveView,
      ),
    }, (refetchCounter, isDefaultSaveViewPresent, defaultSaveView, dateFilterUrl))

    let (
      modalHeading,
      modalHeadingDescription,
      submitButtonText,
      submitButtonIcon,
      loadingText,
    ) = switch modalView {
    | SavedList => (
        "Load Dashboard View",
        "Load a set of applied filters, selected dimensions and data mode from your saved views",
        "Load Base View",
        "undo-alt",
        "Loading...",
      )
    | SaveNew => (
        "Save Dashboard View",
        "You can save the configuration of the current dashboard as a default view or with a timestamp and load it whenever needed.",
        newSave ? "Save New View" : "Update View",
        "plus",
        "Saving...",
      )
    }

    let saveView = bodyDict => {
      let name = bodyDict->getString("name", "Default View")
      if name === appliedSaveView.name {
        updateSaveView(
          ~bodyStr=bodyDict->Js.Json.object_->Js.Json.stringify,
          ~id=appliedSaveView.id,
        )
      } else {
        saveView(~bodyStr=bodyDict->Js.Json.object_->Js.Json.stringify)
      }
      ->then(response => {
        switch response {
        | Success => {
            showToast(~message="Saved Successfully", ~toastType=ToastSuccess, ())
            setRefetchCounter(prev => prev + 1)
            setShowModal(_ => false)
          }

        | Error(errorMessage) => {
            let errorMessage = errorMessage->Belt.Option.getWithDefault("")
            showToast(~message=errorMessage, ~toastType=ToastError, ())
          }
        }
        Js.Nullable.null->resolve
      })
      ->catch(_err => {
        Js.Nullable.null->resolve
      })
    }

    let saveViewFn = bodyDict => {
      if isDefaultSaveViewPresent {
        let bodyStr =
          [("isDefault", false->Js.Json.boolean)]
          ->Js.Dict.fromArray
          ->Js.Json.object_
          ->Js.Json.stringify
        updateSaveView(~bodyStr, ~id=defaultSaveView.id)
        ->then(response => {
          switch response {
          | Success => saveView(bodyDict)
          | Error(errorMessage) => {
              let errorMessage = errorMessage->Belt.Option.getWithDefault("")
              showToast(~message=errorMessage, ~toastType=ToastError, ())
              Js.Nullable.null->resolve
            }
          }
        })
        ->catch(_err => {
          Js.Nullable.null->resolve
        })
      } else {
        saveView(bodyDict)
      }
    }

    let initialValues = React.useMemo1(() => {
      if appliedSaveView.name === "Default View" {
        Js.Json.null
      } else {
        let selectors = []
        if appliedSaveView.includeDateRange {
          selectors->Js.Array2.push("Save with current time interval"->Js.Json.string)->ignore
        }
        if appliedSaveView.isDefault {
          selectors->Js.Array2.push("Make this view Default"->Js.Json.string)->ignore
        }
        let initialValues =
          [
            ("name", appliedSaveView.name->Js.Json.string),
            ("description", appliedSaveView.description->Js.Json.string),
            ("selectors", selectors->Js.Json.array),
          ]
          ->Js.Dict.fromArray
          ->Js.Json.object_
        initialValues
      }
    }, [appliedSaveView])

    let validate = (values: Js.Json.t) => {
      let errors = Js.Dict.empty()
      let valuesDict = values->getDictFromJsonObject

      switch modalView {
      | SaveNew =>
        let name = valuesDict->getString("name", "Default View")
        setNewSave(_ => name !== appliedSaveView.name)
        ["name"]->Js.Array2.forEach(key => {
          let value = valuesDict->getString(key, "")
          if value == "" {
            errors->Js.Dict.set(key, `${key->capitalizeString} Required`->Js.Json.string)
          }
        })
      | SavedList => ()
      }

      errors->Js.Json.object_
    }

    let onSubmit = (values, _) => {
      let valuesDict = values->getDictFromJsonObject

      switch modalView {
      | SaveNew => {
          let name = valuesDict->getString("name", "")
          let description = valuesDict->getString("description", "")
          let selectors = valuesDict->getStrArrayFromDict("selectors", [])
          let isDefault = selectors->Js.Array2.includes("Make this view Default")
          let includeDateRange = selectors->Js.Array2.includes("Save with current time interval")
          let url = {
            urlDict
            ->Js.Dict.entries
            ->Belt.Array.keepMap(entry => {
              let (key, value) = entry
              let value = switch value->Js.Json.classify {
              | JSONFalse => "false"
              | JSONTrue => "true"
              | JSONNull => ""
              | JSONString(string) => string
              | JSONNumber(float) => float->Belt.Float.toString
              | JSONObject(_) => ""
              | JSONArray(array) => `[${array->Js.Array2.toString}]`
              }
              if (key !== "startTime" && key !== "endTime") || includeDateRange {
                Some(`${key}=${value}`)
              } else {
                None
              }
            })
            ->Js.Array2.joinWith("&")
          }

          let bodyDict = Js.Dict.empty()
          bodyDict->Js.Dict.set("tab", moduleName->Js.Json.string)
          bodyDict->Js.Dict.set("url", url->Js.Json.string)
          bodyDict->Js.Dict.set("name", name->Js.Json.string)
          bodyDict->Js.Dict.set("description", description->Js.Json.string)
          if includeDateRange {
            bodyDict->Js.Dict.set("includeDateRange", includeDateRange->Js.Json.boolean)
          }
          if isDefault {
            bodyDict->Js.Dict.set("isDefault", isDefault->Js.Json.boolean)
          }
          saveViewFn(bodyDict)
        }

      | SavedList => {
          updateExistingKeys(defaultSearchDict)
          setAppliedSaveView(_ => SaveViewEntity.defaultSaveView)
          setShowModal(_ => false)
          Js.Nullable.null->resolve
        }
      }
    }

    let savedViewComp =
      <div className={`flex gap-2 mt-4`}>
        {if actualData->Js.Array2.length > 0 {
          <ToolTip
            description="open previously saved views"
            toolTipFor={<div className="flex flex-col relative">
              <UIUtils.RenderIf
                condition={!disableSaveButton || appliedSaveView.name === "Default View"}>
                <div className="w-2 h-2 bg-red-800 absolute rounded-full z-10 right-0 mr-7 mt-2" />
              </UIUtils.RenderIf>
              <Button
                text={isMobileView ? "" : saveViewName}
                leftIcon=Euler("saveView")
                rightIcon=FontAwesome("angle-down")
                onClick={_ => {
                  setModalView(_ => SavedList)
                  setShowModal(_ => true)
                }}
              />
            </div>}
            tooltipWidthClass="w-fit"
          />
        } else {
          React.null
        }}
        <Button
          text={isMobileView ? "" : "Save"}
          leftIcon=FontAwesome("save")
          buttonState={disableSaveButton ? Disabled : Normal}
          onClick={_ => {
            setModalView(_ => SaveNew)
            setShowModal(_ => true)
          }}
          customIconMargin={isMobileView ? "mr-1" : "ml-1"}
        />
      </div>
    <div>
      savedViewComp
      <Modal
        modalHeading
        modalHeadingDescription
        showModal
        closeOnOutsideClick=true
        setShowModal
        modalClass="lg:w-3/5 sm:w-2/3 overflow-auto w-full mx-auto p-4">
        <Form
          onSubmit
          validate
          initialValues
          formClass="flex flex-col gap-4 w-full relative overflow-auto">
          {switch modalView {
          | SaveNew =>
            <>
              <FormRenderer.FieldRenderer field={AnalyticsUtils.nameViewField(~isDisabled=false)} />
              <FormRenderer.FieldRenderer field=AnalyticsUtils.descriptionField />
              <FormRenderer.FieldRenderer
                field={AnalyticsUtils.selectorsField(~isHorizontal=false)} labelClass="hidden"
              />
            </>

          | SavedList =>
            <div className="mb-8">
              <SavedViewTable actualData modifiedTableEntity />
            </div>
          }}
          <div className="self-end">
            <FormRenderer.SubmitButton
              text=submitButtonText
              loadingText
              buttonType=Pagination
              icon=FontAwesome(submitButtonIcon)
              buttonSize={isMobileView ? XSmall : Small}
            />
          </div>
        </Form>
      </Modal>
    </div>
  }
}

module FiltersComponent = {
  @react.component
  let make = (
    ~filterEntity: AnalyticsUtils.filterEntity<'t>,
    ~downloadDataButtonUi: React.element=React.null,
  ) => {
    open AnalyticsUtils
    let iframe_padding = parent !== window ? "px-5" : ""
    let getFilterData = AnalyticsHooks.useGetFiltersData()
    let {updateExistingKeys, filterValue} = React.useContext(
      AnalyticsUrlUpdaterContext.urlUpdaterContext,
    )

    let {
      initialFilters,
      filterDropDownOptions,
      initialFixedFilters,
      defaultFilterKeys,
      filterKeys,
    } = filterEntity

    let filterBody = switch filterEntity {
    | {filterBody} => filterBody
    | _ => AnalyticsUtils.filterBody
    }

    let source = switch filterEntity {
    | {source} => source
    | _ => "BATCH"
    }
    let customFilterKey = switch filterEntity {
    | {customFilterKey} => customFilterKey
    | _ => ""
    }

    let filterKeys = filterKeys
    let filteredTabKeys = filterKeys

    let getModuleFilters = UrlUtils.useGetFilterDictFromUrl("")
    let startTimeVal = getModuleFilters->getString(startTimeFilterKey, "")

    let endTimeVal = getModuleFilters->getString(endTimeFilterKey, "")

    let filterBody = React.useMemo3(() => {
      let filterBodyEntity: AnalyticsUtils.filterBodyEntity = {
        startTime: startTimeVal,
        endTime: endTimeVal,
        groupByNames: filteredTabKeys,
        source,
        mode: ?filterValue->Js.Dict.get("mode"),
      }
      filterBody(filterBodyEntity)
    }, (startTimeVal, endTimeVal, filteredTabKeys->Js.Array2.joinWith(",")))

    let filterDataOrig = getFilterData(filterEntity.uri, Fetch.Post, filterBody)
    let filterData = filterDataOrig->Belt.Option.getWithDefault(Js.Json.object_(Js.Dict.empty()))

    let filterDataOrigTabNames = React.useMemo2(() => {
      switch filterDataOrig {
      | Some(filterData) =>
        Some(
          {
            "queryData": filterData
            ->getDictFromJsonObject
            ->getJsonObjectFromDict("queryData")
            ->getArrayFromJson([])
            ->Js.Array2.filter(item => {
              let itemDict = item->getDictFromJsonObject
              let dimension = itemDict->getString("dimension", "")
              filteredTabKeys->Js.Array2.includes(dimension)
            })
            ->Js.Json.array,
          }->LineChartUtils.objToJson,
        )
      | None => None
      }
    }, (filterDataOrig, filteredTabKeys))

    switch filterDataOrigTabNames {
    | Some(filterData) =>
      <div className={`flex flex-row ${iframe_padding}`}>
        <DynamicFilter
          initialFilters={initialFilters(filterData)}
          options={filterDropDownOptions(filterData)}
          popupFilterFields={filterDropDownOptions(filterData)}
          initialFixedFilters={initialFixedFilters(filterData)}
          defaultFilterKeys
          tabNames=filteredTabKeys
          updateUrlWith=updateExistingKeys //
          key="0"
          showCustomFilter=true
          customViewTop=downloadDataButtonUi
          moduleName=filterEntity.moduleName
          customFilterKey
          filterFieldsPortalName=""
          showSelectFiltersSearch=true
        />
      </div>
    | None =>
      <div className={`flex flex-row ${iframe_padding}`}>
        <DynamicFilter
          initialFilters=[]
          options=[]
          popupFilterFields=[]
          initialFixedFilters={initialFixedFilters(filterData)}
          defaultFilterKeys
          tabNames=filteredTabKeys
          updateUrlWith=updateExistingKeys //
          key="1"
          showCustomFilter=false
          customViewTop=downloadDataButtonUi
          moduleName=filterEntity.moduleName
          customFilterKey
          filterFieldsPortalName=""
          showSelectFiltersSearch=true
        />
      </div>
    }
  }
}

module FiltersComponentNew = {
  @react.component
  let make = (
    ~filterEntity: AnalyticsUtils.filterEntityNew<'t>,
    ~downloadDataButtonUi: React.element=React.null,
    ~domain="txns",
  ) => {
    open AnalyticsUtils
    let betaEndPointConfig = React.useContext(BetaEndPointConfigProvider.betaEndPointConfig)
    let iframe_padding = parent !== window ? "px-5" : ""
    let parentToken = AuthWrapperUtils.useTokenParent(Original)

    let sortingParams = React.useMemo1((): option<AnalyticsNewUtils.sortedBasedOn> => {
      switch filterEntity {
      | {sortingColumnLegend} =>
        Some({
          sortDimension: sortingColumnLegend,
          ordering: #Desc,
        })
      | _ => None
      }
    }, [filterEntity.sortingColumnLegend])

    let obj = React.useContext(AnalyticsUrlUpdaterContext.urlUpdaterContext)
    let updateExistingKeys = obj.updateExistingKeys

    let {initialFilters, initialFixedFilters, defaultFilterKeys, filterKeys} = filterEntity
    let (initialFilterVals, setInitialFilterVals) = React.useState(_ =>
      filterKeys
      ->Js.Array2.map(ele => (ele, ["Loading..."->Js.Json.string]->Js.Json.array))
      ->Js.Dict.fromArray
    )

    let customFilterKey = switch filterEntity {
    | {customFilterKey} => customFilterKey
    | _ => ""
    }

    let filteredTabKeys = filterKeys

    let getModuleFilters = UrlUtils.useGetFilterDictFromUrl("")
    let startTimeVal = getModuleFilters->getString(startTimeFilterKey, "")
    let fetchApi = AuthHooks.useApiFetcher(~betaEndpointConfig=?betaEndPointConfig, ())
    let addLogsAroundFetch = EulerAnalyticsLogUtils.useAddLogsAroundFetchNew()
    let endTimeVal = getModuleFilters->getString(endTimeFilterKey, "")
    let buttonOnClick = React.useCallback4(metric => {
      let timeObj = Js.Dict.fromArray([
        ("start", startTimeVal->Js.Json.string),
        ("end", endTimeVal->Js.Json.string),
      ])
      let tableBody = AnalyticsNewUtils.apiBodyMaker(
        ~timeObj,
        ~metric,
        ~groupBy=[metric],
        ~sortingParams?,
        ~domain,
        ~dataLimit=300.,
        (),
      )
      if (
        initialFilterVals
        ->getArrayFromDict(metric, [])
        ->Js.Array2.includes("Loading..."->Js.Json.string)
      ) {
        fetchApi(
          `/api/q/analyticsEndPoint`,
          ~method_=Post,
          ~bodyStr=tableBody->Js.Json.stringify,
          ~authToken=parentToken,
          ~headers=[("QueryType", "Filter")]->Js.Dict.fromArray,
          (),
        )
        ->addLogsAroundFetch(~logTitle="Filter Api")
        ->then(text => {
          let jsonObj = convertNewLineSaperatedDataToArrayOfJson(text)
          let resArr =
            jsonObj
            ->Js.Array2.reduce(
              (arr, ele) => {
                let dictValue =
                  ele
                  ->getDictFromJsonObject
                  ->Js.Dict.values
                  ->Js.Array2.map(
                    item => {
                      switch item->Js.Json.classify {
                      | JSONString(str) => str
                      | JSONNumber(num) => num->Belt.Float.toString
                      | JSONTrue => "TRUE"
                      | JSONFalse => "FALSE"
                      | _ => ""
                      }->Js.Json.string
                    },
                  )
                arr->Js.Array2.concat(dictValue)
              },
              [],
            )
            ->Js.Array2.filter(
              ele => {
                ele->getStringFromJson("") !== ""
              },
            )
          setInitialFilterVals(
            prev => {
              let newDict = prev->Js.Dict.entries->Js.Dict.fromArray
              newDict->Js.Dict.set(metric, resArr->Js.Json.array)
              newDict
            },
          )
          resolve()
        })
        ->catch(_err => {
          resolve()
        })
        ->ignore
      }
    }, (startTimeVal, endTimeVal, initialFilterVals, sortingParams))

    <div className={`flex flex-row ${iframe_padding}`}>
      <DynamicFilter
        initialFilters={initialFilters(initialFilterVals->Js.Json.object_, buttonOnClick)}
        options=[]
        popupFilterFields=[]
        initialFixedFilters={initialFixedFilters(Js.Json.null)}
        defaultFilterKeys
        tabNames=filteredTabKeys
        updateUrlWith=updateExistingKeys //
        key="0"
        showCustomFilter=true
        customViewTop=downloadDataButtonUi
        moduleName=filterEntity.moduleName
        customFilterKey
        filterFieldsPortalName=""
        showSelectFiltersSearch=true
        revampedFilter=true
      />
    </div>
  }
}

module DownloadCsv = {
  @react.component
  let make = (
    ~title: string,
    ~tableData: Js.Array2.t<Js.Nullable.t<'t>>,
    ~visibleColumns: Js.Array2.t<'colType>,
    ~colMapper,
    ~getHeading: 'colType => Table.header,
  ) => {
    let isMobileView = MatchMedia.useMobileChecker()
    let actualDataOrig =
      tableData
      ->Belt.Array.keepMap(item => item->Js.Nullable.toOption)
      ->Js.Array2.map(convertToStrDict)

    let headerNames = visibleColumns->Belt.Array.keepMap(head => {
      let item = head->getHeading
      let title = head->colMapper
      title !== "" ? Some(item.title) : None
    })
    let initialValues = visibleColumns->Belt.Array.keepMap(head => {
      let title = head->colMapper
      title !== "" ? Some(title) : None
    })

    let handleDownloadClick = _ev => {
      let header = headerNames->Js.Array2.joinWith(",")

      let csv =
        actualDataOrig
        ->Js.Array2.map(allRows => {
          let allRowsDict =
            Js.Json.decodeObject(allRows)->Belt.Option.getWithDefault(Js.Dict.empty())
          initialValues
          ->Js.Array2.map(col => {
            let str =
              Js.Dict.get(allRowsDict, col)
              ->Belt.Option.getWithDefault(Js.Json.null)
              ->Js.Json.stringify

            let strArr = str->Js.String2.split(".")

            let newStr = if (
              strArr->Js.Array2.length === 2 && str->Belt.Float.fromString->Belt.Option.isSome
            ) {
              let newDecimal =
                strArr
                ->Belt.Array.get(1)
                ->Belt.Option.getWithDefault("00")
                ->Js.String2.slice(~from=0, ~to_=2)
              strArr->Belt.Array.get(0)->Belt.Option.getWithDefault("0") ++ "." ++ newDecimal
            } else {
              str
            }
            newStr
          })
          ->Js.Array2.joinWith(",")
        })
        ->Js.Array2.joinWith("\n")
      let finalCsv = header ++ "\n" ++ csv
      let currentTime = Js.Date.now()->Js.Float.toString
      DownloadUtils.downloadOld(~fileName=`${title}_${currentTime}.csv`, ~content=finalCsv)
    }

    <Button
      text={isMobileView ? "" : "Export Table"}
      leftIcon={FontAwesome("download")}
      onClick=handleDownloadClick
      buttonType={Dropdown}
    />
  }
}

module DownloadRawData = {
  @react.component
  let make = (
    ~totalVolume,
    ~downloadDataEntity: AnalyticsUtils.downloadDataEntity,
    ~moduleName,
  ) => {
    let {addConfig, getConfig} = React.useContext(UserPrefContext.userPrefContext)
    let previouslySelectedColumnsUserPrefKey = `download_data_column_${moduleName}`
    let previouslySelectedDownloadData = switch getConfig(previouslySelectedColumnsUserPrefKey) {
    | Some(jsonVal) =>
      jsonVal
      ->LogicUtils.getStrArryFromJson
      ->Js.Array2.filter(item => {downloadDataEntity.downloadRawDataCols->Js.Array2.includes(item)})
    | None => []
    }
    let fetchApi = AuthHooks.useApiFetcher()
    let (showModal, setShowModal) = React.useState(_ => false)
    let (downloadData, setDownloadData) = React.useState(() => previouslySelectedDownloadData)
    let showToast = ToastState.useShowToast()
    let (buttonState, setButtonState) = React.useState(_ => Button.Normal)
    let isMobileView = MatchMedia.useMobileChecker()

    let (isCheckboxSelected, setIsCheckboxSelected) = React.useState(_ => false)
    let getModuleFilters = UrlUtils.useGetFilterDictFromUrl("")

    let parentToken = AuthWrapperUtils.useTokenParent(Original)
    let downloadDataUrl = downloadDataEntity.uri

    let modalHeadingDescription = switch downloadDataEntity {
    | {description} => description
    | _ => ""
    }

    let {timeKeys, downloadRawDataCols, downloadDataBody} = downloadDataEntity

    let {startTimeKey, endTimeKey} = timeKeys
    let startDateTime = getModuleFilters->getString(startTimeKey, "")

    let endDateTime = getModuleFilters->getString(endTimeKey, "")
    let formattedOptions = React.useMemo1(() => {
      downloadRawDataCols->Js.Array2.map((x): SelectBox.dropdownOption => {
        {label: x->snakeToTitle, value: x}
      })
    }, [downloadRawDataCols])

    let handleDownloadClick = _ev => {
      setShowModal(_ => true)
    }
    let setIsCheckboxSelected = value => {
      setIsCheckboxSelected(_ => value)
    }

    let onSubmit = values => {
      setDownloadData(_ => values)
      addConfig(previouslySelectedColumnsUserPrefKey, values->Js.Json.stringArray)
      setButtonState(_ => Button.Loading)
      setShowModal(_ => false)

      let downloadDataEntity: AnalyticsUtils.downloadDataApiBodyEntity = {
        startTime: startDateTime,
        endTime: endDateTime,
        columns: values,
        compressed: isCheckboxSelected,
      }

      if downloadDataUrl !== "" {
        fetchApi(
          downloadDataUrl,
          ~bodyStr=downloadDataBody(downloadDataEntity),
          ~method_=Fetch.Post,
          ~authToken=parentToken,
          ~headers=[("QueryType", "DownloadData")]->Js.Dict.fromArray,
          (),
        )
        ->then(resp => {
          let statusCode = resp->Fetch.Response.status
          setShowModal(_ => false)
          setButtonState(_ => Button.Normal)
          if statusCode !== 200 {
            showToast(~toastType=ToastError, ~message=`Something went wrong`, ~autoClose=true, ())
          }
          resp->Fetch.Response.json
        })
        ->then(res => {
          let downloadDataUrl = res->getDictFromJsonObject->getString("signedURL", "")
          Webapi.Dom.window
          ->Webapi.Dom.Window.open_(~url=downloadDataUrl, ~name="_blank", ())
          ->ignore

          resolve()
        })
        ->catch(_err => {
          resolve()
        })
        ->ignore
      }
    }
    if downloadRawDataCols->Js.Array2.length > 0 {
      <>
        {if isMobileView {
          React.null
        } else {
          <div className="p-1">
            <Button
              text="Download Raw Data"
              loadingText="Download Raw Data"
              buttonSize=Small
              buttonState
              onClick=handleDownloadClick
            />
          </div>
        }}
        <DownloadSelectModal
          modalHeading="Select Columns"
          modalHeadingDescription
          showModal
          setShowModal
          onSubmit
          initialValues=downloadData
          enableSelect=true
          options=formattedOptions
          submitButtonText="Download Report"
          addCheckboxButton=true
          checkboxButtonText="Compressed Data"
          setIsCheckboxSelected
          isCheckboxSelected
          totalVolume
        />
      </>
    } else {
      React.null
    }
  }
}

module SankeyWithDropDown = {
  @react.component
  let make = (
    ~data,
    ~activeTab,
    ~dataLoading,
    ~sankeyConfig,
    ~startNodeLable="Total Volume",
    ~endNodeLable="Status",
    ~loaderType: AnalyticsUtils.loaderType,
  ) => {
    let (sankeyCardinality, setSankeyCardinality) = React.useState(_ => 5)
    let selectInput: ReactFinalForm.fieldRenderPropsInput = {
      name: "snakey_cardinality",
      onBlur: _ev => (),
      onChange: ev => {
        setSankeyCardinality(_ => {
          ev->Identity.formReactEventToString->Belt.Int.fromString->Belt.Option.getWithDefault(5)
        })
      },
      onFocus: _ev => (),
      value: sankeyCardinality->Belt.Int.toString->Js.Json.string,
      checked: true,
    }
    let selectInputOption = React.useMemo0(() => {
      ["5", "10"]
      ->SelectBox.makeOptions
      ->Js.Array2.map(item => {
        ...item,
        label: `Top ${item.label}`,
      })
    })

    let buttonText = React.useMemo1(() => {
      `Top ${sankeyCardinality->Js.String.make} `
    }, [sankeyCardinality])

    let field =
      <SelectBox.BaseDropdown
        options=selectInputOption
        buttonText
        searchable=false
        allowMultiSelect=false
        input=selectInput
        baseComponent={<Button
          text=buttonText
          buttonSize=Button.Small
          rightIcon=Button.CustomIcon(<Icon className="pl-2 " size=20 name="chevron-down" />)
          ellipsisOnly=true
          customButtonStyle="min-w-full justify-between"
        />}
        hideMultiSelectButtons=true
        deselectDisable=true
        buttonType=Button.Primary
        marginTop="mt-10 min-w-full" // mt-10 because the height of the small button is 10
      />

    <SankeyCharts
      data
      activeTab
      sankeyDataLoading=dataLoading
      sankeyConfig
      field
      topN=sankeyCardinality
      startNodeLable
      endNodeLable
      loaderType
    />
  }
}

module ErrorModalContent = {
  @react.component
  let make = (
    ~str: string,
    ~entity: EntityType.entityType<'modalColType, 'modalTable>,
    ~filterByData,
    ~showModalBarChart: string,
    ~colName: string,
  ) => {
    React.useEffect0(() => {
      let onKeyDown = (event: 'a) => {
        let key = event->keyCode
        if key === 13 {
          event->ReactEvent.Keyboard.preventDefault
        }
      }

      Window.addEventListener("keydown", onKeyDown)

      Some(() => Window.removeEventListener("keydown", onKeyDown))
    })
    let (offset, setOffset) = React.useState(() => 0)
    let searchText = ReactFinalForm.useField("searchTable").input.value
    let search_class = "text-gray-400 dark:text-gray-600"
    let (theme, _setTheme) = React.useContext(ThemeProvider.themeContext)
    let splitString =
      Js.String2.split(str, "$$")->Js.Array2.map(errStr =>
        Js.String2.splitByRe(Js.String2.trim(errStr), %re("/\s*[(%)]\s*/"))
      )

    let actualData12 = if Js.Array2.length(splitString[0]->Belt.Option.getWithDefault([])) > 1 {
      splitString->Js.Array2.map(arr => {
        let arr = Belt.Array.keepMap(arr, item => item)

        Js.Dict.fromArray(
          [
            (colName, arr->Belt.Array.get(0)),
            ("percent", arr->Belt.Array.get(1)),
            ("volume", arr->Belt.Array.get(4)),
          ]->Js.Array2.map(item => {
            let (key, value) = item
            (key, value->Belt.Option.getWithDefault("")->Js.Json.string)
          }),
        )
      })
    } else {
      []
    }
    let data = if Js.Array2.length(actualData12) !== 0 {
      actualData12
      ->Js.Array2.map(arr => arr->Js.Json.object_)
      ->Js.Json.array
      ->entity.getObjects
      ->Js.Array2.map(Js.Nullable.return)
    } else {
      []
    }
    let actualData = React.useMemo2(() => {
      data->filterByData(searchText)
    }, (searchText, data))

    let searchTable = FormRenderer.makeFieldInfo(
      ~label="",
      ~name="searchTable",
      ~placeholder="Search ",
      ~customInput=InputFields.textInput(
        ~customStyle="w-64",
        ~autoComplete="off",
        ~leftIcon=<Icon size=16 className=search_class name="search" />,
        (),
      ),
      (),
    )

    // chart data

    let categoryData = actualData12->Js.Array2.map(json => {
      json->getString(colName, "")
    })

    let chartData = if Js.Array2.length(actualData12) !== 0 {
      actualData12->Js.Array2.map(json => {
        {
          "unit": json->getString(colName, ""),
          "y": json->getFloat("percent", 0.0),
        }
      })
    } else {
      []
    }

    let options: Js.Json.t = React.useMemo4(() => {
      let data = [
        {
          "data": chartData,
        },
      ]
      let categories = categoryData
      let title = {snakeToTitle(colName)}
      let gridLineColor = switch theme {
      | Dark => "#2e2f39"
      | Light => "#e6e6e6"
      }
      {
        "chart": {
          "type": "column",
          "zoomType": "x",
          "backgroundColor": Js.Nullable.null,
        },
        "title": {
          "enabled": false,
          "style": LineChartUtils.chartTitleStyle(theme),
          "text": title,
          "margin": 40,
        },
        "tooltip": {
          "enabled": true,
          "useHTML": true,
          "pointFormat": `<div> <span style="padding-left:6px;font-size:14px;color: "black";opacity: 0.75;padding-top:10px">{point.y}%</span></div>`,
          "headerFormat": "{point.key}"->Some,
          "hideDelay": 0,
          "backgroundColor": "white",
          "valueDecimals": 2,
          "outside": true,
        },
        "yAxis": {
          "gridLineColor": gridLineColor,
          "min": 0,
          "title": {
            "enabled": true,
            "style": LineChartUtils.chartTitleStyle(theme),
            "text": title,
            "margin": 20,
          },
          "labels": {
            "format": "{text}%"->Some,
            "enabled": true,
            "useHTML": true,
          }->Some,
        },
        "xAxis": {
          "categories": categories,
        },
        "plotOptions": {
          "column": {
            "stacking": "Normal",
          },
        },
        "legend": {
          "enabled": false,
        },
        "series": data,
        "credits": {
          "enabled": false,
        },
      }->objToJson
    }, (chartData, categoryData, colName, theme))
    if showModalBarChart == "Table" {
      <div className="-mt-6">
        <FormRenderer.FieldRenderer field=searchTable />
        <LoadedTable
          actualData
          totalResults={actualData->Js.Array2.length}
          offset
          setOffset
          entity
          defaultSort={
            key: "volume",
            order: Table.INC,
          }
          currrentFetchCount={actualData->Js.Array2.length}
          title="Analytics Error Summary Table OnClickDetails"
          hideTitle=true
          resultsPerPage=10
          highlightText={searchText->getStringFromJson("")}
        />
      </div>
    } else {
      <div
        className="flex flex-row justify-between border-b  border-jp-gray-500 dark:border-jp-gray-960 dark:bg-jp-gray-950 text-gray-500 px-4 py-2 ">
        <div className="flex-1 min-h-[400px] finChart">
          <HighchartBarChart.RawBarChart options />
        </div>
      </div>
    }
  }
}

module ErrorOnCellClick = {
  @react.component
  let make = (
    ~val,
    ~str,
    ~entity: EntityType.entityType<'modalColType, 'modalTable>,
    ~filterByData,
    ~colName: string,
  ) => {
    let topNValues = None
    let (showErrorTableModal, setShowErrorTableModal) = React.useState(_ => false)
    let (showModalBarChart, setShowModalBarChart) = React.useState(_ => "Table")
    let (modalErrorHeading, setModalErrorHeading) = React.useState(_ => "")
    let (defaultFilter, _) = Recoil.useRecoilState(AnalyticsHooks.defaultFilter)
    let defaultFilterDict = defaultFilter->safeParse->getDictFromJsonObject
    let activeTab =
      defaultFilterDict
      ->getArrayFromDict("activeTab", [])
      ->Js.Array2.map(key => {
        key->getStringFromJson("")
      })
    let defaultFilters = defaultFilterDict->getJsonObjectFromDict("filter")->getDictFromJsonObject
    let dictKeys = val->Js.Dict.keys
    let filters = defaultFilters->getJsonObjectFromDict("filters")->getDictFromJsonObject
    let filterKeys = filters->Js.Dict.keys

    let cellText = switch topNValues {
    | Some(topNValues) =>
      Js.String2.split(str, "$$")
      ->Js.Array2.map(item => {
        let itemU = item->Js.String2.split("(")
        let lastElement =
          itemU->Belt.Array.get(itemU->Js.Array2.length - 1)->Belt.Option.getWithDefault("")
        let item = item->Js.String2.replace(`(${lastElement}`, "")
        (
          lastElement
          ->Js.String2.replace(")", "")
          ->Js.String.trim
          ->Belt.Int.fromString
          ->Belt.Option.getWithDefault(0),
          item,
        )
      })
      ->Js.Array2.sortInPlaceWith((item1, item2) => {
        let (x1, _y1) = item1
        let (x2, _y2) = item2
        if x1 > x2 {
          -1
        } else if x1 == x2 {
          0
        } else {
          1
        }
      })
      ->Js.Array2.mapi((item, index) => {
        let (_, value) = item
        index < topNValues ? Some(value) : None
      })
      ->Belt.Array.keepMap(item => item)
      ->Js.Array2.joinWith(`\n`)

    | None => Js.String2.split(str, "$$")->Js.Array2.joinWith(`\n`)
    }
    let cellText = Js.String2.split(cellText, "(")->Js.Array2.joinWith(` (`)

    activeTab->Js.Array2.forEach(key => {
      if !(filterKeys->Js.Array2.includes(key)) {
        filterKeys->Js.Array2.push(key)->ignore
      }
    })
    filterKeys->Js.Array2.forEach(key => {
      let value = val->getString(key, "")
      if dictKeys->Js.Array2.includes(key) && value !== "" {
        filters->Js.Dict.set(key, [value->Js.Json.string]->Js.Json.array)
      }
    })

    let valStr =
      activeTab
      ->Js.Array2.map(key => {
        val->getJsonObjectFromDict(key)
      })
      ->Js.Array2.joinWith(", ")

    let keyStr = activeTab->Js.Array2.map(snakeToTitle)->Js.Array2.joinWith(", ")

    let heading = `${keyStr} : ${valStr}`

    let onClick = _ => {
      setShowErrorTableModal(_ => true)
      setModalErrorHeading(_ => heading)
    }

    let renderModalChart = ev => {
      if ev == "Table" {
        setShowModalBarChart(_ => "Table")
      } else {
        setShowModalBarChart(_ => "Bar Chart")
      }
    }

    let modalInput: ReactFinalForm.fieldRenderPropsInput = {
      name: "modalInput",
      onBlur: _ev => (),
      onChange: ev => renderModalChart(ev->Identity.formReactEventToString),
      onFocus: _ev => (),
      value: ""->Js.Json.string,
      checked: true,
    }

    <>
      <div onClick>
        <ToolTip
          tooltipForWidthClass="min-w-full"
          contentAlign=Left
          description=cellText
          toolTipPosition=Left
          textStyle="text-fs-13 ibm-plex font-medium"
          textStyleGap="space-y-6"
          toolTipFor={<div
            className={`px-2 py-0.5 ibm-plex text-fs-13 font-normal text-sky-500 cursor-pointer truncate w-12 min-w-full`}>
            {React.string(cellText)}
          </div>}
        />
      </div>
      {if showErrorTableModal {
        <Modal
          modalHeading=modalErrorHeading
          headingClass="!bg-transparent dark:!bg-jp-gray-lightgray_background"
          showModal=showErrorTableModal
          closeOnOutsideClick=true
          setShowModal=setShowErrorTableModal
          borderBottom=true
          modalClass="md:w-10/12 mx-auto my-8 dark:!bg-jp-gray-lightgray_background p-4 pb-8">
          <Form>
            <div className="flex relative flex-row flex-wrap mb-3">
              <SelectBox.BaseDropdown
                allowMultiSelect=false
                hideMultiSelectButtons=true
                buttonText=showModalBarChart
                input={modalInput}
                options={["Bar chart", "Table"]->SelectBox.makeOptions}
                deselectDisable=false
                autoApply=false
              />
            </div>
            <ErrorModalContent str entity filterByData showModalBarChart colName />
          </Form>
        </Modal>
      } else {
        React.null
      }}
    </>
  }
}

module OnCellClick = {
  @react.component
  let make = (
    ~val,
    ~num,
    ~mapper,
    ~tabValues: array<DynamicTabs.tab>,
    ~domain: string,
    ~customFilterKey: option<string>=?,
    ~summaryTableOnClickEntity,
    ~filterByData,
  ) => {
    let clearFormattingValue =
      ReactFinalForm.useField("enableFormattedData").input.value
      ->Js.Json.decodeBoolean
      ->Belt.Option.getWithDefault(false)
    let (showTableModal, setShowTableModal) = React.useState(_ => false)
    let (modalHeading, setModalHeading) = React.useState(_ => "")
    let (defaultFilter, _) = Recoil.useRecoilState(AnalyticsHooks.defaultFilter)
    let {filterValue} = React.useContext(AnalyticsUrlUpdaterContext.urlUpdaterContext)
    let defaultFilterDict = defaultFilter->safeParse->getDictFromJsonObject
    let activeTab =
      defaultFilterDict
      ->getArrayFromDict("activeTab", [])
      ->Js.Array2.map(key => {
        key->getStringFromJson("")
      })
    let defaultFilters = defaultFilterDict->getJsonObjectFromDict("filter")->getDictFromJsonObject
    let dictKeys = val->Js.Dict.keys
    let filters = defaultFilters->getJsonObjectFromDict("filters")->getDictFromJsonObject
    let filterKeys = filters->Js.Dict.keys
    let getTitle = key => {
      (
        tabValues
        ->Js.Array2.filter(item => {
          item.value == key
        })
        ->Belt.Array.get(0)
        ->Belt.Option.getWithDefault({title: "", value: "", isRemovable: false})
      ).title
    }

    activeTab->Js.Array2.forEach(key => {
      if !(filterKeys->Js.Array2.includes(key)) {
        filterKeys->Js.Array2.push(key)->ignore
      }
    })
    filterKeys->Js.Array2.forEach(key => {
      let value = val->getString(key, "")
      if dictKeys->Js.Array2.includes(key) && value !== "" {
        filters->Js.Dict.set(key, [value->Js.Json.string]->Js.Json.array)
      }
    })
    let currentCustomFilterValue = switch customFilterKey {
    | Some(customFilterKey) =>
      filterValue->Js.Dict.get(customFilterKey)->Belt.Option.getWithDefault("")
    | None => ""
    }

    defaultFilters->Js.Dict.set("filters", filters->Js.Json.object_)
    if currentCustomFilterValue !== "" {
      defaultFilters->Js.Dict.set("customFilter", currentCustomFilterValue->Js.Json.string)
    }

    let valStr =
      activeTab
      ->Js.Array2.map(key => {
        val->getJsonObjectFromDict(key)
      })
      ->Js.Array2.joinWith(", ")

    let keyStr = activeTab->Js.Array2.map(getTitle)->Js.Array2.joinWith(", ")

    let heading = `${keyStr} : ${valStr}`
    let search_class = "text-gray-400 dark:text-gray-600"
    let searchTable = FormRenderer.makeFieldInfo(
      ~label="",
      ~name="searchTable",
      ~placeholder="Search ",
      ~customInput=InputFields.textInput(
        ~customStyle="w-64",
        ~autoComplete="off",
        ~leftIcon=<Icon size=16 className=search_class name="search" />,
        (),
      ),
      (),
    )

    let onClick = _ => {
      setShowTableModal(_ => true)
      setModalHeading(_ => heading)
    }
    <>
      <div
        className="px-2 py-0.5 fira-code text-fs-13 font-normal text-sky-500 cursor-pointer"
        onClick>
        {React.string({clearFormattingValue ? num->Belt.Float.toString : num->mapper})}
      </div>
      {if showTableModal {
        <Modal
          modalHeading
          headingClass="!bg-transparent dark:!bg-jp-gray-lightgray_background"
          showModal=showTableModal
          closeOnOutsideClick=true
          setShowModal=setShowTableModal
          borderBottom=true
          modalClass="md:w-10/12 w-full md:mx-auto md:my-8 dark:!bg-jp-gray-lightgray_background p-4 pb-8 overflow-auto">
          <Form>
            <FormRenderer.FieldRenderer field=searchTable />
            <AnalyticsUtils.TableModalContent
              defaultFilters domain filterByData summayTableEntity=summaryTableOnClickEntity
            />
          </Form>
        </Modal>
      } else {
        React.null
      }}
    </>
  }
}

module BaseTableComponent = {
  @react.component
  let make = (
    ~filters: (string, string),
    ~tableData: Js.Json.t,
    ~defaultSort: string,
    ~tableDataLoading: bool,
    ~transactionTableDefaultCols,
    ~newDefaultCols: array<'colType>,
    ~newAllCols: array<'colType>,
    ~getTransactionTable: Js.Json.t => array<'t>,
    ~colMapper: 'colType => string,
    ~tableEntity: EntityType.entityType<'colType, 't>,
    ~tableGlobalFilter: option<(array<Js.Nullable.t<'t>>, Js.Json.t) => array<Js.Nullable.t<'t>>>,
    ~activeTab,
    ~text,
    ~showDeltaToggleUi: option<React.element>=?,
    ~loaderType: AnalyticsUtils.loaderType,
  ) => {
    open DynamicTableUtils
    let actualData = React.useMemo2(() => {
      let data = tableData->getDictFromJsonObject
      let value =
        data
        ->getJsonObjectFromDict("queryData")
        ->getTransactionTable
        ->Js.Array2.map(Js.Nullable.return)
      value
    }, (tableData, getTransactionTable))
    let {parentAuthInfo} = React.useContext(TokenContextProvider.tokenContext)
    let userInfoText = React.useMemo1(() => {
      switch parentAuthInfo {
      | Some(info) => `${info.merchantId}_tab_performance_table_table_${info.username}_currentTime` // tab name also need to be added based on tab currentTime need to be added
      | None => ""
      }
    }, [parentAuthInfo])
    let isMobileView = MatchMedia.useMobileChecker()
    let (showColumnSelector, setShowColumnSelector) = React.useState(() => false)
    let (offset, setOffset) = React.useState(_ => 0)
    let (_, setCounter) = React.useState(_ => 1)
    let refetch = React.useCallback1(_ => {
      setCounter(p => p + 1)
    }, [setCounter])
    let {defaultColumns} = tableEntity
    let visibleColumns = Recoil.useRecoilValueFromAtom(transactionTableDefaultCols)
    let (startTimeFilter, endTimeFilter) = filters
    let downloadDataText = `${userInfoText}_${startTimeFilter}_${endTimeFilter}`
    let defaultSort: Table.sortedObject = {
      key: defaultSort,
      order: Table.INC,
    }

    let rightTitleElement = React.useMemo2(() => {
      <Button
        text={isMobileView ? "" : "Add/Remove Column"}
        customButtonStyle="tableColumnButton"
        leftIcon={CustomIcon(<Icon name="custom_column_table" size=15 className="mr-1" />)}
        buttonType=SecondaryFilled
        buttonSize=Small
        onClick={_ => setShowColumnSelector(_ => true)}
      />
    }, (setShowColumnSelector, isMobileView))

    let modifiedTableEntity = React.useMemo3(() => {
      {
        ...tableEntity,
        defaultColumns: newDefaultCols,
        allColumns: Some(newAllCols),
      }
    }, (tableEntity, newDefaultCols, newAllCols))

    let filterKeysJson = ReactFinalForm.useField("searchField").input.value

    let clearFormattingValue =
      ReactFinalForm.useField("enableFormattedData").input.value
      ->Js.Json.decodeBoolean
      ->Belt.Option.getWithDefault(false)

    let actualData = React.useMemo2(() => {
      switch tableGlobalFilter {
      | Some(tableGlobalFilter) => actualData->tableGlobalFilter(filterKeysJson)
      | None => actualData
      }
    }, (actualData, filterKeysJson))
    let search_class = "text-gray-400 dark:text-gray-600"

    let clearFormattingToggleUi = FormRenderer.makeFieldInfo(
      ~name="enableFormattedData",
      ~label="Clear Formatting",
      ~customInput=InputFields.boolInput(~isDisabled=false),
      (),
    )

    let initialFilterFields = FormRenderer.makeFieldInfo(
      ~label="",
      ~name="searchField",
      ~placeholder="Search",
      ~customInput=InputFields.textInput(
        ~customStyle=`w-64 tableSearch`,
        ~autoComplete="off",
        ~leftIcon=<Icon size={16} className=search_class name={"search"} />,
        (),
      ),
      (),
    )

    let filt = React.useMemo6(() => {
      <div className="flex flex-row gap-4">
        <ChooseColumns
          entity={modifiedTableEntity}
          totalResults={actualData->Js.Array2.length}
          defaultColumns
          activeColumnsAtom={transactionTableDefaultCols}
          setShowColumnSelector
          showColumnSelector
          sortingBasedOnDisabled=false
          orderdColumnBasedOnDefaultCol=true
          showSerialNumber=false
          mandatoryOptions=activeTab
        />
      </div>
    }, (
      modifiedTableEntity,
      actualData,
      transactionTableDefaultCols,
      setShowColumnSelector,
      showColumnSelector,
      defaultColumns,
    ))

    let clearFormattedDataButton = switch showDeltaToggleUi {
    | Some(toggleUi) =>
      <div className="flex flex-row gap-2">
        <div className="flex flex-row items-center">
          <FormRenderer.FieldWrapper label="Show Delta"> {React.null} </FormRenderer.FieldWrapper>
          {toggleUi}
        </div>
        <FormRenderer.FieldRenderer
          field=clearFormattingToggleUi fieldWrapperClass="flex flex-row items-center gap-1"
        />
      </div>
    | None =>
      <FormRenderer.FieldRenderer
        field=clearFormattingToggleUi fieldWrapperClass="flex flex-row items-center gap-1"
      />
    }

    let bottomMargin = "-mb-13"
    let tableBorderClass = "border-collapse border border-jp-gray-940 border-solid border-2 rounded-sm border-opacity-30 dark:border-jp-gray-dark_table_border_color dark:border-opacity-30"
    let downloadCsv =
      <DownloadCsv
        title=downloadDataText
        tableData=actualData
        visibleColumns
        colMapper
        getHeading=modifiedTableEntity.getHeading
      />
    let frozenIndex = activeTab->Js.Array2.length
    <div className="flex flex-1 flex-col m-4">
      <RefetchContextProvider value=refetch>
        {if loaderType === Shimmer && tableDataLoading {
          <Shimmer styleClass="w-full h-96 dark:bg-black bg-white" shimmerType={Big} />
        } else {
          {
            <>
              <div className="flex">
                <AddDataAttributes attributes=[("data-header-text", text)]>
                  <div
                    className="font-bold text-xl text-black text-opacity-75 dark:text-white dark:text-opacity-75">
                    {React.string(text)}
                  </div>
                </AddDataAttributes>
                {if tableDataLoading && loaderType === SideLoader {
                  <div className="animate-spin px-4">
                    <Icon name="spinner" size=20 />
                  </div>
                } else {
                  React.null
                }}
              </div>
              <div className={`flex flex-1 -ml-1  ${isMobileView ? "" : bottomMargin}`}>
                <FormRenderer.FieldRenderer field=initialFilterFields />
              </div>
              <AddDataAttributes attributes=[("data-loaded-table", text)]>
                <div>
                  <LoadedTable
                    visibleColumns
                    title=text
                    hideTitle=true
                    actualData
                    entity=modifiedTableEntity
                    resultsPerPage=10
                    totalResults={actualData->Js.Array2.length}
                    filters={filt}
                    offset
                    setOffset
                    defaultSort
                    rightTitleElement={rightTitleElement}
                    currrentFetchCount={actualData->Js.Array2.length}
                    clearFormattedDataButton
                    downloadCsv={downloadCsv}
                    tableLocalFilter=true
                    tableheadingClass=tableBorderClass
                    tableBorderClass
                    tableDataBorderClass=tableBorderClass
                    frozenUpto={isMobileView ? 1 : frozenIndex}
                    highlightText={filterKeysJson->getStringFromJson("")}
                    clearFormatting=clearFormattingValue
                    isAnalyticsModule=true
                    showTableOnMobileView=true
                  />
                </div>
              </AddDataAttributes>
            </>
          }
        }}
      </RefetchContextProvider>
    </div>
  }
}

let useTableSankeyWrapper = (
  ~sankeyEntity: option<SankeyCharts.sankeyEntity>,
  ~colMapper: 'colType => string,
  ~analyticsTableEntity: AnalyticsUtils.analyticsTableEntity<'colType, 't>,
  ~text,
) => {
  let getModuleFilters = UrlUtils.useGetFilterDictFromUrl("")
  let parentToken = AuthWrapperUtils.useTokenParent(Original)

  let activeTab = React.useMemo1(() => {
    getModuleFilters->getOptionStrArrayFromDict(`${analyticsTableEntity.moduleName}.tabName`)
  }, [getModuleFilters])

  let (activeTabState, setActiveTabState) = React.useState(_ => activeTab)

  let {
    tableEntity,
    defaultSortCol,
    deltaMetrics,
    isIndustry,
    distributionArray,
    metrics,
    tableUpdatedHeading,
    tableGlobalFilter,
    moduleName,
    filterKeys,
    timeKeys,
    modeKey,
    moduleNamePrefix,
    source,
  } = analyticsTableEntity
  let tableSelectedColumnUserPrefKey = `dynamicTable_selected_columns_${moduleName}`
  let tableMetrics = metrics

  let tableCustomFilterKey = switch analyticsTableEntity {
  | {customFilterKey} => customFilterKey
  | _ => ""
  }

  let defaultSort = defaultSortCol
  let {getObjects} = tableEntity
  let getTransactionTable = getObjects
  let (tableLoading, setTableLoading) = React.useState(_ => false)
  let (tableHeaderLoading, setShowTableHeaderLoading) = React.useState(_ => false)
  let {getHeading, allColumns, defaultColumns} = tableEntity
  let allMetricColumn = defaultColumns
  let activeTabStr = activeTab->Belt.Option.getWithDefault([])->Js.Array2.joinWith("-")
  let {startTimeKey, endTimeKey} = timeKeys
  let (startTimeFilterKey, endTimeFilterKey) = (startTimeKey, endTimeKey)
  let (showDelta, setShowDelta) = React.useState(_ => false)
  // with prefix will be specific for the component level filter but without prefix will be at the overall level filters
  let getAllFilter = UrlUtils.useGetFilterDictFromUrl("")
  let showDeltaInput: ReactFinalForm.fieldRenderPropsInput = {
    name: "showDelta",
    onBlur: _ev => (),
    onChange: ev => setShowDelta(_ => ev->Identity.formReactEventToBool),
    onFocus: _ev => (),
    value: showDelta->Js.Json.boolean,
    checked: false,
  }

  // without prefix only table related Filters
  let getTopLevelFilter = React.useMemo1(() => {
    getAllFilter
    ->Js.Dict.entries
    ->Belt.Array.keepMap(item => {
      let (key, value) = item
      let keyArr = key->Js.String2.split(".")
      let prefix = keyArr->Belt.Array.get(0)->Belt.Option.getWithDefault("")
      if prefix === moduleName && prefix !== "" {
        None
      } else {
        Some((prefix, value))
      }
    })
    ->Js.Dict.fromArray
  }, [getAllFilter])

  let allColumns = allColumns->Belt.Option.getWithDefault([])
  let defaultTableColumn = switch analyticsTableEntity {
  | {defaultColumn} => defaultColumn
  | {tableEntity} => tableEntity.allColumns->Belt.Option.getWithDefault([])
  }

  let consumeSankeyFetchedData = React.useMemo1(() => {
    switch sankeyEntity {
    | Some(sankeyEntity) => sankeyEntity.fetchData
    | None => false
    }
  }, [sankeyEntity])
  // NOTE ideally these filters keys should be passed in datatable entity or if we make a entity for the table and sankey

  let (_, setDefaultFilter) = Recoil.useRecoilState(AnalyticsHooks.defaultFilter)

  let mode = switch modeKey {
  | Some(modeKey) => Some(getTopLevelFilter->getString(modeKey, ""))
  | None => Some("ORDER")
  }

  let allFilterKeys = Js.Array2.concat(
    [startTimeFilterKey, endTimeFilterKey, mode->Belt.Option.getWithDefault("")],
    filterKeys,
  )

  let (topFiltersToSearchParam, customFilter) = React.useMemo1(() => {
    let filterSearchParam =
      getTopLevelFilter
      ->Js.Dict.entries
      ->Belt.Array.keepMap(entry => {
        let (key, value) = entry
        if allFilterKeys->Js.Array2.includes(key) {
          switch value->Js.Json.classify {
          | JSONString(str) => `${key}=${str}`->Some
          | JSONNumber(num) => `${key}=${num->Js.String.make}`->Some
          | JSONArray(arr) => `${key}=[${arr->Js.String.make}]`->Some
          | _ => None
          }
        } else {
          None
        }
      })
      ->Js.Array2.joinWith("&")

    (filterSearchParam, getTopLevelFilter->LogicUtils.getString(tableCustomFilterKey, ""))
  }, [getTopLevelFilter])

  let filterValueFromUrl = React.useMemo1(() => {
    getTopLevelFilter
    ->Js.Dict.entries
    ->Belt.Array.keepMap(entries => {
      let (key, value) = entries
      filterKeys->Js.Array2.includes(key) ? Some((key, value)) : None
    })
    ->Js.Dict.fromArray
    ->Js.Json.object_
    ->Some
  }, [topFiltersToSearchParam])

  let startTimeFromUrl = React.useMemo1(() => {
    getTopLevelFilter->getString(startTimeFilterKey, "")
  }, [topFiltersToSearchParam])
  let endTimeFromUrl = React.useMemo1(() => {
    getTopLevelFilter->getString(endTimeFilterKey, "")
  }, [topFiltersToSearchParam])
  let {addConfig, getConfig} = React.useContext(UserPrefContext.userPrefContext)
  let fetchApi = AuthHooks.useApiFetcher()

  let (statusDict, setStatusDict) = React.useState(_ => Js.Dict.empty())
  let addLogsAroundFetch = EulerAnalyticsLogUtils.useAddLogsAroundFetch()
  let (sankeyLoading, setSankeyLoading) = React.useState(_ => true)
  let (sankeyFetchedData, setSankeyFetchedData) = React.useState(_ => None)
  let (sankeyLoaderType, setSankeyLoaderType) = React.useState(_ => AnalyticsUtils.Shimmer)

  let (tableData, setTableData) = React.useState(_ => None)
  let (tableInfoData, setTableInfoData) = React.useState(_ => Js.Json.object_(Js.Dict.empty()))
  let (tableLoaderType, setTableLoaderType) = React.useState(_ => AnalyticsUtils.Shimmer)

  let defaultTableColumn = React.useMemo0(() => {
    let defaultColumnsFromPref = switch getConfig(tableSelectedColumnUserPrefKey) {
    | Some(jsonVal) => jsonVal->LogicUtils.getStrArryFromJson
    | None => []
    }

    let defaultColumnFromUserPref = defaultTableColumn->Belt.Array.keepMap(item => {
      let getHeadingType = item->getHeading
      let key = getHeadingType.key
      defaultColumnsFromPref->Js.Array2.includes(key) ? Some(item) : None
    })

    if defaultColumnFromUserPref->Js.Array2.length === 0 {
      defaultTableColumn
    } else {
      defaultColumnFromUserPref
    }
  })

  let newDefaultCols = React.useMemo1(() => {
    activeTabState
    ->Belt.Option.getWithDefault([])
    ->Belt.Array.keepMap(item => {
      allMetricColumn
      ->Belt.Array.keepMap(
        columnItem => {
          let val = columnItem->getHeading
          val.key === item ? Some(columnItem) : None
        },
      )
      ->Belt.Array.get(0)
    })
    ->Belt.Array.concat(defaultTableColumn)
  }, [activeTabState->Belt.Option.getWithDefault([])->Js.Array2.joinWith("-")])

  let newAllCols = React.useMemo1(() => {
    allMetricColumn
    ->Belt.Array.keepMap(item => {
      let val = item->getHeading
      activeTabState->Belt.Option.getWithDefault([])->Js.Array2.includes(val.key)
        ? Some(item)
        : None
    })
    ->Belt.Array.concat(allColumns)
  }, [activeTabState->Belt.Option.getWithDefault([])->Js.Array2.joinWith("-")])

  let transactionTableDefaultCols = React.useMemo2(() => {
    Recoil.atom(.
      `${moduleName}${moduleNamePrefix}DefaultCols${activeTabState
        ->Belt.Option.getWithDefault([])
        ->Js.Array2.joinWith("-")}`,
      newDefaultCols,
    )
  }, (
    newDefaultCols,
    `${moduleName}DefaultCols${activeTabState
      ->Belt.Option.getWithDefault([])
      ->Js.Array2.joinWith("-")}`,
  ))

  let visibleColumns = Recoil.useRecoilValueFromAtom(transactionTableDefaultCols)

  React.useEffect1(() => {
    let visibleColumnsUpdated =
      visibleColumns
      ->Belt.Array.keepMap(item => {
        let item = item->getHeading
        let itemKey = item.key
        activeTabState->Belt.Option.getWithDefault([])->Js.Array2.includes(itemKey)
          ? None
          : Some(itemKey->Js.Json.string)
      })
      ->Js.Json.array
    addConfig(tableSelectedColumnUserPrefKey, visibleColumnsUpdated)
    None
  }, [visibleColumns])

  let deltaPrefixArr = switch analyticsTableEntity {
  | {colDependentDeltaPrefixArr} =>
    visibleColumns->Belt.Array.keepMap(item => item->colDependentDeltaPrefixArr)
  | {deltaPrefixArr} => deltaPrefixArr
  }

  let tableOverallBodyEntity: AnalyticsUtils.tableApiBodyEntity = {
    startTimeFromUrl,
    endTimeFromUrl,
    ?filterValueFromUrl,
    deltaMetrics,
    isIndustry,
    deltaPrefixArr,
    tableMetrics,
    ?mode,
    customFilter,
    moduleName,
    showDeltaMetrics: false,
    source,
  }

  let overallBody = switch analyticsTableEntity {
  | {tableSummaryBody} => tableSummaryBody(tableOverallBodyEntity)
  | _ => AnalyticsUtils.generateTablePayloadFromEntity(tableOverallBodyEntity)
  }

  let tableApiBodyEntity = {
    ...tableOverallBodyEntity,
    currenltySelectedTab: ?activeTab,
    ?distributionArray,
    showDeltaMetrics: showDelta,
  }
  let tableBody = switch analyticsTableEntity {
  | {tableBodyEntity} => tableBodyEntity(tableApiBodyEntity)
  | _ => AnalyticsUtils.generateTablePayloadFromEntity(tableApiBodyEntity)
  }

  let (updatedCell, showDeltaToggleUi) = switch analyticsTableEntity {
  | {getUpdatedCell} => (
      getUpdatedCell(tableApiBodyEntity),
      Some(InputFields.boolInput(~input=showDeltaInput, ~placeholder="", ~isDisabled=false)),
    )
  | {tableEntity} => (tableEntity.getCell, None)
  }

  React.useEffect5(() => {
    // overall values in table header
    setShowTableHeaderLoading(_ => true)
    setSankeyLoading(_ => true)
    setTableInfoData(_ => Js.Json.object_(Js.Dict.empty()))
    if startTimeFromUrl !== "" && endTimeFromUrl !== "" && parentToken->Belt.Option.isSome {
      fetchApi(
        tableEntity.uri,
        ~method_=Post,
        ~bodyStr=overallBody,
        ~authToken=parentToken,
        ~headers=[("QueryType", "TableInfo")]->Js.Dict.fromArray,
        (),
      )
      ->addLogsAroundFetch(~logTitle="Table info Data Api", ~setStatusDict)
      ->thenResolve(json => {
        setTableInfoData(_ => json)
        setShowTableHeaderLoading(_ => false)
      })
      ->catch(_err => {
        setTableInfoData(_ => Js.Json.object_(Js.Dict.empty()))
        setShowTableHeaderLoading(_ => false)
        resolve()
      })
      ->ignore
    }
    None
  }, (
    topFiltersToSearchParam,
    parentToken,
    customFilter,
    mode,
    deltaPrefixArr->Js.Array2.joinWith(""),
  ))
  React.useEffect6(() => {
    setTableLoading(_ => true)
    setSankeyLoading(_ => true)
    if (
      startTimeFromUrl !== "" &&
      endTimeFromUrl !== "" &&
      parentToken->Belt.Option.isSome &&
      activeTab->Belt.Option.isSome
    ) {
      fetchApi(
        tableEntity.uri,
        ~method_=Post,
        ~bodyStr=tableBody,
        ~authToken=parentToken,
        ~headers=[("QueryType", "TableSankey")]->Js.Dict.fromArray,
        (),
      )
      ->addLogsAroundFetch(~logTitle="Table and Sankey Data Api", ~setStatusDict)
      ->thenResolve(json => {
        setActiveTabState(_ => activeTab)
        setTableData(_ => json->Some)
        if !consumeSankeyFetchedData {
          setSankeyFetchedData(
            _ => Some(
              json->getDictFromJsonObject->getJsonObjectFromDict("queryData")->getArrayFromJson([]),
            ),
          )
        }
        setSankeyLoading(_ => false)
        setTableLoading(_ => false)
      })
      ->catch(_err => {
        setActiveTabState(_ => activeTab)
        setTableData(_ => Js.Json.object_(Js.Dict.empty())->Some)
        if !consumeSankeyFetchedData {
          setSankeyFetchedData(_ => Some([]))
        }
        setSankeyLoading(_ => false)
        setTableLoading(_ => false)
        resolve()
      })
      ->ignore
    }
    None
  }, (
    topFiltersToSearchParam,
    `${activeTabStr}${deltaPrefixArr->Js.Array2.joinWith("")}`,
    parentToken,
    customFilter,
    mode,
    showDelta,
  ))

  let tableEntity = React.useMemo3(() => {
    let data = tableInfoData->getDictFromJsonObject
    let tableInfoDesc =
      tableData->Belt.Option.getWithDefault(Js.Json.object_(Js.Dict.empty()))->getDictFromJsonObject
    let value = data->getJsonObjectFromDict("queryData")->getTransactionTable->Belt.Array.get(0)
    let metaData =
      tableInfoDesc->getArrayFromDict("metaData", [])->AnalyticsUtils.deltaTimeRangeMapper

    let getHeading = switch tableUpdatedHeading {
    | Some(tableUpdatedHeading) => tableUpdatedHeading(~item=value, ~dateObj=Some(metaData), ~mode)
    | None => getHeading
    }

    {
      ...tableEntity,
      getHeading,
      getCell: updatedCell,
    }
  }, (tableInfoData, showDelta, tableData))
  let sampleAiBodyMaker =
    analyticsTableEntity.sampleApiBody->Belt.Option.getWithDefault(AnalyticsUtils.sampleApiBody)
  let sampleApiBody = {...tableApiBodyEntity, ?filterValueFromUrl}
  let dict = sampleAiBodyMaker(sampleApiBody)

  React.useEffect1(() => {
    setDefaultFilter(._ => dict)
    None
  }, [dict])

  // sankey fetch
  React.useEffect4(() => {
    setSankeyLoading(_ => true)
    switch sankeyEntity {
    | Some(sankeyEntity) =>
      if sankeyEntity.fetchData {
        if startTimeFromUrl !== "" && endTimeFromUrl !== "" && parentToken->Belt.Option.isSome {
          fetchApi(
            sankeyEntity.uri,
            ~method_=Post,
            ~bodyStr=[
              AnalyticsUtils.getFilterRequestBody(
                ~groupByNames=sankeyEntity.groupByNames,
                ~filter=filterValueFromUrl,
                ~metrics=sankeyEntity.sankeyMetrics,
                ~delta=false,
                ~mode,
                ~startDateTime=startTimeFromUrl,
                ~endDateTime=endTimeFromUrl,
                ~customFilter,
                ~source=sankeyEntity.source,
                (),
              )->Js.Json.object_,
            ]
            ->Js.Json.array
            ->Js.Json.stringify,
            ~authToken=parentToken,
            ~headers=[("QueryType", "Sankey")]->Js.Dict.fromArray,
            (),
          )
          ->addLogsAroundFetch(~logTitle="Sankey Data Api")
          ->thenResolve(json => {
            setSankeyFetchedData(
              _ => Some(
                json
                ->getDictFromJsonObject
                ->getJsonObjectFromDict("queryData")
                ->getArrayFromJson([]),
              ),
            )

            setSankeyLoading(_ => false)
          })
          ->catch(_err => {
            setSankeyFetchedData(_ => Some([]))
            setSankeyLoading(_ => false)
            resolve()
          })
          ->ignore
        }
      }

    | None => ()
    }

    None
  }, (sankeyEntity, topFiltersToSearchParam, customFilter, mode))

  let (sankeyLevels, startNodeLable, endNodeLable) = React.useMemo2(() => {
    switch sankeyEntity {
    | Some(sankeyEntity) =>
      sankeyEntity.fetchData
        ? (sankeyEntity.groupByNames, sankeyEntity.startNodeLable, sankeyEntity.endNodeLable)
        : (activeTabState, "Total Volume", "Status")
    | None => (activeTabState, "Total Volume", "Status")
    }
  }, (activeTabState, sankeyEntity))

  let tableDataLoading = {tableLoading || tableHeaderLoading}
  React.useEffect2(() => {
    if tableData !== None && tableDataLoading === false {
      setTableLoaderType(_ => SideLoader)
    }
    None
  }, (tableData, tableDataLoading))
  React.useEffect3(() => {
    if sankeyFetchedData !== None && (sankeyLoading || tableDataLoading) == false {
      setSankeyLoaderType(_ => SideLoader)
    }
    None
  }, (sankeyFetchedData, tableDataLoading, sankeyLoading))

  let tableSankeyUi = () => {
    [
      {
        if statusDict->Js.Dict.values->Js.Array2.includes(504) {
          <AnalyticsUtils.NoDataFoundPage />
        } else {
          <Form>
            <BaseTableComponent
              filters=(startTimeFromUrl, endTimeFromUrl)
              text
              tableData={tableData->Belt.Option.getWithDefault(Js.Json.object_(Js.Dict.empty()))}
              tableDataLoading
              transactionTableDefaultCols
              defaultSort
              newDefaultCols
              newAllCols
              tableEntity
              getTransactionTable
              colMapper
              tableGlobalFilter
              activeTab={activeTabState->Belt.Option.getWithDefault([])}
              ?showDeltaToggleUi
              loaderType=tableLoaderType
            />
          </Form>
        }
      },
      {
        switch sankeyEntity {
        | Some(sankeyEntity) =>
          <Form>
            <SankeyWithDropDown
              data={sankeyFetchedData->Belt.Option.getWithDefault([])}
              activeTab={sankeyLevels->Belt.Option.getWithDefault([])}
              dataLoading={sankeyLoading}
              sankeyConfig=sankeyEntity.sankeyMetricsConfig
              startNodeLable
              endNodeLable
              loaderType=sankeyLoaderType
            />
          </Form>
        | None => React.null
        }
      },
    ]
  }
  tableSankeyUi
}

module TabDetails = {
  @react.component
  let make = (
    ~chartEntity: DynamicChart.entity,
    ~activeTab,
    ~sankeyEntity: option<SankeyCharts.sankeyEntity>,
    ~colMapper: 'colType => string,
    ~modeKey=?,
    ~moduleName,
    ~updateUrl: Js.Dict.t<string> => unit,
    ~text="Summary Table",
    ~analyticsTableEntity: option<AnalyticsUtils.analyticsTableEntity<'colType, 't>>,
  ) => {
    let tableSankeyWrapper = useTableSankeyWrapper()

    <div className="h-full mt-4">
      <DynamicChart
        entity=chartEntity selectedTab=activeTab ?modeKey chartId=moduleName updateUrl
      />
      {switch analyticsTableEntity {
      | Some(analyticsTableEntity) =>
        <div className="h-full -mx-4 mt-4 overflow-scroll">
          {tableSankeyWrapper(~sankeyEntity, ~colMapper, ~text, ~analyticsTableEntity)->React.array}
        </div>
      | None => React.null
      }}
    </div>
  }
}

module ParentAnalyticsComponentV1 = {
  @react.component
  let make = (
    ~chartEntity as _: DynamicChart.entity,
    ~sankeyEntity as _: option<SankeyCharts.sankeyEntity>=?,
    ~tabValues as _: array<DynamicTabs.tab>,
    ~colMapper as _: 'colType => string,
    ~stepsForModule=[],
    ~modeKey as _: option<string>=?,
    ~analyticsTableEntity as _: option<AnalyticsUtils.analyticsTableEntity<'colType, 't>>=?,
    ~children=React.null,
    ~totalVolume=0,
    ~setTotalVolume=_ => (),
  ) => {
    let {filterValue} = React.useContext(AnalyticsUrlUpdaterContext.urlUpdaterContext)
    let isMobileView = MatchMedia.useMobileChecker()

    let getModuleFilters = UrlUtils.useGetFilterDictFromUrl("")

    let {parentAuthInfo} = React.useContext(TokenContextProvider.tokenContext)

    let authInfo = switch parentAuthInfo {
    | Some(info) => info
    | None => HyperSwitchAuthTypes.getDummyAuthInfoForToken("")
    }

    let updateComponentPrefrences = UrlUtils.useUpdateUrlWith(~prefix="")

    React.useEffect1(() => {
      updateComponentPrefrences(~dict=filterValue)
      None
    }, [filterValue])

    // as there should be always date and mode so added this condition
    if getModuleFilters->Js.Dict.entries->Js.Array2.length > 0 && authInfo.token !== "" {
      <div
        className={`flex flex-col h-full gap-4 relative ${isMobileView ? "overflow-scroll" : ""}`}>
        // case when no filters but download data is required
        <div className={`flex flex-col pb-5 ${isMobileView ? "" : "overflow-scroll"}`}>
          <div> {children} </div>
        </div>
      </div>
    } else {
      React.null
    }
  }
}

module ParentAnalyticsComponentNew = {
  @react.component
  let make = (~stepsForModule=[], ~domain="txns", ~children=React.null, ~totalVolume=0) => {
    let {filterValue} = React.useContext(AnalyticsUrlUpdaterContext.urlUpdaterContext)
    let isMobileView = MatchMedia.useMobileChecker()

    let getModuleFilters = UrlUtils.useGetFilterDictFromUrl("")

    let {parentAuthInfo} = React.useContext(TokenContextProvider.tokenContext)

    let authInfo = switch parentAuthInfo {
    | Some(info) => info
    | None => HyperSwitchAuthTypes.getDummyAuthInfoForToken("")
    }

    let updateComponentPrefrences = UrlUtils.useUpdateUrlWith(~prefix="")

    React.useEffect1(() => {
      updateComponentPrefrences(~dict=filterValue)
      None
    }, [filterValue])

    // as there should be always date and mode so added this condition
    if getModuleFilters->Js.Dict.entries->Js.Array2.length > 0 && authInfo.token !== "" {
      <div
        className={`flex flex-col h-full gap-4 relative ${isMobileView ? "overflow-scroll" : ""}`}>
        // case when no filters but download data is required
        <div className={`flex flex-col pb-5 ${isMobileView ? "" : "overflow-x-hidden"}`}>
          <div> {children} </div>
        </div>
      </div>
    } else {
      React.null
    }
  }
}

module OnCellClickDistribution = {
  @react.component
  let make = (
    ~valDict,
    ~value="Click to view",
    ~tabValues: array<DynamicTabs.tab>,
    ~domain: string,
    ~customFilterKey: option<string>=?,
    ~summaryTableOnClickEntity,
    ~filterByData,
    ~metrics,
    ~groupBy,
    ~defSort: Table.sortedObject,
    ~defaultFiltersToModal=?,
  ) => {
    let (showTableModal, setShowTableModal) = React.useState(_ => false)
    let (modalHeading, setModalHeading) = React.useState(_ => "")
    let (defaultFilter, _) = Recoil.useRecoilState(AnalyticsHooks.defaultFilter)
    let {filterValue} = React.useContext(AnalyticsUrlUpdaterContext.urlUpdaterContext)
    let defaultFilterDict = defaultFilter->safeParse->getDictFromJsonObject
    let activeTab =
      defaultFilterDict
      ->getArrayFromDict("activeTab", [])
      ->Js.Array2.map(key => {
        key->getStringFromJson("")
      })

    let defaultFilters = defaultFilterDict->getJsonObjectFromDict("filter")->getDictFromJsonObject
    let dictKeys = valDict->Js.Dict.keys
    let filters = defaultFilters->getJsonObjectFromDict("filters")->getDictFromJsonObject
    let filterKeys = filters->Js.Dict.keys
    let getTitle = key => {
      (
        tabValues
        ->Js.Array2.filter(item => {
          item.value == key
        })
        ->Belt.Array.get(0)
        ->Belt.Option.getWithDefault({title: "", value: "", isRemovable: false})
      ).title
    }

    activeTab->Js.Array2.forEach(key => {
      if !(filterKeys->Js.Array2.includes(key)) {
        filterKeys->Js.Array2.push(key)->ignore
      }
    })
    filterKeys->Js.Array2.forEach(key => {
      let value = valDict->getString(key, "")
      if dictKeys->Js.Array2.includes(key) && value !== "" {
        filters->Js.Dict.set(key, [value->Js.Json.string]->Js.Json.array)
      }
    })
    let currentCustomFilterValue = switch customFilterKey {
    | Some(customFilterKey) =>
      filterValue->Js.Dict.get(customFilterKey)->Belt.Option.getWithDefault("")
    | None => ""
    }

    defaultFilters->Js.Dict.set("filters", filters->Js.Json.object_)
    if currentCustomFilterValue !== "" {
      defaultFilters->Js.Dict.set("customFilter", currentCustomFilterValue->Js.Json.string)
    }

    let valStr =
      activeTab
      ->Js.Array2.map(key => {
        valDict->getJsonObjectFromDict(key)
      })
      ->Js.Array2.joinWith(", ")

    let keyStr = activeTab->Js.Array2.map(getTitle)->Js.Array2.joinWith(", ")

    let heading = `${keyStr} : ${valStr}`
    let search_class = "text-gray-400 dark:text-gray-600"
    let searchTable = FormRenderer.makeFieldInfo(
      ~label="",
      ~name="searchTable",
      ~placeholder="Search ",
      ~customInput=InputFields.textInput(
        ~customStyle="w-64",
        ~autoComplete="off",
        ~leftIcon=<Icon size=16 className=search_class name="search" />,
        (),
      ),
      (),
    )

    let onClick = _ => {
      setShowTableModal(_ => true)
      setModalHeading(_ => heading)
    }
    <>
      <div
        className="px-2 py-0.5 fira-code text-fs-13 font-normal text-sky-500 cursor-pointer"
        onClick>
        {React.string(`${value}`)}
      </div>
      {if showTableModal {
        <Modal
          modalHeading
          headingClass="!bg-transparent dark:!bg-jp-gray-lightgray_background"
          showModal=showTableModal
          closeOnOutsideClick=true
          setShowModal=setShowTableModal
          borderBottom=true
          modalClass="md:w-10/12 w-full md:mx-auto md:my-8 dark:!bg-jp-gray-lightgray_background p-4 pb-8 overflow-auto">
          <Form>
            <FormRenderer.FieldRenderer field=searchTable />
            <AnalyticsUtils.TableErrorModalContent
              defaultFilters
              domain
              filterByData
              summayTableEntity=summaryTableOnClickEntity
              metrics
              customFilterValue=currentCustomFilterValue
              groupBy
              defSort
              ?defaultFiltersToModal
            />
          </Form>
        </Modal>
      } else {
        React.null
      }}
    </>
  }
}
