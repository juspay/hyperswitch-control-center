open LogicUtils
open RuleBasedUtils
open Typography
open RuleBasedTypes

let boxBtnStyle = "!bg-transparent !border-0 !shadow-none !rounded-lg !px-3 !py-2.5 !w-full"
let boxTextStyle = `${body.md.medium} text-nd_gray-600`
let boxInputStyle = `!border-0 !bg-transparent !shadow-none !px-3 !py-2.5 ${boxTextStyle}`
let boxSelect = (~options, ~buttonText) =>
  InputFields.selectInput(~options, ~buttonText, ~showBorder=false)
let boxMultiSelect = (~options, ~buttonText) =>
  InputFields.multiSelectInput(
    ~options,
    ~buttonText,
    ~showBorder=false,
    ~buttonType=Button.Transparent,
    ~fullLength=true,
    ~showSelectionAsChips=false,
    ~hideMultiSelectButtons=true,
    ~customButtonStyle=boxBtnStyle,
  )

module GuideCard = {
  @react.component
  let make = () => {
    let row = (icon, text) => {
      <div className="flex items-start gap-3">
        <div
          className="shrink-0 w-7 h-7 rounded-lg bg-nd_primary_blue-50 flex items-center justify-center">
          <Icon name=icon size={14} className="text-nd_primary_blue-500" />
        </div>
        <span className={`${body.sm.regular} text-nd_gray-600`}> {text->React.string} </span>
      </div>
    }

    <div className="border border-nd_gray-200 rounded-xl p-5 flex flex-col gap-4 bg-nd_gray-25">
      <span className={`${body.md.semibold} text-nd_gray-800`}>
        {"Guide to creating rules"->React.string}
      </span>
      {row(
        "info-circle",
        "Rules are processed in order from top to bottom. If Rule 1 doesn't match, it moves to Rule 2, and so on.",
      )}
      {row("check", "Inside each condition group: ALL conditions must be true (AND).")}
      {row("check-circle", "Between condition groups: ANY group can be true (OR).")}
    </div>
  }
}

module DetailsFields = {
  @react.component
  let make = () => {
    let nameField = FormRenderer.makeFieldInfo(
      ~label="Configuration Name",
      ~name="name",
      ~placeholder="e.g. US-card-routing",
      ~isRequired=true,
      ~customInput=InputFields.textInput(~autoFocus=true),
    )
    let descriptionField = FormRenderer.makeFieldInfo(
      ~label="Description",
      ~name="description",
      ~placeholder="Describe what this configuration does",
      ~isRequired=true,
      ~customInput=InputFields.multiLineTextInput(
        ~isDisabled=false,
        ~rows=Some(3),
        ~cols=None,
        ~customClass=body.md.regular,
      ),
    )
    <div className="flex flex-col gap-2">
      <FormRenderer.FieldRenderer field=nameField />
      <FormRenderer.FieldRenderer field=descriptionField />
    </div>
  }
}

module FieldInput = {
  @react.component
  let make = (~prefix) => {
    let fieldOptions = React.useMemo(() => {
      let keys = try Window.getAllKeys() catch {
      | _ => []
      }

      let convertedValue = try {
        Window.getDescriptionCategory()->Identity.jsonToAnyType->convertMapObjectToDict
      } catch {
      | _ => Dict.make()
      }

      convertedValue
      ->Dict.keysToArray
      ->Array.flatMap(category =>
        convertedValue
        ->getArrayFromDict(category, [])
        ->Array.filterMap(
          value => {
            let dictValue = value->getDictFromJsonObject
            let kindValue = dictValue->getString("kind", "")
            keys->Array.includes(kindValue)
              ? Some(
                  (
                    {
                      label: kindValue,
                      value: kindValue,
                      description: dictValue->getString("description", ""),
                      optGroup: category,
                    }: SelectBox.dropdownOption
                  ),
                )
              : None
          },
        )
      )
    }, [])

    let comparisonInput = ReactFinalForm.useField(`${prefix}.comparison`).input
    let valueInput = ReactFinalForm.useField(`${prefix}.value`).input

    <div className="flex items-center bg-white rounded-lg shadow-sm">
      <FormRenderer.FieldRenderer
        field={FormRenderer.makeFieldInfo(~name=`${prefix}.lhs`, ~label="field", ~customInput=(
          ~input,
          ~placeholder as _,
        ) => {
          let inputWithReset = {
            ...input,
            onChange: ev => {
              input.onChange(ev)
              let choice = ev->Identity.formReactEventToString->defaultOperatorChoiceForLhs
              comparisonInput.onChange(
                choice.comparison->operatorToBEKey->Identity.stringToFormReactEvent,
              )
              valueInput.onChange(choice.valueVariant->Identity.anyTypeToReactEvent)
            },
          }
          boxSelect(~options=fieldOptions, ~buttonText="Select Field")(
            ~input=inputWithReset,
            ~placeholder="",
          )
        })}
        fieldWrapperClass="!p-0"
      />
    </div>
  }
}

module OperatorInput = {
  @react.component
  let make = (~prefix) => {
    let lhs = ReactFinalForm.useField(`${prefix}.lhs`).input.value->getStringFromJson("")
    let comparisonInput = ReactFinalForm.useField(`${prefix}.comparison`).input
    let valueInput = ReactFinalForm.useField(`${prefix}.value`).input
    let valueType =
      ReactFinalForm.useField(`${prefix}.value.type`).input.value->getStringFromJson("")
    let choices = operatorChoicesForLhs(lhs)
    let options = choices->Array.map((c): SelectBox.dropdownOption => {
      label: c.label,
      value: (c.selectValue :> string),
    })
    let comparison = comparisonInput.value->getStringFromJson("")
    let selectValue = selectedOperatorValue(~choices, ~comparison, ~valueType)

    let dropdownInput = {
      ...comparisonInput,
      value: (selectValue :> string)->JSON.Encode.string,
      onChange: ev =>
        switch choices->Array.find(c =>
          (c.selectValue :> string) === ev->Identity.formReactEventToString
        ) {
        | Some(c) =>
          comparisonInput.onChange(c.comparison->operatorToBEKey->Identity.stringToFormReactEvent)
          valueInput.onChange(c.valueVariant->Identity.anyTypeToReactEvent)
        | None => ()
        },
    }

    <div className="flex items-center bg-white rounded-lg shadow-sm">
      {boxSelect(~options, ~buttonText="Select Operator")(~input=dropdownInput, ~placeholder="")}
    </div>
  }
}

module ValueInput = {
  @react.component
  let make = (~prefix) => {
    let lhs = ReactFinalForm.useField(`${prefix}.lhs`).input.value->getStringFromJson("")
    let enumArrayType =
      EnumMany({value: []})
      ->Identity.genericTypeToJson
      ->getDictFromJsonObject
      ->getString("type", "")
    let valueType =
      ReactFinalForm.useField(`${prefix}.value.type`).input.value->getStringFromJson("")
    let variantType = variantTypeOfLhs(lhs)
    let isMetadata = variantType->isMetadataValue

    let variantOptions = try {
      Window.getVariantValues(lhs)
    } catch {
    | _ => []
    }

    let valueCustomInput = switch variantType {
    | EnumOne(_) | EnumMany(_) =>
      valueType === enumArrayType
        ? boxMultiSelect(
            ~options=variantOptions->SelectBox.makeOptions,
            ~buttonText="Select values",
          )
        : InputFields.selectInput(
            ~options=variantOptions->SelectBox.makeOptions,
            ~buttonText="Select Value",
            ~showBorder=false,
            ~buttonType=Button.Transparent,
            ~fullLength=true,
            ~customButtonStyle=boxBtnStyle,
            ~textStyle=boxTextStyle,
          )
    | Number(_) => InputFields.numericTextInput(~customStyle=boxInputStyle)
    | StrValue(_) =>
      lhs->isCardBinField
        ? InputFields.numericTextInput(
            ~customStyle=boxInputStyle,
            ~maxLength={lhs === "extended_card_bin" ? 8 : 6},
          )
        : InputFields.textInput(~customStyle=boxInputStyle)
    | MetadataValue(_) => InputFields.textInput(~customStyle=boxInputStyle)
    }

    <div className="flex items-center bg-white rounded-lg shadow-sm">
      <FormRenderer.FieldRenderer
        field={FormRenderer.makeFieldInfo(
          ~name={isMetadata ? `${prefix}.value.value.value` : `${prefix}.value.value`},
          ~label="",
          ~placeholder="Enter value",
          ~customInput=valueCustomInput,
        )}
        fieldWrapperClass="!p-0"
      />
    </div>
  }
}

module MetadataKeyInput = {
  @react.component
  let make = (~prefix) => {
    let lhs = ReactFinalForm.useField(`${prefix}.lhs`).input.value->getStringFromJson("")
    let isMetadata = lhs->variantTypeOfLhs->isMetadataValue

    <RenderIf condition={isMetadata}>
      <div className="flex items-center bg-white rounded-lg shadow-sm">
        <FormRenderer.FieldRenderer
          field={FormRenderer.makeFieldInfo(
            ~name=`${prefix}.value.value.key`,
            ~label="",
            ~placeholder="Enter key",
            ~customInput=InputFields.textInput(~customStyle=boxInputStyle),
          )}
          fieldWrapperClass="!p-0"
        />
      </div>
    </RenderIf>
  }
}

module ConditionWrapper = {
  @react.component
  let make = (~prefix, ~index, ~onRemove, ~canRemove) => {
    let isFirst = index == 0
    let pillLabelText = isFirst ? "IF" : "AND"
    let pillClass = isFirst
      ? "bg-nd_green-150 text-nd_green-400"
      : "bg-nd_primary_blue-50 text-nd_primary_blue-500"
    <div className="flex items-center gap-4">
      <span
        className={`${body.sm.semibold} ${pillClass} w-12 text-center px-2 py-1 rounded-md shrink-0`}>
        {pillLabelText->React.string}
      </span>
      <div
        className="flex-1 flex items-center justify-between bg-nd_gray-25 border border-nd_gray-50 rounded-lg px-4 py-3 min-w-0">
        <LabelVisibilityContext.Provider value={false}>
          <div className="flex items-center gap-4 min-w-0">
            <FieldInput prefix />
            <MetadataKeyInput prefix />
            <OperatorInput prefix />
            <ValueInput prefix />
          </div>
        </LabelVisibilityContext.Provider>
        <RenderIf condition={canRemove}>
          <Icon
            name="close"
            size={16}
            className="text-nd_gray-400 cursor-pointer shrink-0 ml-3"
            onClick={_ => onRemove()}
          />
        </RenderIf>
      </div>
    </div>
  }
}
module ConditionGroupWrapper = {
  @react.component
  let make = (~prefix, ~groupIndex, ~isLast, ~isOnlyGroup, ~onAddGroup, ~onRemoveGroup) => {
    let conditionsInput = ReactFinalForm.useField(`${prefix}.condition`).input
    let conditions = conditionsInput.value->getArrayFromJson([])
    let setConditions = arr =>
      conditionsInput.onChange(arr->Identity.arrayOfGenericTypeToFormReactEvent)

    let addCondition = () =>
      setConditions(conditions->Array.concat([defaultCondition->Identity.genericTypeToJson]))
    let removeCondition = index =>
      setConditions(conditions->Array.filterWithIndex((_, i) => i !== index))
    <>
      <RenderIf condition={groupIndex > 0}>
        <div className="flex justify-center my-3">
          <TagBinding text={"OR"} color=Purple variant=Subtle shape=Squarical size=Xs />
        </div>
      </RenderIf>
      {conditions
      ->Array.mapWithIndex((_, index) =>
        <ConditionWrapper
          key={index->Int.toString}
          prefix={`${prefix}.condition[${index->Int.toString}]`}
          index
          onRemove={() => removeCondition(index)}
          canRemove={conditions->Array.length > 1}
        />
      )
      ->React.array}
      <div className="flex items-center gap-6 pl-1">
        <Button
          text="Add condition"
          buttonType=Button.FilterAdd
          buttonSize=Small
          textStyle="text-nd_primary_blue-500"
          leftIcon={CustomIcon(
            <Icon name="nd-corner-down-left" size=16 className="text-nd_primary_blue-500" />,
          )}
          onClick={_ => addCondition()}
        />
        <RenderIf condition={isLast}>
          <Button
            text="Add condition group"
            buttonType=Button.FilterAdd
            buttonSize=Small
            textStyle="text-nd_primary_blue-500"
            leftIcon={CustomIcon(
              <Icon name="nd-plus" size=14 className="text-nd_primary_blue-500" />,
            )}
            onClick={_ => onAddGroup()}
          />
        </RenderIf>
        <RenderIf condition={!isOnlyGroup}>
          <div className="ml-auto">
            <Button
              text="Delete"
              buttonType=Button.FilterAdd
              buttonSize=Small
              textStyle="text-nd_gray-500"
              leftIcon={CustomIcon(<Icon name="trash" size=14 className="text-nd_gray-500" />)}
              onClick={_ => onRemoveGroup()}
            />
          </div>
        </RenderIf>
      </div>
    </>
  }
}

module OutcomeWrapper = {
  @react.component
  let make = (~prefix) => {
    let url = RescriptReactRouter.useUrl()
    let connectorType: ConnectorTypes.connectorTypeVariants = switch url->RoutingUtils.urlToVariantMapper {
    | PayoutRouting => ConnectorTypes.PayoutProcessor
    | _ => ConnectorTypes.PaymentProcessor
    }
    let connectorList = ConnectorListInterface.useFilteredConnectorList(~retainInList=connectorType)

    let gatewayOptions = connectorList->Array.map((c): SelectBox.dropdownOption => {
      label: c.disabled ? `${c.connector_label} (disabled)` : c.connector_label,
      value: c.id,
    })

    let selectionInput = ReactFinalForm.useField(`${prefix}.connectorSelection`).input
    let selection: connectorSelection = selectionInput.value->connectorSelectionFromJson
    let ids = selection->idsFromConnectorSelection
    let isDistribute = switch selection {
    | VolumeSplit(_) => true
    | Priority(_) => false
    }
    let setSelection = (sel: connectorSelection) =>
      selectionInput.onChange(sel->Identity.anyTypeToReactEvent)

    let removeId = i =>
      setSelection(
        connectorList->connectorSelectionFromIds(
          ~isDistribute,
          ids->Array.filterWithIndex((_, idx) => idx !== i),
        ),
      )

    let dropdownInput: ReactFinalForm.fieldRenderPropsInput = {
      name: `${prefix}.connectorSelection`,
      onBlur: _ => (),
      onFocus: _ => (),
      checked: true,
      value: ids->Array.map(JSON.Encode.string)->JSON.Encode.array,
      onChange: ev =>
        setSelection(
          connectorList->connectorSelectionFromIds(
            ~isDistribute,
            ev->Identity.formReactEventToArrayOfString,
          ),
        ),
    }

    <div className="bg-nd_gray-25 border border-nd_gray-150 rounded-lg p-4 flex flex-col gap-4">
      <div className="flex items-center gap-3">
        <Icon name="nd-corner-down-right" size=16 className="text-nd_gray-400 shrink-0" />
        <span className={`${body.md.medium} text-nd_gray-500 shrink-0`}>
          {(
            connectorType == ConnectorTypes.PayoutProcessor
              ? "Route payouts to"
              : "Route payments to"
          )->React.string}
        </span>
        <div className="flex-1 min-w-0">
          <SelectBoxAdapter.BaseDropdown
            allowMultiSelect=true
            buttonText="Select processors"
            buttonType=Button.SecondaryFilled
            hideMultiSelectButtons=true
            customButtonStyle="!bg-white !w-full !border !border-nd_gray-200 !rounded-lg"
            input=dropdownInput
            options={gatewayOptions}
            searchable=true
            maxHeight="max-h-full sm:max-h-64"
          />
        </div>
      </div>
      <RenderIf condition={ids->Array.length > 0}>
        <div className="flex flex-wrap gap-2 items-center">
          {ids
          ->Array.mapWithIndex((mcaId, i) =>
            <div
              key={i->Int.toString}
              className="flex items-center gap-2 rounded-lg border border-nd_gray-200 bg-nd_gray-25 px-3 py-1.5">
              <span className={`${body.sm.semibold} text-nd_primary_blue-500`}>
                {(i + 1)->Int.toString->React.string}
              </span>
              <span className={`${body.sm.medium} text-nd_gray-700`}>
                {connectorList->connectorLabelFromId(mcaId)->React.string}
              </span>
              <RenderIf condition={isDistribute}>
                <div className="flex items-center gap-1">
                  <FormRenderer.FieldRenderer
                    field={FormRenderer.makeFieldInfo(
                      ~name=`${prefix}.connectorSelection.data[${i->Int.toString}].split`,
                      ~label="",
                      ~placeholder="0",
                      ~customInput=InputFields.numericTextInput(
                        ~customStyle=`!w-12 !px-1.5 !py-1 text-right ${body.sm.regular} text-nd_gray-700`,
                        ~maxLength=3,
                      ),
                    )}
                    fieldWrapperClass="!p-0"
                  />
                  <span className={`${body.sm.regular} text-nd_gray-500`}>
                    {"%"->React.string}
                  </span>
                </div>
              </RenderIf>
              <Icon
                name="close"
                size=12
                className="text-nd_gray-400 cursor-pointer"
                onClick={ev => {
                  ev->ReactEvent.Mouse.stopPropagation
                  removeId(i)
                }}
              />
            </div>
          )
          ->React.array}
        </div>
      </RenderIf>
      <RenderIf condition={ids->Array.length > 0}>
        <div className="flex items-center gap-2">
          <CheckBoxIconAdapter
            isSelected=isDistribute
            setIsSelected={v =>
              setSelection(connectorList->connectorSelectionFromIds(~isDistribute=v, ids))}
            isDisabled=false
          />
          <span className={`${body.sm.regular} text-nd_gray-600`}>
            {"Distribute volume equally across processors"->React.string}
          </span>
        </div>
      </RenderIf>
    </div>
  }
}

module RuleWrapper = {
  @react.component
  let make = (~prefix, ~heading, ~onCopy, ~onRemove) => {
    let (isExpanded, setIsExpanded) = React.useState(_ => true)
    let rotateCss = isExpanded ? "" : "-rotate-90"
    let statementsInput = ReactFinalForm.useField(`${prefix}.statements`).input
    let statements = statementsInput.value->getArrayFromJson([])
    let setStatements = arr => {
      statementsInput.onChange(arr->Identity.arrayOfGenericTypeToFormReactEvent)
    }
    let addGroup = () =>
      setStatements(statements->Array.concat([defaultGroup->Identity.genericTypeToJson]))
    let removeGroup = index =>
      setStatements(statements->Array.filterWithIndex((_, i) => i !== index))
    let lastIndex = statements->Array.length - 1

    <div className="border border-nd_gray-200 rounded-xl my-4 overflow-hidden bg-white">
      <div className="flex items-center gap-2 bg-nd_gray-50 px-4 py-4 border-b border-nd_gray-200">
        <Icon name="grip-vertical" size={16} className="text-nd_gray-400 cursor-grab" />
        <span className={`${body.md.semibold} text-nd_gray-800`}> {heading->React.string} </span>
        <Icon
          name="chevron-down"
          size={16}
          className={`text-nd_gray-600 cursor-pointer ${rotateCss}`}
          onClick={_ => setIsExpanded(p => !p)}
        />
        <div className="ml-auto flex gap-4">
          <Icon
            name="nd-copy"
            size={16}
            className="text-nd_gray-500 cursor-pointer"
            onClick={_ => onCopy()}
          />
          <Icon
            name="trash"
            size={16}
            className="text-nd_red-500 cursor-pointer"
            onClick={_ => onRemove()}
          />
        </div>
      </div>
      <RenderIf condition=isExpanded>
        <div className="flex flex-col gap-6 px-4 pt-4 pb-6">
          <div className="flex flex-col gap-4">
            <p className={`${body.md.medium} text-nd_gray-600`}>
              {"If any of these apply"->React.string}
            </p>
            <div className="border border-nd_gray-150 rounded-lg bg-white p-4 flex flex-col gap-4">
              {statements
              ->Array.mapWithIndex((_, index) => {
                <ConditionGroupWrapper
                  key={index->Int.toString}
                  prefix={`${prefix}.statements[${index->Int.toString}]`}
                  onAddGroup=addGroup
                  onRemoveGroup={_ => removeGroup(index)}
                  groupIndex=index
                  isLast={lastIndex == index}
                  isOnlyGroup={statements->Array.length == 1}
                />
              })
              ->React.array}
            </div>
          </div>
          <div className="flex flex-col gap-4">
            <p className={`${body.lg.medium} text-nd_gray-600`}> {"then...."->React.string} </p>
            <OutcomeWrapper prefix />
          </div>
        </div>
      </RenderIf>
    </div>
  }
}

module OutcomePreview = {
  @react.component
  let make = (~connectorSelection: JSON.t, ~connectorList) => {
    let dataArr = connectorSelection->getDictFromJsonObject->getArrayFromDict("data", [])
    <div className="flex flex-wrap gap-2 items-center">
      {dataArr
      ->Array.mapWithIndex((item, i) => {
        let itemDict = item->getDictFromJsonObject
        let (mcaId, splitOpt) = switch itemDict->Dict.get("connector") {
        | Some(c) if c->JSON.Decode.object->Option.isSome => (
            c->getDictFromJsonObject->getString("merchant_connector_id", ""),
            Some(itemDict->getInt("split", 0)),
          )
        | _ => (itemDict->getString("merchant_connector_id", ""), None)
        }
        <div
          key={i->Int.toString}
          className="flex items-center gap-1.5 rounded-lg border border-nd_gray-200 bg-white px-3 py-1.5">
          <span className={`${body.sm.medium} text-nd_gray-700`}>
            {connectorList->connectorLabelFromId(mcaId)->React.string}
          </span>
          <RenderIf condition={splitOpt->Option.isSome}>
            <span className={`${body.sm.regular} text-nd_gray-500`}>
              {`${splitOpt->Option.getOr(0)->Int.toString}%`->React.string}
            </span>
          </RenderIf>
        </div>
      })
      ->React.array}
    </div>
  }
}

module ConditionSummaryView = {
  @react.component
  let make = (~cond: JSON.t, ~condIndex) => {
    let condDict = cond->getDictFromJsonObject
    let lhs = condDict->getString("lhs", "")
    let cmpStr = condDict->getString("comparison", "")
    let valueDict = condDict->getDictfromDict("value")
    let vType = valueDict->getString("type", "")
    let valueJson = valueDict->Dict.get("value")->Option.getOr(JSON.Encode.null)
    let opLabel = operatorLabelForStoredValue(~lhs, ~comparison=cmpStr, ~valueType=vType)
    let metaKey =
      vType === "metadata_variant" ? valueJson->getDictFromJsonObject->getString("key", "") : ""
    let valueText = switch valueJson->JSON.Classify.classify {
    | Array(arr) => arr->Array.joinWithUnsafe(", ")
    | String(s) => s
    | Number(n) => n->Float.toString
    | Object(o) => o->getString("value", "")
    | _ => ""
    }

    <div key={condIndex->Int.toString} className="flex flex-wrap items-center gap-1.5">
      <RenderIf condition={condIndex > 0}>
        <span className={`${body.sm.semibold} text-nd_gray-500`}> {"AND"->React.string} </span>
      </RenderIf>
      <span className={`${body.sm.medium} text-nd_gray-700`}> {lhs->React.string} </span>
      <RenderIf condition={metaKey->isNonEmptyString}>
        <span className={`${body.sm.medium} text-nd_gray-700`}> {metaKey->React.string} </span>
      </RenderIf>
      <span className={`${body.sm.semibold} text-nd_primary_blue-500`}>
        {opLabel->React.string}
      </span>
      <span className={`${body.sm.medium} text-nd_gray-700`}> {valueText->React.string} </span>
    </div>
  }
}

module RuleSummary = {
  @react.component
  let make = (~rule: JSON.t, ~index, ~connectorList) => {
    let ruleDict = rule->getDictFromJsonObject
    let name = ruleDict->getString("name", "")
    let ruleNo = (index + 1)->Int.toString
    let headingText = name->isNonEmptyString ? `Rule ${ruleNo} · ${name}` : `Rule ${ruleNo}`
    let statements = ruleDict->getArrayFromDict("statements", [])
    let connectorSelection =
      ruleDict->Dict.get("connectorSelection")->Option.getOr(Dict.make()->JSON.Encode.object)

    <div className="border border-nd_gray-200 rounded-xl bg-white p-4 flex flex-col gap-3">
      <span className={`${body.md.semibold} text-nd_gray-800`}> {headingText->React.string} </span>
      <div className="flex flex-wrap items-center gap-3">
        <div className="flex flex-wrap items-center gap-2">
          {statements
          ->Array.mapWithIndex((stmt, si) => {
            let conditions = stmt->getDictFromJsonObject->getArrayFromDict("condition", [])
            <div key={si->Int.toString} className="flex flex-wrap items-center gap-2">
              <RenderIf condition={si > 0}>
                <TagBinding text={"OR"} color=Purple variant=Subtle shape=Squarical size=Xs />
              </RenderIf>
              <div
                className="flex flex-wrap items-center gap-2 rounded-lg bg-nd_gray-25 border border-nd_gray-50 px-3 py-2">
                {conditions
                ->Array.mapWithIndex((cond, ci) => <ConditionSummaryView cond condIndex=ci />)
                ->React.array}
              </div>
            </div>
          })
          ->React.array}
        </div>
        <Icon name="arrow-right" size=16 className="text-nd_gray-400 shrink-0" />
        <OutcomePreview connectorSelection connectorList />
      </div>
    </div>
  }
}

module PreviewView = {
  @react.component
  let make = (~values: JSON.t) => {
    let url = RescriptReactRouter.useUrl()
    let connectorType: ConnectorTypes.connectorTypeVariants = switch url->RoutingUtils.urlToVariantMapper {
    | PayoutRouting => ConnectorTypes.PayoutProcessor
    | _ => ConnectorTypes.PaymentProcessor
    }
    let connectorList = ConnectorListInterface.useFilteredConnectorList(~retainInList=connectorType)

    let dict = values->getDictFromJsonObject
    let name = dict->getString("name", "")
    let description = dict->getString("description", "")
    let data = dict->getDictFromNestedDict("algorithm", "data")
    let rules = data->getArrayFromDict("rules", [])
    let defaultSelection =
      data->Dict.get("defaultSelection")->Option.getOr(Dict.make()->JSON.Encode.object)

    <div className="flex flex-col gap-4">
      <div className="flex flex-col gap-1">
        <span className={`${heading.sm.semibold} text-nd_gray-800`}> {name->React.string} </span>
        <RenderIf condition={description->isNonEmptyString}>
          <span className={`${body.sm.regular} text-nd_gray-600`}>
            {description->React.string}
          </span>
        </RenderIf>
      </div>
      {rules
      ->Array.mapWithIndex((rule, i) =>
        <RuleSummary key={i->Int.toString} rule index=i connectorList />
      )
      ->React.array}
      <div className="border border-nd_gray-200 rounded-xl bg-nd_gray-25 p-4 flex flex-col gap-2">
        <span className={`${body.md.semibold} text-nd_gray-800`}>
          {"Fallback (when no rule matches)"->React.string}
        </span>
        <OutcomePreview connectorSelection=defaultSelection connectorList />
      </div>
    </div>
  }
}
