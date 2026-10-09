open AlertsTypes
open Typography

@react.component
let make = (~alert: alert, ~showModal, ~setShowModal, ~onSaved) => {
  open LogicUtils
  open AlertsUtils
  open AlertsHelper
  open FormRenderer

  let saveConfig = AlertsHooks.useSaveAlertConfig()
  let showToast = ToastAdapter.useShowToast()
  let initialValues = React.useMemo(() => alert->getSnoozeInitialValues, [alert])
  let (isSaving, setIsSaving) = React.useState(_ => false)
  let currentEntry = alert->getSnoozeEntry

  let saveSnooze = async (~snooze, ~successMessage) => {
    try {
      await saveConfig(
        ~body=[("id", alert.id->JSON.Encode.string), ("snooze", snooze)]->getJsonFromArrayOfJson,
      )
      showToast(~message=successMessage, ~toastType=ToastSuccess)
      setShowModal(_ => false)
      onSaved()
    } catch {
    | Exn.Error(e) =>
      showToast(
        ~message=Exn.message(e)->Option.getOr("Failed to update snooze"),
        ~toastType=ToastError,
      )
    }
  }

  let onSubmit = async (values, _) => {
    let valuesDict = values->getDictFromJsonObject
    let entryDict = valuesDict->getDictfromDict("entry")
    let entry =
      entryDict->omitUnselectedDimensions(~selectedKeys=valuesDict->getStrArray("snoozeKeys"))
    let startTime = entryDict->getString("snooze_start_time", "")
    if startTime->isEmptyString {
      showToast(~message="Pick a start and end date first", ~toastType=ToastWarning)
    } else {
      let key = `custom_snooze_entry_${startTime->Date.fromString->Date.toISOString}`
      await saveSnooze(
        ~snooze=[(key, entry)]->getJsonFromArrayOfJson,
        ~successMessage="Alert snoozed",
      )
    }
    Nullable.null
  }

  let removeSnooze = async () => {
    setIsSaving(_ => true)
    await saveSnooze(~snooze=Dict.make()->JSON.Encode.object, ~successMessage="Snooze removed")
    setIsSaving(_ => false)
  }

  <Modal
    showModal
    setShowModal
    modalHeading="Snooze Alert"
    alignModal="justify-center"
    modalClass="mt-20 overflow-auto max-h-85-vh">
    <RenderIf condition=alert.isSnoozed>
      <div className="flex flex-col gap-4 p-4 w-133 max-w-full">
        <div className={`${body.sm.regular} text-nd_gray-500`}>
          {"Only one snooze entry is allowed for an alert."->React.string}
        </div>
        <div className="rounded-lg border border-nd_gray-150 p-4">
          <div className="flex items-center justify-between gap-3 mb-3">
            <div className={`${heading.xs.semibold} text-nd_gray-800`}>
              {"Current snooze"->React.string}
            </div>
            <Button
              text="Delete"
              buttonType=Delete
              buttonSize=Small
              buttonState={isSaving ? Button.Loading : Button.Normal}
              onClick={_ => removeSnooze()->ignore}
            />
          </div>
          <div className="flex flex-col gap-2">
            {currentEntry
            ->Dict.toArray
            ->Array.map(((key, value)) => {
              let text = value->getStringFromJson("-")
              let cell: Table.cell = key->String.endsWith("_time") ? Date(text) : Text(text)
              <AlertDetailRow key label=key cell />
            })
            ->React.array}
          </div>
        </div>
        <div className="flex justify-end pt-3 border-t border-nd_gray-150">
          <Button text="Close" buttonType=Secondary onClick={_ => setShowModal(_ => false)} />
        </div>
      </div>
    </RenderIf>
    <RenderIf condition={!alert.isSnoozed}>
      <Form onSubmit initialValues>
        <div className="flex flex-col gap-4 p-4 w-133 max-w-full">
          <div className={`${body.sm.regular} text-nd_gray-500`}>
            {"Suppress this alert for one time window."->React.string}
          </div>
          <div className="max-w-full overflow-x-auto">
            <FieldRenderer
              field={makeMultiInputFieldInfo(
                ~label="Snooze Window",
                ~isRequired=true,
                ~comboCustomInput=InputFields.dateRangeField(
                  ~startKey="entry.snooze_start_time",
                  ~endKey="entry.snooze_end_time",
                  ~format="YYYY-MM-DDTHH:mm:ss[Z]",
                  ~showTime=true,
                  ~disablePastDates=true,
                  ~numMonths=2,
                  ~isTooltipVisible=false,
                ),
                ~inputFields=[],
              )}
            />
          </div>
          <DimensionFields
            keys=allDimensionKeys
            keysName="snoozeKeys"
            valuesName="entry"
            label="Snooze fields"
            buttonText="Select fields to snooze"
          />
          <div className="flex justify-end gap-2 pt-3 border-t border-nd_gray-150">
            <Button text="Cancel" buttonType=Secondary onClick={_ => setShowModal(_ => false)} />
            <SubmitButton text="Snooze" showToolTip=false />
          </div>
        </div>
      </Form>
    </RenderIf>
  </Modal>
}
