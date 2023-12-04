open HSwitchSettingTypes

let validateAPIKeyForm = (
  values: Js.Json.t,
  ~setIsDisabled=_ => (),
  keys: array<string>,
  ~setShowCustomDate,
  (),
) => {
  let errors = Js.Dict.empty()

  let valuesDict = values->LogicUtils.getDictFromJsonObject

  keys->Js.Array2.forEach(key => {
    let value = LogicUtils.getString(valuesDict, key, "")

    if value == "" {
      switch key {
      | "name" => Js.Dict.set(errors, key, "Please enter name"->Js.Json.string)
      | "description" => Js.Dict.set(errors, key, "Please enter description"->Js.Json.string)
      | "expiration" => Js.Dict.set(errors, key, "Please select expiry"->Js.Json.string)
      | _ => ()
      }
    } else if key == "expiration" && value->Js.String2.toLowerCase != "never" {
      setShowCustomDate(true)
      let date = LogicUtils.getString(valuesDict, "expiration_date", "")

      if date == "" {
        Js.Dict.set(errors, "expiration_date", "Please select expiry date"->Js.Json.string)
      }
    } else if key == "expiration" && value->Js.String2.toLowerCase == "never" {
      setShowCustomDate(false)
    } else if (
      value->Js.String2.length > 0 &&
      (key === "webhook_url" || key === "return_url") &&
      !(value->Js.String2.includes("localhost")) &&
      !Js.Re.test_(
        %re(
          "/^(?:(?:(?:https?|ftp):)?\/\/)(?:\S+(?::\S*)?@)?(?:(?!(?:10|127)(?:\.\d{1,3}){3})(?!(?:169\.254|192\.168)(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|(?:(?:[a-z0-9\u00a1-\uffff][a-z0-9\u00a1-\uffff_-]{0,62})?[a-z0-9\u00a1-\uffff]\.)+(?:[a-z\u00a1-\uffff]{2,}\.?))(?::\d{2,5})?(?:[/?#]\S*)?$/i"
        ),
        value,
      )
    ) {
      Js.Dict.set(errors, key, "Please Enter Valid URL"->Js.Json.string)
    } else if (key === "webhook_url" || key === "return_url") && value->Js.String2.length <= 0 {
      Js.Dict.set(errors, key, "Please Enter Valid URL"->Js.Json.string)
    }
  })
  errors == Js.Dict.empty() ? setIsDisabled(_ => false) : setIsDisabled(_ => true)

  errors->Js.Json.object_
}

type apiKeyExpiryType = Never | Custom

let getStringFromRecordType = value => {
  switch value {
  | Never => "never"
  | Custom => "custom"
  }
}

let getRecordTypeFromString = value => {
  switch value->Js.String2.toLowerCase {
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
  | Name => Table.makeHeaderInfo(~key="name", ~title="Name", ~showSort=true, ())
  | Description => Table.makeHeaderInfo(~key="description", ~title="Description", ())
  | Prefix => Table.makeHeaderInfo(~key="key", ~title="API Key Prefix", ())
  | Created => Table.makeHeaderInfo(~key="created", ~title="Created", ~showSort=true, ())
  | Expiration => Table.makeHeaderInfo(~key="expiration", ~title="Expiration", ~showSort=true, ())
  | CustomCell => Table.makeHeaderInfo(~key="", ~title="", ())
  }
}

let defaultColumns = [Prefix, Name, Description, Created, Expiration, CustomCell]

let allColumns = [Prefix, Name, Description, Created, Expiration, CustomCell]

let apiDefaultCols = Recoil.atom(. "hyperSwitchApiDefaultCols", defaultColumns)

let getItems: Js.Json.t => array<apiKey> = json => {
  LogicUtils.getArrayDataFromJson(json, itemToObjMapper)
}

let apiName = FormRenderer.makeFieldInfo(
  ~label="Name",
  ~name="name",
  ~placeholder="Name",
  ~customInput=InputFields.textInput(),
  ~isRequired=true,
  (),
)

let apiDescription = FormRenderer.makeFieldInfo(
  ~label="Description",
  ~name="description",
  ~placeholder="Description",
  ~customInput=InputFields.textInput(),
  ~isRequired=true,
  (),
)

let makeOptions: array<string> => array<SelectBox.dropdownOption> = options => {
  options->Js.Array2.map(str => {
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
    (),
  ),
  (),
)

let keyExpiryCustomDate = FormRenderer.makeFieldInfo(
  ~label="",
  ~name="expiration_date",
  ~customInput=InputFields.singleDatePickerInput(
    ~disablePastDates=true,
    ~format="YYYY-MM-DDTHH:mm:ss.SSS[Z]",
    (),
  ),
  (),
)

let webhookUrl = FormRenderer.makeFieldInfo(
  ~label="Webhook URL",
  ~name="webhook_url",
  ~placeholder="Enter Webhook URL",
  ~customInput=InputFields.textInput(~autoComplete="off", ()),
  ~isRequired=false,
  (),
)

let returnUrl = FormRenderer.makeFieldInfo(
  ~label="Return URL",
  ~name="return_url",
  ~placeholder="Enter Return URL",
  ~customInput=InputFields.textInput(~autoComplete="off", ()),
  ~isRequired=false,
  (),
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
    let hyperswitchMixPanel = HSMixPanel.useSendEvent()
    let url = RescriptReactRouter.useUrl()
    <div>
      <div className="flex p-5">
        <Icon className="align-middle fill-blue-950 self-center" size=40 name="info-circle" />
        <div className="text-jp-gray-900 ml-4">
          <div
            className="font-bold text-xl px-2 dark:text-jp-gray-text_darktheme dark:text-opacity-75">
            {React.string("Download the API Key")}
          </div>
          <div className="bg-gray-100 p-3 m-2">
            <HelperComponents.CopyTextCustomComp
              displayValue={apiKey}
              copyValue={Some(apiKey)}
              customTextCss="break-all text-sm font-semibold text-jp-gray-800 text-opacity-75"
              customParentClass="flex items-center gap-5"
              customOnCopyClick={() => {
                hyperswitchMixPanel(
                  ~pageName=url.path->LogicUtils.getListHead,
                  ~contextName="api_keys",
                  ~actionName=`copied_key`,
                  (),
                )
              }}
            />
          </div>
          <h1 className="whitespace-pre-line text-orange-950 w-full p-2 rounded-md ">
            <span className="text-orange-950 font-bold text-fs-14"> {"NOTE: "->React.string} </span>
            {"Please note down the API key for your future use as you won't be able to view it later."->React.string}
          </h1>
        </div>
      </div>
      <div className="flex justify-end gap-5 mt-5 mb-1 mr-1">
        <Button
          leftIcon={CustomIcon(<Icon name="download" size=17 className="ml-3 mr-2" />)}
          text="Download the key"
          onClick={_ => {
            downloadFun()
            hyperswitchMixPanel(
              ~pageName=url.path->LogicUtils.getListHead,
              ~contextName="api_keys",
              ~actionName="download_the_key",
              (),
            )
          }}
          buttonType={Primary}
          buttonSize={Small}
        />
      </div>
    </div>
  }
}
