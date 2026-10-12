open OffersHooks
open OffersUtils
open Typography

@react.component
let make = (~offerId, ~offerCode) => {
  let fetchBinList = useOfferBinList()
  let showToast = ToastState.useShowToast()
  let (bins, setBins) = React.useState(_ => None)
  let (isLoading, setIsLoading) = React.useState(_ => false)
  let (showModal, setShowModal) = React.useState(_ => false)
  let (searchText, setSearchText) = React.useState(_ => "")

  let withBins = async onLoaded => {
    switch bins {
    | Some(loadedBins) => onLoaded(loadedBins)
    | None =>
      setIsLoading(_ => true)
      try {
        let loadedBins = await fetchBinList(offerId)
        setBins(_ => Some(loadedBins))
        onLoaded(loadedBins)
      } catch {
      | Exn.Error(e) =>
        showToast(
          ~message=Exn.message(e)->Option.getOr("Failed to fetch the BIN list"),
          ~toastType=ToastError,
        )
      }
      setIsLoading(_ => false)
    }
  }

  let viewBins = _ => withBins(_ => setShowModal(_ => true))->ignore

  let downloadBins = _ =>
    withBins(loadedBins =>
      DownloadUtils.download(
        ~fileName=`${offerCode}_card_bins.csv`,
        ~content=loadedBins->binListCsvContent,
        ~fileType="text/csv",
      )
    )->ignore

  let loadedBins = bins->Option.getOr([])
  let visibleBins = loadedBins->Array.filter(bin => bin->String.includes(searchText->String.trim))

  <div className="flex items-center gap-3">
    <Button
      text="View"
      buttonType=Secondary
      buttonSize=Small
      buttonState={isLoading ? Disabled : Normal}
      onClick=viewBins
    />
    <Button
      text="Download"
      buttonType=Secondary
      buttonSize=Small
      buttonState={isLoading ? Disabled : Normal}
      onClick=downloadBins
    />
    <Modal
      showModal
      setShowModal
      modalHeading="Uploaded BIN List"
      modalHeadingDescription={`${loadedBins
        ->Array.length
        ->Int.toString} BINs uploaded for ${offerCode}`}
      alignModal="justify-center"
      modalClass="mt-20 overflow-auto max-h-85-vh">
      <div className="flex flex-col gap-4 p-4 w-133 max-w-full">
        <SearchInput
          onChange={value => setSearchText(_ => value)}
          inputText=searchText
          placeholder="Search BIN"
          autoFocus=false
          showSearchIcon=true
        />
        <div
          className="border border-nd_gray-150 rounded-xl bg-nd_gray-25 p-4 h-80 overflow-y-auto">
          <RenderIf condition={visibleBins->LogicUtils.isEmptyArray}>
            <div
              className={`flex items-center justify-center h-full text-nd_gray-500 ${body.md.regular}`}>
              {"No BINs match your search"->React.string}
            </div>
          </RenderIf>
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-2">
            {visibleBins
            ->Array.map(bin =>
              <div
                key=bin
                className={`bg-white border border-nd_gray-200 rounded-lg px-3 py-2 text-center font-mono text-nd_gray-700 ${body.md.medium}`}>
                {bin->React.string}
              </div>
            )
            ->React.array}
          </div>
        </div>
        <div className="flex justify-end gap-2 pt-3 border-t border-nd_gray-150">
          <Button text="Close" buttonType=Secondary onClick={_ => setShowModal(_ => false)} />
          <Button text="Download CSV" buttonType=Primary onClick=downloadBins />
        </div>
      </div>
    </Modal>
  </div>
}
