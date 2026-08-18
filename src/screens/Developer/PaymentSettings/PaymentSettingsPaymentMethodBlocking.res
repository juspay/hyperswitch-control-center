open Typography

// Values must match the backend serde spellings exactly:
// CardType/CardSegmentType are snake_case, CardNetwork is PascalCase,
// FundingSource is UPPERCASE (two variants contain spaces).
let cardTypeOptions: array<SelectBox.dropdownOption> = [
  {value: "credit", label: "Credit"},
  {value: "debit", label: "Debit"},
]

let cardNetworkOptions: array<SelectBox.dropdownOption> = [
  {value: "Visa", label: "Visa"},
  {value: "Mastercard", label: "Mastercard"},
  {value: "AmericanExpress", label: "American Express"},
  {value: "JCB", label: "JCB"},
  {value: "DinersClub", label: "Diners Club"},
  {value: "Discover", label: "Discover"},
  {value: "CartesBancaires", label: "Cartes Bancaires"},
  {value: "UnionPay", label: "UnionPay"},
  {value: "Interac", label: "Interac"},
  {value: "RuPay", label: "RuPay"},
  {value: "Maestro", label: "Maestro"},
  {value: "Star", label: "Star"},
  {value: "Pulse", label: "Pulse"},
  {value: "Accel", label: "Accel"},
  {value: "Nyce", label: "Nyce"},
  {value: "Prop", label: "Prop"},
  {value: "PrivateLabel", label: "Private Label"},
  {value: "Dinacard", label: "Dinacard"},
]

let fundingSourceOptions: array<SelectBox.dropdownOption> = [
  {value: "CREDIT", label: "Credit"},
  {value: "DEBIT", label: "Debit"},
  {value: "DEFERRED DEBIT", label: "Deferred Debit"},
  {value: "PREPAID", label: "Prepaid"},
  {value: "CHARGE CARD", label: "Charge Card"},
]

let cardSegmentTypeOptions: array<SelectBox.dropdownOption> = [
  {value: "business", label: "Business"},
  {value: "commercial", label: "Commercial"},
  {value: "consumer", label: "Consumer"},
  {value: "government", label: "Government"},
]

let issuingCountryOptions: array<SelectBox.dropdownOption> =
  CountryUtils.countriesList->Array.map(CountryUtils.getCountryOption)

module CardBlockingConfigFields = {
  @react.component
  let make = (~namePrefix) => {
    open FormRenderer

    let multiSelectField = (~key, ~label, ~options, ~searchable) =>
      makeFieldInfo(
        ~label,
        ~name=`${namePrefix}.${key}`,
        ~customInput=InputFields.multiSelectInput(
          ~options,
          ~buttonText={`Select ${label}`},
          ~showSelectionAsChips=false,
          ~customButtonStyle="!rounded-lg",
          ~fixedDropDownDirection=BottomRight,
          ~searchable,
        ),
      )

    let toggleField = (~key, ~label, ~description) =>
      makeFieldInfo(
        ~name=`${namePrefix}.${key}`,
        ~label,
        ~customInput=InputFields.switchInput(
          ~isDisabled=false,
          ~boolCustomClass="rounded-lg",
          ~toggleBorder="border-nd_primary_blue-450",
          ~toggleEnableColor="bg-nd_primary_blue-450",
        ),
        ~description,
        ~toolTipPosition=Right,
      )

    let multiSelectFields = [
      multiSelectField(
        ~key="card_types",
        ~label="Card Types",
        ~options=cardTypeOptions,
        ~searchable=true,
      ),
      multiSelectField(
        ~key="card_networks",
        ~label="Card Networks",
        ~options=cardNetworkOptions,
        ~searchable=true,
      ),
      multiSelectField(
        ~key="funding_sources",
        ~label="Funding Sources",
        ~options=fundingSourceOptions,
        ~searchable=false,
      ),
      multiSelectField(
        ~key="card_segment_types",
        ~label="Card Segment Types",
        ~options=cardSegmentTypeOptions,
        ~searchable=false,
      ),
      multiSelectField(
        ~key="issuing_country",
        ~label="Issuing Countries",
        ~options=issuingCountryOptions,
        ~searchable=true,
      ),
    ]

    let toggleFields = [
      toggleField(
        ~key="block_if_bin_info_unavailable",
        ~label="Block If BIN Info Unavailable",
        ~description="Block the payment when card BIN information cannot be found",
      ),
      toggleField(
        ~key="block_virtual_cards",
        ~label="Block Virtual Cards",
        ~description="Block payments made with virtual cards",
      ),
      toggleField(
        ~key="block_non_reloadable_prepaid_cards",
        ~label="Block Non-Reloadable Prepaid Cards",
        ~description="Block payments made with non-reloadable prepaid cards",
      ),
      toggleField(
        ~key="gambling_blocked",
        ~label="Block Gambling-Restricted Cards",
        ~description="Block cards that are restricted from gambling usage",
      ),
    ]

    <div className="flex flex-col gap-4">
      <div className="grid grid-cols-1 md:grid-cols-2 gap-x-6 gap-y-4 max-w-4xl">
        {multiSelectFields
        ->Array.mapWithIndex((field, index) =>
          <FieldRenderer
            key={index->Int.toString} field labelClass={`!${body.md.medium} !text-nd-gray-600`}
          />
        )
        ->React.array}
      </div>
      <div className="flex flex-col max-w-4xl">
        {toggleFields
        ->Array.mapWithIndex((field, index) =>
          <FieldRenderer
            key={index->Int.toString}
            field
            labelClass={`!${body.md.medium} !text-nd-gray-600`}
            fieldWrapperClass="w-full flex justify-between items-center py-2"
          />
        )
        ->React.array}
      </div>
    </div>
  }
}

type blockingTarget = Card | ApplePay | GooglePay

let blockingTargets = [Card, ApplePay, GooglePay]

let targetLabel = target =>
  switch target {
  | Card => "Card"
  | ApplePay => "Apple Pay"
  | GooglePay => "Google Pay"
  }

let targetPrefix = target =>
  switch target {
  | Card => "payment_method_blocking.card"
  | ApplePay => "payment_method_blocking.wallet.apple_pay"
  | GooglePay => "payment_method_blocking.wallet.google_pay"
  }

@react.component
let make = () => {
  open FormRenderer
  let (activeTarget, setActiveTarget) = React.useState(_ => Card)
  let activePrefix = activeTarget->targetPrefix

  <DesktopRow itemWrapperClass="mx-1">
    <div className="w-full py-8 flex flex-col gap-6">
      <div>
        <p className={`${body.lg.semibold} text-nd_gray-700`}>
          {"Payment Method Blocking"->React.string}
        </p>
        <p className={`${body.md.medium} text-nd_gray-400 pt-2`}>
          {"Block payments by card type, network, funding source, segment type, or issuing country for card, Apple Pay, and Google Pay payment methods"->React.string}
        </p>
      </div>
      <div className="flex w-fit p-1 gap-1 rounded-lg border border-nd_gray-200 bg-nd_gray-50">
        {blockingTargets
        ->Array.map(target => {
          let isActive = target == activeTarget
          <button
            key={target->targetLabel}
            type_="button"
            className={`px-4 py-1.5 rounded-md ${body.md.medium} ${isActive
                ? "bg-white text-nd_gray-700 shadow-sm"
                : "text-nd_gray-400 hover:text-nd_gray-600"}`}
            onClick={_ => setActiveTarget(_ => target)}>
            {target->targetLabel->React.string}
          </button>
        })
        ->React.array}
      </div>
      <CardBlockingConfigFields key=activePrefix namePrefix=activePrefix />
    </div>
  </DesktopRow>
}
