@react.component
let make = (~onSubmit, ~customFields, ~validateForm) => {
  <FormRenderer
    validate=validateForm
    initialValues={Js.Json.object_(Js.Dict.empty())}
    fields={customFields}
    onSubmit
  />
}
