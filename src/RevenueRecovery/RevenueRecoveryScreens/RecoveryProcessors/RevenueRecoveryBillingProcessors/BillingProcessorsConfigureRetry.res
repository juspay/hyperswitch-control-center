@react.component
let make = (~handleAuthKeySubmit, ~initialValues, ~validateMandatoryField) => {
  open RevenueRecoveryOnboardingUtils

  <PageWrapper
    title="Configure Recovery Plan"
    subTitle="Set up how invoices should be selected and processed for recovery.">
    <Form onSubmit={handleAuthKeySubmit} initialValues validate=validateMandatoryField>
      <div className="max-w-md mx-auto space-y-8">
        <div>
          <div className="font-semibold text-gray-700 mb-2">
            {"External Retry Configuration"->React.string}
          </div>
          <label className="block text-gray-600 text-sm mb-1" htmlFor="retryAfter">
            {"Start Retry After"->React.string}
            <span className="text-red-500 ml-1"> {"*"->React.string} </span>
          </label>
          <div className="flex items-center">
            <div
              className="w-full border border-gray-200 rounded-lg px-4 py-2 text-gray-700 bg-gray-50 flex justify-between">
              {"03"->React.string}
              <span className="ml-2 text-gray-400"> {"Attempts"->React.string} </span>
            </div>
          </div>
        </div>
        <div>
          <div className="font-semibold text-gray-700 mb-2">
            {"Multi card retry Configuration"->React.string}
          </div>
          <div className="flex space-x-4">
            <div className="flex-1">
              <label className="block text-gray-600 text-sm mb-1" htmlFor="noOfRetries">
                {"No of Retries"->React.string}
                <span className="text-red-500 ml-1"> {"*"->React.string} </span>
              </label>
              <div
                className="w-full border border-gray-200 rounded-lg px-4 py-2 text-gray-700 bg-gray-50">
                {"03"->React.string}
              </div>
            </div>
            <div className="flex-1">
              <label className="block text-gray-600 text-sm mb-1" htmlFor="noOfDays">
                {"No of Days"->React.string}
                <span className="text-red-500 ml-1"> {"*"->React.string} </span>
              </label>
              <div
                className="w-full border border-gray-200 rounded-lg px-4 py-2 text-gray-700 bg-gray-50">
                {"03"->React.string}
              </div>
            </div>
          </div>
        </div>
        <div>
          <div className="font-semibold text-gray-700 mb-2">
            {"Hard decline retry Configuration"->React.string}
          </div>
          <div className="bg-gray-50 border border-gray-200 rounded-xl p-4 mb-4 flex">
            <div>
              <div className="font-semibold text-gray-700 flex items-center mb-1">
                <svg
                  className="w-5 h-5 text-gray-400 mr-2"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="2"
                  viewBox="0 0 24 24">
                  <circle cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="2" />
                  <path strokeLinecap="round" strokeLinejoin="round" d="M12 8v4m0 4h.01" />
                </svg>
                {"Hard Declines Budget"->React.string}
              </div>
              <div className="text-gray-500 text-sm mb-2">
                {"Some card declines (e.g. lost/stolen or AVS mismatch) are still salvageable—but they need extra “retry power” like switching gateways or using backup networks."->React.string}
              </div>
              <ul className="list-disc pl-5 text-gray-500 text-sm space-y-1">
                <li>
                  {"Pick how much you're willing to spend each month (e.g. $500)."->React.string}
                </li>
                <li>
                  {"We only use it when our system sees a &gt;50% chance of success."->React.string}
                </li>
              </ul>
            </div>
          </div>
          <div>
            <label className="block text-gray-600 text-sm mb-1" htmlFor="suggestedBudget">
              {"Suggested Budget"->React.string}
            </label>
            <div
              className="w-full border border-gray-200 rounded-lg px-4 py-2 text-gray-700 bg-gray-50">
              {" $ 1600"->React.string}
            </div>
          </div>
        </div>
      </div>
      <FormRenderer.SubmitButton
        text="Next"
        buttonSize={Small}
        customSumbitButtonStyle="!w-full mt-8"
        tooltipForWidthClass="w-full"
      />
    </Form>
  </PageWrapper>
}
