module SuggestedAction = {
  @react.component
  let make = () => {
    <div
      className="whitespace-pre-line break-all flex flex-col gap-1 p-2 ml-4 text-base dark:text-jp-gray-text_darktheme dark:text-opacity-50 font-medium leading-7 opacity-50 mt-4">
      {`Suggested Action:`->React.string}
    </div>
  }
}
module StripSendingCreditCard = {
  @react.component
  let make = () => {
    <>
      <SuggestedAction />
      <div
        className="whitespace-pre-line break-word flex flex-col gap-1 bg-green-50 rounded-md font-medium p-4 ml-6">
        <div className="inline gap-1">
          {`Click `->React.string}
          <a
            className="inline text-blue-900 underline"
            href="https://dashboard.stripe.com/settings/integration"
            target="_blank">
            {React.string("here")}
          </a>
          {` to turn on the "Enable raw card processing" toggle under the show advanced settings`->React.string}
        </div>
      </div>
    </>
  }
}

module StripeInvalidAPIKey = {
  @react.component
  let make = () => {
    <>
      <SuggestedAction />
      <div
        className="whitespace-pre-line break-word flex flex-col gap-1 bg-green-50 rounded-md font-medium p-4 ml-6">
        <div className="inline gap-1">
          {`Please use a secret API key. Click `->React.string}
          <a
            className="inline text-blue-900 underline"
            href="https://dashboard.stripe.com/test/apikeys"
            target="_blank">
            {React.string("here")}
          </a>
          {` to find the Secret key of your stripe account from the list of your API keys`->React.string}
        </div>
      </div>
    </>
  }
}

module PaypalClientAuthenticationFalied = {
  @react.component
  let make = () => {
    <>
      <SuggestedAction />
      <div
        className="whitespace-pre-line break-word flex flex-col gap-1 bg-green-50 rounded-md font-medium p-4 ml-6">
        <div className="inline gap-1">
          {`Please use the correct credentials. Click `->React.string}
          <a
            className="inline text-blue-900 underline"
            href="https://developer.paypal.com/dashboard/applications/sandbox"
            target="_blank">
            {React.string("here")}
          </a>
          {` to find the client secret and client key of your Paypal`->React.string}
        </div>
      </div>
    </>
  }
}
