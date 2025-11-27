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
  let (selectedFilter, setSelectedFilter) = React.useState(_ => None)
  let (allFilters, setAllFilters) = React.useState(_ => [])
  let (categoriesSuggestionResponse, setCategoriesSuggestionResponse) = React.useState(_ =>
    Dict.make()->JSON.Encode.object
  )
  let {userInfo: {version}} = React.useContext(UserInfoProvider.defaultContext)
  let (searchResults, setSearchResults) = React.useState(_ => [])
  let merchentDetails = MerchantDetailsHook.useMerchantDetailsValue()
  let isReconEnabled = merchentDetails.recon_status === Active
  let hswitchTabs = SidebarHooks.useGetHsSidebarValues(~isReconEnabled)
  let loader = LottieFiles.useLottieJson("loader-circle.json")
  let {globalSearch, globalSearchFilters} =
    HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let isShowRemoteResults = globalSearch && userHasAccess(~groupAccess=OperationsView) === Access
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let inputRef = React.useRef(Nullable.null)
  let filtersEnabled = globalSearchFilters

  let redirectOnSelect = element => {
    mixpanelEvent(~eventName="global_search_redirect")
    let redirectLink = element.redirect_link->JSON.Decode.string->Option.getOr(defaultRoute)
    if redirectLink->isNonEmptyString {
      setShowModal(_ => false)
      GlobalVars.appendDashboardPath(~url=redirectLink)->RescriptReactRouter.push
    }
  }

  let getCategoryOptions = async () => {
    setState(_ => Loading)
    try {
      let paymentsUrl = getURL(
        ~entityName=V1(ANALYTICS_FILTERS),
        ~methodType=Post,
        ~id=Some("payments"),
      )

      let paymentsResponse = await fetchDetails(
        paymentsUrl,
        paymentsGroupByNames->getFilterBody,
        Post,
      )
      setCategoriesSuggestionResponse(_ => paymentsResponse)

      setState(_ => Idle)
    } catch {
    | _ => setState(_ => Idle)
    }
  }

  let getSearchResults = async results => {
    try {
      let local_results = []

      let url = getURL(~entityName=V1(GLOBAL_SEARCH), ~methodType=Post)
      let body = searchText->generateQuery

      mixpanelEvent(~eventName="global_search", ~metadata=body->JSON.Encode.object)

      let response = await fetchDetails(url, body->JSON.Encode.object, Post)

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
      let defaultItem = searchText->getDefaultResult

      let finalResults = results->Array.length > 0 ? [defaultItem]->Array.concat(results) : []

      setSearchResults(_ => finalResults)
      setState(_ => Loaded)
    } catch {
    | _ => setState(_ => Loaded)
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

    if (
      searchText->isNonEmptyString &&
      searchText->getSearchValidation &&
      !(searchText->validateQuery)
    ) {
      setState(_ => Loading)
      let localResults: resultType = searchText->getLocalMatchedResults(hswitchTabs)

      if localResults.results->Array.length > 0 {
        results->Array.push(localResults)
      }

      if isShowRemoteResults {
        getSearchResults(results)->ignore
      } else {
        let defaultItem = searchText->getDefaultResult
        let finalResults = results->Array.length > 0 ? [defaultItem]->Array.concat(results) : []

        setSearchResults(_ => finalResults)
        setState(_ => Loaded)
      }
    } else {
      setState(_ => Idle)
      setSearchResults(_ => [])
    }

    None
  }, [searchText])

  let setFilterText = value => {
    setActiveFilter(_ => value)
  }

  React.useEffect(_ => {
    setSearchText(_ => "")
    setLocalSearchText(_ => "")
    setFilterText("")
    setSelectedFilter(_ => None)
    None
  }, [showModal])

  let onKeyPress = event => {
    open ReactEvent.Keyboard
    let metaKey = event->metaKey
    let keyPressed = event->key
    let ctrlKey = event->ctrlKey
    let cmdKey = Window.Navigator.platform->String.includes("Mac")

    if (
      (cmdKey && metaKey && keyPressed == global_search_activate_key) ||
        (ctrlKey && keyPressed == global_search_activate_key)
    ) {
      setShowModal(_ => true)
      event->preventDefault
    }
  }

  React.useEffect(() => {
    if userHasAccess(~groupAccess=AnalyticsView) === Access && version == V1 {
      getCategoryOptions()->ignore
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

  let onFilterClicked = category => {
    let newFilter = category.categoryType->getcategoryFromVariant
    let lastString = searchText->getEndChar
    if activeFilter->isNonEmptyString && lastString !== filterSeparator {
      let end = searchText->String.length - activeFilter->String.length
      let newText = searchText->String.substring(~start=0, ~end)
      setLocalSearchText(_ => `${newText} ${newFilter}:`)
      setFilterText(newFilter)
    } else if lastString !== filterSeparator {
      setLocalSearchText(_ => `${searchText} ${newFilter}:`)
      setFilterText(newFilter)
    }

    revertFocus(~inputRef)
  }

  let onSuggestionClicked = option => {
    let value = activeFilter->String.split(filterSeparator)->getValueFromArray(1, "")
    let key = if value->isNonEmptyString {
      let end = searchText->String.length - (value->String.length + 1)
      searchText->String.substring(~start=0, ~end)
    } else {
      searchText
    }
    let saparater = searchText->getEndChar == filterSeparator ? "" : filterSeparator
    setLocalSearchText(_ => `${key}${saparater}${option}`)
    setFilterText("")

    revertFocus(~inputRef)
  }

  React.useEffect(() => {
    setGlobalSearchText(localSearchText)
    None
  }, [localSearchText])

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

  let viewType = getViewType(~state, ~searchResults)
  let categorySuggestions = {getCategorySuggestions(categoriesSuggestionResponse)}

  <div className="w-max">
    <SearchBox openModalOnClickHandler />
    <RenderIf condition={showModal}>
      <ModalWrapper showModal setShowModal>
        <div className="w-full">
          <ModalSearchBox
            inputRef
            leftIcon
            setShowModal
            setFilterText
            localSearchText
            setLocalSearchText
            allOptions
            selectedOption
            setSelectedOption
            allFilters
            selectedFilter
            setSelectedFilter
            viewType
            redirectOnSelect
            activeFilter
            onFilterClicked
            onSuggestionClicked
            categorySuggestions
            searchText
          />
          {switch viewType {
          | Results | Load | EmptyResult =>
            <SearchResultsComponent
              searchResults
              searchText
              setShowModal
              selectedOption
              redirectOnSelect
              categorySuggestions
              activeFilter
              setAllFilters
              selectedFilter
              setSelectedFilter
              onFilterClicked
              onSuggestionClicked
              viewType
              prefix
              filtersEnabled
            />
          | FiltersSugsestions =>
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
              />
            </RenderIf>
          }}
        </div>
      </ModalWrapper>
    </RenderIf>
  </div>
}
