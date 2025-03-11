let p1MediumTextStyle = HSwitchUtils.getTextClass((P1, Medium))

@react.component
let make = () => {
  open AlternatePaymentMethodsUtils
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let (searchedConnector, setSearchedConnector) = React.useState(_ => "")
  let searchRef = React.useRef(Nullable.null)
  let {setShowSideBar} = React.useContext(GlobalProvider.defaultContext)

  React.useEffect(() => {
    setShowSideBar(_ => true)
    None
  }, [])

  let handleSearch = event => {
    let val = ref(ReactEvent.Form.currentTarget(event)["value"])
    setSearchedConnector(_ => val.contents)
  }

  let handleClick = connectorName => {
    mixpanelEvent(~eventName=`connect_alt_payment_method_${connectorName}`)
    setShowSideBar(_ => false)
    RescriptReactRouter.push(
      GlobalVars.appendDashboardPath(
        ~url=`v2/alt-payment-methods/onboarding/new?name=${connectorName}`,
      ),
    )
  }

  let apmCards = (
    ~apmList: array<AlternatePaymentMethodsTypes.altPaymentMethodTypes>,
    ~heading: string,
    ~showSearch=true,
    (),
  ) => {
    if apmList->Array.length > 0 {
      apmList->Array.sort(sortByName)
    }
    <>
      <div className="flex w-full justify-between gap-4 mt-4 mb-4">
        <RenderIf condition={showSearch}>
          <AddDataAttributes attributes=[("data-testid", "search-alt-payment-method")]>
            <input
              ref={searchRef->ReactDOM.Ref.domRef}
              type_="text"
              value=searchedConnector
              onChange=handleSearch
              placeholder="Search payment method"
              className={`rounded-md px-4 py-2 focus:outline-none w-1/3 border`}
              id="search-payment-method"
            />
          </AddDataAttributes>
        </RenderIf>
      </div>
      <AddDataAttributes
        attributes=[("data-testid", heading->LogicUtils.titleToSnake->String.toLowerCase)]>
        <h2
          className="font-semibold text-xl text-nd_gray-600  dark:text-white dark:text-opacity-75">
          {heading->React.string}
        </h2>
      </AddDataAttributes>
      <RenderIf condition={apmList->Array.length > 0}>
        <div
          className={`grid gap-x-5 gap-y-6 2xl:grid-cols-4 lg:grid-cols-3 md:grid-cols-2 grid-cols-1 mb-5 auto-rows-fr`}>
          {apmList
          ->Array.mapWithIndex((
            connector: AlternatePaymentMethodsTypes.altPaymentMethodTypes,
            i,
          ) => {
            let connectorName = connector->altPaymentMethodsToString
            <ACLDiv
              authorization={userHasAccess(~groupAccess=ConnectorsManage)}
              onClick={_ => handleClick(connectorName)}
              key={i->Int.toString}
              className="border gap-4 bg-white rounded-lg flex p-4  hover:bg-gray-50 hover:cursor-pointer "
              dataAttrStr=connectorName>
              <div className="flex flex-row gap-3 items-center flex-1 ">
                <img
                  alt={`${connectorName}`}
                  className=""
                  src={`/AlternatePaymentMethods/${connectorName}.svg`}
                />
                <p className={`${p1MediumTextStyle} break-all min-w-[150px] lg:min-w-[210px]`}>
                  {connector->altPaymentMethodsDisplayName->React.string}
                </p>
              </div>
            </ACLDiv>
          })
          ->React.array}
        </div>
      </RenderIf>
    </>
  }

  let apmListFiltered = {
    if searchedConnector->LogicUtils.isNonEmptyString {
      altPaymentMethods->Array.filter(item =>
        item
        ->altPaymentMethodsDisplayName
        ->String.toLowerCase
        ->String.includes(searchedConnector->String.toLowerCase)
      )
    } else {
      altPaymentMethods
    }
  }

  <div>
    <PageUtils.PageHeading
      title="Activate Alternative Payment Methods"
      subTitle="Enhance your checkout process by activating any of our supported Alternative Payment Methods (APMs)."
      customSubTitleStyle="font-500 font-normal text-nd_gray-700"
    />
    <div className="flex flex-col gap-4">
      {apmCards(~apmList=apmListFiltered, ~heading="Popular APMs", ())}
    </div>
  </div>
}
