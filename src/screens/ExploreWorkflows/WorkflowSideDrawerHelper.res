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
      <div>
        <p className={`${body.md.medium} text-nd_gray-600`}>
          {"1. Toggle "->React.string}
          <span className=body.md.bold> {"Auto Retries "->React.string} </span>
          {"ON ."->React.string}
        </p>
      </div>
      <div>
        <p className={`${body.md.medium} text-nd_gray-600`}>
          {"2. A "->React.string}
          <span className=body.md.bold> {"Max Auto Retries"->React.string} </span>
          {" field will appear — enter how many times a failed payment should be retried (e.g., 2)."->React.string}
        </p>
      </div>
      <div>
        <p className={`${body.md.medium} text-nd_gray-600`}>
          {"3. Click Update to "->React.string}
          <span className=body.md.bold> {"save"->React.string} </span>
          {"."->React.string}
        </p>
      </div>
    </div>
  </div>
}

let addAtleastTwoConnectors = {
  <div className="flex flex-col gap-4">
    <div className="text-jp-gray-700 space-x-1">
      <span className={`${body.md.medium} text-nd_gray-400`}> {"Go to"->React.string} </span>
      <span
        className={`text-nd_gray-600 bg-nd_gray-50 px-2 py-0.5 border border-nd_gray-200 rounded ${body.sm.semibold}`}>
        {"Connectors → Payment Processors"->React.string}
      </span>
    </div>
    <div className="flex flex-col gap-4">
      <div>
        <p className={`${body.md.medium} text-nd_gray-600`}>
          {"1. Click "->React.string}
          <span className=body.md.bold> {"Connect "->React.string} </span>
          {"under any available processor to add your own credentials."->React.string}
        </p>
      </div>
      <div>
        <p className={`${body.md.medium} text-nd_gray-600`}>
          {"2. Or,use  "->React.string}
          <span className=body.md.bold> {"Dummy Processors"->React.string} </span>
          {" by clicking “Connect Now” at the top and selecting any two test processors (e.g., Stripe Dummy + Paypal Dummy)."->React.string}
        </p>
      </div>
    </div>
  </div>
}

let setProcessorPriorityOrder = {
  <div className="flex flex-col gap-4">
    <div className="text-jp-gray-700 space-x-1">
      <span className={`${body.md.medium} text-nd_gray-400`}> {"Go to"->React.string} </span>
      <span
        className={`text-nd_gray-600 bg-nd_gray-50 px-2 py-0.5 border border-nd_gray-200 rounded ${body.sm.semibold}`}>
        {"Workflow → Routing → Default Fallback"->React.string}
      </span>
    </div>
    <div className="flex flex-col gap-4">
      <div>
        <p className={`${body.md.medium} text-nd_gray-600`}>
          {"1. Drag and drop to set your preferred order of processors. "->React.string}
        </p>
      </div>
      <div>
        <p className={`${body.md.medium} text-nd_gray-600`}>
          {"2. The first connector will be tried first; on failure, retries follow the list order. (e.g., Stripe Dummy will be “1”+ Paypal Dummy will be “2”)"->React.string}
        </p>
      </div>
      <div>
        <p className={`${body.md.medium} text-nd_gray-600`}>
          {"3. Click"->React.string}
          <span className=body.md.bold> {" Save Changes."->React.string} </span>
        </p>
      </div>
    </div>
  </div>
}
