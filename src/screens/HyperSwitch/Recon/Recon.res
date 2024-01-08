@react.component
let make = () => {
  open APIUtils
  open MerchantAccountUtils
  let (redirectToken, setRedirecToken) = React.useState(_ => "")
  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()
  let fetchMerchantAccountDetails = useFetchMerchantDetails()
  let merchentDetails = HSwitchUtils.useMerchantDetailsValue()->getMerchantDetails
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let isReconEnabled = merchentDetails.recon_status === Active

  let onClickForReconRequest = async () => {
    try {
      let url = getURL(~entityName=RECON, ~reconType=#REQUEST, ~methodType=Get, ())
      let _ = await updateDetails(url, Js.Json.null, Post)
      let _ = await fetchMerchantAccountDetails()
      showToast(
        ~message=`Thank you for your interest in our reconciliation module. We are currently reviewing your request for access. We will follow up with you soon regarding next steps.`,
        ~toastType=ToastSuccess,
        (),
      )
    } catch {
    | _ => showToast(~message=`Something went wrong. Please try again.`, ~toastType=ToastError, ())
    }
  }

  let openReconTab = async () => {
    try {
      if redirectToken->String.length === 0 {
        setScreenState(_ => PageLoaderWrapper.Loading)
        let url = getURL(~entityName=RECON, ~reconType=#TOKEN, ~methodType=Get, ())
        let res = await fetchDetails(url)
        let token = res->LogicUtils.getDictFromJsonObject->LogicUtils.getString("token", "")
        setRedirecToken(_ => token)
        let link = "https://sandbox.hyperswitch.io/recon-dashboard/?token=" ++ token
        Window._open(link)
        setScreenState(_ => PageLoaderWrapper.Success)
      } else {
        let link = "https://sandbox.hyperswitch.io/recon-dashboard/?token=" ++ redirectToken
        Window._open(link)
      }
    } catch {
    | Js.Exn.Error(e) => {
        let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Failed to fetch Token!")
        setScreenState(_ => PageLoaderWrapper.Error(err))
      }
    }
  }

  React.useEffect0(() => {
    if isReconEnabled {
      let _ = openReconTab()->ignore
    } else {
      setScreenState(_ => PageLoaderWrapper.Success)
    }
    None
  })

  let subTitleText = isReconEnabled
    ? "Streamline your reconciliation and settlement operations"
    : "Upgrade today to streamline your reconciliation and settlement operations"

  <PageLoaderWrapper screenState>
    <div className="h-screen overflow-scroll flex flex-col w-full ">
      <div className="flex flex-col overflow-scroll h-full gap-6">
        <PageUtils.PageHeading
          title={isReconEnabled ? "Reconciliation" : "Activate Reconciliation"}
          subTitle=subTitleText
        />
        {if isReconEnabled {
          <div
            className={`bg-white dark:bg-jp-gray-lightgray_background border-2 rounded dark:border-jp-gray-850 grid grid-cols-1 md:gap-5 p-2 md:p-8 h-2/3 items-center`}>
            <div className={`flex flex-col items-center w-4/6 md:w-2/6 justify-self-center gap-1`}>
              <div
                className={`text-center text-semibold text-s text-grey-700 opacity-60 dark:text-white`}>
                {"You will be redirected to the recon dashboard in a moment. (Enable pop-ups in your browser for auto-redirection.)"->React.string}
              </div>
              <Button
                text="Go to recon tab"
                buttonType={Primary}
                customButtonStyle="w-2/3 rounded-sm !bg-jp-blue-button_blue border border-jp-blue-border_blue mt-4"
                buttonSize={Small}
                buttonState={Normal}
                onClick={v => {
                  openReconTab()->ignore
                }}
              />
            </div>
          </div>
        } else {
          <div
            className={`flex flex-col gap-5 bg-white dark:bg-jp-gray-lightgray_background border-2 rounded dark:border-jp-gray-850 md:gap-5 p-2 md:p-8 h-2/3 items-center`}>
            <div className="justify-self-center h-full w-full">
              <iframe
                className="w-full h-full"
                src="https://www.youtube.com/embed/YW61xAtQsJo?autoplay=1&loop=1&rel=0&showinfo=0&color=white&playlist=YW61xAtQsJo"
                title="JUSPAY Recon"
              />
            </div>
            {if merchentDetails.recon_status === Requested {
              <div
                className={`text-center text-semibold text-s text-grey-700 opacity-60 dark:text-white`}>
                {"Thank you for your interest in our reconciliation module. We are currently reviewing your request for access. We will follow up with you soon regarding next steps."->React.string}
              </div>
            } else {
              <div className={`flex flex-col items-center w-2/3 justify-self-center gap-1 my-10`}>
                <div className={`font-bold text-xl dark:text-white`}>
                  {"Drop us an email!"->React.string}
                </div>
                <div
                  className={`text-center text-semibold text-s text-grey-700 opacity-60 dark:text-white`}>
                  {"Once submitted, you should hear a response in 48 hours, often sooner."->React.string}
                </div>
                <Button
                  text="Send an email"
                  buttonType={Primary}
                  customButtonStyle="w-2/3 rounded-sm !bg-jp-blue-button_blue border border-jp-blue-border_blue mt-4"
                  buttonSize={Small}
                  buttonState={Normal}
                  onClick={v => {
                    onClickForReconRequest()->ignore
                  }}
                />
                <div className={`flex text-center`}>
                  <div className={`text-s text-grey-700 opacity-60  dark:text-white`}>
                    {"or contact us on"->React.string}
                  </div>
                  <div className={`m-1`}>
                    <Icon size=16 name="slack" />
                  </div>
                  <div>
                    <a
                      className={`text-[#0000FF]`}
                      href="https://hyperswitch-io.slack.com/?redir=%2Fssb%2Fredirect"
                      target="_blank">
                      {"slack"->React.string}
                    </a>
                  </div>
                </div>
              </div>
            }}
          </div>
        }}
      </div>
    </div>
  </PageLoaderWrapper>
}
