type switchMerchantListResponse = {
  merchant_id: string,
  merchant_name: string,
}

let convertListResponseToTypedResponse = json => {
  open LogicUtils
  json
  ->getArrayFromJson([])
  ->Array.map(ele => {
    let dictOfElement = ele->getDictFromJsonObject
    let merchantId = dictOfElement->getString("merchant_id", "")
    let merchantName =
      dictOfElement->getString("merchant_name", merchantId)->String.length > 0
        ? dictOfElement->getString("merchant_name", merchantId)
        : merchantId

    {
      merchant_id: merchantId,
      merchant_name: merchantName,
    }
  })
}

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
        let _ = await updateDetails(url, body, Post)
        let _ = await fetchMerchantIDs()
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

module AddNewMerchantButton = {
  @react.component
  let make = (~setShowModal) => {
    open HeadlessUI
    <div className="px-1 py-1 ">
      <Menu.Item>
        {props =>
          <button
            onClick={_ => setShowModal(_ => true)}
            className={
              let activeClasses = if props["active"] {
                "group flex rounded-md items-center px-2 py-2 text-sm bg-gray-100 dark:bg-black"
              } else {
                "group flex rounded-md items-center px-2 py-2 text-sm"
              }
              `${activeClasses} text-blue-900 flex gap-2 font-medium w-56`
            }>
            <Icon name="plus-circle" size=15 />
            {"Add a new merchant"->React.string}
          </button>}
      </Menu.Item>
    </div>
  }
}

module ExternalUser = {
  @react.component
  let make = (~switchMerchant, ~isAddMerchantEnabled) => {
    open APIUtils
    let fetchDetails = useGetMethod()
    let defaultMerchantId = HSLocalStorage.getFromMerchantDetails("merchant_id")
    let (selectedMerchantObject, setSelectedMerchantObject) = React.useState(_ => {
      merchant_id: defaultMerchantId,
      merchant_name: defaultMerchantId,
    })
    let (showModal, setShowModal) = React.useState(_ => false)
    let (options, setOptions) = React.useState(_ => [])

    let fetchMerchantIDs = async () => {
      let url = getURL(~entityName=USERS, ~userType=#SWITCH_MERCHANT, ~methodType=Get, ())
      try {
        let res = await fetchDetails(url)
        let typedValueOfResponse = res->convertListResponseToTypedResponse
        setOptions(_ => typedValueOfResponse)
        let extractMerchantObject =
          typedValueOfResponse
          ->Array.find(ele => ele.merchant_id === defaultMerchantId)
          ->Option.getWithDefault({
            merchant_id: defaultMerchantId,
            merchant_name: defaultMerchantId,
          })
        setSelectedMerchantObject(_ => extractMerchantObject)
      } catch {
      | _ => ()
      }
    }

    React.useEffect0(() => {
      fetchMerchantIDs()->ignore
      None
    })

    open HeadlessUI
    <>
      <Menu \"as"="div" className="relative inline-block text-left">
        {menuProps =>
          <div>
            <Menu.Button
              className="inline-flex whitespace-pre leading-5 justify-center text-sm font-medium px-4 py-2 font-medium rounded-md hover:bg-opacity-80 bg-white border">
              {buttonProps => {
                <>
                  {selectedMerchantObject.merchant_name->React.string}
                  <Icon className="rotate-180 ml-1 mt-1" name="arrow-without-tail" size=15 />
                </>
              }}
            </Menu.Button>
            <Transition
              \"as"="span"
              enter="transition ease-out duration-100"
              enterFrom="transform opacity-0 scale-95"
              enterTo="transform opacity-100 scale-100"
              leave="transition ease-in duration-75"
              leaveFrom="transform opacity-100 scale-100"
              leaveTo="transform opacity-0 scale-95">
              {<Menu.Items
                className="absolute right-0 z-50 w-fit mt-2 origin-top-right bg-white dark:bg-jp-gray-950 divide-y divide-gray-100 rounded-md shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none">
                {props => <>
                  <div className="px-1 py-1 ">
                    {options
                    ->Array.mapWithIndex((option, i) =>
                      <Menu.Item key={i->string_of_int}>
                        {props =>
                          <div className="relative">
                            <button
                              onClick={_ => option.merchant_id->switchMerchant->ignore}
                              className={
                                let activeClasses = if props["active"] {
                                  "group flex rounded-md items-center w-full px-2 py-2 text-sm bg-gray-100 dark:bg-black"
                                } else {
                                  "group flex rounded-md items-center w-full px-2 py-2 text-sm"
                                }
                                `${activeClasses} font-medium`
                              }>
                              <div className="mr-5"> {option.merchant_name->React.string} </div>
                            </button>
                            <UIUtils.RenderIf
                              condition={selectedMerchantObject.merchant_name ===
                                option.merchant_name}>
                              <Icon
                                className="absolute top-2 right-2 text-blue-900"
                                name="check"
                                size=15
                              />
                            </UIUtils.RenderIf>
                          </div>}
                      </Menu.Item>
                    )
                    ->React.array}
                  </div>
                  <UIUtils.RenderIf condition={isAddMerchantEnabled}>
                    <AddNewMerchantButton setShowModal />
                  </UIUtils.RenderIf>
                </>}
              </Menu.Items>}
            </Transition>
          </div>}
      </Menu>
      <UIUtils.RenderIf condition={showModal}>
        <NewAccountCreationModal setShowModal showModal fetchMerchantIDs />
      </UIUtils.RenderIf>
    </>
  }
}

@react.component
let make = (~userRole, ~isAddMerchantEnabled=false) => {
  open LogicUtils
  open HSLocalStorage
  open APIUtils
  let (value, setValue) = React.useState(() => "")
  let merchantId = getFromMerchantDetails("merchant_id")
  let updateDetails = useUpdateMethod()
  let showPopUp = PopUpState.useShowPopUp()
  let isInternalUser = userRole->String.includes("internal_")
  let (successModal, setSuccessModal) = React.useState(_ => false)

  let input = React.useMemo1((): ReactFinalForm.fieldRenderPropsInput => {
    {
      name: "-",
      onBlur: _ev => (),
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
      onFocus: _ev => (),
      value: Js.Json.string(value),
      checked: false,
    }
  }, [value])

  let switchMerchant = async value => {
    try {
      let url = getURL(~entityName=USERS, ~userType=#SWITCH_MERCHANT, ~methodType=Post, ())
      let body = Dict.make()
      body->Dict.set("merchant_id", value->Js.Json.string)
      let res = await updateDetails(url, body->Js.Json.object_, Post)
      let responseDict = res->getDictFromJsonObject
      let token = responseDict->getString("token", "")
      let switchedMerchantId = responseDict->getString("merchant_id", "")
      LocalStorage.setItem("login", token)
      HSwitchUtils.setMerchantDetails("merchant_id", switchedMerchantId->Js.Json.string)
      setSuccessModal(_ => true)
      await HyperSwitchUtils.delay(2000)
      Window.Location.reload()
      setSuccessModal(_ => false)
    } catch {
    | _ => setValue(_ => "")
    }
  }

  let handleKeyUp = event => {
    if event->ReactEvent.Keyboard.keyCode === 13 {
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
    <>
      <ExternalUser switchMerchant isAddMerchantEnabled />
      <Modal
        showModal=successModal
        setShowModal=setSuccessModal
        modalClass="w-80 !h-48 flex items-center justify-center m-auto"
        paddingClass=""
        childClass="flex items-center justify-center h-full w-full">
        {<div className="flex items-center gap-2">
          <p className="text-xl font-semibold"> {"Switching merchant..."->React.string} </p>
        </div>}
      </Modal>
    </>
  }
}
