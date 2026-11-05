open SuperpositionTypes
open SuperpositionUtils
open LogicUtils
open Typography

let makeInput = (~name, ~value, ~onChange): ReactFinalForm.fieldRenderPropsInput => {
  name,
  onBlur: _ => (),
  onChange,
  onFocus: _ => (),
  value,
  checked: false,
}

let toDropdownOptions = (values: array<string>): array<SelectBox.dropdownOption> =>
  values->Array.map(value => {SelectBox.label: value, value})

module ActionIcon = {
  @react.component
  let make = (~iconName, ~description, ~isDisabled=false, ~onClick) => {
    <ToolTip
      description
      toolTipPosition=Top
      toolTipFor={<Icon
        name=iconName
        size=16
        onClick={_ => isDisabled ? () : onClick()}
        className={isDisabled
          ? "cursor-not-allowed text-nd_gray-300"
          : "cursor-pointer text-nd_gray-600"}
      />}
    />
  }
}

module ValueText = {
  @react.component
  let make = (~value: JSON.t) => {
    let text = value->formatValue
    text->isEmptyString
      ? <span className={`${body.md.regular} text-nd_gray-400 italic`}>
          {"Empty"->React.string}
        </span>
      : <span className={`${code.md.regular} text-nd_gray-700 break-all line-clamp-2`} title=text>
          {text->React.string}
        </span>
  }
}

module KindBadge = {
  @react.component
  let make = (~kind) =>
    <span
      className={`${body.sm.medium} text-nd_gray-500 bg-nd_gray-50 border border-nd_gray-150 rounded px-1.5 w-fit`}>
      {kind->getValueKindLabel->React.string}
    </span>
}

module SectionLabel = {
  @react.component
  let make = (~label, ~hint=?) => {
    <div className="flex flex-col gap-0.5">
      <span className={`${body.md.semibold} text-nd_gray-700`}> {label->React.string} </span>
      {switch hint {
      | Some(hint) =>
        <span className={`${body.sm.regular} text-nd_gray-500`}> {hint->React.string} </span>
      | None => React.null
      }}
    </div>
  }
}

module ReasonInput = {
  @react.component
  let make = (~reason, ~setReason, ~disabled=false) => {
    let error = switch (reason->isNonEmptyString, reason->validateChangeReason) {
    | (true, Error(message)) => Some(message)
    | _ => None
    }
    <div className="flex flex-col gap-2">
      <SectionLabel label="Reason" hint="Required. Recorded in the audit trail." />
      <TextInputAdapter
        input={makeInput(~name="change-reason", ~value=reason->JSON.Encode.string, ~onChange=ev => {
          let value = ReactEvent.Form.target(ev)["value"]
          setReason(_ => value)
        })}
        placeholder="Why is this changing?"
        maxLength=changeReasonMaxLength
        isDisabled=disabled
      />
      {switch error {
      | Some(message) =>
        <span className={`${body.sm.regular} text-nd_red-500`}> {message->React.string} </span>
      | None => React.null
      }}
    </div>
  }
}

module ConditionChips = {
  @react.component
  let make = (~condition: Dict.t<JSON.t>) => {
    let scopeEntries =
      scopeDimensionNames->Array.filterMap(name =>
        condition->Dict.get(name)->Option.map(value => (name, value, true))
      )
    let extraEntries =
      condition
      ->Dict.toArray
      ->Array.filter(((name, _)) => !(scopeDimensionNames->Array.includes(name)))
      ->Array.map(((name, value)) => (name, value, false))

    <div className="flex flex-wrap gap-2">
      {[...scopeEntries, ...extraEntries]
      ->Array.map(((name, value, isLocked)) => {
        let valueText = value->formatDimensionValue
        <div
          key=name
          title={`${name->getDimensionDisplayName}: ${valueText}`}
          className={`flex items-center gap-1.5 border rounded-lg px-2.5 py-1 max-w-full whitespace-nowrap ${isLocked
              ? "border-nd_gray-150 bg-nd_gray-50"
              : "border-nd_primary_blue-200 bg-nd_primary_blue-50"}`}>
          <span className={`${body.sm.medium} text-nd_gray-500 shrink-0`}>
            {name->getDimensionDisplayName->React.string}
          </span>
          <span className={`${code.sm.medium} text-nd_gray-700 truncate`}>
            {valueText->React.string}
          </span>
          <RenderIf condition=isLocked>
            <Icon name="lock-icon" size=10 className="text-nd_gray-400 shrink-0" />
          </RenderIf>
        </div>
      })
      ->React.array}
    </div>
  }
}

module FixedScope = {
  @react.component
  let make = () => {
    let scope = SuperpositionHooks.useScope()
    <div className="flex flex-col gap-3 border border-nd_gray-150 rounded-xl px-5 py-4">
      <SectionLabel
        label="Fixed scope"
        hint="Everything here applies to this scope. It comes from the account you're signed in to and can't be changed."
      />
      <ConditionChips condition=scope />
    </div>
  }
}

module ValueEditor = {
  @react.component
  let make = (~name, ~kind, ~draft, ~setDraft: string => unit, ~disabled=false) => {
    let onTextChange = ev => setDraft(ReactEvent.Form.target(ev)["value"])
    let onSelectChange = ev => setDraft(ev->Identity.formReactEventToString)
    switch kind {
    | BoolValue =>
      <SwitchAdapter
        isSelected={draft == "true"}
        setIsSelected={isSelected => setDraft(isSelected ? "true" : "false")}
        isDisabled=disabled
      />
    | IntegerValue | NumberValue =>
      <TextInputAdapter
        input={makeInput(~name, ~value=draft->JSON.Encode.string, ~onChange=onTextChange)}
        placeholder={kind == IntegerValue ? "Enter a whole number" : "Enter a number"}
        inputType="number"
        isDisabled=disabled
      />
    | StringValue =>
      <TextInputAdapter
        input={makeInput(~name, ~value=draft->JSON.Encode.string, ~onChange=onTextChange)}
        placeholder="Enter a value"
        isDisabled=disabled
      />
    | EnumValue(options) =>
      <SingleSelectWrapper
        items={options->toDropdownOptions->SingleSelectWrapper.makeItems(~selectedValue=draft)}
        placeholder="Select a value"
        input={makeInput(~name, ~value=draft->JSON.Encode.string, ~onChange=onSelectChange)}
        disabled
        fullWidth=true
      />
    | StringListValue(options) if options->isNonEmptyArray => {
        let selectedValues =
          draft
          ->safeParse
          ->getArrayFromJson([])
          ->Array.filterMap(JSON.Decode.string)
        <MultiSelectWrapper
          items={options->toDropdownOptions->MultiSelectWrapper.makeItems(~selectedValues)}
          placeholder="Select values"
          input={makeInput(
            ~name,
            ~value=selectedValues->Array.map(JSON.Encode.string)->JSON.Encode.array,
            ~onChange=ev =>
              setDraft(
                ev
                ->Identity.formReactEventToArrayOfString
                ->Array.map(JSON.Encode.string)
                ->JSON.Encode.array
                ->JSON.stringify,
              ),
          )}
          disabled
          fullWidth=true
        />
      }
    | StringListValue(_) | JsonValue =>
      <div className="border border-nd_gray-200 rounded-lg overflow-hidden">
        <MonacoEditorLazy
          defaultLanguage="json"
          value=draft
          height="180px"
          readOnly=disabled
          minimap=false
          showCopy=false
          onChange={value => setDraft(value)}
        />
      </div>
    }
  }
}

let getDimensionValueKind = (dimension: dimension) =>
  getValueKind(dimension.schema, JSON.Encode.string(""))

module ConditionsEditor = {
  @react.component
  let make = (
    ~dimensions: array<dimension>,
    ~conditions: array<(string, string)>,
    ~setConditions: (array<(string, string)> => array<(string, string)>) => unit,
    ~disabled=false,
  ) => {
    let usedNames = conditions->Array.map(((name, _)) => name)
    let availableNames =
      dimensions
      ->Array.filter(dimension =>
        !(scopeDimensionNames->Array.includes(dimension.name)) &&
        !(usedNames->Array.includes(dimension.name))
      )
      ->Array.toSorted((a, b) => Int.toFloat(a.position - b.position))
      ->Array.map(dimension => dimension.name)

    let setConditionValue = (name, value) =>
      setConditions(prev =>
        prev->Array.map(((conditionName, conditionValue)) =>
          conditionName == name ? (conditionName, value) : (conditionName, conditionValue)
        )
      )

    <div className="flex flex-col gap-3">
      {conditions
      ->Array.map(((name, value)) => {
        let kind =
          dimensions
          ->Array.find(dimension => dimension.name == name)
          ->Option.mapOr(StringValue, getDimensionValueKind)
        <div key=name className="flex items-center gap-3">
          <span className={`${body.md.medium} text-nd_gray-600 w-40 shrink-0`}>
            {name->getDimensionDisplayName->React.string}
          </span>
          <div className="flex-1">
            <ValueEditor
              name={`condition-${name}`}
              kind
              draft=value
              setDraft={value => setConditionValue(name, value)}
              disabled
            />
          </div>
          <ActionIcon
            iconName="nd-delete-dustbin-02"
            description="Remove condition"
            isDisabled=disabled
            onClick={() =>
              setConditions(prev =>
                prev->Array.filter(((conditionName, _)) => conditionName != name)
              )}
          />
        </div>
      })
      ->React.array}
      <RenderIf condition={availableNames->isNonEmptyArray && !disabled}>
        <div className="w-60">
          <SingleSelectWrapper
            items={availableNames
            ->toDropdownOptions
            ->SingleSelectWrapper.makeItems(~selectedValue="")}
            placeholder="Add condition"
            input={makeInput(~name="add-condition", ~value=""->JSON.Encode.string, ~onChange=ev => {
              let name = ev->Identity.formReactEventToString
              if name->isNonEmptyString {
                setConditions(prev => prev->Array.concat([(name, "")]))
              }
            })}
            enableSearch=true
          />
        </div>
      </RenderIf>
    </div>
  }
}

let parseConditions = (~dimensions: array<dimension>, conditions: array<(string, string)>) =>
  conditions->Array.reduce(Ok([]), (acc, (name, draft)) =>
    switch acc {
    | Error(_) => acc
    | Ok(parsed) => {
        let kind =
          dimensions
          ->Array.find(dimension => dimension.name == name)
          ->Option.mapOr(StringValue, getDimensionValueKind)
        switch (draft->isEmptyString, kind->draftToValue(draft)) {
        | (true, _) => Error(`Enter a value for ${name->getDimensionDisplayName}`)
        | (false, Ok(value)) => Ok(parsed->Array.concat([(name, value)]))
        | (false, Error(message)) => Error(`${name->getDimensionDisplayName}: ${message}`)
        }
      }
    }
  )

let getExnMessage = (error, fallback) =>
  switch error {
  | Exn.Error(e) => Exn.message(e)->Option.getOr(fallback)
  | _ => fallback
  }

// A collapsible block with a header row. Unlike LoadedTable's collapsible rows, which keep
// a snapshot of the expanded content, its children re-render with the page.
module ExpandableSection = {
  @react.component
  let make = (
    ~title: React.element,
    ~meta,
    ~isExpanded,
    ~onToggle,
    ~isSelected=?,
    ~isPartiallySelected=false,
    ~onSelect=?,
    ~children,
  ) => {
    <div className="border border-nd_gray-150 rounded-lg overflow-hidden">
      <div
        className="flex items-center gap-3 px-4 py-3 cursor-pointer hover:bg-nd_gray-25"
        onClick={_ => onToggle()}>
        {switch (isSelected, onSelect) {
        | (Some(isSelected), Some(onSelect)) =>
          <div
            className="flex items-center"
            onClick={ev => {
              ev->ReactEvent.Mouse.stopPropagation
              onSelect(!isSelected)
            }}>
            <CheckBoxIconAdapter
              isSelected={isSelected || isPartiallySelected}
              isSelectedStateMinus={!isSelected && isPartiallySelected}
              checkboxDimension="h-4 w-4"
            />
          </div>
        | _ => React.null
        }}
        <Icon
          name={isExpanded ? "caret-down" : "caret-right"} size=14 className="text-nd_gray-500"
        />
        <div className="flex-1 min-w-0"> title </div>
        <span className={`${body.sm.medium} text-nd_gray-500 shrink-0`}>
          {meta->React.string}
        </span>
      </div>
      <RenderIf condition=isExpanded>
        <div className="border-t border-nd_gray-150"> children </div>
      </RenderIf>
    </div>
  }
}

module HowItWorks = {
  @react.component
  let make = (~storageKey, ~heading, ~linkText, ~children) => {
    let storageKey = `superposition_help_${storageKey}`
    let (isHidden, setIsHidden) = React.useState(_ =>
      LocalStorage.getItem(storageKey)->Nullable.toOption != Some("shown")
    )
    let setHidden = hidden => {
      hidden ? LocalStorage.removeItem(storageKey) : LocalStorage.setItem(storageKey, "shown")
      setIsHidden(_ => hidden)
    }

    isHidden
      ? <div
          className={`flex items-center gap-1.5 w-fit cursor-pointer ${body.md.medium} text-nd_primary_blue-500`}
          onClick={_ => setHidden(false)}>
          <Icon name="nd-info-circle" size=14 />
          {linkText->React.string}
        </div>
      : <div
          className="flex flex-col gap-3 border border-nd_primary_blue-200 bg-nd_primary_blue-50 rounded-xl px-5 py-4">
          <div className="flex items-center justify-between gap-4">
            <div className="flex items-center gap-2">
              <Icon name="nd-info-circle" size=16 className="text-nd_primary_blue-500" />
              <span className={`${body.md.semibold} text-nd_gray-800`}>
                {heading->React.string}
              </span>
            </div>
            <span
              className={`${body.sm.medium} text-nd_primary_blue-500 cursor-pointer shrink-0`}
              onClick={_ => setHidden(true)}>
              {"Hide"->React.string}
            </span>
          </div>
          children
        </div>
  }
}

module Term = {
  @react.component
  let make = (~term, ~children) =>
    <div className={`flex gap-2 ${body.md.regular} text-nd_gray-600`}>
      <span className={`${body.md.semibold} text-nd_gray-800 shrink-0 w-32`}>
        {term->React.string}
      </span>
      <span> children </span>
    </div>
}
