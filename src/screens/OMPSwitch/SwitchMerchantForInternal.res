@react.component
let make = () => {
  let showToast = ToastState.useShowToast()
  let showPopUp = PopUpState.useShowPopUp()
  let internalSwitch = OMPSwitchHooks.useInternalSwitch()
  let (value, setValue) = React.useState(() => "")
  let {userInfo: {merchantId}} = React.useContext(UserInfoProvider.defaultContext)

  let input = React.useMemo((): ReactFinalForm.fieldRenderPropsInput => {
    {
      name: "-",
      onBlur: _ => (),
      onChange: ev => {
        let value = {ev->ReactEvent.Form.target}["value"]
        if value->String.includes("<script>") || value->String.includes("</script>") {
          showPopUp({
            popUpType: (Warning, WithIcon),
            heading: `Script Tags are not allowed`,
            description: React.string(`Input cannot contain <script>, </script> tags`),
            handleConfirm: {text: "OK"},
          })
        }
        let val = value->String.replace("<script>", "")->String.replace("</script>", "")
        setValue(_ => val)
      },
      onFocus: _ => (),
      value: JSON.Encode.string(value),
      checked: false,
    }
  }, [value])

  let switchMerchant = async () => {
    try {
      let _ = await internalSwitch(~expectedMerchantId=Some(value))
    } catch {
    | _ => showToast(~message="Failed to switch the merchant! Try again.", ~toastType=ToastError)
    }
  }

  let handleKeyUp = event => {
    if event->ReactEvent.Keyboard.keyCode === 13 {
      switchMerchant()->ignore
    }
  }

  <div className="flex items-center gap-4">
    <div
      className={`p-3 rounded-lg whitespace-nowrap text-fs-13 bg-hyperswitch_green_trans border-hyperswitch_green_trans text-hyperswitch_green font-semibold`}>
      {merchantId->React.string}
    </div>
    <TextInput
      input customWidth="w-30 2xl:w-80" placeholder="Switch merchant" onKeyUp=handleKeyUp
    />
  </div>
}
