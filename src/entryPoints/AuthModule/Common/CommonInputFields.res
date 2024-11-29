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
  ~name="start_amount",
  ~placeholder="0",
  ~customInput=InputFields.numericTextInput(),
  ~type_="number",
)

let endAmountField = FormRenderer.makeFieldInfo(
  ~label="",
  ~name="end_amount",
  ~placeholder="0",
  ~customInput=InputFields.numericTextInput(),
  ~type_="number",
)

module CustomAmountEqualField = {
  @react.component
  let make = () => {
    let form = ReactFinalForm.useForm()
    <div className={"flex gap-5 items-center justify-center w-28 ml-2"}>
      <FormRenderer.FieldRenderer
        labelClass="font-semibold !text-black"
        field={FormRenderer.makeFieldInfo(~label="", ~name="start_amount", ~customInput=(
          ~input,
          ~placeholder as _,
        ) =>
          InputFields.numericTextInput()(
            ~input={
              ...input,
              onChange: {
                ev => {
                  form.change("end_amount", ev->Identity.genericTypeToJson)
                  input.onChange(ev)
                }
              },
            },
            ~placeholder="0",
          )
        )}
      />
    </div>
  }
}

module CustomAmountBetweenField = {
  @react.component
  let make = () => {
    let form = ReactFinalForm.useForm()
    <div className="flex gap-1 items-center justify-center mx-1 w-10.25-rem">
      <FormRenderer.FieldRenderer
        labelClass="font-semibold !text-black"
        field={FormRenderer.makeFieldInfo(~label="", ~name="start_amount", ~customInput=(
          ~input,
          ~placeholder as _,
        ) =>
          InputFields.numericTextInput()(
            ~input={
              ...input,
              onChange: {
                ev => {
                  form.change("end_amount", 0->Identity.genericTypeToJson)
                  input.onChange(ev)
                }
              },
            },
            ~placeholder="0",
          )
        )}
      />
      <p className="mt-3 text-xs text-jp-gray-700"> {"and"->React.string} </p>
      <FormRenderer.FieldRenderer labelClass="font-semibold !text-black" field=endAmountField />
    </div>
  }
}
