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
  @react.component
  let make = (~prefix, ~searchText) => {
    <FramerMotion.Motion.Div
      layoutId="empty" initial={{scale: 0.9, opacity: 0.0}} animate={{scale: 1.0, opacity: 1.0}}>
      <div className="flex flex-col w-full h-fit p-7 justify-center items-center gap-6">
        <img alt="no-result" className="w-1/9" src={`${prefix}/icons/globalSearchNoResult.svg`} />
        <div className="w-3/5 text-wrap text-center break-all">
          {`No Results for " ${searchText} "`->React.string}
        </div>
      </div>
    </FramerMotion.Motion.Div>
  }
}

module OptionsWrapper = {
  open HeadlessUI
  @react.component
  let make = (~children) => {
    <FramerMotion.Motion.Div layoutId="options">
      <Combobox.Options
        static={true}
        className="w-full overflow-auto text-base max-h-[60vh] focus:outline-none sm:text-sm">
        {_ => {children}}
      </Combobox.Options>
    </FramerMotion.Motion.Div>
  }
}

module OptionWrapper = {
  open HeadlessUI
  @react.component
  let make = (~index, ~value, ~children) => {
    let activeClasses = isActive => {
      let borderClass = isActive ? "bg-gray-100 dark:bg-jp-gray-960" : ""
      `group flex items-center w-full p-2 text-sm rounded-lg ${borderClass}`
    }

    <Combobox.Option
      className="flex flex-row cursor-pointer truncate" key={index->Int.toString} value>
      {props => {
        <div className={props["active"]->activeClasses}> {children} </div>
      }}
    </Combobox.Option>
  }
}

module ModalWrapper = {
  @react.component
  let make = (~showModal, ~setShowModal, ~children) => {
    <Modal
      showModal
      setShowModal
      modalClass="w-full md:w-7/12 lg:w-6/12 xl:w-6/12 2xl:w-4/12 mx-auto"
      paddingClass="pt-24"
      closeOnOutsideClick=true
      bgClass="bg-transparent dark:bg-transparent border-transparent dark:border-transparent shadow-transparent">
      <FramerMotion.Motion.Div
        layoutId="search"
        key="search"
        initial={{borderRadius: ["15px", "15px", "15px", "15px"], scale: 0.9}}
        animate={{borderRadius: ["15px", "15px", "15px", "15px"], scale: 1.0}}
        className={"flex flex-col bg-white gap-2 overflow-hidden py-2 !show-scrollbar"}>
        {children}
      </FramerMotion.Motion.Div>
    </Modal>
  }
}

module SearchResultsComponent = {
  open GlobalSearchTypes
  open LogicUtils

  @react.component
  let make = (~searchResults, ~searchText, ~setShowModal) => {
    React.useEffect(() => {
      let onKeyPress = event => {
        let keyPressed = event->ReactEvent.Keyboard.key

        if keyPressed == "Enter" {
          let redirectLink = `/search?query=${searchText}`
          if redirectLink->isNonEmptyString {
            setShowModal(_ => false)
            GlobalVars.appendDashboardPath(~url=redirectLink)->RescriptReactRouter.push
          }
        }
      }
      Window.addEventListener("keydown", onKeyPress)
      Some(() => Window.removeEventListener("keydown", onKeyPress))
    }, [])

    <OptionsWrapper>
      {searchResults
      ->Array.mapWithIndex((section: resultType, index) => {
        let borderClass =
          index !== searchResults->Array.length - 1 ? "border-b-1 dark:border-jp-gray-960" : ""
        <FramerMotion.Motion.Div
          key={Int.toString(index)}
          layoutId={section.section->getSectionHeader}
          className={`px-3 mb-3 py-1 ${borderClass}`}>
          <FramerMotion.Motion.Div
            initial={{opacity: 0.5}}
            animate={{opacity: 0.5}}
            layoutId={`${section.section->getSectionHeader}-${index->Belt.Int.toString}`}
            className="text-lightgray_background  px-2 pb-1 flex justify-between">
            <div className="font-bold">
              {section.section->getSectionHeader->String.toUpperCase->React.string}
            </div>
            <div>
              <GlobalSearchBarUtils.ShowMoreLink
                section
                cleanUpFunction={() => {setShowModal(_ => false)}}
                textStyleClass="text-xs"
                searchText
              />
            </div>
          </FramerMotion.Motion.Div>
          {section.results
          ->Array.mapWithIndex((item, i) => {
            let elementsArray = item.texts

            <OptionWrapper key={Int.toString(i)} index={i} value={item}>
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
        </FramerMotion.Motion.Div>
      })
      ->React.array}
    </OptionsWrapper>
  }
}

module FilterResultsComponent = {
  open GlobalSearchTypes
  open GlobalSearchBarUtils
  @react.component
  let make = (~categorySuggestions: array<categoryOption>, ~searchText, ~setGlobalSearchText) => {
    let filters = categorySuggestions->Array.filter(category => {
      category.categoryType
      ->getcategoryFromVariant
      ->String.includes(searchText)
    })

    <FramerMotion.Motion.Div
      initial={{opacity: 0.5}}
      animate={{opacity: 0.5}}
      layoutId="categories-section"
      className="px-2 pb-1">
      <FramerMotion.Motion.Div layoutId="categories-title" className="font-bold px-2 pt-2">
        {"Suggested Filters"->String.toUpperCase->React.string}
      </FramerMotion.Motion.Div>
      <div className="">
        {filters
        ->Array.map(category => {
          <div
            className="flex justify-between hover:bg-gray-100 cursor-pointer hover:rounded-lg p-2 group items-center"
            onClick={_ => {
              setGlobalSearchText(`${searchText} ${category.categoryType->getcategoryFromVariant}:`)
            }}>
            <div
              className="bg-gray-300 py-1 px-2 rounded-md flex gap-1 items-center opacity-80 w-fit">
              <span className="font-bold text-sm">
                {`${category.categoryType
                  ->getcategoryFromVariant
                  ->String.toLocaleLowerCase} : `->React.string}
              </span>
            </div>
            <div className="text-sm opacity-70"> {category.placeholder->React.string} </div>
          </div>
        })
        ->React.array}
      </div>
    </FramerMotion.Motion.Div>
  }
}

module ModalSearchBox = {
  @react.component
  let make = (~leftIcon, ~setShowModal, ~setGlobalSearchText, ~searchText) => {
    let (searchText, setSearchText) = React.useState(_ => "")

    let input: ReactFinalForm.fieldRenderPropsInput = {
      {
        name: {"global_search"},
        onBlur: _ => (),
        onChange: ev => {
          let value = {ev->ReactEvent.Form.target}["value"]
          setSearchText(_ => value)
          //setGlobalSearchText(value)
        },
        onFocus: _ => (),
        value: JSON.Encode.string(searchText),
        checked: false,
      }
    }

    // let currentTags = React.useMemo(() => {
    //   input.value->JSON.Decode.array->Option.getOr([])->Belt.Array.keepMap(JSON.Decode.string)
    // }, [input.value])

    // let setTags = tags => {
    //   tags->Identity.arrayOfGenericTypeToFormReactEvent->input.onChange
    // }

    let handleKeyDown = e => {
      //open ReactEvent.Keyboard
      // let isEmpty = text->LogicUtils.isEmptyString

      // if !isEmpty && e->keyCode === 32 {
      //   let arr = text->String.split(" ")
      //   let newArr = []
      //   arr->Array.forEach(ele => {
      //     if (
      //       !(newArr->Array.includes(ele->String.trim)) &&
      //       !(currentTags->Array.includes(ele->String.trim))
      //     ) {
      //       if ele->String.trim->LogicUtils.isNonEmptyString {
      //         newArr->Array.push(ele->String.trim)->ignore
      //       }
      //     }
      //   })

      //   setTags(currentTags->Array.concat(newArr))
      //   setText(_ => "")
      // }
      Js.log2(">>", "here")
    }

    let onSubmit = (_values, _) => {
      Nullable.null->Promise.resolve
    }

    let validateForm = _values => {
      let errors = Dict.make()
      errors->JSON.Encode.object
    }

    <Form
      key="global-search"
      initialValues={Dict.make()->JSON.Encode.object}
      validate={values => values->validateForm}
      onSubmit>
      <LabelVisibilityContext showLabel=false>
        <FormRenderer.FieldRenderer
          field={FormRenderer.makeFieldInfo(
            ~label="",
            ~name="global_search",
            ~customInput=(~input as _, ~placeholder as _) => {
              <FramerMotion.Motion.Div layoutId="input" className="h-11 bg-white">
                <div className={`flex flex-row items-center border-b dark:border-jp-gray-960`}>
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
              </FramerMotion.Motion.Div>
            },
            ~isRequired=false,
          )}
        />
      </LabelVisibilityContext>
    </Form>
  }
}
