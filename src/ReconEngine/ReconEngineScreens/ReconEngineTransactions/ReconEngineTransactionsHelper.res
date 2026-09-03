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
  let make = (
    ~openedTransaction: transactionType,
    ~accountIds: array<string>,
    ~accountsData: array<accountType>,
  ) => {
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
      <ReconEngineTransactionEntries
        primaryTransactionId={openedTransaction.id}
        accountIds
        accountsData
        entriesDetailFields=EntriesTableEntity.detailsFields
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

module HierarchicalEntryRenderer = {
  @react.component
  let make = (~fieldValue: string) => {
    <div className="px-8 py-3.5">
      <div className="truncate max-w-48 whitespace-nowrap h-7"> {fieldValue->React.string} </div>
    </div>
  }
}

module HierarchicalMoreEntriesRenderer = {
  @react.component
  let make = (~hasMoreEntries: bool, ~text: string="") => {
    <RenderIf condition={hasMoreEntries}>
      <div className="px-8 py-3.5">
        <div
          className={`truncate max-w-48 whitespace-nowrap h-7 text-nd_gray-500 ${body.sm.medium}`}>
          {text->React.string}
        </div>
      </div>
    </RenderIf>
  }
}

module AuditTrail = {
  @react.component
  let make = (
    ~allTransactionDetails,
    ~accountIds: array<string>,
    ~accountsData: array<ReconEngineTypes.accountType>,
  ) => {
    open AuditTrailStepIndicatorTypes
    open ReconEngineTransactionsUtils

    let (showModal, setShowModal) = React.useState(_ => false)
    let (openedTransaction, setOpenedTransaction) = React.useState(_ =>
      Dict.make()->getTransactionsPayloadFromDict
    )

    React.useMemo(() => {
      if allTransactionDetails->Array.length > 0 {
        allTransactionDetails->Array.sort(ReconEngineTransactionsUtils.sortByVersion)
      }
    }, [allTransactionDetails])

    let sections =
      allTransactionDetails->Array.map((transaction: ReconEngineTypes.transactionType) => {
        let reasonText = switch transaction.data.reason {
        | Some(reason) if reason->isNonEmptyString => Some(reason)
        | _ => transaction.discarded_data->Option.flatMap(discardedData => discardedData.reason)
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
          modifiedBy: transaction.modified_by,
        }
        customComponent
      })

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
        <div className="h-full relative">
          <div className="absolute inset-0 overflow-y-auto px-2 pb-20">
            <RenderIf condition={showModal && openedTransaction.id->isNonEmptyString}>
              <EntryAuditTrailInfo
                key={openedTransaction.id} openedTransaction accountIds accountsData
              />
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
      </Modal>
    </>
  }
}

module AuditTrailTab = {
  @react.component
  let make = (
    ~transactionId: string,
    ~accountIds: array<string>,
    ~accountsData: array<ReconEngineTypes.accountType>,
  ) => {
    let getTransactions = ReconEngineHooks.useGetTransactions()
    let (allTransactionDetails, setAllTransactionDetails) = React.useState(_ => [])
    let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

    let fetchTransactionVersions = async () => {
      setScreenState(_ => PageLoaderWrapper.Loading)
      try {
        let transactionsList = await getTransactions(
          ~queryParameters=Some(`transaction_id=${transactionId}`),
        )
        setAllTransactionDetails(_ => transactionsList)
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch transaction details"))
      }
    }

    React.useEffect(() => {
      fetchTransactionVersions()->ignore
      None
    }, [])

    <PageLoaderWrapper
      screenState customLoader={<Shimmer styleClass="h-40 w-full mt-8 rounded-xl" />}>
      <AuditTrail allTransactionDetails accountIds accountsData />
    </PageLoaderWrapper>
  }
}
