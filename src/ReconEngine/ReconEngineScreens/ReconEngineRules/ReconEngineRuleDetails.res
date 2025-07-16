open ReconEngineRulesTypes
open Typography
open ReconEngineRulesEntity
open ReconEngineRulesUtils
let labelCss = `block ${body.md.medium} text-nd_gray-700 mb-2`
module FieldDisplay = {
  @react.component
  let make = (~label: string, ~value: string, ~className: string="") => {
    <div className={`flex flex-col gap-2 ${className}`}>
      <div className={`${body.md.medium} text-nd_gray-500`}> {label->React.string} </div>
      <div className={`${body.md.semibold} text-nd_gray-600`}> {value->React.string} </div>
    </div>
  }
}
module StatusBadge = {
  @react.component
  let make = (~isActive: bool) => {
    let (bgColor, textColor, text) = isActive
      ? ("bg-green-100", "text-green-800", "ACTIVE")
      : ("bg-nd_gray-100", "text-nd_gray-800", "INACTIVE")

    <div className="flex flex-col gap-2">
      <div className="text-sm font-medium text-jp-gray-600"> {"Status"->React.string} </div>
      <div className="flex items-center">
        <span className={`px-2 py-1 text-xs font-medium rounded-sm ${bgColor} ${textColor}`}>
          {text->React.string}
        </span>
      </div>
    </div>
  }
}

module SourceTargetHeader = {
  @react.component
  let make = () => {
    let headerCss = `${body.sm.semibold} text-nd_gray-500 uppercase tracking-wide`
    <div className="flex items-center gap-4 mb-4">
      <div className="flex-1 max-w-xs flex flex-row gap-2">
        <Icon
          name="recon-src-account"
          size=20
          className="text-nd_gray-500 border border-nd_gray-150 rounded-md p-0.5"
        />
        <div className={`${headerCss}`}> {"Source Account"->React.string} </div>
      </div>
      <div className="w-8" />
      <div className="flex-1 max-w-xs flex flex-row gap-2">
        <Icon
          name="recon-target-account"
          size=20
          className="text-nd_gray-500 border border-nd_gray-150 rounded-md p-0.5"
        />
        <div className={`${headerCss}`}> {"Target Account"->React.string} </div>
      </div>
    </div>
  }
}
module SearchIdentifier = {
  @react.component
  let make = (~rule: rulePayload) => {
    // Get search identifier from targets[0].search_identifier
    let searchIdentifier =
      rule.targets
      ->Array.get(0)
      ->Option.map(target => target.search_identifier)

    <div className="p-6">
      <SourceTargetHeader />
      <div className="flex flex-col gap-4">
        // Search identifier mapping
        {switch searchIdentifier {
        | Some(identifier) =>
          // Create individual inputs for source and target fields
          let sourceFieldInput: ReactFinalForm.fieldRenderPropsInput = {
            name: "search_source_field",
            onBlur: _ => (),
            onChange: _ => (),
            onFocus: _ => (),
            value: identifier.source_field->JSON.Encode.string,
            checked: true,
          }

          let targetFieldInput: ReactFinalForm.fieldRenderPropsInput = {
            name: "search_target_field",
            onBlur: _ => (),
            onChange: _ => (),
            onFocus: _ => (),
            value: identifier.target_field->JSON.Encode.string,
            checked: true,
          }

          let sourceFieldOptions = [
            {
              SelectBox.label: getFieldDisplayName(identifier.source_field),
              value: identifier.source_field,
            },
          ]

          let targetFieldOptions = [
            {
              SelectBox.label: getFieldDisplayName(identifier.target_field),
              value: identifier.target_field,
            },
          ]

          <div className="flex items-center gap-4 py-2">
            // Source Field
            <div className="flex-1 max-w-xs">
              <SelectBox.BaseDropdown
                allowMultiSelect=false
                buttonText={getFieldDisplayName(identifier.source_field)}
                input=sourceFieldInput
                options=sourceFieldOptions
                hideMultiSelectButtons=true
                deselectDisable=true
                disableSelect=true
                fullLength=true
              />
            </div>
            // Arrow
            <div className="flex items-center">
              <Icon name="nd-arrow-right" size=14 className="text-nd_gray-500" />
            </div>
            // Target Field
            <div className="flex-1 max-w-xs">
              <SelectBox.BaseDropdown
                allowMultiSelect=false
                buttonText={getFieldDisplayName(identifier.target_field)}
                input=targetFieldInput
                options=targetFieldOptions
                hideMultiSelectButtons=true
                deselectDisable=true
                disableSelect=true
                fullLength=true
              />
            </div>
          </div>
        | None =>
          <div className="text-sm text-jp-gray-500 text-center py-4">
            {"No search identifier configured"->React.string}
          </div>
        }}
      </div>
    </div>
  }
}
module MappingRules = {
  @react.component
  let make = (~rule: rulePayload) => {
    // Get mapping rules from targets[0].match_rules.rules
    let mappingRules =
      rule.targets
      ->Array.get(0)
      ->Option.map(target => target.match_rules.rules)
      ->Option.getOr([])

    <div className="p-6">
      <SourceTargetHeader />
      <div className="flex flex-col gap-4">
        {mappingRules
        ->Array.mapWithIndex((mapping, index) => {
          let sourceFieldInput: ReactFinalForm.fieldRenderPropsInput = {
            name: `mapping_source_${index->Int.toString}`,
            onBlur: _ => (),
            onChange: _ => (),
            onFocus: _ => (),
            value: mapping.source_field->JSON.Encode.string,
            checked: true,
          }

          let targetFieldInput: ReactFinalForm.fieldRenderPropsInput = {
            name: `mapping_target_${index->Int.toString}`,
            onBlur: _ => (),
            onChange: _ => (),
            onFocus: _ => (),
            value: mapping.target_field->JSON.Encode.string,
            checked: true,
          }

          let sourceFieldOptions = [
            {
              SelectBox.label: getFieldDisplayName(mapping.source_field),
              value: mapping.source_field,
            },
          ]

          let targetFieldOptions = [
            {
              SelectBox.label: getFieldDisplayName(mapping.target_field),
              value: mapping.target_field,
            },
          ]

          <div key={index->Int.toString} className="flex items-center gap-4 py-2">
            <div className="flex-1 max-w-xs">
              <SelectBox.BaseDropdown
                allowMultiSelect=false
                buttonText={getFieldDisplayName(mapping.source_field)}
                input=sourceFieldInput
                options=sourceFieldOptions
                hideMultiSelectButtons=true
                deselectDisable=true
                disableSelect=true
                fullLength=true
              />
            </div>
            // Arrow
            <div className="flex items-center">
              <Icon name="nd-arrow-right" size=14 className="text-nd_gray-500" />
            </div>
            // Target Field
            <div className="flex-1 max-w-xs">
              <SelectBox.BaseDropdown
                allowMultiSelect=false
                buttonText={getFieldDisplayName(mapping.target_field)}
                input=targetFieldInput
                options=targetFieldOptions
                hideMultiSelectButtons=true
                deselectDisable=true
                disableSelect=true
                fullLength=true
              />
            </div>
          </div>
        })
        ->React.array}
      </div>
    </div>
  }
}
module TriggerRules = {
  @react.component
  let make = (~rule: rulePayload) => {
    let getOperatorOptions = (): array<SelectBox.dropdownOption> => [
      {label: "=", value: "equals"},
      {label: "≠", value: "not_equals"},
    ]
    let getFieldOptions = (): array<SelectBox.dropdownOption> => [
      {label: "Card Type", value: "metadata.card_type"},
    ]
    let operatorOptions = getOperatorOptions()
    let fieldOptions = getFieldOptions()

    let triggerData =
      rule.sources
      ->Array.get(0)
      ->Option.map(source => source.trigger)
    let triggerField = triggerData->Option.map(trigger => trigger.field)->Option.getOr("")
    let triggerOperator =
      triggerData->Option.map(trigger => trigger.operator.value)->Option.getOr("")
    let triggerValue = triggerData->Option.map(trigger => trigger.value)->Option.getOr("")

    let fieldInput: ReactFinalForm.fieldRenderPropsInput = {
      name: "trigger_field",
      onBlur: _ => (),
      onChange: _ => (),
      onFocus: _ => (),
      value: triggerField->JSON.Encode.string,
      checked: true,
    }

    let operatorInput: ReactFinalForm.fieldRenderPropsInput = {
      name: "trigger_operator",
      onBlur: _ => (),
      onChange: _ => (),
      onFocus: _ => (),
      value: triggerOperator->JSON.Encode.string,
      checked: true,
    }

    let valueInput: ReactFinalForm.fieldRenderPropsInput = {
      name: "trigger_value",
      onBlur: _ => (),
      onChange: _ => (),
      onFocus: _ => (),
      value: triggerValue->JSON.Encode.string,
      checked: true,
    }

    <div className="p-6">
      <div className="flex flex-row gap-6">
        <div className="flex-1 flex-col gap-2">
          <label className={`${labelCss}`}> {"Field"->React.string} </label>
          <SelectBox.BaseDropdown
            allowMultiSelect=false
            buttonText={getFieldDisplayName(triggerField)}
            input=fieldInput
            options=fieldOptions
            hideMultiSelectButtons=true
            deselectDisable=true
            disableSelect=true
            fullLength=true
          />
        </div>
        <div className="flex flex-col gap-2 items-center">
          <label className={`${labelCss}`}> {"Operator"->React.string} </label>
          <SelectBox.BaseDropdown
            allowMultiSelect=false
            buttonText={operatorOptions
            ->Array.find(opt => opt.value === triggerOperator)
            ->Option.map(opt => opt.label)
            ->Option.getOr("Select Operator")}
            input=operatorInput
            options=operatorOptions
            hideMultiSelectButtons=true
            deselectDisable=true
            disableSelect=true
            customButtonStyle="w-16"
            // fullLength=true
          />
        </div>
        <div className="flex-1 flex-col gap-2">
          <label className={`${labelCss}`}> {"Value"->React.string} </label>
          {InputFields.textInput(~isDisabled=true, ~inputStyle="rounded-lg")(
            ~input=valueInput,
            ~placeholder="Enter trigger value",
          )}
        </div>
      </div>
    </div>
  }
}
module SourceTargetAccount = {
  @react.component
  let make = (~rule: rulePayload) => {
    let getAccountName = (accountId: string): string => {
      let accounts =
        SampleOverviewData.account->LogicUtils.getArrayDataFromJson(
          ReconEngineOverviewUtils.accountItemToObjMapper,
        )

      accounts
      ->Array.find(account => account.account_id === accountId)
      ->Option.map(account => account.account_name)
      ->Option.getOr("Unknown Account")
    }

    let getAccountOptions = () => {
      let accounts =
        SampleOverviewData.account->LogicUtils.getArrayDataFromJson(
          ReconEngineOverviewUtils.accountItemToObjMapper,
        )
      accounts->Array.map((account): SelectBox.dropdownOption => {
        {
          label: account.account_name,
          value: account.account_id,
        }
      })
    }
    let accountOptions = getAccountOptions()
    let sourceAccountId =
      rule.sources
      ->Array.get(0)
      ->Option.map(source => source.account_id)
      ->Option.getOr("")

    let targetAccountId =
      rule.targets
      ->Array.get(0)
      ->Option.map(target => target.account_id)
      ->Option.getOr("")

    let sourceAccountInput: ReactFinalForm.fieldRenderPropsInput = {
      name: "source_account",
      onBlur: _ => (),
      onChange: _ => (),
      onFocus: _ => (),
      value: sourceAccountId->JSON.Encode.string,
      checked: true,
    }

    let targetAccountInput: ReactFinalForm.fieldRenderPropsInput = {
      name: "target_account",
      onBlur: _ => (),
      onChange: _ => (),
      onFocus: _ => (),
      value: targetAccountId->JSON.Encode.string,
      checked: true,
    }

    {
      <div className="p-6">
        <div className="flex items-center gap-4">
          // Source Account
          <div className="flex-1 max-w-xs">
            <label className={`${labelCss}`}> {"Source Account"->React.string} </label>
            <SelectBox.BaseDropdown
              allowMultiSelect=false
              buttonText={getAccountName(sourceAccountId)}
              input=sourceAccountInput
              options={accountOptions}
              hideMultiSelectButtons=true
              deselectDisable=true
              disableSelect=true
              fullLength=true
            />
          </div>
          <div className="flex items-center mt-8">
            <Icon name="nd-arrow-right" size=14 className="text-nd_gray-500" />
          </div>
          <div className="flex-1 max-w-xs">
            <label className={`${labelCss}`}> {"Target Account"->React.string} </label>
            <SelectBox.BaseDropdown
              allowMultiSelect=false
              buttonText={getAccountName(targetAccountId)}
              input=targetAccountInput
              options={accountOptions}
              hideMultiSelectButtons=true
              deselectDisable=true
              disableSelect=true
              fullLength=true
            />
          </div>
        </div>
      </div>
    }
  }
}
module RuleSchemaComponents = {
  @react.component
  let make = (~rule: rulePayload) => {
    <div className="flex flex-col gap-6">
      // source target accounts
      <Accordion
        initialExpandedArray=[0]
        accordion={[
          {
            title: "Source and Target Accounts",
            renderContent: () => <SourceTargetAccount rule />,
            renderContentOnTop: None,
          },
        ]}
        accordianTopContainerCss="border border-nd_gray-150 rounded-lg"
        accordianBottomContainerCss="p-4"
        contentExpandCss="p-0"
        titleStyle="font-semibold text-md text-jp-gray-900"
      />
      // Trigger Rules Section
      <Accordion
        initialExpandedArray=[0]
        accordion={[
          {
            title: "Trigger Rules",
            renderContent: () => <TriggerRules rule />,
            renderContentOnTop: None,
          },
        ]}
        accordianTopContainerCss="border border-nd_gray-150 rounded-lg"
        accordianBottomContainerCss="p-4"
        contentExpandCss="p-0"
        titleStyle="font-semibold text-md text-jp-gray-900"
      />
      // Search Identifier Section
      <Accordion
        initialExpandedArray=[0]
        accordion={[
          {
            title: "Search Identifier",
            renderContent: () => <SearchIdentifier rule />,
            renderContentOnTop: None,
          },
        ]}
        accordianTopContainerCss="border border-nd_gray-150 rounded-lg"
        accordianBottomContainerCss="p-4"
        contentExpandCss="p-0"
        titleStyle="font-semibold text-md text-jp-gray-900"
      />
      // Mapping Rules Section
      <Accordion
        initialExpandedArray=[0]
        accordion={[
          {
            title: "Mapping Rules",
            renderContent: () => <MappingRules rule />,
            renderContentOnTop: None,
          },
        ]}
        accordianTopContainerCss="border border-nd_gray-150 rounded-lg"
        accordianBottomContainerCss="p-4"
        contentExpandCss="p-0"
        titleStyle="font-semibold text-md text-jp-gray-900"
      />
    </div>
  }
}

module RuleDetailsContent = {
  @react.component
  let make = (~rule: rulePayload) => {
    let fields = [
      ("ID", rule.rule_id),
      ("Rule Name", rule.rule_name),
      (
        "Description",
        rule.rule_description->LogicUtils.isNonEmptyString ? rule.rule_description : "NA",
      ),
    ]

    <div className="flex flex-col gap-16">
      <div className="rounded-lg p-6 border border-nd_gray-150">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-2 gap-8">
          {fields
          ->Array.mapWithIndex(((label, value), index) => {
            <FieldDisplay key={index->Int.toString} label value />
          })
          ->React.array}
          <StatusBadge isActive={rule.is_active} />
        </div>
      </div>
      <div className="bg-white rounded-lg">
        <div className="flex flex-col gap-1 mb-6">
          <span className={`${body.lg.semibold} text-nd_gray-800`}>
            {"Rule Schema"->React.string}
          </span>
          <p className={`${body.md.medium} text-nd_gray-400`}>
            {"Configure the source and target accounts and matching rules for this reconciliation rule."->React.string}
          </p>
        </div>
        <RuleSchemaComponents rule />
      </div>
    </div>
  }
}

@react.component
let make = (~id) => {
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (ruleData, setRuleData) = React.useState(_ => None)

  let getRuleDetails = async _ => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let response = SampleData.rules
      let data = response->LogicUtils.getArrayDataFromJson(ruleItemToObjMapper)
      let foundRule = data->Array.find(rule => rule.rule_id === id)
      setRuleData(_ => foundRule)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to load rule details"))
    }
  }

  React.useEffect(() => {
    getRuleDetails()->ignore
    None
  }, [id])

  <PageLoaderWrapper screenState>
    <div className="flex flex-col gap-8 p-6">
      <PageUtils.PageHeading
        title="Rule Details"
        subTitle="View the details of the selected rule"
        customHeadingStyle="py-0"
      />
      {switch ruleData {
      | Some(rule) => <RuleDetailsContent rule />
      | None => <div className="bg-white rounded-lg p-6"> {"Rule not found"->React.string} </div>
      }}
    </div>
  </PageLoaderWrapper>
}
