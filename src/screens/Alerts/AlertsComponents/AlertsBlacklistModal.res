open AlertsTypes

@react.component
let make = (~alert: alert, ~showModal, ~setShowModal, ~onSaved) => {
  open LogicUtils
  open AlertsUtils
  open Typography

  let saveConfig = AlertsHooks.useSaveAlertConfig()
  let showToast = ToastAdapter.useShowToast()
  let initialValues = React.useMemo(() => alert->getBlacklistInitialValues, [alert])
  let (isSaving, setIsSaving) = React.useState(_ => false)

  let saveBlacklist = async (~suppression, ~metadata, ~successMessage) => {
    try {
      await saveConfig(~body=suppression)
      await saveConfig(
        ~body=[
          ("id", alert.id->JSON.Encode.string),
          ("metadata", metadata->getJsonFromArrayOfJson),
        ]->getJsonFromArrayOfJson,
      )
      showToast(~message=successMessage, ~toastType=ToastSuccess)
      setShowModal(_ => false)
      onSaved()
    } catch {
    | Exn.Error(e) =>
      showToast(
        ~message=Exn.message(e)->Option.getOr("Failed to update blacklist"),
        ~toastType=ToastError,
      )
    }
  }

  let onSubmit = async (values, _) => {
    let valuesDict = values->getDictFromJsonObject
    let selectedKeys = valuesDict->getStrArray("blacklistKeys")
    if selectedKeys->isEmptyArray {
      showToast(~message="Select at least one field to blacklist by", ~toastType=ToastWarning)
    } else {
      let entry =
        valuesDict
        ->getArrayFromDict("blacklist", [])
        ->getValueFromArray(0, JSON.Encode.null)
        ->getDictFromJsonObject
        ->omitUnselectedDimensions(~selectedKeys)

      await saveBlacklist(
        ~suppression=[
          ("name", alert.name->JSON.Encode.string),
          ("blacklist", [entry]->JSON.Encode.array),
        ]->getJsonFromArrayOfJson,
        ~metadata=alert.metadata
        ->getDictFromJsonObject
        ->Dict.toArray
        ->Array.concat([
          ((IsBlacklistedKey :> string), (Blacklisted :> string)->JSON.Encode.string),
          (
            (BlacklistKey :> string),
            [(`entry_${Date.now()->Float.toString}`, entry)]->getJsonFromArrayOfJson,
          ),
        ]),
        ~successMessage="Merchant blacklisted for this rule",
      )
    }
    Nullable.null
  }

  let removeBlacklist = async () => {
    setIsSaving(_ => true)
    await saveBlacklist(
      ~suppression=[
        ("name", alert.name->JSON.Encode.string),
        ("blacklist", []->JSON.Encode.array),
      ]->getJsonFromArrayOfJson,
      ~metadata=alert.metadata
      ->getDictFromJsonObject
      ->Dict.toArray
      ->Array.filter(((key, _)) =>
        key !== (IsBlacklistedKey :> string) && key !== (BlacklistKey :> string)
      ),
      ~successMessage="Merchant removed from blacklist",
    )
    setIsSaving(_ => false)
  }

  <Modal
    showModal
    setShowModal
    modalHeading={alert.isBlacklisted ? "Remove Merchant from Blacklist" : "Blacklist Merchant"}
    alignModal="justify-center"
    modalClass="mt-20 overflow-auto max-h-85-vh">
    <RenderIf condition=alert.isBlacklisted>
      <div className="flex flex-col gap-4 p-4 w-100 max-w-full">
        <div className={`${body.sm.regular} text-nd_gray-500`}>
          {"This merchant will no longer be suppressed for this alert rule."->React.string}
        </div>
        <div className="flex justify-end gap-2 pt-3 border-t border-nd_gray-150">
          <Button text="Cancel" buttonType=Secondary onClick={_ => setShowModal(_ => false)} />
          <Button
            text="Remove blacklist"
            buttonType=Primary
            buttonState={isSaving ? Loading : Normal}
            onClick={_ => removeBlacklist()->ignore}
          />
        </div>
      </div>
    </RenderIf>
    <RenderIf condition={!alert.isBlacklisted}>
      <Form onSubmit initialValues>
        <div className="flex flex-col gap-3 p-4 w-100 max-w-full">
          <div className={`${body.sm.regular} text-nd_gray-500`}>
            {"Pick which fields this rule is blacklisted by. Only merchant/profile affect suppression."->React.string}
          </div>
          <AlertsHelper.DimensionFields
            keys=blacklistKeys
            keysName="blacklistKeys"
            valuesName="blacklist[0]"
            label="Blacklist Keys"
            buttonText="Select fields"
          />
          <div className="flex justify-end gap-2 pt-3 border-t border-nd_gray-150">
            <Button text="Cancel" buttonType=Secondary onClick={_ => setShowModal(_ => false)} />
            <FormRenderer.SubmitButton text="Blacklist" showToolTip=false />
          </div>
        </div>
      </Form>
    </RenderIf>
  </Modal>
}
