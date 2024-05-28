let validateAPIKeyForm = (values: JSON.t, ~setIsDisabled=_ => (), keys: array<string>, ()) => {
  let errors = Dict.make()

  let valuesDict = values->LogicUtils.getDictFromJsonObject

  keys->Array.forEach(key => {
    let value = LogicUtils.getString(valuesDict, key, "")

    if value->LogicUtils.isEmptyString {
      switch key {
      | "name" => Dict.set(errors, key, "Please enter name"->JSON.Encode.string)
      | "description" => Dict.set(errors, key, "Please enter description"->JSON.Encode.string)
      | "expiration" => Dict.set(errors, key, "Please select expiry"->JSON.Encode.string)
      | _ => ()
      }
    } else if key == "expiration" && value->String.toLowerCase != "never" {
      let date = LogicUtils.getString(valuesDict, "expiration_date", "")

      if date->LogicUtils.isEmptyString {
        Dict.set(errors, "expiration_date", "Please select expiry date"->JSON.Encode.string)
      }
    } else if (
      value->LogicUtils.isNonEmptyString &&
      (key === "webhook_url" || key === "return_url") &&
      !(value->String.includes("localhost")) &&
      !Js.Re.test_(
        %re(
          "/^(?:(?:(?:https?|ftp):)?\/\/)(?:\S+(?::\S*)?@)?(?:(?!(?:10|127)(?:\.\d{1,3}){3})(?!(?:169\.254|192\.168)(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|(?:(?:[a-z0-9\u00a1-\uffff][a-z0-9\u00a1-\uffff_-]{0,62})?[a-z0-9\u00a1-\uffff]\.)+(?:[a-z\u00a1-\uffff]{2,}\.?))(?::\d{2,5})?(?:[/?#]\S*)?$/i"
        ),
        value,
      )
    ) {
      Dict.set(errors, key, "Please Enter Valid URL"->JSON.Encode.string)
    } else if (key === "webhook_url" || key === "return_url") && value->String.length <= 0 {
      Dict.set(errors, key, "Please Enter Valid URL"->JSON.Encode.string)
    }
  })
  errors == Dict.make() ? setIsDisabled(_ => false) : setIsDisabled(_ => true)

  errors->JSON.Encode.object
}

let errorClass = "text-sm leading-4 font-medium text-start ml-1 mt-2"
let pkKey = FormRenderer.makeFieldInfo(
  ~label="Public Key",
  ~name="public_key",
  ~placeholder="Public Key",
  ~customInput=InputFields.multiLineTextInput(~isDisabled=false, ~rows=Some(1), ~cols=Some(85), ()),
  ~isRequired=true,
  (),
)

let keyExpiryCustomDate = FormRenderer.makeFieldInfo(
  ~label="Time Span (min:900 max:3600)",
  ~name="raw_card_ttl",
  ~placeholder="in seconds",
  ~isRequired=true,
  ~customInput=InputFields.numericTextInput(~maxLength=4, ()),
  (),
)

@react.component
let make = () => {
  let initialValues = Dict.make()

  let onSubmit = async (values, _) => {
    // try {
    let valuesDict = values->LogicUtils.getDictFromJsonObject

    //   let body = Dict.make()
    //   Dict.set(body, "name", valuesDict->LogicUtils.getString("name", "")->JSON.Encode.string)
    //   let description = valuesDict->LogicUtils.getString("description", "")
    //   Dict.set(body, "description", description->JSON.Encode.string)

    //   let expirationDate = valuesDict->LogicUtils.getString("expiration_date", "")

    //   let expriryValue = switch valuesDict
    //   ->LogicUtils.getString("expiration", "")
    //   ->getRecordTypeFromString {
    //   | Custom => expirationDate
    //   | _ => Never->getStringFromRecordType
    //   }

    //   Dict.set(body, "expiration", expriryValue->JSON.Encode.string)

    //   setModalState(_ => Loading)

    //   let url = switch action {
    //   | Update => {
    //       let key_id = keyId->Option.getOr("")
    //       getURL(~entityName=API_KEYS, ~methodType=Post, ~id=Some(key_id), ())
    //     }

    //   | _ => getURL(~entityName=API_KEYS, ~methodType=Post, ())
    //   }

    //   let json = await updateDetails(url, body->JSON.Encode.object, Post, ())
    //   let keyDict = json->LogicUtils.getDictFromJsonObject

    //   setApiKey(_ => keyDict->LogicUtils.getString("api_key", ""))
    //   switch action {
    //   | Update => setShowModal(_ => false)
    //   | _ => {
    //       Clipboard.writeText(keyDict->LogicUtils.getString("api_key", ""))
    //       setModalState(_ => Success)
    //     }
    //   }

    //   let _ = getAPIKeyDetails()
    // } catch {
    // | Exn.Error(e) =>
    //   switch Exn.message(e) {
    //   | Some(_error) =>
    //     showToast(~message="Api Key Generation Failed", ~toastType=ToastState.ToastError, ())
    //   | None => ()
    //   }
    //   setModalState(_ => SettingApiModalError)
    // }
    Nullable.null
  }

  <div className="mt-10">
    <h2
      className="font-bold text-xl pb-3 text-black text-opacity-75 dark:text-white dark:text-opacity-75">
      {"Publishable Key Forwarding"->React.string}
    </h2>
    <div
      className="px-2 py-4 border border-jp-gray-500 dark:border-jp-gray-960 bg-white dark:bg-jp-gray-lightgray_background rounded-md">
      <FormRenderer.DesktopRow>
        <ReactFinalForm.Form
          key="API-key"
          initialValues={initialValues->JSON.Encode.object}
          subscription=ReactFinalForm.subscribeToPristine
          validate={values => validateAPIKeyForm(values, ["name", "expiration"], ())}
          onSubmit
          render={({handleSubmit}) => {
            <form onSubmit={handleSubmit} className="h-full w-full">
              <div className="flex justify-between gap-7">
                <FormRenderer.FieldRenderer
                  fieldWrapperClass="w-full max-w-2xl" field=pkKey errorClass
                />
                <FormRenderer.FieldRenderer
                  fieldWrapperClass="w-80" field=keyExpiryCustomDate errorClass
                />
                <div className="mt-9 self-start">
                  <FormRenderer.SubmitButton
                    text="Submit" buttonSize={Small} customHeightClass="h-10"
                  />
                </div>
              </div>
            </form>
          }}
        />
      </FormRenderer.DesktopRow>
    </div>
  </div>
}
