module RenderedComponent = {
  @react.component
  let make = (~ele, ~searchText) => {
    open LogicUtils

    listOfMatchedText(ele, searchText)
    ->Array.mapWithIndex((item, i) => {
      if (
        String.toLowerCase(item) == String.toLowerCase(searchText) && String.length(searchText) > 0
      ) {
        <mark
          key={i->Int.toString}
          className="border-searched_text_border bg-yellow-searched_text font-medium text-fs-14 text-lightgray_background opacity-50">
          {item->React.string}
        </mark>
      } else {
        <span
          key={i->Int.toString}
          className="font-medium text-fs-14 text-lightgray_background opacity-50">
          {item->React.string}
        </span>
      }
    })
    ->React.array
  }
}

module SearchBox = {
  @react.component
  let make = (~openModalOnClickHandler) => {
    let shortcutText = Window.Navigator.platform->String.includes("Mac") ? "Cmd + K" : "Ctrl + K"
    let isMobileView = MatchMedia.useMobileChecker()

    if isMobileView {
      <Icon size=14 name="search" className="mx-2" onClick={openModalOnClickHandler} />
    } else {
      <div
        className={`flex w-80 gap-2 items-center bg-white text-grey-700 text-opacity-30 font-semibold justify-between py-2 px-3 rounded-lg border border-jp-gray-border_gray hover:cursor-text`}
        onClick={openModalOnClickHandler}>
        <div className="flex gap-2 ">
          <Icon size=14 name="search" />
          <p className="hidden lg:inline-block text-sm"> {"Search"->React.string} </p>
        </div>
        <div className="text-semibold text-sm hidden md:block"> {shortcutText->React.string} </div>
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
    let activeClass = value == selectedOption ? "bg-gray-100 rounded-lg p-2 group items-center" : ""
    <div
      onClick={_ => {
        value->redirectOnSelect
      }}
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
        initial={{borderRadius: ["15px", "15px", "15px", "15px"], scale: 0.9}}
        animate={{borderRadius: ["15px", "15px", "15px", "15px"], scale: 1.0}}
        className={"flex flex-col bg-white gap-2 overflow-hidden py-2 !show-scrollbar"}>
        {children}
      </Div>
    </Modal>
  }
}

module ShowMoreLink = {
  open GlobalSearchTypes
  @react.component
  let make = (
    ~section: resultType,
    ~cleanUpFunction=() => {()},
    ~textStyleClass="",
    ~searchText,
  ) => {
    <RenderIf condition={section.total_results > 10}>
      {
        let linkText = `View ${section.total_results->Int.toString} result${section.total_results > 1
            ? "s"
            : ""}`

        switch section.section {
        | Local
        | Default
        | Others => React.null
        | SessionizerPaymentAttempts
        | SessionizerPaymentIntents
        | SessionizerPaymentRefunds
        | SessionizerPaymentDisputes
        | PaymentAttempts
        | PaymentIntents
        | Refunds
        | Disputes =>
          <div
            onClick={_ => {
              let link = switch section.section {
              | PaymentAttempts => `payment-attempts?query=${searchText}&domain=payment_attempts`
              | SessionizerPaymentAttempts =>
                `payment-attempts?query=${searchText}&domain=sessionizer_payment_attempts`
              | PaymentIntents => `payment-intents?query=${searchText}&domain=payment_intents`
              | SessionizerPaymentIntents =>
                `payment-intents?query=${searchText}&domain=sessionizer_payment_intents`
              | Refunds => `refunds-global?query=${searchText}&domain=refunds`
              | SessionizerPaymentRefunds =>
                `refunds-global?query=${searchText}&domain=sessionizer_refunds`
              | Disputes => `dispute-global?query=${searchText}&domain=disputes`
              | SessionizerPaymentDisputes =>
                `dispute-global?query=${searchText}&domain=sessionizer_disputes`
              | Local
              | Others
              | Default => ""
              }
              GlobalVars.appendDashboardPath(~url=link)->RescriptReactRouter.push
              cleanUpFunction()
            }}
            className={`font-medium cursor-pointer underline underline-offset-2 opacity-50 ${textStyleClass}`}>
            {linkText->React.string}
          </div>
        }
      }
    </RenderIf>
  }
}

module SearchResultsComponent = {
  open GlobalSearchTypes
  open LogicUtils
  open FramerMotion.Motion
  @react.component
  let make = (~searchResults, ~searchText, ~setShowModal, ~selectedOption, ~redirectOnSelect) => {
    let borderClass = searchResults->Array.length > 0 ? "border-t dark:border-jp-gray-960" : ""

    <div
      className={`w-full overflow-auto text-base max-h-[60vh] focus:outline-none sm:text-sm ${borderClass}`}>
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
                  <RenderIf condition={elementValue->isNonEmptyString} key={index->Int.toString}>
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
    </div>
  }
}

let sidebarScrollbarCss = `
  @supports (-webkit-appearance: none){
    .sidebar-scrollbar {
        scrollbar-width: auto;
        scrollbar-color: #8a8c8f;
      }
      
      .sidebar-scrollbar::-webkit-scrollbar {
        display: block;
        overflow: scroll;
        height: 4px;
        width: 5px;
      }
      
      .sidebar-scrollbar::-webkit-scrollbar-thumb {
        background-color: #8a8c8f;
        border-radius: 3px;
      }
      
      .sidebar-scrollbar::-webkit-scrollbar-track {
        display: none;
      }
}
  `

module FilterResultsComponent = {
  open LogicUtils
  open GlobalSearchTypes
  open GlobalSearchBarUtils
  open FramerMotion.Motion
  @react.component
  let make = (
    ~categorySuggestions: array<categoryOption>,
    ~activeFilter,
    ~setActiveFilter,
    ~searchText,
    ~setLocalSearchText,
  ) => {
    let filterKey = activeFilter->String.split(":")->getValueFromArray(0, "")
    let filters = categorySuggestions->Array.filter(category => {
      category.categoryType
      ->getcategoryFromVariant
      ->String.includes(filterKey)
    })

    let checkFilterKey = list => {
      switch list->Array.get(0) {
      | Some(value) =>
        value.categoryType->getcategoryFromVariant === filterKey && value.options->Array.length > 0
      | _ => false
      }
    }

    <RenderIf condition={filters->Array.length > 0}>
      <Div
        initial={{opacity: 0.5}}
        animate={{opacity: 0.5}}
        layoutId="categories-section"
        className="px-2 pt-2 border-t dark:border-jp-gray-960">
        <Div layoutId="categories-title" className="font-bold px-2">
          {"Suggested Filters"->String.toUpperCase->React.string}
        </Div>
        <div>
          <RenderIf condition={filters->Array.length === 1 && filters->checkFilterKey}>
            <div className="h-full max-h-[450px] overflow-scroll sidebar-scrollbar">
              <style> {React.string(sidebarScrollbarCss)} </style>
              {switch filters->Array.get(0) {
              | Some(value) =>
                value.options
                ->Array.map(option => {
                  <div
                    className="flex justify-between hover:bg-gray-100 cursor-pointer hover:rounded-lg p-2 group items-center"
                    onClick={_ => {
                      let saparater =
                        searchText->String.charAt(searchText->String.length - 1) == ":" ? "" : ":"
                      setLocalSearchText(_ => `${searchText}${saparater}${option}`)
                      setActiveFilter(_ => "")
                    }}>
                    <div className="bg-gray-200 py-1 px-2 rounded-md flex gap-1 items-center w-fit">
                      <span className="font-medium text-sm">
                        {`${value.categoryType
                          ->getcategoryFromVariant
                          ->String.toLocaleLowerCase} : ${option}`->React.string}
                      </span>
                    </div>
                  </div>
                })
                ->React.array
              | _ => React.null
              }}
            </div>
          </RenderIf>
          <RenderIf condition={!(filters->Array.length === 1 && filters->checkFilterKey)}>
            {filters
            ->Array.map(category => {
              <div
                className="flex justify-between hover:bg-gray-100 cursor-pointer hover:rounded-lg p-2 group items-center"
                onClick={_ => {
                  let newFilter = category.categoryType->getcategoryFromVariant
                  let lastString = searchText->String.charAt(searchText->String.length - 1)
                  if activeFilter->isNonEmptyString && lastString !== ":" {
                    let end = searchText->String.length - activeFilter->String.length
                    let newText = searchText->String.substring(~start=0, ~end)
                    setLocalSearchText(_ => `${newText} ${newFilter}:`)
                    setActiveFilter(_ => newFilter)
                  } else if lastString !== ":" {
                    setLocalSearchText(_ => `${searchText} ${newFilter}:`)
                    setActiveFilter(_ => newFilter)
                  }
                }}>
                <div className="bg-gray-200 py-1 px-2 rounded-md flex gap-1 items-center w-fit">
                  <span className="font-medium text-sm">
                    {`${category.categoryType
                      ->getcategoryFromVariant
                      ->String.toLocaleLowerCase} : `->React.string}
                  </span>
                </div>
                <div className="text-sm opacity-70"> {category.placeholder->React.string} </div>
              </div>
            })
            ->React.array}
          </RenderIf>
        </div>
      </Div>
    </RenderIf>
  }
}

module ModalSearchBox = {
  open LogicUtils
  open FramerMotion.Motion
  @react.component
  let make = (
    ~leftIcon,
    ~setShowModal,
    ~setFilterText,
    ~localSearchText,
    ~setLocalSearchText,
    ~allOptions,
    ~selectedOption,
    ~setSelectedOption,
    ~redirectOnSelect,
  ) => {
    let (errorMessage, setErrorMessage) = React.useState(_ => "")

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

    let handleKeyDown = e => {
      open ReactEvent.Keyboard

      let index = allOptions->Array.findIndex(item => {
        item == selectedOption
      })

      if e->keyCode == 40 {
        let newIndex =
          index == allOptions->Array.length - 1 ? 0 : Int.mod(index + 1, allOptions->Array.length)
        switch allOptions->Array.get(newIndex) {
        | Some(val) => setSelectedOption(_ => val)
        | _ => ()
        }
      } else if e->keyCode == 38 {
        let newIndex =
          index === 0 ? allOptions->Array.length - 1 : Int.mod(index - 1, allOptions->Array.length)
        switch allOptions->Array.get(newIndex) {
        | Some(val) => setSelectedOption(_ => val)
        | _ => ()
        }
      } else if e->keyCode == 13 {
        selectedOption->redirectOnSelect
      }

      if e->keyCode === 32 {
        setFilterText("")
      } else {
        let values = localSearchText->String.split(" ")
        let filter = values->getValueFromArray(values->Array.length - 1, "")
        setFilterText(filter)
      }
    }

    let validateForm = _values => {
      let errors = Dict.make()
      let lastChar = localSearchText->String.charCodeAt(localSearchText->String.length - 1)
      if localSearchText->GlobalSearchBarUtils.validateQuery && lastChar == 32.0 {
        setErrorMessage(_ => "Multiple free-text terms found")
      } else if !(localSearchText->GlobalSearchBarUtils.validateQuery) {
        setErrorMessage(_ => "")
      }
      errors->JSON.Encode.object
    }

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
                    <TextInput
                      input
                      autoFocus=true
                      placeholder="Search"
                      autoComplete="off"
                      onKeyUp=handleKeyDown
                      customStyle="bg-white border-none"
                      onActiveStyle="bg-white"
                      onHoverCss="bg-white"
                      inputStyle="!text-lg"
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
                  <div className="text-sm text-orange-500 ml-12 pl-2">
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
