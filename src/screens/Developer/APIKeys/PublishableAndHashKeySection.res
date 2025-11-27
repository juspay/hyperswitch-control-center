@react.component
let make = () => {
  let getURL = APIUtils.useGetURL()
  let fetchDetails = APIUtils.useGetMethod()
  let {userInfo: {version}} = React.useContext(UserInfoProvider.defaultContext)
  let (merchantInfo, setMerchantInfo) = React.useState(() =>
    JSON.Encode.null->MerchantAccountDetailsMapper.getMerchantDetails
  )
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

  let getMerchantDetails = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let entityName: APIUtilsTypes.entityTypeWithVersion = switch version {
      | V1 => V1(MERCHANT_ACCOUNT)
      | V2 => V2(MERCHANT_ACCOUNT)
      }
      let accountUrl = getURL(~entityName, ~methodType=Get)
      let merchantDetails = await fetchDetails(accountUrl)
      let merchantInfo = merchantDetails->MerchantAccountDetailsMapper.getMerchantDetails
      setMerchantInfo(_ => merchantInfo)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Exn.Error(e) =>
      setScreenState(_ => PageLoaderWrapper.Error(Exn.message(e)->Option.getOr("Error")))
    }
  }

  React.useEffect(() => {
    getMerchantDetails()->ignore
    None
  }, [])

  let paymentResponseHashKey = merchantInfo.payment_response_hash_key->Option.getOr("")
  let heading = `Publishable Key ${paymentResponseHashKey->LogicUtils.isNonEmptyString
      ? "and Payment Response Hash Key"
      : ""}`

  <PageLoaderWrapper screenState sectionHeight="h-40-vh">
    <div className="mt-10">
      <h2
        className="font-bold text-xl pb-3 text-black text-opacity-75 dark:text-white dark:text-opacity-75">
        {heading->React.string}
      </h2>
      <div
        className="px-2 py-4 border border-jp-gray-500 dark:border-jp-gray-960 bg-white dark:bg-jp-gray-lightgray_background rounded-md">
        <FormRenderer.DesktopRow>
          <div className="flex flex-col gap-1 md:gap-4 mb-4 md:mb-0">
            <div className="flex">
              <div className="break-all text-md text-base text-grey-700 font-semibold">
                {"Publishable Key"->React.string}
              </div>
              <div className="ml-1 mt-0.5 h-5 w-5">
                <ToolTip
                  tooltipWidthClass="w-fit"
                  description="Visit Dev Docs"
                  toolTipFor={<div
                    className="cursor-pointer"
                    onClick={_ => {
                      "https://hyperswitch.io/docs"->Window._open
                    }}>
                    <Icon name="open_arrow" size=12 />
                  </div>}
                  toolTipPosition=ToolTip.Top
                />
              </div>
            </div>
            <HelperComponents.CopyTextCustomComp
              displayValue={Some(merchantInfo.publishable_key)}
              customTextCss="break-all text-sm truncate md:whitespace-normal font-semibold text-jp-gray-800 text-opacity-75"
              customParentClass="flex items-center gap-5"
              customIconCss="text-jp-gray-700"
            />
          </div>
          <RenderIf condition={paymentResponseHashKey->String.length !== 0}>
            <div className="flex flex-col gap-2 md:gap-4">
              <div className="break-all text-md text-base text-grey-700 font-semibold">
                {"Payment Response Hash Key"->React.string}
              </div>
              <HelperComponents.CopyTextCustomComp
                displayValue={Some(paymentResponseHashKey)}
                customTextCss="break-all truncate md:whitespace-normal text-sm font-semibold text-jp-gray-800 text-opacity-75"
                customParentClass="flex items-center gap-5"
                customIconCss="text-jp-gray-700"
              />
            </div>
          </RenderIf>
        </FormRenderer.DesktopRow>
      </div>
    </div>
  </PageLoaderWrapper>
}
