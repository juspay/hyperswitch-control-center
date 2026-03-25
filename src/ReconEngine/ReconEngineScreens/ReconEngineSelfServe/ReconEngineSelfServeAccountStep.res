open ReconEngineSelfServeTypes
open ReconEngineSelfServeUtils

module AccountCard = {
  @react.component
  let make = (~account: createdAccount, ~index: int) => {
    let typeColor =
      account.account_type === "credit"
        ? "bg-green-50 text-green-700 border-green-200"
        : "bg-orange-50 text-orange-700 border-orange-200"
    <div className="flex items-center justify-between p-4 border border-gray-200 rounded-lg">
      <div className="flex items-center gap-3">
        <div
          className="w-8 h-8 rounded-full bg-gray-100 flex items-center justify-center text-sm font-semibold text-gray-600">
          {(index + 1)->Int.toString->React.string}
        </div>
        <div>
          <p className="font-medium text-gray-900"> {account.account_name->React.string} </p>
          <p className="text-xs text-gray-500"> {account.account_id->React.string} </p>
        </div>
      </div>
      <div className="flex items-center gap-2">
        <span className={`text-xs px-2 py-0.5 rounded-full border ${typeColor}`}>
          {account.account_type->LogicUtils.capitalizeString->React.string}
        </span>
        <span
          className="text-xs px-2 py-0.5 rounded-full border bg-gray-50 text-gray-600 border-gray-200">
          {account.currency->React.string}
        </span>
      </div>
    </div>
  }
}

@react.component
let make = (~state: selfServeState, ~onAccountCreated, ~onNext) => {
  let createAccount = ReconEngineSelfServeHooks.useCreateAccount()

  let (accountName, setAccountName) = React.useState(_ => "")
  let (accountType, setAccountType) = React.useState(_ => "credit")
  let (currency, setCurrency) = React.useState(_ => "USD")
  let (isSubmitting, setIsSubmitting) = React.useState(_ => false)

  let handleSubmit = async () => {
    if accountName->String.trim->String.length > 0 {
      setIsSubmitting(_ => true)
      let req: accountCreateRequest = {
        account_name: accountName->String.trim,
        account_type: accountType,
        currency,
        initial_balance: 0.0,
      }
      let result = await createAccount(req)
      switch result {
      | Some(account) => {
          onAccountCreated(account)
          setAccountName(_ => "")
        }
      | None => ()
      }
      setIsSubmitting(_ => false)
    }
  }

  let canProceed = state.accounts->Array.length >= 2

  <div className="flex flex-col gap-6 max-w-xl">
    <div>
      <h2 className="text-lg font-semibold text-gray-900 mb-1">
        {"Create Accounts"->React.string}
      </h2>
      <p className="text-sm text-gray-500">
        {"You need at least two accounts to reconcile. For example, a payment processor account (credit) and a bank account (debit)."->React.string}
      </p>
    </div>
    // Existing accounts
    <RenderIf condition={state.accounts->Array.length > 0}>
      <div className="flex flex-col gap-2">
        <h3 className="text-sm font-medium text-gray-700">
          {`Created Accounts (${state.accounts->Array.length->Int.toString})`->React.string}
        </h3>
        {state.accounts
        ->Array.mapWithIndex((account, index) =>
          <AccountCard key={account.account_id} account index />
        )
        ->React.array}
      </div>
    </RenderIf>
    // Add account form
    <div className="border border-gray-200 rounded-lg p-5 bg-gray-50">
      <h3 className="text-sm font-semibold text-gray-700 mb-4">
        {"Add New Account"->React.string}
      </h3>
      <div className="flex flex-col gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            {"Account Name"->React.string}
          </label>
          <input
            type_="text"
            value={accountName}
            onChange={e => setAccountName(_ => ReactEvent.Form.target(e)["value"])}
            placeholder="e.g., FIUU, Bank Settlement"
            className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
          />
        </div>
        <div className="flex gap-4">
          <div className="flex-1">
            <label className="block text-sm font-medium text-gray-700 mb-1">
              {"Account Type"->React.string}
            </label>
            <div className="flex gap-2">
              <button
                type_="button"
                className={`flex-1 px-3 py-2 rounded-lg text-sm font-medium border transition-colors ${accountType === "credit"
                    ? "bg-green-50 border-green-300 text-green-700"
                    : "bg-white border-gray-300 text-gray-600 hover:bg-gray-50"}`}
                onClick={_ => setAccountType(_ => "credit")}>
                {"Credit"->React.string}
              </button>
              <button
                type_="button"
                className={`flex-1 px-3 py-2 rounded-lg text-sm font-medium border transition-colors ${accountType === "debit"
                    ? "bg-orange-50 border-orange-300 text-orange-700"
                    : "bg-white border-gray-300 text-gray-600 hover:bg-gray-50"}`}
                onClick={_ => setAccountType(_ => "debit")}>
                {"Debit"->React.string}
              </button>
            </div>
            <p className="text-xs text-gray-400 mt-1">
              {"Credit: incoming payments increase balance. Debit: incoming entries decrease balance."->React.string}
            </p>
          </div>
          <div className="flex-1">
            <label className="block text-sm font-medium text-gray-700 mb-1">
              {"Currency"->React.string}
            </label>
            <select
              value={currency}
              onChange={e => setCurrency(_ => ReactEvent.Form.target(e)["value"])}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
              {commonCurrencies
              ->Array.map(c =>
                <option key={c} value={c}> {c->React.string} </option>
              )
              ->React.array}
            </select>
          </div>
        </div>
        <button
          type_="button"
          disabled={accountName->String.trim->String.length === 0 || isSubmitting}
          onClick={_ => handleSubmit()->ignore}
          className="w-full px-4 py-2 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700 disabled:bg-gray-300 disabled:cursor-not-allowed transition-colors">
          {(isSubmitting ? "Creating..." : "Add Account")->React.string}
        </button>
      </div>
    </div>
    // Next button
    <div className="flex justify-end pt-2">
      <button
        type_="button"
        disabled={!canProceed}
        onClick={_ => onNext()}
        className="px-6 py-2.5 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700 disabled:bg-gray-300 disabled:cursor-not-allowed transition-colors flex items-center gap-2">
        {`Continue to Ingestion Setup`->React.string}
        <span> {`\u{2192}`->React.string} </span>
      </button>
    </div>
    <RenderIf condition={state.accounts->Array.length >= 1 && state.accounts->Array.length < 2}>
      <div className="text-sm text-amber-600 bg-amber-50 border border-amber-200 rounded-lg px-4 py-3">
        {`You need at least 2 accounts to reconcile. Add ${(2 - state.accounts->Array.length)->Int.toString} more.`->React.string}
      </div>
    </RenderIf>
  </div>
}
