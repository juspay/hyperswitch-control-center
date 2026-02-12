module PreviewTable = {
  open PaymentAttemptEntity
  open GlobalSearchTypes
  open ResultsTableUtils
  @react.component
  let make = (~data) => {
    let defaultSort: Table.sortedObject = {
      key: "",
      order: Table.INC,
    }

    let tableData =
      data
      ->Array.map(item => {
        let data = item.texts->Array.get(0)->Option.getOr(Dict.make()->JSON.Encode.object)
        data->JSON.Decode.object->Option.getOr(Dict.make())
      })
      ->Array.filter(dict => dict->Dict.keysToArray->Array.length > 0)
      ->Array.map(item => item->tableItemToObjMapper->Nullable.make)

    <LoadedTable
      visibleColumns
      title=domain
      hideTitle=true
      actualData={tableData}
      entity=tableEntity
      resultsPerPage=10
      totalResults={tableData->Array.length}
      offset={0}
      setOffset={_ => ()}
      defaultSort
      currrentFetchCount={tableData->Array.length}
      tableLocalFilter=false
      tableheadingClass=tableBorderClass
      tableBorderClass
      ignoreHeaderBg=true
      tableDataBorderClass=tableBorderClass
      isAnalyticsModule=false
      showResultsPerPageSelector=false
      paginationClass="hidden"
    />
  }
}

@react.component
let make = () => {
  open APIUtils
  open PaymentAttemptEntity
  let updateDetails = useUpdateMethod()
  let fetchTableData = ResultsTableUtils.useGetData()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (data, setData) = React.useState(_ => [])
  let (rawData, setRawData) = React.useState(_ => [])
  let (totalCount, setTotalCount) = React.useState(_ => 0)
  let widthClass = "w-full"
  let heightClass = ""
  let defaultValue: LoadedTable.pageDetails = {offset: 0, resultsPerPage: 50}
  let pageDetailDict = Recoil.useRecoilValueFromAtom(LoadedTable.table_pageDetails)
  let setPageDetails = Recoil.useSetRecoilState(LoadedTable.table_pageDetails)
  let pageDetail = pageDetailDict->Dict.get(domain)->Option.getOr(defaultValue)
  let (offset, setOffset) = React.useState(_ => pageDetail.offset)
  let searchText = UrlUtils.useGetFilterDictFromUrl("")->LogicUtils.getString("query", "")
  let path = UrlUtils.useGetFilterDictFromUrl("")->LogicUtils.getString("source", "")

  let clearPageDetails = () => {
    let newDict = pageDetailDict->Dict.toArray->Dict.fromArray
    newDict->Dict.set(domain, defaultValue)
    setPageDetails(_ => newDict)
  }

  let getData = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)

    try {
      let (data, total) = await fetchTableData(~updateDetails, ~offset, ~query={searchText}, ~path)

      let arr = Array.make(~length=offset, Dict.make())
      if data->Array.length == 0 && total <= offset {
        setOffset(_ => 0)
      }

      if total > 0 {
        let dataDictArr = data->Belt.Array.keepMap(JSON.Decode.object)
        let orderData = arr->Array.concat(dataDictArr)->Array.map(tableItemToObjMapper)
        let list = orderData->Array.map(Nullable.make)

        setTotalCount(_ => total)
        setData(_ => list)
        setRawData(_ => data)
        setScreenState(_ => PageLoaderWrapper.Success)
      } else {
        setScreenState(_ => PageLoaderWrapper.Custom)
      }
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Something went wrong!"))
    }
  }

  React.useEffect(() => {
    if searchText->String.length > 0 {
      getData()->ignore
    } else {
      setScreenState(_ => PageLoaderWrapper.Success)
    }

    Some(
      () => {
        clearPageDetails()
      },
    )
  }, (offset, searchText))

  let downloadData = () => {
    open LogicUtils
    try {
      let csvHeaders = [
        "payment_id",
        "attempt_id",
        "status",
        "amount",
        "currency",
        "connector",
        "connector_transaction_id",
        "amount_to_capture",
        "created_at",
        "error_message",
        "capture_method",
        "authentication_type",
        "payment_method",
        "payment_method_type",
        "payment_method_data",
        "card_network",
        "modified_at",
        "error_code",
        "payment_method_id",
        "card_holder_name",
        "profile_id",
      ]

      let data = rawData->Array.map(item => {
        let dict = item->getDictFromJsonObject
        let newDict = Dict.make()

        let currency = dict->getString("currency", "")
        let amount = dict->getFloat("amount", 0.0)
        let amountToCapture = dict->getFloat("amount_to_capture", 0.0)

        let formattedAmount = CurrencyUtils.convertCurrencyFromLowestDenomination(
          ~amount,
          ~currency,
        )
        let formattedAmountToCapture = CurrencyUtils.convertCurrencyFromLowestDenomination(
          ~amount=amountToCapture,
          ~currency,
        )

        newDict->Dict.set(
          "payment_id",
          dict->getvalFromDict("payment_id")->Option.getOr(JSON.Encode.null),
        )
        newDict->Dict.set(
          "attempt_id",
          dict->getvalFromDict("attempt_id")->Option.getOr(JSON.Encode.null),
        ) // Using attempt_id directly here if available, or fall back logic
        newDict->Dict.set("status", dict->getvalFromDict("status")->Option.getOr(JSON.Encode.null))
        newDict->Dict.set("amount", formattedAmount->JSON.Encode.float)
        newDict->Dict.set(
          "currency",
          dict->getvalFromDict("currency")->Option.getOr(JSON.Encode.null),
        )
        newDict->Dict.set(
          "connector",
          dict->getvalFromDict("connector")->Option.getOr(JSON.Encode.null),
        )
        newDict->Dict.set(
          "connector_transaction_id",
          dict->getvalFromDict("connector_transaction_id")->Option.getOr(JSON.Encode.null),
        )
        newDict->Dict.set("amount_to_capture", formattedAmountToCapture->JSON.Encode.float)

        let createdAt = dict->getFloat("created_at", 0.0)
        if createdAt != 0.0 {
          newDict->Dict.set(
            "created_at",
            DateTimeUtils.unixToISOString(createdAt)->JSON.Encode.string,
          )
        } else {
          newDict->Dict.set("created_at", JSON.Encode.null)
        }
        newDict->Dict.set(
          "error_message",
          dict->getvalFromDict("error_message")->Option.getOr(JSON.Encode.null),
        )
        newDict->Dict.set(
          "capture_method",
          dict->getvalFromDict("capture_method")->Option.getOr(JSON.Encode.null),
        )
        newDict->Dict.set(
          "authentication_type",
          dict->getvalFromDict("authentication_type")->Option.getOr(JSON.Encode.null),
        )
        newDict->Dict.set(
          "payment_method",
          dict->getvalFromDict("payment_method")->Option.getOr(JSON.Encode.null),
        )
        newDict->Dict.set(
          "payment_method_type",
          dict->getvalFromDict("payment_method_type")->Option.getOr(JSON.Encode.null),
        )
        newDict->Dict.set(
          "business_sub_label",
          dict->getvalFromDict("business_sub_label")->Option.getOr(JSON.Encode.null),
        )
        newDict->Dict.set(
          "payment_method_data",
          dict->getvalFromDict("payment_method_data")->Option.getOr(JSON.Encode.null),
        )
        let cardNetwork =
          dict
          ->getJsonObjectFromDict("payment_method_data")
          ->getDictFromJsonObject
          ->getJsonObjectFromDict("card")
          ->getDictFromJsonObject
          ->getString("card_network", "")
        if cardNetwork != "" {
          newDict->Dict.set("card_network", cardNetwork->JSON.Encode.string)
        } else {
          newDict->Dict.set("card_network", JSON.Encode.null)
        }
        let cardHolderName =
          dict
          ->getJsonObjectFromDict("payment_method_data")
          ->getDictFromJsonObject
          ->getJsonObjectFromDict("card")
          ->getDictFromJsonObject
          ->getString("card_holder_name", "")
        if cardHolderName != "" {
          newDict->Dict.set("card_holder_name", cardHolderName->JSON.Encode.string)
        } else {
          newDict->Dict.set("card_holder_name", JSON.Encode.null)
        }
        let modifiedAt = dict->getFloat("modified_at", 0.0)
        if modifiedAt != 0.0 {
          newDict->Dict.set(
            "modified_at",
            DateTimeUtils.unixToISOString(modifiedAt)->JSON.Encode.string,
          )
        } else {
          newDict->Dict.set("modified_at", JSON.Encode.null)
        }

        newDict->Dict.set(
          "error_code",
          dict->getvalFromDict("error_code")->Option.getOr(JSON.Encode.null),
        )
        newDict->Dict.set(
          "payment_method_id",
          dict->getvalFromDict("payment_method_id")->Option.getOr(JSON.Encode.null),
        )
        newDict->Dict.set(
          "profile_id",
          dict->getvalFromDict("profile_id")->Option.getOr(JSON.Encode.null),
        )

        newDict->JSON.Encode.object
      })

      let csvContent = data->DownloadUtils.convertArrayToCSVWithCustomHeaders(csvHeaders)
      DownloadUtils.download(
        ~fileName=`payment_attempts_${searchText}.csv`,
        ~content=csvContent,
        ~fileType="text/csv",
      )
    } catch {
    | _ => ()
    }
  }

  open ResultsTableUtils
  <div className={`flex flex-col mx-auto h-full ${widthClass} ${heightClass} min-h-[50vh]`}>
    <div className="flex justify-between items-center mb-4">
      <PageUtils.PageHeading title="Payment Attempt" />
      <Button
        text="Download"
        buttonType={Primary}
        leftIcon={Button.CustomIcon(<Icon name="nd-download-bar-down" size=16 />)}
        onClick={_ => downloadData()}
        buttonSize={Small}
      />
    </div>
    <PageLoaderWrapper screenState>
      <LoadedTable
        visibleColumns
        title=domain
        hideTitle=true
        actualData=data
        entity=tableEntity
        resultsPerPage=50
        showSerialNumber=true
        totalResults={totalCount}
        offset
        setOffset
        currrentFetchCount={data->Array.length}
        tableLocalFilter=false
        tableheadingClass=tableBorderClass
        tableBorderClass
        ignoreHeaderBg=true
        tableDataBorderClass=tableBorderClass
        isAnalyticsModule=false
        showResultsPerPageSelector=false
      />
    </PageLoaderWrapper>
  </div>
}
