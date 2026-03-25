open ReconEngineSelfServeTypes

@react.component
let make = (~state: selfServeState, ~merchantId, ~profileId, ~onIngestionCreated, ~onNext, ~onBack) => {
  let createIngestion = ReconEngineSelfServeHooks.useCreateIngestionConfig()

  let (selectedAccountId, setSelectedAccountId) = React.useState(_ => "")
  let (ingestionName, setIngestionName) = React.useState(_ => "")
  let (configType, setConfigType) = React.useState(_ => "manual")
  let (isSubmitting, setIsSubmitting) = React.useState(_ => false)

  // Adyen fields
  let (hmacSecret, setHmacSecret) = React.useState(_ => "")
  let (webhookUsername, setWebhookUsername) = React.useState(_ => "")
  let (webhookPassword, setWebhookPassword) = React.useState(_ => "")
  let (reportUsername, setReportUsername) = React.useState(_ => "")
  let (reportPassword, setReportPassword) = React.useState(_ => "")

  // SFTP fields
  let (filePath, setFilePath) = React.useState(_ => "")

  let accountsWithoutIngestion =
    state.accounts->Array.filter(acc =>
      !(state.ingestions->Array.some(ing => ing.account_id === acc.account_id))
    )

  React.useEffect(() => {
    if selectedAccountId === "" {
      switch accountsWithoutIngestion->Array.get(0) {
      | Some(acc) => setSelectedAccountId(_ => acc.account_id)
      | None => ()
      }
    }
    None
  }, [accountsWithoutIngestion->Array.length])

  let handleSubmit = async () => {
    if ingestionName->String.trim->String.length > 0 && selectedAccountId !== "" {
      setIsSubmitting(_ => true)
      let config = switch configType {
      | "adyen" =>
        Adyen({
          hmac_secret: hmacSecret,
          webhook_basic_auth_username: webhookUsername,
          webhook_basic_auth_password: webhookPassword,
          report_basic_auth_username: reportUsername,
          report_basic_auth_password: reportPassword,
        })
      | "sftp_internal" => SftpInternal({file_path: filePath})
      | _ => Manual
      }
      let req: ingestionConfigCreateRequest = {
        merchant_id: merchantId,
        profile_id: profileId,
        name: ingestionName->String.trim,
        description: None,
        account_id: selectedAccountId,
        config,
        is_active: true,
      }
      let result = await createIngestion(req)
      switch result {
      | Some(ingestion) => {
          onIngestionCreated(ingestion)
          setIngestionName(_ => "")
          setSelectedAccountId(_ => "")
          setConfigType(_ => "manual")
        }
      | None => ()
      }
      setIsSubmitting(_ => false)
    }
  }

  let canProceed =
    state.accounts->Array.every(acc =>
      state.ingestions->Array.some(ing => ing.account_id === acc.account_id)
    )

  let allAccountsConfigured = accountsWithoutIngestion->Array.length === 0

  <div className="flex flex-col gap-6 max-w-xl">
    <div>
      <h2 className="text-lg font-semibold text-gray-900 mb-1">
        {"Setup Ingestion"->React.string}
      </h2>
      <p className="text-sm text-gray-500">
        {"Configure how data enters the system for each account. Each account needs an ingestion source."->React.string}
      </p>
    </div>
    // Existing ingestions
    <RenderIf condition={state.ingestions->Array.length > 0}>
      <div className="flex flex-col gap-2">
        <h3 className="text-sm font-medium text-gray-700">
          {"Configured Sources"->React.string}
        </h3>
        {state.ingestions
        ->Array.map(ing => {
          let accountName =
            state.accounts
            ->Array.find(a => a.account_id === ing.account_id)
            ->Option.map(a => a.account_name)
            ->Option.getOr("Unknown")
          <div
            key={ing.ingestion_id}
            className="flex items-center justify-between p-3 border border-gray-200 rounded-lg">
            <div>
              <p className="font-medium text-sm text-gray-900"> {ing.name->React.string} </p>
              <p className="text-xs text-gray-500">
                {`${accountName} \u{2022} ${ing.config_type}`->React.string}
              </p>
            </div>
            <span
              className="text-xs px-2 py-0.5 rounded-full bg-green-50 text-green-700 border border-green-200">
              {"Configured"->React.string}
            </span>
          </div>
        })
        ->React.array}
      </div>
    </RenderIf>
    // Add ingestion form
    <RenderIf condition={!allAccountsConfigured}>
      <div className="border border-gray-200 rounded-lg p-5 bg-gray-50">
        <h3 className="text-sm font-semibold text-gray-700 mb-4">
          {"Add Ingestion Source"->React.string}
        </h3>
        <div className="flex flex-col gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              {"Account"->React.string}
            </label>
            <select
              value={selectedAccountId}
              onChange={e => setSelectedAccountId(_ => ReactEvent.Form.target(e)["value"])}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
              <option value="" disabled=true> {"Select account..."->React.string} </option>
              {accountsWithoutIngestion
              ->Array.map(acc =>
                <option key={acc.account_id} value={acc.account_id}>
                  {`${acc.account_name} (${acc.account_type})`->React.string}
                </option>
              )
              ->React.array}
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              {"Source Name"->React.string}
            </label>
            <input
              type_="text"
              value={ingestionName}
              onChange={e => setIngestionName(_ => ReactEvent.Form.target(e)["value"])}
              placeholder="e.g., FIUU Manual Upload"
              className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              {"Source Type"->React.string}
            </label>
            <div className="grid grid-cols-3 gap-3">
              {[("manual", "Manual Upload", "Upload CSV files manually"),
                ("adyen", "Adyen Webhook", "Receive data via Adyen webhooks"),
                ("sftp_internal", "SFTP", "Pull files from SFTP server")]
              ->Array.map(((value, label, desc)) =>
                <div
                  key={value}
                  className={`p-3 border rounded-lg cursor-pointer transition-colors ${configType === value
                      ? "border-blue-300 bg-blue-50"
                      : "border-gray-200 hover:border-gray-300"}`}
                  onClick={_ => setConfigType(_ => value)}>
                  <p className="text-sm font-medium text-gray-900"> {label->React.string} </p>
                  <p className="text-xs text-gray-500 mt-0.5"> {desc->React.string} </p>
                </div>
              )
              ->React.array}
            </div>
          </div>
          // Adyen config fields
          <RenderIf condition={configType === "adyen"}>
            <div className="flex flex-col gap-3 border-t border-gray-200 pt-4">
              <div>
                <label className="block text-xs font-medium text-gray-600 mb-1">
                  {"HMAC Secret"->React.string}
                </label>
                <input
                  type_="password"
                  value={hmacSecret}
                  onChange={e => setHmacSecret(_ => ReactEvent.Form.target(e)["value"])}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-medium text-gray-600 mb-1">
                    {"Webhook Username"->React.string}
                  </label>
                  <input
                    type_="text"
                    value={webhookUsername}
                    onChange={e => setWebhookUsername(_ => ReactEvent.Form.target(e)["value"])}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                  />
                </div>
                <div>
                  <label className="block text-xs font-medium text-gray-600 mb-1">
                    {"Webhook Password"->React.string}
                  </label>
                  <input
                    type_="password"
                    value={webhookPassword}
                    onChange={e => setWebhookPassword(_ => ReactEvent.Form.target(e)["value"])}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                  />
                </div>
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-medium text-gray-600 mb-1">
                    {"Report Username"->React.string}
                  </label>
                  <input
                    type_="text"
                    value={reportUsername}
                    onChange={e => setReportUsername(_ => ReactEvent.Form.target(e)["value"])}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                  />
                </div>
                <div>
                  <label className="block text-xs font-medium text-gray-600 mb-1">
                    {"Report Password"->React.string}
                  </label>
                  <input
                    type_="password"
                    value={reportPassword}
                    onChange={e => setReportPassword(_ => ReactEvent.Form.target(e)["value"])}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                  />
                </div>
              </div>
            </div>
          </RenderIf>
          // SFTP config fields
          <RenderIf condition={configType === "sftp_internal"}>
            <div className="border-t border-gray-200 pt-4">
              <label className="block text-xs font-medium text-gray-600 mb-1">
                {"File Path"->React.string}
              </label>
              <input
                type_="text"
                value={filePath}
                onChange={e => setFilePath(_ => ReactEvent.Form.target(e)["value"])}
                placeholder="path/to/file"
                className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
          </RenderIf>
          <button
            type_="button"
            disabled={ingestionName->String.trim->String.length === 0 ||
              selectedAccountId === "" ||
              isSubmitting}
            onClick={_ => handleSubmit()->ignore}
            className="w-full px-4 py-2 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700 disabled:bg-gray-300 disabled:cursor-not-allowed transition-colors">
            {(isSubmitting ? "Creating..." : "Add Source")->React.string}
          </button>
        </div>
      </div>
    </RenderIf>
    <RenderIf condition={allAccountsConfigured}>
      <div
        className="text-sm text-green-700 bg-green-50 border border-green-200 rounded-lg px-4 py-3">
        {"All accounts have ingestion sources configured."->React.string}
      </div>
    </RenderIf>
    // Navigation
    <div className="flex justify-between pt-2">
      <button
        type_="button"
        onClick={_ => onBack()}
        className="px-4 py-2 text-gray-600 border border-gray-300 rounded-lg text-sm font-medium hover:bg-gray-50 transition-colors">
        {`\u{2190} Back`->React.string}
      </button>
      <button
        type_="button"
        disabled={!canProceed}
        onClick={_ => onNext()}
        className="px-6 py-2.5 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700 disabled:bg-gray-300 disabled:cursor-not-allowed transition-colors flex items-center gap-2">
        {"Continue to Transformation"->React.string}
        <span> {`\u{2192}`->React.string} </span>
      </button>
    </div>
  </div>
}
