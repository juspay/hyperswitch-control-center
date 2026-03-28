open ReconEngineSelfServeTypes
open ReconEngineSelfServeUtils

let defaultMetadataField: metadataFieldFormState = {
  identifier: "",
  fieldName: "",
  fieldType: "string",
  required: true,
  description: "",
}

let defaultTransformationForm: transformationFormState = {
  name: "",
  accountId: "",
  ingestionId: "",
  processingMode: Transaction,
  currencyIdentifier: "",
  amountIdentifier: "",
  amountUnitType: MajorUnit,
  amountDelimiter: Dot,
  effectiveAtIdentifier: "",
  dateOrder: YearMonthDay,
  dateDelimiter: Hyphen,
  balanceDirectionIdentifier: "",
  creditValues: [],
  debitValues: [],
  orderIdIdentifier: "",
  metadataFields: [],
  uniqueConstraintField: "",
  uniqueConstraintDescription: "",
}

module MetadataFieldRow = {
  @react.component
  let make = (
    ~field: metadataFieldFormState,
    ~index: int,
    ~onUpdate: (int, metadataFieldFormState) => unit,
    ~onRemove: int => unit,
  ) => {
    let setFieldType = (fn: string => string) => {
      let newVal = fn(field.fieldType)
      onUpdate(index, {...field, fieldType: newVal})
    }
    <div className="flex flex-col gap-3 p-4 rounded-lg border border-nd_gray-200 bg-nd_gray-50">
      <div className="flex items-center justify-between">
        <span className="text-xs font-semibold text-nd_gray-500">
          {`Field ${(index + 1)->Int.toString}`->React.string}
        </span>
        <Button
          text="Remove"
          buttonType=Secondary
          buttonSize=XSmall
          onClick={_ => onRemove(index)}
          customButtonStyle="!text-red-400 !border-0"
        />
      </div>
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
        <div className="flex flex-col gap-1">
          <label
            htmlFor={`metadataIdentifier_${index->Int.toString}`}
            className="text-xs font-medium text-nd_gray-600">
            {"CSV Column Name"->React.string}
          </label>
          <input
            id={`metadataIdentifier_${index->Int.toString}`}
            type_="text"
            className=innerInputClassName
            placeholder="e.g., Date, MerchantID, Settle Amount"
            value={field.identifier}
            onChange={e => {
              let v = ReactEvent.Form.target(e)["value"]
              onUpdate(index, {...field, identifier: v})
            }}
          />
        </div>
        <div className="flex flex-col gap-1">
          <label
            htmlFor={`metadataFieldKey_${index->Int.toString}`}
            className="text-xs font-medium text-nd_gray-600">
            {"Field Key"->React.string}
          </label>
          <div className="flex items-center">
            <span
              className="px-2 py-1.5 text-sm text-nd_gray-400 bg-nd_gray-100 border border-r-0 border-nd_gray-200 rounded-l-md">
              {"metadata."->React.string}
            </span>
            <input
              id={`metadataFieldKey_${index->Int.toString}`}
              type_="text"
              className="flex-1 px-2.5 py-1.5 text-sm border border-nd_gray-200 rounded-r-md focus:outline-none focus:border-blue-400 focus:ring-1 focus:ring-blue-400 placeholder:text-nd_gray-300"
              placeholder="e.g., date, merchant_id"
              value={field.fieldName->String.replace("metadata.", "")}
              onChange={e => {
                let v = ReactEvent.Form.target(e)["value"]
                let sanitized = v->String.replaceRegExp(%re("/[^a-zA-Z0-9_]/g"), "")
                onUpdate(index, {...field, fieldName: `metadata.${sanitized}`})
              }}
            />
          </div>
        </div>
      </div>
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
        <div className="flex flex-col gap-1">
          <label className="text-xs font-medium text-nd_gray-600">
            {"Field Type"->React.string}
          </label>
          <SelectBox
            input={makeControlledSelectInput(
              ~name=`metadataFieldType_${index->Int.toString}`,
              ~value=field.fieldType,
              ~setValue=setFieldType,
            )}
            options={metadataFieldTypeOptions}
            deselectDisable=true
            showClearAll=false
          />
        </div>
        <div className="flex flex-col gap-1">
          <label
            htmlFor={`metadataDescription_${index->Int.toString}`}
            className="text-xs font-medium text-nd_gray-600">
            {"Description"->React.string}
          </label>
          <input
            id={`metadataDescription_${index->Int.toString}`}
            type_="text"
            className=innerInputClassName
            placeholder="Brief description of this field"
            value={field.description}
            onChange={e => {
              let v = ReactEvent.Form.target(e)["value"]
              onUpdate(index, {...field, description: v})
            }}
          />
        </div>
      </div>
    </div>
  }
}

@react.component
let make = (
  ~wizardState: wizardState,
  ~onTransformationCreated: createdTransformation => unit,
  ~onNext: unit => unit,
  ~onBack: unit => unit,
) => {
  let createTransformation = ReconEngineSelfServeHooks.useCreateTransformationConfig()
  let {merchantId} =
    CommonAuthHooks.useCommonAuthInfo()->Option.getOr(CommonAuthHooks.defaultAuthInfo)
  let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()

  let (form, setForm) = React.useState(_ => defaultTransformationForm)
  let (isSubmitting, setIsSubmitting) = React.useState(_ => false)
  let (showAdvanced, setShowAdvanced) = React.useState(_ => false)
  let (creditValueInput, setCreditValueInput) = React.useState(_ => "")
  let (debitValueInput, setDebitValueInput) = React.useState(_ => "")

  // Setter wrappers for SelectBox controlled inputs
  let setAccountId = (fn: string => string) =>
    setForm(prev => {...prev, accountId: fn(prev.accountId)})
  let setIngestionId = (fn: string => string) =>
    setForm(prev => {...prev, ingestionId: fn(prev.ingestionId)})
  let setProcessingMode = (fn: string => string) =>
    setForm(prev => {
      let newStr = fn(prev.processingMode->processingModeToString)
      {...prev, processingMode: newStr->stringToProcessingMode}
    })
  let setAmountUnitType = (fn: string => string) =>
    setForm(prev => {
      let newStr = fn(prev.amountUnitType->unitTypeToString)
      {...prev, amountUnitType: newStr->stringToUnitType}
    })
  let setAmountDelimiter = (fn: string => string) =>
    setForm(prev => {
      let newStr = fn(prev.amountDelimiter->delimiterToString)
      {...prev, amountDelimiter: newStr->stringToDelimiter}
    })
  let setDateOrder = (fn: string => string) =>
    setForm(prev => {
      let newStr = fn(prev.dateOrder->dateOrderToString)
      {...prev, dateOrder: newStr->stringToDateOrder}
    })
  let setDateDelimiter = (fn: string => string) =>
    setForm(prev => {
      let newStr = fn(prev.dateDelimiter->delimiterToString)
      {...prev, dateDelimiter: newStr->stringToDelimiter}
    })
  let setUniqueConstraintField = (fn: string => string) =>
    setForm(prev => {...prev, uniqueConstraintField: fn(prev.uniqueConstraintField)})

  let accountOptions: array<SelectBox.dropdownOption> = wizardState.accounts->Array.map(account => {
    {
      SelectBox.label: `${account.account_name} (${account.account_type})`,
      value: account.account_id,
    }
  })

  let ingestionOptionsForAccount =
    wizardState.ingestions
    ->Array.filter(ing => ing.account_id === form.accountId)
    ->Array.map(ing => {
      {SelectBox.label: ing.name, value: ing.ingestion_id}
    })

  // Build unique constraint field options from metadata fields + standard fields
  let constraintFieldOptions: array<SelectBox.dropdownOption> = {
    let standardFields = [
      {SelectBox.label: "Order ID", value: "order_id"},
      {SelectBox.label: "Amount", value: "amount"},
      {SelectBox.label: "Effective At", value: "effective_at"},
    ]
    let metaFields = form.metadataFields->Array.map(f => {
      {SelectBox.label: f.identifier, value: f.fieldName}
    })
    standardFields->Array.concat(metaFields)
  }

  let addMetadataField = () => {
    setForm(prev => {
      ...prev,
      metadataFields: prev.metadataFields->Array.concat([defaultMetadataField]),
    })
  }

  let updateMetadataField = (index, field) => {
    setForm(prev => {
      let updated = prev.metadataFields->Array.mapWithIndex((f, i) => i === index ? field : f)
      {...prev, metadataFields: updated}
    })
  }

  let removeMetadataField = index => {
    setForm(prev => {
      let updated = prev.metadataFields->Array.filterWithIndex((_, i) => i !== index)
      {...prev, metadataFields: updated}
    })
  }

  let addCreditValue = () => {
    if creditValueInput->String.trim->String.length > 0 {
      setForm(prev => {
        ...prev,
        creditValues: prev.creditValues->Array.concat([creditValueInput->String.trim]),
      })
      setCreditValueInput(_ => "")
    }
  }

  let addDebitValue = () => {
    if debitValueInput->String.trim->String.length > 0 {
      setForm(prev => {
        ...prev,
        debitValues: prev.debitValues->Array.concat([debitValueInput->String.trim]),
      })
      setDebitValueInput(_ => "")
    }
  }

  let handleSubmit = async () => {
    setIsSubmitting(_ => true)
    let result = await createTransformation(~form, ~merchantId, ~profileId)
    switch result {
    | Some(transformation) => {
        onTransformationCreated(transformation)
        setForm(_ => defaultTransformationForm)
      }
    | None => ()
    }
    setIsSubmitting(_ => false)
  }

  let allAccountsCoveredByTransformation =
    wizardState.accounts->Array.every(account =>
      wizardState.transformations->Array.some(t => t.account_id === account.account_id)
    )

  <div className="flex flex-col gap-10 max-w-3xl">
    // Context from previous steps
    <RenderIf condition={wizardState.accounts->Array.length > 0}>
      <div
        className="flex flex-col gap-1 px-3 py-2 bg-nd_gray-50 rounded-lg text-xs text-nd_gray-500 ml-4 sm:ml-10 mb-2">
        <div className="flex items-center gap-2">
          <Icon name="nd-check" customHeight="10" className="text-green-500" />
          {`Accounts: ${wizardState.accounts
            ->Array.map(a => `${a.account_name} (${a.account_type})`)
            ->Array.joinWith(", ")}`->React.string}
        </div>
        <div className="flex items-center gap-2">
          <Icon name="nd-check" customHeight="10" className="text-green-500" />
          {`Data sources: ${wizardState.ingestions
            ->Array.map(i => i.name)
            ->Array.joinWith(", ")}`->React.string}
        </div>
      </div>
    </RenderIf>
    // Header
    <div className="flex flex-col gap-2">
      <div className="flex items-center gap-2">
        <div
          className="w-8 h-8 rounded-full bg-blue-50 flex items-center justify-center text-sm font-semibold text-blue-600">
          {"3"->React.string}
        </div>
        <h2 className="text-lg font-semibold text-nd_gray-800">
          {"Map Your CSV Columns"->React.string}
        </h2>
      </div>
      <p className="text-sm text-nd_gray-500 leading-relaxed ml-4 sm:ml-10">
        {"Map your CSV columns to the recon engine's standard fields. This tells the engine where to find amounts, dates, order IDs, and additional metadata in your files."->React.string}
      </p>
    </div>
    // How it works
    <div className="ml-4 sm:ml-10 p-4 bg-blue-50 rounded-lg border border-blue-100">
      <div className="flex items-start gap-3">
        <Icon name="nd-overview" className="text-blue-500 mt-0.5" customHeight="16" />
        <div className="flex flex-col gap-1">
          <p className="text-sm font-medium text-blue-700"> {"How it works"->React.string} </p>
          <p className="text-xs text-blue-600 leading-relaxed">
            {"Your CSV has column headers like \"Settle Amount\" or \"Value Date\". You tell the engine which column maps to which standard field (amount, date, etc.). Additional columns become metadata fields that can be used in recon rules."->React.string}
          </p>
        </div>
      </div>
    </div>
    // Form - Section 1: Basic Info
    <div
      className="ml-4 sm:ml-10 flex flex-col gap-5 p-6 rounded-xl border border-nd_gray-200 bg-white">
      <div className="flex items-center gap-2 text-sm font-semibold text-nd_gray-700">
        <span
          className="w-7 h-7 rounded-full bg-blue-50 flex items-center justify-center text-xs font-semibold text-blue-600">
          {"1"->React.string}
        </span>
        {"Basic Information"->React.string}
      </div>
      <div className="flex flex-col gap-4">
        <div className="flex flex-col gap-1.5">
          <label htmlFor="transformationName" className="text-sm font-medium text-nd_gray-700">
            {"Transformation Name"->React.string}
          </label>
          <input
            id="transformationName"
            type_="text"
            className=inputClassName
            placeholder="e.g., PSP Payments, Bank Statements"
            value={form.name}
            onChange={e => setForm(prev => {...prev, name: ReactEvent.Form.target(e)["value"]})}
          />
        </div>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div className="flex flex-col gap-1.5">
            <label className="text-sm font-medium text-nd_gray-700">
              {"Account"->React.string}
            </label>
            <SelectBox
              input={makeControlledSelectInput(
                ~name="transformAccountId",
                ~value=form.accountId,
                ~setValue=setAccountId,
              )}
              options={accountOptions}
              deselectDisable=true
              showClearAll=false
            />
          </div>
          <div className="flex flex-col gap-1.5">
            <label className="text-sm font-medium text-nd_gray-700">
              {"Ingestion Source"->React.string}
            </label>
            <SelectBox
              input={makeControlledSelectInput(
                ~name="transformIngestionId",
                ~value=form.ingestionId,
                ~setValue=setIngestionId,
              )}
              options={ingestionOptionsForAccount}
              deselectDisable=true
              showClearAll=false
            />
          </div>
        </div>
        <div className="flex flex-col gap-1.5">
          <label className="text-sm font-medium text-nd_gray-700">
            {"Processing Mode"->React.string}
          </label>
          <p className="text-xs text-nd_gray-400">
            {"\"Transaction\" creates expected entries waiting for confirmation. \"Confirmation\" matches against existing expected entries."->React.string}
          </p>
          <SelectBox
            input={makeControlledSelectInput(
              ~name="processingMode",
              ~value=form.processingMode->processingModeToString,
              ~setValue=setProcessingMode,
            )}
            options={processingModeOptions}
            deselectDisable=true
            showClearAll=false
          />
        </div>
      </div>
    </div>
    // Section 2: Core Field Mappings
    <div
      className="ml-4 sm:ml-10 flex flex-col gap-5 p-6 rounded-xl border border-nd_gray-200 bg-white">
      <div className="flex items-center gap-2 text-sm font-semibold text-nd_gray-700">
        <span
          className="w-7 h-7 rounded-full bg-blue-50 flex items-center justify-center text-xs font-semibold text-blue-600">
          {"2"->React.string}
        </span>
        {"Core Field Mappings"->React.string}
      </div>
      <p className="text-xs text-nd_gray-400">
        {"Map your CSV column headers to the engine's required fields. The \"identifier\" is the exact column header name in your CSV file."->React.string}
      </p>
      // Currency
      <div className="flex flex-col gap-1.5 p-3 bg-nd_gray-50 rounded-lg">
        <label htmlFor="currencyColumn" className="text-sm font-medium text-nd_gray-700">
          {"Currency Column"->React.string}
        </label>
        <input
          id="currencyColumn"
          type_="text"
          className=innerInputClassName
          placeholder="e.g., Transaction Currency, Currency Code"
          value={form.currencyIdentifier}
          onChange={e =>
            setForm(prev => {...prev, currencyIdentifier: ReactEvent.Form.target(e)["value"]})}
        />
      </div>
      // Amount
      <div className="flex flex-col gap-3 p-3 bg-nd_gray-50 rounded-lg">
        <label htmlFor="amountColumn" className="text-sm font-medium text-nd_gray-700">
          {"Amount Column"->React.string}
        </label>
        <input
          id="amountColumn"
          type_="text"
          className=innerInputClassName
          placeholder="e.g., Settle Amount, Credit"
          value={form.amountIdentifier}
          onChange={e =>
            setForm(prev => {...prev, amountIdentifier: ReactEvent.Form.target(e)["value"]})}
        />
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
          <div className="flex flex-col gap-1">
            <label className="text-xs font-medium text-nd_gray-600">
              {"Unit Type"->React.string}
            </label>
            <SelectBox
              input={makeControlledSelectInput(
                ~name="amountUnitType",
                ~value=form.amountUnitType->unitTypeToString,
                ~setValue=setAmountUnitType,
              )}
              options={unitTypeOptions}
              deselectDisable=true
              showClearAll=false
            />
          </div>
          <RenderIf condition={form.amountUnitType === MajorUnit}>
            <div className="flex flex-col gap-1">
              <label className="text-xs font-medium text-nd_gray-600">
                {"Decimal Separator"->React.string}
              </label>
              <SelectBox
                input={makeControlledSelectInput(
                  ~name="amountDelimiter",
                  ~value=form.amountDelimiter->delimiterToString,
                  ~setValue=setAmountDelimiter,
                )}
                options={delimiterOptions}
                deselectDisable=true
                showClearAll=false
              />
            </div>
          </RenderIf>
        </div>
      </div>
      // Date
      <div className="flex flex-col gap-3 p-3 bg-nd_gray-50 rounded-lg">
        <label htmlFor="dateColumn" className="text-sm font-medium text-nd_gray-700">
          {"Date Column"->React.string}
        </label>
        <input
          id="dateColumn"
          type_="text"
          className=innerInputClassName
          placeholder="e.g., Date, Value Date"
          value={form.effectiveAtIdentifier}
          onChange={e =>
            setForm(prev => {...prev, effectiveAtIdentifier: ReactEvent.Form.target(e)["value"]})}
        />
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
          <div className="flex flex-col gap-1">
            <label className="text-xs font-medium text-nd_gray-600">
              {"Date Order"->React.string}
            </label>
            <SelectBox
              input={makeControlledSelectInput(
                ~name="dateOrder",
                ~value=form.dateOrder->dateOrderToString,
                ~setValue=setDateOrder,
              )}
              options={dateOrderOptions}
              deselectDisable=true
              showClearAll=false
            />
          </div>
          <div className="flex flex-col gap-1">
            <label className="text-xs font-medium text-nd_gray-600">
              {"Date Separator"->React.string}
            </label>
            <SelectBox
              input={makeControlledSelectInput(
                ~name="dateDelimiter",
                ~value=form.dateDelimiter->delimiterToString,
                ~setValue=setDateDelimiter,
              )}
              options={delimiterOptions}
              deselectDisable=true
              showClearAll=false
            />
          </div>
        </div>
      </div>
      // Order ID
      <div className="flex flex-col gap-1.5 p-3 bg-nd_gray-50 rounded-lg">
        <label htmlFor="orderIdColumn" className="text-sm font-medium text-nd_gray-700">
          {"Order ID Column"->React.string}
        </label>
        <input
          id="orderIdColumn"
          type_="text"
          className=innerInputClassName
          placeholder="e.g., Merchant Ref ID, Transaction Reference"
          value={form.orderIdIdentifier}
          onChange={e =>
            setForm(prev => {...prev, orderIdIdentifier: ReactEvent.Form.target(e)["value"]})}
        />
      </div>
      // Balance Direction
      <div className="flex flex-col gap-3 p-3 bg-nd_gray-50 rounded-lg">
        <label htmlFor="balanceDirectionColumn" className="text-sm font-medium text-nd_gray-700">
          {"Credit/Debit Indicator"->React.string}
        </label>
        <p className="text-xs text-nd_gray-400">
          {"Which column in your CSV indicates if a row is a credit or debit? List the values from that column that mean credit vs debit."->React.string}
        </p>
        <input
          id="balanceDirectionColumn"
          type_="text"
          className=innerInputClassName
          placeholder="e.g., Transaction Currency, Account Type"
          value={form.balanceDirectionIdentifier}
          onChange={e =>
            setForm(prev => {
              ...prev,
              balanceDirectionIdentifier: ReactEvent.Form.target(e)["value"],
            })}
        />
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
          <div className="flex flex-col gap-1.5">
            <label htmlFor="creditValueInput" className="text-xs font-medium text-nd_gray-600">
              {"Credit Values"->React.string}
            </label>
            <div className="flex gap-1.5">
              <input
                id="creditValueInput"
                type_="text"
                className={`flex-1 ${innerInputClassName}`}
                placeholder="e.g., CR, credit, incoming"
                value={creditValueInput}
                onChange={e => setCreditValueInput(_ => ReactEvent.Form.target(e)["value"])}
                onKeyDown={e =>
                  if ReactEvent.Keyboard.key(e) === "Enter" {
                    ReactEvent.Keyboard.preventDefault(e)
                    addCreditValue()
                  }}
              />
              <Button
                text="+"
                buttonType=Secondary
                buttonSize=XSmall
                onClick={_ => addCreditValue()}
                customButtonStyle="!bg-blue-50 !text-blue-600"
              />
            </div>
            <div className="flex flex-wrap gap-1">
              {form.creditValues
              ->Array.mapWithIndex((v, i) =>
                <span
                  key={i->Int.toString}
                  className="text-xs px-2 py-0.5 bg-blue-50 text-blue-600 rounded-full">
                  {v->React.string}
                </span>
              )
              ->React.array}
            </div>
          </div>
          <div className="flex flex-col gap-1.5">
            <label htmlFor="debitValueInput" className="text-xs font-medium text-nd_gray-600">
              {"Debit Values"->React.string}
            </label>
            <div className="flex gap-1.5">
              <input
                id="debitValueInput"
                type_="text"
                className={`flex-1 ${innerInputClassName}`}
                placeholder="e.g., DR, debit, outgoing"
                value={debitValueInput}
                onChange={e => setDebitValueInput(_ => ReactEvent.Form.target(e)["value"])}
                onKeyDown={e =>
                  if ReactEvent.Keyboard.key(e) === "Enter" {
                    ReactEvent.Keyboard.preventDefault(e)
                    addDebitValue()
                  }}
              />
              <Button
                text="+"
                buttonType=Secondary
                buttonSize=XSmall
                onClick={_ => addDebitValue()}
                customButtonStyle="!bg-green-50 !text-green-600"
              />
            </div>
            <div className="flex flex-wrap gap-1">
              {form.debitValues
              ->Array.mapWithIndex((v, i) =>
                <span
                  key={i->Int.toString}
                  className="text-xs px-2 py-0.5 bg-green-50 text-green-600 rounded-full">
                  {v->React.string}
                </span>
              )
              ->React.array}
            </div>
          </div>
        </div>
      </div>
    </div>
    // Section 3: Metadata Fields
    <div
      className="ml-4 sm:ml-10 flex flex-col gap-5 p-6 rounded-xl border border-nd_gray-200 bg-white">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2 text-sm font-semibold text-nd_gray-700">
          <span
            className="w-7 h-7 rounded-full bg-blue-50 flex items-center justify-center text-xs font-semibold text-blue-600">
            {"3"->React.string}
          </span>
          {"Metadata Fields"->React.string}
        </div>
        <Button
          text="+ Add Field"
          buttonType=Secondary
          buttonSize=XSmall
          onClick={_ => addMetadataField()}
          customButtonStyle="!text-blue-600 !border-0"
        />
      </div>
      <p className="text-xs text-nd_gray-400">
        {"Map additional CSV columns that aren't core fields. These become metadata fields you can reference in recon rules. The internal field name should follow the pattern \"metadata.field_name\"."->React.string}
      </p>
      <RenderIf condition={form.metadataFields->Array.length === 0}>
        <div className="flex flex-col items-center gap-2 py-6 text-center">
          <p className="text-sm text-nd_gray-400">
            {"No metadata fields added yet."->React.string}
          </p>
          <Button
            text="+ Add Field to map additional CSV columns"
            buttonType=Secondary
            buttonSize=XSmall
            onClick={_ => addMetadataField()}
            customButtonStyle="!text-blue-600 !border-0"
          />
        </div>
      </RenderIf>
      {form.metadataFields
      ->Array.mapWithIndex((field, idx) =>
        <MetadataFieldRow
          key={idx->Int.toString}
          field
          index=idx
          onUpdate=updateMetadataField
          onRemove=removeMetadataField
        />
      )
      ->React.array}
    </div>
    // Section 4: Unique Constraint (collapsible advanced)
    <div
      className="ml-4 sm:ml-10 flex flex-col gap-3 p-6 rounded-xl border border-nd_gray-200 bg-white">
      <div
        className="flex items-center justify-between w-full cursor-pointer"
        ariaExpanded={showAdvanced}
        onClick={_ => setShowAdvanced(prev => !prev)}>
        <div className="flex items-center gap-2 text-sm font-semibold text-nd_gray-700">
          <span
            className="w-7 h-7 rounded-full bg-blue-50 flex items-center justify-center text-xs font-semibold text-blue-600">
            {"4"->React.string}
          </span>
          {"Uniqueness Constraint"->React.string}
        </div>
        <Icon
          name={showAdvanced ? "nd-angle-up" : "nd-angle-down"}
          className="text-nd_gray-400"
          customHeight="14"
        />
      </div>
      <RenderIf condition={showAdvanced}>
        <p className="text-xs text-nd_gray-400">
          {"Define which field must be unique across entries. This prevents duplicate processing."->React.string}
        </p>
        <div className="flex flex-col gap-3">
          <div className="flex flex-col gap-1.5">
            <label className="text-xs font-medium text-nd_gray-600">
              {"Unique Field"->React.string}
            </label>
            <SelectBox
              input={makeControlledSelectInput(
                ~name="uniqueConstraintField",
                ~value=form.uniqueConstraintField,
                ~setValue=setUniqueConstraintField,
              )}
              options={constraintFieldOptions}
              deselectDisable=true
              showClearAll=false
            />
          </div>
          <div className="flex flex-col gap-1.5">
            <label
              htmlFor="uniqueConstraintDescription"
              className="text-xs font-medium text-nd_gray-600">
              {"Description"->React.string}
            </label>
            <input
              id="uniqueConstraintDescription"
              type_="text"
              className=innerInputClassName
              placeholder="e.g., Merchant Ref Id must be unique across all transactions"
              value={form.uniqueConstraintDescription}
              onChange={e =>
                setForm(prev => {
                  ...prev,
                  uniqueConstraintDescription: ReactEvent.Form.target(e)["value"],
                })}
            />
          </div>
        </div>
      </RenderIf>
    </div>
    // Submit
    <div className="ml-4 sm:ml-10">
      <Button
        text="Create Transformation Config"
        buttonType=Primary
        buttonSize=Small
        onClick={_ => handleSubmit()->ignore}
        buttonState={isSubmitting ? Loading : Normal}
        customButtonStyle="w-full"
      />
    </div>
    // Created transformations list
    <RenderIf condition={wizardState.transformations->Array.length > 0}>
      <div className="ml-4 sm:ml-10 flex flex-col gap-3">
        <h3 className="text-sm font-semibold text-nd_gray-700">
          {`Created Column Mappings (${wizardState.transformations
            ->Array.length
            ->Int.toString})`->React.string}
        </h3>
        {wizardState.transformations
        ->Array.mapWithIndex((t, idx) =>
          <div
            key={idx->Int.toString}
            className="flex items-center justify-between p-3 rounded-lg border border-nd_gray-200 bg-nd_gray-50">
            <div className="flex items-center gap-3">
              <Icon name="nd-check" customHeight="14" className="text-green-500" />
              <span className="text-sm font-medium text-nd_gray-700"> {t.name->React.string} </span>
            </div>
            <span className="text-xs text-nd_gray-400 font-mono">
              {t.transformation_id->React.string}
            </span>
          </div>
        )
        ->React.array}
      </div>
    </RenderIf>
    // Navigation
    <div className="ml-4 sm:ml-10 flex gap-3">
      <Button
        text="Back"
        buttonType=Secondary
        buttonSize=Small
        onClick={_ => onBack()}
        leftIcon={CustomIcon(<Icon name="nd-arrow-left" customHeight="14" />)}
      />
      <RenderIf condition={allAccountsCoveredByTransformation}>
        <Button
          text="Continue to Rules"
          buttonType=Primary
          buttonSize=Small
          onClick={_ => onNext()}
          rightIcon={CustomIcon(<Icon name="nd-arrow-right" customHeight="14" />)}
          customButtonStyle="flex-1"
        />
      </RenderIf>
    </div>
  </div>
}
