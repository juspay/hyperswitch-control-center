open HSwitchSettingTypes
open MerchantAccountUtils
open APIUtils
open SettingsFieldsInfo

module InfoOnlyView = {
  @react.component
  let make = (~heading, ~subHeading="Default value") => {
    <div className="flex flex-col gap-2 m-2 md:m-4">
      <p className="font-semibold text-fs-13"> {heading->React.string} </p>
      <p className="font-medium text-fs-13 text-black opacity-50 break-words">
        {subHeading->React.string}
      </p>
    </div>
  }
}
module DetailsSection = {
  @react.component
  let make = (~details: fieldsInfoType, ~formState, ~merchantInfo) => {
    <div className="flex md:flex-row flex-col md:gap-14 ">
      <div className="flex flex-col md:pt-4 md:w-1/3">
        <p className="font-semibold text-fs-16"> {details.name->React.string} </p>
        <p className="font-medium hidden md:block text-fs-13 text-black opacity-50">
          {details.description->React.string}
        </p>
      </div>
      <div className="w-full border-b mt-1 md:hidden dark:opacity-20 " />
      <div className="w-full grid md:grid-cols-2 grid-cols-1 gap-x-16 ">
        {details.inputFields
        ->Array.mapWithIndex((field, index) => {
          let merchantName = merchantInfo->LogicUtils.getString(field.name, "Not Added")
          let defaultText = merchantName->String.length > 0 ? merchantName : "Not Added"

          <div key={index->Belt.Int.toString}>
            {switch formState {
            | Preview => <InfoOnlyView heading={field.label} subHeading={defaultText} />
            | Edit =>
              <FormRenderer.FieldRenderer
                labelClass="font-semibold !text-black"
                field={FormRenderer.makeFieldInfo(
                  ~label=field.label,
                  ~name=field.name,
                  ~placeholder=field.placeholder,
                  ~customInput=field.inputType,
                  (),
                )}
              />
            }}
          </div>
        })
        ->React.array}
      </div>
    </div>
  }
}
let renderingArray = [primaryDetails, secondaryDetails, businessDetails]

@react.component
let make = () => {
  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod()
  let showToast = ToastState.useShowToast()
  let (uid, setUid) = React.useState(() => None)
  let (merchantInfo, setMerchantInfo) = React.useState(() => Dict.make())
  let (formState, setFormState) = React.useState(_ => Preview)
  let (fetchState, setFetchState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (isDisabled, setIsDisabled) = React.useState(_ => false)

  let onSubmit = async (values, _) => {
    try {
      setFetchState(_ => Loading)
      let accountUrl = getURL(~entityName=MERCHANT_ACCOUNT, ~methodType=Post, ~id=uid, ())
      let merchantDetails = await updateDetails(
        accountUrl,
        values->getSettingsPayload(uid->Belt.Option.getWithDefault("")),
        Post,
      )
      setFormState(_ => Preview)
      let merchantInfo = merchantDetails->getMerchantDetails->parseMerchantJson
      setMerchantInfo(_ => merchantInfo)
      showToast(~message=`Successfully updated business details`, ~toastType=ToastSuccess, ())
      setFetchState(_ => Success)
    } catch {
    | Js.Exn.Error(e) =>
      switch Js.Exn.message(e) {
      | Some(message) => setFetchState(_ => Error(message))
      | None => setFetchState(_ => Error("Something went wrong!"))
      }
    }
    Js.Nullable.null
  }
  let fetchMerchantInfo = async () => {
    let merchantId = HSLocalStorage.getFromMerchantDetails("merchant_id")
    setUid(_ => Some(merchantId))
    try {
      setFetchState(_ => Loading)
      let accountUrl = getURL(~entityName=MERCHANT_ACCOUNT, ~methodType=Get, ())
      let merchantDetails = await fetchDetails(accountUrl)
      let merchantInfo = merchantDetails->getMerchantDetails->parseMerchantJson
      setMerchantInfo(_ => merchantInfo)
      setFetchState(_ => Success)
    } catch {
    | Js.Exn.Error(e) =>
      switch Js.Exn.message(e) {
      | Some(message) => setFetchState(_ => Error(message))
      | None => setFetchState(_ => Error("Something went wrong!"))
      }
    }
    None
  }

  React.useEffect0(() => {
    fetchMerchantInfo()->ignore
    setFormState(_ => Preview)
    None
  })
  let buttonText = switch formState {
  | Preview => "Edit"
  | Edit => "Save"
  }

  <PageLoaderWrapper screenState={fetchState}>
    <div className="flex flex-col gap-6">
      <PageUtils.PageHeading
        title="Business Details"
        subTitle="Manage core business information associated with the payment account."
      />
      <Form
        onSubmit
        initialValues={merchantInfo->Js.Json.object_}
        validate={values => {
          open HSwitchSettingTypes
          validateMerchantAccountForm(
            ~values,
            ~fieldsToValidate=[PrimaryPhone, PrimaryEmail, Website, SecondaryEmail, SecondaryPhone],
            ~setIsDisabled=Some(setIsDisabled),
            ~initialData={merchantInfo->Js.Json.object_},
          )
        }}>
        <div
          className="flex flex-col md:flex-row justify-between bg-white p-7 gap-8 rounded-sm border border-jp-gray-border_gray">
          <div className="w-full flex flex-col gap-5 md:gap-10">
            {renderingArray
            ->Array.mapWithIndex((details, i) =>
              <DetailsSection key={i->string_of_int} details formState merchantInfo />
            )
            ->React.array}
          </div>
          {switch formState {
          | Preview =>
            <Button
              text="Edit"
              onClick={_ => setFormState(_ => Edit)}
              buttonType=Primary
              buttonSize={Small}
              customButtonStyle="rounded-sm"
            />
          | Edit =>
            <div className="!flex !items-start gap-4">
              <Button
                text="Cancel"
                onClick={_ => setFormState(_ => Preview)}
                buttonType={Secondary}
                buttonSize={Small}
                customButtonStyle="rounded-sm"
              />
              <div className="!flex !items-start">
                <FormRenderer.SubmitButton
                  text=buttonText
                  buttonType=Primary
                  buttonSize={Small}
                  disabledParamter={isDisabled}
                  customSumbitButtonStyle="rounded-sm"
                />
              </div>
            </div>
          }}
        </div>
      </Form>
    </div>
  </PageLoaderWrapper>
}
