let h2TextStyle = HSwitchUtils.getTextClass((H2, Optional))

@react.component
let make = (~setTwoFaPageState, ~onClickDownload, ~setShowNewQR) => {
  let showToast = ToastState.useShowToast()
  let getURL = APIUtils.useGetURL()
  let fetchDetails = APIUtils.useGetMethod()
  let (recoveryCodes, setRecoveryCodes) = React.useState(_ => [])
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)

  let generateRecoveryCodes = async () => {
    open LogicUtils
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(~entityName=USERS, ~userType=#GENERATE_RECOVERY_CODES, ~methodType=Get, ())
      let response = await fetchDetails(url)
      let recoveryCodesValue = response->getDictFromJsonObject->getStrArray("recovery_codes")
      setRecoveryCodes(_ => recoveryCodesValue)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Something went wrong")
        let errorCode = err->safeParse->getDictFromJsonObject->getString("code", "")

        if errorCode->CommonAuthUtils.errorSubCodeMapper === UR_38 {
          setTwoFaPageState(_ => TotpTypes.TOTP_SHOW_QR)
          setShowNewQR(prev => !prev)
        } else {
          showToast(~message="Something went wrong", ~toastType=ToastError, ())
          setScreenState(_ => PageLoaderWrapper.Error(err))
        }
      }
    }
  }

  let downloadRecoveryCodes = () => {
    open LogicUtils
    DownloadUtils.downloadOld(
      ~fileName="recoveryCodes.txt",
      ~content=JSON.stringifyWithIndent(recoveryCodes->getJsonFromArrayOfString, 3),
    )
  }

  let copyRecoveryCodes = ev => {
    open LogicUtils
    ev->ReactEvent.Mouse.stopPropagation
    Clipboard.writeText(JSON.stringifyWithIndent(recoveryCodes->getJsonFromArrayOfString, 3))
    showToast(~message="Copied to Clipboard!", ~toastType=ToastSuccess, ())
  }

  React.useEffect0(() => {
    generateRecoveryCodes()->ignore
    None
  })

  <PageLoaderWrapper screenState>
    <div className={`bg-white h-40-rem w-133 rounded-2xl flex flex-col`}>
      <div className="p-6 border-b-2 flex justify-between items-center">
        <p className={`${h2TextStyle} text-grey-900`}>
          {"Two factor recovery codes"->React.string}
        </p>
      </div>
      <div className="px-8 py-8 flex flex-col flex-1 justify-between">
        <div className="flex flex-col  gap-6">
          <p className="text-jp-gray-700">
            {"Recovery codes provide a way to access your account if you lose your device and can't receive two-factor authentication codes."->React.string}
          </p>
          <HSwitchUtils.WarningArea
            warningText="These codes are the last resort for accessing your account in case you lose your password and second factors. If you cannot find these codes, you will lose access to your account."
          />
          <TwoFaElements.ShowRecoveryCodes recoveryCodes />
        </div>
        <div className="flex gap-4 justify-end">
          <Button
            leftIcon={CustomIcon(<img src={`/assets/CopyToClipboard.svg`} />)}
            text={"Copy"}
            buttonType={Secondary}
            buttonSize={Small}
            onClick={copyRecoveryCodes}
          />
          <Button
            leftIcon={FontAwesome("download-api-key")}
            text={"Download"}
            buttonType={Primary}
            buttonSize={Small}
            onClick={_ => {
              downloadRecoveryCodes()
              onClickDownload(~skip_2fa=false)->ignore
            }}
          />
        </div>
      </div>
    </div>
  </PageLoaderWrapper>
}
