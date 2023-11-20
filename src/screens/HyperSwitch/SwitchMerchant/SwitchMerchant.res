external formEventToStr: ReactEvent.Form.t => string = "%identity"

module NewAccountCreationModal = {
  @react.component
  let make = (~setShowModal, ~showModal, ~fetchMerchantIDs) => {
    open APIUtils
    let updateDetails = useUpdateMethod()
    let showToast = ToastState.useShowToast()

    let createNewAccount = async values => {
      try {
        let url = getURL(~entityName=USERS, ~userType=#CREATE_MERCHANT, ~methodType=Fetch.Post, ())
        let body = values
        let _res = await updateDetails(url, body, Post)
        let _merchantIds = await fetchMerchantIDs()
        showToast(
          ~toastType=ToastSuccess,
          ~message="Account Created Successfully!",
          ~autoClose=true,
          (),
        )
      } catch {
      | _ =>
        showToast(~toastType=ToastError, ~message="Account Creation Failed", ~autoClose=true, ())
      }

      setShowModal(_ => false)
      Js.Nullable.null
    }

    let onSubmit = (values, _) => {
      createNewAccount(values)
    }

    let modalBody = {
      <>
        <div className="p-2 m-2">
          <div className="py-5 px-3 flex justify-between align-top">
            <CardUtils.CardHeader
              heading="Create a New Merchant Account"
              subHeading="Enter your company name and get started"
              customSubHeadingStyle="w-full !max-w-none pr-10"
            />
            <div className="h-fit" onClick={_ => setShowModal(_ => false)}>
              <Icon
                name="close" className="border-2 p-2 rounded-2xl bg-gray-100 cursor-pointer" size=30
              />
            </div>
          </div>
          <div className="min-h-96">
            <Form key="new-account-creation" onSubmit>
              <div className="flex flex-col gap-12 h-full w-full">
                <FormRenderer.DesktopRow>
                  <div className="flex flex-col gap-5">
                    <FormRenderer.FieldRenderer
                      fieldWrapperClass="w-full"
                      field={FormRenderer.makeFieldInfo(
                        ~label="Company Name",
                        ~name="company_name",
                        ~placeholder="Eg: HyperSwitch Pvt Ltd",
                        ~customInput=InputFields.textInput(),
                        ~isRequired=true,
                        (),
                      )}
                      errorClass={ProdVerifyModalUtils.errorClass}
                      labelClass="!text-black font-medium !-ml-[0.5px]"
                    />
                  </div>
                </FormRenderer.DesktopRow>
                <div className="flex justify-end w-full pr-5 pb-3">
                  <FormRenderer.SubmitButton text="Create Account" buttonSize={Small} />
                </div>
              </div>
              <FormValuesSpy />
            </Form>
          </div>
        </div>
      </>
    }

    <Modal
      showModal
      closeOnOutsideClick=true
      setShowModal
      childClass="p-0"
      borderBottom=true
      modalClass="w-full max-w-2xl mx-auto my-auto dark:!bg-jp-gray-lightgray_background">
      modalBody
    </Modal>
  }
}

module ExternalUser = {
  @react.component
  let make = (~switchMerchant) => {
    open APIUtils
    let fetchDetails = useGetMethod()
    let merchantCreationOptionValue = "new-merchant"
    let (selectedMerchantID, setSelectedMerchantID) = React.useState(_ => "")
    let (showModal, setShowModal) = React.useState(_ => false)
    let (options, setOptions) = React.useState(_ => [])

    let fetchMerchantIDs = async () => {
      let url = getURL(~entityName=USERS, ~userType=#SWITCH_MERCHANT, ~methodType=Get, ())
      try {
        let res = await fetchDetails(url)
        let merchantIdsArray = res->LogicUtils.getStrArryFromJson->SelectBox.makeOptions
        merchantIdsArray
        ->Array.push({
          label: "Create Account",
          value: merchantCreationOptionValue,
          icon: Euler("plus"),
        })
        ->ignore
        setOptions(_ => merchantIdsArray)
      } catch {
      | _ => ()
      }
    }

    React.useEffect0(() => {
      open HSLocalStorage
      setSelectedMerchantID(_ => getFromMerchantDetails("merchant_id"))
      fetchMerchantIDs()->ignore
      None
    })

    let handleMerchantSwitchSelection = ev => {
      let optionValueString = ev->formEventToStr
      if optionValueString === merchantCreationOptionValue {
        setShowModal(_ => true)
      } else {
        switchMerchant(optionValueString)->ignore
      }
    }

    <>
      <CustomInputSelectBox
        customButtonStyle="rounded-full !p-2"
        deselectDisable={true}
        onChange={handleMerchantSwitchSelection}
        value={selectedMerchantID->Js.Json.string}
        buttonText={selectedMerchantID}
        options={options}
      />
      <UIUtils.RenderIf condition={showModal}>
        <NewAccountCreationModal setShowModal showModal fetchMerchantIDs />
      </UIUtils.RenderIf>
    </>
  }
}

@react.component
let make = (~userRole) => {
  open LogicUtils
  open HSLocalStorage
  open APIUtils
  let hyperswitchMixPanel = HSMixPanel.useSendEvent()
  let url = RescriptReactRouter.useUrl()
  let (value, setValue) = React.useState(() => "")
  let merchantId = getFromMerchantDetails("merchant_id")
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()
  let showPopUp = PopUpState.useShowPopUp()
  let isInternalUser = userRole->Js.String2.includes("internal_")

  let input = React.useMemo1((): ReactFinalForm.fieldRenderPropsInput => {
    {
      name: "-",
      onBlur: _ev => (),
      onChange: ev => {
        let value = {ev->ReactEvent.Form.target}["value"]
        if value->Js.String2.includes("<script>") || value->Js.String2.includes("</script>") {
          showPopUp({
            popUpType: (Warning, WithIcon),
            heading: `Script Tags are not allowed`,
            description: React.string(`Input cannot contain <script>, </script> tags`),
            handleConfirm: {text: "OK"},
          })
        }
        let val = value->Js.String2.replace("<script>", "")->Js.String2.replace("</script>", "")
        setValue(_ => val)
      },
      onFocus: _ev => (),
      value: Js.Json.string(value),
      checked: false,
    }
  }, [value])

  let switchMerchant = async value => {
    try {
      let url = getURL(~entityName=USERS, ~userType=#SWITCH_MERCHANT, ~methodType=Post, ())
      let body = Js.Dict.empty()
      body->Js.Dict.set("merchant_id", value->Js.Json.string)
      let res = await updateDetails(url, body->Js.Json.object_, Post)
      let responseDict = res->getDictFromJsonObject
      let token = responseDict->getString("token", "")
      let switchedMerchantId = responseDict->getString("merchant_id", "")
      LocalStorage.setItem("login", token)
      HSwitchUtils.setMerchantDetails("merchant_id", switchedMerchantId->Js.Json.string)
      showToast(~message=`Merchant Switched Succesfully`, ~toastType=ToastSuccess, ())
      Window.Location.reload()
    } catch {
    | _ => setValue(_ => "")
    }
  }

  let handleKeyUp = event => {
    if event->ReactEvent.Keyboard.keyCode === 13 {
      [`${url.path->LogicUtils.getListHead}`, `global`]->Js.Array2.forEach(ele =>
        hyperswitchMixPanel(~eventName=Some(`${ele}_switch_merchant`), ())
      )
      switchMerchant(value)->ignore
    }
  }

  if isInternalUser {
    <div className="flex items-center gap-4">
      <div
        className={`p-3 rounded-lg whitespace-nowrap text-fs-13 bg-hyperswitch_green_trans border-hyperswitch_green_trans text-hyperswitch_green font-semibold`}>
        {merchantId->React.string}
      </div>
      <TextInput input customWidth="w-80" placeholder="Switch merchant" onKeyUp=handleKeyUp />
    </div>
  } else {
    <ExternalUser switchMerchant />
  }
}
