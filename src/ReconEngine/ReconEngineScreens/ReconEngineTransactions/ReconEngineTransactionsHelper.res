open Typography
open LogicUtils

module DisplayKeyValueParams = {
  @react.component
  let make = (
    ~showTitle: bool=true,
    ~heading: Table.header,
    ~value: Table.cell,
    ~wordBreak=true,
  ) => {
    let description = heading.description->Option.getOr("")

    {
      <AddDataAttributes attributes=[("data-label", heading.title)]>
        <div className="flex flex-col gap-2 py-4">
          <div
            className="flex flex-row text-fs-11 text-nd_gray-500 text-opacity-50 dark:text-nd_gray-500 dark:text-opacity-50">
            <div className={`text-nd_gray-500 ${body.md.medium}`}>
              {React.string(showTitle ? heading.title : " x")}
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

module TransactionDetails = {
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

module TransactionDetailInfo = {
  open ReconEngineTypes

  @react.component
  let make = (
    ~currentTransactionDetails: transactionType,
    ~detailsFields: array<TransactionsTableEntity.transactionColType>,
    ~customWidthClass="w-1/4",
  ) => {
    open TransactionsTableEntity

    let isMiniLaptopView = MatchMedia.useMatchMedia("(max-width: 1300px)")
    let widthClass = if isMiniLaptopView {
      "md:w-1/2 w-full"
    } else {
      customWidthClass
    }
    let isArchived = currentTransactionDetails.transaction_status == Archived
    <div className="w-full border border-nd_gray-150 rounded-xl p-2 relative">
      <RenderIf condition={isArchived}>
        <p
          className={`${body.sm.semibold} absolute top-0 right-0 bg-nd_gray-50 text-nd_gray-600 px-3 py-2 rounded-bl-lg`}>
          {"Archived"->React.string}
        </p>
      </RenderIf>
      <TransactionDetails
        data=currentTransactionDetails
        getHeading
        getCell
        detailsFields
        isButtonEnabled=true
        widthClass
      />
    </div>
  }
}

module EntryAuditTrailInfo = {
  open ReconEngineTypes

  @react.component
  let make = (~openedTransaction: transactionType, ~entriesList: array<entryType>=[]) => {
    open EntriesTableEntity
    open ReconEngineTransactionsUtils
    open ReconEngineUtils

    let accountGroups = React.useMemo(() => {
      let groupedByAccount = entriesList->Array.reduce(Dict.make(), (acc, entry) => {
        let accountId = entry.account_id
        let existing = acc->getValueFromDict(accountId, [])
        acc->Dict.set(accountId, [...existing, entry])
        acc
      })

      groupedByAccount
      ->Dict.toArray
      ->Array.map(((accountId, entries)) => {
        let entry = entries->getValueFromArray(0, Dict.make()->entryItemToObjMapper)
        let accountName = entry.account_name
        ({accountId, accountName, entries}: ReconEngineTransactionsTypes.accountGroup)
      })
    }, [entriesList])

    let heading = detailsFields->Array.map(getHeading)

    let getSectionRowDetails = (sectionIndex: int, rowIndex: int) => {
      let group = accountGroups->getValueFromArray(
        sectionIndex,
        (
          {
            accountId: "",
            accountName: "",
            entries: [],
          }: ReconEngineTransactionsTypes.accountGroup
        ),
      )
      let entry = group.entries->getValueFromArray(rowIndex, Dict.make()->entryItemToObjMapper)
      let filteredEntryMetadata = entry.metadata->getFilteredMetadataFromEntries
      let hasEntryMetadata = !(filteredEntryMetadata->isEmptyDict)

      <RenderIf condition={rowIndex < group.entries->Array.length}>
        <RenderIf condition={hasEntryMetadata}>
          <div className="p-4">
            <div className="w-full bg-nd_gray-50 rounded-xl overflow-y-scroll !max-h-60 py-2 px-6">
              <PrettyPrintJson
                jsonToDisplay={filteredEntryMetadata->JSON.Encode.object->JSON.stringify}
              />
            </div>
          </div>
        </RenderIf>
      </RenderIf>
    }

    let sections = accountGroups->Array.map(group => {
      open ReconEngineExceptionTransactionTypes
      {
        titleElement: <p className={`text-nd_gray-800 ${body.lg.semibold} mb-2`}>
          {group.accountName->React.string}
        </p>,
        rows: group.entries->Array.map(entry =>
          detailsFields->Array.map(colType => getCell(entry, colType))
        ),
        rowData: group.entries->Array.map(entry => entry->Identity.genericTypeToJson),
      }
    })

    <div className="flex flex-col gap-4 px-2 my-6">
      <RenderIf condition={openedTransaction.data.reason->Option.isSome}>
        <div className="flex flex-col gap-2 p-4 border border-nd_gray-150 rounded-lg w-full">
          <div className="flex flex-row justify-between">
            <p className={`${body.lg.semibold} text-nd_gray-700`}>
              {"Resolution Remark"->React.string}
            </p>
          </div>
          <p className={`${body.md.medium} text-nd_gray-500`}>
            {openedTransaction.data.reason->Option.getOr("")->React.string}
          </p>
        </div>
      </RenderIf>
      <ReconEngineCustomExpandableSelectionTable
        title="" heading getSectionRowDetails showScrollBar=true showOptions=false sections
      />
      <RenderIf condition={openedTransaction.linked_transaction->Option.isSome}>
        <div className="flex flex-col gap-4">
          <p className={`text-nd_gray-800 ${body.lg.semibold}`}> {"Linked with"->React.string} </p>
          <div className="overflow-visible">
            <LoadedTable
              title="Linked Entries"
              hideTitle=true
              actualData={[openedTransaction]->Array.map(Nullable.make)}
              entity={LinkedTransactionTableEntity.entriesEntityForLinkedTxn()}
              resultsPerPage=10
              showSerialNumber=false
              totalResults={[openedTransaction]->Array.length}
              offset={0}
              setOffset={_ => ()}
              currentFetchCount={[openedTransaction]->Array.length}
            />
          </div>
        </div>
      </RenderIf>
    </div>
  }
}

module EntryMatchSummary = {
  // Groups a transaction's entries by their source account and, when the
  // transaction spans exactly two accounts (the common recon case), renders
  // them as two connected cards instead of raw tables — so the reader sees
  // "these entries matched those entries" at a glance instead of having to
  // cross-reference Order ID across separate tables themselves.
  open ReconEngineTypes

  // Entry-level detail only earns its place on screen while it's still
  // scannable — past a handful of entries, listing every row just
  // reproduces the table below. So this card shows the aggregate (total +
  // Credit/Debit counts) always, and only expands to per-entry rows when
  // there are few enough to actually read at a glance.
  let maxVisibleEntries = 4

  let formatEntryAmount = amount => amount->Float.toFixedWithPrecision(~digits=2)

  module EntrySideCard = {
    @react.component
    let make = (~group: ReconEngineTransactionsTypes.accountGroup) => {
      open LogicUtils

      let currency = switch group.entries->Array.get(0) {
      | Some(entry) => entry.currency
      | None => ""
      }
      let total = group.entries->Array.reduce(0.0, (sum, entry) => sum +. entry.amount)
      let creditCount = group.entries->Array.filter(entry => entry.entry_type == Credit)->Array.length
      let debitCount = group.entries->Array.filter(entry => entry.entry_type == Debit)->Array.length
      let entryCount = group.entries->Array.length
      let showRows = entryCount <= maxVisibleEntries
      let visibleEntries = if showRows {
        group.entries
      } else {
        []
      }

      <div className="flex-1 min-w-0 max-w-sm border border-nd_gray-150 rounded-xl p-4 flex flex-col gap-3">
        <p className={`${body.sm.medium} text-nd_gray-500 truncate`}>
          {group.accountName->React.string}
        </p>
        <div className="flex items-baseline gap-1.5">
          <span className={`${heading.sm.semibold} text-nd_gray-800 tabular-nums`}>
            {total->formatEntryAmount->React.string}
          </span>
          <span className={`${body.sm.regular} text-nd_gray-500`}> {currency->React.string} </span>
        </div>
        <div className="flex items-center gap-1.5 -mt-1.5">
          <RenderIf condition={creditCount > 0}>
            <span className={`${body.xs.medium} text-nd_green-600 whitespace-nowrap`}>
              {`${creditCount->Int.toString} Credit`->React.string}
            </span>
          </RenderIf>
          <RenderIf condition={creditCount > 0 && debitCount > 0}>
            <span className="text-nd_gray-300"> {"·"->React.string} </span>
          </RenderIf>
          <RenderIf condition={debitCount > 0}>
            <span className={`${body.xs.medium} text-nd_primary_blue-600 whitespace-nowrap`}>
              {`${debitCount->Int.toString} Debit`->React.string}
            </span>
          </RenderIf>
        </div>
        <RenderIf condition={showRows}>
          <div className="flex flex-col">
            {visibleEntries
            ->Array.mapWithIndex((entry, index) =>
              <div
                key={index->Int.toString}
                className="flex items-center justify-between gap-3 py-2 border-t border-nd_gray-100 first:border-t-0 first:pt-0">
                <div className="flex items-center gap-2 min-w-0">
                  <TagBinding
                    text={(entry.entry_type :> string)->capitalizeString}
                    variant=Subtle
                    size=Xs
                    color={entry.entry_type == Credit ? Success : Primary}
                  />
                  <span
                    className={`${code.md.medium} text-nd_gray-700 tabular-nums whitespace-nowrap`}>
                    {entry.amount->formatEntryAmount->React.string}
                  </span>
                </div>
                <HelperComponents.CopyTextCustomComp
                  customTextCss="max-w-32 truncate text-nd_gray-500"
                  displayValue=Some(entry.order_id)
                />
              </div>
            )
            ->React.array}
          </div>
        </RenderIf>
        <RenderIf condition={!showRows}>
          <p className={`${body.xs.regular} text-nd_gray-400 pt-2 border-t border-nd_gray-100`}>
            {`${entryCount->Int.toString} entries — see full list in Entries below`->React.string}
          </p>
        </RenderIf>
      </div>
    }
  }

  @react.component
  let make = (~entriesList: array<entryType>) => {
    open LogicUtils

    let accountGroups = React.useMemo(() => {
      let groupedByAccount = entriesList->Array.reduce(Dict.make(), (acc, entry) => {
        let accountId = entry.account_id
        let existing = acc->getValueFromDict(accountId, [])
        acc->Dict.set(accountId, [...existing, entry])
        acc
      })

      groupedByAccount
      ->Dict.toArray
      ->Array.map(((accountId, entries)) => {
        let accountName = switch entries->Array.get(0) {
        | Some(entry) => entry.account_name
        | None => ""
        }
        ({accountId, accountName, entries}: ReconEngineTransactionsTypes.accountGroup)
      })
    }, [entriesList])

    <RenderIf condition={accountGroups->Array.length == 2}>
      {switch (accountGroups->Array.get(0), accountGroups->Array.get(1)) {
      | (Some(left), Some(right)) =>
        <div className="w-full border border-nd_gray-150 rounded-xl p-4">
          <p className={`${body.sm.medium} text-nd_gray-500 mb-3`}>
            {"Matched entries"->React.string}
          </p>
          <div className="flex flex-col md:flex-row items-center gap-3">
            <EntrySideCard group=left />
            <div className="flex md:flex-col items-center justify-center gap-1 px-1 shrink-0">
              <Icon name="nd-swap-arrow-horizontal" size=18 className="text-nd_gray-400" />
              <p className={`${body.xs.medium} text-nd_gray-500 whitespace-nowrap`}>
                {"Matched on Order ID"->React.string}
              </p>
            </div>
            <EntrySideCard group=right />
          </div>
        </div>
      | _ => React.null
      }}
    </RenderIf>
  }
}

module HierarchicalEntryRenderer = {
  @react.component
  let make = (~fieldValue: string) => {
    <div className="px-8 py-3.5">
      <div className="truncate max-w-48 whitespace-nowrap h-7"> {fieldValue->React.string} </div>
    </div>
  }
}

module AuditTrail = {
  @react.component
  let make = (~allTransactionDetails) => {
    open AuditTrailStepIndicatorTypes
    open ReconEngineTransactionsUtils
    open ReconEngineTypes
    open APIUtils

    let getURL = useGetURL()
    let fetchDetails = useGetMethod()

    let (showModal, setShowModal) = React.useState(_ => false)
    let (openedTransaction, setOpenedTransaction) = React.useState(_ =>
      Dict.make()->getTransactionsPayloadFromDict
    )
    let (entriesList, setEntriesList) = React.useState(_ => [
      Dict.make()->transactionsEntryItemToObjMapperFromDict,
    ])
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

    React.useMemo(() => {
      if allTransactionDetails->Array.length > 0 {
        allTransactionDetails->Array.sort(ReconEngineTransactionsUtils.sortByVersion)
      }
    }, [allTransactionDetails])

    let getEntriesDetails = async _ => {
      setScreenState(_ => PageLoaderWrapper.Loading)
      try {
        let url = getURL(
          ~entityName=V1(HYPERSWITCH_RECON),
          ~methodType=Get,
          ~hyperswitchReconType=#PROCESSED_ENTRIES_LIST_WITH_TRANSACTION,
          ~id=Some(openedTransaction.transaction_id),
        )
        let res = await fetchDetails(url)
        let entriesList = res->getArrayDataFromJson(transactionsEntryItemToObjMapperFromDict)
        let entriesDataArray = openedTransaction.entries->Array.map(entry => {
          let foundEntry =
            entriesList
            ->Array.find(e => entry.entry_id == e.entry_id)
            ->Option.getOr(Dict.make()->transactionsEntryItemToObjMapperFromDict)

          {
            ...foundEntry,
            account_name: entry.account.account_name,
          }
        })
        setEntriesList(_ => entriesDataArray)
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch transaction details"))
      }
    }

    let sections = allTransactionDetails->Array.map((transaction: transactionType) => {
      let reasonText = transaction.data.reason->Option.mapOr(None, reason => Some(reason))

      let customComponent = {
        id: transaction.version->Int.toString,
        customComponent: Some(
          <TransactionDetailInfo
            currentTransactionDetails=transaction
            detailsFields=[Status, Variance, CreatedAt]
            customWidthClass="w-1/3"
          />,
        ),
        onClick: _ => {
          setOpenedTransaction(_ => transaction)
          setShowModal(_ => true)
        },
        reasonText,
      }
      customComponent
    })

    React.useEffect(() => {
      if showModal {
        getEntriesDetails()->ignore
      }
      None
    }, [showModal])

    let modalHeading = {
      <div className="flex justify-between border-b">
        <div className="flex items-center m-6 gap-4 w-full">
          <HelperComponents.CopyTextCustomComp
            customTextCss={`max-w-36 truncate whitespace-nowrap ${heading.sm.semibold} text-nd_gray-800`}
            displayValue=Some(openedTransaction.transaction_id)
          />
          <TableUtils.LabelCell
            labelColor={ReconEngineTransactionsUtils.getTransactionStatusLabelColor(
              openedTransaction.transaction_status,
            )}
            text={openedTransaction.transaction_status
            ->TransactionsTableEntity.getDomainTransactionStatusString
            ->String.toUpperCase}
          />
        </div>
        <Icon
          name="modal-close-icon"
          className="cursor-pointer mr-4"
          size=30
          onClick={_ => setShowModal(_ => false)}
        />
      </div>
    }

    <>
      <div className="my-8">
        <p className={`${body.lg.semibold} text-nd_gray-800`}> {"Audit Trail"->React.string} </p>
        <p className={`text-nd_gray-400 mt-1 ${body.md.medium}`}>
          {"An immutable history of every version and update made to this transaction"->React.string}
        </p>
      </div>
      <AuditTrailStepIndicator sections />
      <Modal
        setShowModal
        showModal
        closeOnOutsideClick=true
        modalClass="flex flex-col justify-start h-screen w-2/5 float-right overflow-hidden !bg-white dark:!bg-jp-gray-lightgray_background"
        childClass="relative h-full"
        customModalHeading=modalHeading>
        <PageLoaderWrapper
          screenState
          customLoader={<div className="h-full flex flex-col justify-center items-center">
            <div className="animate-spin mb-1">
              <Icon name="spinner" size=20 />
            </div>
          </div>}>
          <div className="h-full relative">
            <div className="absolute inset-0 overflow-y-auto px-2 pb-20">
              <RenderIf condition={entriesList->Array.length > 0}>
                <EntryAuditTrailInfo openedTransaction entriesList />
              </RenderIf>
              <RenderIf condition={entriesList->Array.length === 0}>
                <div className="text-center text-nd_gray-500 py-8">
                  {"No entries found"->React.string}
                </div>
              </RenderIf>
            </div>
            <div
              className="absolute bottom-0 left-0 right-0 bg-white dark:bg-jp-gray-lightgray_background p-4 border-t border-nd_gray-150">
              <Button
                customButtonStyle="!w-full"
                buttonType=Button.Primary
                onClick={_ => setShowModal(_ => false)}
                text="OK"
              />
            </div>
          </div>
        </PageLoaderWrapper>
      </Modal>
    </>
  }
}
