open ReconEngineSelfServeTypes
open ReconEngineSelfServeUtils

@react.component
let make = (
  ~wizardState: wizardState,
  ~onIngestionCreated: createdIngestion => unit,
  ~onNext: unit => unit,
  ~onBack: unit => unit,
) => {
  let createIngestion = ReconEngineSelfServeHooks.useCreateIngestionConfig()
  let {merchantId} =
    CommonAuthHooks.useCommonAuthInfo()->Option.getOr(CommonAuthHooks.defaultAuthInfo)
  let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()

  let (selectedAccountId, setSelectedAccountId) = React.useState(_ => "")
  let (ingestionName, setIngestionName) = React.useState(_ => "")
  let (configVariantStr, setConfigVariantStr) = React.useState(_ => "manual")
  let (isSubmitting, setIsSubmitting) = React.useState(_ => false)

  let accountOptions: array<SelectBox.dropdownOption> = wizardState.accounts->Array.map(account => {
    let label = `${account.account_name} (${account.account_type})`
    let value = account.account_id
    {SelectBox.label, value}
  })

  let ingestionTypeOptions: array<SelectBox.dropdownOption> = [
    {label: "Manual CSV Upload", value: "manual"},
    {label: "Adyen Webhook", value: "adyen"},
    {label: "SFTP Internal", value: "sftp_internal"},
  ]

  let configVariantFromString = (s: string): ingestionConfigVariant => {
    switch s {
    | "adyen" => Adyen
    | "sftp_internal" => SftpInternal
    | _ => Manual
    }
  }

  let configVariant = configVariantStr->configVariantFromString

  let handleSubmit = async () => {
    setIsSubmitting(_ => true)
    let result = await createIngestion(
      ~merchantId,
      ~profileId,
      ~name=ingestionName,
      ~accountId=selectedAccountId,
      ~configVariant,
    )
    switch result {
    | Some(ingestion) => {
        onIngestionCreated(ingestion)
        setIngestionName(_ => "")
        setSelectedAccountId(_ => "")
        setConfigVariantStr(_ => "manual")
      }
    | None => ()
    }
    setIsSubmitting(_ => false)
  }

  // Check if all accounts have ingestion configs
  let accountsWithIngestion =
    wizardState.accounts->Array.filter(account =>
      wizardState.ingestions->Array.some(ing => ing.account_id === account.account_id)
    )
  let allAccountsCovered =
    accountsWithIngestion->Array.length === wizardState.accounts->Array.length

  <div className="flex flex-col gap-10 max-w-3xl">
    // Context from previous steps
    <RenderIf condition={wizardState.accounts->Array.length > 0}>
      <div
        className="flex items-center gap-2 px-3 py-2 bg-nd_gray-50 rounded-lg text-xs text-nd_gray-500 ml-10 mb-2">
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
      <p className="text-sm text-nd_gray-500 leading-relaxed ml-10">
        {"Define how data enters the recon engine. Each account needs a data source. For most setups, \"Manual CSV Upload\" is the simplest way to start."->React.string}
      </p>
    </div>
    // How it works
    <div className="ml-10 p-4 bg-blue-50 rounded-lg border border-blue-100">
      <div className="flex items-start gap-3">
        <Icon name="nd-overview" className="text-blue-500 mt-0.5" customHeight="16" />
        <div className="flex flex-col gap-1">
          <p className="text-sm font-medium text-blue-700"> {"How it works"->React.string} </p>
          <p className="text-xs text-blue-600 leading-relaxed">
            {"Each account needs its own ingestion config. Manual upload lets you upload CSV files through the UI. Adyen webhook receives data automatically. SFTP pulls files from a configured path."->React.string}
          </p>
        </div>
      </div>
    </div>
    // Form
    <div className="ml-10 flex flex-col gap-5 p-6 rounded-xl border border-nd_gray-200 bg-white">
      <div className="flex flex-col gap-1.5">
        <label className="text-sm font-medium text-nd_gray-700"> {"Account"->React.string} </label>
        <p className="text-xs text-nd_gray-400">
          {"Select the account to configure ingestion for"->React.string}
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
      </div>
      <div className="flex flex-col gap-1.5">
        <label className="text-sm font-medium text-nd_gray-700">
          {"Data Source Name"->React.string}
        </label>
        <input
          type_="text"
          className="w-full px-3 py-2 text-sm border border-nd_gray-200 rounded-lg focus:outline-none focus:border-blue-400 focus:ring-1 focus:ring-blue-400 placeholder:text-nd_gray-300"
          placeholder="e.g., FIUU Manual Upload, Bank Settlement Manual Upload"
          value={ingestionName}
          onChange={e => setIngestionName(_ => ReactEvent.Form.target(e)["value"])}
        />
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
    <RenderIf condition={wizardState.ingestions->Array.length > 0}>
      <div className="ml-10 flex flex-col gap-3">
        <h3 className="text-sm font-semibold text-nd_gray-700">
          {`Created Ingestion Configs (${wizardState.ingestions
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
    <div className="ml-10 flex gap-3">
      <Button
        text="Back"
        buttonType=Secondary
        buttonSize=Small
        onClick={_ => onBack()}
        leftIcon={CustomIcon(<Icon name="nd-arrow-left" customHeight="14" />)}
      />
      <RenderIf condition={allAccountsCovered}>
        <Button
          text="Continue to Transformation"
          buttonType=Primary
          buttonSize=Small
          onClick={_ => onNext()}
          rightIcon={CustomIcon(<Icon name="nd-arrow-right" customHeight="14" />)}
          customButtonStyle="flex-1"
        />
      </RenderIf>
    </div>
    <RenderIf condition={!allAccountsCovered && wizardState.ingestions->Array.length > 0}>
      <div className="ml-10 p-3 bg-amber-50 rounded-lg border border-amber-200">
        <p className="text-xs text-amber-700">
          {"Each account needs an ingestion config. Create configs for all your accounts to continue."->React.string}
        </p>
      </div>
    </RenderIf>
  </div>
}
