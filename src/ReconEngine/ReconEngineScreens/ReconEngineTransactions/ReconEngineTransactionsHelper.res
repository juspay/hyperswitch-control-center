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
              labelMargin="!py-0 mt-2"
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
  @react.component
  let make = (~currentTransactionDetails: ReconEngineTransactionsTypes.transactionPayload) => {
    open TransactionsTableEntity
    open ReconEngineTransactionsUtils
    open ReconEngineTransactionsTypes

    let isMiniLaptopView = MatchMedia.useMatchMedia("(max-width: 1300px)")
    let widthClass = if isMiniLaptopView {
      "md:w-1/3 w-1/2"
    } else {
      "w-1/4"
    }

    let isArchived =
      currentTransactionDetails.transaction_status->getTransactionTypeFromString == Archived

    let detailsFields: array<transactionColType> = [TransactionId, Status, Variance, CreatedAt]

    <div className="w-full border border-nd_gray-150 rounded-lg p-2 relative">
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
  open ReconEngineTransactionsTypes
  @react.component
  let make = (~entryDetails) => {
    open EntriesTableEntity
    open ReconEngineTransactionsUtils

    let isArchived = entryDetails.status->getEntryTypeFromString == Archived

    let detailsFields = [
      EntryId,
      EntryType,
      AccountName,
      Amount,
      Currency,
      TransactionId,
      Status,
      CreatedAt,
      EffectiveAt,
    ]

    let (hasMetadata, filteredMetadata) = React.useMemo(() => {
      let filteredMetadata = entryDetails.metadata->getFilteredMetadataFromEntries
      (filteredMetadata->Dict.keysToArray->Array.length > 0, filteredMetadata)
    }, [entryDetails.metadata])

    <div className="flex flex-col gap-4 mb-6 px-2">
      <div className="w-full border border-nd_gray-150 rounded-lg p-2 relative">
        <RenderIf condition={isArchived}>
          <p
            className={`${body.sm.semibold} absolute top-0 right-0 bg-nd_gray-50 text-nd_gray-600 px-3 py-2 rounded-bl-lg`}>
            {"Archived"->React.string}
          </p>
        </RenderIf>
        <TransactionDetails
          data=entryDetails getHeading getCell widthClass="w-1/2" detailsFields isButtonEnabled=true
        />
      </div>
      <RenderIf condition={hasMetadata}>
        <div className="flex flex-col gap-2">
          <p className={`text-nd_gray-800 ${body.lg.semibold}`}> {"Metadata"->React.string} </p>
          <div className="w-full border border-nd_gray-150 rounded-lg p-2 bg-nd_gray-50">
            <PrettyPrintJson jsonToDisplay={filteredMetadata->JSON.Encode.object->JSON.stringify} />
          </div>
        </div>
      </RenderIf>
    </div>
  }
}

module HierarchicalEntryRenderer = {
  @react.component
  let make = (
    ~fieldValue: string,
    ~containerClassName: string="",
    ~index: int,
    ~entryClassName: string="",
  ) => {
    let paddingCss = Int.mod(index, 2) == 0 ? "pb-4" : "pt-4"
    <div key={randomString(~length=10)} className={`px-8 ${paddingCss} text-sm text-gray-900`}>
      {fieldValue->React.string}
    </div>
  }
}

module AuditTrail = {
  @react.component
  let make = (~allTransactionDetails) => {
    open AuditTrailStepIndicatorTypes
    open ReconEngineTransactionsUtils
    open ReconEngineTransactionsTypes
    open APIUtils

    let getURL = useGetURL()
    let fetchDetails = useGetMethod()

    let (showModal, setShowModal) = React.useState(_ => false)
    let (openedTransaction, setOpenedTransaction) = React.useState(_ =>
      Dict.make()->getAllTransactionPayload
    )
    let (entriesList, setEntriesList) = React.useState(_ => [Dict.make()->getAllEntryPayload])
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
        let entriesList = res->getArrayDataFromJson(getAllEntryPayload)
        let entriesDataArray = openedTransaction.entries->Array.map(entry => {
          let foundEntry =
            entriesList
            ->Array.find(e => entry.entry_id == e.entry_id)
            ->Option.getOr(Dict.make()->getAllEntryPayload)

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

    let sections = allTransactionDetails->Array.map((transaction: transactionPayload) => {
      let customComponent = {
        id: transaction.version->Int.toString,
        customComponent: Some(<TransactionDetailInfo currentTransactionDetails=transaction />),
        onClick: _ => {
          setOpenedTransaction(_ => transaction)
          setShowModal(_ => true)
        },
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
        <div className="flex gap-4 items-center m-6">
          <p className={`text-nd_gray-800 ${heading.sm.semibold}`}>
            {"More Details"->React.string}
          </p>
        </div>
        <Icon
          name="modal-close-icon"
          className="cursor-pointer mr-4"
          size=30
          onClick={_ => setShowModal(_ => false)}
        />
      </div>
    }

    let tabs: array<Tabs.tab> = React.useMemo(() => {
      open Tabs
      entriesList->Array.map(entryDetails => {
        {
          title: entryDetails.entry_id,
          renderContent: () => <EntryAuditTrailInfo entryDetails />,
        }
      })
    }, [entriesList])

    <div>
      <div className="mb-6">
        <p className={`text-nd_gray-800 ${body.lg.semibold}`}> {"Audit Trail"->React.string} </p>
        <p className={`text-nd_gray-500 ${body.md.medium}`}>
          {"This section shows the audit trail of the transaction, including all changes made to it."->React.string}
        </p>
      </div>
      <Modal
        setShowModal
        showModal
        closeOnOutsideClick=true
        modalClass="flex flex-col justify-start h-screen w-1/3 float-right overflow-hidden !bg-white dark:!bg-jp-gray-lightgray_background"
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
            <div className="overflow-y-auto px-2 h-modalContentHeight pb-5">
              <RenderIf condition={Array.length(tabs) > 0}>
                <Tabs
                  tabs
                  showBorder=true
                  includeMargin=false
                  defaultClasses={`!w-max flex flex-auto flex-row items-center justify-center px-6 ${body.md.semibold}`}
                  selectTabBottomBorderColor="bg-primary"
                  customBottomBorderColor="mb-6"
                />
              </RenderIf>
              <RenderIf condition={Array.length(tabs) === 0}>
                <div className="text-center text-nd_gray-500 py-8">
                  {"No entries found"->React.string}
                </div>
              </RenderIf>
            </div>
            <div
              className="absolute bottom-0 left-0 right-0 h-20 bg-white dark:bg-jp-gray-lightgray_background p-4 flex items-center">
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
      <AuditTrailStepIndicator sections />
    </div>
  }
}
