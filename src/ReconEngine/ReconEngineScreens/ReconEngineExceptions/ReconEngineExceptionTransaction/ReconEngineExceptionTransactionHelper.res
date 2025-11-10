open Typography
open ReconEngineExceptionTransactionUtils
open ReconEngineExceptionTransactionTypes
open LogicUtils

module CustomToastElement = {
  @react.component
  let make = (~transaction: ReconEngineTypes.transactionType, ~toastKey: string) => {
    let hideToast = ToastState.useHideToast()

    let (message, description, link, linkText) = switch transaction.transaction_status {
    | PartiallyReconciled => (
        "Transaction partially reconciled",
        "Please review the exceptions page for details",
        `${GlobalVars.appendDashboardPath(
            ~url=`/v1/recon-engine/exceptions/recon/${transaction.id}`,
          )}`,
        "See Exception",
      )
    | Void => (
        "Transaction ignored successfully",
        "Your transaction has been moved to transactions page",
        `${GlobalVars.appendDashboardPath(~url=`/v1/recon-engine/transactions/${transaction.id}`)}`,
        "See Transaction",
      )
    | Posted => (
        "Transaction matched successfully",
        "Your transaction has been moved to transactions page",
        `${GlobalVars.appendDashboardPath(~url=`/v1/recon-engine/transactions/${transaction.id}`)}`,
        "See Transaction",
      )
    | _ => (
        "Transaction processed successfully",
        "Please review the transactions page for details",
        `${GlobalVars.appendDashboardPath(~url=`/v1/recon-engine/transactions/${transaction.id}`)}`,
        "See Transaction",
      )
    }

    <div
      className="flex flex-row items-start justify-between bg-nd_gray-800 rounded-xl p-6 pointer-events-auto min-w-[500px] shadow-lg m-2">
      <div className="flex flex-row items-start gap-4 flex-1">
        <Icon name="nd-check-circle-outline" size=24 className="text-nd_green-500 mt-1" />
        <div className="flex flex-col gap-2">
          <p className={`${heading.sm.semibold} text-nd_gray-25`}> {message->React.string} </p>
          <p className={`${body.md.regular} text-nd_gray-300`}> {description->React.string} </p>
          <Link to_=link>
            <p
              className={`${body.md.semibold} text-nd_primary_blue-400 hover:text-nd_primary_blue-300 cursor-pointer`}>
              {linkText->React.string}
            </p>
          </Link>
        </div>
      </div>
      <div onClick={_ => hideToast(toastKey)}>
        <Icon
          name="nd-cross"
          size=20
          className="text-nd_gray-400 hover:text-nd_gray-200 cursor-pointer ml-4"
        />
      </div>
    </div>
  }
}

module ResolutionModal = {
  @react.component
  let make = (
    ~exceptionStage: exceptionResolutionStage,
    ~setExceptionStage,
    ~setSelectedRows,
    ~config: resolutionConfig,
    ~children,
    ~activeModal,
    ~setActiveModal,
  ) => {
    let showModal = switch (exceptionStage, activeModal) {
    | (ResolvingException(VoidTransaction), Some(IgnoreTransactionModal)) => true
    | (ResolvingException(ForceReconcile), Some(ForceReconcileModal)) => true
    | (ResolvingException(EditEntry), Some(EditEntryModal)) => true
    | (ResolvingException(CreateNewEntry), Some(CreateEntryModal)) => true
    | (ResolvingException(MarkAsReceived), Some(MarkAsReceivedModal)) => true
    | (ResolvingException(LinkStagingEntriesToTransaction), Some(LinkStagingEntriesModal)) => true
    | _ => false
    }

    let (modalClass, childClass, headingClass, descriptionClass) = switch config.layout {
    | CenterModal => (
        "w-full max-w-2xl mx-auto my-auto dark:!bg-jp-gray-lightgray_background",
        "mx-4 mb-4 h-full",
        `${heading.sm.semibold} text-nd_gray-700`,
        `${body.md.regular} text-nd_gray-600 mt-1`,
      )
    | SidePanelModal => (
        "flex flex-col justify-start h-screen w-1/3 float-right overflow-hidden !bg-white dark:!bg-jp-gray-lightgray_background",
        "relative h-full flex flex-col overflow-y-auto",
        "",
        "",
      )
    | ExpandedSidePanelModal => (
        "flex flex-col justify-start h-screen w-1/2 float-right overflow-hidden !bg-white dark:!bg-jp-gray-lightgray_background",
        "relative h-full flex flex-col overflow-y-auto",
        "",
        "",
      )
    }

    let onCloseClickCustomFun = _ => {
      switch exceptionStage {
      | ResolvingException(VoidTransaction) => {
          setExceptionStage(_ => ShowResolutionOptions(NoResolutionOptionNeeded))
          setActiveModal(_ => None)
        }
      | ResolvingException(ForceReconcile) => {
          setExceptionStage(_ => ShowResolutionOptions(NoResolutionOptionNeeded))
          setActiveModal(_ => None)
        }
      | ResolvingException(EditEntry) => {
          setExceptionStage(_ => ShowResolutionOptions(FixEntries))
          setSelectedRows(_ => [])
          setActiveModal(_ => None)
        }
      | ResolvingException(CreateNewEntry) => {
          setExceptionStage(_ => ShowResolutionOptions(NoResolutionOptionNeeded))
          setActiveModal(_ => None)
        }
      | _ => ()
      }
    }

    let setShowModal = (fn: bool => bool) => {
      let shouldShow = fn(showModal)
      if !shouldShow {
        setActiveModal(_ => None)
      }
    }

    <Modal
      setShowModal
      showModal
      closeOnOutsideClick={config.closeOnOutsideClick}
      onCloseClickCustomFun
      modalClass
      childClass
      modalHeadingDescription={config.description->Option.getOr("")}
      modalHeadingClass={headingClass}
      modalDescriptionClass={descriptionClass}
      modalHeading={config.heading}>
      {children}
    </Modal>
  }
}

module ExceptionDataDisplay = {
  @react.component
  let make = (
    ~currentExceptionDetails: ReconEngineTypes.transactionType,
    ~entryDetails: array<ReconEngineTypes.entryType>,
    ~accountInfoMap: Dict.t<accountInfo>=Dict.make(),
  ) => {
    let mismatchData = React.useMemo(() => {
      if currentExceptionDetails.transaction_status === Mismatched {
        entryDetails
        ->Array.filter(entry => entry.status == Mismatched)
        ->Array.map(entry => entry.data)
        ->LogicUtils.getValueFromArray(0, Js.Json.null)
      } else {
        Js.Json.null
      }
    }, [currentExceptionDetails.transaction_status])

    let (heading, subHeading) = switch currentExceptionDetails.transaction_status {
    | Mismatched => getHeadingAndSubHeadingForMismatch(mismatchData, ~accountInfoMap)
    | Expected => (
        "Expected",
        `This transaction is marked as expected since ${currentExceptionDetails.created_at->DateTimeUtils.getFormattedDate(
            "DD MMM YYYY, hh:mm A",
          )}`,
      )
    | PartiallyReconciled => (
        "Partially Reconciled",
        "Please review the details and take necessary actions.",
      )
    | _ => ("", "")
    }

    <div className="flex flex-col">
      <div className={`text-nd_red-700 ${body.md.semibold} mb-2`}> {heading->React.string} </div>
      <div className={`${body.md.regular} text-nd_gray-600`}> {subHeading->React.string} </div>
    </div>
  }
}

module MetadataInput = {
  @react.component
  let make = (
    ~input: ReactFinalForm.fieldRenderPropsInput,
    ~placeholder as _,
    ~disabled: bool=false,
  ) => {
    let currentValue = input.value->getDictFromJsonObject

    let initialRows = React.useMemo(() => {
      currentValue
      ->Dict.toArray
      ->Array.map(((key, value)) => {
        {
          id: randomString(~length=10),
          key,
          value: value->getStringFromJson(""),
        }
      })
    }, [])

    let (metadataRows, setMetadataRows) = React.useState(_ =>
      initialRows->Array.length > 0 ? initialRows : []
    )

    let updateFormValue = (rows: array<metadataRow>) => {
      let metadataDict = Dict.make()
      rows->Array.forEach(row => {
        if row.key->isNonEmptyString {
          Dict.set(metadataDict, row.key, row.value->JSON.Encode.string)
        }
      })
      input.onChange(metadataDict->JSON.Encode.object->Identity.anyTypeToReactEvent)
    }

    let addNewRow = () => {
      let newRows = metadataRows->Array.concat([
        {
          id: randomString(~length=10),
          key: "",
          value: "",
        },
      ])
      setMetadataRows(_ => newRows)
      updateFormValue(newRows)
    }

    let deleteRow = (id: string) => {
      let newRows = metadataRows->Array.filter(row => row.id !== id)
      setMetadataRows(_ => newRows)
      updateFormValue(newRows)
    }

    let updateRowKey = (id: string, newKey: string) => {
      let newRows = metadataRows->Array.map(row => row.id === id ? {...row, key: newKey} : row)
      setMetadataRows(_ => newRows)
      updateFormValue(newRows)
    }

    let updateRowValue = (id: string, newValue: string) => {
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

    <div className="flex flex-col gap-3 mt-4">
      <div className="flex flex-col gap-3 border border-nd_gray-200 rounded-xl p-4">
        <p className={`${body.md.semibold} text-nd_gray-700 mb-4`}>
          {"Metadata "->React.string}
          <span className={`text-nd_gray-400 ${body.md.medium}`}>
            {"(optional)"->React.string}
          </span>
        </p>
        <style> {React.string(expandableTableScrollbarCss)} </style>
        <div className="flex flex-col gap-3 max-h-40 overflow-y-scroll show-scrollbar pr-2">
          {metadataRows
          ->Array.map(row => {
            <div
              key={row.id}
              className="flex items-center gap-3 border border-nd_gray-200 rounded-xl p-3 bg-nd_gray-0">
              <RenderIf condition={!disabled}>
                <div className="cursor-pointer" onClick={_ => deleteRow(row.id)}>
                  <Icon name="nd-delete-dustbin-02" size=16 className="text-nd_red-500" />
                </div>
              </RenderIf>
              <div className="flex-1">
                {InputFields.textInput(~inputStyle="!rounded-xl", ~isDisabled=disabled)(
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
                {InputFields.textInput(~inputStyle="!rounded-xl", ~isDisabled=disabled)(
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
          })
          ->React.array}
        </div>
        <RenderIf condition={!disabled}>
          <div className="flex flex-row justify-start h-full items-end mt-2">
            <div
              className="flex items-center gap-2 hover:text-nd_primary_blue-600 hover:scale-105 cursor-pointer"
              onClick={_ => addNewRow()}>
              <Icon
                name="nd-plus" size=16 className={`text-nd_primary_blue-500 ${body.md.semibold}`}
              />
              <span className={`${body.md.semibold} text-nd_primary_blue-500`}>
                {"Add Field"->React.string}
              </span>
            </div>
          </div>
        </RenderIf>
      </div>
    </div>
  }
}

let reasonMultiLineTextInputField = (~label) => {
  <FormRenderer.FieldRenderer
    labelClass="font-semibold"
    field={FormRenderer.makeFieldInfo(
      ~label,
      ~name="reason",
      ~placeholder="Enter remark",
      ~customInput=InputFields.multiLineTextInput(
        ~isDisabled=false,
        ~rows=Some(4),
        ~cols=Some(50),
        ~maxLength=500,
        ~customClass="!h-28 !rounded-xl",
      ),
      ~isRequired=true,
    )}
  />
}

let accountSelectInputField = (
  ~entriesList: array<ReconEngineTypes.entryType>,
  ~isNewlyCreatedEntry: bool,
  ~disabled: bool=false,
) => {
  <FormRenderer.FieldRenderer
    labelClass="font-semibold"
    field={FormRenderer.makeFieldInfo(
      ~label="Account",
      ~name="account",
      ~placeholder="Select account",
      ~customInput=InputFields.selectInput(
        ~options=getUniqueAccountOptionsFromEntries(entriesList),
        ~fullLength=true,
        ~buttonText="Select account",
        ~disableSelect=!isNewlyCreatedEntry || disabled,
      ),
      ~isRequired=true,
      ~disabled=!isNewlyCreatedEntry || disabled,
    )}
  />
}

let entryTypeSelectInputField = (~disabled: bool=false) => {
  <FormRenderer.FieldRenderer
    labelClass="font-semibold"
    field={FormRenderer.makeFieldInfo(
      ~label="Entry Direction",
      ~name="entry_type",
      ~placeholder="Select direction",
      ~customInput=InputFields.selectInput(
        ~options=[
          {
            label: "Credit",
            value: "credit",
          },
          {
            label: "Debit",
            value: "debit",
          },
        ],
        ~fullLength=true,
        ~buttonText="Select direction",
        ~disableSelect=disabled,
      ),
      ~isRequired=true,
      ~disabled,
    )}
  />
}

let currencySelectInputField = (
  ~entriesList: array<ReconEngineTypes.entryType>,
  ~isNewlyCreatedEntry: bool,
  ~entryDetails: ReconEngineTypes.entryType,
  ~disabled: bool=false,
) => {
  <FormRenderer.FieldRenderer
    labelClass="font-semibold"
    field={FormRenderer.makeFieldInfo(
      ~label="Currency",
      ~name="currency",
      ~placeholder="Select currency",
      ~customInput=InputFields.selectInput(
        ~options={
          isNewlyCreatedEntry
            ? getUniqueCurrencyOptionsFromEntries(entriesList)
            : [
                {
                  label: entryDetails.currency,
                  value: entryDetails.currency,
                },
              ]
        },
        ~fullLength=true,
        ~buttonText="Select currency",
        ~disableSelect=!isNewlyCreatedEntry || disabled,
      ),
      ~isRequired=true,
      ~disabled=!isNewlyCreatedEntry || disabled,
    )}
  />
}

let amountTextInputField = (~disabled: bool=false) => {
  <FormRenderer.FieldRenderer
    labelClass="font-semibold"
    field={FormRenderer.makeFieldInfo(
      ~label="Amount",
      ~name="amount",
      ~placeholder="Enter amount",
      ~customInput=InputFields.textInput(~inputStyle="!rounded-xl", ~isDisabled=disabled),
      ~isRequired=true,
      ~disabled,
    )}
  />
}

let orderIdTextInputField = (~disabled: bool=false) => {
  <FormRenderer.FieldRenderer
    labelClass="font-semibold"
    field={FormRenderer.makeFieldInfo(
      ~label="Order ID",
      ~name="order_id",
      ~placeholder="Enter Order ID",
      ~customInput=InputFields.textInput(~inputStyle="!rounded-xl", ~isDisabled=disabled),
      ~isRequired=true,
      ~disabled,
    )}
  />
}

let effectiveAtDatePickerInputField = () => {
  <FormRenderer.FieldRenderer
    labelClass="font-semibold"
    field={FormRenderer.makeFieldInfo(
      ~label="Effective At",
      ~name="effective_at",
      ~placeholder="Enter date and time",
      ~customInput=InputFields.singleDatePickerInput(
        ~format="YYYY-MM-DDTHH:mm:ss[Z]",
        ~showTime=true,
        ~disablePastDates=false,
        ~disableFutureDates=true,
        ~fullLength=true,
      ),
      ~isRequired=true,
      ~disabled=false,
    )}
  />
}

let metadataCustomInputField = (~disabled: bool=false) => {
  <FormRenderer.FieldRenderer
    field={FormRenderer.makeFieldInfo(~label="", ~name="metadata", ~customInput=(
      ~input,
      ~placeholder,
    ) => <MetadataInput input placeholder disabled={disabled} />)}
  />
}

let getEntriesSections = (
  ~groupedEntries: Dict.t<array<ReconEngineExceptionTransactionTypes.exceptionResolutionEntryType>>,
  ~accountInfoMap,
  ~detailsFields,
  ~showTotalAmount: bool=true,
) => {
  let sectionData = calculateSectionData(
    ~groupedEntries,
    ~accountInfoMap,
    ~getBalanceByAccountType,
    ~getSumOfAmountWithCurrency,
  )

  let overallBalance = calculateOverallBalance(sectionData)

  let amountColorClass = overallBalance == 0.0 ? "text-nd_green-600" : "text-nd_red-600"

  sectionData->Array.map(((_accountId, accountInfo, accountEntries, totalAmount, currency)) => {
    let accountRows =
      accountEntries->Array.map(entry =>
        detailsFields->Array.map(
          colType => EntriesTableEntity.getCell(entry->getEntryTypeFromExceptionEntryType, colType),
        )
      )
    let rowData = accountEntries->Array.map(entry => entry->Identity.genericTypeToJson)

    let titleElement =
      <div className="flex justify-between items-center mb-4">
        <p className={`text-nd_gray-700 ${body.lg.semibold}`}>
          {accountInfo.account_info_name->React.string}
        </p>
        <RenderIf condition={showTotalAmount}>
          <div className={`${amountColorClass} ${body.lg.medium}`}>
            {CurrencyFormatUtils.valueFormatter(
              totalAmount,
              AmountWithSuffix,
              ~currency,
            )->React.string}
          </div>
        </RenderIf>
      </div>

    (
      {
        titleElement,
        rows: accountRows,
        rowData,
      }: tableSection
    )
  })
}

let getSectionRowDetails = (~sectionIndex: int, ~rowIndex: int, ~groupedEntries) => {
  open ReconEngineUtils
  open ReconEngineTransactionsUtils

  let accountId = groupedEntries->Dict.keysToArray->getValueFromArray(sectionIndex, "")
  let sectionEntries = groupedEntries->Dict.get(accountId)->Option.getOr([])
  let entry = sectionEntries->getValueFromArray(rowIndex, Dict.make()->entryItemToObjMapper)
  let filteredEntryMetadata = entry.metadata->getFilteredMetadataFromEntries
  let hasEntryMetadata = filteredEntryMetadata->Dict.keysToArray->Array.length > 0

  <RenderIf condition={hasEntryMetadata}>
    <div className="p-4">
      <div className="w-full bg-nd_gray-50 rounded-xl overflow-y-scroll !max-h-60 py-2 px-6">
        <PrettyPrintJson
          jsonToDisplay={filteredEntryMetadata->JSON.Encode.object->JSON.stringify}
        />
      </div>
    </div>
  </RenderIf>
}

let getStagingEntryDetails = (~rowIndex: int, ~stagingEntries) => {
  open ReconEngineTransactionsUtils
  let stagingEntry =
    stagingEntries->LogicUtils.getValueFromArray(
      rowIndex,
      Dict.make()->ReconEngineUtils.processingItemToObjMapper,
    )
  let filteredMetadata = stagingEntry.metadata->getFilteredMetadataFromEntries
  let hasMetadata = filteredMetadata->Dict.keysToArray->Array.length > 0

  <RenderIf condition={hasMetadata}>
    <div className="p-4">
      <div className="w-full bg-nd_gray-50 rounded-xl overflow-y-scroll !max-h-60 py-2 px-6">
        <PrettyPrintJson jsonToDisplay={filteredMetadata->JSON.Encode.object->JSON.stringify} />
      </div>
    </div>
  </RenderIf>
}

let getStagingEntrySections = (~stagingEntries, ~stagingEntriesDetailsFields) => {
  [
    {
      titleElement: React.null,
      rows: stagingEntries->Array.map(entry => {
        stagingEntriesDetailsFields->Array.map(colType => {
          ReconEngineExceptionEntity.getProcessingCell(entry, colType)
        })
      }),
      rowData: stagingEntries->Array.map(entry => entry->Identity.genericTypeToJson),
    },
  ]
}

module ResolutionButton = {
  @react.component
  let make = (~config: ReconEngineExceptionTransactionTypes.buttonConfig) => {
    <RenderIf condition={config.condition}>
      <Button
        buttonState=Normal
        buttonSize=Medium
        buttonType=Secondary
        text={config.text}
        textWeight={`${body.md.semibold}`}
        leftIcon={CustomIcon(<Icon name={config.icon} className={config.iconClass} size=16 />)}
        onClick={_ => config.onClick()}
        customButtonStyle="!w-fit"
      />
    </RenderIf>
  }
}

module BottomActionBar = {
  @react.component
  let make = (~config: ReconEngineExceptionTransactionTypes.bottomBarConfig) => {
    <>
      <p className={`${body.md.semibold} text-nd_gray-500`}> {config.prompt->React.string} </p>
      <Button
        buttonState={config.buttonEnabled ? Normal : Disabled}
        buttonSize=Medium
        buttonType=Primary
        text={config.buttonText}
        textWeight={`${body.md.semibold}`}
        customButtonStyle="!w-fit"
        onClick={_ => config.onClick()}
      />
    </>
  }
}
