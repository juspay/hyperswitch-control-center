module Field = {
  @react.component
  let make = (~label: string, ~value: string, ~copyData=?) => {
    <div className="flex flex-row items-center">
      <p className="text-gray-500 dark:text-gray-400 pb-2 w-[40%] text-sm">
        {label->React.string}
      </p>
      <p className="text-gray-900 font-semibold text-sm dark:text-gray-400 pt-2 pb-2 pl-2">
        {value->React.string}
      </p>
      {switch copyData {
      | Some(data) => <Clipboard.Copy data={data->JSON.Encode.string} />
      | None => React.null
      }}
    </div>
  }
}

@react.component
let make = () => {
  let testCardNumber = "4242 4242 4242 4242"
  let cardNumberCopy = "4242424242424242"
  let testCredsLink = "https://docs.hyperswitch.io/hyperswitch-cloud/connectors/test-a-payment-with-connector"
  let applePayDocsLink = "https://hyperswitch.io/docs/paymentMethods/testCredentials"

  <div className="p-6 bg-jp-gray-test_credentials_bg w-full h-fit">
    <div className="mb-4">
      <div className="flex items-center gap-4 mb-2">
        <p className="text-sm font-semibold">
          {"For Testing Stripe & Dummy Connectors"->React.string}
        </p>
      </div>
      <div className="border-b border-[#c5d7f1] pb-4 mb-4">
        <Field label="Card Number :" value=testCardNumber copyData=cardNumberCopy />
        <Field label="Expiry:" value="Any future date" />
        <Field label="CVC:" value="Any 3 Digits" />
        <a
          className="flex items-center text-blue-400 dark:text-blue-300 hover:underline cursor-pointer gap-1 pt-2"
          href=testCredsLink
          target="_blank"
          rel="noopener noreferrer">
          {"Test creds for other connectors here"->React.string}
          <img alt="open-new-tab" src="/icons/open-new-tab.svg" />
        </a>
      </div>
    </div>
    <div className="flex items-center gap-4 mb-4">
      <p className="text-sm font-semibold"> {"For Testing Apple Pay"->React.string} </p>
      <img alt="apple-pay" src="/Gateway/APPLE_PAY.svg" className="w-10 h-10" />
    </div>
    <div className="text-sm text-gray-700 opacity-70 leading-5">
      <span>
        {"Apple Pay cannot be tested from the dashboard as it is registered with merchant domain name and not app.hyperswitch. Please test using merchant SDK – refer the "->React.string}
      </span>
      <a
        className="text-blue-400 underline underline-offset-4 decoration-blue-400"
        href=applePayDocsLink
        target="_blank"
        rel="noopener noreferrer">
        {"documentation"->React.string}
      </a>
    </div>
  </div>
}
