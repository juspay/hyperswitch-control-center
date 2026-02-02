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
        let existing = acc->getvalFromDict(accountId)->Option.getOr([])
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
              currrentFetchCount={[openedTransaction]->Array.length}
            />
          </div>
        </div>
      </RenderIf>
    </div>
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
      let reasonText = switch transaction.data.posted_type {
      | Some(ManuallyReconciled)
      | Some(ForceReconciled) =>
        transaction.data.reason
      | _ => None
      }

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
          <div
            className={`px-3 py-1 rounded-lg ${body.sm.semibold} ${openedTransaction.transaction_status->getTransactionStatusLabel}`}>
            {openedTransaction.transaction_status
            ->TransactionsTableEntity.getDomainTransactionStatusString
            ->String.toUpperCase
            ->React.string}
          </div>
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
