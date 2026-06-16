open ThemePreviewUtils
open ThemePreviewTypes
open Typography

@react.component
let make = () => {
  let formState = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )
  let formValues = formState.values->LogicUtils.getDictFromJsonObject
  let emailConfig = getEmailFormValues(~formValues)

  <div className="rounded-lg overflow-hidden w-full shadow-xl p-4 bg-nd_gray-50 ">
    <div
      className="flex flex-col items-center text-center pt-4 pb-8"
      style={ReactDOM.Style.make(~backgroundColor=emailConfig.background_color, ())}>
      <div className="flex justify-center h-10">
        <div
          className="flex border-2 border-dashed rounded-lg py-1.5 px-4 items-center opacity-30"
          style={ReactDOM.Style.make(~borderColor=emailConfig.foreground_color, ())}>
          <span
            className={`${body.xs.medium} opacity-60`}
            style={ReactDOM.Style.make(~color=emailConfig.foreground_color, ())}>
            {React.string(mockValues.emailLogoPlaceholder)}
          </span>
        </div>
      </div>
      <div
        className={`${heading.md.semibold} mt-6`}
        style={ReactDOM.Style.make(~color=emailConfig.foreground_color, ())}>
        {React.string(`Welcome to ${emailConfig.entity_name}!`)}
      </div>
      <div className="mt-2">
        <p
          className={`${body.sm.medium} opacity-80`}
          style={ReactDOM.Style.make(~color=emailConfig.foreground_color, ())}>
          {React.string(mockValues.emailGreeting)}
        </p>
      </div>
      <span
        className={`${body.sm.semibold} mt-8 py-2 px-8 rounded-full cursor-pointer text-white`}
        style={ReactDOM.Style.make(~backgroundColor=emailConfig.primary_color, ())}>
        {React.string(`Unlock ${emailConfig.entity_name}`)}
      </span>
      <div className="max-w-50 mt-8">
        <p
          className={`${body.sm.medium} opacity-80`}
          style={ReactDOM.Style.make(~color=emailConfig.foreground_color, ())}>
          {React.string(mockValues.emailLinkExpireText(emailConfig.entity_name))}
        </p>
      </div>
    </div>
  </div>
}
