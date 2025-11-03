open Typography

@react.component
let make = (
  ~showViewModal,
  ~setShowViewModal,
  ~ingestionHistory: ReconEngineTypes.ingestionHistoryType,
) => {
  open APIUtils
  open ReconEngineAccountsSourcesUtils

  let (headerKeys, setHeaderKeys) = React.useState(_ => [])
  let (csvData, setCsvData) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let showToast = ToastState.useShowToast()

  let fetchIngestionHistoryFileData = async () => {
    try {
      let url = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~hyperswitchReconType=#PREVIEW_INGESTION_HISTORY_FILE,
        ~methodType=Get,
        ~id=Some(ingestionHistory.id),
      )
      let res = await fetchDetails(url)
      let (headers, jsonArray) = getHeadersAndJsonArray(~res)
      setHeaderKeys(_ => headers)
      setCsvData(_ => jsonArray)
    } catch {
    | _ => showToast(~message="Failed to load CSV file. Please try again.", ~toastType=ToastError)
    }
  }

  React.useEffect(() => {
    if showViewModal {
      fetchIngestionHistoryFileData()->ignore
    }
    None
  }, [showViewModal])

  let (headerLength, csvDataLength) = React.useMemo(() => {
    (headerKeys->Array.length, csvData->Array.length)
  }, (headerKeys, csvData))

  <Modal
    setShowModal=setShowViewModal
    showModal=showViewModal
    closeOnOutsideClick=true
    modalHeading=ingestionHistory.file_name
    modalHeadingClass={`text-nd_gray-800 ${heading.sm.semibold}`}
    alignModal="justify-center items-center"
    modalClass="flex flex-col justify-start !max-h-750-px w-4/5 !overflow-scroll !bg-white dark:!bg-jp-gray-lightgray_background"
    childClass="relative h-full">
    <div className="h-full overflow-scroll p-6">
      <RenderIf condition={headerLength > 0 && csvDataLength > 0}>
        <LoadedTable
          title="CSV Data"
          hideTitle=true
          actualData={csvData->Array.map(Nullable.make)}
          totalResults=csvDataLength
          resultsPerPage=10
          offset
          setOffset
          currrentFetchCount=csvDataLength
          entity={getCsvEntity(~headerKeys)}
          collapseTableRow=false
        />
      </RenderIf>
      <RenderIf condition={headerLength === 0 || csvDataLength === 0}>
        <NewAnalyticsHelper.NoData message="No Data Found" height="h-40" />
      </RenderIf>
    </div>
  </Modal>
}
