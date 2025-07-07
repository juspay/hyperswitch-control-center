module NewMerchantCreationModal = {
  @react.component
  let make = (~setShowModal, ~showModal, ~getMerchantList) => {
    open APIUtils
    open LogicUtils
    let getURL = useGetURL()
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let updateDetails = useUpdateMethod()
    let showToast = ToastState.useShowToast()
    let {activeProduct} = React.useContext(ProductSelectionProvider.defaultContext)
    let merchantList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.merchantListAtom)
    let createNewMerchant = async values => {
      try {
        switch activeProduct {
        | Orchestration(V1)
        | DynamicRouting
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
  open APIUtils
  open LogicUtils
  open OMPSwitchUtils
  open OMPSwitchHelper
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let showToast = ToastState.useShowToast()
  let internalSwitch = OMPSwitchHooks.useInternalSwitch()
  let {userInfo: {merchantId}} = React.useContext(UserInfoProvider.defaultContext)
  let (showModal, setShowModal) = React.useState(_ => false)
  let (merchantList, setMerchantList) = Recoil.useRecoilState(HyperswitchAtom.merchantListAtom)
  let isMobileView = MatchMedia.useMobileChecker()
  let merchantDetailsTypedValue = Recoil.useRecoilValueFromAtom(
    HyperswitchAtom.merchantDetailsValueAtom,
  )
  let (showSwitchingMerch, setShowSwitchingMerch) = React.useState(_ => false)
  let (arrow, setArrow) = React.useState(_ => false)
  let {
    globalUIConfig: {
      sidebarColor: {backgroundColor, primaryTextColor, borderColor, secondaryTextColor},
    },
  } = React.useContext(ThemeProvider.themeContext)
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let {devModularityV2} = featureFlagDetails
  let {setActiveProductValue} = React.useContext(ProductSelectionProvider.defaultContext)

  let getV2MerchantList = async () => {
    try {
      let v2MerchantListUrl = getURL(
        ~entityName=V2(USERS),
        ~userType=#LIST_MERCHANT,
        ~methodType=Get,
      )
      let v2MerchantResponse = await fetchDetails(v2MerchantListUrl, ~version=V2)
      v2MerchantResponse->getArrayFromJson([])
    } catch {
    | _ => []
    }
  }
  let getMerchantList = async () => {
    try {
      let v1MerchantListUrl = getURL(
        ~entityName=V1(USERS),
        ~userType=#LIST_MERCHANT,
        ~methodType=Get,
      )
      let v1MerchantResponse = await fetchDetails(v1MerchantListUrl)

      let v2MerchantList = if devModularityV2 {
        await getV2MerchantList()
      } else {
        []
      }
      let concatenatedList = v1MerchantResponse->getArrayFromJson([])->Array.concat(v2MerchantList)
      let response = concatenatedList->uniqueObjectFromArrayOfObjects(keyExtractorForMerchantid)
      let concatenatedListTyped = response->getMappedValueFromArrayOfJson(merchantItemToObjMapper)
      setMerchantList(_ => concatenatedListTyped)
    } catch {
    | _ => {
        setMerchantList(_ => [ompDefaultValue(merchantId, "")])
        showToast(~message="Failed to fetch merchant list", ~toastType=ToastError)
      }
    }
  }

  let switchMerch = async value => {
    try {
      setShowSwitchingMerch(_ => true)
      let merchantData =
        merchantList
        ->Array.find(merchant => merchant.id == value)
        ->Option.getOr(ompDefaultValue(merchantId, ""))
      let version = merchantData.version->Option.getOr(UserInfoTypes.V1)
      let productType = merchantData.productType->Option.getOr(Orchestration(V1))
      let _ = await internalSwitch(~expectedMerchantId=Some(value), ~version, ~changePath=true)
      setActiveProductValue(productType)
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

  React.useEffect(() => {
    getMerchantList()->ignore
    None
  }, [merchantDetailsTypedValue.merchant_name])

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
        getMerchantList
        switchMerch
      />
    let listItem: OMPSwitchTypes.ompListTypesCustom = {
      id: item.id,
      name: item.name,
      customComponent,
    }
    listItem
  })

  <div className="w-fit">
    <SelectBox.BaseDropdown
      allowMultiSelect=false
      buttonText=""
      input
      deselectDisable=true
      options={updatedMerchantList->generateDropdownOptionsCustomComponent}
      marginTop={`mt-12 ${borderColor} shadow-generic_shadow`}
      hideMultiSelectButtons=true
      addButton=false
      customStyle={`!border-none w-fit ${backgroundColor.sidebarSecondary} !${borderColor} `}
      searchable=true
      baseComponent={<ListBaseComp user=#Merchant heading="Merchant" subHeading arrow />}
      baseComponentCustomStyle={`!border-none`}
      bottomComponent={<AddNewOMPButton
        user=#Merchant
        setShowModal
        customStyle={`${backgroundColor.sidebarSecondary} ${primaryTextColor} ${borderColor} !border-none`}
        addItemBtnStyle
        customHRTagStyle={`${borderColor}`}
      />}
      toggleChevronState
      customScrollStyle
      dropdownContainerStyle
      shouldDisplaySelectedOnTop=true
      customSearchStyle={`${backgroundColor.sidebarSecondary} ${secondaryTextColor} ${borderColor}`}
      searchInputPlaceHolder="Search Merchant Account or ID"
      placeholderCss={`text-fs-13 ${backgroundColor.sidebarSecondary}`}
    />
    <RenderIf condition={showModal}>
      <NewMerchantCreationModal setShowModal showModal getMerchantList />
    </RenderIf>
    <LoaderModal
      showModal={showSwitchingMerch}
      setShowModal={setShowSwitchingMerch}
      text="Switching merchant..."
    />
  </div>
}
