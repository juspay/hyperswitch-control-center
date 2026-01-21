open ReconEngineRulesTypes
open Typography
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
      <div className={`${body.md.medium} text-nd_gray-500`}> {"Status"->React.string} </div>
      <div className="flex items-center">
        <span className={`px-2 py-1 ${body.sm.semibold} rounded-sm ${bgColor} ${textColor}`}>
          {text->React.string}
        </span>
      </div>
    </div>
  }
}

module RuleIDCopy = {
  @react.component
  let make = (~ruleId: string) => {
    <div className="flex flex-col gap-2">
      <div className={`${body.md.medium} text-nd_gray-500`}> {"Rule ID"->React.string} </div>
      <HelperComponents.CopyTextCustomComp
        displayValue=Some(ruleId)
        copyValue=Some(ruleId)
        customTextCss={`${body.md.semibold} text-nd_gray-600`}
      />
    </div>
  }
}

module SearchIdentifier = {
  @react.component
  let make = (~rule: rulePayload) => {
    let searchIdentifier = switch rule.strategy {
    | OneToOne(oneToOne) =>
      switch oneToOne {
      | SingleSingle(data) => Some(data.search_identifier)
      | SingleMany(data) => Some(data.search_identifier)
      | ManySingle(data) => Some(data.search_identifier)
      }
    | UnknownReconStrategy => None
    }

    <div className="flex flex-col gap-8 p-6 border border-nd_gray-150 rounded-xl bg-white">
      <div className="flex flex-col gap-1 items-start">
        <p className={`${body.lg.semibold} text-nd_gray-800`}>
          {"How matching records are linked"->React.string}
        </p>
        <p className={`${body.md.medium} text-nd_gray-400`}>
          {"We compare a field from the source account with a field from the target account to identify the same record"->React.string}
        </p>
      </div>
      <div className="flex flex-col gap-4">
        {switch searchIdentifier {
        | Some(identifier) =>
          let sourceFieldInput = createFormInput(
            ~name="search_source_field",
            ~value=identifier.source_field,
          )
          let targetFieldInput = createFormInput(
            ~name="search_target_field",
            ~value=identifier.target_field,
          )

          let sourceFieldOptions = [
            createDropdownOption(
              ~label=getFieldDisplayName(identifier.source_field),
              ~value=identifier.source_field,
            ),
          ]
          let targetFieldOptions = [
            createDropdownOption(
              ~label=getFieldDisplayName(identifier.target_field),
              ~value=identifier.target_field,
            ),
          ]

          <div className="flex items-center gap-10">
            <div className="flex-1 max-w-325">
              <label className=labelCss> {"Source Column"->React.string} </label>
              <SelectBox.BaseDropdown
                allowMultiSelect=false
                buttonText={getFieldDisplayName(identifier.source_field)}
                input=sourceFieldInput
                options=sourceFieldOptions
                hideMultiSelectButtons=true
                deselectDisable=true
                disableSelect=true
                fullLength=true
                customButtonStyle="w-147-px h-40-px"
              />
              <p className={`${body.md.regular} text-nd_gray-500 mt-2 ml-1`}>
                {"This value identifies the record on the source side"->React.string}
              </p>
            </div>
            <div className="flex items-center">
              <Icon name="nd-arrow-right" size=16 className="text-nd_gray-500" />
            </div>
            <div className="flex-1 max-w-325">
              <label className=labelCss> {"Target Column"->React.string} </label>
              <SelectBox.BaseDropdown
                allowMultiSelect=false
                buttonText={getFieldDisplayName(identifier.target_field)}
                input=targetFieldInput
                options=targetFieldOptions
                hideMultiSelectButtons=true
                deselectDisable=true
                disableSelect=true
                fullLength=true
                customButtonStyle="w-147-px h-40-px"
              />
              <p className={`${body.md.regular} text-nd_gray-500 mt-2 ml-1`}>
                {"We match this value with the source field"->React.string}
              </p>
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
    let mappingRules = switch rule.strategy {
    | OneToOne(oneToOne) =>
      switch oneToOne {
      | SingleSingle(data) => data.match_rules.rules
      | SingleMany(data) => data.match_rules.rules
      | ManySingle(data) => data.match_rules.rules
      }
    | UnknownReconStrategy => []
    }

    <div className="flex flex-col gap-8 p-6 border border-nd_gray-150 rounded-xl bg-white">
      <div className="flex flex-col gap-1 items-start">
        <p className={`${body.lg.semibold} text-nd_gray-800`}>
          {"How matches are validated"->React.string}
        </p>
        <p className={`${body.md.medium} text-nd_gray-400`}>
          {"Once records are identified as related, we check these conditions to confirm if they match"->React.string}
        </p>
      </div>
      <div className="flex flex-col gap-4">
        <div className="flex items-center gap-10">
          <div className="flex-1 max-w-325 flex flex-row gap-2">
            <div className={`${body.md.medium} text-nd_gray-700`}>
              {"Source"->React.string}
              <span className={`${body.md.regular} text-nd_gray-400 ml-1`}>
                {"(This value is compared against target value)"->React.string}
              </span>
            </div>
          </div>
          <div className="w-4" />
          <div className="flex-1 max-w-325 flex flex-row gap-2">
            <div className={`${body.md.medium} text-nd_gray-700`}>
              {"Target"->React.string}
              <span className={`${body.md.regular} text-nd_gray-400 ml-1`}>
                {"(This value must match the source value)"->React.string}
              </span>
            </div>
          </div>
        </div>
        {mappingRules
        ->Array.mapWithIndex((mapping, index) => {
          let sourceFieldInput = createFormInput(
            ~name=`mapping_source_${index->Int.toString}`,
            ~value=mapping.source_field,
          )
          let targetFieldInput = createFormInput(
            ~name=`mapping_target_${index->Int.toString}`,
            ~value=mapping.target_field,
          )

          let sourceFieldOptions = [
            createDropdownOption(
              ~label=getFieldDisplayName(mapping.source_field),
              ~value=mapping.source_field,
            ),
          ]
          let targetFieldOptions = [
            createDropdownOption(
              ~label=getFieldDisplayName(mapping.target_field),
              ~value=mapping.target_field,
            ),
          ]
          <div className="flex flex-col gap-4" key={LogicUtils.randomString(~length=10)}>
            <div className="flex items-center gap-10">
              <div className="flex-1 max-w-325">
                <SelectBox.BaseDropdown
                  allowMultiSelect=false
                  buttonText={getFieldDisplayName(mapping.source_field)}
                  input=sourceFieldInput
                  options=sourceFieldOptions
                  hideMultiSelectButtons=true
                  deselectDisable=true
                  disableSelect=true
                  fullLength=true
                  customButtonStyle="w-147-px h-40-px"
                />
              </div>
              <div className="flex items-center">
                <Icon name="nd-arrow-right" size=16 className="text-nd_gray-500" />
              </div>
              <div className="flex-1 max-w-325">
                <SelectBox.BaseDropdown
                  allowMultiSelect=false
                  buttonText={getFieldDisplayName(mapping.target_field)}
                  input=targetFieldInput
                  options=targetFieldOptions
                  hideMultiSelectButtons=true
                  deselectDisable=true
                  disableSelect=true
                  fullLength=true
                  customButtonStyle="w-147-px h-40-px"
                />
              </div>
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
      createDropdownOption(~label="=", ~value="equals"),
      createDropdownOption(~label="≠", ~value="not_equals"),
    ]
    let getFieldOptions = (): array<SelectBox.dropdownOption> => [
      createDropdownOption(~label="Card Type", ~value="metadata.card_type"),
    ]
    let operatorOptions = getOperatorOptions()
    let fieldOptions = getFieldOptions()

    let triggerData = switch rule.strategy {
    | OneToOne(oneToOne) =>
      switch oneToOne {
      | SingleSingle(data) => Some(data.source_account.trigger)
      | SingleMany(data) => Some(data.source_account.trigger)
      | ManySingle(data) => Some(data.source_account.trigger)
      }
    | UnknownReconStrategy => None
    }

    let triggerField = triggerData->Option.map(trigger => trigger.field)->Option.getOr("")
    let triggerOperator =
      triggerData->Option.map(trigger => trigger.operator.value)->Option.getOr("")
    let triggerValue = triggerData->Option.map(trigger => trigger.value)->Option.getOr("")

    let fieldInput = createFormInput(~name="trigger_field", ~value=triggerField)
    let operatorInput = createFormInput(~name="trigger_operator", ~value=triggerOperator)
    let valueInput = createFormInput(~name="trigger_value", ~value=triggerValue)

    <div className="flex flex-col gap-2">
      <p className={`${body.md.medium} text-nd_gray-700`}> {"Filters"->React.string} </p>
      <div className="flex flex-row gap-4">
        <div className="flex-1 flex flex-col gap-2 max-w-325">
          <SelectBox.BaseDropdown
            allowMultiSelect=false
            buttonText={getFieldDisplayName(triggerField)}
            input=fieldInput
            options=fieldOptions
            hideMultiSelectButtons=true
            deselectDisable=true
            disableSelect=true
            fullLength=true
            customButtonStyle="w-147-px h-40-px"
          />
        </div>
        <SelectBox.BaseDropdown
          allowMultiSelect=false
          buttonText={operatorOptions
          ->Array.find(opt => opt.value === triggerOperator)
          ->Option.mapOr("Select Operator", opt => opt.label)}
          input=operatorInput
          options=operatorOptions
          hideMultiSelectButtons=true
          deselectDisable=true
          disableSelect=true
          customButtonStyle="w-16 h-40-px"
        />
        <div className="flex-1 flex flex-col gap-2 max-w-325">
          {InputFields.textInput(
            ~isDisabled=true,
            ~inputStyle="rounded-lg",
            ~customDashboardClass="h-40-px text-sm font-normal",
            ~onDisabledStyle=`!bg-nd_gray-50 border-nd_gray-200 !text-nd_gray-500 ${body.md.semibold}`,
          )(~input=valueInput, ~placeholder="Enter trigger value")}
        </div>
      </div>
      <p className={`${body.md.regular} text-nd_gray-500 ml-1 mb-1`}>
        {"Only records with these matching filters will create expectations"->React.string}
      </p>
    </div>
  }
}
module SourceTargetAccount = {
  @react.component
  let make = (~rule: rulePayload) => {
    let (accountData, setAccountData) = React.useState(_ => [])
    let getAccounts = ReconEngineHooks.useGetAccounts()
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

    let getAccountsData = async _ => {
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)
        let accountData = await getAccounts()
        setAccountData(_ => accountData)
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Custom)
      }
    }

    React.useEffect(() => {
      getAccountsData()->ignore
      None
    }, [])

    let getAccountName = (accountId: string): string => {
      accountData
      ->Array.find(account => account.account_id === accountId)
      ->Option.map(account => account.account_name)
      ->Option.getOr("Unknown Account")
    }

    let accountOptions =
      accountData->Array.map((account): SelectBox.dropdownOption =>
        createDropdownOption(~label=account.account_name, ~value=account.account_id)
      )

    let (sourceAccountId, targetAccountId) = switch rule.strategy {
    | OneToOne(oneToOne) =>
      switch oneToOne {
      | SingleSingle(data) => (data.source_account.account_id, data.target_account.account_id)
      | SingleMany(data) => (data.source_account.account_id, data.target_account.account_id)
      | ManySingle(data) => (data.source_account.account_id, data.target_account.account_id)
      }
    | UnknownReconStrategy => ("", "")
    }

    let sourceAccountInput = createFormInput(~name="source_account", ~value=sourceAccountId)
    let targetAccountInput = createFormInput(~name="target_account", ~value=targetAccountId)

    <div className="flex flex-col gap-8 p-6 border border-nd_gray-150 rounded-xl bg-white">
      <div className="flex flex-col gap-1 items-start">
        <p className={`${body.lg.semibold} text-nd_gray-800`}>
          {"Expectation Creation"->React.string}
        </p>
        <p className={`${body.md.medium} text-nd_gray-400`}>
          {"What should exist on the other side?"->React.string}
        </p>
      </div>
      <PageLoaderWrapper
        screenState
        customUI={<NewAnalyticsHelper.NoData height="h-32" message="No data available." />}
        customLoader={<Shimmer styleClass="h-32 w-full rounded-b-lg" />}>
        <div className="flex items-center gap-10">
          <div className="flex-1 max-w-325">
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
              customButtonStyle="w-147-px h-40-px"
            />
            <p className={`${body.md.regular} text-nd_gray-500 mt-2 ml-1`}>
              {"Where the original transaction is recorded"->React.string}
            </p>
          </div>
          <div className="flex items-center">
            <Icon name="nd-arrow-right" size=16 className="text-nd_gray-500" />
          </div>
          <div className="flex-1 max-w-325">
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
              customButtonStyle="w-147-px h-40-px"
            />
            <p className={`${body.md.regular} text-nd_gray-500 mt-2 ml-1`}>
              {"Where the transaction should show up"->React.string}
            </p>
          </div>
        </div>
        <TriggerRules rule />
      </PageLoaderWrapper>
    </div>
  }
}

module RuleSchemaComponents = {
  @react.component
  let make = (~rule: rulePayload) => {
    <div className="flex flex-col gap-6">
      <SourceTargetAccount rule />
      <SearchIdentifier rule />
      <MappingRules rule />
    </div>
  }
}

module RuleDetailsContent = {
  @react.component
  let make = (~rule: rulePayload) => {
    let fields = [
      ("Rule Name", rule.rule_name),
      (
        "Description",
        rule.rule_description->LogicUtils.isNonEmptyString ? rule.rule_description : "NA",
      ),
    ]

    <div className="flex flex-col gap-6">
      <div className="rounded-lg p-6 border border-nd_gray-150">
        <div className="grid md:grid-cols-2 gap-6">
          {fields
          ->Array.map(((label, value)) => {
            <FieldDisplay key={LogicUtils.randomString(~length=10)} label={label} value={value} />
          })
          ->React.array}
          <RuleIDCopy.make ruleId={rule.rule_id} />
          <StatusBadge isActive={rule.is_active} />
        </div>
      </div>
      <RuleSchemaComponents rule />
    </div>
  }
}

@react.component
let make = (~id) => {
  open APIUtils
  open LogicUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (ruleData, setRuleData) = React.useState((): option<rulePayload> => None)

  let getRulesDetails = async _ => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#RECON_RULES,
        ~id=Some(id),
      )
      let res = await fetchDetails(url)
      let rule = res->getDictFromJsonObject->ruleItemToObjMapper
      setRuleData(_ => Some(rule))
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  React.useEffect(() => {
    getRulesDetails()->ignore
    None
  }, [])

  <PageLoaderWrapper screenState>
    <div className="flex flex-col gap-6">
      <BreadCrumbNavigation
        path=[{title: "Rules Library", link: `/v1/recon-engine/rules`}]
        currentPageTitle=id
        cursorStyle="cursor-pointer"
        customTextClass="text-nd_gray-400"
        titleTextClass="text-nd_gray-600 font-medium"
        fontWeight="font-medium"
        dividerVal=Slash
        childGapClass="gap-2"
      />
      <PageUtils.PageHeading title="View Rule" customHeadingStyle="py-0" />
      {switch ruleData {
      | Some(rule) => <RuleDetailsContent rule />
      | None => <div className="bg-white rounded-lg p-6"> {"Rule not found"->React.string} </div>
      }}
    </div>
  </PageLoaderWrapper>
}
