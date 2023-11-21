let regex = (a, searchString) => {
  let searchStringNew =
    searchString
    ->Js.String2.replaceByRe(%re("/[<>\[\]';|?*\\]/g"), "")
    ->Js.String2.replaceByRe(%re("/\(/g"), "\\(")
    ->Js.String2.replaceByRe(%re("/\+/g"), "\\+")
    ->Js.String2.replaceByRe(%re("/\)/g"), "\\)")
  Js.Re.fromStringWithFlags("(.*)(" ++ a ++ "" ++ searchStringNew ++ ")(.*)", ~flags="i")
}

let shouldDisplay = (~globalSearchList, ~searchText) => {
  let isMatch = switch Js.String2.match_(globalSearchList, regex("\\b", searchText)) {
  | Some(_) => true
  | None => Js.String2.match_(globalSearchList, regex("_", searchText))->Belt.Option.isSome
  }
  isMatch && searchText->Js.String2.length > 0
}
let listText = (text, searchText) => {
  switch Js.String2.match_(text, regex("\\b", searchText)) {
  | Some(r) => r->Array.sliceToEnd(~start=1)->Belt.Array.keepMap(x => x)
  | None =>
    switch Js.String2.match_(text, regex("_", searchText)) {
    | Some(a) => a->Array.sliceToEnd(~start=1)->Belt.Array.keepMap(x => x)
    | None => [text]
    }
  }
}
let matchInSearchOption = (searchOptions, searchText, name, link, ~sectionName="", ()) => {
  let valueReturned =
    searchOptions
    ->Belt.Option.getWithDefault([])
    ->Js.Array2.filter(item => {
      let (searchKey, _redirection) = item
      shouldDisplay(~globalSearchList=searchKey, ~searchText)
    })
    ->Js.Array2.map(item => {
      let (searchKey, redirection) = item
      [
        (
          "elements",
          [
            sectionName->Js.Json.string,
            name->Js.Json.string,
            searchKey->Js.Json.string,
          ]->Js.Json.array,
        ),
        ("redirect_link", `${link}${redirection}`->Js.Json.string),
      ]->Js.Dict.fromArray
    })

  valueReturned
}

module RenderedComponent = {
  @react.component
  let make = (~ele, ~searchText) => {
    listText(ele, searchText)
    ->Array.mapWithIndex((item, i) => {
      if (
        Js.String2.toLowerCase(item) == Js.String2.toLowerCase(searchText) &&
          Js.String2.length(searchText) > 0
      ) {
        <mark
          key={i->string_of_int}
          className="border-searched_text_border bg-yellow-searched_text ml-1 font-medium text-fs-14 text-lightgray_background opacity-50">
          {item->React.string}
        </mark>
      } else {
        <span
          key={i->string_of_int}
          className="font-medium text-fs-14 text-lightgray_background opacity-50">
          {item->React.string}
        </span>
      }
    })
    ->React.array
  }
}

@react.component
let make = () => {
  open HeadlessUI
  let (showModal, setShowModal) = React.useState(_ => false)
  let (searchText, setSearchText) = React.useState(_ => "")
  let (arr, setArr) = React.useState(_ => [])
  let featureFlagDetails = FeatureFlagUtils.featureFlagObject
  let merchentDetails = HSwitchUtils.useMerchantDetailsValue()
  let isReconEnabled =
    (merchentDetails->HSwitchMerchantAccountUtils.getMerchantDetails).recon_status === Active

  let hswitchTabs = SidebarValues.getHyperSwitchAppSidebars(
    ~isReconEnabled,
    ~featureFlagDetails,
    (),
  )
  let url = RescriptReactRouter.useUrl()
  let hyperswitchMixPanel = HSMixPanel.useSendEvent()

  let searchText = searchText->Js.String2.trim
  React.useEffect1(_ => {
    let matchedList = hswitchTabs->Array.reduce([], (acc, item) => {
      switch item {
      | Link(obj)
      | RemoteLink(obj) => {
          if shouldDisplay(~globalSearchList=obj.name, ~searchText) {
            let matchedEle =
              [
                ("elements", [""->Js.Json.string, obj.name->Js.Json.string]->Js.Json.array),
                ("redirect_link", obj.link->Js.Json.string),
              ]->Js.Dict.fromArray
            acc->Array.push(matchedEle)
          }
          let matchedSearchValues = matchInSearchOption(
            obj.searchOptions,
            searchText,
            obj.name,
            obj.link,
            ~sectionName="",
            (),
          )

          acc->Js.Array2.concat(matchedSearchValues)
        }

      | Section(sectionObj) => {
          let sectionSearchedValues = sectionObj.links->Array.reduce(
            [],
            (insideAcc, item) => {
              switch item {
              | SubLevelLink(obj)
              | SubLevelRemoteLink(obj) => {
                  if (
                    shouldDisplay(~globalSearchList=sectionObj.name, ~searchText) ||
                    shouldDisplay(~globalSearchList=obj.name, ~searchText)
                  ) {
                    let matchedEle =
                      [
                        (
                          "elements",
                          [
                            sectionObj.name->Js.Json.string,
                            obj.name->Js.Json.string,
                          ]->Js.Json.array,
                        ),
                        ("redirect_link", obj.link->Js.Json.string),
                      ]->Js.Dict.fromArray
                    insideAcc->Array.push(matchedEle)
                  }
                  let matchedSearchValues = matchInSearchOption(
                    obj.searchOptions,
                    searchText,
                    obj.name,
                    obj.link,
                    ~sectionName=sectionObj.name,
                    (),
                  )
                  insideAcc->Js.Array2.concat(matchedSearchValues)
                }
              }
            },
          )
          acc->Js.Array2.concat(sectionSearchedValues)
        }

      | LinkWithTag(obj) => {
          if shouldDisplay(~globalSearchList=obj.name, ~searchText) {
            let matchedEle =
              [
                ("elements", [obj.name->Js.Json.string]->Js.Json.array),
                ("redirect_link", obj.link->Js.Json.string),
              ]->Js.Dict.fromArray
            acc->Array.push(matchedEle)
          }

          let matchedSearchValues = matchInSearchOption(
            obj.searchOptions,
            searchText,
            obj.name,
            obj.link,
            ~sectionName="",
            (),
          )
          acc->Js.Array2.concat(matchedSearchValues)
        }

      | Heading(_) | CustomComponent(_) => []
      }
    })
    setArr(_ => matchedList)
    None
  }, [searchText])

  let prefix = LogicUtils.useUrlPrefix()

  React.useEffect2(() => {
    if searchText->Js.String2.length > 0 && arr->Js.Array2.length === 0 {
      hyperswitchMixPanel(
        ~eventName=Some("open_searchbar_resultnotfound"),
        ~description=Some(searchText),
        (),
      )
    }
    None
  }, (searchText, arr->Js.Array2.length))

  let redirectOnSelect = (element, mixpanelActionName) => {
    let redirectLink = element->LogicUtils.getString("redirect_link", "")
    if redirectLink->Js.String2.length > 0 {
      setShowModal(_ => false)
      hyperswitchMixPanel(
        ~pageName=url.path->LogicUtils.getListHead,
        ~contextName="searchbar",
        ~actionName=mixpanelActionName,
        (),
      )
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

      if Window.Navigator.platform->Js.String2.includes("Mac") && metaKey && keyPressed == "k" {
        setShowModal(_ => true)
        hyperswitchMixPanel(~eventName=Some(`open_searchbar_cmd+k`), ())
      } else if ctrlKey && keyPressed == "k" {
        event->ReactEvent.Keyboard.preventDefault
        setShowModal(_ => true)
        hyperswitchMixPanel(~eventName=Some(`open_searchbar_ctrl+k`), ())
      }
    }
    Window.addEventListener("keydown", onKeyPress)
    Some(() => Window.removeEventListener("keydown", onKeyPress))
  })

  let isMobileView = MatchMedia.useMobileChecker()
  let shortcutText = Window.Navigator.platform->Js.String2.includes("Mac") ? "Cmd + K" : "Ctrl + K"
  let searchBoxBorderColor =
    arr->Js.Array2.length > 0
      ? "border border-transparent"
      : "border border-blue-700 rounded-md !shadow-[0_0_8px_2px_rgba(0,_112,_255,_0.2)]"
  let openModalOnClickHandler = _ => {
    hyperswitchMixPanel(~eventName=Some("open_searchbar_icononclick"), ())
    setShowModal(_ => true)
  }
  <div className="w-max">
    {if isMobileView {
      <Icon size=14 name="search" className="mx-2" onClick={openModalOnClickHandler} />
    } else {
      <div
        className={`flex w-80 inline gap-2 items-center bg-white text-grey-700 text-opacity-30 font-semibold justify-between p-2 rounded-md border border-jp-gray-border_gray`}
        onClick={openModalOnClickHandler}>
        <div className="flex gap-2 ">
          <Icon size=14 name="search" />
          <p className="hidden lg:inline-block text-sm"> {React.string("Search anything...")} </p>
        </div>
        <div className="text-semibold text-sm hidden md:block"> {shortcutText->React.string} </div>
      </div>
    }}
    <UIUtils.RenderIf condition={showModal}>
      <Modal
        showModal
        setShowModal
        modalClass="w-full md:w-2/3 lg:w-4/12 mx-auto"
        closeOnOutsideClick=true
        bgClass="bg-transparent dark:bg-transparent border-transparent dark:border-transparent shadow-transparent	">
        <div
          className={`flex flex-col bg-white dark:bg-black gap-2 rounded-md  ${searchBoxBorderColor}`}>
          <Combobox
            className="w-full " onChange={element => redirectOnSelect(element, "onenterpress")}>
            {listBoxProps => {
              let borderClass = arr->Js.Array2.length > 0 ? "border-b dark:border-jp-gray-960" : ""
              <div className="relative py-2">
                <div className={`flex flex-row relative items-center grow ${borderClass}`}>
                  <div id="leftIcon" className="self-center p-3 opacity-30">
                    <Icon size=14 name="search" />
                  </div>
                  <Combobox.Input
                    \"as"="input"
                    className="relative w-full py-3 text-left bg-transparent focus:outline-none cursor-default sm:text-sm"
                    autoFocus=true
                    placeholder="Search anything..."
                    autoComplete="off"
                    onChange={event => {
                      setSearchText(_ => event["target"]["value"])
                    }}
                  />
                  <Icon
                    size=16
                    name="times"
                    parentClass="flex justify-end opacity-30"
                    className="mx-2"
                    onClick={_ => {
                      setShowModal(_ => false)
                    }}
                  />
                </div>
                <Transition
                  \"as"="span"
                  leave="transition ease-in duration-100"
                  leaveFrom="opacity-100"
                  leaveTo="opacity-0">
                  <Combobox.Options
                    className="w-full overflow-auto text-base rounded-md max-h-96 focus:outline-none sm:text-sm">
                    {optionsProps => {
                      arr
                      ->Array.mapWithIndex((ele, i) => {
                        let elementsArray = ele->LogicUtils.getArrayFromDict("elements", [])
                        <Combobox.Option
                          className="flex flex-row border-b dark:border-jp-gray-960 p-2 cursor-pointer"
                          onClick={_ => redirectOnSelect(ele, "onclick")}
                          key={i->string_of_int}
                          value=ele>
                          {props => {
                            let activeClasses = if props["active"] {
                              "group flex rounded-md items-center w-full px-2 py-2 text-sm bg-gray-100 dark:bg-jp-gray-960"
                            } else {
                              "group flex rounded-md items-center w-full px-2 py-2 text-sm"
                            }

                            <div className=activeClasses>
                              {elementsArray
                              ->Array.mapWithIndex((item, index) => {
                                let elementValue =
                                  item->Js.Json.decodeString->Belt.Option.getWithDefault("")
                                <UIUtils.RenderIf
                                  condition={elementValue->Js.String2.length > 0}
                                  key={index->string_of_int}>
                                  <RenderedComponent ele=elementValue searchText />
                                  <UIUtils.RenderIf
                                    condition={index >= 0 &&
                                      index < elementsArray->Js.Array2.length - 1}>
                                    <span className="mx-2 text-lightgray_background opacity-50">
                                      {">"->React.string}
                                    </span>
                                  </UIUtils.RenderIf>
                                </UIUtils.RenderIf>
                              })
                              ->React.array}
                            </div>
                          }}
                        </Combobox.Option>
                      })
                      ->React.array
                    }}
                  </Combobox.Options>
                </Transition>
              </div>
            }}
          </Combobox>
          <UIUtils.RenderIf
            condition={searchText->Js.String2.length > 0 && arr->Js.Array2.length === 0}>
            <div className="flex flex-col w-full h-72 p-2 justify-center items-center gap-1">
              <img className="w-1/3" src={`${prefix}/icons/globalSearchNoResult.svg`} />
              <div> {`No Results for ${searchText}`->React.string} </div>
            </div>
          </UIUtils.RenderIf>
        </div>
      </Modal>
    </UIUtils.RenderIf>
  </div>
}
