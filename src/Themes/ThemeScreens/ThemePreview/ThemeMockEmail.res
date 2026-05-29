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

  <div className="rounded-lg overflow-hidden w-full shadow-xl p-6 bg-nd_gray-50 ">
    <div
      className="flex flex-col items-center text-center pt-5 pb-14"
      style={ReactDOM.Style.make(~backgroundColor=emailConfig.background_color, ())}>
      <div className="flex justify-center h-16">
        <div
          className="flex border-2 border-dashed rounded-lg py-2 px-5 items-center opacity-30"
          style={ReactDOM.Style.make(~borderColor=emailConfig.foreground_color, ())}>
          <span
            className={`${body.xs.medium} opacity-60`}
            style={ReactDOM.Style.make(~color=emailConfig.foreground_color, ())}>
            {React.string(mockValues.emailLogoPlaceholder)}
          </span>
        </div>
      </div>
      <div
        className={`${heading.xl.semibold} mt-10`}
        style={ReactDOM.Style.make(~color=emailConfig.foreground_color, ())}>
        {React.string(`Welcome to ${emailConfig.entity_name}!`)}
      </div>
      <div className="mt-2.5">
        <p
          className={`${body.sm.medium} opacity-80`}
          style={ReactDOM.Style.make(~color=emailConfig.foreground_color, ())}>
          {React.string(mockValues.emailGreeting)}
        </p>
      </div>
      <span
        className={`${body.sm.semibold} mt-12 py-3 px-10 rounded-full cursor-pointer text-white`}
        style={ReactDOM.Style.make(~backgroundColor=emailConfig.primary_color, ())}>
        {React.string(`Unlock ${emailConfig.entity_name}`)}
      </span>
      <div className="max-w-50 mt-12">
        <p
          className={`${body.sm.medium} opacity-80`}
          style={ReactDOM.Style.make(~color=emailConfig.foreground_color, ())}>
          {React.string(mockValues.emailLinkExpireText(emailConfig.entity_name))}
        </p>
      </div>
    </div>
  </div>
}
