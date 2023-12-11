open Window

@react.component
let make = () => {
  let (isModalOpen, setIsModalOpen) = React.useState(_ => false)
  let (paymentStatus, setPaymentStatus) = React.useState(_ => "")
  let (paymentMsg, setPaymentMsg) = React.useState(_ => "")
  let (iconName, setIconName) = React.useState(_ => "")
  let themeColors = HSwitchSDKUtils.getThemeColorsFromTheme(
    Recoil.useRecoilValueFromAtom(HSwitchRecoilAtoms.theme),
  )
  let paymentStatusState = Recoil.useRecoilValueFromAtom(HSwitchRecoilAtoms.paymentStatus)
  let (isClicked, setIsClicked) = React.useState(_ => false)

  React.useEffect1(() => {
    let windowUrl = urlSearch(location.href)
    let status = windowUrl.searchParams.get(. "status")->Js.Json.decodeString

    let finalStatus =
      status === None && paymentStatusState !== "" ? Some(paymentStatusState) : status

    switch finalStatus {
    | Some(val) => {
        switch val {
        | "succeeded" => {
            setPaymentStatus(_ => val)
            setPaymentMsg(_ => HSwitchSDKUtils.successPaymentMsg)
            setIconName(_ => "circle-tick")
          }
        | "failed" =>
          setPaymentStatus(_ => val)
          setPaymentMsg(_ => HSwitchSDKUtils.failurePaymentMsg)
          setIconName(_ => "circle-cross")
        | _ => {
            setPaymentStatus(_ => "processing")
            setPaymentMsg(_ => HSwitchSDKUtils.processingPaymentMsg)
            setIconName(_ => "circle-tick")
          }
        }
        setIsModalOpen(_ => true)
      }
    | None => ()
    }

    None
  }, [paymentStatusState])

  let handleRedirect = () => {
    if !isClicked {
      setIsClicked(_ => true)
      let url = urlSearch(HSwitchSDKUtils.redirectUrl)
      location.replace(. url.href)
    }
  }

  let redirectMsg = isClicked ? "Restarting Demo..." : "Restart Demo"

  <div>
    <HSwitchModal isModalOpen setIsModalOpen>
      <div className="flex flex-col p-9 gap-4">
        <Icon
          size=32
          name={iconName}
          className={paymentStatus === "failed"
            ? "text-red-600"
            : paymentStatus === "processing"
            ? "text-status-yellow"
            : "text-status-green"}
        />
        <div className="font-semibold text-xl capitalize">
          {React.string(`Payment ${paymentStatus}`)}
        </div>
        <div className="leading-5"> {React.string(paymentMsg)} </div>
        <button
          className={`rounded-md mt-4 cursor-pointer w-full h-11 font-medium text-center text-base relative overflow-hidden ${themeColors.checkoutButtonClass}`}>
          <div
            style={ReactDOMStyle.make(~color=themeColors.tabLabelColor, ())}
            onClick={_ => handleRedirect()}>
            <span className="absolute top-[20%] left-[33%]"> {React.string(redirectMsg)} </span>
            <UIUtils.RenderIf condition={!isClicked}>
              <Icon size=12 name="rotate" className="absolute bottom-[38%] right-[5%]" />
            </UIUtils.RenderIf>
            <Icon size=12 name="rotate" className="absolute bottom-[38%] right-[5%]" />
          </div>
        </button>
      </div>
    </HSwitchModal>
  </div>
}
