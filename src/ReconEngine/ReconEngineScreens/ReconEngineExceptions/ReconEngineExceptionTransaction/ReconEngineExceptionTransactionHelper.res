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
        "Transaction partially matched",
        "Please review the exceptions page for details",
        `exceptions/recon/${transaction.transaction_id}`,
        "See Exception",
      )
    | Void => (
        "Transaction ignored successfully",
        "Your transaction has been moved to transactions page",
        `transactions/${transaction.transaction_id}`,
        "See Transaction",
      )
    | Posted(Manual) | Matched(Force) | Matched(Manual) | Matched(Auto) => (
        "Transaction matched successfully",
        "Your transaction has been moved to transactions page",
        `transactions/${transaction.transaction_id}`,
        "See Transaction",
      )
    | Missing
    | Expected
    | UnderAmount(Expected)
    | OverAmount(Expected)
    | UnderAmount(Mismatch)
    | OverAmount(Mismatch)
    | DataMismatch
    | Archived
    | UnknownDomainTransactionStatus
    | UnderAmount(UnknownDomainTransactionAmountMismatchStatus)
    | OverAmount(UnknownDomainTransactionAmountMismatchStatus)
    | Matched(UnknownDomainTransactionMatchedStatus)
    | Posted(UnknownDomainTransactionPostedStatus) => (
        "Transaction processed successfully",
        "Please review the transactions page for details",
        `transactions/${transaction.transaction_id}`,
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
          <Link to_={GlobalVars.appendDashboardPath(~url=`/v1/recon-engine/${link}`)}>
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
    ~config: ReconEngineExceptionsTypes.resolutionConfig,
    ~children,
    ~activeModal,
    ~setActiveModal,
  ) => {
    let showModal = switch (exceptionStage, activeModal) {
    | (ResolvingException(VoidTransaction), Some(IgnoreTransactionModal))
    | (ResolvingException(ForceReconcile), Some(ForceReconcileModal))
    | (ResolvingException(EditEntry), Some(EditEntryModal))
    | (ResolvingException(CreateNewEntry), Some(CreateEntryModal))
    | (ResolvingException(MarkAsReceived), Some(MarkAsReceivedModal))
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
        `${heading.sm.semibold} text-nd_gray-700`,
        `${body.md.regular} text-nd_gray-600 mt-1`,
      )
    | ExpandedSidePanelModal => (
        "flex flex-col justify-start h-screen w-1/2 float-right overflow-hidden !bg-white dark:!bg-jp-gray-lightgray_background",
        "relative h-full flex flex-col overflow-y-auto",
        `${heading.sm.semibold} text-nd_gray-700`,
        `${body.md.regular} text-nd_gray-600 mt-1`,
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
      switch currentExceptionDetails.transaction_status {
      | DataMismatch
      | OverAmount(Mismatch)
      | UnderAmount(Mismatch) =>
        entryDetails
        ->Array.filter(entry => entry.status == Mismatched)
        ->Array.map(entry => entry.data)
        ->LogicUtils.getValueFromArray(0, Js.Json.null)
      | Posted(Manual)
      | Matched(Force)
      | Matched(Manual)
      | Matched(Auto)
      | OverAmount(Expected)
      | UnderAmount(Expected)
      | Archived
      | Void
      | Missing
      | Expected
      | PartiallyReconciled
      | Posted(UnknownDomainTransactionPostedStatus)
      | Matched(UnknownDomainTransactionMatchedStatus)
      | OverAmount(UnknownDomainTransactionAmountMismatchStatus)
      | UnderAmount(UnknownDomainTransactionAmountMismatchStatus)
      | UnknownDomainTransactionStatus => Js.Json.null
      }
    }, [currentExceptionDetails.transaction_status])

    let (heading, subHeading) = switch currentExceptionDetails.transaction_status {
    | DataMismatch
    | OverAmount(Mismatch)
    | UnderAmount(Mismatch) =>
      getHeadingAndSubHeadingForMismatch(mismatchData, ~accountInfoMap)
    | Expected | OverAmount(Expected) | UnderAmount(Expected) => (
        "Expected",
        `This transaction is marked as expected since ${currentExceptionDetails.created_at->DateTimeUtils.getFormattedDate(
            "DD MMM YYYY, hh:mm A",
          )}`,
      )
    | Missing => (
        "Missing",
        `This transaction is marked as expected since ${currentExceptionDetails.created_at->DateTimeUtils.getFormattedDate(
            "DD MMM YYYY, hh:mm A",
          )}`,
      )
    | PartiallyReconciled => (
        "Partially Matched",
        "Please review the details and take necessary actions.",
      )
    | Posted(Manual)
    | Matched(Force)
    | Matched(Manual)
    | Matched(Auto)
    | Archived
    | Void
    | Posted(UnknownDomainTransactionPostedStatus)
    | Matched(UnknownDomainTransactionMatchedStatus)
    | OverAmount(UnknownDomainTransactionAmountMismatchStatus)
    | UnderAmount(UnknownDomainTransactionAmountMismatchStatus)
    | UnknownDomainTransactionStatus => ("", "")
    }

    <div className="flex flex-col">
      <div className={`text-nd_red-700 ${body.md.semibold} mb-2`}> {heading->React.string} </div>
      <div className={`${body.md.regular} text-nd_gray-600`}> {subHeading->React.string} </div>
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

module AccountComboSelectInput = {
  @react.component
  let make = (
    ~accountsList: array<ReconEngineTypes.accountType>,
    ~disabled: bool,
    ~fieldsArray: array<ReactFinalForm.fieldRenderProps>,
    ~setTransformationsList,
  ) => {
    open APIUtils
    open ReconEngineUtils

    let accountIdField = (fieldsArray[0]->Option.getOr(ReactFinalForm.fakeFieldRenderProps)).input
    let accountNameField = (fieldsArray[1]->Option.getOr(ReactFinalForm.fakeFieldRenderProps)).input
    let form = ReactFinalForm.useForm()
    let getURL = useGetURL()
    let fetchDetails = useGetMethod()

    let fetchTransformationConfigs = async (accountId: string) => {
      try {
        let url = getURL(
          ~entityName=V1(HYPERSWITCH_RECON),
          ~methodType=Get,
          ~hyperswitchReconType=#TRANSFORMATION_CONFIG,
          ~queryParameters=Some(`account_id=${accountId}`),
        )
        let res = await fetchDetails(url)
        setTransformationsList(_ => res->getArrayDataFromJson(transformationConfigItemToObjMapper))
      } catch {
      | _ => setTransformationsList(_ => [])
      }
    }

    let input: ReactFinalForm.fieldRenderPropsInput = {
      ...accountIdField,
      onChange: ev => {
        let accountId = ev->Identity.formReactEventToString
        let accountName =
          accountsList
          ->Array.find(acc => acc.account_id == accountId)
          ->Option.mapOr("", acc => acc.account_name)

        accountIdField.onChange(ev)
        accountNameField.onChange(accountName->JSON.Encode.string->Identity.anyTypeToReactEvent)
        form.change("transformation_id", ""->JSON.Encode.string)
        if accountId->isNonEmptyString {
          fetchTransformationConfigs(accountId)->ignore
        }
      },
    }

    <SelectBox
      input
      options={accountsList->Array.map((account): SelectBox.dropdownOption => {
        {
          label: account.account_name,
          value: account.account_id,
        }
      })}
      buttonText="Select account"
      allowMultiSelect=false
      deselectDisable=false
      isHorizontal=true
      disableSelect=disabled
      fullLength=true
    />
  }
}

let accountTransformationSelectInputField = (~accountsList, ~setTransformationsList) => {
  <FormRenderer.FieldRenderer
    labelClass="font-semibold"
    field={FormRenderer.makeMultiInputFieldInfo(
      ~label="Account",
      ~comboCustomInput={
        {
          fn: (fieldsArray: array<ReactFinalForm.fieldRenderProps>) => {
            <AccountComboSelectInput
              accountsList disabled=false fieldsArray setTransformationsList
            />
          },
          names: ["account", "account_name"],
        }
      },
      ~inputFields=[
        FormRenderer.makeInputFieldInfo(~name="account"),
        FormRenderer.makeInputFieldInfo(~name="account_name"),
      ],
      ~isRequired=true,
    )}
  />
}

let getEntriesSections = (
  ~groupedEntries: Dict.t<array<exceptionResolutionEntryType>>,
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

module BottomActionBar = {
  @react.component
  let make = (~config: ReconEngineExceptionsTypes.bottomBarConfig) => {
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
