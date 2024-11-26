let emailField = FormRenderer.makeFieldInfo(
  ~label="Email",
  ~name="email",
  ~placeholder="Enter your Email",
  ~isRequired=false,
  ~customInput=(~input, ~placeholder as _) =>
    InputFields.textInput(~autoComplete="off")(
      ~input={
        ...input,
        onChange: event =>
          ReactEvent.Form.target(event)["value"]
          ->String.trim
          ->Identity.stringToFormReactEvent
          ->input.onChange,
      },
      ~placeholder="Enter your Email",
    ),
)

let oldPasswordField = FormRenderer.makeFieldInfo(
  ~label="Old Password",
  ~name="old_password",
  ~placeholder="Enter your Old Password",
  ~type_="password",
  ~customInput=InputFields.passwordMatchField(
    ~leftIcon={
      <Icon name="password-lock" size=13 />
    },
  ),
  ~isRequired=false,
)

let newPasswordField = FormRenderer.makeFieldInfo(
  ~label="New Password",
  ~name="new_password",
  ~placeholder="Enter your New Password",
  ~type_="password",
  ~customInput=InputFields.passwordMatchField(
    ~leftIcon={
      <Icon name="password-lock" size=13 />
    },
  ),
  ~isRequired=false,
)

let confirmNewPasswordField = FormRenderer.makeFieldInfo(
  ~label="Confirm Password",
  ~name="confirm_password",
  ~placeholder="Re-enter your Password",
  ~type_="password",
  ~customInput=InputFields.textInput(
    ~type_="password",
    ~autoComplete="off",
    ~leftIcon={
      <Icon name="password-lock" size=13 />
    },
  ),
  ~isRequired=false,
)

let createPasswordField = FormRenderer.makeFieldInfo(
  ~label="Password",
  ~name="create_password",
  ~placeholder="Enter your Password",
  ~type_="password",
  ~customInput=InputFields.passwordMatchField(
    ~leftIcon={
      <Icon name="password-lock" size=13 />
    },
  ),
  ~isRequired=false,
)

let confirmPasswordField = FormRenderer.makeFieldInfo(
  ~label="Confirm Password",
  ~name="comfirm_password",
  ~placeholder="Re-enter your Password",
  ~type_="password",
  ~customInput=InputFields.textInput(
    ~type_="password",
    ~autoComplete="off",
    ~leftIcon={
      <Icon name="password-lock" size=13 />
    },
  ),
  ~isRequired=false,
)

let passwordField = FormRenderer.makeFieldInfo(
  ~label="Password",
  ~name="password",
  ~placeholder="Enter your Password",
  ~type_="password",
  ~customInput=InputFields.textInput(
    ~type_="password",
    ~autoComplete="off",
    ~leftIcon={
      <Icon name="password-lock" size=13 />
    },
  ),
  ~isRequired=false,
)

let startamountField = FormRenderer.makeFieldInfo(
  ~label="",
  ~name="amount_filter.start_amount",
  ~placeholder="0",
  ~customInput=InputFields.numericTextInput(),
  ~type_="number",
)

let endAmountField = FormRenderer.makeFieldInfo(
  ~label="",
  ~name="amount_filter.end_amount",
  ~placeholder="0",
  ~customInput=InputFields.numericTextInput(),
  ~type_="number",
)

module CustomAmountField = {
  @react.component
  let make = () => {
    let form = ReactFinalForm.useForm()
    <>
      <div className={"flex gap-5 items-center justify-center w-[10.125rem] ml-2"}>
        <img alt="cursor" src={`/assets/arrowicon.svg`} className="cursor-pointer mt-3" />
        <FormRenderer.FieldRenderer
          labelClass="font-semibold !text-black"
          field={FormRenderer.makeFieldInfo(
            ~label="",
            ~name="amount_filter.start_amount",
            ~customInput=(~input, ~placeholder as _) =>
              InputFields.numericTextInput()(
                ~input={
                  ...input,
                  onChange: {
                    ev => {
                      form.change("amount_filter.end_amount", ev->Identity.genericTypeToJson)
                      input.onChange(ev)
                    }
                  },
                },
                ~placeholder="0",
              ),
          )}
        />
      </div>
    </>
  }
}
