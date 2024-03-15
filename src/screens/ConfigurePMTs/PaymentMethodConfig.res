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
            ->Option.getOr(Js.Json.null)
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
    />
  }
}

let renderValueInp = (
  options: array<SelectBox.dropdownOption>,
  fieldsArray: array<ReactFinalForm.fieldRenderProps>,
) => {
  <PmtConfigInp options fieldsArray />
}
type valueInput = {
  label: string,
  name1: string,
  name2: string,
  options: array<SelectBox.dropdownOption>,
}
let valueInput = (inputArg: valueInput) => {
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
  ~config: string,
  ~setReferesh: unit => promise<unit>,
) => {
  open FormRenderer
  let (showPaymentMthdConfigModal, setShowPaymentMthdConfigModal) = React.useState(_ => false)
  let (initialValues, setInitialValues) = React.useState(_ => Dict.make()->JSON.Encode.object)
  let (currencies, setCurrencies) = React.useState(_ => [])
  let (countries, setCountries) = React.useState(_ => [])

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
  let showToast = ToastState.useShowToast()

  let getProcessorDetails = async () => {
    open LogicUtils
    try {
      let data =
        connectorList
        ->Array.filter(item =>
          item.merchant_connector_id === paymentMethodConfig.merchant_connector_id
        )
        ->Array.get(0)
        ->Option.getOr(Dict.make()->ConnectorListMapper.getProcessorPayloadType)
      let encodeConnectorPayload = data->PaymentMethodConfigUtils.encodeConnectorPayload
      let res = await fetchDetails(
        `http://localhost:8080/configs/?connector=${connector_name}&paymentMethodType=${payment_method_type}`,
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
      setShowPaymentMthdConfigModal(_ => true)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Something went wrong")
        let errorMessage = err->safeParse->getDictFromJsonObject->getString("message", "")
        showToast(~message=errorMessage, ~toastType=ToastError, ())
        setShowPaymentMthdConfigModal(_ => true)
      }
    }
  }

  let onSubmit = async (values, _) => {
    open LogicUtils
    try {
      let url = getURL(~entityName=CONNECTOR, ~methodType=Post, ~id=Some(merchant_connector_id), ())
      let _ = await updateDetails(url, values, Post, ())
      let _ = await setReferesh()
      setShowPaymentMthdConfigModal(_ => false)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Something went wrong")
        let errorMessage = err->safeParse->getDictFromJsonObject->getString("message", "")
        showToast(~message=errorMessage, ~toastType=ToastError, ())
        setShowPaymentMthdConfigModal(_ => true)
      }
    }
    Nullable.null
  }
  let id = `payment_methods_enabled[${payment_method_index->Int.toString}].payment_method_types[${payment_method_types_index->Int.toString}]`

  <div>
    <Modal
      childClass="p-0"
      showModal={showPaymentMthdConfigModal}
      showModalHeadingIconName={paymentMethodConfig.connector_name->String.toUpperCase}
      customIcon={Some(
        <GatewayIcon
          gateway={paymentMethodConfig.connector_name->String.toUpperCase} className="w-12 h-12"
        />,
      )}
      modalHeadingDescriptionElement={<div
        className="text-md font-medium leading-7 opacity-50 mt-1 w-full">
        {"Configure PMTs"->React.string}
      </div>}
      paddingClass=""
      modalHeading={paymentMethodConfig.payment_method->String.toUpperCase}
      setShowModal={setShowPaymentMthdConfigModal}
      modalHeadingDescription="Start by creating your business name"
      modalClass="w-full max-w-lg m-auto !bg-white dark:!bg-jp-gray-lightgray_background">
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
        <FormValuesSpy />
      </Form>
    </Modal>
    <div onClick={_ => getProcessorDetails()->ignore}>
      {config->String.length > 0 ? config->React.string : "NA"->React.string}
    </div>
  </div>
}
