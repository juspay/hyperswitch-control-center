open SuperpositionTypes
open SuperpositionUtils
open SuperpositionHelper
open LogicUtils
open Typography

let modalClass = "w-full max-w-2xl mx-auto my-auto dark:!bg-jp-gray-lightgray_background"

module Footer = {
  @react.component
  let make = (
    ~onCancel,
    ~onSave,
    ~saveText,
    ~isSaving,
    ~canSave,
    ~onRemove=?,
    ~removeText="",
    ~canRemove=true,
  ) => {
    <div className="flex items-center justify-between gap-3 pt-2">
      <div>
        {switch onRemove {
        | Some(onRemove) =>
          <Button
            text=removeText
            buttonType=Delete
            buttonState={isSaving || !canRemove ? Disabled : Normal}
            onClick={_ => onRemove()}
            customButtonStyle="!w-fit"
          />
        | None => React.null
        }}
      </div>
      <div className="flex items-center gap-3">
        <Button
          text="Cancel" buttonType=Secondary onClick={_ => onCancel()} customButtonStyle="!w-fit"
        />
        <Button
          text=saveText
          buttonType=Primary
          buttonState={isSaving ? Loading : canSave ? Normal : Disabled}
          onClick={_ => onSave()}
          customButtonStyle="!w-fit"
        />
      </div>
    </div>
  }
}

module SpecializationModal = {
  @react.component
  let make = (
    ~showModal,
    ~setShowModal,
    ~heading,
    ~description="",
    ~rows: array<configRow>,
    ~dimensions: array<dimension>,
    ~allowConditions=true,
    ~requireConditions=false,
    ~existingContext: option<context>=?,
    ~saveText="Save",
    ~removeText="Remove specialization",
    ~onSaved,
  ) => {
    let api = SuperpositionHooks.useSuperpositionApi()
    let scope = SuperpositionHooks.useScope()
    let showToast = ToastAdapter.useShowToast()
    let (isSaving, setIsSaving) = React.useState(_ => false)
    let (reason, setReason) = React.useState(_ => "")
    let (errorMessage, setErrorMessage) = React.useState(_ => None)

    let initialValue = (row: configRow) =>
      existingContext
      ->Option.flatMap(context => context.override->Dict.get(row.key))
      ->Option.getOr(row.value)

    let (drafts, setDrafts) = React.useState(_ =>
      rows->Array.map(row => (row.key, row.kind->valueToDraft(row->initialValue)))->Dict.fromArray
    )
    let (conditions, setConditions) = React.useState(_ =>
      existingContext->Option.mapOr([], context =>
        context.condition
        ->getExtraConditions(scope)
        ->Dict.toArray
        ->Array.map(((name, value)) => (name, value->formatDimensionValue))
      )
    )

    let setDraft = (key, draft) =>
      setDrafts(prev => {
        let next = prev->Dict.copy
        next->Dict.set(key, draft)
        next
      })

    let parsedValues =
      rows->Array.map(row => (
        row,
        row.kind->draftToValue(drafts->Dict.get(row.key)->Option.getOr("")),
      ))
    let firstValueError = parsedValues->Array.findMap(((row, parsed)) =>
      switch parsed {
      | Error(message) => Some(`${row.key}: ${message}`)
      | Ok(_) => None
      }
    )

    let closeModal = () => setShowModal(_ => false)

    let runWrite = async (write, successMessage) => {
      setIsSaving(_ => true)
      setErrorMessage(_ => None)
      try {
        await write()
        showToast(~message=successMessage, ~toastType=ToastSuccess)
        closeModal()
        onSaved()
      } catch {
      | error => setErrorMessage(_ => Some(error->getExnMessage("Could not save the change")))
      }
      setIsSaving(_ => false)
    }

    let reasonResult = reason->validateChangeReason
    let hasValidReason = reasonResult->Result.isOk

    let onSave = () => {
      switch (firstValueError, conditions->parseConditions(~dimensions), reasonResult) {
      | (Some(message), _, _) | (None, Error(message), _) | (None, Ok(_), Error(message)) =>
        setErrorMessage(_ => Some(message))
      | (None, Ok([]), Ok(_)) if requireConditions && existingContext->Option.isNone =>
        setErrorMessage(_ => Some(
          "Add at least one condition. Without one, this is a custom value.",
        ))
      | (None, Ok(extraConditions), Ok(changeReason)) => {
          let extra = extraConditions->Dict.fromArray
          let override =
            parsedValues
            ->Array.filterMap(((row, parsed)) =>
              switch parsed {
              | Ok(value) => Some((row.key, value))
              | Error(_) => None
              }
            )
            ->Dict.fromArray
          let condition = switch existingContext {
          | Some(context) => context.condition
          | None => scope->mergeConditions(extra)
          }
          let contextDescription = switch extra->Dict.keysToArray {
          | [] => "Values for this level"
          | _ => `Specialization for ${extra->describeConditions}`
          }
          runWrite(
            () =>
              api.putContext(~condition, ~override, ~description=contextDescription, ~changeReason),
            extra->Dict.keysToArray->isEmptyArray ? "Custom value saved" : "Specialization saved",
          )->ignore
        }
      }
    }

    let onRemove = existingContext->Option.map(context => () =>
      switch reasonResult {
      | Error(message) => setErrorMessage(_ => Some(message))
      | Ok(changeReason) =>
        runWrite(
          () => api.removeKeys(~context, ~keys=rows->Array.map(row => row.key), ~changeReason),
          "Specialization removed",
        )->ignore
      })

    let isEditingExisting = existingContext->Option.isSome
    let appliedCondition = existingContext->Option.mapOr(scope, context => context.condition)

    <Modal
      modalHeading=heading
      modalHeadingDescription=description
      modalDescriptionClass={`${body.md.regular} text-nd_gray-500 mt-1`}
      showModal
      setShowModal
      modalClass
      childClass="p-6"
      borderBottom=true>
      <div className="flex flex-col gap-6 max-h-[70vh] overflow-y-auto">
        <div className="flex flex-col gap-3">
          <SectionLabel
            label="Applies to"
            hint={allowConditions && !isEditingExisting
              ? "The fixed scope is locked. Add conditions to narrow it further, for example to one connector."
              : "The fixed scope is locked."}
          />
          <ConditionChips condition=appliedCondition />
          <RenderIf condition={allowConditions && !isEditingExisting}>
            <ConditionsEditor dimensions conditions setConditions disabled=isSaving />
          </RenderIf>
        </div>
        <div className="flex flex-col gap-4">
          <SectionLabel label={rows->Array.length == 1 ? "Value" : "Values"} />
          {rows
          ->Array.map(row =>
            <div key=row.key className="flex flex-col gap-2">
              <div className="flex items-center gap-2">
                <span className={`${code.md.medium} text-nd_gray-700 break-all`}>
                  {row.key->React.string}
                </span>
                <KindBadge kind=row.kind />
              </div>
              <RenderIf condition={row.description->isNonEmptyString}>
                <span className={`${body.sm.regular} text-nd_gray-500`}>
                  {row.description->React.string}
                </span>
              </RenderIf>
              <ValueEditor
                name=row.key
                kind=row.kind
                draft={drafts->Dict.get(row.key)->Option.getOr("")}
                setDraft={draft => setDraft(row.key, draft)}
                disabled=isSaving
              />
            </div>
          )
          ->React.array}
        </div>
        <div className="flex flex-col gap-2">
          <ReasonInput reason setReason disabled=isSaving />
        </div>
        {switch errorMessage {
        | Some(message) =>
          <span className={`${body.md.medium} text-nd_red-500`}> {message->React.string} </span>
        | None => React.null
        }}
        <Footer
          onCancel=closeModal
          onSave
          saveText
          isSaving
          canSave={firstValueError->Option.isNone && hasValidReason}
          ?onRemove
          removeText
          canRemove=hasValidReason
        />
      </div>
    </Modal>
  }
}

module ReasonModal = {
  @react.component
  let make = (~heading, ~description, ~confirmText, ~onConfirm, ~onClose, ~children=React.null) => {
    let (reason, setReason) = React.useState(_ => "")
    let (isSaving, setIsSaving) = React.useState(_ => false)
    let (errorMessage, setErrorMessage) = React.useState(_ => None)
    let reasonResult = reason->validateChangeReason

    let confirm = async changeReason => {
      setIsSaving(_ => true)
      setErrorMessage(_ => None)
      try {
        await onConfirm(changeReason)
      } catch {
      | error => setErrorMessage(_ => Some(error->getExnMessage("Could not save the change")))
      }
      setIsSaving(_ => false)
    }

    <Modal
      modalHeading=heading
      modalHeadingDescription=description
      modalDescriptionClass={`${body.md.regular} text-nd_gray-500 mt-1`}
      showModal=true
      setShowModal={_ => onClose()}
      modalClass
      childClass="p-6"
      borderBottom=true>
      <div className="flex flex-col gap-6">
        children
        <ReasonInput reason setReason disabled=isSaving />
        {switch errorMessage {
        | Some(message) =>
          <span className={`${body.md.medium} text-nd_red-500`}> {message->React.string} </span>
        | None => React.null
        }}
        <Footer
          onCancel=onClose
          onSave={() =>
            switch reasonResult {
            | Ok(changeReason) => confirm(changeReason)->ignore
            | Error(message) => setErrorMessage(_ => Some(message))
            }}
          saveText=confirmText
          isSaving
          canSave={reasonResult->Result.isOk}
        />
      </div>
    </Modal>
  }
}

module RemoveSpecializationModal = {
  @react.component
  let make = (~entry: specializationEntry, ~onClose, ~onChanged) => {
    let api = SuperpositionHooks.useSuperpositionApi()
    let showToast = ToastAdapter.useShowToast()
    let (reason, setReason) = React.useState(_ => "")
    let (isSaving, setIsSaving) = React.useState(_ => false)
    let (errorMessage, setErrorMessage) = React.useState(_ => None)
    let {entryRow: row, spec} = entry
    let reasonResult = reason->validateChangeReason

    let remove = async changeReason => {
      setIsSaving(_ => true)
      setErrorMessage(_ => None)
      try {
        await api.removeKeys(~context=spec.context, ~keys=[row.key], ~changeReason)
        showToast(~message="Specialization removed", ~toastType=ToastSuccess)
        onClose()
        onChanged()
      } catch {
      | error =>
        setErrorMessage(_ => Some(error->getExnMessage("Could not remove the specialization")))
      }
      setIsSaving(_ => false)
    }

    <Modal
      modalHeading="Remove specialization"
      modalHeadingDescription={`${row.key} will no longer be set for these conditions.`}
      modalDescriptionClass={`${body.md.regular} text-nd_gray-500 mt-1`}
      showModal=true
      setShowModal={_ => onClose()}
      modalClass
      childClass="p-6"
      borderBottom=true>
      <div className="flex flex-col gap-6">
        <div className="flex flex-col gap-3">
          <SectionLabel label="Applies to" />
          <ConditionChips condition=spec.context.condition />
        </div>
        <div className="flex flex-col gap-2">
          <SectionLabel label="Current value" />
          <ValueText
            value={spec.context.override->Dict.get(row.key)->Option.getOr(JSON.Encode.null)}
          />
        </div>
        <ReasonInput reason setReason disabled=isSaving />
        {switch errorMessage {
        | Some(message) =>
          <span className={`${body.md.medium} text-nd_red-500`}> {message->React.string} </span>
        | None => React.null
        }}
        <div className="flex items-center justify-end gap-3 pt-2">
          <Button
            text="Cancel" buttonType=Secondary onClick={_ => onClose()} customButtonStyle="!w-fit"
          />
          <Button
            text="Remove"
            buttonType=Delete
            buttonState={isSaving ? Loading : reasonResult->Result.isOk ? Normal : Disabled}
            onClick={_ =>
              switch reasonResult {
              | Ok(changeReason) => remove(changeReason)->ignore
              | Error(message) => setErrorMessage(_ => Some(message))
              }}
            customButtonStyle="!w-fit"
          />
        </div>
      </div>
    </Modal>
  }
}

module ExplainTimeline = {
  @react.component
  let make = (~row: configRow, ~contexts) => {
    let api = SuperpositionHooks.useSuperpositionApi()
    let scope = SuperpositionHooks.useScope()
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
    let (steps, setSteps) = React.useState(_ => [])

    React.useEffect(() => {
      let load = async () => {
        try {
          let timeline = await api.explain(row.key)
          setSteps(_ => timeline->getOverridingSteps(~key=row.key, ~contexts))
          setScreenState(_ => PageLoaderWrapper.Success)
        } catch {
        | error =>
          setScreenState(_ => PageLoaderWrapper.Error(
            error->getExnMessage("Could not load the explanation"),
          ))
        }
      }
      load()->ignore
      None
    }, [row.key])

    let defaultValue =
      steps->Array.get(0)->Option.mapOr(row.inheritedValue, step => step.valueBefore)

    let stepCard = (~title, ~subtitle, ~value, ~isLast) =>
      <div className="flex gap-4">
        <div className="flex flex-col items-center shrink-0">
          <div
            className={`h-3 w-3 mt-1.5 rounded-full ${isLast
                ? "bg-nd_primary_blue-500"
                : "bg-nd_gray-300"}`}
          />
          <RenderIf condition={!isLast}>
            <div className="w-px flex-1 bg-nd_gray-200 mt-1" />
          </RenderIf>
        </div>
        <div className="flex flex-col gap-1 pb-5 min-w-0">
          <span className={`${body.md.semibold} text-nd_gray-700`}> {title->React.string} </span>
          <RenderIf condition={subtitle->isNonEmptyString}>
            <span className={`${body.sm.regular} text-nd_gray-500 break-all`}>
              {subtitle->React.string}
            </span>
          </RenderIf>
          <ValueText value />
        </div>
      </div>

    <PageLoaderWrapper screenState sectionHeight="h-40">
      <div className="flex flex-col max-h-[70vh] overflow-y-auto">
        {stepCard(
          ~title="Default",
          ~subtitle="Value before any level changes it",
          ~value=defaultValue,
          ~isLast=steps->Array.length == 0,
        )}
        {steps
        ->Array.mapWithIndex((step, index) =>
          <React.Fragment key=step.stepContextId>
            {stepCard(
              ~title={
                step.stepCondition->isThisLevel(scope)
                  ? "This level"
                  : step.stepCondition->getLevelLabel
              },
              ~subtitle=step.stepCondition->describeConditions,
              ~value=step.valueAfter,
              ~isLast=index == steps->Array.length - 1,
            )}
          </React.Fragment>
        )
        ->React.array}
      </div>
    </PageLoaderWrapper>
  }
}

module ExplainModal = {
  @react.component
  let make = (~showModal, ~setShowModal, ~row: configRow, ~contexts) =>
    <Modal
      modalHeading="How this value is resolved"
      modalHeadingDescription={row.key->getKeyLabel}
      modalDescriptionClass={`${body.md.regular} text-nd_gray-500 mt-1`}
      showModal
      setShowModal
      modalClass
      childClass="p-6"
      borderBottom=true>
      <ExplainTimeline row contexts />
    </Modal>
}

module AuditDetailModal = {
  @react.component
  let make = (~showModal, ~setShowModal, ~log: auditLog) => {
    let changes = log->getAuditValueChanges
    let (conditionBefore, conditionAfter) = log->getAuditConditions
    let reason = log->getAuditReason

    let valueCell = (~value: option<JSON.t>, ~isAfter) =>
      switch value {
      | Some(value) =>
        <div
          className={`w-fit max-w-full rounded px-2 py-0.5 ${isAfter
              ? "bg-nd_green-50"
              : "bg-nd_red-50"}`}>
          <ValueText value />
        </div>
      | None =>
        <span className={`${body.md.regular} text-nd_gray-400 italic`}>
          {"Not set"->React.string}
        </span>
      }

    let appliesTo = switch (conditionBefore, conditionAfter) {
    | (Some(before), Some(after))
      if !jsonEquals(before->JSON.Encode.object, after->JSON.Encode.object) =>
      <div className="flex flex-col gap-2">
        <span className={`${body.sm.medium} text-nd_gray-500`}> {"Before"->React.string} </span>
        <ConditionChips condition=before />
        <span className={`${body.sm.medium} text-nd_gray-500`}> {"After"->React.string} </span>
        <ConditionChips condition=after />
      </div>
    | (_, Some(condition)) | (Some(condition), None) => <ConditionChips condition />
    | (None, None) => React.null
    }

    <Modal
      modalHeading={`${log.tableName->getAuditTableLabel} ${log.action->getAuditActionVerb}`}
      modalHeadingDescription={`${log->getAuditAuthor} · ${log.timestamp->getAuditTimestamp}`}
      modalDescriptionClass={`${body.md.regular} text-nd_gray-500 mt-1`}
      showModal
      setShowModal
      modalClass="w-full max-w-4xl mx-auto my-auto dark:!bg-jp-gray-lightgray_background"
      childClass="p-6"
      borderBottom=true>
      <div className="flex flex-col gap-6 max-h-[70vh] overflow-y-auto">
        <RenderIf condition={conditionBefore->Option.isSome || conditionAfter->Option.isSome}>
          <div className="flex flex-col gap-3">
            <SectionLabel
              label="Applies to"
              hint="Locked chips are the fixed scope; the rest are extra conditions."
            />
            appliesTo
          </div>
        </RenderIf>
        <div className="flex flex-col gap-3">
          <SectionLabel label="Changes" />
          {changes->isNonEmptyArray
            ? <div className="border border-nd_gray-150 rounded-lg overflow-hidden">
                <div
                  className={`grid grid-cols-3 gap-4 px-4 py-2 bg-nd_gray-50 border-b border-nd_gray-150 ${body.sm.medium} text-nd_gray-500`}>
                  <span> {"Key"->React.string} </span>
                  <span> {"Before"->React.string} </span>
                  <span> {"After"->React.string} </span>
                </div>
                {changes
                ->Array.map(change =>
                  <div
                    key=change.changedKey
                    className="grid grid-cols-3 gap-4 px-4 py-3 border-b border-nd_gray-150 last:border-b-0 items-start">
                    <span className={`${code.md.medium} text-nd_gray-700 break-all`}>
                      {change.changedKey->React.string}
                    </span>
                    {valueCell(~value=change.before, ~isAfter=false)}
                    {valueCell(~value=change.after, ~isAfter=true)}
                  </div>
                )
                ->React.array}
              </div>
            : <span className={`${body.md.regular} text-nd_gray-500`}>
                {"No values changed. Only details such as the description or priority were updated."->React.string}
              </span>}
        </div>
        <RenderIf condition={reason->isNonEmptyString}>
          <div className="flex flex-col gap-1">
            <SectionLabel label="Reason" />
            <span className={`${body.md.regular} text-nd_gray-700`}> {reason->React.string} </span>
          </div>
        </RenderIf>
      </div>
    </Modal>
  }
}
