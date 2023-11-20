@react.component
let make = () => {
  let hyperswitchMixPanel = HSMixPanel.useSendEvent()
  let url = RescriptReactRouter.useUrl()
  let fetchDetails = APIUtils.useGetMethod()
  let (merchantInfo, setMerchantInfo) = React.useState(() => Js.Dict.empty())
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

  let getMerchantDetails = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let accountUrl = APIUtils.getURL(~entityName=MERCHANT_ACCOUNT, ~methodType=Get, ())
      let merchantDetails = await fetchDetails(accountUrl)
      let merchantInfo = merchantDetails->HSwitchMerchantAccountUtils.getMerchantDetails

      setMerchantInfo(_ => merchantInfo->HSwitchMerchantAccountUtils.parseMerchantJson)

      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Js.Exn.Error(e) =>
      setScreenState(_ => PageLoaderWrapper.Error(
        Js.Exn.message(e)->Belt.Option.getWithDefault("Error"),
      ))
    }
  }

  React.useEffect0(() => {
    getMerchantDetails()->ignore
    None
  })

  let paymentResponsHashKey = merchantInfo->LogicUtils.getString("payment_response_hash_key", "")

  <PageLoaderWrapper screenState sectionHeight="h-40-vh">
    <div className="mt-10">
      <h2
        className="font-bold text-xl pb-3 text-black text-opacity-75 dark:text-white dark:text-opacity-75">
        {"Publishable Key and Payment Response Hash Key"->React.string}
      </h2>
      <div
        className="px-2 py-4 border border-jp-gray-500 dark:border-jp-gray-960 bg-white dark:bg-jp-gray-lightgray_background rounded-md">
        <FormRenderer.DesktopRow>
          <div className="flex flex-col gap-4">
            <div className="flex">
              <div className="break-all text-md text-base text-grey-700 font-semibold">
                {"Publishable Key"->React.string}
              </div>
              <div className="ml-1 mt-0.5 h-5 w-5">
                <ToolTip
                  description="Visit Dev Docs"
                  toolTipFor={<div
                    className="cursor-pointer"
                    onClick={_ => {
                      hyperswitchMixPanel(
                        ~pageName=url.path->LogicUtils.getListHead,
                        ~contextName="publishable_key",
                        ~actionName="visit_docs",
                        (),
                      )
                      "https://hyperswitch.io/docs"->Window._open
                    }}>
                    <Icon name="open_arrow" size=12 />
                  </div>}
                  toolTipPosition=ToolTip.Top
                />
              </div>
            </div>
            <HelperComponents.CopyTextCustomComp
              displayValue={merchantInfo->LogicUtils.getString("publishable_key", "")}
              customTextCss="break-all text-sm font-semibold text-jp-gray-800 text-opacity-75"
              customParentClass="flex items-center gap-5"
              customOnCopyClick={() => {
                hyperswitchMixPanel(
                  ~pageName=url.path->LogicUtils.getListHead,
                  ~contextName="publishable_key",
                  ~actionName="key_copied",
                  (),
                )
              }}
            />
          </div>
          <UIUtils.RenderIf condition={paymentResponsHashKey->Js.String2.length !== 0}>
            <div className="flex flex-col gap-4">
              <div className="break-all text-md text-base text-grey-700 font-semibold">
                {"Payment Response Hash Key"->React.string}
              </div>
              <HelperComponents.CopyTextCustomComp
                displayValue={paymentResponsHashKey}
                customTextCss="break-all text-sm font-semibold text-jp-gray-800 text-opacity-75"
                customParentClass="flex items-center gap-5"
                customOnCopyClick={() => {
                  hyperswitchMixPanel(
                    ~pageName=url.path->LogicUtils.getListHead,
                    ~contextName="payment_response_hash_key",
                    ~actionName="key_copied",
                    (),
                  )
                }}
              />
            </div>
          </UIUtils.RenderIf>
        </FormRenderer.DesktopRow>
      </div>
    </div>
  </PageLoaderWrapper>
}
