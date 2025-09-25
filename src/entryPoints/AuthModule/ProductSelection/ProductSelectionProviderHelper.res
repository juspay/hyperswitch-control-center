module SwitchMerchantBody = {
  @react.component
  let make = (
    ~merchantDetails: OMPSwitchTypes.ompListTypes,
    ~setShowModal,
    ~selectedProduct,
    ~setActiveProductValue,
  ) => {
    open Typography
    let internalSwitch = OMPSwitchHooks.useInternalSwitch(~setActiveProductValue)
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
      <div className={`${heading.md.semibold} mb-4`}>
        {"Switching merchant...."->React.string}
      </div>
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
    open Typography
    open LogicUtils
    let internalSwitch = OMPSwitchHooks.useInternalSwitch(~setActiveProductValue)
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
        ~customButtonStyle="pr-4 pl-2",
        ~fullLength=true,
        ~textStyle="!max-w-400 overflow-hidden",
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
          customHeadingStyle={`!${body.lg.semibold}`}
          customSubHeadingStyle="w-full !max-w-none "
        />
        <div
          className="h-fit"
          onClick={_ => {
            setActiveProductValue(merchantDetailsTypedValue.product_type)
            setShowModal(_ => false)
          }}>
          <Icon name="modal-close-icon" className="cursor-pointer nd_gray-500" size=30 />
        </div>
      </div>
      <hr />
      <Form key="new-merchant-creation" onSubmit initialValues validate={validateForm}>
        <div className="flex flex-col h-full w-full">
          <span className={`${body.md.medium} text-nd_gray-400  mx-4 mt-4`}>
            {"Select the appropriate Merchant from the list of ID's created for this module."->React.string}
          </span>
          <div className="py-4">
            <FormRenderer.DesktopRow>
              <FormRenderer.FieldRenderer
                fieldWrapperClass="w-full"
                field={merchantName}
                showErrorOnChange=true
                errorClass={ProdVerifyModalUtils.errorClass}
                labelClass={`!text-black ${body.md.medium}`}
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
open ProductTypes
module CreateNewMerchantBody = {
  @react.component
  let make = (~setShowModal, ~selectedProduct: productTypes, ~setActiveProductValue) => {
    open APIUtils
    open LogicUtils
    open Typography
    let getURL = useGetURL()
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let updateDetails = useUpdateMethod()
    let showToast = ToastState.useShowToast()
    let internalSwitch = OMPSwitchHooks.useInternalSwitch(~setActiveProductValue)
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
        | Recon(V1)
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
      | _ =>
        setActiveProductValue(merchantDetailsTypedValue.product_type)
        showToast(~toastType=ToastError, ~message="Merchant Creation Failed", ~autoClose=true)
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
            setActiveProductValue(merchantDetailsTypedValue.product_type)
            setShowModal(_ => false)
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
                labelClass={`!text-black ${body.md.medium} !-ml-[0.5px]`}
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
