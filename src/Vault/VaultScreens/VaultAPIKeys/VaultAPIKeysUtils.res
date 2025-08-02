open VaultAPITypes

let getRecordTypeFromString = value => {
  switch value->String.toLowerCase {
  | "never" => Never
  | _ => Custom
  }
}

let getStringFromRecordType = value => {
  switch value {
  | Never => "never"
  | Custom => "custom"
  }
}

let apiName = FormRenderer.makeFieldInfo(
  ~label="Name",
  ~name="name",
  ~placeholder="Name",
  ~customInput=InputFields.textInput(),
  ~isRequired=true,
)

let apiDescription = FormRenderer.makeFieldInfo(
  ~label="Description",
  ~name="description",
  ~placeholder="Description",
  ~customInput=InputFields.textInput(),
  ~isRequired=true,
)

let makeOptions: array<string> => array<SelectBox.dropdownOption> = options => {
  options->Array.map(str => {
    let option: SelectBox.dropdownOption = {label: str->LogicUtils.snakeToTitle, value: str}
    option
  })
}

let keyExpiry = FormRenderer.makeFieldInfo(
  ~label="Expiration",
  ~name="expiration",
  ~customInput=InputFields.selectInput(
    ~options=["never", "custom"]->makeOptions,
    ~buttonText="Select Option",
  ),
)

let keyExpiryCustomDate = FormRenderer.makeFieldInfo(
  ~label="",
  ~name="expiration_date",
  ~customInput=InputFields.singleDatePickerInput(
    ~disablePastDates=true,
    ~format="YYYY-MM-DDTHH:mm:ss.SSS[Z]",
  ),
)

let validateAPIKeyForm = (
  values: JSON.t,
  ~setIsDisabled=_ => (),
  keys: array<string>,
  ~setShowCustomDate,
) => {
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
      setShowCustomDate(true)
      let date = LogicUtils.getString(valuesDict, "expiration_date", "")

      if date->LogicUtils.isEmptyString {
        Dict.set(errors, "expiration_date", "Please select expiry date"->JSON.Encode.string)
      }
    } else if key == "expiration" && value->String.toLowerCase == "never" {
      setShowCustomDate(false)
    } else if key == "name" && value->String.length > 64 {
      Dict.set(errors, "name", "Name can't be more than 64 characters"->JSON.Encode.string)
    } else if key == "description" && value->String.length > 256 {
      Dict.set(
        errors,
        "description",
        "Description can't be more than 256 characters"->JSON.Encode.string,
      )
    } else if (
      value->LogicUtils.isNonEmptyString &&
      (key === "webhook_url" || key === "return_url") &&
      !(value->String.includes("localhost")) &&
      !RegExp.test(
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

let itemToObjMapper = dict => {
  open LogicUtils
  {
    key_id: getString(dict, "key_id", ""),
    name: getString(dict, "name", ""),
    description: getString(dict, "description", ""),
    prefix: getString(dict, "prefix", ""),
    created: getString(dict, "created", ""),
    expiration: getString(dict, "expiration", "")->getRecordTypeFromString,
    expiration_date: getString(dict, "expiration", ""),
  }
}

let getItems: JSON.t => array<apiKey> = json => {
  LogicUtils.getArrayDataFromJson(json, itemToObjMapper)
}

let defaultColumns = [Prefix, Name, Description, Created, Expiration, CustomCell]

let allColumns = [Prefix, Name, Description, Created, Expiration, CustomCell]

let getHeading = colType => {
  switch colType {
  | Name => Table.makeHeaderInfo(~key="name", ~title="Name")
  | Description => Table.makeHeaderInfo(~key="description", ~title="Description")
  | Prefix => Table.makeHeaderInfo(~key="key", ~title="API Key Prefix")
  | Created => Table.makeHeaderInfo(~key="created", ~title="Created")
  | Expiration => Table.makeHeaderInfo(~key="expiration", ~title="Expiration")
  | CustomCell => Table.makeHeaderInfo(~key="", ~title="")
  }
}
