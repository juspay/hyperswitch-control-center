open AlertsTypes

@react.component
let make = (~alert: alert, ~onSaved) => {
  open AlertsUtils
  open LogicUtils
  open Typography

  let saveConfig = AlertsHooks.useSaveAlertConfig()
  let showToast = ToastAdapter.useShowToast()
  let {email} = React.useContext(UserInfoProvider.defaultContext).getResolvedUserInfo()
  let initialValues = React.useMemo2(() => alert->getCommentInitialValues(~email), (alert, email))
  let (isUnderEdit, setIsUnderEdit) = React.useState(_ => false)
  let (isSaving, setIsSaving) = React.useState(_ => false)
  let authorization = AlertsHooks.useAlertsManageAccess()
  let comment = alert.metadata->getDictFromJsonObject->getString("comment", "")

  let onSubmit = async (values, _) => {
    setIsSaving(_ => true)
    try {
      await saveConfig(~body=values)
      showToast(~message="Comment updated", ~toastType=ToastSuccess)
      setIsUnderEdit(_ => false)
      onSaved()
    } catch {
    | Exn.Error(e) =>
      showToast(
        ~message=Exn.message(e)->Option.getOr("Failed to update comment"),
        ~toastType=ToastError,
      )
    }
    setIsSaving(_ => false)
    Nullable.null
  }

  <div className="min-w-0 w-full">
    <RenderIf condition=isUnderEdit>
      <Form onSubmit initialValues>
        <div className="flex items-center gap-1">
          <div className="flex-1 min-w-0">
            <ReactFinalForm.Field name="metadata.comment">
              {fieldState =>
                <TextInput
                  input=fieldState.input
                  placeholder="Add a comment"
                  autoFocus=true
                  isDisabled=isSaving
                  customDashboardClass={`h-8 ${body.md.medium}`}
                  customPaddingClass="px-2"
                  customStyle="-mx-2 rounded-md"
                  onKeyUp={event =>
                    if event->ReactEvent.Keyboard.key === "Escape" {
                      setIsUnderEdit(_ => false)
                    }}
                />}
            </ReactFinalForm.Field>
          </div>
          <Button
            type_="submit"
            ariaLabel="Save comment"
            onClick={_ => ()}
            buttonType=Transparent
            buttonSize=XSmall
            buttonState={isSaving ? Disabled : Normal}
            leftIcon={CustomIcon(<Icon name={"nd-check"} size=14 />)}
          />
          <Button
            ariaLabel="Cancel comment edit"
            buttonType=Transparent
            buttonSize=XSmall
            buttonState={isSaving ? Disabled : Normal}
            onClick={_ => setIsUnderEdit(_ => false)}
            leftIcon={CustomIcon(<Icon name={"nd-cross"} size=14 />)}
          />
        </div>
      </Form>
    </RenderIf>
    <RenderIf condition={!isUnderEdit}>
      <div className="group flex items-center gap-1 min-w-0 py-1 border border-transparent">
        <span
          className={`truncate ${body.md.medium} ${comment->isNonEmptyString
              ? "text-nd_gray-600"
              : "text-nd_gray-400"}`}>
          {(comment->isNonEmptyString ? comment : "Add a comment")->React.string}
        </span>
        <ACLButton
          authorization
          buttonType=Transparent
          buttonSize=XSmall
          customButtonStyle="opacity-0 group-hover:opacity-100 focus:opacity-100 transition-opacity"
          leftIcon={CustomIcon(<Icon name="nd-pencil" size=14 className="text-nd_gray-400" />)}
          onClick={_ => setIsUnderEdit(_ => true)}
        />
      </div>
    </RenderIf>
  </div>
}
