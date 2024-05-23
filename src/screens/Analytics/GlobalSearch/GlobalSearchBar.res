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
        <img className="w-1/9" src={`${prefix}/icons/globalSearchNoResult.svg`} />
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
  let make = (~index, ~value, ~redirectOnSelect, ~children) => {
    let activeClasses = isActive => {
      let borderClass = isActive ? "bg-gray-100 dark:bg-jp-gray-960" : ""
      `group flex items-center w-full p-2 text-sm rounded-lg ${borderClass}`
    }

    <Combobox.Option
      className="flex flex-row cursor-pointer truncate"
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
  open UIUtils
  @react.component
  let make = (~searchResults, ~searchText, ~redirectOnSelect, ~setShowModal) => {
    <OptionsWrapper>
      {searchResults
      ->Array.mapWithIndex((section: resultType, index) => {
        let borderClass =
          index !== searchResults->Array.length - 1 ? "border-b-1 dark:border-jp-gray-960" : ""
        <FramerMotion.Motion.Div
          layoutId={section.section->getSectionHeader} className={`px-3 mb-3 py-1 ${borderClass}`}>
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

            <OptionWrapper index={i} value={item} redirectOnSelect>
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

@react.component
let make = () => {
  open GlobalSearchTypes
  open GlobalSearchBarUtils
  open HeadlessUI
  open LogicUtils
  open UIUtils
  let getURL = APIUtils.useGetURL()
  let prefix = useUrlPrefix()
  let setGLobalSearchResults = HyperswitchAtom.globalSeacrchAtom->Recoil.useSetRecoilState
  let fetchDetails = APIUtils.useUpdateMethod()
  let (state, setState) = React.useState(_ => Idle)
  let (showModal, setShowModal) = React.useState(_ => false)
  let (searchText, setSearchText) = React.useState(_ => "")
  let (searchResults, setSearchResults) = React.useState(_ => [])
  let merchentDetails = HSwitchUtils.useMerchantDetailsValue()
  let isReconEnabled = merchentDetails.recon_status === Active
  let hswitchTabs = SidebarValues.useGetSidebarValues(~isReconEnabled)
  let searchText = searchText->String.trim
  let loader = LottieFiles.useLottieJson("loader-circle.json")
  let {globalSearch} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let permissionJson = Recoil.useRecoilValueFromAtom(HyperswitchAtom.userPermissionAtom)
  let isShowRemoteResults = globalSearch && permissionJson.operationsView === Access

  let redirectOnSelect = element => {
    let redirectLink = element.redirect_link->JSON.Decode.string->Option.getOr("/search")
    if redirectLink->isNonEmptyString {
      setShowModal(_ => false)
      HSwitchGlobalVars.appendDashboardPath(~url=redirectLink)->RescriptReactRouter.push
    }
  }

  let getSearchResults = async results => {
    try {
      let url = getURL(~entityName=GLOBAL_SEARCH, ~methodType=Post, ())
      let body = [("query", searchText->JSON.Encode.string)]->LogicUtils.getJsonFromArrayOfJson
      let response = await fetchDetails(url, body, Post, ())

      let local_results = []
      results->Array.forEach((item: resultType) => {
        switch item.section {
        | Local => local_results->Array.pushMany(item.results)
        | _ => ()
        }
      })

      let remote_results = response->parseResponse

      setGLobalSearchResults(._ => {
        local_results,
        remote_results,
        searchText,
      })

      let values = response->getRemoteResults
      results->Array.pushMany(values)

      if results->Array.length > 0 {
        let defaultItem = searchText->getDefaultResult

        let arr = [defaultItem]->Array.concat(results)

        setSearchResults(_ => arr)
      } else {
        setSearchResults(_ => [])
      }
      setState(_ => Loaded)
    } catch {
    | _ => setState(_ => Failed)
    }
  }

  React.useEffect1(_ => {
    let results = []

    if searchText->String.length > 0 {
      setState(_ => Loading)
      let localResults: resultType = searchText->getLocalMatchedResults(hswitchTabs)

      if localResults.results->Array.length > 0 {
        results->Array.push(localResults)
      }

      if isShowRemoteResults {
        getSearchResults(results)->ignore
      } else {
        if results->Array.length > 0 {
          let defaultItem = searchText->getDefaultResult

          let arr = [defaultItem]->Array.concat(results)

          setSearchResults(_ => arr)
        } else {
          setSearchResults(_ => [])
        }
        setState(_ => Loaded)
      }
    } else {
      setState(_ => Idle)
      setSearchResults(_ => [])
    }

    None
  }, [searchText])

  React.useEffect1(_ => {
    setSearchText(_ => "")
    None
  }, [showModal])

  React.useEffect0(() => {
    let onKeyPress = event => {
      // TODO: Check this again as it is stopping all the user inputs from keyboard
      //  event->ReactEvent.Keyboard.preventDefault
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

  let borderClass = searchText->String.length > 0 ? "border-b dark:border-jp-gray-960" : ""

  let setGlobalSearchText = ReactDebounce.useDebounced(value => {
    setSearchText(_ => value)
  }, ~wait=500)

  let leftIcon = switch state {
  | Loading =>
    <div className="w-14 overflow-hidden mr-1">
      <div className="w-24 -ml-5 ">
        <Lottie animationData={loader} autoplay=true loop=true />
      </div>
    </div>
  | _ =>
    <div id="leftIcon" className="self-center py-3 pl-5 pr-4">
      <Icon size=18 name="search" />
    </div>
  }

  let modalSearchBox =
    <FramerMotion.Motion.Div layoutId="input" className="h-11 bg-white">
      <div className={`flex flex-row items-center grow ${borderClass}`}>
        {leftIcon}
        <Combobox.Input
          \"as"="input"
          className="w-full py-3 !text-lg bg-transparent focus:outline-none cursor-default sm:text-sm"
          autoFocus=true
          placeholder="Search"
          autoComplete="off"
          onChange={event => {
            setGlobalSearchText(event["target"]["value"])
          }}
        />
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

  <div className="w-max">
    <SearchBox openModalOnClickHandler />
    <RenderIf condition={showModal}>
      <ModalWrapper showModal setShowModal>
        <Combobox
          className="w-full"
          onChange={element => {
            element->redirectOnSelect
          }}>
          {_ => {
            <>
              {modalSearchBox}
              {switch state {
              | Loading =>
                <div className="my-14 py-4">
                  <Loader />
                </div>
              | _ =>
                if searchText->isNonEmptyString && searchResults->Array.length === 0 {
                  <EmptyResult prefix searchText />
                } else {
                  <SearchResultsComponent searchResults searchText redirectOnSelect setShowModal />
                }
              }}
            </>
          }}
        </Combobox>
      </ModalWrapper>
    </RenderIf>
  </div>
}
