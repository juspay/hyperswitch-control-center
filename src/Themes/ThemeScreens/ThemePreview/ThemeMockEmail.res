open ThemePreviewUtils
open Typography

@react.component
let make = () => {
  let formState = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )
  let formValues = formState.values->LogicUtils.getDictFromJsonObject
  let emailConfig = getEmailFormValues(~formValues)

  let outerStyle = ReactDOM.Style.make(
    ~backgroundColor="#f5f5f5",
    ~padding="24px",
    ~fontFamily="Arial, sans-serif",
    (),
  )

  let containerStyle = ReactDOM.Style.make(
    ~backgroundColor=emailConfig.background_color,
    ~textAlign="center",
    ~maxWidth="100%",
    ~margin="auto",
    (),
  )

  let headingStyle = ReactDOM.Style.make(
    ~color=emailConfig.foreground_color,
    ~margin="0",
    ~lineHeight="2.5rem",
    (),
  )

  let subTextStyle = ReactDOM.Style.make(
    ~color=emailConfig.foreground_color,
    ~opacity="0.8",
    ~lineHeight="1.4rem",
    ~margin="0",
    (),
  )

  let buttonStyle = ReactDOM.Style.make(
    ~backgroundColor=emailConfig.primary_color,
    ~color="#ffffff",
    ~padding="12px 40px",
    ~borderRadius="64px",
    ~border="none",
    ~cursor="pointer",
    ~display="inline-block",
    ~textAlign="center",
    ~textDecoration="none",
    (),
  )

  let linkExpireTextStyle = ReactDOM.Style.make(
    ~color=emailConfig.foreground_color,
    ~opacity="0.8",
    ~lineHeight="1.4rem",
    ~margin="0",
    (),
  )

  <div className="rounded-lg overflow-hidden w-full shadow-xl" style=outerStyle>
    <div style=containerStyle>
      <div style={ReactDOM.Style.make(~height="20px", ())} />
      <div
        style={ReactDOM.Style.make(
          ~display="flex",
          ~alignItems="center",
          ~justifyContent="center",
          ~height="4rem",
          (),
        )}>
        <div
          style={ReactDOM.Style.make(
            ~border="2px dashed",
            ~borderColor=emailConfig.foreground_color,
            ~opacity="0.3",
            ~borderRadius="8px",
            ~padding="8px 20px",
            ~display="inline-flex",
            ~alignItems="center",
            ~justifyContent="center",
            (),
          )}>
          <span
            className={`${body.xs.medium}`}
            style={ReactDOM.Style.make(~color=emailConfig.foreground_color, ~opacity="0.6", ())}>
            {React.string("Your Logo Here")}
          </span>
        </div>
      </div>
      <div style={ReactDOM.Style.make(~height="40px", ())} />
      <div className={`${heading.xl.semibold}`} style=headingStyle>
        {React.string(`Welcome to ${emailConfig.entity_name}!`)}
      </div>
      <div style={ReactDOM.Style.make(~height="10px", ())} />
      <div style={ReactDOM.Style.make(~maxWidth="80%", ~margin="auto", ())}>
        <p className={`${body.sm.medium}`} style=subTextStyle>
          {React.string(`Dear User, we are thrilled to welcome you into our community!`)}
        </p>
      </div>
      <div style={ReactDOM.Style.make(~height="30px", ())} />
      <span className={`${body.sm.semibold}`} style=buttonStyle>
        {React.string(`Unlock ${emailConfig.entity_name}`)}
      </span>
      <div style={ReactDOM.Style.make(~height="30px", ())} />
      <div style={ReactDOM.Style.make(~maxWidth="85%", ~margin="auto", ())}>
        <p className={`${body.sm.medium}`} style=linkExpireTextStyle>
          {React.string(
            `This link provides instant access to ${emailConfig.entity_name} account. It will expire in 24 hours and can only be used once.`,
          )}
        </p>
      </div>
      <div style={ReactDOM.Style.make(~height="70px", ())} />
    </div>
  </div>
}
