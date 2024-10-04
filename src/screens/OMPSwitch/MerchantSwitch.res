module NewAccountCreationModal = {
  @react.component
  let make = (~setShowModal, ~showModal, ~getMerchantList) => {
    open APIUtils
    let getURL = useGetURL()
    let updateDetails = useUpdateMethod()
    let showToast = ToastState.useShowToast()
    let createNewAccount = async values => {
      try {
        let url = getURL(~entityName=USERS, ~userType=#CREATE_MERCHANT, ~methodType=Post)
        let _ = await updateDetails(url, values, Post)
        getMerchantList()->ignore
        showToast(
          ~toastType=ToastSuccess,
          ~message="Account Created Successfully!",
          ~autoClose=true,
        )
      } catch {
      | _ => showToast(~toastType=ToastError, ~message="Account Creation Failed", ~autoClose=true)
      }

      setShowModal(_ => false)
      Nullable.null
    }

    let onSubmit = (values, _) => {
      createNewAccount(values)
    }

    let merchantName = FormRenderer.makeFieldInfo(
      ~label="Merchant Name",
      ~name="company_name",
      ~placeholder="Eg: My New Merchant",
      ~customInput=InputFields.textInput(),
      ~isRequired=true,
    )

    let validateForm = (values: JSON.t) => {
      open LogicUtils
      let errors = Dict.make()
      let companyName = values->getDictFromJsonObject->getString("company_name", "")->String.trim
      let regexForCompanyName = "^([a-z]|[A-Z]|[0-9]|_|\\s)+$"

      let errorMessage = if companyName->isEmptyString {
        "Merchant name cannot be empty"
      } else if companyName->String.length > 64 {
        "Merchant name too long"
      } else if !RegExp.test(RegExp.fromString(regexForCompanyName), companyName) {
        "Merchant name should not contain special characters"
      } else {
        ""
      }

      if errorMessage->isNonEmptyString {
        Dict.set(errors, "company_name", errorMessage->JSON.Encode.string)
      }

      errors->JSON.Encode.object
    }

    let modalBody = {
      <div className="p-2 m-2">
        <div className="py-5 px-3 flex justify-between align-top">
          <CardUtils.CardHeader
            heading="Add a new merchant"
            subHeading=""
            customSubHeadingStyle="w-full !max-w-none pr-10"
          />
          <div className="h-fit" onClick={_ => setShowModal(_ => false)}>
            <Icon
              name="close" className="border-2 p-2 rounded-2xl bg-gray-100 cursor-pointer" size=30
            />
          </div>
        </div>
        <Form key="new-account-creation" onSubmit validate={validateForm}>
          <div className="flex flex-col gap-12 h-full w-full">
            <FormRenderer.DesktopRow>
              <div className="flex flex-col gap-5">
                <FormRenderer.FieldRenderer
                  fieldWrapperClass="w-full"
                  field={merchantName}
                  showErrorOnChange=true
                  errorClass={ProdVerifyModalUtils.errorClass}
                  labelClass="!text-black font-medium !-ml-[0.5px]"
                />
              </div>
            </FormRenderer.DesktopRow>
            <div className="flex justify-end w-full pr-5 pb-3">
              <FormRenderer.SubmitButton text="Add Merchant" buttonSize={Small} />
            </div>
          </div>
        </Form>
      </div>
    }

    <Modal
      showModal
      closeOnOutsideClick=true
      setShowModal
      childClass="p-0"
      borderBottom=true
      modalClass="w-full max-w-xl mx-auto my-auto dark:!bg-jp-gray-lightgray_background">
      modalBody
    </Modal>
  }
}

@react.component
let make = () => {
  open APIUtils
  open LogicUtils
  open OMPSwitchUtils
  open OMPSwitchHelper
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let showToast = ToastState.useShowToast()
  let merchSwitch = OMPSwitchHooks.useMerchantSwitch()
  let {userInfo: {merchantId}} = React.useContext(UserInfoProvider.defaultContext)
  let (showModal, setShowModal) = React.useState(_ => false)
  let (merchantList, setMerchantList) = Recoil.useRecoilState(HyperswitchAtom.merchantListAtom)
  let (showSwitchingMerch, setShowSwitchingMerch) = React.useState(_ => false)
  let (arrow, setArrow) = React.useState(_ => false)

  let getMerchantList = async () => {
    try {
      let url = getURL(~entityName=USERS, ~userType=#LIST_MERCHANT, ~methodType=Get)
      let response = await fetchDetails(url)
      setMerchantList(_ => response->getArrayDataFromJson(merchantItemToObjMapper))
    } catch {
    | _ => {
        setMerchantList(_ => ompDefaultValue(merchantId, ""))
        showToast(~message="Failed to fetch merchant list", ~toastType=ToastError)
      }
    }
  }

  let switchMerch = async value => {
    try {
      setShowSwitchingMerch(_ => true)
      let _ = await merchSwitch(~expectedMerchantId=value, ~currentMerchantId=merchantId)
      setShowSwitchingMerch(_ => false)
    } catch {
    | _ => {
        showToast(~message="Failed to switch merchant", ~toastType=ToastError)
        setShowSwitchingMerch(_ => false)
      }
    }
  }

  let input: ReactFinalForm.fieldRenderPropsInput = {
    name: "name",
    onBlur: _ => (),
    onChange: ev => {
      let value = ev->Identity.formReactEventToString
      switchMerch(value)->ignore
    },
    onFocus: _ => (),
    value: merchantId->JSON.Encode.string,
    checked: true,
  }

  let customHRTagStyle = "border-t border-blue-830"
  let customPadding = "py-1 w-full"
  let customStyle = "w-56 text-gray-200 bg-blue-840 dark:bg-black hover:bg-popover-background-hover hover:text-gray-100 !w-full"
  let customScrollStyle = "max-h-72 overflow-scroll px-1 pt-1"
  React.useEffect(() => {
    getMerchantList()->ignore
    None
  }, [])

  let toggleChevronState = () => {
    setArrow(prev => !prev)
  }

  <div className="border border-popover-background rounded w-5/6">
    <SelectBox.BaseDropdown
      allowMultiSelect=false
      buttonText=""
      input
      deselectDisable=true
      customButtonStyle="!rounded-md"
      options={merchantList->generateDropdownOptions}
      marginTop="mt-14"
      hideMultiSelectButtons=true
      addButton=false
      customStyle="bg-blue-840 hover:bg-popover-background-hover rounded !w-full"
      customSelectStyle="md:bg-blue-840 hover:bg-popover-background-hover rounded"
      searchable=false
      baseComponent={<ListBaseComp
        heading="Merchant" subHeading={currentOMPName(merchantList, merchantId)} arrow
      />}
      baseComponentCustomStyle="bg-popover-background border-blue-820 rounded text-white"
      bottomComponent={<AddNewMerchantProfileButton
        user="merchant" setShowModal customPadding customStyle customHRTagStyle
      />}
      optionClass="text-gray-200 text-fs-14"
      selectClass="text-gray-200 text-fs-14"
      customDropdownOuterClass="!border-none !w-full"
      fullLength=true
      toggleChevronState
      customScrollStyle
    />
    <RenderIf condition={showModal}>
      <NewAccountCreationModal setShowModal showModal getMerchantList />
    </RenderIf>
    <LoaderModal
      showModal={showSwitchingMerch}
      setShowModal={setShowSwitchingMerch}
      text="Switching merchant..."
    />
  </div>
}
