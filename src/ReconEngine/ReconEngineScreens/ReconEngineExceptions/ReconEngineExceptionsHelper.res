open Typography
open ReconEngineExceptionsTypes
open ReconEngineExceptionsUtils
open LogicUtils

module ResolutionButton = {
  @react.component
  let make = (~config: ReconEngineExceptionsTypes.buttonConfig) => {
    <RenderIf condition={config.condition}>
      <Button
        buttonState=Normal
        buttonSize=Medium
        buttonType={config.buttonType}
        text={config.text}
        textWeight={`${body.md.semibold}`}
        leftIcon={CustomIcon(<Icon name={config.icon} className={config.iconClass} size=16 />)}
        onClick={_ => config.onClick()}
        customButtonStyle="!w-fit"
      />
    </RenderIf>
  }
}

module MetadataInput = {
  @react.component
  let make = (
    ~input: ReactFinalForm.fieldRenderPropsInput,
    ~placeholder as _,
    ~disabled: bool=false,
    ~metadataSchema: ReconEngineTypes.metadataSchemaType,
    ~metadataRows: array<metadataRow>,
    ~setMetadataRows: (array<metadataRow> => array<metadataRow>) => unit,
    ~isMetadataLoading: bool,
  ) => {
    let (validationErrors, setValidationErrors) = React.useState(_ => Dict.make())

    let getInitialRows = currentValue => {
      let existingRows =
        currentValue
        ->Dict.toArray
        ->Array.map(((key, value)) => {
          {
            id: randomString(~length=10),
            key,
            value: value->getStringFromJson(""),
          }
        })

      if metadataSchema.id->isNonEmptyString {
        let requiredFields =
          metadataSchema.schema_data.fields.metadata_fields->Array.filter(field => field.required)

        let requiredRows = requiredFields->Array.map(field => {
          let existingValue =
            existingRows
            ->Array.find(row => row.key == field.identifier)
            ->Option.mapOr("", row => row.value)

          {
            id: randomString(~length=10),
            key: field.identifier,
            value: existingValue,
          }
        })

        let optionalRows = existingRows->Array.filter(row => {
          !(requiredFields->Array.some(field => field.identifier == row.key))
        })

        requiredRows->Array.concat(optionalRows)
      } else {
        existingRows
      }
    }

    let updateFormValue = (rows: array<metadataRow>) => {
      let metadataDict = Dict.make()
      rows->Array.forEach(row => {
        if row.key->isNonEmptyString {
          Dict.set(metadataDict, row.key, row.value->JSON.Encode.string)
        }
      })
      input.onChange(metadataDict->JSON.Encode.object->Identity.anyTypeToReactEvent)
    }

    React.useEffect(() => {
      let currentValue = input.value->getDictFromJsonObject
      let newRows = getInitialRows(currentValue)
      setMetadataRows(_ => newRows)
      updateFormValue(newRows)
      None
    }, [metadataSchema.id])

    let isSchemaField = (key: string): bool => {
      if metadataSchema.id->isNonEmptyString {
        metadataSchema.schema_data.fields.metadata_fields->Array.some(field =>
          field.identifier == key
        )
      } else {
        false
      }
    }

    let unusedOptionalFields = React.useMemo(() => {
      if metadataSchema.id->isNonEmptyString {
        let optionalFields =
          metadataSchema.schema_data.fields.metadata_fields->Array.filter(field => !field.required)

        optionalFields->Array.filter(field => {
          !(metadataRows->Array.some(row => row.key == field.identifier))
        })
      } else {
        []
      }
    }, (metadataSchema, metadataRows))

    let addOptionalField = (key: string) => {
      let newRows = metadataRows->Array.concat([
        {
          id: randomString(~length=10),
          key,
          value: "",
        },
      ])
      setMetadataRows(_ => newRows)
      updateFormValue(newRows)
    }

    let deleteRow = (id: string, isRequired: bool) => {
      if !isRequired {
        let newRows = metadataRows->Array.filter(row => row.id !== id)
        setMetadataRows(_ => newRows)
        updateFormValue(newRows)
      }
    }

    let isRequiredField = (key: string): bool => {
      if metadataSchema.id->isNonEmptyString {
        metadataSchema.schema_data.fields.metadata_fields->Array.some(field =>
          field.identifier == key && field.required
        )
      } else {
        false
      }
    }

    let updateRowKey = (id: string, newKey: string) => {
      let row = metadataRows->Array.find(r => r.id === id)
      let newRows = metadataRows->Array.map(row => row.id === id ? {...row, key: newKey} : row)
      setMetadataRows(_ => newRows)
      updateFormValue(newRows)

      switch row {
      | Some(r) =>
        if r.value->isNonEmptyString && newKey->isEmptyString {
          setValidationErrors(prev => {
            let updated = prev->Dict.toArray->Dict.fromArray
            Dict.set(updated, id, "Please provide a key for this field")
            updated
          })
        } else if newKey->isNonEmptyString {
          let validationError = validateMetadataFieldValue(newKey, r.value, metadataSchema)
          setValidationErrors(prev => {
            let updated = prev->Dict.toArray->Dict.fromArray
            switch validationError {
            | Some(err) => Dict.set(updated, id, err)
            | None => Dict.delete(updated, id)->ignore
            }
            updated
          })
        }
      | None => ()
      }
    }

    let updateRowValue = (id: string, newValue: string) => {
      let row = metadataRows->Array.find(r => r.id === id)
      let validationError = switch row {
      | Some(r) =>
        if r.key->isEmptyString && newValue->isNonEmptyString {
          Some("Please provide a key for this field")
        } else if r.key->isNonEmptyString {
          validateMetadataFieldValue(r.key, newValue, metadataSchema)
        } else {
          None
        }
      | None => None
      }
      setValidationErrors(prev => {
        let updated = prev->Dict.toArray->Dict.fromArray
        switch validationError {
        | Some(err) => Dict.set(updated, id, err)
        | None => Dict.delete(updated, id)->ignore
        }
        updated
      })
      let newRows = metadataRows->Array.map(row => row.id === id ? {...row, value: newValue} : row)
      setMetadataRows(_ => newRows)
      updateFormValue(newRows)
    }

    let expandableTableScrollbarCss = `
      @supports (-webkit-appearance: none) {
        .show-scrollbar {
          scrollbar-width: auto;
          scrollbar-color: #CACFD8; 
        }

        .show-scrollbar::-webkit-scrollbar {
          display: block;
          height: 6px;
          width: 5px;
        }

        .show-scrollbar::-webkit-scrollbar-thumb {
          background-color: #CACFD8; 
          border-radius: 3px;
        }

        .show-scrollbar::-webkit-scrollbar-track {
          display:none;
        }
      }
    `

    <div className="flex flex-col gap-3 mb-2">
      <div className="flex flex-col gap-3 border border-nd_gray-200 rounded-xl p-4">
        <div className="flex flex-row justify-between items-center">
          <p className={`${body.md.semibold} text-nd_gray-700 mb-4`}>
            {"Metadata "->React.string}
            <span className={`text-nd_gray-400 ${body.md.medium}`}>
              {"(optional)"->React.string}
            </span>
          </p>
          <RenderIf condition={!disabled && unusedOptionalFields->Array.length > 0}>
            <SelectBox
              input={
                onChange: ev => {
                  let value = ev->Identity.formReactEventToString
                  if value->isNonEmptyString {
                    addOptionalField(value)
                  }
                },
                value: ""->JSON.Encode.string,
                name: "",
                onBlur: _ => (),
                onFocus: _ => (),
                checked: false,
              }
              options={unusedOptionalFields->Array.map((field): SelectBox.dropdownOption => {
                {
                  value: field.identifier,
                  label: field.identifier ++ " (Optional)",
                }
              })}
              buttonText="Add Field"
              allowMultiSelect=false
              deselectDisable=false
              isHorizontal=true
              fullLength=false
            />
          </RenderIf>
        </div>
        <RenderIf condition={isMetadataLoading}>
          <div className="h-full flex flex-col justify-center items-center py-10">
            <div className="animate-spin mb-1">
              <Icon name="spinner" size=20 />
            </div>
          </div>
        </RenderIf>
        <style> {React.string(expandableTableScrollbarCss)} </style>
        <RenderIf condition={!isMetadataLoading}>
          <div className="flex flex-col gap-3 max-h-40 overflow-y-scroll show-scrollbar pr-2">
            {metadataRows
            ->Array.map(row => {
              let isRequired = isRequiredField(row.key)
              let isSchema = isSchemaField(row.key)
              let validationError = validationErrors->Dict.get(row.id)
              <div
                key={row.id}
                className="flex flex-col gap-2 border border-nd_gray-200 rounded-xl p-3 bg-nd_gray-0">
                <div className="flex items-center gap-3">
                  <RenderIf condition={!disabled && !isRequired}>
                    <div className="cursor-pointer" onClick={_ => deleteRow(row.id, isRequired)}>
                      <Icon name="nd-delete-dustbin-02" size=16 className="text-nd_red-500" />
                    </div>
                  </RenderIf>
                  <RenderIf condition={isRequired}>
                    <div className="cursor-not-allowed opacity-50">
                      <Icon name="nd-delete-dustbin-02" size=16 className="text-nd_gray-400" />
                    </div>
                  </RenderIf>
                  <div className="flex-1">
                    {InputFields.textInput(
                      ~inputStyle="!rounded-xl",
                      ~isDisabled={disabled || isSchema},
                    )(
                      ~input=(
                        {
                          value: row.key->JSON.Encode.string,
                          onChange: e => {
                            let value = ReactEvent.Form.target(e)["value"]
                            updateRowKey(row.id, value)
                          },
                          onBlur: _ => (),
                          onFocus: _ => (),
                          name: "",
                          checked: false,
                        }: ReactFinalForm.fieldRenderPropsInput
                      ),
                      ~placeholder="Key",
                    )}
                  </div>
                  <div className="flex items-center text-nd_gray-400"> {"="->React.string} </div>
                  <div className="flex-1">
                    {InputFields.textInput(
                      ~inputStyle={
                        validationError->Option.isSome
                          ? "!rounded-xl !border-nd_red-500"
                          : "!rounded-xl"
                      },
                      ~isDisabled=disabled,
                    )(
                      ~input=(
                        {
                          value: row.value->JSON.Encode.string,
                          onChange: e => {
                            let value = ReactEvent.Form.target(e)["value"]
                            updateRowValue(row.id, value)
                          },
                          onBlur: _ => (),
                          onFocus: _ => (),
                          name: "",
                          checked: false,
                        }: ReactFinalForm.fieldRenderPropsInput
                      ),
                      ~placeholder="Value",
                    )}
                  </div>
                </div>
                <RenderIf condition={validationError->Option.isSome}>
                  <div className="pl-8">
                    <p className={`${body.sm.regular} text-nd_red-600`}>
                      {validationError->Option.getOr("")->React.string}
                    </p>
                  </div>
                </RenderIf>
              </div>
            })
            ->React.array}
          </div>
        </RenderIf>
      </div>
    </div>
  }
}

module TransformationConfigSelectInput = {
  @react.component
  let make = (
    ~transformationsList: array<ReconEngineTypes.transformationConfigType>,
    ~disabled: bool,
    ~setMetadataSchema,
    ~setIsMetadataLoading,
    ~input: ReactFinalForm.fieldRenderPropsInput,
  ) => {
    open ReconEngineHooks

    let form = ReactFinalForm.useForm()
    let fetchMetadataSchema = useFetchMetadataSchema()

    let handleFetchMetadataSchema = async (transformationId: string) => {
      try {
        setIsMetadataLoading(_ => true)
        let schema = await fetchMetadataSchema(~transformationId)
        setMetadataSchema(_ => schema)
        setIsMetadataLoading(_ => false)
      } catch {
      | _ => {
          setMetadataSchema(_ => Dict.make()->ReconEngineUtils.metadataSchemaItemToObjMapper)
          setIsMetadataLoading(_ => false)
        }
      }
    }

    let modifiedInput: ReactFinalForm.fieldRenderPropsInput = {
      ...input,
      onChange: ev => {
        let transformationId = ev->Identity.formReactEventToString
        input.onChange(ev)
        form.change("metadata", Dict.make()->JSON.Encode.object)
        if transformationId->isNonEmptyString {
          handleFetchMetadataSchema(transformationId)->ignore
        } else {
          setMetadataSchema(_ => Dict.make()->ReconEngineUtils.metadataSchemaItemToObjMapper)
          setIsMetadataLoading(_ => false)
        }
      },
    }

    <SelectBox
      input={modifiedInput}
      options={transformationsList->Array.map((config): SelectBox.dropdownOption => {
        {
          value: config.transformation_id,
          label: config.name,
        }
      })}
      buttonText="Select transformation config"
      allowMultiSelect=false
      deselectDisable=false
      isHorizontal=true
      disableSelect=disabled
      fullLength=true
    />
  }
}

let transformationConfigSelectInputField = (
  ~transformationsList: array<ReconEngineTypes.transformationConfigType>,
  ~disabled: bool=false,
  ~setMetadataSchema,
  ~setIsMetadataLoading,
) => {
  <FormRenderer.FieldRenderer
    labelClass="font-semibold"
    field={FormRenderer.makeFieldInfo(
      ~label="Transformation Config",
      ~name="transformation_id",
      ~placeholder="Select transformation config",
      ~customInput=(~input, ~placeholder as _) => {
        <TransformationConfigSelectInput
          transformationsList disabled setMetadataSchema input setIsMetadataLoading
        />
      },
      ~isRequired=true,
      ~disabled,
    )}
  />
}

let metadataCustomInputField = (
  ~disabled: bool=false,
  ~metadataSchema: ReconEngineTypes.metadataSchemaType,
  ~metadataRows: array<ReconEngineExceptionsTypes.metadataRow>,
  ~setMetadataRows,
  ~isMetadataLoading,
) => {
  <FormRenderer.FieldRenderer
    field={FormRenderer.makeFieldInfo(
      ~label="",
      ~name="metadata",
      ~customInput=(~input, ~placeholder) =>
        <MetadataInput
          input
          placeholder
          disabled={disabled}
          metadataSchema
          metadataRows
          setMetadataRows
          isMetadataLoading
        />,
      ~validate=ReconEngineExceptionsUtils.validateMetadataField(~metadataRows),
    )}
  />
}
