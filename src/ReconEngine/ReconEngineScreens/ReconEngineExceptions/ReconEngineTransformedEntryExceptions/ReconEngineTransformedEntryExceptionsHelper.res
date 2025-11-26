open Typography
open ReconEngineTypes
open ReconEngineTransformedEntryExceptionsTypes
open LogicUtils
open ReconEngineUtils
open ReconEngineExceptionsTypes

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
  ~accountsList: array<ReconEngineTypes.accountType>,
  ~disabled: bool=false,
) => {
  let accountsOptions = accountsList->Array.map((account): SelectBox.dropdownOption => {
    {
      value: account.account_id,
      label: account.account_name,
    }
  })

  <FormRenderer.FieldRenderer
    labelClass="font-semibold"
    field={FormRenderer.makeFieldInfo(
      ~label="Account",
      ~name="account.account_id",
      ~placeholder="Select account",
      ~customInput=InputFields.selectInput(
        ~options=accountsOptions,
        ~fullLength=true,
        ~buttonText="Select account",
        ~disableSelect=disabled,
      ),
      ~isRequired=true,
      ~disabled,
    )}
  />
}

module AccountComboSelectInput = {
  @react.component
  let make = (
    ~accountsList: array<ReconEngineTypes.accountType>,
    ~disabled: bool,
    ~fieldsArray: array<ReactFinalForm.fieldRenderProps>,
    ~setTransformationsList: (
      array<transformationConfigType> => array<transformationConfigType>
    ) => unit,
    ~initialAccountId: string,
  ) => {
    open APIUtils
    let accountIdField = (fieldsArray[0]->Option.getOr(ReactFinalForm.fakeFieldRenderProps)).input
    let accountNameField = (fieldsArray[1]->Option.getOr(ReactFinalForm.fakeFieldRenderProps)).input
    let formApi = ReactFinalForm.useForm()
    let prevAccountIdRef = React.useRef(initialAccountId)
    let getURL = useGetURL()
    let fetchDetails = useGetMethod()

    let accountsOptions = accountsList->Array.map((account): SelectBox.dropdownOption => {
      {
        value: account.account_id,
        label: account.account_name,
      }
    })

    let fetchTransformationConfigs = async (accountId: string) => {
      try {
        let url = getURL(
          ~entityName=V1(HYPERSWITCH_RECON),
          ~methodType=Get,
          ~hyperswitchReconType=#TRANSFORMATION_CONFIG,
          ~queryParamerters=Some(`account_id=${accountId}`),
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
        accountIdField.onChange(accountId->Identity.anyTypeToReactEvent)
        accountNameField.onChange(accountName->Identity.anyTypeToReactEvent)

        let prevAccountId = prevAccountIdRef.current
        if accountId !== prevAccountId && accountId->isNonEmptyString {
          prevAccountIdRef.current = accountId
          formApi.change("transformation_id", ""->JSON.Encode.string)
          fetchTransformationConfigs(accountId)->ignore
        }
      },
    }

    <SelectBox
      input
      options=accountsOptions
      buttonText="Select account"
      allowMultiSelect=false
      deselectDisable=false
      isHorizontal=true
      disableSelect=disabled
      fullLength=true
    />
  }
}

let accountComboSelectInputField = (
  ~accountsList: array<ReconEngineTypes.accountType>,
  ~disabled: bool=false,
  ~setTransformationsList: (
    array<transformationConfigType> => array<transformationConfigType>
  ) => unit,
  ~initialAccountId: string,
): InputFields.comboCustomInputRecord => {
  let fn = (fieldsArray: array<ReactFinalForm.fieldRenderProps>) => {
    <AccountComboSelectInput
      accountsList disabled fieldsArray setTransformationsList initialAccountId
    />
  }
  {fn, names: ["account.account_id", "account.account_name"]}
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
  ~entryDetails: ReconEngineTypes.processingEntryType,
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
          [
            {
              label: entryDetails.currency,
              value: entryDetails.currency,
            },
          ]
        },
        ~fullLength=true,
        ~buttonText="Select currency",
        ~disableSelect=disabled,
      ),
      ~isRequired=true,
      ~disabled,
    )}
  />
}

let transformationConfigSelectInputField = (
  ~transformationsList: array<ReconEngineTypes.transformationConfigType>,
  ~disabled: bool=false,
) => {
  let transformationOptions = transformationsList->Array.map((config): SelectBox.dropdownOption => {
    {
      value: config.transformation_id,
      label: config.name,
    }
  })

  <FormRenderer.FieldRenderer
    labelClass="font-semibold"
    field={FormRenderer.makeFieldInfo(
      ~label="Transformation Config",
      ~name="transformation_id",
      ~placeholder="Select transformation config",
      ~customInput=InputFields.selectInput(
        ~options=transformationOptions,
        ~fullLength=true,
        ~buttonText="Select transformation config",
        ~disableSelect=disabled,
      ),
      ~isRequired=true,
      ~disabled,
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
    ) =>
      <ReconEngineExceptionTransactionHelper.MetadataInput input placeholder disabled={disabled} />
    )}
  />
}

module CustomToastElement = {
  @react.component
  let make = (~processingEntry: processingEntryType, ~toastKey: string, ~ingestionHistoryId) => {
    let hideToast = ToastState.useHideToast()

    let (message, description, link, linkText) = switch processingEntry.status {
    | Processed => (
        "Transformed entry processed successfully",
        "The entry has been moved to transformation entry page",
        `${GlobalVars.appendDashboardPath(
            ~url=`/v1/recon-engine/transformed-entries/ingestion-history/${ingestionHistoryId}?transformationHistoryId=${processingEntry.transformation_history_id}&stagingEntryId=${processingEntry.staging_entry_id}`,
          )}`,
        "See Entry",
      )
    | Void => (
        "Transformed entry ignored successfully",
        "The entry has been moved to transformation entry page",
        `transformed-entries/ingestion-history/${ingestionHistoryId}?transformationHistoryId=${processingEntry.transformation_history_id}&stagingEntryId=${processingEntry.staging_entry_id}`,
        "See Entry",
      )
    | Pending => (
        "Transformed entry is pending",
        "The entry is being processed and will be available shortly",
        `exceptions/transformed-entries/${processingEntry.staging_entry_id}`,
        "See Entry",
      )
    | NeedsManualReview => (
        "Transformed entry marked for manual review",
        "Please review the entry in the transformed entry exceptions page",
        `exceptions/transformed-entries/${processingEntry.staging_entry_id}`,
        "See Entry",
      )
    | _ => (
        "Transformed entry processed successfully",
        "The entry has been moved to transformation entry page",
        `transformed-entries/ingestion-history/${ingestionHistoryId}?transformationHistoryId=${processingEntry.transformation_history_id}&stagingEntryId=${processingEntry.staging_entry_id}`,
        "See Entry",
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

module DisplayKeyValueParams = {
  @react.component
  let make = (~heading: Table.header, ~value: Table.cell, ~wordBreak=true) => {
    let description = heading.description->Option.getOr("")

    {
      <AddDataAttributes attributes=[("data-label", heading.title)]>
        <div className="flex flex-col gap-2 py-4">
          <div
            className="flex flex-row text-fs-11 text-nd_gray-500 text-opacity-50 dark:text-nd_gray-500 dark:text-opacity-50">
            <div className={`text-nd_gray-500 ${body.md.medium}`}>
              {heading.title->React.string}
            </div>
            <RenderIf condition={description->LogicUtils.isNonEmptyString}>
              <div className="text-sm text-gray-500 mx-2 -mt-1">
                <ToolTip description={description} toolTipPosition={ToolTip.Top} />
              </div>
            </RenderIf>
          </div>
          <div className={`text-left text-nd_gray-600 ${body.md.semibold}`}>
            <Table.TableCell
              cell=value
              textAlign=Table.Left
              fontBold=true
              customMoneyStyle="!font-normal !text-sm"
              labelMargin="!py-0"
            />
          </div>
        </div>
      </AddDataAttributes>
    }
  }
}

module TransformedEntryDetails = {
  @react.component
  let make = (
    ~data,
    ~getHeading,
    ~getCell,
    ~detailsFields,
    ~justifyClassName="justify-start",
    ~widthClass="w-1/5",
    ~bgColor="bg-white dark:bg-jp-gray-lightgray_background",
    ~isButtonEnabled=false,
    ~border="border border-jp-gray-940 border-opacity-75 dark:border-jp-gray-960",
    ~customFlex="flex-wrap",
  ) => {
    <FormRenderer.DesktopRow>
      <div
        className={`flex ${customFlex} ${justifyClassName} dark:bg-jp-gray-lightgray_background dark:border-jp-gray-no_data_border `}>
        {detailsFields
        ->Array.map(colType => {
          <div className=widthClass key={LogicUtils.randomString(~length=10)}>
            <DisplayKeyValueParams heading={getHeading(colType)} value={getCell(data, colType)} />
          </div>
        })
        ->React.array}
      </div>
    </FormRenderer.DesktopRow>
  }
}

module TransformedEntryDetailsInfo = {
  @react.component
  let make = (
    ~currentProcessingEntryDetails: ReconEngineTypes.processingEntryType,
    ~detailsFields: array<ReconEngineExceptionEntity.processingColType>,
  ) => {
    open ReconEngineExceptionEntity

    let isMiniLaptopView = MatchMedia.useMatchMedia("(max-width: 1300px)")
    let widthClass = if isMiniLaptopView {
      "md:w-1/3 w-1/2"
    } else {
      "w-1/4"
    }
    let isArchived = currentProcessingEntryDetails.status == Archived
    <div className="w-full border border-nd_gray-150 rounded-xl p-2 relative">
      <RenderIf condition={isArchived}>
        <p
          className={`${body.sm.semibold} absolute top-0 right-0 bg-nd_gray-50 text-nd_gray-600 px-3 py-2 rounded-bl-lg`}>
          {"Archived"->React.string}
        </p>
      </RenderIf>
      <TransformedEntryDetails
        data=currentProcessingEntryDetails
        getHeading=getProcessingHeading
        getCell=getProcessingCell
        detailsFields
        isButtonEnabled=true
        widthClass
      />
    </div>
  }
}

module AuditTrail = {
  @react.component
  let make = (~allTransactionDetails: array<processingEntryType>) => {
    React.useMemo(() => {
      if allTransactionDetails->Array.length > 0 {
        allTransactionDetails->Array.sort(ReconEngineTransformedEntryExceptionsUtils.sortByVersion)
      }
    }, [allTransactionDetails])

    let sections = allTransactionDetails->Array.map((processingEntry: processingEntryType) => {
      let customComponent = {
        AuditTrailStepIndicatorTypes.id: processingEntry.version->Int.toString,
        customComponent: Some(
          <TransformedEntryDetailsInfo
            currentProcessingEntryDetails=processingEntry
            detailsFields=[OrderId, Status, EntryType, EffectiveAt]
          />,
        ),
        onClick: _ => {
          ()
        },
        reasonText: switch processingEntry.discarded_data {
        | Some(discardedData) =>
          discardedData.reason->isNonEmptyString ? Some(discardedData.reason) : None
        | None => None
        },
      }
      customComponent
    })

    <div className="mt-6">
      <AuditTrailStepIndicator sections />
    </div>
  }
}

module ExceptionDataDisplay = {
  @react.component
  let make = (~currentTransformedEntryDetails: ReconEngineTypes.processingEntryType) => {
    let (
      heading,
      subHeading,
    ) = switch currentTransformedEntryDetails.data.needs_manual_review_type {
    | NoRulesFound => ("No Rules Found", "The transformed entry did not match any existing rules.")
    | StagingEntryCurrencyMismatch => (
        "Currency Mismatch",
        "The currency of the transformed entry does not match the expected currency.",
      )
    | DuplicateEntry => (
        "Duplicate Entry",
        "The transformed entry is identified as a duplicate of an existing entry.",
      )
    | NoExpectationEntryFound => (
        "No Expectation Entry Found",
        "No corresponding expectation entry was found for the transformed entry.",
      )
    | MissingSearchIdentifierValue => (
        "Missing Search Identifier Value",
        "The transformed entry is missing a required search identifier value.",
      )
    | MissingUniqueField => (
        "Missing Unique Field",
        "The transformed entry is missing a unique field required for processing.",
      )
    | UnknownNeedsManualReviewType => (
        "Unknown",
        "Please review the details and take necessary actions.",
      )
    }

    <div className="flex flex-col">
      <div className={`text-nd_red-700 ${body.md.semibold} mb-2`}> {heading->React.string} </div>
      <div className={`${body.md.regular} text-nd_gray-600`}> {subHeading->React.string} </div>
    </div>
  }
}

module ResolutionModal = {
  @react.component
  let make = (
    ~exceptionStage: exceptionResolutionStage,
    ~setExceptionStage,
    ~config: resolutionConfig,
    ~children,
    ~activeModal,
    ~setActiveModal,
  ) => {
    let showModal = switch (exceptionStage, activeModal) {
    | (ResolvingTransformedEntry(VoidTransformedEntry), Some(VoidTransformedEntryModal))
    | (ResolvingTransformedEntry(EditTransformedEntry), Some(EditTransformedEntryModal)) => true
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
      | ResolvingTransformedEntry(VoidTransformedEntry) => {
          setExceptionStage(_ => ShowTransformedEntryResolutionOptions(
            NoTransformedEntryResolutionOptionNeeded,
          ))
          setActiveModal(_ => None)
        }
      | ResolvingTransformedEntry(EditTransformedEntry) => {
          setExceptionStage(_ => ShowTransformedEntryResolutionOptions(
            NoTransformedEntryResolutionOptionNeeded,
          ))
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

let getSectionRowDetails = (~sectionIndex: int, ~rowIndex: int, ~groupedEntries) => {
  open ReconEngineTransactionsUtils

  let accountId = groupedEntries->Dict.keysToArray->getValueFromArray(sectionIndex, "")
  let sectionEntries = groupedEntries->Dict.get(accountId)->Option.getOr([])
  let entry = sectionEntries->getValueFromArray(rowIndex, Dict.make()->processingItemToObjMapper)
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

let getEntriesSections = (~groupedEntries: array<processingEntryType>, ~detailsFields) => {
  groupedEntries->Array.map(entry => {
    let rowData = [entry->Identity.genericTypeToJson]
    let processingEntryRows =
      detailsFields->Array.map(colType =>
        ReconEngineExceptionEntity.getProcessingCell(entry, colType)
      )

    (
      {
        rows: [processingEntryRows],
        rowData,
      }: ReconEngineExceptionTransactionTypes.tableSection
    )
  })
}
