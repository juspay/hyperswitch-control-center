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
      open LogicUtils
      let dict = values->getDictFromJsonObject
      let trimmedData = dict->getString("company_name", "")->String.trim
      Dict.set(dict, "company_name", trimmedData->JSON.Encode.string)
      createNewAccount(dict->JSON.Encode.object)
    }

    let merchantName = FormRenderer.makeFieldInfo(
      ~label="Merchant Name",
      ~name="company_name",
      ~customInput=(~input, ~placeholder as _) =>
        InputFields.textInput()(
          ~input={
            ...input,
            onChange: event =>
              ReactEvent.Form.target(event)["value"]
              ->String.trimStart
              ->Identity.stringToFormReactEvent
              ->input.onChange,
          },
          ~placeholder="Eg: My New Merchant",
        ),
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
        "Merchant name cannot exceed 64 characters"
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
      <div className="">
        <div className="pt-3 m-3 flex justify-between">
          <CardUtils.CardHeader
            heading="Add a new merchant"
            subHeading=""
            customSubHeadingStyle="w-full !max-w-none pr-10"
          />
          <div className="h-fit" onClick={_ => setShowModal(_ => false)}>
            <Icon name="modal-close-icon" className="cursor-pointer" size=30 />
          </div>
        </div>
        <hr />
        <Form key="new-account-creation" onSubmit validate={validateForm}>
          <div className="flex flex-col h-full w-full">
            <div className="py-10">
              <FormRenderer.DesktopRow>
                <FormRenderer.FieldRenderer
                  fieldWrapperClass="w-full"
                  field={merchantName}
                  showErrorOnChange=true
                  errorClass={ProdVerifyModalUtils.errorClass}
                  labelClass="!text-black font-medium !-ml-[0.5px]"
                />
              </FormRenderer.DesktopRow>
            </div>
            <hr className="mt-4" />
            <div className="flex justify-end w-full p-3">
              <FormRenderer.SubmitButton text="Add Merchant" buttonSize=Small />
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

  let customStyle = "text-blue-500 bg-white dark:bg-black hover:bg-jp-gray-100 text-nowrap w-full"
  let addItemBtnStyle = "border border-t-0 w-full"
  let customScrollStyle = "max-h-72 overflow-scroll px-1 pt-1 border border-b-0"
  let dropdownContainerStyle = "rounded-md border border-1 w-[15rem]"

  React.useEffect(() => {
    getMerchantList()->ignore
    None
  }, [])

  let toggleChevronState = () => {
    setArrow(prev => !prev)
  }

  <div className="w-fit">
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
      customStyle="rounded w-fit"
      searchable=false
      baseComponent={<ListBaseComp
        heading="Merchant" subHeading={currentOMPName(merchantList, merchantId)} arrow
      />}
      baseComponentCustomStyle="bg-white rounded"
      bottomComponent={<AddNewMerchantProfileButton
        user="merchant" setShowModal customStyle addItemBtnStyle
      />}
      optionClass="text-gray-600 text-fs-14"
      selectClass="text-gray-600 text-fs-14"
      customDropdownOuterClass="!border-none w-fit"
      toggleChevronState
      customScrollStyle
      dropdownContainerStyle
      shouldDisplaySelectedOnTop=true
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
