let defaultValueOfCheckList: ProdOnboardingTypes.checkListType = {
  headerText: "Setup Your First Processor",
  headerVariant: #SetupProcessor,
  itemsVariants: [SELECT_PROCESSOR, SETUP_CREDS, SETUP_WEBHOOK_PROCESSOR],
}

let checkList: array<ProdOnboardingTypes.checkListType> = [
  {
    headerText: "Configure Live Endpoints",
    headerVariant: #ConfigureEndpoint,
    itemsVariants: [REPLACE_API_KEYS, SETUP_WEBHOOK_USER],
  },
  {
    headerText: "Complete Setup",
    headerVariant: #SetupComplete,
    itemsVariants: [SETUP_COMPLETED],
  },
]

let updatedCheckList = [defaultValueOfCheckList]->Array.concat(checkList)

let getPageView = index => {
  open ProdOnboardingTypes
  switch index {
  | SELECT_PROCESSOR => SETUP_CREDS
  | SETUP_CREDS => SETUP_WEBHOOK_PROCESSOR
  | SETUP_WEBHOOK_PROCESSOR => REPLACE_API_KEYS
  | REPLACE_API_KEYS => SETUP_WEBHOOK_USER
  | SETUP_WEBHOOK_USER => SETUP_COMPLETED
  | _ => SETUP_COMPLETED
  }
}

let getBackPageView = index => {
  open ProdOnboardingTypes
  switch index {
  | SETUP_CREDS => SELECT_PROCESSOR
  | SETUP_WEBHOOK_PROCESSOR => SETUP_CREDS
  | REPLACE_API_KEYS => SETUP_WEBHOOK_PROCESSOR
  | SETUP_WEBHOOK_USER => REPLACE_API_KEYS
  | _ => SETUP_COMPLETED
  }
}

let getIndexFromVariant = index => {
  open ProdOnboardingTypes
  switch index {
  | SELECT_PROCESSOR => 0
  | SETUP_CREDS => 1
  | SETUP_WEBHOOK_PROCESSOR => 2
  | REPLACE_API_KEYS => 3
  | SETUP_WEBHOOK_USER => 4
  // | TEST_LIVE_PAYMENT => 5
  | SETUP_COMPLETED => 5
  | _ => 0
  }
}

let sidebarTextFromVariant = pageView => {
  open ProdOnboardingTypes
  switch pageView {
  | SELECT_PROCESSOR => "Select a Processor"
  | SETUP_CREDS => "Setup Credentials"
  | SETUP_WEBHOOK_PROCESSOR => "Configure Processor Webhooks"
  | REPLACE_API_KEYS => "Replace API keys & Live Endpoints"
  | SETUP_WEBHOOK_USER => "Configure Hyperswitch Webhooks"
  // | TEST_LIVE_PAYMENT => "Test a live Payment"
  | SETUP_COMPLETED => "Setup Completed"
  | _ => ""
  }
}

let getCheckboxText = connectorName => {
  open ConnectorTypes
  switch connectorName {
  | STRIPE | CHECKOUT =>
    `I have enabled raw cards on ${connectorName
      ->ConnectorUtils.getConnectorNameString
      ->LogicUtils.capitalizeString}`
  | BLUESNAP => `I have uploaded PCI DSS Certificate`
  | ADYEN => "I have submitted Hyperswitch's PCI Certificates to Adyen"
  | _ => ""
  }
}

let highlightedText = "text-base font-normal text-blue-700 underline"
let subTextStyle = "text-base font-normal text-grey-700 opacity-50"
let getWarningBlockForConnector = connectorName => {
  open ConnectorTypes
  switch connectorName {
  | STRIPE =>
    Some(
      <span>
        <span className={`${subTextStyle} !opacity-100`}>
          {"Enable Raw Cards: Navigate to Settings > Integrations in your Stripe dashboard; click on advanced options and toggle 'Handle card information directly' or raise a support ticket"->React.string}
        </span>
        <span className="ml-2">
          <a
            href="https://support.stripe.com/contact/email?body=I+would+like+to+request+that+Stripe+enable+raw+card+data+APIs+for+my+account&question=other&subject=Request+to+enable+raw+card+data+APIs&topic=other"
            target="_blank"
            className={`${highlightedText} cursor-pointer`}>
            {`here`->React.string}
          </a>
        </span>
      </span>,
    )
  | ADYEN =>
    Some(<>
      <p className=highlightedText> {"Download"->React.string} </p>
      <p className={`${subTextStyle} !opacity-100`}>
        {`and submit our PCI Certificates to Adyen's support team to enable raw cards`->React.string}
      </p>
    </>)
  | CHECKOUT =>
    Some(<>
      <p className={`${subTextStyle} !opacity-100`}>
        {`Enable Raw Cards: To enable full card processing on your account, drop an email to`->React.string}
      </p>
      <p className=highlightedText> {`support@checkout.com`->React.string} </p>
    </>)
  | BLUESNAP =>
    Some(<>
      <p className=highlightedText> {"Download"->React.string} </p>
      <p className={`${subTextStyle} !opacity-100`}>
        {`and upload the PCI DSS Certificates`->React.string}
      </p>
      <a
        href="https://www.securitymetrics.com/pcidss/bluesnap"
        target="_blank"
        className=highlightedText>
        {`here`->React.string}
      </a>
    </>)
  | _ => None
  }
}

let getProdApiBody = (
  ~parentVariant: ProdOnboardingTypes.sectionHeadingVariant,
  ~connectorId="",
  ~_paymentId: string="",
  (),
) => {
  switch parentVariant {
  | #SetupProcessor =>
    [
      (
        (parentVariant :> string),
        [("connector_id", connectorId->Js.Json.string)]->Dict.fromArray->Js.Json.object_,
      ),
    ]
    ->Dict.fromArray
    ->Js.Json.object_

  | #ProductionAgreement =>
    [
      (
        (parentVariant :> string),
        [("version", HSwitchGlobalVars.agreementVersion->Js.Json.string)]
        ->Dict.fromArray
        ->Js.Json.object_,
      ),
    ]
    ->Dict.fromArray
    ->Js.Json.object_
  | _ => (parentVariant :> string)->Js.Json.string
  }
}

let getProdOnboardingUrl = (enum: ProdOnboardingTypes.sectionHeadingVariant) => {
  open APIUtils
  `${getURL(~entityName=USERS, ~userType=#USER_DATA, ~methodType=Get, ())}?keys=${(enum :> string)}`
}

let getPreviewState = headerVariant => {
  open ProdOnboardingTypes
  switch headerVariant {
  | #SetupProcessor => SELECT_PROCESSOR_PREVIEW
  | #ConfigureEndpoint => LIVE_ENDPOINTS_PREVIEW
  | #SetupComplete => COMPLETE_SETUP_PREVIEW
  | _ => SELECT_PROCESSOR_PREVIEW
  }
}
