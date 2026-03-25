open ReconEngineSelfServeTypes
open ReconEngineSelfServeUtils

module MetadataFieldRow = {
  @react.component
  let make = (~index, ~field: metadataFieldSchemaConfig, ~onUpdate, ~onRemove) => {
    <div className="flex items-start gap-3 p-3 border border-gray-200 rounded-lg bg-white">
      <div className="flex-1 grid grid-cols-3 gap-3">
        <div>
          <label className="block text-xs font-medium text-gray-500 mb-1">
            {"CSV Column"->React.string}
          </label>
          <input
            type_="text"
            value={field.identifier}
            onChange={e => {
              let v = ReactEvent.Form.target(e)["value"]
              onUpdate(index, {...field, identifier: v})
            }}
            placeholder="Column name in CSV"
            className="w-full px-2 py-1.5 border border-gray-300 rounded text-sm focus:outline-none focus:ring-1 focus:ring-blue-500"
          />
        </div>
        <div>
          <label className="block text-xs font-medium text-gray-500 mb-1">
            {"Field Key"->React.string}
          </label>
          <input
            type_="text"
            value={field.field_name->String.replace("metadata.", "")}
            onChange={e => {
              let v = ReactEvent.Form.target(e)["value"]
              onUpdate(index, {...field, field_name: `metadata.${v}`})
            }}
            placeholder="e.g., merchant_ref_id"
            className="w-full px-2 py-1.5 border border-gray-300 rounded text-sm focus:outline-none focus:ring-1 focus:ring-blue-500"
          />
          <p className="text-[10px] text-gray-400 mt-0.5">
            {`Will be stored as metadata.${field.field_name->String.replace("metadata.", "")}`->React.string}
          </p>
        </div>
        <div>
          <label className="block text-xs font-medium text-gray-500 mb-1">
            {"Description"->React.string}
          </label>
          <input
            type_="text"
            value={field.description}
            onChange={e => {
              let v = ReactEvent.Form.target(e)["value"]
              onUpdate(index, {...field, description: v})
            }}
            placeholder="Brief description"
            className="w-full px-2 py-1.5 border border-gray-300 rounded text-sm focus:outline-none focus:ring-1 focus:ring-blue-500"
          />
        </div>
      </div>
      <button
        type_="button"
        onClick={_ => onRemove(index)}
        className="mt-5 p-1 text-gray-400 hover:text-red-500 transition-colors">
        <span className="text-lg"> {`\u{00D7}`->React.string} </span>
      </button>
    </div>
  }
}

@react.component
let make = (
  ~state: selfServeState,
  ~merchantId,
  ~profileId,
  ~onTransformationCreated,
  ~onNext,
  ~onBack,
) => {
  let createTransformation = ReconEngineSelfServeHooks.useCreateTransformationConfig()

  // Form state for current transformation being built
  let (selectedIngestionId, setSelectedIngestionId) = React.useState(_ => "")
  let (transformationName, setTransformationName) = React.useState(_ => "")
  let (isSubmitting, setIsSubmitting) = React.useState(_ => false)

  // Required field identifiers (CSV column names)
  let (currencyColumn, setCurrencyColumn) = React.useState(_ => "")
  let (amountColumn, setAmountColumn) = React.useState(_ => "")
  let (amountUnitType, setAmountUnitType) = React.useState(_ => "major_unit")
  let (amountDelimiterVal, setAmountDelimiterVal) = React.useState(_ => "dot")
  let (effectiveAtColumn, setEffectiveAtColumn) = React.useState(_ => "")
  let (dateOrder, setDateOrder) = React.useState(_ => "year_month_day")
  let (dateDelimiter, setDateDelimiter) = React.useState(_ => "hyphen")
  let (balanceDirColumn, setBalanceDirColumn) = React.useState(_ => "")
  let (creditValues, setCreditValues) = React.useState(_ => "")
  let (debitValues, setDebitValues) = React.useState(_ => "")
  let (orderIdColumn, setOrderIdColumn) = React.useState(_ => "")

  // Processing mode
  let (processingModeVal, setProcessingModeVal) = React.useState(_ => "transaction")

  // Unique constraint
  let (uniqueField, setUniqueField) = React.useState(_ => "order_id")
  let (uniqueDescription, setUniqueDescription) = React.useState(_ => "")

  // Metadata fields
  let (metadataFields, setMetadataFields) = React.useState(_ => [])

  let ingestionsWithoutTransformation =
    state.ingestions->Array.filter(ing =>
      !(state.transformations->Array.some(t => t.ingestion_id === ing.ingestion_id))
    )

  React.useEffect(() => {
    if selectedIngestionId === "" {
      switch ingestionsWithoutTransformation->Array.get(0) {
      | Some(ing) => setSelectedIngestionId(_ => ing.ingestion_id)
      | None => ()
      }
    }
    None
  }, [ingestionsWithoutTransformation->Array.length])

  let addMetadataField = () => {
    let newField: metadataFieldSchemaConfig = {
      identifier: "",
      field_name: "metadata.",
      field_type: StringFieldType({validation_rules: [], transformation_rules: []}),
      required: true,
      description: "",
    }
    setMetadataFields(prev => Array.concat(prev, [newField]))
  }

  let updateMetadataField = (index, field) => {
    setMetadataFields(prev =>
      prev->Array.mapWithIndex((f, i) =>
        if i === index {
          field
        } else {
          f
        }
      )
    )
  }

  let removeMetadataField = index => {
    setMetadataFields(prev => prev->Array.filterWithIndex((_, i) => i !== index))
  }

  let handleSubmit = async () => {
    let selectedIngestion =
      state.ingestions->Array.find(i => i.ingestion_id === selectedIngestionId)
    switch selectedIngestion {
    | None => ()
    | Some(ingestion) => {
        setIsSubmitting(_ => true)

        let parseDateOrder = switch dateOrder {
        | "day_month_year" => DayMonthYear
        | "month_day_year" => MonthDayYear
        | "year_day_month" => YearDayMonth
        | _ => YearMonthDay
        }

        let parseDateDelimiter = switch dateDelimiter {
        | "slash" => Slash
        | "dot" => DelimiterDot
        | "space" => Space
        | "none" => DelimiterNone
        | _ => Hyphen
        }

        let parseAmountUnit = switch amountUnitType {
        | "minor_unit" => MinorUnit
        | _ =>
          MajorUnit(
            switch amountDelimiterVal {
            | "comma" => Comma
            | _ => Dot
            },
          )
        }

        let parseProcessingMode = switch processingModeVal {
        | "confirmation" => Confirmation
        | _ => Transaction
        }

        let creditVals =
          creditValues
          ->String.split(",")
          ->Array.map(String.trim)
          ->Array.filter(s => s->String.length > 0)
        let debitVals =
          debitValues
          ->String.split(",")
          ->Array.map(String.trim)
          ->Array.filter(s => s->String.length > 0)

        let req: createTransformationConfigRequest = {
          ingestion_id: ingestion.ingestion_id,
          account_id: ingestion.account_id,
          name: transformationName,
          is_active: true,
          config: {
            merchant_id: merchantId,
            profile_id: profileId,
            account_id: ingestion.account_id,
          },
          metadata_schema_data: {
            fields: {
              currency: {identifier: currencyColumn},
              amount: {
                identifier: amountColumn,
                unit_type: parseAmountUnit,
                validation_rules_minor: [],
                validation_rules_major: [],
              },
              effective_at: {
                identifier: effectiveAtColumn,
                date_time_format: {
                  date_format: {
                    order: parseDateOrder,
                    delimiter: parseDateDelimiter,
                  },
                  time_format: None,
                },
              },
              balance_direction: {
                identifier: balanceDirColumn,
                credit_values: creditVals,
                debit_values: debitVals,
              },
              order_id: {
                identifier: orderIdColumn,
                transformation_rules: [],
              },
              metadata_fields: metadataFields,
            },
            unique_constraint: {
              constraint_type: SingleField(uniqueField),
              description: uniqueDescription,
            },
            processing_mode: parseProcessingMode,
          },
        }

        let result = await createTransformation(req)
        switch result {
        | Some(transformation) => {
            onTransformationCreated(transformation)
            // Reset form
            setTransformationName(_ => "")
            setSelectedIngestionId(_ => "")
            setCurrencyColumn(_ => "")
            setAmountColumn(_ => "")
            setEffectiveAtColumn(_ => "")
            setBalanceDirColumn(_ => "")
            setCreditValues(_ => "")
            setDebitValues(_ => "")
            setOrderIdColumn(_ => "")
            setUniqueField(_ => "order_id")
            setUniqueDescription(_ => "")
            setMetadataFields(_ => [])
          }
        | None => ()
        }
        setIsSubmitting(_ => false)
      }
    }
  }

  let canProceed =
    state.ingestions->Array.every(ing =>
      state.transformations->Array.some(t => t.ingestion_id === ing.ingestion_id)
    )

  let allConfigured = ingestionsWithoutTransformation->Array.length === 0

  <div className="flex flex-col gap-6 max-w-2xl">
    <div>
      <h2 className="text-lg font-semibold text-gray-900 mb-1">
        {"Configure Transformation"->React.string}
      </h2>
      <p className="text-sm text-gray-500">
        {"Map your CSV columns to reconciliation fields. This tells the system what each column in your data file means."->React.string}
      </p>
    </div>
    // Existing transformations
    <RenderIf condition={state.transformations->Array.length > 0}>
      <div className="flex flex-col gap-2">
        <h3 className="text-sm font-medium text-gray-700"> {"Configured"->React.string} </h3>
        {state.transformations
        ->Array.map(t =>
          <div
            key={t.transformation_id}
            className="flex items-center justify-between p-3 border border-gray-200 rounded-lg">
            <div>
              <p className="font-medium text-sm text-gray-900"> {t.name->React.string} </p>
              <p className="text-xs text-gray-500">
                {`${t.metadata_fields->Array.length->Int.toString} metadata fields`->React.string}
              </p>
            </div>
            <span
              className="text-xs px-2 py-0.5 rounded-full bg-green-50 text-green-700 border border-green-200">
              {"Done"->React.string}
            </span>
          </div>
        )
        ->React.array}
      </div>
    </RenderIf>
    // Info box
    <div className="bg-purple-50 border border-purple-200 rounded-lg p-4 flex gap-3">
      <span className="text-lg flex-shrink-0"> {`\u{1F4CB}`->React.string} </span>
      <div className="text-xs text-purple-800 leading-relaxed">
        <p className="font-semibold mb-1"> {"What is a transformation?"->React.string} </p>
        <p className="text-purple-700">
          {"A transformation tells the system how to read your CSV files. You map each CSV column header to a system field. For example, if your CSV has a column called \"Settle Amount\", you map it to the system's \"amount\" field."->React.string}
        </p>
      </div>
    </div>
    // Add transformation form
    <RenderIf condition={!allConfigured}>
      <div className="border border-gray-200 rounded-lg overflow-hidden">
        // Header section
        <div className="p-5 bg-white">
          <h3 className="text-sm font-semibold text-gray-800 mb-4 flex items-center gap-2">
            <span className="w-5 h-5 rounded-full bg-purple-100 text-purple-700 flex items-center justify-center text-[10px] font-bold">
              {"1"->React.string}
            </span>
            {"Basic Setup"->React.string}
          </h3>
          <div className="grid grid-cols-2 gap-4 ml-7">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                {"Ingestion Source"->React.string}
              </label>
              <select
                value={selectedIngestionId}
                onChange={e => setSelectedIngestionId(_ => ReactEvent.Form.target(e)["value"])}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
                <option value="" disabled=true> {"Select..."->React.string} </option>
                {ingestionsWithoutTransformation
                ->Array.map(ing =>
                  <option key={ing.ingestion_id} value={ing.ingestion_id}>
                    {ing.name->React.string}
                  </option>
                )
                ->React.array}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                {"Transformation Name"->React.string}
              </label>
              <input
                type_="text"
                value={transformationName}
                onChange={e => setTransformationName(_ => ReactEvent.Form.target(e)["value"])}
                placeholder="e.g., PSP Payments"
                className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
          </div>
        </div>
        // Required field mappings section
        <div className="p-5 bg-white border-t border-gray-100">
          <h4 className="text-sm font-semibold text-gray-800 mb-1 flex items-center gap-2">
            <span className="w-5 h-5 rounded-full bg-purple-100 text-purple-700 flex items-center justify-center text-[10px] font-bold">
              {"2"->React.string}
            </span>
            {"Required Field Mappings"->React.string}
          </h4>
          <p className="text-xs text-gray-500 mb-4 ml-7">
            {"Enter the exact CSV column header name for each system field. These are the core fields every entry needs."->React.string}
          </p>
            <div className="grid grid-cols-2 gap-4 ml-7">
              // Currency
              <div>
                <label className="block text-xs font-medium text-gray-600 mb-1">
                  {"Currency Column"->React.string}
                </label>
                <input
                  type_="text"
                  value={currencyColumn}
                  onChange={e => setCurrencyColumn(_ => ReactEvent.Form.target(e)["value"])}
                  placeholder="e.g., Transaction Currency"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-blue-500"
                />
              </div>
              // Amount
              <div>
                <label className="block text-xs font-medium text-gray-600 mb-1">
                  {"Amount Column"->React.string}
                </label>
                <input
                  type_="text"
                  value={amountColumn}
                  onChange={e => setAmountColumn(_ => ReactEvent.Form.target(e)["value"])}
                  placeholder="e.g., Settle Amount"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-blue-500"
                />
              </div>
              // Amount unit type
              <div>
                <label className="block text-xs font-medium text-gray-600 mb-1">
                  {"Amount Unit"->React.string}
                </label>
                <select
                  value={amountUnitType}
                  onChange={e => setAmountUnitType(_ => ReactEvent.Form.target(e)["value"])}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-blue-500">
                  <option value="major_unit"> {"Major Unit (e.g., 10.50)"->React.string} </option>
                  <option value="minor_unit">
                    {"Minor Unit (e.g., 1050 cents)"->React.string}
                  </option>
                </select>
              </div>
              // Amount delimiter (only for major unit)
              <RenderIf condition={amountUnitType === "major_unit"}>
                <div>
                  <label className="block text-xs font-medium text-gray-600 mb-1">
                    {"Decimal Separator"->React.string}
                  </label>
                  <select
                    value={amountDelimiterVal}
                    onChange={e => setAmountDelimiterVal(_ => ReactEvent.Form.target(e)["value"])}
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-blue-500">
                    <option value="dot"> {"Dot (.)"->React.string} </option>
                    <option value="comma"> {"Comma (,)"->React.string} </option>
                  </select>
                </div>
              </RenderIf>
              // Effective At
              <div>
                <label className="block text-xs font-medium text-gray-600 mb-1">
                  {"Date Column"->React.string}
                </label>
                <input
                  type_="text"
                  value={effectiveAtColumn}
                  onChange={e => setEffectiveAtColumn(_ => ReactEvent.Form.target(e)["value"])}
                  placeholder="e.g., Date"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-blue-500"
                />
              </div>
              // Date format
              <div>
                <label className="block text-xs font-medium text-gray-600 mb-1">
                  {"Date Format"->React.string}
                </label>
                <div className="flex gap-2">
                  <select
                    value={dateOrder}
                    onChange={e => setDateOrder(_ => ReactEvent.Form.target(e)["value"])}
                    className="flex-1 px-2 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-blue-500">
                    <option value="year_month_day"> {"YYYY-MM-DD"->React.string} </option>
                    <option value="day_month_year"> {"DD-MM-YYYY"->React.string} </option>
                    <option value="month_day_year"> {"MM-DD-YYYY"->React.string} </option>
                  </select>
                  <select
                    value={dateDelimiter}
                    onChange={e => setDateDelimiter(_ => ReactEvent.Form.target(e)["value"])}
                    className="w-24 px-2 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-blue-500">
                    <option value="hyphen"> {"-"->React.string} </option>
                    <option value="slash"> {"/"->React.string} </option>
                    <option value="dot"> {"."->React.string} </option>
                  </select>
                </div>
              </div>
              // Balance Direction
              <div>
                <label className="block text-xs font-medium text-gray-600 mb-1">
                  {"Balance Direction Column"->React.string}
                </label>
                <input
                  type_="text"
                  value={balanceDirColumn}
                  onChange={e => setBalanceDirColumn(_ => ReactEvent.Form.target(e)["value"])}
                  placeholder="e.g., Transaction Currency"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-blue-500"
                />
              </div>
              // Credit/Debit values
              <div>
                <label className="block text-xs font-medium text-gray-600 mb-1">
                  {"Credit Values"->React.string}
                </label>
                <input
                  type_="text"
                  value={creditValues}
                  onChange={e => setCreditValues(_ => ReactEvent.Form.target(e)["value"])}
                  placeholder="e.g., credit, cr, MYR"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-blue-500"
                />
                <p className="text-[10px] text-gray-400 mt-0.5">
                  {"Comma-separated values that indicate a credit"->React.string}
                </p>
              </div>
              <div>
                <label className="block text-xs font-medium text-gray-600 mb-1">
                  {"Debit Values"->React.string}
                </label>
                <input
                  type_="text"
                  value={debitValues}
                  onChange={e => setDebitValues(_ => ReactEvent.Form.target(e)["value"])}
                  placeholder="e.g., debit, dr, CA"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-blue-500"
                />
              </div>
              // Order ID
              <div>
                <label className="block text-xs font-medium text-gray-600 mb-1">
                  {"Order/Reference ID Column"->React.string}
                </label>
                <input
                  type_="text"
                  value={orderIdColumn}
                  onChange={e => setOrderIdColumn(_ => ReactEvent.Form.target(e)["value"])}
                  placeholder="e.g., Merchant Ref ID"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-blue-500"
                />
              </div>
              // Processing mode
              <div>
                <label className="block text-xs font-medium text-gray-600 mb-1">
                  {"Processing Mode"->React.string}
                </label>
                <select
                  value={processingModeVal}
                  onChange={e => setProcessingModeVal(_ => ReactEvent.Form.target(e)["value"])}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-blue-500">
                  <option value="transaction">
                    {"Transaction (creates expected entries)"->React.string}
                  </option>
                  <option value="confirmation">
                    {"Confirmation (matches against existing)"->React.string}
                  </option>
                </select>
              </div>
            </div>
          </div>
          // Metadata Fields section
          <div className="p-5 bg-white border-t border-gray-100">
            <div className="flex items-center justify-between mb-3">
              <h4 className="text-sm font-semibold text-gray-800 flex items-center gap-2">
                <span className="w-5 h-5 rounded-full bg-purple-100 text-purple-700 flex items-center justify-center text-[10px] font-bold">
                  {"3"->React.string}
                </span>
                {"Additional Metadata Fields"->React.string}
              </h4>
              <button
                type_="button"
                onClick={_ => addMetadataField()}
                className="text-sm text-blue-600 hover:text-blue-700 font-medium flex items-center gap-1">
                <span> {"+"->React.string} </span>
                {"Add Field"->React.string}
              </button>
            </div>
            <p className="text-xs text-gray-500 mb-3 ml-7">
              {"Map additional CSV columns to metadata fields. These become available as matching fields in recon rules."->React.string}
            </p>
            <div className="flex flex-col gap-2">
              {metadataFields
              ->Array.mapWithIndex((field, index) =>
                <MetadataFieldRow
                  key={index->Int.toString}
                  index
                  field
                  onUpdate={updateMetadataField}
                  onRemove={removeMetadataField}
                />
              )
              ->React.array}
            </div>
            <RenderIf condition={metadataFields->Array.length === 0}>
              <div
                className="text-center py-6 text-sm text-gray-400 border border-dashed border-gray-300 rounded-lg">
                {"No metadata fields added yet. Click \"Add Field\" to map additional CSV columns."->React.string}
              </div>
            </RenderIf>
          </div>
          // Unique Constraint section
          <div className="p-5 bg-white border-t border-gray-100">
            <h4 className="text-sm font-semibold text-gray-800 mb-1 flex items-center gap-2">
              <span className="w-5 h-5 rounded-full bg-purple-100 text-purple-700 flex items-center justify-center text-[10px] font-bold">
                {"4"->React.string}
              </span>
              {"Unique Constraint & Processing"->React.string}
            </h4>
            <p className="text-xs text-gray-500 mb-3 ml-7">
              {"Which field should be unique per entry? Duplicates based on this field will be flagged."->React.string}
            </p>
            <div className="grid grid-cols-2 gap-4 ml-7">
              <div>
                <label className="block text-xs font-medium text-gray-600 mb-1">
                  {"Unique Field"->React.string}
                </label>
                <select
                  value={uniqueField}
                  onChange={e => setUniqueField(_ => ReactEvent.Form.target(e)["value"])}
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-blue-500">
                  <option value="order_id"> {"order_id"->React.string} </option>
                  {metadataFields
                  ->Array.map(f =>
                    <option key={f.field_name} value={f.field_name}>
                      {f.field_name->React.string}
                    </option>
                  )
                  ->React.array}
                </select>
              </div>
              <div>
                <label className="block text-xs font-medium text-gray-600 mb-1">
                  {"Description"->React.string}
                </label>
                <input
                  type_="text"
                  value={uniqueDescription}
                  onChange={e => setUniqueDescription(_ => ReactEvent.Form.target(e)["value"])}
                  placeholder="e.g., Order ID must be unique"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-1 focus:ring-blue-500"
                />
              </div>
            </div>
          </div>
          // Submit
          <button
            type_="button"
            disabled={transformationName->String.trim->String.length === 0 ||
              currencyColumn->String.length === 0 ||
              amountColumn->String.length === 0 ||
              effectiveAtColumn->String.length === 0 ||
              orderIdColumn->String.length === 0 ||
              isSubmitting}
            onClick={_ => handleSubmit()->ignore}
            className="w-full px-4 py-2.5 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700 disabled:bg-gray-300 disabled:cursor-not-allowed transition-colors">
            {(isSubmitting ? "Creating Transformation..." : "Save Transformation")->React.string}
          </button>
        </div>
      </div>
    </RenderIf>
    <RenderIf condition={allConfigured}>
      <div
        className="text-sm text-green-700 bg-green-50 border border-green-200 rounded-lg px-4 py-3">
        {"All ingestion sources have transformations configured."->React.string}
      </div>
    </RenderIf>
    // Navigation
    <div className="flex justify-between pt-2">
      <button
        type_="button"
        onClick={_ => onBack()}
        className="px-4 py-2 text-gray-600 border border-gray-300 rounded-lg text-sm font-medium hover:bg-gray-50 transition-colors">
        {`\u{2190} Back`->React.string}
      </button>
      <button
        type_="button"
        disabled={!canProceed}
        onClick={_ => onNext()}
        className="px-6 py-2.5 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700 disabled:bg-gray-300 disabled:cursor-not-allowed transition-colors flex items-center gap-2">
        {"Continue to Rules"->React.string}
        <span> {`\u{2192}`->React.string} </span>
      </button>
    </div>
  </div>
}
