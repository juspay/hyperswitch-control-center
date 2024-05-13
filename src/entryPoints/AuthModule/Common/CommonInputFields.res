let emailField = FormRenderer.makeFieldInfo(
  ~label="Email",
  ~name="email",
  ~placeholder="Enter your Email",
  ~isRequired=false,
  ~customInput=(~input, ~placeholder as _) =>
    InputFields.textInput(
      ~input={
        ...input,
        onChange: event =>
          ReactEvent.Form.target(event)["value"]
          ->String.trim
          ->Identity.stringToFormReactEvent
          ->input.onChange,
      },
      ~placeholder="Enter your Email",
      ~autoComplete="off",
      (),
    ),
  (),
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
    (),
  ),
  ~isRequired=false,
  (),
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
    (),
  ),
  ~isRequired=false,
  (),
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
    (),
  ),
  ~isRequired=false,
  (),
)
