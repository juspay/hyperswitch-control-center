open AlertsTypes
open LogicUtils

@react.component
let make = (~alert: alert, ~showModal, ~setShowModal, ~onSaved) => {
  open AlertsUtils
  open FormRenderer

  let saveConfig = AlertsHooks.useSaveAlertConfig()
  let showToast = ToastAdapter.useShowToast()
  let initialValues = React.useMemo(() => alert->getResolveInitialValues, [alert])

  let onSubmit = async (values, _) => {
    try {
      await saveConfig(~body=values)
      showToast(~message="Resolution saved", ~toastType=ToastSuccess)
      setShowModal(_ => false)
      onSaved()
    } catch {
    | Exn.Error(e) =>
      showToast(
        ~message=Exn.message(e)->Option.getOr("Failed to save resolution"),
        ~toastType=ToastError,
      )
    }
    Nullable.null
  }

  <Modal
    showModal
    setShowModal
    modalHeading="Resolve Alert"
    alignModal="justify-center"
    modalClass="mt-20 overflow-auto max-h-85-vh">
    <Form onSubmit initialValues>
      <div className="flex flex-col gap-3 p-4 w-100 max-w-full">
        <div className="grid grid-cols-2 gap-3">
          {selectField(
            ~label="Resolution",
            ~name="metadata.resolution",
            ~options=allResolutionStatuses
            ->Array.map((v): string => (v :> string))
            ->SelectBox.makeOptions,
          )}
          {selectField(
            ~label="Classification",
            ~name="metadata.is_internal",
            ~options=allInternalClassifications
            ->Array.map((v): string => (v :> string))
            ->SelectBox.makeOptions,
          )}
          {selectField(
            ~label="Actionable",
            ~name="metadata.is_actionable",
            ~options=allActionableStatuses
            ->Array.map((v): string => (v :> string))
            ->SelectBox.makeOptions,
          )}
          {selectField(
            ~label="Visible to Merchant",
            ~name="metadata.is_visible_to_merchant",
            ~options=allYesNoUnknown
            ->Array.map((v): string => (v :> string))
            ->SelectBox.makeOptions,
          )}
          {selectField(
            ~label="Mimir RCA Helpful",
            ~name="metadata.is_mimir_rca_helpful",
            ~options=allYesNoUnknown
            ->Array.map((v): string => (v :> string))
            ->SelectBox.makeOptions,
          )}
          <FieldRenderer
            field={makeFieldInfo(
              ~label="Root Cause",
              ~name="metadata.rca_merchant",
              ~customInput=InputFields.textInput(),
              ~placeholder="e.g. Connector outage",
            )}
          />
        </div>
        <FieldRenderer
          field={makeFieldInfo(
            ~label="Comment",
            ~name="metadata.comment",
            ~customInput=InputFields.multiLineTextInput(
              ~isDisabled=false,
              ~rows=Some(3),
              ~cols=Some(40),
            ),
            ~placeholder="Additional notes",
          )}
        />
        <ReactFinalForm.Field name="metadata.is_mimir_rca_helpful">
          {fieldState => {
            let hasRcaComment =
              alert.metadata
              ->getDictFromJsonObject
              ->getString("is_mimir_rca_correct_comment", "")
              ->isNonEmptyString
            <RenderIf
              condition={fieldState.input.value->getStringFromJson("") === (Yn_Yes :> string) ||
                hasRcaComment}>
              <FieldRenderer
                field={makeFieldInfo(
                  ~label="RCA Comment",
                  ~name="metadata.is_mimir_rca_correct_comment",
                  ~customInput=InputFields.multiLineTextInput(
                    ~isDisabled=false,
                    ~rows=Some(3),
                    ~cols=Some(40),
                  ),
                  ~placeholder="Add RCA feedback",
                )}
              />
            </RenderIf>
          }}
        </ReactFinalForm.Field>
        <div className="flex justify-end gap-2 pt-3 border-t border-nd_gray-150">
          <Button text="Cancel" buttonType=Secondary onClick={_ => setShowModal(_ => false)} />
          <SubmitButton text="Save" showToolTip=false />
        </div>
      </div>
    </Form>
  </Modal>
}
