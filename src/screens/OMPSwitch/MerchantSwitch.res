module ListBaseComp = {
  @react.component
  let make = () => {
    let {merchantId} = React.useContext(UserInfoProvider.defaultContext)
    let (arrow, setArrow) = React.useState(_ => false)

    <div
      className="flex items-center justify-center text-sm text-center text-white font-medium rounded hover:bg-opacity-80 bg-sidebar-blue"
      onClick={_ => setArrow(prev => !prev)}>
      <div className="flex flex-col items-start px-2 py-2">
        <p className="text-xs text-gray-400"> {"Merchant"->React.string} </p>
        <p className="fs-10"> {merchantId->React.string} </p>
      </div>
      <div className="px-2 py-2">
        <Icon
          className={arrow
            ? "-rotate-180 transition duration-[250ms] opacity-70"
            : "rotate-0 transition duration-[250ms] opacity-70"}
          name="arrow-without-tail-new"
          size=15
        />
      </div>
    </div>
  }
}

module AddNewMerchantButton = {
  @react.component
  let make = (~setShowModal) => {
    let userPermissionJson = Recoil.useRecoilValueFromAtom(HyperswitchAtom.userPermissionAtom)
    let cursorStyles = PermissionUtils.cursorStyles(userPermissionJson.merchantDetailsManage)
    <ACLDiv
      permission={userPermissionJson.merchantDetailsManage}
      onClick={_ => setShowModal(_ => true)}
      isRelative=false
      contentAlign=Default
      tooltipForWidthClass="!h-full"
      className={`${cursorStyles} py-1`}>
      {<>
        <hr className="border-t border-blue-830" />
        <div
          className="group flex gap-2 items-center font-medium w-56 px-2 py-2 text-sm text-gray-200 bg-blue-840 dark:bg-black hover:bg-popover-background-hover hover:text-gray-100">
          <Icon name="plus-circle" size=15 />
          {"Add new merchant"->React.string}
        </div>
      </>}
    </ACLDiv>
  }
}

module NewAccountCreationModal = {
  @react.component
  let make = (~setShowModal, ~showModal, ~setFetchUpdatedMerchantList) => {
    open APIUtils
    let getURL = useGetURL()
    let updateDetails = useUpdateMethod()
    let showToast = ToastState.useShowToast()
    let createNewAccount = async values => {
      try {
        let url = getURL(~entityName=USERS, ~userType=#CREATE_MERCHANT, ~methodType=Post)
        let _ = await updateDetails(url, values, Post)
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
      setFetchUpdatedMerchantList(prev => !prev)
      createNewAccount(values)
    }

    let merchantName = FormRenderer.makeFieldInfo(
      ~label="Merchant Name",
      ~name="company_name",
      ~placeholder="Eg: My New Merchant",
      ~customInput=InputFields.textInput(),
      ~isRequired=true,
    )

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
        <Form key="new-account-creation" onSubmit>
          <div className="flex flex-col gap-12 h-full w-full">
            <FormRenderer.DesktopRow>
              <div className="flex flex-col gap-5">
                <FormRenderer.FieldRenderer
                  fieldWrapperClass="w-full"
                  field={merchantName}
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
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let {merchantId} = React.useContext(UserInfoProvider.defaultContext)
  let (merchantList, setMerchantList) = React.useState(_ => JSON.Encode.null)
  let (showModal, setShowModal) = React.useState(_ => false)
  let (fetchUpdatedMerchantList, setFetchUpdatedMerchantList) = React.useState(_ => true)

  let getMerchantList = async () => {
    try {
      let url = getURL(~entityName=USERS, ~userType=#LIST_MERCHANT, ~methodType=Get)
      let response = await fetchDetails(url)
      setMerchantList(_ => response)
    } catch {
    | _ => ()
    }
  }

  React.useEffect(() => {
    getMerchantList()->ignore
    None
  }, [fetchUpdatedMerchantList])

  let merchantListArray =
    merchantList
    ->getArrayFromJson([])
    ->Array.map(item => {
      item->getDictFromJsonObject->getString("merchant_id", "")
    })

  let options = merchantListArray->SelectBox.makeOptions

  let input: ReactFinalForm.fieldRenderPropsInput = {
    name: "name",
    onBlur: _ => (),
    onChange: _ => (),
    onFocus: _ => (),
    value: merchantId->JSON.Encode.string,
    checked: true,
  }

  <div className="border border-popover-background rounded mx-2">
    <SelectBox.BaseDropdown
      allowMultiSelect=false
      buttonText=""
      input
      deselectDisable=true
      customButtonStyle="!rounded-md"
      options
      marginTop="mt-14"
      hideMultiSelectButtons=true
      addButton=false
      customStyle="bg-blue-840 hover:bg-popover-background-hover rounded !w-full"
      customSelectStyle="md:bg-blue-840 hover:bg-popover-background-hover rounded"
      searchable=false
      baseComponent={<ListBaseComp />}
      baseComponentCustomStyle="bg-popover-background border-blue-820 rounded"
      bottomComponent={<AddNewMerchantButton setShowModal />}
      optionClass="text-gray-200 text-fs-14"
      selectClass="text-gray-200 text-fs-14"
      customDropdownOuterClass="!border-none"
      showBorder=true
    />
    <RenderIf condition={showModal}>
      <NewAccountCreationModal setShowModal showModal setFetchUpdatedMerchantList />
    </RenderIf>
  </div>
}
