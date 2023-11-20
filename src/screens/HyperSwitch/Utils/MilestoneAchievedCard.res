open LottieFiles
open HSwitchUtils
let confettiJson = "successConfetti.json"
@react.component
let make = (
  ~headingModule="",
  ~subText="",
  ~buttonText: option<string>=?,
  ~customBackButtonRoute,
) => {
  let confettiGif = useLottieJson(confettiJson)
  let url = RescriptReactRouter.useUrl()
  let hyperswitchMixPanel = HSMixPanel.useSendEvent()
  let currentPageName = url.path->LogicUtils.getListHead
  let (paymentModal, setPaymentModal) = React.useState(_ => false)
  let isConfigureConnector = ListHooks.useListCount(~entityName=CONNECTOR) > 0
  let merchantDetailsValue = useMerchantDetailsValue()

  <div
    className="relative flex flex-row border-l-4 border-milestone_card_border bg-white gap-4 rounded-md px-8  pt-4 pb-8 w-10/12 lg:w-successCardWidth h-fit my-6 items-center">
    <div className="flex flex-col  gap-2">
      <Icon name="successTag" size=30 className="w-40" />
      <div className=" flex flex-col w-full gap-4 flex-wrap">
        <p className="text-grey-700 text-fs-20 font-semibold ">
          {`Congrats on your ${headingModule}`->React.string}
        </p>
        <p className="text-grey-700 opacity-50 font-medium"> {subText->React.string} </p>
        <div className="flex mt-4 gap-4 flex-col lg:flex-row ">
          <ProdIntentForm isFromMilestoneCard=true />
          {switch buttonText {
          | Some(buttonText) =>
            <Button
              text=buttonText
              buttonType=Secondary
              customButtonStyle="py-1 px-14 !bg-jp-gray-button_gray rounded-sm border-jp-gray-border_gray"
              buttonSize={Small}
              onClick={_ => {
                if Js.String.startsWith("https", customBackButtonRoute) {
                  Window._open(customBackButtonRoute)
                } else {
                  setPaymentModal(_ => true)
                  if currentPageName->Js.String2.length > 0 {
                    [currentPageName, "global"]->Js.Array2.forEach(ele =>
                      hyperswitchMixPanel(
                        ~pageName=ele,
                        ~contextName="milestoneachieved",
                        ~actionName="makeapayment",
                        (),
                      )
                    )
                  }
                }
              }}
            />
          | None => React.null
          }}
          <UIUtils.RenderIf condition={paymentModal}>
            <HomeUtils.SDKOverlay
              overlayPaymentModal=paymentModal
              setOverlayPaymentModal=setPaymentModal
              merchantDetailsValue
              isConfigureConnector
              customBackButtonRoute
            />
          </UIUtils.RenderIf>
        </div>
      </div>
    </div>
    <div className=" hidden lg:block">
      <ReactSuspenseWrapper>
        <Lottie autoplay=true loop=true animationData=confettiGif />
      </ReactSuspenseWrapper>
    </div>
  </div>
}
