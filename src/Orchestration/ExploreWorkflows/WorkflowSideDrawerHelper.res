open Typography

let exploreAutoRetries = {
  <div className="flex flex-col gap-4">
    <div className="text-jp-gray-700 space-x-1">
      <span className={`${body.md.medium} text-nd_gray-400`}> {"Go to"->React.string} </span>
      <span
        className={`text-nd_gray-600 bg-nd_gray-50 px-2 py-0.5 border border-nd_gray-200 rounded ${body.sm.semibold}`}>
        {"Developers → Payment Settings"->React.string}
      </span>
    </div>
    <div className="flex flex-col gap-4">
      <p className={`${body.md.medium} text-nd_gray-600`}>
        {"1. Toggle "->React.string}
        <span className=body.md.bold> {"Auto Retries "->React.string} </span>
        {"ON ."->React.string}
      </p>
      <p className={`${body.md.medium} text-nd_gray-600`}>
        {"2. A "->React.string}
        <span className=body.md.bold> {"Max Auto Retries"->React.string} </span>
        {" field will appear — enter how many times a failed payment should be retried (e.g., 2)."->React.string}
      </p>
      <p className={`${body.md.medium} text-nd_gray-600`}>
        {"3. Click Update to "->React.string}
        <span className=body.md.bold> {"save"->React.string} </span>
        {"."->React.string}
      </p>
    </div>
  </div>
}

let addAtleastTwoConnectors = {
  <div className="flex flex-col gap-4">
    <div className="text-jp-gray-700 space-x-1">
      <span className={`${body.md.medium} text-nd_gray-400`}> {"Navigate to"->React.string} </span>
      <span
        className={`text-nd_gray-600 bg-nd_gray-50 px-2 py-0.5 border border-nd_gray-200 rounded ${body.sm.semibold}`}>
        {"Connectors → Payment Processors"->React.string}
      </span>
    </div>
    <div className="flex flex-col gap-4">
      <p className={`${body.md.medium} text-nd_gray-600`}>
        {"1. Click "->React.string}
        <span className=body.md.bold> {"Connect a Dummy Processor "->React.string} </span>
      </p>
      <p className={`${body.md.medium} text-nd_gray-600`}>
        {"2. Locate  "->React.string}
        <span className=body.md.bold> {"Paypal Dummy"->React.string} </span>
        {", then click "->React.string}
        <span className=body.md.bold> {"Connect."->React.string} </span>
      </p>
      <p className={`${body.md.medium} text-nd_gray-600`}>
        {"3. Click  "->React.string}
        <span className=body.md.bold> {"Continue"->React.string} </span>
        {" to complete the Paypal Dummy setup."->React.string}
      </p>
      <p className={`${body.md.medium} text-nd_gray-600`}>
        {"4. Repeat steps 2-4 to add "->React.string}
        <span className=body.md.bold> {"Stripe Dummy."->React.string} </span>
      </p>
    </div>
  </div>
}

let setProcessorPriorityOrder = {
  <div className="flex flex-col gap-4">
    <div className="text-jp-gray-700 space-x-1">
      <span className={`${body.md.medium} text-nd_gray-400`}> {"Navigate to"->React.string} </span>
      <span
        className={`text-nd_gray-600 bg-nd_gray-50 px-2 py-0.5 border border-nd_gray-200 rounded ${body.sm.semibold}`}>
        {"Workflow → Routing → Default Fallback"->React.string}
      </span>
    </div>
    <div className="flex flex-col gap-4">
      <p className={`${body.md.medium} text-nd_gray-600`}>
        {"1. Arrange connectors so "->React.string}
        <span className=body.md.bold> {" PayPal Dummy"->React.string} </span>
        {" is first and "->React.string}
        <span className=body.md.bold> {"Stripe Dummy"->React.string} </span>
        {" is second."->React.string}
      </p>
      <p className={`${body.md.medium} text-nd_gray-600`}>
        {"2. Click"->React.string}
        <span className=body.md.bold> {" Save Changes"->React.string} </span>
        {"—ensure this sequence."->React.string}
      </p>
    </div>
  </div>
}

let simulateAndVerifyRetry = {
  <div className="flex flex-col gap-4">
    <div className="text-jp-gray-700 space-x-1">
      <span className={`${body.md.medium} text-nd_gray-400`}> {"Navigate to"->React.string} </span>
      <span
        className={`text-nd_gray-600 bg-nd_gray-50 px-2 py-0.5 border border-nd_gray-200 rounded ${body.sm.semibold}`}>
        {"Overview → Try It Out."->React.string}
      </span>
    </div>
    <div className="flex flex-col gap-4">
      <p className={`${body.md.medium} text-nd_gray-600`}>
        {"1. Click"->React.string}
        <span className=body.md.bold> {" Show Preview."->React.string} </span>
      </p>
      <div className={`${body.md.medium} text-nd_gray-600 flex flex-col gap-2`}>
        {"2. In the payment form, enter:"->React.string}
        <div className="ml-4 flex flex-col gap-2">
          <div className="flex items-center gap-2">
            <div className="h-1 w-1 rounded-full bg-nd_gray-700" />
            <span className=body.md.bold> {"Card Number:"->React.string} </span>
            {"4000 0000 0000 9995"->React.string}
          </div>
          <div className="flex items-center gap-2">
            <div className="h-1 w-1 rounded-full bg-nd_gray-700" />
            <span className=body.md.bold> {"Expiry Date:"->React.string} </span>
            {"Any future date"->React.string}
          </div>
          <div className="flex items-center gap-2">
            <div className="h-1 w-1 rounded-full bg-nd_gray-700" />
            <span className=body.md.bold> {"CVC:"->React.string} </span>
            {"Any three-digit number"->React.string}
          </div>
          <div className="flex items-center gap-2">
            <div className="h-1 w-1 rounded-full bg-nd_gray-700" />
            {"Then click"->React.string}
            <span className=body.md.bold> {"Pay"->React.string} </span>
          </div>
        </div>
      </div>
      <p className={`${body.md.medium} text-nd_gray-600`}>
        {"3. Verify that the transaction fails on PayPal and is retried on Stripe. Once you see the"->React.string}
        <span className=body.md.bold> {" “Payment Successful”"->React.string} </span>
        {" banner, click"->React.string}
        <span className=body.md.bold> {" Go to Payment Operations"->React.string} </span>
        {", then expand"->React.string}
        <span className=body.md.bold> {" Payment Attempts"->React.string} </span>
        {" to view the two attempts"->React.string}
      </p>
    </div>
  </div>
}
