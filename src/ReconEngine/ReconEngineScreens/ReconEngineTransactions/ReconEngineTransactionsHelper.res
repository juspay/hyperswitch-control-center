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
  @react.component
  let make = (~currentTransactionDetails: ReconEngineTypes.transactionType) => {
    open TransactionsTableEntity

    let isMiniLaptopView = MatchMedia.useMatchMedia("(max-width: 1300px)")
    let widthClass = if isMiniLaptopView {
      "md:w-1/3 w-1/2"
    } else {
      "w-1/4"
    }
    let isArchived = currentTransactionDetails.transaction_status == Archived
    let detailsFields: array<transactionColType> = [TransactionId, Status, Variance, CreatedAt]
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
  let make = (~entriesList: array<entryType>=[]) => {
    open EntriesTableEntity
    open ReconEngineTransactionsUtils
    open ReconEngineUtils

    let mainEntry = React.useMemo(() => {
      entriesList->Array.get(0)->Option.getOr(Dict.make()->transactionsEntryItemToObjMapperFromDict)
    }, [entriesList])

    let reconciledEntries = React.useMemo(() => {
      entriesList->Array.slice(~start=1, ~end=entriesList->Array.length)
    }, [entriesList])

    let isArchived = mainEntry.status == Archived

    let (hasMetadata, filteredMetadata) = React.useMemo(() => {
      let filteredMetadata = mainEntry.metadata->getFilteredMetadataFromEntries
      (filteredMetadata->Dict.keysToArray->Array.length > 0, filteredMetadata)
    }, [mainEntry.metadata])

    let (isMetadataExpanded, setIsMetadataExpanded) = React.useState(_ => false)
    let (expandedRowIndexArray, setExpandedRowIndexArray) = React.useState(_ => [])

    let onExpandIconClick = (isExpanded, rowIndex) => {
      if isExpanded {
        setExpandedRowIndexArray(prev => prev->Array.filter(index => index !== rowIndex))
      } else {
        setExpandedRowIndexArray(prev => prev->Array.concat([rowIndex]))
      }
    }

    let getRowDetails = (rowIndex: int) => {
      let entry =
        reconciledEntries->Array.get(rowIndex)->Option.getOr(Dict.make()->entryItemToObjMapper)
      let filteredEntryMetadata = entry.metadata->getFilteredMetadataFromEntries
      let hasEntryMetadata = filteredEntryMetadata->Dict.keysToArray->Array.length > 0

      <RenderIf condition={rowIndex < reconciledEntries->Array.length}>
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

    let heading = detailsFields->Array.map(getHeading)
    let rows =
      reconciledEntries->Array.map(entry =>
        detailsFields->Array.map(colType => getCell(entry, colType))
      )
    <div className="flex flex-col gap-4 mb-6 px-2 mt-6">
      <div className="w-full border border-nd_gray-150 rounded-xl p-2 relative">
        <RenderIf condition={isArchived}>
          <p
            className={`${body.sm.semibold} absolute top-0 right-0 bg-nd_gray-50 text-nd_gray-600 px-3 py-2 rounded-bl-lg`}>
            {"Archived"->React.string}
          </p>
        </RenderIf>
        <div className="flex flex-col">
          <TransactionDetails
            data=mainEntry getHeading getCell widthClass="w-1/2" detailsFields isButtonEnabled=true
          />
          <RenderIf condition={hasMetadata}>
            <div className="flex flex-col">
              <div
                className="flex flex-row items-center cursor-pointer hover:text-primary transition-colors m"
                onClick={_ => setIsMetadataExpanded(prev => !prev)}>
                <p className={`text-primary ${body.lg.semibold}`}>
                  {"Show metadata"->React.string}
                </p>
                <Icon
                  name={isMetadataExpanded ? "caret-up" : "caret-down"}
                  size=16
                  className="text-nd_gray-600"
                />
              </div>
              <RenderIf condition={isMetadataExpanded}>
                <div className="p-4">
                  <div
                    className="w-full bg-nd_gray-50 rounded-lg overflow-y-scroll !max-h-60 py-2 px-6 border ">
                    <PrettyPrintJson
                      jsonToDisplay={filteredMetadata->JSON.Encode.object->JSON.stringify}
                    />
                  </div>
                </div>
              </RenderIf>
            </div>
          </RenderIf>
        </div>
      </div>
      <RenderIf condition={reconciledEntries->Array.length > 0}>
        <div className="flex flex-col gap-4">
          <p className={`text-nd_gray-800 ${body.lg.semibold}`}>
            {"Reconciled with"->React.string}
          </p>
          <div className="overflow-visible">
            <CustomExpandableTable
              title="Reconciled Entries"
              tableClass="border rounded-xl overflow-y-auto"
              borderClass=" "
              firstColRoundedHeadingClass="rounded-tl-xl"
              lastColRoundedHeadingClass="rounded-tr-xl"
              headingBgColor="bg-nd_gray-25"
              headingFontWeight="font-semibold"
              headingFontColor="text-nd_gray-400"
              rowFontColor="text-nd_gray-600"
              customRowStyle="text-sm"
              rowFontStyle="font-medium"
              heading
              rows
              onExpandIconClick
              expandedRowIndexArray
              getRowDetails
              showSerial=false
              showScrollBar=true
            />
          </div>
        </div>
      </RenderIf>
    </div>
  }
}

module HierarchicalEntryRenderer = {
  @react.component
  let make = (~fieldValue: string, ~containerClassName: string="", ~entryClassName: string="") => {
    <div
      key={randomString(~length=10)}
      className={`px-8 py-3.5 text-sm text-gray-900 w-48 truncate whitespace-nowrap ${entryClassName}`}>
      {fieldValue->React.string}
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
            {openedTransaction.transaction_id->React.string}
          </p>
          <div
            className={`px-3 py-1 rounded-lg ${body.md.semibold} ${openedTransaction.transaction_status->getTransactionStatusLabel}`}>
            {(openedTransaction.transaction_status :> string)->React.string}
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
            <div className="absolute inset-0 overflow-y-auto px-2 pb-20">
              <RenderIf condition={entriesList->Array.length > 0}>
                <EntryAuditTrailInfo entriesList />
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
      <AuditTrailStepIndicator sections />
    </div>
  }
}
