open ReconEngineSelfServeTypes
open ReconEngineSelfServeUtils

@send
external scrollIntoViewSmooth: (Dom.element, {"behavior": string, "block": string}) => unit =
  "scrollIntoView"

@react.component
let make = (
  ~wizardState: wizardState,
  ~onIngestionCreated: createdIngestion => unit,
  ~onNext: unit => unit,
  ~onBack: unit => unit,
  ~isGuidedMode: bool=true,
) => {
  let createIngestion = ReconEngineSelfServeHooks.useCreateIngestionConfig()
  let {merchantId} =
    CommonAuthHooks.useCommonAuthInfo()->Option.getOr(CommonAuthHooks.defaultAuthInfo)
  let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()

  // In guided mode: auto-select remaining account and filter configured ones
  // In expert mode: show all accounts
  let availableAccounts = if isGuidedMode {
    wizardState.accounts->Array.filter(account =>
      !(wizardState.ingestions->Array.some(ing => ing.account_id === account.account_id))
    )
  } else {
    wizardState.accounts
  }
  let autoAccountId = if isGuidedMode {
    switch availableAccounts {
    | [singleAccount] => singleAccount.account_id
    | _ => ""
    }
  } else {
    ""
  }
  let (selectedAccountId, setSelectedAccountId) = React.useState(_ => autoAccountId)
  let (ingestionName, setIngestionName) = React.useState(_ => "")
  let (configVariantStr, setConfigVariantStr) = React.useState(_ => "manual")
  let (isSubmitting, setIsSubmitting) = React.useState(_ => false)

  let accountOptions: array<SelectBox.dropdownOption> = availableAccounts->Array.map(account => {
    let label = `${account.account_name} (${account.account_type})`
    let value = account.account_id
    {SelectBox.label, value}
  })

  let ingestionTypeOptions: array<SelectBox.dropdownOption> = [
    {label: "Manual CSV Upload", value: "manual"},
    {label: "Adyen Webhook", value: "adyen"},
    {label: "SFTP Internal", value: "sftp_internal"},
  ]

  // Adyen config fields
  let (hmacSecret, setHmacSecret) = React.useState(_ => "")
  let (webhookUsername, setWebhookUsername) = React.useState(_ => "")
  let (webhookPassword, setWebhookPassword) = React.useState(_ => "")
  let (reportUsername, setReportUsername) = React.useState(_ => "")
  let (reportPassword, setReportPassword) = React.useState(_ => "")
  // SFTP config fields
  let (sftpFilePath, setSftpFilePath) = React.useState(_ => "")

  let configVariant = configVariantStr->stringToIngestionConfigVariant

  let (showErrors, setShowErrors) = React.useState(_ => false)
  let nextButtonRef = React.useRef(Nullable.null)
  let errorInputClass = "!border-red-400 !focus:border-red-400 !focus:ring-red-400"
  let isNameEmpty = ingestionName->String.trim->String.length === 0
  let isAccountEmpty = selectedAccountId->String.length === 0

  let handleSubmit = async () => {
    let hasErrors = isNameEmpty || isAccountEmpty
    setShowErrors(_ => hasErrors)
    if !hasErrors {
      setIsSubmitting(_ => true)
      let result = await createIngestion(
        ~merchantId,
        ~profileId,
        ~name=ingestionName,
        ~accountId=selectedAccountId,
        ~configVariant,
        ~hmacSecret,
        ~webhookUsername,
        ~webhookPassword,
        ~reportUsername,
        ~reportPassword,
        ~sftpFilePath,
      )
      switch result {
      | Some(ingestion) => {
          onIngestionCreated(ingestion)
          setIngestionName(_ => "")
          setSelectedAccountId(_ => "")
          setConfigVariantStr(_ => "manual")
          setHmacSecret(_ => "")
          setWebhookUsername(_ => "")
          setWebhookPassword(_ => "")
          setReportUsername(_ => "")
          setReportPassword(_ => "")
          setSftpFilePath(_ => "")
        }
      | None => ()
      }
      setIsSubmitting(_ => false)
    }
  }

  // Check if all accounts have ingestion configs
  let accountsWithIngestion =
    wizardState.accounts->Array.filter(account =>
      wizardState.ingestions->Array.some(ing => ing.account_id === account.account_id)
    )
  let allAccountsCovered =
    accountsWithIngestion->Array.length === wizardState.accounts->Array.length

  React.useEffect(() => {
    if isGuidedMode && allAccountsCovered {
      nextButtonRef.current
      ->Nullable.toOption
      ->Option.forEach(el =>
        el->scrollIntoViewSmooth({"behavior": "smooth", "block": "center"})
      )
    }
    None
  }, [allAccountsCovered])

  <div className="flex flex-col gap-10 max-w-3xl">
    // Context from previous steps
    <RenderIf condition={wizardState.accounts->Array.length > 0}>
      <div
        className="flex items-center gap-2 px-3 py-2 bg-nd_gray-50 rounded-lg text-xs text-nd_gray-500 ml-4 sm:ml-10 mb-2">
        <Icon name="nd-check" customHeight="10" className="text-green-500" />
        {`Using ${wizardState.accounts->Array.length->Int.toString} accounts: ${wizardState.accounts
          ->Array.map(a => a.account_name)
          ->Array.joinWith(", ")}`->React.string}
      </div>
    </RenderIf>
    // Header
    <div className="flex flex-col gap-2">
      <div className="flex items-center gap-2">
        <div
          className="w-8 h-8 rounded-full bg-blue-50 flex items-center justify-center text-sm font-semibold text-blue-600">
          {"2"->React.string}
        </div>
        <h2 className="text-lg font-semibold text-nd_gray-800">
          {"Connect Data Sources"->React.string}
        </h2>
      </div>
      <p className="text-sm text-nd_gray-500 leading-relaxed ml-4 sm:ml-10">
        {"Define how data enters the recon engine. Each account needs a data source. For most setups, \"Manual CSV Upload\" is the simplest way to start."->React.string}
      </p>
    </div>
    // How it works
    <div className="ml-4 sm:ml-10 p-4 bg-blue-50 rounded-lg border border-blue-100">
      <div className="flex items-start gap-3">
        <Icon name="nd-overview" className="text-blue-500 mt-0.5" customHeight="16" />
        <div className="flex flex-col gap-1">
          <p className="text-sm font-medium text-blue-700"> {"How it works"->React.string} </p>
          <p className="text-xs text-blue-600 leading-relaxed">
            {"Each account needs its own data source. Manual upload lets you upload CSV files through the UI. Adyen webhook receives data automatically. SFTP pulls files from a configured path."->React.string}
          </p>
        </div>
      </div>
    </div>
    // Form
    <div
      className="ml-4 sm:ml-10 flex flex-col gap-5 p-6 rounded-xl border border-nd_gray-200 bg-white">
      <div className="flex flex-col gap-1.5">
        <label className="text-sm font-medium text-nd_gray-700"> {"Account"->React.string} </label>
        <p className="text-xs text-nd_gray-400">
          {"Select the account for this data source"->React.string}
        </p>
        <SelectBox
          input={makeControlledSelectInput(
            ~name="accountId",
            ~value=selectedAccountId,
            ~setValue=setSelectedAccountId,
          )}
          options={accountOptions}
          deselectDisable=true
          showClearAll=false
        />
        <RenderIf condition={showErrors && isAccountEmpty}>
          <p className="text-xs text-red-500"> {"Please select an account"->React.string} </p>
        </RenderIf>
      </div>
      <div className="flex flex-col gap-1.5">
        <label htmlFor="ingestionName" className="text-sm font-medium text-nd_gray-700">
          {"Data Source Name"->React.string}
        </label>
        <input
          id="ingestionName"
          type_="text"
          className={showErrors && isNameEmpty
            ? `${inputClassName} ${errorInputClass}`
            : inputClassName}
          placeholder="e.g., FIUU Manual Upload, Bank Settlement Manual Upload"
          value={ingestionName}
          onChange={e => setIngestionName(_ => ReactEvent.Form.target(e)["value"])}
        />
        <RenderIf condition={showErrors && isNameEmpty}>
          <p className="text-xs text-red-500"> {"Data source name is required"->React.string} </p>
        </RenderIf>
      </div>
      <div className="flex flex-col gap-1.5">
        <label className="text-sm font-medium text-nd_gray-700">
          {"Import Method"->React.string}
        </label>
        <p className="text-xs text-nd_gray-400">
          {"How will you send data? Manual = upload CSV files yourself. Adyen = automatic from your Adyen account. SFTP = automatic from a shared file server."->React.string}
        </p>
        <SelectBox
          input={makeControlledSelectInput(
            ~name="configVariant",
            ~value=configVariantStr,
            ~setValue=setConfigVariantStr,
          )}
          options={ingestionTypeOptions}
          deselectDisable=true
          showClearAll=false
        />
      </div>
      <RenderIf condition={configVariantStr === "adyen"}>
        <div className="flex flex-col gap-3 p-4 bg-nd_gray-50 rounded-lg">
          <p className="text-xs font-medium text-nd_gray-600">
            {"Adyen Configuration"->React.string}
          </p>
          <div className="flex flex-col gap-1.5">
            <label htmlFor="hmacSecret" className="text-xs font-medium text-nd_gray-600">
              {"HMAC Secret"->React.string}
            </label>
            <input
              id="hmacSecret"
              type_="password"
              className=innerInputClassName
              placeholder="Enter HMAC secret"
              value={hmacSecret}
              onChange={e => setHmacSecret(_ => ReactEvent.Form.target(e)["value"])}
            />
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <div className="flex flex-col gap-1.5">
              <label htmlFor="webhookUsername" className="text-xs font-medium text-nd_gray-600">
                {"Webhook Username"->React.string}
              </label>
              <input
                id="webhookUsername"
                type_="text"
                className=innerInputClassName
                placeholder="Basic auth username"
                value={webhookUsername}
                onChange={e => setWebhookUsername(_ => ReactEvent.Form.target(e)["value"])}
              />
            </div>
            <div className="flex flex-col gap-1.5">
              <label htmlFor="webhookPassword" className="text-xs font-medium text-nd_gray-600">
                {"Webhook Password"->React.string}
              </label>
              <input
                id="webhookPassword"
                type_="password"
                className=innerInputClassName
                placeholder="Basic auth password"
                value={webhookPassword}
                onChange={e => setWebhookPassword(_ => ReactEvent.Form.target(e)["value"])}
              />
            </div>
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <div className="flex flex-col gap-1.5">
              <label htmlFor="reportUsername" className="text-xs font-medium text-nd_gray-600">
                {"Report Username"->React.string}
              </label>
              <input
                id="reportUsername"
                type_="text"
                className=innerInputClassName
                placeholder="Report auth username"
                value={reportUsername}
                onChange={e => setReportUsername(_ => ReactEvent.Form.target(e)["value"])}
              />
            </div>
            <div className="flex flex-col gap-1.5">
              <label htmlFor="reportPassword" className="text-xs font-medium text-nd_gray-600">
                {"Report Password"->React.string}
              </label>
              <input
                id="reportPassword"
                type_="password"
                className=innerInputClassName
                placeholder="Report auth password"
                value={reportPassword}
                onChange={e => setReportPassword(_ => ReactEvent.Form.target(e)["value"])}
              />
            </div>
          </div>
        </div>
      </RenderIf>
      <RenderIf condition={configVariantStr === "sftp_internal"}>
        <div className="flex flex-col gap-3 p-4 bg-nd_gray-50 rounded-lg">
          <p className="text-xs font-medium text-nd_gray-600">
            {"SFTP Configuration"->React.string}
          </p>
          <div className="flex flex-col gap-1.5">
            <label htmlFor="sftpFilePath" className="text-xs font-medium text-nd_gray-600">
              {"File Path"->React.string}
            </label>
            <input
              id="sftpFilePath"
              type_="text"
              className=innerInputClassName
              placeholder="e.g., /data/imports/settlements/"
              value={sftpFilePath}
              onChange={e => setSftpFilePath(_ => ReactEvent.Form.target(e)["value"])}
            />
          </div>
        </div>
      </RenderIf>
      <Button
        text="Add Data Source"
        buttonType=Primary
        buttonSize=Small
        onClick={_ => handleSubmit()->ignore}
        buttonState={isSubmitting ? Loading : Normal}
        customButtonStyle="w-full mt-2"
      />
    </div>
    // Created ingestions list
    <RenderIf condition={isGuidedMode && wizardState.ingestions->Array.length > 0}>
      <div className="ml-4 sm:ml-10 flex flex-col gap-3">
        <h3 className="text-sm font-semibold text-nd_gray-700">
          {`Created Data Sources (${wizardState.ingestions
            ->Array.length
            ->Int.toString})`->React.string}
        </h3>
        <div className="flex flex-col gap-2">
          {wizardState.ingestions
          ->Array.mapWithIndex((ingestion, idx) => {
            let accountName =
              wizardState.accounts
              ->Array.find(a => a.account_id === ingestion.account_id)
              ->Option.map(a => a.account_name)
              ->Option.getOr("Unknown")
            <div
              key={idx->Int.toString}
              className="flex items-center justify-between p-3 rounded-lg border border-nd_gray-200 bg-nd_gray-50">
              <div className="flex items-center gap-3">
                <Icon name="nd-check" customHeight="14" className="text-green-500" />
                <span className="text-sm font-medium text-nd_gray-700">
                  {ingestion.name->React.string}
                </span>
                <span className="text-xs px-2 py-0.5 rounded-full bg-nd_gray-100 text-nd_gray-500">
                  {accountName->React.string}
                </span>
              </div>
              <span className="text-xs text-nd_gray-400 font-mono">
                {ingestion.ingestion_id->React.string}
              </span>
            </div>
          })
          ->React.array}
        </div>
      </div>
    </RenderIf>
    // Navigation
    <RenderIf condition={isGuidedMode}>
      <div className="ml-4 sm:ml-10 flex gap-3" ref={ReactDOM.Ref.domRef(nextButtonRef)}>
        <Button
          text="Back"
          buttonType=Secondary
          buttonSize=Small
          onClick={_ => onBack()}
          leftIcon={CustomIcon(<Icon name="nd-arrow-left" customHeight="14" />)}
        />
        <RenderIf condition={allAccountsCovered}>
          <Button
            text="Continue to Column Mapping"
            buttonType=Primary
            buttonSize=Small
            onClick={_ => onNext()}
            rightIcon={CustomIcon(<Icon name="nd-arrow-right" customHeight="14" />)}
            customButtonStyle="flex-1"
          />
        </RenderIf>
      </div>
      <RenderIf condition={!allAccountsCovered && wizardState.ingestions->Array.length > 0}>
        <div className="ml-4 sm:ml-10 p-3 bg-amber-50 rounded-lg border border-amber-200">
          <p className="text-xs text-amber-700">
            {"Each account needs a data source. Add data sources for all your accounts to continue."->React.string}
          </p>
        </div>
      </RenderIf>
    </RenderIf>
  </div>
}
