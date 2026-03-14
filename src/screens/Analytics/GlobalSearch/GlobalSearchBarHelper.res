open LogicUtils
open GlobalSearchTypes
module RenderedComponent = {
  open String
  @react.component
  let make = (~ele, ~searchText) => {
    let defaultStyle = "font-medium text-fs-14 text-lightgray_background opacity-50"

    listOfMatchedText(ele, searchText)
    ->Array.mapWithIndex((item, index) => {
      let key = index->Int.toString
      let element = item->React.string

      if item->toLowerCase == searchText->toLowerCase && searchText->isNonEmptyString {
        <mark key className={`border-searched_text_border bg-yellow-searched_text ${defaultStyle}`}>
          element
        </mark>
      } else {
        <span key className=defaultStyle> element </span>
      }
    })
    ->React.array
  }
}

module SearchBox = {
  @react.component
  let make = (~openModalOnClickHandler) => {
    let iconBoxCss = "w-5 h-5 border border-gray-200 bg-white flex rounded-sm items-center justify-center cursor-pointer "
    let cmdIcon = Window.Navigator.platform->String.includes("Mac") ? "⌘" : "^"
    let shortcutIcons = {
      <>
        <div className="flex flex-row text-nd_gray-400 gap-1">
          <div className={`${iconBoxCss} `}> {cmdIcon->React.string} </div>
          <div className={`${iconBoxCss} text-xs`}> {"K"->React.string} </div>
        </div>
      </>
    }
    let isMobileView = MatchMedia.useMobileChecker()

    if isMobileView {
      <Icon size=14 name="search" className="mx-2" onClick={openModalOnClickHandler} />
    } else {
      <div
        className={`flex w-50 2xl:w-80 gap-2 items-center text-grey-800 text-opacity-40 font-semibold justify-between py-2 px-3 rounded-lg border border-jp-gray-border_gray hover:cursor-text shadow-sm bg-nd_gray-100`}
        onClick={openModalOnClickHandler}>
        <div className="flex gap-2 ">
          <Icon size=14 name="search" />
          <p className="hidden lg:inline-block text-sm font-medium"> {"Search"->React.string} </p>
        </div>
        <div className="text-semibold text-sm hidden md:block cursor-pointer"> shortcutIcons </div>
      </div>
    }
  }
}

module EmptyResult = {
  open FramerMotion.Motion
  @react.component
  let make = (~prefix, ~searchText) => {
    <Div layoutId="empty" initial={{scale: 0.9, opacity: 0.0}} animate={{scale: 1.0, opacity: 1.0}}>
      <div className="flex flex-col w-full h-fit p-7 justify-center items-center gap-6">
        <img alt="no-result" className="w-1/9" src={`${prefix}/icons/globalSearchNoResult.svg`} />
        <div className="w-3/5 text-wrap text-center break-all">
          {`No Results for " ${searchText} "`->React.string}
        </div>
      </div>
    </Div>
  }
}

module OptionWrapper = {
  @react.component
  let make = (~index, ~value, ~children, ~selectedOption, ~redirectOnSelect) => {
    let activeClass = value == selectedOption ? "bg-gray-100 rounded-lg" : ""

    <div
      onClick={_ => value->redirectOnSelect}
      className={`flex ${activeClass} flex-row truncate hover:bg-gray-100 cursor-pointer hover:rounded-lg p-2 group items-center`}
      key={index->Int.toString}>
      {children}
    </div>
  }
}

module ModalWrapper = {
  open FramerMotion.Motion
  @react.component
  let make = (~showModal, ~setShowModal, ~children) => {
    let borderRadius = ["15px", "15px", "15px", "15px"]

    <Modal
      showModal
      setShowModal
      modalClass="w-full md:w-7/12 lg:w-6/12 xl:w-6/12 2xl:w-4/12 mx-auto"
      paddingClass="pt-24"
      closeOnOutsideClick=true
      bgClass="bg-transparent dark:bg-transparent border-transparent dark:border-transparent shadow-transparent">
      <Div
        layoutId="search"
        key="search"
        initial={{borderRadius, scale: 0.9}}
        animate={{borderRadius, scale: 1.0}}
        className={"flex flex-col bg-white gap-2 overflow-hidden py-2 !show-scrollbar"}>
        {children}
      </Div>
    </Modal>
  }
}

module ShowMoreLink = {
  @react.component
  let make = (
    ~section: resultType,
    ~cleanUpFunction=() => {()},
    ~textStyleClass="",
    ~searchText,
  ) => {
    let totalCount = section.total_results

    let generateLink = (path, source) => {
      `${path}?query=${searchText}&source=${source}`
    }

    let onClick = _ => {
      let link = switch section.section {
      | PaymentAttempts => generateLink("payment-attempts", "payment_attempts")
      | SessionizerPaymentAttempts =>
        generateLink("payment-attempts", "sessionizer_payment_attempts")
      | PaymentIntents => generateLink("payment-intents", "payment_intents")
      | SessionizerPaymentIntents => generateLink("payment-intents", "sessionizer_payment_intents")
      | Payouts => generateLink("payouts-global", "payouts")
      | PayoutAttempts => generateLink("payout-attempts", "payout_attempts")
      | Refunds => generateLink("refunds-global", "refunds")
      | SessionizerPaymentRefunds => generateLink("refunds-global", "sessionizer_refunds")
      | Disputes => generateLink("dispute-global", "disputes")
      | SessionizerPaymentDisputes => generateLink("dispute-global", "sessionizer_disputes")
      | Local
      | Others
      | Default => ""
      }
      GlobalVars.appendDashboardPath(~url=link)->RescriptReactRouter.push
      cleanUpFunction()
    }

    <RenderIf condition={totalCount > 10}>
      {
        let suffix = totalCount > 1 ? "s" : ""
        let linkText = `View ${totalCount->Int.toString} result${suffix}`

        switch section.section {
        | SessionizerPaymentAttempts
        | SessionizerPaymentIntents
        | SessionizerPaymentRefunds
        | SessionizerPaymentDisputes
        | PaymentAttempts
        | PaymentIntents
        | Payouts
        | PayoutAttempts
        | Refunds
        | Disputes =>
          <div
            onClick
            className={`font-medium cursor-pointer underline underline-offset-2 opacity-50 ${textStyleClass}`}>
            {linkText->React.string}
          </div>
        | Local
        | Default
        | Others => React.null
        }
      }
    </RenderIf>
  }
}

module KeyValueFilter = {
  open GlobalSearchBarUtils
  @react.component
  let make = (~filter) => {
    let itemValue =
      filter.categoryType
      ->getcategoryFromVariant
      ->String.toLocaleLowerCase

    <div className="font-medium px-2 py-1">
      {`Enter ${itemValue} (e.g.,${filter.placeholder})`->React.string}
    </div>
  }
}

module FilterOption = {
  @react.component
  let make = (~onClick, ~value, ~placeholder=None, ~filter, ~selectedFilter=None, ~viewType) => {
    let activeBg = "bg-gray-200"
    let wrapperBg = "bg-gray-400/40"
    let rounded = "rounded-lg"

    let (activeWrapperClass, activeClass) = switch selectedFilter {
    | Some(val) =>
      filter == val
        ? (`${activeBg} ${rounded}`, `${wrapperBg}`)
        : (`hover:${activeBg} hover:${rounded}`, `hover:${wrapperBg} ${activeBg}`)
    | None => (`hover:${activeBg} hover:${rounded} `, `hover:${wrapperBg} ${activeBg}`)
    }

    switch viewType {
    | FiltersSugsestions =>
      <div
        className={`flex justify-between p-2 group items-center cursor-pointer ${activeWrapperClass}`}
        onClick>
        <div className={`${activeClass} py-1 px-2 rounded-md flex gap-1 items-center w-fit`}>
          <span className="font-medium text-sm"> {value->React.string} </span>
        </div>
        <RenderIf condition={placeholder->Option.isSome}>
          <div className="text-sm opacity-70"> {placeholder->Option.getOr("")->React.string} </div>
        </RenderIf>
      </div>
    | _ =>
      <span
        className={`${activeClass} py-1 px-2 rounded-md flex gap-1 items-center w-fit cursor-pointer font-medium text-sm`}
        onClick>
        {value->React.string}
      </span>
    }
  }
}

module NoResults = {
  @react.component
  let make = () => {
    <div className="text-sm p-2"> {"No Results"->React.string} </div>
  }
}

module FilterResultsComponent = {
  open GlobalSearchBarUtils
  open FramerMotion.Motion
  @react.component
  let make = (
    ~categorySuggestions: array<categoryOption>,
    ~activeFilter,
    ~searchText,
    ~setAllFilters,
    ~selectedFilter,
    ~setSelectedFilter,
    ~onFilterClicked,
    ~onSuggestionClicked,
    ~viewType=FiltersSugsestions,
  ) => {
    let filterKey = activeFilter->String.split(filterSeparator)->getValueFromArray(0, "")

    let filters = categorySuggestions->Array.filter(category => {
      if activeFilter->isNonEmptyString {
        let categoryType = category.categoryType->getcategoryFromVariant
        if searchText->getEndChar == filterSeparator {
          `${categoryType}${filterSeparator}` == `${filterKey}${filterSeparator}`
        } else {
          categoryType->String.includes(filterKey)
        }
      } else {
        true
      }
    })

    let checkFilterKey = list => {
      switch list->Array.get(0) {
      | Some(value) =>
        value.categoryType->getcategoryFromVariant === filterKey && value.options->Array.length > 0
      | _ => false
      }
    }

    let updateAllFilters = () => {
      if filters->Array.length == 1 {
        switch filters->Array.get(0) {
        | Some(filter) =>
          if filter.options->Array.length > 0 && filters->checkFilterKey {
            let filterValue = activeFilter->String.split(filterSeparator)->getValueFromArray(1, "")

            let options = if filterValue->isNonEmptyString {
              filter.options->Array.filter(option => option->String.includes(filterValue))
            } else {
              filter.options
            }

            let newFilters = options->Array.map(option => {
              let value = {
                categoryType: filter.categoryType,
                options: [option],
                placeholder: filter.placeholder,
              }

              value
            })
            setAllFilters(_ => newFilters)
          } else {
            setAllFilters(_ => filters)
          }
        | _ => ()
        }
      } else {
        setAllFilters(_ => filters)
      }
    }

    React.useEffect(() => {
      updateAllFilters()
      None
    }, [activeFilter])

    React.useEffect(() => {
      setSelectedFilter(_ => None)
      None
    }, [filters->Array.length])

    let optionsFlexClass = viewType != FiltersSugsestions ? "flex flex-wrap gap-3 px-2 pt-2" : ""

    let filterOptions = index => {
      if viewType != FiltersSugsestions {
        index < sectionsViewResultsCount
      } else {
        true
      }
    }

    let isFreeTextKey = if filters->Array.length == 1 {
      switch filters->Array.get(0) {
      | Some(val) => val.options->Array.length == 0
      | None => false
      }
    } else {
      false
    }

    let sectionHeader = isFreeTextKey ? "" : "Suggested Filters"

    <RenderIf condition={filters->Array.length > 0}>
      <Div
        initial={{opacity: 0.5}}
        animate={{opacity: 0.5}}
        layoutId="categories-section"
        className="px-2 pt-2 border-t dark:border-jp-gray-960">
        <Div layoutId="categories-title" className="font-bold px-2">
          {sectionHeader->String.toUpperCase->React.string}
        </Div>
        <div>
          <RenderIf condition={filters->Array.length === 1 && filters->checkFilterKey}>
            <div className="h-full max-h-[450px] overflow-scroll sidebar-scrollbar">
              <style> {React.string(sidebarScrollbarCss)} </style>
              {switch filters->Array.get(0) {
              | Some(value) =>
                let filterValue =
                  activeFilter->String.split(filterSeparator)->getValueFromArray(1, "")

                let options = if filterValue->isNonEmptyString {
                  value.options->Array.filter(option => option->String.includes(filterValue))
                } else {
                  value.options
                }

                if options->Array.length > 0 {
                  <div className=optionsFlexClass>
                    {options
                    ->Array.filterWithIndex((_, index) => {
                      index->filterOptions
                    })
                    ->Array.map(option => {
                      let filter = {
                        categoryType: value.categoryType,
                        options: [option],
                        placeholder: value.placeholder,
                      }

                      let itemValue = `${value.categoryType
                        ->getcategoryFromVariant
                        ->String.toLocaleLowerCase} : ${option}`

                      <FilterOption
                        onClick={_ => option->onSuggestionClicked}
                        value=itemValue
                        filter
                        selectedFilter
                        viewType
                      />
                    })
                    ->React.array}
                  </div>
                } else {
                  <NoResults />
                }
              | _ => <NoResults />
              }}
            </div>
          </RenderIf>
          <RenderIf condition={!(filters->Array.length === 1 && filters->checkFilterKey)}>
            <div className=optionsFlexClass>
              {if isFreeTextKey {
                filters
                ->Array.map(filter => {
                  <KeyValueFilter filter />
                })
                ->React.array
              } else {
                filters
                ->Array.map(category => {
                  let itemValue = `${category.categoryType
                    ->getcategoryFromVariant
                    ->String.toLocaleLowerCase} ${filterSeparator} `
                  <FilterOption
                    onClick={_ => category->onFilterClicked}
                    value=itemValue
                    placeholder={Some(category.placeholder)}
                    filter={category}
                    selectedFilter
                    viewType
                  />
                })
                ->React.array
              }}
            </div>
          </RenderIf>
        </div>
      </Div>
    </RenderIf>
  }
}

module SearchResultsComponent = {
  open FramerMotion.Motion
  @react.component
  let make = (
    ~searchResults,
    ~searchText,
    ~setShowModal,
    ~selectedOption,
    ~redirectOnSelect,
    ~categorySuggestions,
    ~activeFilter,
    ~setAllFilters,
    ~selectedFilter,
    ~setSelectedFilter,
    ~onFilterClicked,
    ~onSuggestionClicked,
    ~viewType,
    ~prefix,
    ~filtersEnabled,
  ) => {
    <div className={"w-full overflow-auto text-base max-h-[60vh] focus:outline-none sm:text-sm "}>
      <RenderIf condition={filtersEnabled}>
        <FilterResultsComponent
          categorySuggestions
          activeFilter
          searchText
          setAllFilters
          selectedFilter
          onFilterClicked
          onSuggestionClicked
          setSelectedFilter
          viewType
        />
      </RenderIf>
      {switch viewType {
      | Load =>
        <div className="mb-24">
          <Loader />
        </div>
      | EmptyResult => <EmptyResult prefix searchText />
      | _ =>
        <Div className="mt-3 border-t" layoutId="border">
          {searchResults
          ->Array.mapWithIndex((section: resultType, index) => {
            <Div
              key={Int.toString(index)}
              layoutId={`${section.section->getSectionHeader} ${Int.toString(index)}`}
              className={`px-3 mb-3 py-1`}>
              <Div
                layoutId={`${section.section->getSectionHeader}-${index->Belt.Int.toString}`}
                className="text-lightgray_background  px-2 pb-1 flex justify-between ">
                <div className="font-bold opacity-50">
                  {section.section->getSectionHeader->String.toUpperCase->React.string}
                </div>
                <ShowMoreLink
                  section
                  cleanUpFunction={() => {setShowModal(_ => false)}}
                  textStyleClass="text-xs"
                  searchText
                />
              </Div>
              {section.results
              ->Array.mapWithIndex((item, i) => {
                let elementsArray = item.texts
                <OptionWrapper
                  key={Int.toString(i)} index={i} value={item} selectedOption redirectOnSelect>
                  {elementsArray
                  ->Array.mapWithIndex(
                    (item, index) => {
                      let elementValue = item->JSON.Decode.string->Option.getOr("")
                      <RenderIf
                        condition={elementValue->isNonEmptyString} key={index->Int.toString}>
                        <RenderedComponent ele=elementValue searchText />
                        <RenderIf condition={index >= 0 && index < elementsArray->Array.length - 1}>
                          <span className="mx-2 text-lightgray_background opacity-50">
                            {">"->React.string}
                          </span>
                        </RenderIf>
                      </RenderIf>
                    },
                  )
                  ->React.array}
                </OptionWrapper>
              })
              ->React.array}
            </Div>
          })
          ->React.array}
        </Div>
      }}
    </div>
  }
}

module ModalSearchBox = {
  open GlobalSearchBarUtils
  open FramerMotion.Motion
  open ReactEvent.Keyboard
  @react.component
  let make = (
    ~inputRef: React.ref<'a>,
    ~leftIcon,
    ~setShowModal,
    ~setFilterText,
    ~localSearchText,
    ~setLocalSearchText,
    ~allOptions,
    ~selectedOption,
    ~setSelectedOption,
    ~redirectOnSelect,
    ~allFilters,
    ~selectedFilter,
    ~setSelectedFilter,
    ~viewType,
    ~activeFilter,
    ~onFilterClicked,
    ~onSuggestionClicked,
    ~categorySuggestions,
    ~searchText,
  ) => {
    let (errorMessage, setErrorMessage) = React.useState(_ => "")

    let tabKey = 9
    let arrowDown = 40
    let arrowUp = 38
    let enterKey = 13
    let spaceKey = 32

    let input: ReactFinalForm.fieldRenderPropsInput = {
      {
        name: "global_search",
        onBlur: _ => (),
        onChange: ev => {
          let value = {ev->ReactEvent.Form.target}["value"]
          setLocalSearchText(_ => value)
        },
        onFocus: _ => (),
        value: localSearchText->JSON.Encode.string,
        checked: false,
      }
    }

    let getNextIndex = (selectedIndex, options) => {
      let count = options->Array.length
      selectedIndex == count - 1 ? 0 : Int.mod(selectedIndex + 1, count)
    }
    let getPrevIndex = (selectedIndex, options) => {
      let count = options->Array.length
      selectedIndex === 0 ? count - 1 : Int.mod(selectedIndex - 1, count)
    }

    let tabKeyPressHandler = e => {
      revertFocus(~inputRef)

      let keyPressed = e->keyCode

      switch viewType {
      | EmptyResult | Load => ()
      | Results => {
          let index = allOptions->Array.findIndex(item => {
            item == selectedOption
          })

          if keyPressed == tabKey {
            let newIndex = getNextIndex(index, allOptions)
            switch allOptions->Array.get(newIndex) {
            | Some(val) => setSelectedOption(_ => val)
            | _ => ()
            }
          }
        }
      | FiltersSugsestions => {
          let index = allFilters->Array.findIndex(item => {
            switch selectedFilter {
            | Some(val) => item == val
            | _ => false
            }
          })

          if keyPressed == tabKey {
            let newIndex = getNextIndex(index, allFilters)
            switch allFilters->Array.get(newIndex) {
            | Some(val) => setSelectedFilter(_ => val->Some)
            | _ => ()
            }
          }
        }
      }
    }

    React.useEffect(() => {
      Window.addEventListener("keydown", tabKeyPressHandler)
      Some(() => Window.removeEventListener("keydown", tabKeyPressHandler))
    }, (selectedFilter, selectedOption))

    let handleKeyDown = e => {
      let keyPressed = e->keyCode

      switch viewType {
      | Results => {
          let index = allOptions->Array.findIndex(item => {
            item == selectedOption
          })

          if keyPressed == arrowDown {
            let newIndex = getNextIndex(index, allOptions)
            switch allOptions->Array.get(newIndex) {
            | Some(val) => setSelectedOption(_ => val)
            | _ => ()
            }
          } else if keyPressed == arrowUp {
            let newIndex = getPrevIndex(index, allOptions)
            switch allOptions->Array.get(newIndex) {
            | Some(val) => setSelectedOption(_ => val)
            | _ => ()
            }
          } else if keyPressed == enterKey {
            selectedOption->redirectOnSelect
          }
        }

      | FiltersSugsestions => {
          let index = allFilters->Array.findIndex(item => {
            switch selectedFilter {
            | Some(val) => item == val
            | _ => false
            }
          })

          if keyPressed == arrowDown {
            let newIndex = getNextIndex(index, allFilters)
            switch allFilters->Array.get(newIndex) {
            | Some(val) => setSelectedFilter(_ => val->Some)
            | _ => ()
            }
          } else if keyPressed == arrowUp {
            let newIndex = getPrevIndex(index, allFilters)
            switch allFilters->Array.get(newIndex) {
            | Some(val) => setSelectedFilter(_ => val->Some)
            | _ => ()
            }
          } else if keyPressed == enterKey {
            switch selectedFilter {
            | Some(filter) =>
              if activeFilter->String.includes(filterSeparator) {
                switch filter.options->Array.get(0) {
                | Some(val) => val->onSuggestionClicked
                | _ => ()
                }
              } else {
                filter->onFilterClicked
              }
            | _ => ()
            }
          }
        }

      | EmptyResult | Load => ()
      }

      if keyPressed == spaceKey {
        setFilterText("")
      } else {
        let values = localSearchText->String.split(" ")
        let filter = values->getValueFromArray(values->Array.length - 1, "")
        if activeFilter !== filter {
          setFilterText(filter)
        }
      }
    }

    let filterKey = activeFilter->String.split(filterSeparator)->getValueFromArray(0, "")

    let filters = categorySuggestions->Array.filter(category => {
      if activeFilter->isNonEmptyString {
        let categoryType = category.categoryType->getcategoryFromVariant
        if searchText->getEndChar == filterSeparator {
          `${categoryType}${filterSeparator}` == `${filterKey}${filterSeparator}`
        } else {
          categoryType->String.includes(filterKey)
        }
      } else {
        true
      }
    })

    let validateForm = _ => {
      let errors = Dict.make()
      if localSearchText->validateQuery && filters->Array.length == 0 {
        setErrorMessage(_ =>
          "Only one free-text search is allowed and additional text will be ignored."
        )
      } else if !(localSearchText->validateQuery) {
        setErrorMessage(_ => "")
      }
      errors->JSON.Encode.object
    }

    let textColor = errorMessage->isNonEmptyString ? "text-red-900" : "text-jp-gray-900"

    <Form
      key="global-search"
      initialValues={Dict.make()->JSON.Encode.object}
      validate={values => values->validateForm}
      onSubmit={(_, _) => Nullable.null->Promise.resolve}>
      <LabelVisibilityContext showLabel=false>
        <FormRenderer.FieldRenderer
          field={FormRenderer.makeFieldInfo(
            ~label="",
            ~name="global_search",
            ~customInput=(~input as _, ~placeholder as _) => {
              <Div layoutId="input" className="h-fit bg-white">
                <div className={`flex flex-row items-center `}>
                  {leftIcon}
                  <div className="w-full overflow-scroll flex flex-row items-center">
                    <input
                      ref={inputRef->ReactDOM.Ref.domRef}
                      autoComplete="off"
                      autoFocus=true
                      placeholder="Search"
                      className={`w-full pr-2 pl-2 ${textColor} text-opacity-75 focus:text-opacity-100  placeholder-jp-gray-900  focus:outline-none rounded  h-10 text-lg font-normal  placeholder-opacity-50 `}
                      name={input.name}
                      label="No"
                      value=localSearchText
                      type_="text"
                      checked={false}
                      onChange=input.onChange
                      onKeyUp=handleKeyDown
                    />
                  </div>
                  <div
                    className="bg-gray-200 py-1 px-2 rounded-md flex gap-1 items-center mr-5 cursor-pointer ml-2 opacity-70"
                    onClick={_ => {
                      setShowModal(_ => false)
                    }}>
                    <span className="opacity-40 font-bold text-sm"> {"Esc"->React.string} </span>
                    <Icon size=15 name="times" parentClass="flex justify-end opacity-30" />
                  </div>
                </div>
                <RenderIf condition={errorMessage->isNonEmptyString}>
                  <div className="text-sm text-red-900 ml-12 pl-2">
                    {errorMessage->React.string}
                  </div>
                </RenderIf>
              </Div>
            },
            ~isRequired=false,
          )}
        />
      </LabelVisibilityContext>
    </Form>
  }
}
