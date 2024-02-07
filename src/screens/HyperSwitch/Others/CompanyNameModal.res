@react.component
let make = (~showModal, ~setShowModal) => {
  open APIUtils
  open LogicUtils
  let showToast = ToastState.useShowToast()
  let updateDetails = useUpdateMethod(~showErrorToast=false, ())
  let merchantId = HSLocalStorage.getFromMerchantDetails("merchant_id")
  let setMerchantDetailsValue = Recoil.useSetRecoilState(HyperswitchAtom.merchantDetailsValueAtom)

  let (isDisabled, setIsDisabled) = React.useState(_ => false)

  let onSubmit = async (values, _) => {
    try {
      let accountUrl = getURL(
        ~entityName=MERCHANT_ACCOUNT,
        ~methodType=Post,
        ~id=Some(merchantId),
        (),
      )
      let body =
        [
          ("merchant_id", merchantId->JSON.Encode.string),
          (
            "merchant_name",
            values->getDictFromJsonObject->getString("merchant_name", "")->JSON.Encode.string,
          ),
        ]
        ->Dict.fromArray
        ->JSON.Encode.object
      let merchantDetails = await updateDetails(accountUrl, body, Post, ())
      setMerchantDetailsValue(._ => merchantDetails->JSON.stringify)
      showToast(~message=`Successfully updated business details`, ~toastType=ToastSuccess, ())
      setShowModal(_ => false)
    } catch {
    | _ => {
        showToast(~message=`Please try again!`, ~toastType=ToastError, ())
        setShowModal(_ => true)
      }
    }
    Nullable.null
  }

  let validateForm = values => {
    let merchantNameVal = values->getDictFromJsonObject->getString("merchant_name", "")
    if merchantNameVal->isEmptyString {
      setIsDisabled(_ => true)
    } else {
      setIsDisabled(_ => false)
    }
    JSON.Encode.null
  }

  <Modal
    showModal
    paddingClass=""
    modalHeading="Welcome aboard! Let's get started"
    setShowModal
    showCloseIcon=false
    modalHeadingDescription="Start by creating your business profile"
    modalClass="w-full max-w-lg m-auto !bg-white dark:!bg-jp-gray-lightgray_background">
    <Form
      key="merchant_name-validation"
      initialValues={Dict.make()->JSON.Encode.object}
      onSubmit
      validate={values => values->validateForm}>
      <div className="flex flex-col gap-6 h-full w-full">
        <FormRenderer.DesktopRow>
          <FormRenderer.FieldRenderer
            fieldWrapperClass="w-full"
            field={FormRenderer.makeFieldInfo(
              ~label="Business name",
              ~name="merchant_name",
              ~placeholder="Eg: HyperSwitch Pvt Ltd",
              ~customInput=InputFields.textInput(),
              ~isRequired=true,
              (),
            )}
            labelClass="!text-black font-medium !-ml-[0.5px]"
          />
        </FormRenderer.DesktopRow>
        <div className="flex justify-end w-full pr-5 pb-3">
          <FormRenderer.SubmitButton
            text="Start Exploring" buttonSize={Small} disabledParamter=isDisabled
          />
        </div>
      </div>
    </Form>
  </Modal>
}
