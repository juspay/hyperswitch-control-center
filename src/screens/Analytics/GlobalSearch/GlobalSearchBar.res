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
          className="border-searched_text_border bg-yellow-searched_text ml-1 font-medium text-fs-14 text-lightgray_background opacity-50">
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
        className={`flex w-80 inline gap-2 items-center bg-white text-grey-700 text-opacity-30 font-semibold justify-between py-2 px-3 rounded-lg border border-jp-gray-border_gray`}
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
    <div className="flex flex-col w-full h-72 p-2 justify-center items-center gap-1">
      <img className="w-1/3" src={`${prefix}/icons/globalSearchNoResult.svg`} />
      <div className="w-1/2 text-wrap text-center break-all">
        {`No Results for ${searchText}`->React.string}
      </div>
    </div>
  }
}

module OptionsWrapper = {
  open HeadlessUI
  @react.component
  let make = (~children) => {
    <Transition
      \"as"="span"
      leave="transition ease-in duration-100"
      leaveFrom="opacity-100"
      leaveTo="opacity-0">
      <Combobox.Options
        className="w-full overflow-auto text-base rounded-lg max-h-96 focus:outline-none sm:text-sm">
        {_ => {
          children
        }}
      </Combobox.Options>
    </Transition>
  }
}

module OptionWrapper = {
  open HeadlessUI
  @react.component
  let make = (~index, ~value, ~redirectOnSelect, ~children) => {
    let activeClasses = isActive => {
      if isActive {
        "group flex rounded-lg items-center w-full px-2 py-2 text-sm bg-gray-100 dark:bg-jp-gray-960"
      } else {
        "group flex rounded-lg items-center w-full px-2 py-2 text-sm"
      }
    }

    <Combobox.Option
      className="flex flex-row border-b dark:border-jp-gray-960 p-2 cursor-pointer"
      onClick={_ => value->redirectOnSelect}
      key={index->Int.toString}
      value>
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
      modalClass="w-full md:w-2/3 lg:w-4/12 mx-auto"
      paddingClass="pt-24"
      closeOnOutsideClick=true
      bgClass="bg-transparent dark:bg-transparent border-transparent dark:border-transparent shadow-transparent	">
      {children}
    </Modal>
  }
}

@react.component
let make = () => {
  open GlobalSearchBarUtils
  open HeadlessUI
  open LogicUtils
  open UIUtils
  let prefix = useUrlPrefix()
  let (showModal, setShowModal) = React.useState(_ => false)
  let (searchText, setSearchText) = React.useState(_ => "")
  let (searchResults, setSearchResults) = React.useState(_ => [])
  let merchentDetails = HSwitchUtils.useMerchantDetailsValue()
  let isReconEnabled =
    (merchentDetails->MerchantAccountUtils.getMerchantDetails).recon_status === Active
  let hswitchTabs = SidebarValues.useGetSidebarValues(~isReconEnabled)
  let searchText = searchText->String.trim
  let searchBoxBorderColor = "border border-transparent"

  React.useEffect1(_ => {
    let results = searchText->getMatchedList(hswitchTabs)
    setSearchResults(_ => results)
    None
  }, [searchText])

  let redirectOnSelect = element => {
    let redirectLink = element->getString("redirect_link", "")
    if redirectLink->isNonEmptyString {
      setShowModal(_ => false)
      RescriptReactRouter.push(redirectLink)
    }
  }

  React.useEffect1(_ => {
    setSearchText(_ => "")
    None
  }, [showModal])

  React.useEffect0(() => {
    let onKeyPress = event => {
      let metaKey = event->ReactEvent.Keyboard.metaKey
      let keyPressed = event->ReactEvent.Keyboard.key
      let ctrlKey = event->ReactEvent.Keyboard.ctrlKey

      if Window.Navigator.platform->String.includes("Mac") && metaKey && keyPressed == "k" {
        setShowModal(_ => true)
      } else if ctrlKey && keyPressed == "k" {
        event->ReactEvent.Keyboard.preventDefault
        setShowModal(_ => true)
      }
    }
    Window.addEventListener("keydown", onKeyPress)
    Some(() => Window.removeEventListener("keydown", onKeyPress))
  })

  let openModalOnClickHandler = _ => {
    setShowModal(_ => true)
  }

  let borderClass = searchResults->Array.length > 0 ? "border-b dark:border-jp-gray-960" : ""

  let modalSearchBox =
    <div className={`flex flex-row relative items-center grow ${borderClass}`}>
      <div id="leftIcon" className="self-center p-3">
        <Icon size=14 name="search" />
      </div>
      <Combobox.Input
        \"as"="input"
        className="relative w-full py-3 text-left bg-transparent focus:outline-none cursor-default sm:text-sm"
        autoFocus=true
        placeholder="Search"
        autoComplete="off"
        onChange={event => {
          setSearchText(_ => event["target"]["value"])
        }}
      />
      <Icon
        size=16
        name="times"
        parentClass="flex justify-end opacity-30"
        className="mr-3 cursor-pointer"
        onClick={_ => {
          setShowModal(_ => false)
        }}
      />
    </div>

  <div className="w-max">
    <SearchBox openModalOnClickHandler />
    <RenderIf condition={showModal}>
      <ModalWrapper showModal setShowModal>
        {<div
          className={`flex flex-col bg-white dark:bg-black gap-2 rounded-lg  ${searchBoxBorderColor}`}>
          <Combobox className="w-full " onChange={element => element->redirectOnSelect}>
            {_ => {
              <div className="relative py-1">
                {modalSearchBox}
                <OptionsWrapper>
                  {searchResults
                  ->Array.mapWithIndex((ele, i) => {
                    let elementsArray = ele->getArrayFromDict("elements", [])
                    <OptionWrapper index={i} value={ele} redirectOnSelect>
                      {elementsArray
                      ->Array.mapWithIndex((item, index) => {
                        let elementValue = item->JSON.Decode.string->Option.getOr("")
                        <RenderIf
                          condition={elementValue->isNonEmptyString} key={index->Int.toString}>
                          <RenderedComponent ele=elementValue searchText />
                          <RenderIf
                            condition={index >= 0 && index < elementsArray->Array.length - 1}>
                            <span className="mx-2 text-lightgray_background opacity-50">
                              {">"->React.string}
                            </span>
                          </RenderIf>
                        </RenderIf>
                      })
                      ->React.array}
                    </OptionWrapper>
                  })
                  ->React.array}
                </OptionsWrapper>
              </div>
            }}
          </Combobox>
          <RenderIf condition={searchText->isNonEmptyString && searchResults->Array.length === 0}>
            <EmptyResult prefix searchText />
          </RenderIf>
        </div>}
      </ModalWrapper>
    </RenderIf>
  </div>
}
