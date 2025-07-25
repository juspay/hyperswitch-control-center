open Typography

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
        ->Array.mapWithIndex((colType, i) => {
          <div className=widthClass key={i->Int.toString}>
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
  let make = (~currentTransactionDetails, ~detailsFields) => {
    open TransactionsTableEntity

    <div className="w-full border border-nd_gray-150 rounded-lg p-2">
      <TransactionDetails
        data=currentTransactionDetails getHeading getCell detailsFields isButtonEnabled=true
      />
    </div>
  }
}

module EntryAuditTrailInfo = {
  open ReconEngineTransactionsTypes
  @react.component
  let make = (~entryDetails) => {
    open EntriesTableEntity

    let detailsFields = React.useMemo(() => {
      let baseFields: array<entryColType> = [
        EntryId,
        EntryType,
        Amount,
        Currency,
        TransactionId,
        Status,
      ]
      let fieldsWithDiscardedStatus = switch entryDetails.discarded_status {
      | Some(_) => Array.concat(baseFields, [DiscardedStatus])
      | None => baseFields
      }
      Array.concat(fieldsWithDiscardedStatus, [CreatedAt, EffectiveAt])
    }, [entryDetails.discarded_status])

    <div className="flex flex-col gap-4 mb-6 px-2">
      <div className="w-full border border-nd_gray-150 rounded-lg p-2">
        <TransactionDetails
          data=entryDetails getHeading getCell widthClass="w-1/2" detailsFields isButtonEnabled=true
        />
      </div>
      <div className="flex flex-col gap-2">
        <p className={`text-nd_gray-800 ${body.lg.semibold}`}> {"Metadata"->React.string} </p>
        <div className="w-full border border-nd_gray-150 rounded-lg p-2 bg-nd_gray-50">
          <PrettyPrintJson jsonToDisplay={entryDetails.metadata->Js.Json.stringify} />
        </div>
      </div>
    </div>
  }
}

module AuditTrail = {
  @react.component
  let make = (~allTransactionDetails) => {
    open AuditTrailStepIndicatorTypes
    open ReconEngineTransactionsUtils
    open LogicUtils
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
          entriesList
          ->Array.find(e => entry.entry_id == e.entry_id)
          ->Option.getOr(Dict.make()->getAllEntryPayload)
        })
        setEntriesList(_ => entriesDataArray)
        setScreenState(_ => PageLoaderWrapper.Success)
      } catch {
      | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch transaction details"))
      }
    }

    let sections = allTransactionDetails->Array.map(transaction => {
      let customComponent = {
        id: transaction.version->Int.toString,
        customComponent: Some(
          <TransactionDetailInfo
            currentTransactionDetails=transaction
            detailsFields=[TransactionId, Status, DiscardedStatus, Variance, CreatedAt]
          />,
        ),
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
        modalClass="flex flex-col w-1/3 h-screen float-right overflow-hidden !bg-white dark:!bg-jp-gray-lightgray_background"
        childClass="mb-6 mx-2 h-full flex flex-col justify-between"
        customModalHeading=modalHeading>
        <PageLoaderWrapper
          screenState
          customLoader={<div className="h-full flex flex-col justify-center items-center">
            <div className="animate-spin mb-1">
              <Icon name="spinner" size=20 />
            </div>
          </div>}>
          <div className="flex flex-col gap-4 overflow-y-auto h-840-px">
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
          <Button
            customButtonStyle="!w-full"
            buttonType=Button.Primary
            onClick={_ => setShowModal(_ => false)}
            text="OK"
          />
        </PageLoaderWrapper>
      </Modal>
      <AuditTrailStepIndicator sections />
    </div>
  }
}
