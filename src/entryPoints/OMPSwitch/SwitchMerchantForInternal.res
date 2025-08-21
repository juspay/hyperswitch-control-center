// type optionType = {label: string, value: string}
@react.component
let make = () => {
  open Typography
  open InsightsHelper
  open NewAnalyticsTypes

  let showPopUp = PopUpState.useShowPopUp()
  let {setActiveProductValue} = React.useContext(ProductSelectionProvider.defaultContext)
  let internalSwitch = OMPSwitchHooks.useInternalSwitch(~setActiveProductValue)
  let (value, setValue) = React.useState(() => "")
  let (showModal, setShowModal) = React.useState(_ => false)
  let {userInfo: {merchantId}} = React.useContext(UserInfoProvider.defaultContext)
  let maxStringLength = 50

  let (selectedVersion, setSelectedVersion) = React.useState(_ => {
    label: "V1",
    value: "v1",
  })

  let dropDownOptions = [{label: "V1", value: "v1"}, {label: "V2", value: "v2"}]

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

  let showToast = ToastState.useShowToast()
  let onCopyClick = ev => {
    ev->ReactEvent.Mouse.stopPropagation
    Clipboard.writeText(merchantId)
    showToast(~message="Copied to Clipboard!", ~toastType=ToastSuccess)
  }

  let switchMerchant = async () => {
    try {
      let _ = await internalSwitch(
        ~expectedMerchantId=Some(value),
        ~version=selectedVersion.value->UserInfoUtils.versionMapper,
      )
    } catch {
    | _ => showToast(~message="Failed to switch the merchant! Try again.", ~toastType=ToastError)
    }
  }

  let truncatedMerchantId = merchantId->String.slice(~start=0, ~end=maxStringLength)

  <div className="flex items-center gap-4">
    <Modal
      showModal
      closeOnOutsideClick=false
      setShowModal
      childClass="p-0"
      borderBottom=true
      modalClass="w-full !max-w-lg mx-auto my-auto dark:!bg-jp-gray-lightgray_background">
      <div>
        <div className="pt-2 mx-4 my-2  flex justify-between">
          <CardUtils.CardHeader
            heading={`Switch merchant`}
            subHeading=""
            customHeadingStyle="!text-lg font-semibold"
            customSubHeadingStyle="w-full !max-w-none "
          />
          <div
            className="h-fit"
            onClick={_ => {
              setShowModal(_ => false)
            }}>
            <Icon name="modal-close-icon" className="cursor-pointer text-gray-500" size=30 />
          </div>
        </div>
        <hr />
        <div className="p-5 flex flex-col gap-7">
          <div>
            <div className="text-nd_gray-700 font-medium flex gap-1 w-fit align-center">
              {"Merchant Id"->React.string}
              <span className="text-red-900 mb-0.5"> {"*"->React.string} </span>
            </div>
            <TextInput input customWidth="w-full" placeholder="Merchant Id" />
          </div>
          <div className="flex-col gap-2 items-center z-20">
            <div className="text-nd_gray-700 font-medium flex gap-1 w-fit align-center">
              {"Version"->React.string}
              <span className="text-red-900 mb-0.5"> {"*"->React.string} </span>
            </div>
            <CustomDropDown
              buttonText={selectedVersion}
              options={dropDownOptions}
              setOption={value => setSelectedVersion(_ => value)}
            />
          </div>
          <Button
            buttonType={Primary}
            customButtonStyle="w-full"
            text="Switch merchant"
            buttonSize=Small
            onClick={_ => switchMerchant()->ignore}
          />
        </div>
      </div>
    </Modal>
    <div className="flex items-center gap-2">
      <div
        className={`flex gap-3 px-3 py-2 rounded-lg whitespace-nowrap text-fs-13 bg-hyperswitch_green_trans border-hyperswitch_green_trans text-hyperswitch_green ${body.md.semibold}`}>
        {truncatedMerchantId->React.string}
        <RenderIf condition={merchantId->String.length > maxStringLength}>
          {"..."->React.string}
        </RenderIf>
        <Icon
          name="nd-copy"
          className="cursor-pointer"
          size=18
          onClick={ev => {
            onCopyClick(ev)
          }}
        />
      </div>
      <div
        className="flex items-center gap-2 px-3 py-2 bg-nd_gray-100 hover:bg-nd_gray-150 dark:bg-gray-900 rounded-xl border"
        onClick={_ => setShowModal(_ => true)}>
        <span className={`${body.md.semibold} text-gray-500 cursor-pointer`}>
          {"Switch merchant"->React.string}
        </span>
      </div>
    </div>
  </div>
}
