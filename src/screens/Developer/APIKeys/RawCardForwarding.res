let validateAPIKeyForm = (values: JSON.t, ~setIsDisabled=_ => (), keys: array<string>, ()) => {
  open LogicUtils
  let errors = Dict.make()
  let valuesDict = values->getDictFromJsonObject->getDictfromDict("extended_card_info_config")

  keys->Array.forEach(key => {
    let value = getString(valuesDict, key, "")

    if value->isEmptyString {
      switch key {
      | "public_key" => Dict.set(errors, key, "Please enter public key"->JSON.Encode.string)
      | "raw_card_ttl" => {
          let value = getInt(valuesDict, "raw_card_ttl", 0)

          if value == 0 {
            Dict.set(
              errors,
              key,
              "Please enter raw card time to live in seconds"->JSON.Encode.string,
            )
          } else if value < 900 {
            Dict.set(errors, "raw_card_ttl", "Min time span should be 900s"->JSON.Encode.string)
          } else if value > 3600 {
            Dict.set(
              errors,
              "raw_card_ttl",
              "Max time span should not exceed 3600s"->JSON.Encode.string,
            )
          }
        }
      | _ => ()
      }
    }
  })
  errors == Dict.make() ? setIsDisabled(_ => false) : setIsDisabled(_ => true)

  errors->JSON.Encode.object
}

let errorClass = "text-sm leading-4 font-medium text-start ml-1 mt-2"

let pkKey = FormRenderer.makeFieldInfo(
  ~label="Public Key",
  ~name="extended_card_info_config.public_key",
  ~placeholder="Public Key",
  ~customInput=InputFields.textInput(),
  ~isRequired=true,
  (),
)

let keyExpiryCustomDate = FormRenderer.makeFieldInfo(
  ~label="Time Span (min:900s max:3600s)",
  ~name="extended_card_info_config.raw_card_ttl",
  ~placeholder="in seconds",
  ~isRequired=true,
  ~customInput=InputFields.numericTextInput(~maxLength=4, ()),
  (),
)

@react.component
let make = () => {
  let getURL = APIUtils.useGetURL()
  let updateDetails = APIUtils.useUpdateMethod()
  let (businessProfile, _) = HyperswitchAtom.businessProfilesAtom->Recoil.useRecoilState
  let showToast = ToastState.useShowToast()
  let initialValueJson = JSON.Encode.object(Dict.make())
  let activeBusinessProfile = businessProfile->MerchantAccountUtils.getValueFromBusinessProfile

  let onSubmit = async (values, form: ReactFinalForm.formApi) => {
    try {
      let url = getURL(
        ~entityName=BUSINESS_PROFILE,
        ~methodType=Post,
        ~id=Some(activeBusinessProfile.profile_id),
        (),
      )

      let _ = await updateDetails(url, values, Post, ())
      form.reset(JSON.Encode.object(Dict.make())->Nullable.make)
      form.resetFieldState("extended_card_info_config.public_key")
      form.resetFieldState("extended_card_info_config.raw_card_ttl")
      showToast(~message="Card forwarding successful", ~toastType=ToastState.ToastSuccess, ())
    } catch {
    | Exn.Error(e) =>
      switch Exn.message(e) {
      | Some(_error) =>
        showToast(~message="Raw card forwarding failed", ~toastType=ToastState.ToastError, ())
      | None => ()
      }
    }
    Nullable.null
  }

  <div className="mt-10">
    <h2
      className="font-bold text-xl pb-3 text-black text-opacity-75 dark:text-white dark:text-opacity-75">
      {"Raw card forwarding"->React.string}
    </h2>
    <div
      className="px-2 py-4 border border-jp-gray-500 dark:border-jp-gray-960 bg-white dark:bg-jp-gray-lightgray_background rounded-md">
      <FormRenderer.DesktopRow>
        <Form
          onSubmit
          validate={values => validateAPIKeyForm(values, ["public_key", "raw_card_ttl"], ())}
          initialValues={initialValueJson}>
          <div className="flex flex-wrap justify-between gap-5">
            <FormRenderer.FieldRenderer
              fieldWrapperClass="w-full max-w-3xl" field=pkKey errorClass
            />
            <FormRenderer.FieldRenderer
              fieldWrapperClass="w-80" field=keyExpiryCustomDate errorClass
            />
          </div>
          <div className="w-full flex justify-end mt-5">
            <FormRenderer.SubmitButton
              text="Submit" buttonSize={Small} loadingText="Sending..." customHeightClass=""
            />
          </div>
        </Form>
      </FormRenderer.DesktopRow>
    </div>
  </div>
}
