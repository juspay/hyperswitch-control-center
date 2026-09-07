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
  let (cardBinCount, setCardBinCount) = React.useState(_ => defaultBlocklistCount)
  let (fingerprintCount, setFingerprintCount) = React.useState(_ => defaultBlocklistCount)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)

  let fetchCount = async dataKind => {
    let url = getURL(
      ~entityName=V1(BLOCKLIST_COUNT),
      ~methodType=Get,
      ~queryParameters=Some(dataKind->blocklistCountQuery),
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
      setCardBinCount(_ => cardBin)
      setFingerprintCount(_ => fingerprint)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  React.useEffect(() => {
    fetchCounts()->ignore
    None
  }, [profileId])

  let countCards = {
    let binCards =
      cardBinCount.counts_by_length->Array.map(((length, count)) => (
        `${length->blocklistCountLengthLabel} BINs`,
        count,
      ))
    let binCards = binCards->isEmptyArray ? [("Card BINs", cardBinCount.total_count)] : binCards
    binCards->Array.concat([("Fingerprints", fingerprintCount.total_count)])
  }

  <div className="max-w-3xl">
    <div className="flex flex-col sm:flex-row gap-4">
      {countCards
      ->Array.mapWithIndex(((title, count), index) =>
        <div key={index->Int.toString} className="flex-1 min-w-0">
          <PageLoaderWrapper
            screenState
            customUI={<NewAnalyticsHelper.NoData height="h-20" message="Couldn't load count." />}
            customLoader={<Shimmer styleClass="h-20 w-full rounded-lg" />}>
            <BlocklistHelper.CountCard title count />
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
