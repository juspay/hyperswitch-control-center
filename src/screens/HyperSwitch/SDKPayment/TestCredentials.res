@react.component
let make = () => {
  let initialValues = Dict.make()
  Dict.set(initialValues, "dummy_card_number", "4242 4242 4242 4242"->Js.Json.string)
  <div className="p-6 bg-jp-gray-test_credentials_bg w-full h-fit">
    <div className="mb-4">
      <div className="flex items-center gap-4">
        <p className="text-sm font-semibold">
          {"For Testing Stripe & Dummy Connectors"->React.string}
        </p>
      </div>
      <div className="border-b border-[#c5d7f1] pb-4 mb-4">
        <div className="flex flex-row items-center pt-4">
          <p className="text-gray-500 dark:text-gray-400 pb-2 w-[40%] text-sm">
            {"Card Number :"->React.string}
          </p>
          <p className="text-gray-900 text-bold text-sm dark:text-gray-400 pt-2 pb-2 pl-2 ">
            {"4242 4242 4242 4242"->React.string}
          </p>
          <Clipboard.Copy data={"4242424242424242"->Js.Json.string} />
        </div>
        <div className="flex flex-row items-center">
          <p className="text-gray-500 dark:text-gray-400 pb-2 w-[40%] text-sm">
            {"Expiry:"->React.string}
          </p>
          <p className="text-gray-900 text-bold text-sm dark:text-gray-400 pt-2 pb-2 pl-2 ">
            {"Any future date"->React.string}
          </p>
        </div>
        <div className="flex flex-row items-center">
          <p className="text-gray-500 dark:text-gray-400 pb-2 w-[40%] text-sm">
            {"CVC:"->React.string}
          </p>
          <p className="text-gray-900 text-bold text-sm dark:text-gray-400 pt-2 pb-2 pl-2 ">
            {"Any 3 Digits"->React.string}
          </p>
        </div>
        <div
          className="flex items-center cursor-pointer text-blue-600 dark:text-blue-500 hover:underline"
          onClick={_ => {
            Window._open(
              "https://docs.hyperswitch.io/hyperswitch-cloud/connectors/test-a-payment-with-connector",
            )
          }}>
          {"Test creds for other connectors here"->React.string}
          <img src={`/icons/open-new-tab.svg`} />
        </div>
      </div>
    </div>
    <div className="flex items-center gap-4">
      <p className="text-sm font-semibold"> {"For Testing Apple Pay"->React.string} </p>
      <img src={`/Gateway/APPLE_PAY.svg`} className="w-10 h-10" />
    </div>
    <div className="flex flex-row w-full mb-4 text-sm">
      <p className="text-grey-700 opacity-50 leading-5">
        <p className="inline">
          {"Apple Pay cannot be tested from the dashboard as it is registered with merchant domain name and not app.hyperswitch. Please test using merchant SDK - refer the "->React.string}
        </p>
        <a
          className="inline text-blue-600 underline underline-offset-4 decoration-blue-600"
          href="https://hyperswitch.io/docs/paymentMethods/testCredentials"
          target="_blank">
          //TODO - Need to be changed with Apple Pay Hyperlink.
          {"documentation"->React.string}
        </a>
      </p>
    </div>
  </div>
}
