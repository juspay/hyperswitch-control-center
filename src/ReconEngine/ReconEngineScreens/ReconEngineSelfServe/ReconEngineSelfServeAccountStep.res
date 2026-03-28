open ReconEngineSelfServeTypes
open ReconEngineSelfServeUtils

@react.component
let make = (
  ~wizardState: wizardState,
  ~onAccountCreated: createdAccount => unit,
  ~onNext: unit => unit,
) => {
  let createAccount = ReconEngineSelfServeHooks.useCreateAccount()
  let (accountName, setAccountName) = React.useState(_ => "")
  let (accountType, setAccountType) = React.useState(_ => "credit")
  let (currency, setCurrency) = React.useState(_ => "USD")
  let (initialBalance, setInitialBalance) = React.useState(_ => "0")
  let (isSubmitting, setIsSubmitting) = React.useState(_ => false)
  let (showErrors, setShowErrors) = React.useState(_ => false)

  let isAccountNameEmpty = accountName->String.trim->String.length === 0

  let errorInputClass = "!border-red-400 !focus:border-red-400 !focus:ring-red-400"

  let handleSubmit = async () => {
    if isAccountNameEmpty {
      setShowErrors(_ => true)
    } else {
      setShowErrors(_ => false)
      setIsSubmitting(_ => true)
      let balance = initialBalance->Float.fromString->Option.getOr(0.0)
      let result = await createAccount(
        ~accountName,
        ~accountType,
        ~currency,
        ~initialBalance=balance,
      )
      switch result {
      | Some(account) => {
          onAccountCreated(account)
          setAccountName(_ => "")
          setAccountType(_ => "credit")
          setCurrency(_ => "USD")
          setInitialBalance(_ => "0")
        }
      | None => ()
      }
      setIsSubmitting(_ => false)
    }
  }

  <div className="flex flex-col gap-10 max-w-3xl">
    // Header
    <div className="flex flex-col gap-2">
      <div className="flex items-center gap-2">
        <div
          className="w-8 h-8 rounded-full bg-blue-50 flex items-center justify-center text-sm font-semibold text-blue-600">
          {"1"->React.string}
        </div>
        <h2 className="text-lg font-semibold text-nd_gray-800">
          {"Create Accounts"->React.string}
        </h2>
      </div>
      <p className="text-sm text-nd_gray-500 leading-relaxed ml-4 sm:ml-10">
        {"Accounts represent your data sources. You typically need at least two: a credit account (e.g., your payment gateway) and a debit account (e.g., your bank). The recon engine will match entries between these accounts."->React.string}
      </p>
    </div>
    // How it works — visual diagram
    <div className="ml-4 sm:ml-10 p-4 bg-blue-50 rounded-lg border border-blue-100">
      <div className="flex items-start gap-3">
        <Icon name="nd-overview" className="text-blue-500 mt-0.5" customHeight="16" />
        <div className="flex flex-col gap-3">
          <p className="text-sm font-medium text-blue-700"> {"How it works"->React.string} </p>
          <div className="flex items-center gap-3">
            <div className="flex flex-col gap-1 p-2 bg-blue-100 rounded-md border border-blue-200 text-center min-w-[100px]">
              <p className="text-xs font-semibold text-blue-700"> {"Credit"->React.string} </p>
              <p className="text-[10px] text-blue-600"> {"Payment Gateway"->React.string} </p>
              <p className="text-[10px] text-blue-500 italic"> {"e.g., FIUU, Stripe"->React.string} </p>
            </div>
            <div className="flex flex-col items-center gap-0.5">
              <Icon name="nd-arrow-right" customHeight="12" className="text-blue-400" />
              <p className="text-[9px] text-blue-400 font-medium"> {"reconcile"->React.string} </p>
              <Icon name="nd-arrow-left" customHeight="12" className="text-blue-400" />
            </div>
            <div className="flex flex-col gap-1 p-2 bg-green-100 rounded-md border border-green-200 text-center min-w-[100px]">
              <p className="text-xs font-semibold text-green-700"> {"Debit"->React.string} </p>
              <p className="text-[10px] text-green-600"> {"Bank Settlement"->React.string} </p>
              <p className="text-[10px] text-green-500 italic"> {"e.g., CIMB, HSBC"->React.string} </p>
            </div>
          </div>
          <p className="text-xs text-blue-600 leading-relaxed">
            {"The engine matches entries between your credit account (money in) and debit account (money confirmed) to find discrepancies."->React.string}
          </p>
        </div>
      </div>
    </div>
    // Quick Start hint (shown when no accounts exist yet)
    <RenderIf condition={wizardState.accounts->Array.length === 0}>
      <div className="ml-4 sm:ml-10 p-3 bg-amber-50 rounded-lg border border-amber-200">
        <p className="text-xs text-amber-700">
          {"Start by creating a credit account for your payment processor (e.g., \"FIUU\" or \"Stripe\"), then create a debit account for your bank settlement data."->React.string}
        </p>
      </div>
    </RenderIf>
    // Form
    <div
      className="ml-4 sm:ml-10 flex flex-col gap-5 p-6 rounded-xl border border-nd_gray-200 bg-white">
      <div className="flex flex-col gap-1.5">
        <label htmlFor="accountName" className="text-sm font-medium text-nd_gray-700">
          {"Account Name"->React.string}
        </label>
        <input
          id="accountName"
          type_="text"
          className={showErrors && isAccountNameEmpty
            ? `${inputClassName} ${errorInputClass}`
            : inputClassName}
          placeholder="e.g., FIUU, Bank Settlement, Stripe"
          value={accountName}
          onChange={e => setAccountName(_ => ReactEvent.Form.target(e)["value"])}
        />
        <RenderIf condition={showErrors && isAccountNameEmpty}>
          <p className="text-xs text-red-500"> {"Account name is required"->React.string} </p>
        </RenderIf>
      </div>
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <div className="flex flex-col gap-1.5">
          <label className="text-sm font-medium text-nd_gray-700">
            {"Account Type"->React.string}
          </label>
          <p className="text-xs text-nd_gray-400">
            {"Credit = money in (gateway), Debit = money out (bank)"->React.string}
          </p>
          <SelectBox
            input={makeControlledSelectInput(
              ~name="accountType",
              ~value=accountType,
              ~setValue=setAccountType,
            )}
            options={accountTypeOptions}
            deselectDisable=true
            showClearAll=false
          />
        </div>
        <div className="flex flex-col gap-1.5">
          <label className="text-sm font-medium text-nd_gray-700">
            {"Currency"->React.string}
          </label>
          <p className="text-xs text-nd_gray-400">
            {"Select the currency for this account"->React.string}
          </p>
          <SelectBox
            input={makeControlledSelectInput(
              ~name="currency",
              ~value=currency,
              ~setValue=setCurrency,
            )}
            options={currencyOptions}
            deselectDisable=true
            showClearAll=false
          />
        </div>
      </div>
      <div className="flex flex-col gap-1.5">
        <label htmlFor="initialBalance" className="text-sm font-medium text-nd_gray-700">
          {"Initial Balance"->React.string}
        </label>
        <p className="text-xs text-nd_gray-400">
          {"Starting balance (e.g., 0.00)"->React.string}
        </p>
        <input
          id="initialBalance"
          type_="number"
          className=inputClassName
          placeholder="0.00"
          value={initialBalance}
          onChange={e => setInitialBalance(_ => ReactEvent.Form.target(e)["value"])}
        />
      </div>
      <Button
        text="Create Account"
        buttonType=Primary
        buttonSize=Small
        onClick={_ => handleSubmit()->ignore}
        buttonState={isSubmitting ? Loading : Normal}
        customButtonStyle="w-full mt-2"
      />
    </div>
    // Created accounts list
    <RenderIf condition={wizardState.accounts->Array.length > 0}>
      <div className="ml-4 sm:ml-10 flex flex-col gap-3">
        <h3 className="text-sm font-semibold text-nd_gray-700">
          {`Created Accounts (${wizardState.accounts->Array.length->Int.toString})`->React.string}
        </h3>
        <div className="flex flex-col gap-2">
          {wizardState.accounts
          ->Array.mapWithIndex((account, idx) => {
            let bgColor =
              account.account_type === "credit"
                ? "bg-blue-50 border-blue-200"
                : "bg-green-50 border-green-200"
            let textColor = account.account_type === "credit" ? "text-blue-700" : "text-green-700"
            let badgeColor =
              account.account_type === "credit"
                ? "bg-blue-100 text-blue-600"
                : "bg-green-100 text-green-600"
            <div
              key={idx->Int.toString}
              className={`flex items-center justify-between p-3 rounded-lg border ${bgColor}`}>
              <div className="flex items-center gap-3">
                <Icon name="nd-check" customHeight="14" className="text-green-500" />
                <span className={`text-sm font-medium ${textColor}`}>
                  {account.account_name->React.string}
                </span>
                <span className={`text-xs px-2 py-0.5 rounded-full ${badgeColor}`}>
                  {account.account_type->React.string}
                </span>
              </div>
              <span className="text-xs text-nd_gray-400 font-mono">
                {account.account_id->React.string}
              </span>
            </div>
          })
          ->React.array}
        </div>
      </div>
    </RenderIf>
    // Next button
    <RenderIf condition={wizardState.accounts->Array.length >= 2}>
      <div className="ml-4 sm:ml-10">
        <Button
          text="Continue to Data Sources"
          buttonType=Primary
          buttonSize=Small
          onClick={_ => onNext()}
          rightIcon={CustomIcon(<Icon name="nd-arrow-right" customHeight="14" />)}
          customButtonStyle="w-full"
        />
      </div>
    </RenderIf>
    <RenderIf condition={wizardState.accounts->Array.length === 1}>
      <div className="ml-4 sm:ml-10 p-3 bg-amber-50 rounded-lg border border-amber-200">
        <p className="text-xs text-amber-700">
          {"You need at least 2 accounts (one credit, one debit) to set up reconciliation. Create one more account to continue."->React.string}
        </p>
      </div>
    </RenderIf>
  </div>
}
