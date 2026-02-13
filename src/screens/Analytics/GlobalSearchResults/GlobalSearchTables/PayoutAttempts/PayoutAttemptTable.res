module PreviewTable = {
  open PayoutAttemptEntity
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
        let data = item.texts->LogicUtils.getValueFromArray(0, Dict.make()->JSON.Encode.object)
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
  open PayoutAttemptEntity
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
        "payout_id",
        "payout_attempt_id",
        "payout_link_id",
        "merchant_order_reference_id",
        "connector_payout_id",
        "status",
        "amount",
        "currency",
        "payout_type",
        "confirm",
        "attempt_count",
        "is_eligible",
        "connector",
        "payout_method_id",
        "profile_id",
        "merchant_id",
        "organization_id",
        "customer_id",
        "recurring",
        "auto_fulfill",
        "priority",
        "description",
        "error_code",
        "error_message",
        "unified_code",
        "unified_message",
        "business_country",
        "business_label",
        "entity_type",
        "created_at",
        "last_modified_at",
        "additional_payout_method_data",
        "metadata",
      ]

      let data = rawData->Array.map(item => {
        let dict = item->getDictFromJsonObject
        let newDict = Dict.make()

        // Use destination_currency if currency is not available, as per SQL alias "destination_currency AS currency"
        let currency = dict->getString("currency", dict->getString("destination_currency", ""))
        let amount = dict->getFloat("amount", 0.0)

        let formattedAmount = CurrencyUtils.convertCurrencyFromLowestDenomination(
          ~amount,
          ~currency,
        )

        newDict->Dict.set(
          "payout_id",
          dict->getvalFromDict("payout_id")->Option.getOr(JSON.Encode.null),
        )
        newDict->Dict.set(
          "payout_attempt_id",
          dict->getvalFromDict("payout_attempt_id")->Option.getOr(JSON.Encode.null),
        )
        newDict->Dict.set(
          "payout_link_id",
          dict->getvalFromDict("payout_link_id")->Option.getOr(JSON.Encode.null),
        )
        newDict->Dict.set(
          "merchant_order_reference_id",
          dict->getvalFromDict("merchant_order_reference_id")->Option.getOr(JSON.Encode.null),
        )
        newDict->Dict.set(
          "connector_payout_id",
          dict->getvalFromDict("connector_payout_id")->Option.getOr(JSON.Encode.null),
        )
        newDict->Dict.set("status", dict->getvalFromDict("status")->Option.getOr(JSON.Encode.null))
        newDict->Dict.set("amount", formattedAmount->JSON.Encode.float)
        newDict->Dict.set("currency", currency->JSON.Encode.string)
        newDict->Dict.set(
          "payout_type",
          dict->getvalFromDict("payout_type")->Option.getOr(JSON.Encode.null),
        )
        newDict->Dict.set(
          "confirm",
          dict->getvalFromDict("confirm")->Option.getOr(JSON.Encode.null),
        )
        newDict->Dict.set(
          "attempt_count",
          dict->getvalFromDict("attempt_count")->Option.getOr(JSON.Encode.null),
        )
        newDict->Dict.set(
          "is_eligible",
          dict->getvalFromDict("is_eligible")->Option.getOr(JSON.Encode.null),
        )
        newDict->Dict.set(
          "connector",
          dict->getvalFromDict("connector")->Option.getOr(JSON.Encode.null),
        )
        newDict->Dict.set(
          "payout_method_id",
          dict->getvalFromDict("payout_method_id")->Option.getOr(JSON.Encode.null),
        )
        newDict->Dict.set(
          "profile_id",
          dict->getvalFromDict("profile_id")->Option.getOr(JSON.Encode.null),
        )
        newDict->Dict.set(
          "merchant_id",
          dict->getvalFromDict("merchant_id")->Option.getOr(JSON.Encode.null),
        )
        newDict->Dict.set(
          "organization_id",
          dict->getvalFromDict("organization_id")->Option.getOr(JSON.Encode.null),
        )
        newDict->Dict.set(
          "customer_id",
          dict->getvalFromDict("customer_id")->Option.getOr(JSON.Encode.null),
        )
        newDict->Dict.set(
          "recurring",
          dict->getvalFromDict("recurring")->Option.getOr(JSON.Encode.null),
        )
        newDict->Dict.set(
          "auto_fulfill",
          dict->getvalFromDict("auto_fulfill")->Option.getOr(JSON.Encode.null),
        )
        newDict->Dict.set(
          "priority",
          dict->getvalFromDict("priority")->Option.getOr(JSON.Encode.null),
        )
        newDict->Dict.set(
          "description",
          dict->getvalFromDict("description")->Option.getOr(JSON.Encode.null),
        )
        newDict->Dict.set(
          "error_code",
          dict->getvalFromDict("error_code")->Option.getOr(JSON.Encode.null),
        )
        newDict->Dict.set(
          "error_message",
          dict->getvalFromDict("error_message")->Option.getOr(JSON.Encode.null),
        )
        newDict->Dict.set(
          "unified_code",
          dict->getvalFromDict("unified_code")->Option.getOr(JSON.Encode.null),
        )
        newDict->Dict.set(
          "unified_message",
          dict->getvalFromDict("unified_message")->Option.getOr(JSON.Encode.null),
        )
        newDict->Dict.set(
          "business_country",
          dict->getvalFromDict("business_country")->Option.getOr(JSON.Encode.null),
        )
        newDict->Dict.set(
          "business_label",
          dict->getvalFromDict("business_label")->Option.getOr(JSON.Encode.null),
        )
        newDict->Dict.set(
          "entity_type",
          dict->getvalFromDict("entity_type")->Option.getOr(JSON.Encode.null),
        )

        let createdAt = dict->getFloat("created_at", 0.0)
        if createdAt != 0.0 {
          newDict->Dict.set(
            "created_at",
            DateTimeUtils.unixToISOString(createdAt)->JSON.Encode.string,
          )
        } else {
          newDict->Dict.set("created_at", JSON.Encode.null)
        }

        let lastModifiedAt = dict->getFloat("last_modified_at", 0.0)
        if lastModifiedAt != 0.0 {
          newDict->Dict.set(
            "last_modified_at",
            DateTimeUtils.unixToISOString(lastModifiedAt)->JSON.Encode.string,
          )
        } else {
          newDict->Dict.set("last_modified_at", JSON.Encode.null)
        }

        newDict->Dict.set(
          "additional_payout_method_data",
          dict->getvalFromDict("additional_payout_method_data")->Option.getOr(JSON.Encode.null),
        )
        newDict->Dict.set(
          "metadata",
          dict->getvalFromDict("metadata")->Option.getOr(JSON.Encode.null),
        )

        newDict->JSON.Encode.object
      })

      let csvContent = data->DownloadUtils.convertArrayToCSVWithCustomHeaders(csvHeaders)

      DownloadUtils.download(
        ~fileName=`payout_attempts_${searchText}.csv`,
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
      <PageUtils.PageHeading title="Payout Attempts" />
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
