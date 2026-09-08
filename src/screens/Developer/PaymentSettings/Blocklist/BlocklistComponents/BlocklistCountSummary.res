open BlocklistUtils
open BlocklistTypes
open LogicUtils
open APIUtils
open Typography

@react.component
let make = () => {
  let getURL = useGetURL()
  let fetchDetails = useGetMethod(~showErrorToast=false)
  let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  let (counts, setCounts) = React.useState(_ => defaultBlocklistCounts)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

  let fetchCount = async dataKind => {
    let url = getURL(
      ~entityName=V1(BLOCKLIST_COUNT),
      ~methodType=Get,
      ~queryParameters=Some(`data_kind=${dataKind->blocklistDataKindToQueryParam}`),
    )
    let response = await fetchDetails(url)
    response->getBlocklistCountFromResponse
  }

  let fetchCounts = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let (cardBin, fingerprint) = await Promise.all2((
        fetchCount(GenericCardBin),
        fetchCount(Fingerprint),
      ))
      setCounts(_ => {cardBin, fingerprint})
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  React.useEffect(() => {
    fetchCounts()->ignore
    None
  }, [profileId])

  let blocklistCountsData = {
    let binCounts =
      counts.cardBin.counts_by_length->isEmptyArray
        ? [("Card BINs", counts.cardBin.total_count)]
        : counts.cardBin.counts_by_length->Array.map(((length, count)) => (
            `${length->Int.toString}-digit BINs`,
            count,
          ))
    binCounts->Array.concat([("Fingerprints", counts.fingerprint.total_count)])
  }

  <div className="max-w-3xl">
    <div className="flex flex-col sm:flex-row gap-4">
      {blocklistCountsData
      ->Array.mapWithIndex(((title, count), index) =>
        <div key={index->Int.toString} className="flex-1 min-w-0">
          <PageLoaderWrapper
            screenState
            customUI={<NewAnalyticsHelper.NoData height="h-20" message="Couldn't load count." />}
            customLoader={<Shimmer styleClass="h-20 w-full rounded-lg" />}>
            <section className="h-full border border-nd_gray-200 rounded-lg bg-white p-4">
              <p className={`text-nd_gray-500 ${body.sm.medium}`}> {title->React.string} </p>
              <p className={`text-nd_gray-800 mt-1 ${heading.md.semibold}`}>
                {count->formatBlocklistCount->React.string}
              </p>
            </section>
          </PageLoaderWrapper>
        </div>
      )
      ->React.array}
    </div>
    <p className={`text-nd_gray-400 mt-2 ${body.sm.medium}`}>
      {"Counts are loaded when the page opens. Refresh the page to see updated counts after adding or removing entries."->React.string}
    </p>
  </div>
}
