let defaultSubmit = (_, _) => {
  Js.Nullable.null->Js.Promise.resolve
}
module FormBody = {
  @react.component
  let make = (~children, ~formClass, ~handleSubmit, ~submitOnEnter) => {
    let form = ReactFinalForm.useForm()
    let formRef = React.useRef(Js.Nullable.null)
    React.useEffect0(() => {
      let onKeyDown = (ev: 'a) => {
        let keyCode = ev->ReactEvent.Keyboard.keyCode

        let tagName = Document.activeElement->Webapi.Dom.Element.tagName
        if keyCode === 13 {
          let enterIsFromWithinForm = switch formRef.current->Js.Nullable.toOption {
          | Some(element) => element->Webapi.Dom.Element.contains(~child=Document.activeElement)
          | None => false
          }

          if (
            tagName !== "INPUT" &&
            tagName !== "TEXTAREA" &&
            ((submitOnEnter && !enterIsFromWithinForm) || enterIsFromWithinForm)
          ) {
            let _ = form.submit()
          }
        }
      }

      Window.addEventListener("keydown", onKeyDown)
      Some(() => Window.removeEventListener("keydown", onKeyDown))
    })
    <form onSubmit={handleSubmit} className={formClass} ref={formRef->ReactDOM.Ref.domRef}>
      {children}
    </form>
  }
}
@react.component
let make = (
  ~children,
  ~onSubmit=defaultSubmit,
  ~initialValues=?,
  ~validate=?,
  ~formClass="",
  ~submitOnEnter=false,
) => {
  <ReactFinalForm.Form
    subscription=ReactFinalForm.subscribeToValues
    ?initialValues
    onSubmit
    ?validate
    render={({handleSubmit}) =>
      <FormBody handleSubmit formClass submitOnEnter> {children} </FormBody>}
  />
}
