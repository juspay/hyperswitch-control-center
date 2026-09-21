open OffersFormUtils

let textField = (~name, ~label, ~placeholder, ~isRequired=false) =>
  FormRenderer.makeFieldInfo(
    ~label,
    ~name,
    ~placeholder,
    ~customInput=InputFields.textInput(~customStyle="rounded-xl"),
    ~isRequired,
  )

let descriptionField = FormRenderer.makeFieldInfo(
  ~label="Offer Description",
  ~name="description",
  ~placeholder="Eg. Get 5% discount upto Rs.200 for transaction of Rs.1000 and above",
  ~customInput=InputFields.multiLineTextInput(~isDisabled=false, ~rows=Some(4), ~cols=None),
)

let selectField = (~name, ~label, ~options, ~buttonText, ~isRequired=false) =>
  FormRenderer.makeFieldInfo(
    ~label,
    ~name,
    ~customInput=InputFields.selectInput(
      ~options,
      ~buttonText,
      ~fullLength=true,
      ~deselectDisable=true,
      ~searchable=true,
    ),
    ~isRequired,
  )

let amountField = (~name, ~label, ~placeholder, ~isRequired=false) =>
  FormRenderer.makeFieldInfo(
    ~label,
    ~name,
    ~placeholder,
    ~customInput=InputFields.numericTextInput(~precision=2),
    ~isRequired,
  )

let countField = (~name, ~label, ~placeholder) =>
  FormRenderer.makeFieldInfo(
    ~label,
    ~name,
    ~placeholder,
    ~customInput=InputFields.numericTextInput(~precision=0),
  )

let offerCodeField = textField(
  ~name="offer_code",
  ~label="Offer Code",
  ~placeholder="Eg. PAYTM50, ICICI10, SWIGGYIT",
  ~isRequired=true,
)

let titleField = textField(
  ~name="title",
  ~label="Offer Title",
  ~placeholder="Eg. Get 4% cashback, Get 10x rewards",
  ~isRequired=true,
)

let displayTitleField = textField(
  ~name="display_title",
  ~label="Offer Display Title",
  ~placeholder="Eg. Get 5% cashback, 10x rewards",
)

let logoField = selectField(
  ~name="sponsored_by",
  ~label="Logo for Offer",
  ~options=OffersSponsors.sponsorOptions,
  ~buttonText="Choose Logo. Eg: Merchant",
  ~isRequired=true,
)

let languageField = selectField(
  ~name="language",
  ~label="Language",
  ~options=languageOptions,
  ~buttonText="Select Language",
  ~isRequired=true,
)

let validityField = FormRenderer.makeMultiInputFieldInfo(
  ~label="Offer Validity",
  ~comboCustomInput=InputFields.dateRangeField(
    ~startKey="start_time",
    ~endKey="end_time",
    ~format="YYYY-MM-DDTHH:mm:ss[Z]",
    ~disablePastDates=true,
    ~numMonths=2,
    ~isTooltipVisible=false,
  ),
  ~inputFields=[],
  ~isRequired=true,
)

let calculationRuleField = selectField(
  ~name="calculation_rule",
  ~label="Discount Type",
  ~options=calculationRuleOptions,
  ~buttonText="Select Discount Type",
  ~isRequired=true,
)

let benefitValueField = amountField(
  ~name="benefit_value",
  ~label="Discount Value",
  ~placeholder="Eg. 10",
  ~isRequired=true,
)

let maxAmountField = amountField(
  ~name="max_amount",
  ~label="Maximum Discount Amount",
  ~placeholder="Eg. 200 - Maximum discount given per transaction",
)

let campaignAmountField = amountField(
  ~name="campaign_amount",
  ~label="Offer Campaign Amount",
  ~placeholder="Eg. 10000 - Maximum budget is capped for this offer",
)

let campaignCountField = countField(
  ~name="campaign_count",
  ~label="Offer Campaign Count",
  ~placeholder="Eg. 1000 - Maximum number of times the offer can be availed",
)

let currencyField = selectField(
  ~name="currency",
  ~label="Currency",
  ~options=currencyOptions,
  ~buttonText="Choose Currency",
  ~isRequired=true,
)

let minOrderAmountField = amountField(
  ~name="min_order_amount",
  ~label="Minimum Transaction Amount",
  ~placeholder="Eg. 1000 - Minimum cart value to make the offer eligible",
  ~isRequired=true,
)

let maxOrderAmountField = amountField(
  ~name="max_order_amount",
  ~label="Maximum Transaction Amount",
  ~placeholder="Eg. 10000 - Maximum cart value for the offer to be eligible",
)

let amountPerCardField = amountField(
  ~name="amount_per_card",
  ~label="Amount Per Unique Card",
  ~placeholder="Eg. 500 - Maximum discount amount per unique card",
)

let countPerCardField = countField(
  ~name="count_per_card",
  ~label="Offer Count Per Unique Card",
  ~placeholder="Eg. 2 - Maximum times a unique card can avail the offer",
)
