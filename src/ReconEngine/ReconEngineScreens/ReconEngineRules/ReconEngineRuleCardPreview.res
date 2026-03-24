open Typography
open ReconEngineRulesTypes
open ReconEngineRulesUtils

module AccountPill = {
  @react.component
  let make = (~accountId: string, ~accountData: array<ReconEngineTypes.accountType>, ~color: string) => {
    let accountName = getAccountName(accountId, accountData)
    <div
      className={`flex flex-row items-center gap-2 px-3 py-1.5 rounded-lg border ${color} text-sm font-medium`}>
      <Icon name="nd-connectors" size=14 />
      <span className="truncate max-w-[140px]"> {accountName->React.string} </span>
    </div>
  }
}

module StrategyBadge = {
  @react.component
  let make = (~strategy: reconStrategyType) => {
    let label = getReconStrategyDisplayName(strategy)
    let shortLabel = switch strategy {
    | OneToOne(_) => "1:1"
    | OneToMany(_) => "1:N"
    | UnknownReconStrategy => "?"
    }
    <div className="flex flex-col items-center gap-1">
      <div
        className="w-8 h-8 rounded-full bg-nd_gray-100 border border-nd_gray-200 flex items-center justify-center">
        <span className={`text-nd_gray-600 ${body.sm.semibold}`}> {shortLabel->React.string} </span>
      </div>
      <span className={`text-nd_gray-400 ${body.sm.medium} text-center max-w-[120px] truncate`}>
        {label->React.string}
      </span>
    </div>
  }
}

module RuleCard = {
  @react.component
  let make = (~rule: rulePayload, ~accountData: array<ReconEngineTypes.accountType>) => {
    let (sourceAccountId, targetAccounts) = getSourceAndTargetAccountDetails(rule.strategy)

    <div
      className="border border-nd_gray-150 rounded-xl p-4 bg-white hover:border-nd_gray-300 transition-colors cursor-pointer"
      onClick={_ => {
        RescriptReactRouter.push(
          GlobalVars.appendDashboardPath(~url=`/v1/recon-engine/rules/${rule.rule_id}`),
        )
      }}>
      <div className="flex flex-row justify-between items-start mb-3">
        <div className="flex flex-col gap-1">
          <div className="flex flex-row items-center gap-2">
            <p className={`text-nd_gray-800 ${body.md.semibold}`}> {rule.rule_name->React.string} </p>
            <div
              className={`px-2 py-0.5 rounded-full text-xs font-semibold ${rule.is_active
                  ? "bg-nd_green-50 text-nd_green-600"
                  : "bg-nd_gray-100 text-nd_gray-500"}`}>
              {(rule.is_active ? "Active" : "Inactive")->React.string}
            </div>
          </div>
          <RenderIf condition={rule.rule_description->LogicUtils.isNonEmptyString}>
            <p className={`text-nd_gray-400 ${body.sm.medium} truncate max-w-md`}>
              {rule.rule_description->React.string}
            </p>
          </RenderIf>
        </div>
        <div
          className={`px-2 py-1 rounded-md bg-nd_gray-50 border border-nd_gray-150 ${body.sm.semibold} text-nd_gray-600`}>
          {`P${rule.priority->Int.toString}`->React.string}
        </div>
      </div>
      <div className="flex flex-row items-center gap-3 mt-4">
        <AccountPill
          accountId={sourceAccountId} accountData color="bg-blue-50 border-blue-200 text-blue-700"
        />
        <Icon name="nd-arrow-right" size=16 className="text-nd_gray-400 flex-shrink-0" />
        <StrategyBadge strategy={rule.strategy} />
        <Icon name="nd-arrow-right" size=16 className="text-nd_gray-400 flex-shrink-0" />
        <div className="flex flex-row items-center gap-2 flex-wrap">
          {targetAccounts
          ->Array.mapWithIndex((target, index) => {
            <AccountPill
              key={index->Int.toString}
              accountId={target.account_id}
              accountData
              color="bg-green-50 border-green-200 text-green-700"
            />
          })
          ->React.array}
        </div>
      </div>
    </div>
  }
}

@react.component
let make = (~rulesData: array<rulePayload>, ~accountData: array<ReconEngineTypes.accountType>) => {
  <RenderIf condition={rulesData->Array.length > 0}>
    <div className="flex flex-col gap-3">
      {rulesData
      ->Array.map(rule => {
        <RuleCard key={rule.rule_id} rule accountData />
      })
      ->React.array}
    </div>
  </RenderIf>
}
