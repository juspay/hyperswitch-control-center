module PmtConfigInp = {
  @react.component
  let make = (
    ~options: array<SelectBox.dropdownOption>,
    ~fieldsArray: array<ReactFinalForm.fieldRenderProps>,
  ) => {
    let enabledList = (fieldsArray[0]->Option.getOr(ReactFinalForm.fakeFieldRenderProps)).input
    let valueField = (fieldsArray[1]->Option.getOr(ReactFinalForm.fakeFieldRenderProps)).input
    let enableType = (fieldsArray[2]->Option.getOr(ReactFinalForm.fakeFieldRenderProps)).input

    let input: ReactFinalForm.fieldRenderPropsInput = {
      name: "string",
      onBlur: _ev => (),
      onChange: ev => {
        let value = ev->Identity.formReactEventToArrayOfString
        if value->Array.length <= 0 {
          valueField.onChange(
            None
            ->Option.map(JSON.Encode.object)
            ->Option.getOr(JSON.Encode.null)
            ->Identity.anyTypeToReactEvent,
          )
        } else {
          enabledList.onChange(value->Identity.anyTypeToReactEvent)
          enableType.onChange("enable_only"->Identity.anyTypeToReactEvent)
        }
      },
      onFocus: _ev => (),
      value: enabledList.value,
      checked: true,
    }
    <SelectBox.BaseDropdown
      allowMultiSelect=true
      buttonText="Select Value"
      input
      options
      hideMultiSelectButtons=true
      showSelectionAsChips={false}
      customButtonStyle="w-full"
      fullLength=true
      dropdownClassName={`${options->PaymentMethodConfigUtils.dropdownClassName}`}
    />
  }
}

let renderValueInp = (
  options: array<SelectBox.dropdownOption>,
  fieldsArray: array<ReactFinalForm.fieldRenderProps>,
) => {
  <PmtConfigInp options fieldsArray />
}

let valueInput = (inputArg: PaymentMethodConfigTypes.valueInput) => {
  open FormRenderer
  makeMultiInputFieldInfoOld(
    ~label=`${inputArg.label}`,
    ~comboCustomInput=renderValueInp(inputArg.options),
    ~inputFields=[
      makeInputFieldInfo(~name=`${inputArg.name1}`, ()),
      makeInputFieldInfo(~name=`${inputArg.name2}`, ()),
      makeInputFieldInfo(~name=`${inputArg.name2}.type`, ()),
    ],
    (),
  )
}

@react.component
let make = (
  ~paymentMethodConfig: PaymentMethodConfigTypes.paymentMethodConfiguration,
  ~config: string="",
  ~setReferesh: unit => promise<unit>,
  ~element: option<React.element>=?,
) => {
  open FormRenderer
  let permissionJson = Recoil.useRecoilValueFromAtom(HyperswitchAtom.userPermissionAtom)
  let (showPaymentMthdConfigModal, setShowPaymentMthdConfigModal) = React.useState(_ => false)
  let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->JSON.Encode.object)
  let (currencies, setCurrencies) = React.useState(_ => [])
  let (countries, setCountries) = React.useState(_ => [])
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Success)
  let {
    payment_method_index,
    payment_method_types_index,
    connector_name,
    payment_method_type,
    merchant_connector_id,
  } = paymentMethodConfig
  open APIUtils
  let connectorList = HyperswitchAtom.connectorListAtom->Recoil.useRecoilValueFromAtom
  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod()

  let getProcessorDetails = async () => {
    open LogicUtils
    try {
      setShowPaymentMthdConfigModal(_ => true)
      setScreenState(_ => Loading)
      let paymentMethoConfigUrl = getURL(~entityName=PAYMENT_METHOD_CONFIG, ~methodType=Get, ())
      let data =
        connectorList
        ->Array.filter(item =>
          item.merchant_connector_id === paymentMethodConfig.merchant_connector_id
        )
        ->getValueFromArray(0, Dict.make()->ConnectorListMapper.getProcessorPayloadType)
      let encodeConnectorPayload = data->PaymentMethodConfigUtils.encodeConnectorPayload
      let res = await fetchDetails(
        `${paymentMethoConfigUrl}?connector=${connector_name}&paymentMethodType=${payment_method_type}`,
      )
      let countries =
        res
        ->getDictFromJsonObject
        ->getArrayFromDict("countries", [])
        ->Array.map(item => {
          let dict = item->getDictFromJsonObject
          let a: SelectBox.dropdownOption = {
            label: dict->getString("name", ""),
            value: dict->getString("code", ""),
          }
          a
        })
      let currencies =
        res
        ->getDictFromJsonObject
        ->getArrayFromDict("currencies", [])
        ->Array.map(item => {
          let a: SelectBox.dropdownOption = {
            label: item->getStringFromJson(""),
            value: item->getStringFromJson(""),
          }
          a
        })
      setCountries(_ => countries)
      setCurrencies(_ => currencies)

      setInitialValues(_ => encodeConnectorPayload)
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => Error("Something went wrong"))
    }
  }

  let onSubmit = async (values, _) => {
    try {
      let url = getURL(~entityName=CONNECTOR, ~methodType=Post, ~id=Some(merchant_connector_id), ())
      let _ = await updateDetails(url, values, Post, ())
      let _ = await setReferesh()
      setShowPaymentMthdConfigModal(_ => false)
    } catch {
    | _ => setShowPaymentMthdConfigModal(_ => false)
    }
    Nullable.null
  }
  let id = `payment_methods_enabled[${payment_method_index->Int.toString}].payment_method_types[${payment_method_types_index->Int.toString}]`

  <>
    <UIUtils.RenderIf condition={showPaymentMthdConfigModal}>
      <Modal
        childClass="p-0"
        showModal={showPaymentMthdConfigModal}
        modalHeadingDescriptionElement={<div
          className="text-md font-medium leading-7 opacity-50 mt-1 w-full">
          {"Configure PMTs"->React.string}
        </div>}
        paddingClass=""
        modalHeading={paymentMethodConfig.payment_method_type->String.toUpperCase}
        setShowModal={setShowPaymentMthdConfigModal}
        modalClass="w-full max-w-lg m-auto !bg-white">
        <PageLoaderWrapper screenState sectionHeight="h-30-vh">
          <Form key="pmts-configuration" initialValues onSubmit={onSubmit}>
            <div className="p-5">
              <FieldRenderer
                field={valueInput({
                  name1: `${id}.accepted_countries.list`,
                  name2: `${id}.accepted_countries`,
                  label: `Countries`,
                  options: countries,
                })}
              />
              <FieldRenderer
                field={valueInput({
                  name1: `${id}.accepted_currencies.list`,
                  name2: `${id}.accepted_currencies`,
                  label: `Currencies`,
                  options: currencies,
                })}
              />
            </div>
            <hr className="w-full" />
            <div className="flex justify-end w-full pr-5 pb-3 mt-5">
              <FormRenderer.SubmitButton loadingText="Processing..." text="Submit" />
            </div>
            // <FormValuesSpy />
          </Form>
        </PageLoaderWrapper>
      </Modal>
    </UIUtils.RenderIf>
    <ACLDiv
      permission=permissionJson.connectorsManage
      className="cursor-pointer"
      onClick={_ => getProcessorDetails()->ignore}>
      {switch element {
      | Some(component) => component
      | _ => config->LogicUtils.isNonEmptyString ? config->React.string : "NA"->React.string
      }}
    </ACLDiv>
  </>
}
