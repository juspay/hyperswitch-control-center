open InputFields
type inputFieldType = {
  name: string,
  placeholder: string,
  format: option<(. ~value: Js.Json.t, ~name: string) => Js.Json.t>,
  parse: option<(. ~value: Js.Json.t, ~name: string) => Js.Json.t>,
  disabled: bool,
  isRequired: bool,
  @as("type") type_: string,
  customInput: customInputFn,
  validate: option<(option<string>, Js.Json.t) => Js.Promise.t<Js.Nullable.t<string>>>,
}
type fieldInfoType = {
  label: string,
  customLabelIcon: option<React.element>,
  subHeading: option<string>,
  subHeadingIcon: option<string>,
  description: option<string>,
  descriptionComponent: option<React.element>,
  subText: option<string>,
  isRequired: bool,
  toolTipPosition: option<ToolTip.toolTipPosition>,
  comboCustomInput: option<comboCustomInputFn>,
  inputFields: array<inputFieldType>,
  inputNames: array<string>,
  fieldPortalKey?: string,
}

let makeInputFieldInfo = (
  ~label=?,
  ~name,
  ~customInput=?,
  ~placeholder=?,
  ~format=?,
  ~disabled=false,
  ~parse=?,
  ~type_="text",
  ~isRequired=false,
  ~validate: option<(option<string>, Js.Json.t) => Js.Promise.t<Js.Nullable.t<string>>>=?,
  (),
) => {
  let label = label->Belt.Option.getWithDefault(name)

  let newCustomInput =
    customInput->Belt.Option.getWithDefault(InputFields.textInput(~isDisabled=disabled, ()))

  {
    name,
    placeholder: placeholder->Belt.Option.getWithDefault(label),
    customInput: newCustomInput,
    disabled,
    format,
    parse,
    type_,
    isRequired,
    validate,
  }
}

let makeMultiInputFieldInfoOld = (
  ~label,
  ~customLabelIcon=?,
  ~subHeading=?,
  ~subHeadingIcon=?,
  ~description=?,
  ~toolTipPosition=?,
  ~descriptionComponent=?,
  ~subText=?,
  ~isRequired=false,
  ~comboCustomInput=?,
  ~inputFields,
  (),
) => {
  {
    label,
    customLabelIcon,
    subHeading,
    subHeadingIcon,
    description,
    toolTipPosition,
    descriptionComponent,
    subText,
    isRequired,
    comboCustomInput,
    inputFields,
    inputNames: inputFields->Array.map(x => x.name),
  }
}

let makeMultiInputFieldInfo = (
  ~label,
  ~customLabelIcon=?,
  ~subHeading=?,
  ~subHeadingIcon=?,
  ~description=?,
  ~toolTipPosition=?,
  ~descriptionComponent=?,
  ~subText=?,
  ~isRequired=false,
  ~comboCustomInput: option<comboCustomInputRecord>=?,
  ~fieldPortalKey: option<string>=?,
  ~inputFields,
  (),
) => {
  let inputNames =
    comboCustomInput
    ->Belt.Option.mapWithDefault([], x => x.names)
    ->Array.concat(inputFields->Array.map(x => x.name))
  {
    label,
    customLabelIcon,
    subHeading,
    subHeadingIcon,
    description,
    toolTipPosition,
    descriptionComponent,
    subText,
    isRequired,
    comboCustomInput: comboCustomInput->Belt.Option.map(x => x.fn),
    inputFields,
    inputNames,
    ?fieldPortalKey,
  }
}

let makeFieldInfo = (
  ~label=?,
  ~customLabelIcon=?,
  ~name,
  ~customInput=?,
  ~description=?,
  ~toolTipPosition=?,
  ~descriptionComponent=?,
  ~subText=?,
  ~placeholder=?,
  ~subHeading=?,
  ~subHeadingIcon=?,
  ~format=?,
  ~disabled=false,
  ~parse=?,
  ~type_="text",
  ~isRequired=false,
  ~fieldPortalKey: option<string>=?,
  ~validate: option<(option<string>, Js.Json.t) => Js.Promise.t<Js.Nullable.t<string>>>=?,
  (),
) => {
  let label = label->Belt.Option.getWithDefault(name)

  let newCustomInput =
    customInput->Belt.Option.getWithDefault(InputFields.textInput(~isDisabled=disabled, ()))

  makeMultiInputFieldInfo(
    ~label,
    ~customLabelIcon?,
    ~description?,
    ~toolTipPosition?,
    ~descriptionComponent?,
    ~subHeading?,
    ~subText?,
    ~subHeadingIcon?,
    ~isRequired,
    ~fieldPortalKey?,
    ~inputFields=[
      makeInputFieldInfo(
        ~label,
        ~name,
        ~customInput=newCustomInput,
        ~placeholder?,
        ~format?,
        ~disabled,
        ~parse?,
        ~type_,
        ~isRequired,
        ~validate?,
        (),
      ),
    ],
    (),
  )
}

module FieldWrapper = {
  @react.component
  let make = (
    ~label,
    ~customLabelIcon=?,
    ~labelClass="",
    ~labelTextStyleClass="",
    ~labelPadding="",
    ~subHeading=?,
    ~subHeadingIcon=?,
    ~description=?,
    ~toolTipPosition=ToolTip.Bottom,
    ~descriptionComponent=?,
    ~subText=?,
    ~isRequired=false,
    ~fieldWrapperClass="",
    ~children,
    ~dataId="",
    ~subTextClass="",
    ~subHeadingClass="",
  ) => {
    let showLabel = React.useContext(LabelVisibilityContext.formLabelRenderContext)
    let fieldWrapperClass = if fieldWrapperClass == "" {
      "p-1 flex flex-col"
    } else {
      fieldWrapperClass
    }
    let subTextClass = `pt-2 pb-2 text-sm text-bold text-jp-gray-900 text-opacity-50 dark:text-jp-gray-text_darktheme dark:text-opacity-50 ${subTextClass}`

    let labelPadding = labelPadding === "" ? "pt-2 pb-2" : labelPadding

    let labelTextClass =
      labelTextStyleClass->String.length > 0
        ? labelTextStyleClass
        : "text-fs-13 text-jp-gray-900 text-opacity-50 dark:text-jp-gray-text_darktheme dark:text-opacity-50 ml-1"

    <AddDataAttributes attributes=[("data-component-field-wrapper", `field-${dataId}`)]>
      <div className={fieldWrapperClass}>
        {<>
          <div className="flex items-center">
            <UIUtils.RenderIf condition=showLabel>
              <AddDataAttributes attributes=[("data-form-label", label)]>
                <label className={`${labelPadding} ${labelTextClass} ${labelClass}`}>
                  {React.string(label)}
                  <UIUtils.RenderIf condition=isRequired>
                    <span className="text-red-950"> {React.string(" *")} </span>
                  </UIUtils.RenderIf>
                </label>
              </AddDataAttributes>
            </UIUtils.RenderIf>
            {switch description {
            | Some(description) =>
              <UIUtils.RenderIf condition={description !== ""}>
                <div className="text-sm text-gray-500 mx-2">
                  <ToolTip description toolTipPosition />
                </div>
              </UIUtils.RenderIf>
            | None => React.null
            }}
            {switch descriptionComponent {
            | Some(descriptionComponent) =>
              <div className="text-sm text-gray-500 mx-2">
                <ToolTip descriptionComponent toolTipPosition tooltipWidthClass="w-80" />
              </div>
            | None => React.null
            }}
            {switch customLabelIcon {
            | Some(customLabelIcon) => <div className="pl-2"> {customLabelIcon} </div>
            | None => React.null
            }}
          </div>
          {switch subHeading {
          | Some(sb) =>
            <div className="flex flex-row items-center">
              {switch subHeadingIcon {
              | Some(iconName) =>
                <Icon size=13 name=iconName className=" opacity-60 mr-2 ml-1 mb-2" />
              | None => React.null
              }}
              <div
                className={`text-sm text-jp-gray-900 text-opacity-50 dark:text-jp-gray-text_darktheme dark:text-opacity-50 mb-2 ${subHeadingClass}`}>
                {React.string(sb)}
              </div>
            </div>
          | None => React.null
          }}
        </>}
        children
        {switch subText->Belt.Option.flatMap(LogicUtils.getNonEmptyString) {
        | Some(subText) => <div className=subTextClass> {React.string(subText)} </div>
        | None => React.null
        }}
      </div>
    </AddDataAttributes>
  }
}

module FieldError = {
  @react.component
  let make = (
    ~meta: ReactFinalForm.fieldRenderPropsMeta,
    ~alwaysShow=false,
    ~errorClass="",
    ~showErrorOnChange=false,
  ) => {
    let errorTextStyle = "text-red-950 dark:text-red-400 text-fs-10 font-medium ml-1"
    let error = if meta.touched || alwaysShow || (showErrorOnChange && meta.modified) {
      if !(meta.submitError->Js.Nullable.isNullable) && !meta.dirtySinceLastSubmit {
        Js.Nullable.toOption(meta.submitError)
      } else {
        Js.Nullable.toOption(meta.error)
      }
    } else {
      None
    }

    switch error {
    | Some(err) =>
      <AddDataAttributes attributes=[("data-form-error", err)]>
        <div
          className={`flex flex-row items-center ${errorTextStyle} pt-2 leading-4 text-start ${errorClass}`}>
          <FormErrorIcon />
          {React.string(err)}
        </div>
      </AddDataAttributes>
    | None => React.null
    }
  }
}

module FieldErrorRenderer = {
  @react.component
  let make = (~field: inputFieldType, ~errorClass="") => {
    <ReactFinalForm.Field
      name={field.name}
      validate=?{field.validate}
      render={({meta}) => <FieldError meta errorClass />}
    />
  }
}

module FieldInputRenderer = {
  @react.component
  let make = (
    ~field: inputFieldType,
    ~customRender=?,
    ~showError=true,
    ~errorClass="",
    ~showErrorOnChange=false,
  ) => {
    React.cloneElement(
      <ReactFinalForm.Field
        name={field.name}
        format=?{field.format}
        parse=?{field.parse}
        validate=?{field.validate}
        render={switch customRender {
        | Some(fn) => fn

        | None =>
          ({input, meta}) => {
            <>
              {field.customInput(~input, ~placeholder=field.placeholder)}
              {if showError {
                <FieldError meta errorClass showErrorOnChange />
              } else {
                React.null
              }}
            </>
          }
        }}
      />,
      {"type": field.type_},
    )
  }
}

module ComboFieldsRenderer = {
  @react.component
  let make = (~field: fieldInfoType) => {
    <div>
      <ButtonGroup wrapperClass="flex flex-row items-center">
        {field.inputFields
        ->Array.mapWithIndex((field, i) => {
          <ErrorBoundary key={string_of_int(i)}>
            <FieldInputRenderer field showError=false />
          </ErrorBoundary>
        })
        ->React.array}
      </ButtonGroup>
      <div>
        {field.inputFields
        ->Array.mapWithIndex((field, i) => {
          <ErrorBoundary key={string_of_int(i)}>
            <FieldErrorRenderer field />
          </ErrorBoundary>
        })
        ->React.array}
      </div>
    </div>
  }
}

module ComboFieldsRenderer3 = {
  module ComboFieldsRecursive = {
    @react.component
    let make = (
      ~inputFields,
      ~fieldsState=[],
      ~renderInputs: array<ReactFinalForm.fieldRenderProps> => React.element,
      ~renderComboFields: (
        ~inputFields: array<inputFieldType>,
        ~fieldsState: array<ReactFinalForm.fieldRenderProps>,
        ~renderInputs: array<ReactFinalForm.fieldRenderProps> => React.element,
      ) => React.element,
    ) => {
      if inputFields->Array.length === 0 {
        renderInputs(fieldsState)
      } else {
        let inputField =
          inputFields[0]->Belt.Option.getWithDefault(makeInputFieldInfo(~name="", ()))

        let restInputFields = Js.Array2.sliceFrom(inputFields, 1)

        <ReactFinalForm.Field
          name=inputField.name
          parse=?inputField.parse
          format=?inputField.format
          validate=?{inputField.validate}>
          {fieldState => {
            let newFieldsState = Array.concatMany([], [fieldsState, [fieldState]])

            renderComboFields(
              ~inputFields=restInputFields,
              ~renderInputs,
              ~fieldsState=newFieldsState,
            )
          }}
        </ReactFinalForm.Field>
      }
    }
  }

  let rec renderComboFields = (~inputFields, ~fieldsState, ~renderInputs) => {
    <ComboFieldsRecursive inputFields fieldsState renderComboFields renderInputs />
  }

  @react.component
  let make = (
    ~inputFields,
    ~fieldsState=[],
    ~renderInputs: array<ReactFinalForm.fieldRenderProps> => React.element,
  ) => {
    <ComboFieldsRecursive inputFields fieldsState renderComboFields renderInputs />
  }
}

module DesktopRow = {
  @react.component
  let make = (~children, ~wrapperClass="", ~itemWrapperClass="mx-4", ~backgroundColor="") => {
    <div className={`flex flex-col md:flex-row md:flex-wrap ${backgroundColor} ${wrapperClass}`}>
      {children->React.Children.map(element => {
        if element !== React.null {
          <AddDataAttributes attributes=[("data-component", "desktopRow")]>
            <div className={`flex-1 space-y-2 ${itemWrapperClass}`}> element </div>
          </AddDataAttributes>
        } else {
          React.null
        }
      })}
    </div>
  }
}

module FieldRenderer = {
  @react.component
  let make = (
    ~field: fieldInfoType,
    ~fieldWrapperClass="",
    ~labelClass="",
    ~labelTextStyleClass="",
    ~labelPadding="",
    ~errorClass="",
    ~subTextClass="",
    ~subHeadingClass="",
    ~showErrorOnChange=false,
  ) => {
    let portalKey = ""

    let isVisible = true

    if isVisible {
      let names = field.inputNames->Array.joinWith("-")

      <Portal to=portalKey>
        <AddDataAttributes attributes=[("data-component", "fieldRenderer")]>
          <ErrorBoundary>
            <FieldWrapper
              label=field.label
              customLabelIcon=?field.customLabelIcon
              labelClass
              labelTextStyleClass
              labelPadding
              subHeading=?field.subHeading
              subHeadingIcon=?field.subHeadingIcon
              subText=?field.subText
              description=?field.description
              descriptionComponent=?field.descriptionComponent
              isRequired=field.isRequired
              toolTipPosition=?field.toolTipPosition
              fieldWrapperClass
              subTextClass
              subHeadingClass
              dataId=names>
              {if field.inputFields->Array.length === 1 {
                let field =
                  field.inputFields[0]->Belt.Option.getWithDefault(makeInputFieldInfo(~name="", ()))

                <ErrorBoundary>
                  <FieldInputRenderer field errorClass showErrorOnChange />
                </ErrorBoundary>
              } else {
                switch field.comboCustomInput {
                | Some(renderInputs) =>
                  <ComboFieldsRenderer3 inputFields=field.inputFields renderInputs />
                | None => <ComboFieldsRenderer field />
                }
              }}
            </FieldWrapper>
          </ErrorBoundary>
        </AddDataAttributes>
      </Portal>
    } else {
      React.null
    }
  }
}

module FormError = {
  @react.component
  let make = (~form: ReactFinalForm.formApi) => {
    let (submitErrors, setSubmitErrors) = React.useState(() => None)

    let subscriptionJson = {
      let subscriptionDict = Dict.make()

      Dict.set(subscriptionDict, "submitErrors", Js.Json.boolean(true))

      Js.Json.object_(subscriptionDict)
    }

    React.useEffect0(() => {
      let unsubscribe = form.subscribe(formState => {
        setSubmitErrors(_ => formState.submitErrors->Js.Nullable.toOption)

        ()
      }, subscriptionJson)

      Some(unsubscribe)
    })
    switch submitErrors {
    | Some(errorsJson) =>
      switch errorsJson->Js.Json.decodeObject {
      | Some(dict) =>
        let errStr = switch Dict.get(dict, "FORM_ERROR") {
        | Some(err) => LogicUtils.getStringFromJson(err, "")
        | None => "Error occurred on submit"
        }
        <div className="text-red-950"> {React.string(errStr)} </div>
      | None => React.null
      }
    | None => React.null
    }
  }
}

type modalObj = {
  confirmType: string,
  confirmText: React.element,
  buttonText: string,
  cancelButtonText: string,
  popUpType: PopUpState.popUpType,
}

module SubmitButton = {
  @react.component
  let make = (
    ~text="Submit",
    ~disabledParamter=false,
    ~icon=Button.NoIcon,
    ~rightIcon=Button.NoIcon,
    ~loginPageValidator=false,
    ~customSumbitButtonStyle="",
    ~showToolTip=true,
    ~buttonType=Button.Primary,
    ~loadingText="",
    ~buttonSize=?,
    ~toolTipPosition=ToolTip.Top,
    ~tooltipPositioning: ToolTip.tooltipPositioning=#fixed,
    ~withDialog=false,
    ~modalObj: option<modalObj>=?,
    ~tooltipWidthClass="w-64",
    ~tooltipForWidthClass="",
    ~tooltipForHeight="h-full",
    ~userInteractionRequired=false,
    ~customTextSize=?,
    ~customPaddingClass=?,
    ~textStyle=?,
    ~textWeight=?,
    ~customHeightClass=?,
  ) => {
    let dict = Dict.make()
    [
      "hasSubmitErrors",
      "hasValidationErrors",
      "errors",
      "submitErrors",
      "submitting",
    ]->Array.forEach(item => {
      Dict.set(dict, item, Js.Json.boolean(true))
    })

    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      dict->Js.Json.object_->Js.Nullable.return,
    )
    let {hasValidationErrors, hasSubmitErrors, submitting, dirtySinceLastSubmit, errors} = formState

    let errorsList = JsonFlattenUtils.flattenObject(errors, false)->Dict.toArray

    let hasError = {
      if loginPageValidator {
        hasValidationErrors
      } else {
        (hasValidationErrors || hasSubmitErrors || submitting) && !dirtySinceLastSubmit
      }
    }

    let disabled = hasError || disabledParamter

    let showPopUp = PopUpState.useShowPopUp()
    let (avoidDisable, setAvoidDisable) = React.useState(_ => userInteractionRequired)
    React.useEffect0(() => {
      let onClick = {
        _ev => {
          setAvoidDisable(_ => false)
        }
      }
      Window.addEventListener("click", onClick)
      Some(
        () => {
          Window.removeEventListener("click", onClick)
        },
      )
    })
    let form = ReactFinalForm.useForm()
    let openPopUp = (confirmType, confirmText, buttonText, cancelButtonText, popUpType) => {
      showPopUp({
        popUpType: (popUpType, WithIcon),
        heading: confirmType,
        description: confirmText,
        handleConfirm: {text: buttonText, onClick: _ => form.submit()->ignore},
        handleCancel: {text: cancelButtonText},
      })
    }
    let popUpBtn =
      <Button
        text
        buttonType
        buttonState={disabled ? Disabled : Normal}
        onClick={_ => {
          if !disabled {
            switch modalObj {
            | Some({confirmType, confirmText, buttonText, cancelButtonText, popUpType}) =>
              openPopUp(confirmType, confirmText, buttonText, cancelButtonText, popUpType)

            | None => ()
            }
          }
        }}
        leftIcon=icon
        rightIcon
        customButtonStyle={customSumbitButtonStyle}
        ?buttonSize
        ?customTextSize
        ?customPaddingClass
        ?textStyle
        ?textWeight
      />

    let buttonState: Button.buttonState =
      loadingText !== "" && submitting ? Loading : !avoidDisable && disabled ? Disabled : Normal

    let submitBtn =
      <>
        <button type_="submit" className="hidden" />
        <Button
          text
          buttonType
          buttonState
          loadingText
          onClick={_ev => {
            form.submit()->ignore
          }} //either onclick or type_should be called #warning
          leftIcon=icon
          rightIcon
          customButtonStyle={customSumbitButtonStyle}
          ?buttonSize
          ?customHeightClass
          ?textStyle
        />
      </>

    let button = withDialog ? popUpBtn : submitBtn
    if errorsList->Array.length === 0 {
      button
    } else {
      let description =
        errorsList
        ->Array.map(entry => {
          let (key, jsonValue) = entry
          let value = LogicUtils.getStringFromJson(jsonValue, "Error")

          `${key->LogicUtils.snakeToTitle}: ${value}`
        })
        ->Array.joinWith("\n")
      let tooltipStyle = hasError ? "bg-infra-red-900" : ""
      if showToolTip && !avoidDisable {
        <ToolTip
          description
          toolTipFor=button
          toolTipPosition
          customStyle=tooltipStyle
          tooltipPositioning
          tooltipWidthClass
          height=tooltipForHeight
          tooltipForWidthClass
        />
      } else {
        button
      }
    }
  }
}

module FieldsRenderer = {
  @react.component
  let make = (
    ~fields,
    ~fieldWrapperClass="",
    ~labelClass="",
    ~labelPadding="",
    ~errorClass="",
    ~subTextClass="",
    ~subHeadingClass="",
  ) => {
    Array.mapWithIndex(fields, (field, i) => {
      <FieldRenderer
        key={string_of_int(i)}
        field
        fieldWrapperClass
        labelClass
        labelPadding
        errorClass
        subTextClass
        subHeadingClass
      />
    })->React.array
  }
}

module FormContent = {
  @react.component
  let make = (
    ~form: ReactFinalForm.formApi,
    ~title,
    ~fields,
    ~handleSubmit,
    ~fieldsWrapperClass="",
    ~fieldWrapperClass="",
    ~formClass="",
    ~showFormSpy=false,
    ~submitButtonText=?,
  ) => {
    <form onSubmit={handleSubmit}>
      <div className=formClass>
        {switch title {
        | Some(str) => <div> {React.string(str)} </div>
        | None => React.null
        }}
        <div className={`p-2 ${fieldsWrapperClass}`}>
          {if showFormSpy {
            <div className="flex flex-1 flex-row overflow-hidden">
              <div className="flex flex-1 flex-col overflow-scroll p-4">
                <FieldsRenderer fields fieldWrapperClass />
              </div>
              <FormValuesSpy wrapperClass="h-full w-1/3" restrictToLocal=false />
            </div>
          } else {
            <FieldsRenderer fields fieldWrapperClass />
          }}
        </div>
        <div className="p-3">
          <FormError form />
        </div>
        <div className="flex justify-center mb-2">
          <SubmitButton text=?submitButtonText />
        </div>
      </div>
    </form>
  }
}

@react.component
let make = (
  ~title=?,
  ~fields: array<fieldInfoType>,
  ~initialValues,
  ~validate=?,
  ~submitButtonText=?,
  ~onSubmit: (
    ReactFinalForm.formValues,
    ReactFinalForm.formApi,
  ) => Promise.t<Js.Nullable.t<Js.Json.t>>,
  ~fieldsWrapperClass="",
  ~fieldWrapperClass="",
  ~formClass="",
  ~showFormSpy=false,
) => {
  <ReactFinalForm.Form
    onSubmit
    validate=?{validate}
    initialValues
    subscription=ReactFinalForm.subscribeToValues
    render={({form, handleSubmit}) => {
      <FormContent
        form
        title
        fields
        handleSubmit
        fieldsWrapperClass
        fieldWrapperClass
        formClass
        showFormSpy
        ?submitButtonText
      />
    }}
  />
}
