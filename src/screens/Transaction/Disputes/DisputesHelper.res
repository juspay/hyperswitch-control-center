open Typography

module DualRefundsAlert = {
  @react.component
  let make = (~subText, ~customLearnMoreComponent=React.null) => {
    <div
      className="my-4 flex flex-col gap-2 rounded-lg border border-nd_yellow-500 bg-nd_yellow-50 p-4">
      <div className="flex flex-row justify-between items-center">
        <div className="flex flex-col gap-2">
          <div className="flex flex-row items-center gap-2">
            <Icon name="nd-alert-triangle-outline" size={16} className="text-nd_gray-800" />
            <p className={`${body.md.semibold} text-nd_gray-800`}>
              {"Dual Refunds Detected"->React.string}
            </p>
          </div>
          <p className={`${body.md.regular} text-nd_gray-600 pl-6`}> {subText->React.string} </p>
        </div>
        {customLearnMoreComponent}
      </div>
    </div>
  }
}

module LearnMoreComponent = {
  @react.component
  let make = (~disputesData: DisputeTypes.disputes, ~merchantId, ~orgId) => {
    <Link
      to_={GlobalVars.appendDashboardPath(
        ~url=`/payments/${disputesData.payment_id}/${disputesData.profile_id}/${merchantId->Option.getOr(
            "",
          )}/${orgId->Option.getOr("")}`,
      )}>
      <p className={`${body.md.semibold} text-nd_yellow-700`}> {"Learn More"->React.string} </p>
    </Link>
  }
}
