open ProductSelectionState
open ProductTypes

module SwitchMerchantBody = {
  @react.component
  let make = (~merchantDetails: OMPSwitchTypes.ompListTypes, ~setShowModal, ~selectedProduct) => {
    let internalSwitch = OMPSwitchHooks.useInternalSwitch()
    let showToast = ToastState.useShowToast()

    let switchMerch = async () => {
      try {
        let version = UserUtils.getVersion(selectedProduct)
        let _ = await internalSwitch(~expectedMerchantId=Some(merchantDetails.id), ~version)
      } catch {
      | _ => showToast(~message="Failed to switch merchant", ~toastType=ToastError)
      }
      setShowModal(_ => false)
    }

    React.useEffect(() => {
      switchMerch()->ignore
      None
    }, [])
    <div className="flex flex-col items-center gap-2">
      <Loader />
      <div className="text-xl font-semibold mb-4"> {"Switching merchant...."->React.string} </div>
    </div>
  }
}

module SelectMerchantBody = {
  @react.component
  let make = (
    ~setShowModal,
    ~merchantList: array<OMPSwitchTypes.ompListTypes>,
    ~selectedProduct: ProductTypes.productTypes,
  ) => {
    open LogicUtils
    let url = RescriptReactRouter.useUrl()
    let internalSwitch = OMPSwitchHooks.useInternalSwitch()
    let showToast = ToastState.useShowToast()
    let merchantDetailsTypedValue =
      HyperswitchAtom.merchantDetailsValueAtom->Recoil.useRecoilValueFromAtom

    let dropDownOptions =
      merchantList
      ->Array.filter(item => {
        switch item.productType {
        | Some(prodType) => prodType == selectedProduct
        | None => false
        }
      })
      ->Array.map((item: OMPSwitchTypes.ompListTypes): SelectBox.dropdownOption => {
        {
          label: `${item.name->String.length > 0 ? item.name : item.id} - ${item.id}`,
          value: item.id,
        }
      })

    let getFirstValueForDropdown = dropDownOptions->getValueFromArray(
      0,
      {
        label: "",
        value: "",
      },
    )

    let initialValues =
      [
        ("merchant_selected", getFirstValueForDropdown.value->JSON.Encode.string),
      ]->getJsonFromArrayOfJson

    let merchantName = FormRenderer.makeFieldInfo(
      ~label="Merchant ID",
      ~name="merchant_selected",
      ~customInput=InputFields.selectInput(
        ~options=dropDownOptions,
        ~buttonText="Select Field",
        ~deselectDisable=true,
        ~customButtonStyle="!w-full pr-4 pl-2",
        ~fullLength=true,
      ),
      ~isRequired=true,
    )

    let onSubmit = async (values, _) => {
      try {
        let dict = values->getDictFromJsonObject
        let merchantid = dict->getString("merchant_selected", "")->String.trim
        let version = UserUtils.getVersion(selectedProduct)

        let _ = await internalSwitch(~expectedMerchantId=Some(merchantid), ~version)
      } catch {
      | _ => showToast(~message="Failed to switch merchant", ~toastType=ToastError)
      }
      setShowModal(_ => false)
      Nullable.null
    }

    let validateForm = (values: JSON.t) => {
      let errors = Dict.make()
      let merchant_selected =
        values->getDictFromJsonObject->getString("merchant_selected", "")->String.trim

      if merchant_selected->isEmptyString {
        Dict.set(errors, "company_name", "Merchant cannot be emoty"->JSON.Encode.string)
      }

      errors->JSON.Encode.object
    }

    <div>
      <div className="pt-2 mx-4 my-2  flex justify-between">
        <CardUtils.CardHeader
          heading={`Merchant Selection for ${selectedProduct->ProductUtils.getProductDisplayName}`}
          subHeading=""
          customHeadingStyle="!text-lg font-semibold"
          customSubHeadingStyle="w-full !max-w-none "
        />
        <div
          className="h-fit"
          onClick={_ => {
            let currentUrl = GlobalVars.extractModulePath(
              ~path=url.path,
              ~end=url.path->List.toArray->Array.length,
            )
            setShowModal(_ => false)
            let productUrl = ProductUtils.getProductUrl(
              ~productType=merchantDetailsTypedValue.product_type,
              ~url=currentUrl,
            )
            RescriptReactRouter.replace(productUrl)
          }}>
          <Icon name="modal-close-icon" className="cursor-pointer text-gray-500" size=30 />
        </div>
      </div>
      <hr />
      <Form key="new-merchant-creation" onSubmit initialValues validate={validateForm}>
        <div className="flex flex-col h-full w-full">
          <span className="text-sm text-gray-400 font-medium mx-4 mt-4">
            {"Select the appropriate Merchant from the list of ID's created for this module."->React.string}
          </span>
          <div className="py-4">
            <FormRenderer.DesktopRow>
              <FormRenderer.FieldRenderer
                fieldWrapperClass="w-full"
                field={merchantName}
                showErrorOnChange=true
                errorClass={ProdVerifyModalUtils.errorClass}
                labelClass="!text-black font-medium"
              />
            </FormRenderer.DesktopRow>
          </div>
          <div className="flex justify-end w-full p-3">
            <FormRenderer.SubmitButton
              text="Select Merchant" buttonSize=Small customSumbitButtonStyle="w-full mb-2"
            />
          </div>
        </div>
      </Form>
    </div>
  }
}

module CreateNewMerchantBody = {
  @react.component
  let make = (~setShowModal, ~selectedProduct: productTypes) => {
    open APIUtils
    open LogicUtils

    let url = RescriptReactRouter.useUrl()
    let getURL = useGetURL()
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let updateDetails = useUpdateMethod()
    let showToast = ToastState.useShowToast()
    let internalSwitch = OMPSwitchHooks.useInternalSwitch()
    let merchantDetailsTypedValue =
      HyperswitchAtom.merchantDetailsValueAtom->Recoil.useRecoilValueFromAtom
    let merchantList = Recoil.useRecoilValueFromAtom(HyperswitchAtom.merchantListAtom)
    let initialValues = React.useMemo(() => {
      let dict = Dict.make()
      let productName = selectedProduct->ProductUtils.getProductStringName
      let display_product_name = selectedProduct->ProductUtils.getProductStringDisplayName
      dict->Dict.set("product_type", productName->JSON.Encode.string)
      let randomString = randomString(~length=10)
      dict->Dict.set("company_name", JSON.Encode.string(`${display_product_name}_${randomString}`))
      dict->JSON.Encode.object
    }, [selectedProduct])

    let switchMerch = async merchantid => {
      try {
        let version = UserUtils.getVersion(selectedProduct)

        let _ = await internalSwitch(~expectedMerchantId=Some(merchantid), ~version)
      } catch {
      | _ => showToast(~message="Failed to switch merchant", ~toastType=ToastError)
      }
    }

    let onSubmit = async (values, _) => {
      try {
        let dict = values->getDictFromJsonObject
        let trimmedData = dict->getString("company_name", "")->String.trim
        Dict.set(dict, "company_name", trimmedData->JSON.Encode.string)

        let res = switch selectedProduct {
        | Orchestration(V1)
        | DynamicRouting
        | CostObservability => {
            let url = getURL(~entityName=V1(USERS), ~userType=#CREATE_MERCHANT, ~methodType=Post)
            await updateDetails(url, values, Post)
          }
        | _ => {
            let url = getURL(~entityName=V2(USERS), ~userType=#CREATE_MERCHANT, ~methodType=Post)
            await updateDetails(url, values, Post, ~version=V2)
          }
        }
        mixpanelEvent(~eventName="create_new_merchant", ~metadata=values)

        let merchantID = res->getDictFromJsonObject->getString("merchant_id", "")
        let _ = await switchMerch(merchantID)
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
      let regexForCompanyName = "^([a-z]|[A-Z]|[0-9]|_|\\s)+$"
      let isDuplicate =
        merchantList->Array.some(merchant =>
          merchant.name->String.toLowerCase == companyName->String.toLowerCase
        )
      let errorMessage = if companyName->isEmptyString {
        "Merchant name cannot be empty"
      } else if companyName->String.length > 64 {
        "Merchant name cannot exceed 64 characters"
      } else if !RegExp.test(RegExp.fromString(regexForCompanyName), companyName) {
        "Merchant name should not contain special characters"
      } else if isDuplicate {
        "Merchant with this name already exists in this organization"
      } else {
        ""
      }

      if errorMessage->isNonEmptyString {
        Dict.set(errors, "company_name", errorMessage->JSON.Encode.string)
      }

      errors->JSON.Encode.object
    }

    <div className="">
      <div className="pt-3 m-3 flex justify-between">
        <CardUtils.CardHeader
          heading="Add a new merchant"
          subHeading=""
          customSubHeadingStyle="w-full !max-w-none pr-10"
        />
        <div
          className="h-fit"
          onClick={_ => {
            let currentUrl = GlobalVars.extractModulePath(
              ~path=url.path,
              ~end=url.path->List.toArray->Array.length,
            )
            setShowModal(_ => false)
            let productUrl = ProductUtils.getProductUrl(
              ~productType=merchantDetailsTypedValue.product_type,
              ~url=currentUrl,
            )
            RescriptReactRouter.replace(productUrl)
          }}>
          <Icon name="modal-close-icon" className="cursor-pointer" size=30 />
        </div>
      </div>
      <hr />
      <Form key="new-merchant-creation" onSubmit initialValues validate={validateForm}>
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
}

module ModalBody = {
  @react.component
  let make = (~action, ~setShowModal, ~selectedProduct) => {
    switch action {
    | CreateNewMerchant => <CreateNewMerchantBody setShowModal selectedProduct />
    | SwitchToMerchant(merchantDetails) =>
      <SwitchMerchantBody merchantDetails setShowModal selectedProduct />
    | SelectMerchantToSwitch(merchantDetails) =>
      <SelectMerchantBody setShowModal merchantList={merchantDetails} selectedProduct />
    }
  }
}

module ProductExistModal = {
  @react.component
  let make = (~showModal, ~setShowModal, ~action, ~selectedProduct) => {
    <Modal
      showModal
      closeOnOutsideClick=false
      setShowModal
      childClass="p-0"
      borderBottom=true
      modalClass="w-full !max-w-lg mx-auto my-auto dark:!bg-jp-gray-lightgray_background">
      <ModalBody setShowModal action selectedProduct />
    </Modal>
  }
}

open SessionStorage
let currentProductValue =
  sessionStorage.getItem("product")
  ->Nullable.toOption
  ->Option.getOr("orchestration")

let defaultContext = React.createContext(
  defaultValueOfProductProvider(~currentProductValue, ~version=V1),
)

module Provider = {
  let make = React.Context.provider(defaultContext)
}

@react.component
let make = (~children) => {
  let merchantList: array<OMPSwitchTypes.ompListTypes> = Recoil.useRecoilValueFromAtom(
    HyperswitchAtom.merchantListAtom,
  )
  let {userInfo: {version}} = React.useContext(UserInfoProvider.defaultContext)
  let (activeProduct, setActiveProduct) = React.useState(_ =>
    currentProductValue->ProductUtils.getProductVariantFromString(~version)
  )
  let (action, setAction) = React.useState(_ => None)
  let (showModal, setShowModal) = React.useState(_ => false)
  let (selectedProduct, setSelectedProduct) = React.useState(_ => None)

  let setCreateNewMerchant = product => {
    setShowModal(_ => true)
    setAction(_ => Some(CreateNewMerchant))
    setSelectedProduct(_ => Some(product))
  }

  let setSwitchToMerchant = (merchantDetails, product) => {
    setShowModal(_ => true)
    setAction(_ => Some(SwitchToMerchant(merchantDetails)))
    setSelectedProduct(_ => Some(product))
  }

  let setSelectMerchantToSwitch = merchantList => {
    setShowModal(_ => true)
    setAction(_ => Some(SelectMerchantToSwitch(merchantList)))
  }

  let onProductSelectClick = product => {
    let productVariant = product->ProductUtils.getProductVariantFromDisplayName
    setSelectedProduct(_ => Some(product->ProductUtils.getProductVariantFromDisplayName))

    let midsWithProductValue = merchantList->Array.filter(mid => {
      mid.productType->Option.mapOr(false, productVaule => {
        switch (productVaule, productVariant) {
        | (Orchestration(v1), Orchestration(v2)) => v1 == v2
        | (produceValue, productVariant) => produceValue == productVariant ? true : false
        }
      })
    })

    if midsWithProductValue->Array.length == 0 {
      setCreateNewMerchant(productVariant)
    } else if midsWithProductValue->Array.length == 1 {
      let merchantIdToSwitch =
        midsWithProductValue
        ->Array.get(0)
        ->Option.getOr({
          name: "",
          id: "",
          productType: Orchestration(V1),
        })

      setSwitchToMerchant(merchantIdToSwitch, productVariant)
    } else if midsWithProductValue->Array.length > 1 {
      setSelectMerchantToSwitch(midsWithProductValue)
    } else {
      setAction(_ => None)
    }
  }
  let setActiveProductValue = product => {
    setActiveProduct(_ => product)
  }

  let merchantHandle = React.useMemo(() => {
    switch action {
    | Some(actionVariant) =>
      <ProductExistModal
        showModal
        setShowModal
        action={actionVariant}
        selectedProduct={selectedProduct->Option.getOr(Vault)}
      />
    | None => React.null
    }
  }, (action, showModal))

  <Provider
    value={
      setCreateNewMerchant,
      setSwitchToMerchant,
      setSelectMerchantToSwitch,
      onProductSelectClick,
      activeProduct,
      setActiveProductValue,
    }>
    children
    {merchantHandle}
  </Provider>
}
