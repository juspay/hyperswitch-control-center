module NewMerchantCreationModal = {
  @react.component
  let make = (~setShowModal, ~showModal) => {
    open APIUtils
    open LogicUtils
    let getURL = useGetURL()
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let updateDetails = useUpdateMethod()
    let showToast = ToastState.useShowToast()
    let {activeProduct} = React.useContext(ProductSelectionProvider.defaultContext)
    let merchantList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.merchantListAtom)
    let getMerchantList = MerchantListHook.useFetchMerchantList()
    let createNewMerchant = async values => {
      try {
        switch activeProduct {
        | Orchestration(V1)
        | DynamicRouting
        | Recon(V1)
        | CostObservability => {
            let url = getURL(~entityName=V1(USERS), ~userType=#CREATE_MERCHANT, ~methodType=Post)
            let _ = await updateDetails(url, values, Post)
          }
        | _ => {
            let url = getURL(~entityName=V2(USERS), ~userType=#CREATE_MERCHANT, ~methodType=Post)
            let _ = await updateDetails(url, values, Post, ~version=V2)
          }
        }
        mixpanelEvent(~eventName="create_new_merchant", ~metadata=values)
        getMerchantList()->ignore
        showToast(
          ~toastType=ToastSuccess,
          ~message="Merchant Created Successfully!",
          ~autoClose=true,
        )
      } catch {
      | _ => showToast(~toastType=ToastError, ~message="Merchant Creation Failed", ~autoClose=true)
      }

      setShowModal(_ => false)
      Nullable.null
    }

    let initialValues = React.useMemo(() => {
      let dict = Dict.make()
      dict->Dict.set(
        "product_type",
        activeProduct->ProductUtils.getProductStringName->String.toLowerCase->JSON.Encode.string,
      )
      dict->JSON.Encode.object
    }, [activeProduct])

    let onSubmit = (values, _) => {
      let dict = values->getDictFromJsonObject
      let trimmedData = dict->getString("company_name", "")->String.trim
      Dict.set(dict, "company_name", trimmedData->JSON.Encode.string)
      createNewMerchant(dict->JSON.Encode.object)
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
      let errors = Dict.make()
      let companyName = values->getDictFromJsonObject->getString("company_name", "")->String.trim
      let isDuplicate =
        merchantList->Array.some(merchant =>
          merchant.name->String.toLowerCase == companyName->String.toLowerCase
        )
      let regexForCompanyName = "^([a-z]|[A-Z]|[0-9]|_|\\s)+$"
      let errorMessage = if companyName->isEmptyString {
        "Merchant name cannot be empty"
      } else if companyName->String.length > 64 {
        "Merchant name cannot exceed 64 characters"
      } else if !RegExp.test(RegExp.fromString(regexForCompanyName), companyName) {
        "Merchant name should not contain special characters"
      } else if isDuplicate {
        "Merchant with this name already exists"
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
        <Form key="new-merchant-creation" onSubmit validate={validateForm} initialValues>
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
  open OMPSwitchUtils
  open OMPSwitchHelper
  let {setActiveProductValue} = React.useContext(ProductSelectionProvider.defaultContext)
  let showToast = ToastState.useShowToast()
  let internalSwitch = OMPSwitchHooks.useInternalSwitch(~setActiveProductValue)
  let {merchantId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  let (showModal, setShowModal) = React.useState(_ => false)
  let merchantList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.merchantListAtom)
  let isMobileView = MatchMedia.useMobileChecker()
  let (showSwitchingMerch, setShowSwitchingMerch) = React.useState(_ => false)
  let (arrow, setArrow) = React.useState(_ => false)
  let (isCurrentMerchantPlatform, isCurrentOrganizationPlatform) = OMPSwitchHooks.useOMPType()
  let {
    globalUIConfig: {
      sidebarColor: {backgroundColor, borderColor, primaryTextColor, secondaryTextColor},
    },
  } = React.useContext(ThemeProvider.themeContext)

  let switchMerch = async value => {
    try {
      setShowSwitchingMerch(_ => true)
      let merchantData =
        merchantList
        ->Array.find(merchant => merchant.id == value)
        ->Option.getOr(ompDefaultValue(merchantId, ""))
      let version = merchantData.version->Option.getOr(UserInfoTypes.V1)
      let _ = await internalSwitch(~expectedMerchantId=Some(value), ~version, ~changePath=true)
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

  let widthClass = isMobileView ? "w-full" : "md:w-60 md:max-w-80"
  let roundedClass = isMobileView ? "rounded-none" : "rounded-md"

  let addItemBtnStyle = `w-full ${borderColor} border-t-0`
  let customScrollStyle = `max-h-72 overflow-scroll px-1 pt-1 ${borderColor}`
  let dropdownContainerStyle = `${roundedClass} border border-1 ${borderColor} ${widthClass}`

  let subHeading = {currentOMPName(merchantList, merchantId)}

  let toggleChevronState = () => {
    setArrow(prev => !prev)
  }

  let updatedMerchantList: array<
    OMPSwitchTypes.ompListTypesCustom,
  > = merchantList->Array.mapWithIndex((item, i) => {
    let customComponent =
      <MerchantDropdownItem
        key={Int.toString(i)}
        merchantName=item.name
        productType={switch item.productType {
        | Some(product) => product
        | None => Orchestration(V1)
        }}
        index=i
        currentId=item.id
        switchMerch
      />
    let listItem: OMPSwitchTypes.ompListTypesCustom = {
      id: item.id,
      name: item.name,
      type_: item.type_->Option.getOr(#standard),
      customComponent,
    }
    listItem
  })

  <div className="w-fit flex flex-col gap-4">
    <SelectBox.BaseDropdown
      allowMultiSelect=false
      buttonText=""
      input
      deselectDisable=true
      options={updatedMerchantList->generateDropdownOptionsCustomComponent(
        ~isPlatformOrg=isCurrentOrganizationPlatform,
      )}
      marginTop={`mt-16 ${borderColor} shadow-generic_shadow ml-2`}
      hideMultiSelectButtons=true
      addButton=false
      customStyle={`!border-none w-fit ${backgroundColor.sidebarSecondary} !${borderColor} `}
      searchable=true
      baseComponent={<ListBaseComp
        user=#Merchant heading="Merchant" subHeading arrow isPlatform=isCurrentMerchantPlatform
      />}
      baseComponentCustomStyle="!border-none"
      bottomComponent={<AddNewOMPButton
        user=#Merchant
        setShowModal
        customStyle={`${backgroundColor.sidebarSecondary} ${primaryTextColor} ${borderColor} !border-none`}
        addItemBtnStyle
        customHRTagStyle={borderColor}
      />}
      toggleChevronState
      customScrollStyle
      dropdownContainerStyle
      shouldDisplaySelectedOnTop=true
      customSearchStyle={`${backgroundColor.sidebarSecondary} ${secondaryTextColor} ${borderColor}`}
      searchInputPlaceHolder="Search Merchant Account or ID"
      placeholderCss={`text-fs-13 ${backgroundColor.sidebarSecondary}`}
      reverseSortGroupKeys=true
    />
    <RenderIf condition={showModal}>
      <NewMerchantCreationModal setShowModal showModal />
    </RenderIf>
    <LoaderModal
      showModal={showSwitchingMerch}
      setShowModal={setShowSwitchingMerch}
      text="Switching merchant..."
    />
  </div>
}
