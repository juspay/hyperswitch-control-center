open PaymentMethodBlockingTypes

let getFieldName = (paymentMethod: paymentMethod, key) => {
  let prefix = switch paymentMethod {
  | #Card => "payment_method_blocking.card"
  | #ApplePay => "payment_method_blocking.wallet.apple_pay"
  | #GooglePay => "payment_method_blocking.wallet.google_pay"
  }
  `${prefix}.${key}`
}

let getToggleField = (~paymentMethod, ~field: toggleField) =>
  FormRenderer.makeFieldInfo(
    ~label=field.label,
    ~name=paymentMethod->getFieldName(field.key),
    ~description=field.description,
    ~customInput=InputFields.switchInput(
      ~isDisabled=false,
      ~boolCustomClass="rounded-lg",
      ~toggleBorder="border-nd_primary_blue-450",
      ~toggleEnableColor="bg-nd_primary_blue-450",
    ),
  )

let getSelectFields = (~paymentMethod, ~wasmOptions) => {
  let multiSelectField = (~key, ~label, ~buttonText, ~options) =>
    FormRenderer.makeFieldInfo(
      ~label,
      ~name=paymentMethod->getFieldName(key),
      ~customInput=InputFields.multiSelectInput(
        ~options,
        ~buttonText,
        ~showSelectionAsChips=false,
        ~customButtonStyle="!rounded-lg",
        ~fixedDropDownDirection=BottomRight,
        ~searchable=true,
      ),
    )

  [
    multiSelectField(
      ~key="issuing_country",
      ~label="Issuing Country",
      ~buttonText="Select Countries",
      ~options=wasmOptions.issuingCountry,
    ),
    multiSelectField(
      ~key="card_types",
      ~label="Card Types",
      ~buttonText="Select Card Types",
      ~options=wasmOptions.cardTypes,
    ),
    multiSelectField(
      ~key="card_networks",
      ~label="Card Networks",
      ~buttonText="Select Card Networks",
      ~options=wasmOptions.cardNetworks,
    ),
    multiSelectField(
      ~key="funding_sources",
      ~label="Funding Sources",
      ~buttonText="Select Funding Sources",
      ~options=wasmOptions.fundingSources,
    ),
    multiSelectField(
      ~key="card_segment_types",
      ~label="Card Segment Types",
      ~buttonText="Select Segment Types",
      ~options=wasmOptions.cardSegmentTypes,
    ),
    multiSelectField(
      ~key="card_subtypes",
      ~label="Card Subtypes",
      ~buttonText="Select Card Subtypes",
      ~options=wasmOptions.cardSubtypes,
    ),
  ]
}

let toggleFields = [
  {
    key: "block_virtual_cards",
    label: "Block virtual cards",
    description: "Blocks cards the BIN record identifies as virtual.",
  },
  {
    key: "block_non_reloadable_prepaid_cards",
    label: "Block non-reloadable prepaid cards",
    description: "Blocks prepaid cards that cannot be topped up.",
  },
  {
    key: "gambling_blocked",
    label: "Block gambling BINs",
    description: "Blocks BINs flagged for gambling.",
  },
  {
    key: "block_if_bin_info_unavailable",
    label: "Block if BIN info unavailable",
    description: "Blocks the payment when no details are available for the card's BIN. Off by default, so unrecognised BINs are allowed through.",
  },
]
