open HSwitchSettingTypes

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

type apiKeyExpiryType = Never | Custom

let getStringFromRecordType = value => {
  switch value {
  | Never => "never"
  | Custom => "custom"
  }
}

let getRecordTypeFromString = value => {
  switch value->String.toLowerCase {
  | "never" => Never
  | _ => Custom
  }
}

type apiKey = {
  key_id: string,
  name: string,
  description: string,
  prefix: string,
  created: string,
  expiration: apiKeyExpiryType,
  expiration_date: string,
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

let defaultColumns = [Prefix, Name, Description, Created, Expiration, CustomCell]

let allColumns = [Prefix, Name, Description, Created, Expiration, CustomCell]

let getItems: JSON.t => array<apiKey> = json => {
  LogicUtils.getArrayDataFromJson(json, itemToObjMapper)
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
let makeOptionsWithDifferentValues = (options: array<JSON.t>): array<SelectBox.dropdownOption> => {
  open LogicUtils
  options->Array.map((item): SelectBox.dropdownOption => {
    let itemDict = item->LogicUtils.getDictFromJsonObject
    {label: itemDict->getString("name", ""), value: itemDict->getString("code", "")}
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

let webhookUrl = FormRenderer.makeFieldInfo(
  ~label="Webhook URL",
  ~name="webhook_url",
  ~placeholder="Enter Webhook URL",
  ~customInput=InputFields.textInput(~autoComplete="off"),
  ~isRequired=false,
)

let returnUrl = FormRenderer.makeFieldInfo(
  ~label="Return URL",
  ~name="return_url",
  ~placeholder="Enter Return URL",
  ~customInput=InputFields.textInput(~autoComplete="off"),
  ~isRequired=false,
)

let authenticationConnectors = connectorList =>
  FormRenderer.makeFieldInfo(
    ~label="Authentication Connectors",
    ~name="authentication_connectors",
    ~customInput=InputFields.multiSelectInput(
      ~options=connectorList->SelectBox.makeOptions,
      ~buttonText="Select Field",
      ~showSelectionAsChips=false,
      ~customButtonStyle=`!rounded-md`,
      ~fixedDropDownDirection=TopRight,
    ),
    ~isRequired=false,
  )

let merchantCategoryCode = merchantCodeArray =>
  FormRenderer.makeFieldInfo(
    ~label="Merchant Category Code",
    ~name="merchant_category_code",
    ~customInput=InputFields.selectInput(
      ~options={
        merchantCodeArray->makeOptionsWithDifferentValues
      },
      ~buttonText="Select Option",
      ~deselectDisable=true,
      ~dropdownCustomWidth="w-full",
    ),
    ~isRequired=false,
  )

let threeDsRequestorUrl = FormRenderer.makeFieldInfo(
  ~label="3DS Requestor URL",
  ~name="three_ds_requestor_url",
  ~placeholder="Enter 3DS Requestor URL",
  ~customInput=InputFields.textInput(~autoComplete="off"),
  ~isRequired=false,
)

let threeDsRequestoApprUrl = FormRenderer.makeFieldInfo(
  ~label="3DS Requestor App URL",
  ~name="three_ds_requestor_app_url",
  ~placeholder="Enter 3DS Requestor App URL",
  ~customInput=InputFields.textInput(~autoComplete="off"),
  ~isRequired=false,
)

let maxAutoRetries = FormRenderer.makeFieldInfo(
  ~label="Max Auto Retries",
  ~name="max_auto_retries_enabled",
  ~placeholder="Enter number of max auto retries",
  ~customInput=InputFields.numericTextInput(),
  ~isRequired=true,
)

module ErrorUI = {
  @react.component
  let make = (~text) => {
    <div className="flex p-5">
      <img className="w-12 h-12 my-auto border-gray-100" src={`/icons/error.svg`} alt="warning" />
      <div className="text-jp-gray-900">
        <div
          className="font-bold ml-4 text-xl px-2 dark:text-jp-gray-text_darktheme dark:text-opacity-75">
          {React.string(`API ${text} Failed`)}
        </div>
        <div
          className="whitespace-pre-line flex flex-col gap-1 p-2 ml-4 text-fs-13 dark:text-jp-gray-text_darktheme dark:text-opacity-50">
          {`Unable to ${text} a API key. Please try again later.`->React.string}
        </div>
      </div>
    </div>
  }
}

module SuccessUI = {
  @react.component
  let make = (~downloadFun, ~apiKey) => {
    <div>
      <div className="flex p-5">
        <Icon className="align-middle fill-blue-600 self-center" size=40 name="info-circle" />
        <div className="text-jp-gray-900 ml-4">
          <div
            className="font-bold text-xl px-2 dark:text-jp-gray-text_darktheme dark:text-opacity-75">
            {React.string("Download the API Key")}
          </div>
          <div className="bg-gray-100 p-3 m-2">
            <HelperComponents.CopyTextCustomComp
              displayValue={Some(apiKey)}
              copyValue={Some(apiKey)}
              customTextCss="break-all text-sm font-semibold text-jp-gray-800 text-opacity-75"
              customParentClass="flex items-center gap-5"
            />
          </div>
          <HSwitchUtils.AlertBanner
            bannerType=Info
            bannerContent={<p>
              {"Please note down the API key for your future use as you won't be able to view it later."->React.string}
            </p>}
          />
        </div>
      </div>
      <div className="flex justify-end gap-5 mt-5 mb-1 mr-1">
        <Button
          leftIcon={CustomIcon(<Icon name="download" size=17 className="ml-3 mr-2" />)}
          text="Download the key"
          onClick={_ => {
            downloadFun()
          }}
          buttonType={Primary}
          buttonSize={Small}
        />
      </div>
    </div>
  }
}

let elevatedWithAccess = "Your API keys have elevated privileges. You can use them to create new merchants and generate API keys for any merchant within this organization."

let elevatedWithoutAccess = "The API keys shown here have elevated privileges. They can be used to create merchants and generate API keys for any merchant within this organization. Contact your administrator if you require access."

let regularWithAccess = "The API keys shown here include keys you've created yourself, along with keys generated for you by the Platform Merchant account."

let regularWithoutAccess = "The API keys displayed here include keys generated for your account by the Platform Merchant."

let bannerText = (~isPlatformMerchant, ~hasCreateApiKeyAccess: CommonAuthTypes.authorization) =>
  switch (isPlatformMerchant, hasCreateApiKeyAccess) {
  | (true, Access) => elevatedWithAccess
  | (true, NoAccess) => elevatedWithoutAccess
  | (false, Access) => regularWithAccess
  | (false, NoAccess) => regularWithoutAccess
  }
