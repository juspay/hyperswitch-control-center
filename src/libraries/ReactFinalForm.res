type fieldRenderPropsInput = {
  name: string,
  onBlur: ReactEvent.Focus.t => unit,
  onChange: ReactEvent.Form.t => unit,
  onFocus: ReactEvent.Focus.t => unit,
  value: JSON.t,
  checked: bool,
}

type fieldRenderPropsCustomInput<'t> = {
  name: string,
  onBlur: ReactEvent.Focus.t => unit,
  onChange: 't => unit,
  onFocus: ReactEvent.Focus.t => unit,
  value: JSON.t,
  checked: bool,
}

let makeInputRecord = (val, setVal): fieldRenderPropsInput => {
  {
    name: "",
    onBlur: _ev => (),
    onChange: setVal,
    onFocus: _ev => (),
    value: val,
    checked: false,
  }
}

external toTypedField: fieldRenderPropsInput => fieldRenderPropsCustomInput<'t> = "%identity"

type fieldRenderPropsMeta = {
  active: bool,
  data: bool,
  dirty: bool,
  dirtySinceLastSubmit: bool,
  error: Nullable.t<string>,
  initial: bool,
  invalid: bool,
  modified: bool,
  modifiedSinceLastSubmit: bool,
  pristine: bool,
  submitError: Nullable.t<string>,
  submitFailed: bool,
  submitSucceeded: bool,
  submitting: bool,
  touched: bool,
  valid: bool,
  validating: bool,
  visited: bool,
  value: JSON.t,
}

let makeCustomError = error => {
  {
    active: true,
    data: true,
    dirty: true,
    dirtySinceLastSubmit: true,
    error: Nullable.fromOption(error),
    initial: true,
    invalid: true,
    modified: true,
    modifiedSinceLastSubmit: true,
    pristine: true,
    submitError: Nullable.null,
    submitFailed: true,
    submitSucceeded: true,
    submitting: true,
    touched: true,
    valid: true,
    validating: true,
    visited: true,
    value: JSON.Encode.null,
  }
}

type fieldRenderProps = {
  input: fieldRenderPropsInput,
  meta: fieldRenderPropsMeta,
}

type formValues = JSON.t

type submitErrorResponse = {
  responseCode: string,
  responseMessage: string,
  status: string,
}

type formState = {
  dirty: bool,
  submitError: Nullable.t<string>,
  submitErrors: Nullable.t<JSON.t>,
  hasValidationErrors: bool,
  hasSubmitErrors: bool,
  submitting: bool,
  values: JSON.t,
  initialValues: JSON.t,
  errors: JSON.t,
  dirtySinceLastSubmit: bool,
  dirtyFields: Dict.t<bool>,
  dirtyFieldsSinceLastSubmit: Dict.t<bool>,
  submitSucceeded: bool,
  modifiedSinceLastSubmit: bool,
}

type unsubscribeFn = unit => unit

type formApi = {
  batch: bool,
  blur: bool,
  change: (string, JSON.t) => unit,
  destroyOnUnregister: bool,
  focus: bool,
  getFieldState: string => option<fieldRenderPropsMeta>,
  getRegisteredFields: bool,
  getState: unit => formState,
  initialize: bool,
  isValidationPaused: bool,
  mutators: bool,
  pauseValidation: bool,
  registerField: bool,
  reset: Nullable.t<JSON.t> => unit,
  resetFieldState: string => unit,
  restart: bool,
  resumeValidation: bool,
  submit: unit => Promise.t<Nullable.t<JSON.t>>,
  subscribe: (formState => unit, JSON.t) => unsubscribeFn,
}

type formRenderProps = {
  form: formApi,
  handleSubmit: ReactEvent.Form.t => unit,
  submitError: string,
  values: JSON.t,
  // handleSubmit: ReactEvent.Form.t => Promise.t<Nullable.t<JSON.t>>,
}

@module("final-form")
external formError: string = "FORM_ERROR"

let subscribeToValues = [("values", true)]->Dict.fromArray

let subscribeToPristine = [("pristine", true)]->Dict.fromArray

module Form = {
  @module("react-final-form") @react.component
  external make: (
    ~children: formRenderProps => React.element=?,
    ~component: bool=?,
    ~debug: bool=?,
    ~decorators: bool=?,
    ~form: string=?,
    ~initialValues: JSON.t=?,
    ~initialValuesEqual: bool=?,
    ~keepDirtyOnReinitialize: bool=?,
    ~mutators: bool=?,
    ~onSubmit: (formValues, formApi) => Promise.t<Nullable.t<JSON.t>>,
    ~render: formRenderProps => React.element=?,
    ~subscription: Dict.t<bool>,
    ~validate: JSON.t => JSON.t=?,
    ~validateOnBlur: bool=?,
  ) => React.element = "Form"
}
module Field = {
  @module("react-final-form") @react.component
  external make: (
    ~afterSubmit: bool=?,
    ~allowNull: bool=?,
    ~beforeSubmit: bool=?,
    ~children: fieldRenderProps => React.element=?,
    ~component: string=?,
    ~data: bool=?,
    ~defaultValue: bool=?,
    ~format: (. ~value: JSON.t, ~name: string) => JSON.t=?,
    ~formatOnBlur: bool=?,
    ~initialValue: bool=?,
    ~isEqual: bool=?,
    ~multiple: bool=?,
    ~name: string,
    ~parse: (. ~value: JSON.t, ~name: string) => JSON.t=?,
    ~ref: bool=?,
    ~render: fieldRenderProps => React.element=?,
    ~subscription: bool=?,
    @as("type") ~type_: bool=?,
    ~validate: (option<string>, JSON.t) => Promise.t<Nullable.t<string>>=?, // (field_vale, form_object)
    ~validateFields: bool=?,
    ~value: bool=?,
    ~placeholder: string=?,
  ) => React.element = "Field"
}

type formSubscription = JSON.t
let useFormSubscription = (keys): formSubscription => {
  React.useMemo0(() => {
    let dict = Dict.make()
    keys->Array.forEach(key => {
      Dict.set(dict, key, JSON.Encode.bool(true))
    })
    dict->JSON.Encode.object
  })
}

module FormSpy = {
  @module("react-final-form") @react.component
  external make: (
    ~children: formState => React.element,
    ~component: bool=?,
    ~onChange: bool=?,
    ~render: formState => React.element=?,
    ~subscription: formSubscription,
  ) => React.element = "FormSpy"
}

@module("react-final-form")
external useFormState: Nullable.t<JSON.t> => formState = "useFormState"

@module("react-final-form")
external useForm: unit => formApi = "useForm"

@module("react-final-form")
external useField: string => fieldRenderProps = "useField"

type useFieldOption

@obj
external makeUseFieldOption: (
  ~format: (. ~value: JSON.t, ~name: string) => JSON.t=?,
  ~parse: (. ~value: JSON.t, ~name: string) => JSON.t=?,
  unit,
) => useFieldOption = ""

@module("react-final-form")
external useFieldWithOptions: (string, useFieldOption) => fieldRenderProps = "useField"

let makeFakeInput = (
  ~value=JSON.Encode.null,
  ~onChange=_ev => (),
  ~onBlur=_ev => (),
  ~onFocus=_ev => (),
  (),
) => {
  let input: fieldRenderPropsInput = {
    name: "--",
    onBlur,
    onChange,
    onFocus,
    value,
    checked: true,
  }
  input
}

let fakeFieldRenderProps = {
  input: makeFakeInput(),
  meta: makeCustomError(None),
}
