@react.component
let make = () => {
  open GlobalSearchTypes
  open GlobalSearchBarUtils
  open LogicUtils
  open GlobalSearchBarHelper

  let getURL = APIUtils.useGetURL()
  let prefix = useUrlPrefix()
  let setGLobalSearchResults = HyperswitchAtom.globalSeacrchAtom->Recoil.useSetRecoilState
  let fetchDetails = APIUtils.useUpdateMethod()
  let (state, setState) = React.useState(_ => Idle)
  let (showModal, setShowModal) = React.useState(_ => false)
  let (searchText, setSearchText) = React.useState(_ => "")
  let (activeFilter, setActiveFilter) = React.useState(_ => "")
  let (localSearchText, setLocalSearchText) = React.useState(_ => "")
  let (selectedOption, setSelectedOption) = React.useState(_ => ""->getDefaultOption)
  let (allOptions, setAllOptions) = React.useState(_ => [])
  let (categorieSuggestionResponse, setCategorieSuggestionResponse) = React.useState(_ =>
    Dict.make()->JSON.Encode.object
  )
  let (searchResults, setSearchResults) = React.useState(_ => [])
  let merchentDetails = HSwitchUtils.useMerchantDetailsValue()
  let isReconEnabled = merchentDetails.recon_status === Active
  let hswitchTabs = SidebarValues.useGetSidebarValues(~isReconEnabled)
  let loader = LottieFiles.useLottieJson("loader-circle.json")
  let {globalSearch} = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let isShowRemoteResults = globalSearch && userHasAccess(~groupAccess=OperationsView) === Access
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let {userInfo: {merchantId}} = React.useContext(UserInfoProvider.defaultContext)

  let redirectOnSelect = element => {
    mixpanelEvent(~eventName="global_search_redirect")
    let redirectLink = element.redirect_link->JSON.Decode.string->Option.getOr("/search")
    if redirectLink->isNonEmptyString {
      setShowModal(_ => false)
      GlobalVars.appendDashboardPath(~url=redirectLink)->RescriptReactRouter.push
    }
  }

  let getCategoryOptions = async () => {
    setState(_ => Loading)
    try {
      let paymentsUrl = getURL(
        ~entityName=ANALYTICS_FILTERS,
        ~methodType=Post,
        ~id=Some("payments"),
      )

      let paymentsResponse = await fetchDetails(
        paymentsUrl,
        paymentsGroupByNames->getFilterBody,
        Post,
      )
      setCategorieSuggestionResponse(_ => paymentsResponse)

      setState(_ => Loaded)
    } catch {
    | _ => setState(_ => Loaded)
    }
  }

  let getSearchResults = async results => {
    try {
      let url = getURL(~entityName=GLOBAL_SEARCH, ~methodType=Post)

      let body = generateSearchBody(~searchText, ~merchant_id={merchantId})

      let response = await fetchDetails(url, body, Post)

      let local_results = []
      results->Array.forEach((item: resultType) => {
        switch item.section {
        | Local => local_results->Array.pushMany(item.results)
        | _ => ()
        }
      })

      let remote_results = response->parseResponse

      setGLobalSearchResults(_ => {
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

  React.useEffect(() => {
    let allOptions = searchResults->getAllOptions
    setAllOptions(_ => allOptions)
    setSelectedOption(_ => searchText->getDefaultOption)
    None
  }, [searchResults])

  React.useEffect(_ => {
    let results = []

    if searchText->String.length > 0 && activeFilter->LogicUtils.isEmptyString {
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

  React.useEffect(_ => {
    setSearchText(_ => "")
    setLocalSearchText(_ => "")
    setActiveFilter(_ => "")
    None
  }, [showModal])

  React.useEffect(() => {
    getCategoryOptions()->ignore

    let onKeyPress = event => {
      let metaKey = event->ReactEvent.Keyboard.metaKey
      let keyPressed = event->ReactEvent.Keyboard.key
      let ctrlKey = event->ReactEvent.Keyboard.ctrlKey

      if Window.Navigator.platform->String.includes("Mac") && metaKey && keyPressed == "k" {
        event->ReactEvent.Keyboard.preventDefault
        setShowModal(_ => true)
      } else if ctrlKey && keyPressed == "k" {
        event->ReactEvent.Keyboard.preventDefault
        setShowModal(_ => true)
      }
    }
    Window.addEventListener("keydown", onKeyPress)
    Some(() => Window.removeEventListener("keydown", onKeyPress))
  }, [])

  let openModalOnClickHandler = _ => {
    setShowModal(_ => true)
  }

  let setGlobalSearchText = ReactDebounce.useDebounced(value => {
    setSearchText(_ => value)
  }, ~wait=500)

  React.useEffect(() => {
    setGlobalSearchText(localSearchText)
    None
  }, [localSearchText])

  let setFilterText = ReactDebounce.useDebounced(value => {
    setActiveFilter(_ => value)
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

  <div className="w-max">
    <SearchBox openModalOnClickHandler />
    <RenderIf condition={showModal}>
      <ModalWrapper showModal setShowModal>
        <div className="w-full">
          <ModalSearchBox
            leftIcon
            setShowModal
            setFilterText
            localSearchText
            setLocalSearchText
            allOptions
            selectedOption
            setSelectedOption
            redirectOnSelect
          />
          {switch state {
          | Loading =>
            <div className="my-14 py-4">
              <Loader />
            </div>
          | _ =>
            // if (
            //   activeFilter->isNonEmptyString ||
            //     (activeFilter->isEmptyString && searchText->isEmptyString)
            // ) {
            //   <FilterResultsComponent
            //     categorySuggestions={getCategorySuggestions(categorieSuggestionResponse)}
            //     activeFilter
            //     setActiveFilter
            //     searchText
            //     setLocalSearchText
            //   />
            // } else
            if searchText->isNonEmptyString && searchResults->Array.length === 0 {
              <EmptyResult prefix searchText />
            } else {
              <SearchResultsComponent
                searchResults searchText setShowModal selectedOption redirectOnSelect
              />
            }
          }}
        </div>
      </ModalWrapper>
    </RenderIf>
  </div>
}
