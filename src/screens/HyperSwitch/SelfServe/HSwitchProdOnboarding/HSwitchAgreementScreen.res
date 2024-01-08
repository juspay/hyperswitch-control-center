@react.component
let make = () => {
  open APIUtils
  let showToast = ToastState.useShowToast()
  let fetchApi = AuthHooks.useApiFetcher()
  let updateDetails = useUpdateMethod(~showErrorToast=false, ())
  let {dashboardPageState, setDashboardPageState} = React.useContext(GlobalProvider.defaultContext)
  let (isAgreeEnable, setIsAgreeEnable) = React.useState(_ => false)
  let (isSelected, setIsSelected) = React.useState(_ => false)
  let userRole = HSLocalStorage.getFromUserDetails("user_role")
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  React.useEffect1(() => {
    RescriptReactRouter.push("agreement-signature")
    None
  }, [dashboardPageState])

  let agreementSignature = async () => {
    try {
      let agreementUrl = getURL(~entityName=USERS, ~userType=#MERCHANT_DATA, ~methodType=Post, ())
      let body = ProdOnboardingUtils.getProdApiBody(~parentVariant=#ProductionAgreement, ())
      let _ = await updateDetails(agreementUrl, body, Post)
      setDashboardPageState(_ => #PROD_ONBOARDING)
    } catch {
    | _ =>
      showToast(~toastType=ToastError, ~message="Oops, something went wrong. Please try again.", ())
    }
  }

  let downloadPDF = () => {
    let currentDate =
      Js.Date.now()
      ->Js.Date.fromFloat
      ->Js.Date.toISOString
      ->TimeZoneHook.formattedISOString("YYYY-MM-DD HH:mm:ss")

    //? - For localtesting this condn added
    if HSwitchGlobalVars.urlFordownloadingAgreementMapper->String.length > 0 {
      open Promise
      fetchApi(HSwitchGlobalVars.urlFordownloadingAgreementMapper, ~method_=Get, ())
      ->then(resp => {
        Fetch.Response.blob(resp)
      })
      ->then(content => {
        DownloadUtils.download(
          ~fileName=`HyperswitchTermsAndConditions-${currentDate}.pdf`,
          ~content,
          ~fileType="application/pdf",
        )
        showToast(~toastType=ToastSuccess, ~message="Agreement download complete", ())
        agreementSignature()->ignore
        resolve()
      })
      ->catch(_ => {
        showToast(
          ~toastType=ToastError,
          ~message="Oops, something went wrong with the download. Please try again.",
          (),
        )
        resolve()
      })
      ->ignore
    } else {
      showToast(
        ~toastType=ToastError,
        ~message="Oops, something went wrong with the download - localhost",
        (),
      )
      setDashboardPageState(_ => #PROD_ONBOARDING)
    }
  }

  let errorState =
    <DefaultLandingPage
      height="75vh"
      width="100%"
      title="Oops, we hit a little bump on the road!"
      customStyle="py-16 !m-0"
      overriddingStylesTitle="text-2xl font-semibold"
      buttonText="Refresh"
      overriddingStylesSubtitle="!text-sm text-grey-700 opacity-50 !w-3/4"
      subtitle="We apologize for the inconvenience, but it seems like we encountered a hiccup while processing your request."
      onClickHandler={_ => Window.Location.reload()}
      isButton=true
    />

  let loadingState =
    <div className={`h-screen w-screen flex flex-col justify-center items-center`}>
      <Loader />
    </div>

  let buttonState = if GlobalVars.isLocalhost {
    Button.Normal
  } else if isSelected && isAgreeEnable {
    Button.Normal
  } else {
    Button.Disabled
  }

  <HSwitchUtils.BackgroundImageWrapper>
    <div className="w-full h-[90%] md:w-pageWidth11 mx-auto py-10">
      <div className="flex items-center justify-between px-20 bg-white pb-5 pt-10">
        <img src={`assets/Dark/hyperswitchLogoIconWithText.svg`} />
        <UIUtils.RenderIf condition={featureFlagDetails.switchMerchant}>
          <SwitchMerchant userRole={userRole} />
        </UIUtils.RenderIf>
      </div>
      <div className="flex flex-col gap-5 bg-white px-20 pb-10 w-full h-full overflow-hidden">
        <div className="flex justify-between items-center flex-wrap gap-2">
          <div className="font-semibold text-xl">
            {"Hyperswitch Service Agreement"->React.string}
          </div>
          <ToolTip
            description={"Please read to the bottom of this Service Agreement before you can continue"}
            toolTipFor={<Button
              text={"Accept & Proceed"}
              buttonType={Primary}
              buttonSize={Small}
              customButtonStyle="!px-2 rounded-lg"
              onClick={_ =>
                GlobalVars.isLocalhost ? setDashboardPageState(_ => #HOME) : downloadPDF()}
              buttonState
            />}
            toolTipPosition=ToolTip.Top
            tooltipWidthClass="w-auto"
          />
        </div>
        <div
          className="h-full w-full overflow-auto show-scrollbar bg-pdf_background p-5 md:p-10"
          onScroll={ev => {
            let reachedBottom =
              {ev->ReactEvent.UI.target}["scrollHeight"] - 250 <
                {ev->ReactEvent.UI.target}["clientHeight"] + {ev->ReactEvent.UI.target}["scrollTop"]
            if reachedBottom {
              setIsAgreeEnable(_ => true)
            }
          }}>
          <ReactSuspenseWrapper>
            <ReactPDFViewerSinglePageLazy
              url=HSwitchGlobalVars.urlFordownloadingAgreementMapper
              error=errorState
              loading={loadingState}
            />
          </ReactSuspenseWrapper>
        </div>
        <div className="flex items-center gap-2">
          <CheckBoxIcon isSelected setIsSelected={_ => setIsSelected(prev => !prev)} />
          <p> {"I have read and agree to Hyperswitch's Services Agreement."->React.string} </p>
        </div>
      </div>
    </div>
  </HSwitchUtils.BackgroundImageWrapper>
}
