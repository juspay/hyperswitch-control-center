open ProductSelectionState
open ProductTypes

module SwitchMerchantBody = {
  @react.component
  let make = (
    ~merchantDetails: OMPSwitchTypes.ompListTypes,
    ~setShowModal,
    ~selectedProduct,
    ~setActiveProductValue,
  ) => {
    let internalSwitch = OMPSwitchHooks.useInternalSwitch()
    let showToast = ToastState.useShowToast()

    let switchMerch = async () => {
      try {
        let version = UserUtils.getVersion(selectedProduct)
        let _ = await internalSwitch(~expectedMerchantId=Some(merchantDetails.id), ~version)
        setActiveProductValue(selectedProduct)
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
    ~setActiveProductValue,
  ) => {
    open LogicUtils
    let internalSwitch = OMPSwitchHooks.useInternalSwitch()
    let showToast = ToastState.useShowToast()
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

    let merchantName = FormRenderer.makeFieldInfo(
      ~label="Merchant to switch",
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
        setActiveProductValue(selectedProduct)
        switch selectedProduct {
        | Orchestration => RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/home"))
        | _ =>
          RescriptReactRouter.replace(
            GlobalVars.appendDashboardPath(
              ~url=`/v2/${(Obj.magic(selectedProduct) :> string)->String.toLowerCase}/home`,
            ),
          )
        }
      } catch {
      | _ => showToast(~message="Failed to switch merchant", ~toastType=ToastError)
      }
      setShowModal(_ => false)
      Nullable.null
    }

    <div>
      <div className="pt-3 m-3 flex justify-between">
        <CardUtils.CardHeader
          heading="Merchant Selection"
          subHeading=""
          customSubHeadingStyle="w-full !max-w-none pr-10"
        />
        <div className="h-fit" onClick={_ => setShowModal(_ => false)}>
          <Icon name="modal-close-icon" className="cursor-pointer" size=30 />
        </div>
      </div>
      <hr />
      <Form key="new-merchant-creation" onSubmit>
        <div className="flex flex-col h-full w-full">
          <div className="py-10">
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
          <hr className="mt-4" />
          <div className="flex justify-end w-full p-3">
            <FormRenderer.SubmitButton text="Switch to merchant" buttonSize=Small />
          </div>
        </div>
      </Form>
    </div>
  }
}

module CreateNewMerchantBody = {
  @react.component
  let make = (~setShowModal, ~selectedProduct: productTypes, ~setActiveProductValue) => {
    open APIUtils
    open LogicUtils
    let getURL = useGetURL()
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let updateDetails = useUpdateMethod()
    let showToast = ToastState.useShowToast()
    let internalSwitch = OMPSwitchHooks.useInternalSwitch()

    let initialValues = React.useMemo(() => {
      let dict = Dict.make()
      dict->Dict.set("product_type", (Obj.magic(selectedProduct) :> string)->JSON.Encode.string)
      dict->JSON.Encode.object
    }, [selectedProduct])

    let switchMerch = async merchantid => {
      try {
        let version = UserUtils.getVersion(selectedProduct)

        let _ = await internalSwitch(~expectedMerchantId=Some(merchantid), ~version)
        setActiveProductValue(selectedProduct)
        let productUrl = ProductUtils.getProductUrl(~productType=selectedProduct, ~url="/home")
        RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url=productUrl))
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
        | Orchestration
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
      | err => {
          Js.log(err)
          showToast(~toastType=ToastError, ~message="Merchant Creation Failed", ~autoClose=true)
        }
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
      <Form key="new-merchant-creation" onSubmit initialValues>
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
  let make = (~action, ~setShowModal, ~selectedProduct, ~setActiveProductValue) => {
    switch action {
    | CreateNewMerchant =>
      <CreateNewMerchantBody setShowModal selectedProduct setActiveProductValue />
    | SwitchToMerchant(merchantDetails) =>
      <SwitchMerchantBody merchantDetails setShowModal selectedProduct setActiveProductValue />
    | SelectMerchantToSwitch(merchantDetails) =>
      <SelectMerchantBody
        setShowModal merchantList={merchantDetails} selectedProduct setActiveProductValue
      />
    }
  }
}

module ProductExistModal = {
  @react.component
  let make = (~showModal, ~setShowModal, ~action, ~selectedProduct, ~setActiveProductValue) => {
    <Modal
      showModal
      closeOnOutsideClick=true
      setShowModal
      childClass="p-0"
      borderBottom=true
      modalClass="w-full max-w-xl mx-auto my-auto dark:!bg-jp-gray-lightgray_background">
      <ModalBody setShowModal action selectedProduct setActiveProductValue />
    </Modal>
  }
}

open SessionStorage
let currentProductValue =
  sessionStorage.getItem("product")
  ->Nullable.toOption
  ->Option.getOr("orchestration")

let defaultContext = React.createContext(defaultValueOfProductProvider(~currentProductValue))

module Provider = {
  let make = React.Context.provider(defaultContext)
}

@react.component
let make = (~children) => {
  let merchantList: array<OMPSwitchTypes.ompListTypes> = Recoil.useRecoilValueFromAtom(
    HyperswitchAtom.merchantListAtom,
  )
  let (activeProduct, setActiveProduct) = React.useState(_ =>
    currentProductValue->ProductUtils.getProductVariantFromString
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
      mid.productType->Option.mapOr(false, productVaule => productVaule === productVariant)
    })

    if midsWithProductValue->Array.length == 0 {
      setAction(_ => None)
    } else if midsWithProductValue->Array.length == 1 {
      let merchantIdToSwitch =
        midsWithProductValue
        ->Array.get(0)
        ->Option.getOr({
          name: "",
          id: "",
          productType: Orchestration,
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
    sessionStorage.setItem("product", (Obj.magic(product) :> string))
  }

  let setDefaultProductToSessionStorage = productType => {
    open ProductUtils
    let currentSessionData = sessionStorage.getItem("product")->Nullable.toOption
    let data = switch currentSessionData {
    | Some(sessionData) => sessionData->getProductVariantFromString
    | None => productType
    }
    setActiveProductValue(data)
  }

  let merchantHandle = React.useMemo(() => {
    switch action {
    | Some(actionVariant) =>
      <ProductExistModal
        showModal
        setShowModal
        action={actionVariant}
        selectedProduct={selectedProduct->Option.getOr(Vault)}
        setActiveProductValue
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
      setDefaultProductToSessionStorage,
    }>
    children
    {merchantHandle}
  </Provider>
}
