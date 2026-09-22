open LogicUtils
open OffersFormUtils
open Typography

@react.component
let make = () => {
  let form = ReactFinalForm.useForm()
  let showToast = ToastState.useShowToast()
  let inputRef = React.useRef(Nullable.null)
  let (fileName, setFileName) = React.useState(_ => "")
  let (binCount, setBinCount) = React.useState(_ => 0)

  let clearFileInput = () =>
    inputRef.current
    ->getOptionalFromNullable
    ->Option.forEach(elem => elem->DOMUtils.toInputElement->DOMUtils.setInputValue(""))

  let setBins = (~name, ~bins) => {
    form.change("card_bins", bins->getJsonFromArrayOfString)
    setFileName(_ => name)
    setBinCount(_ => bins->Array.length)
  }

  let removeFile = _ => {
    setBins(~name="", ~bins=[])
    clearFileInput()
  }

  let handleFileContents = (~name, event) => {
    let content = ReactEvent.Form.target(event)["result"]
    switch content->parseBinCsv {
    | Ok(bins) => setBins(~name, ~bins)
    | Error(message) => {
        showToast(~message, ~toastType=ToastError)
        clearFileInput()
      }
    }
  }

  let handleFileChange = ev => {
    switch ReactEvent.Form.target(ev)["files"][0] {
    | Some(file) => {
        let fileReader = FileReader.reader
        fileReader.onload = event => handleFileContents(~name=file["name"], event)
        fileReader.onerror = _ =>
          showToast(~message="Unable to read the CSV file", ~toastType=ToastError)
        fileReader->FileReader.readFileAsText(file)
      }
    | None => ()
    }
  }

  let triggerFilePicker = _ =>
    inputRef.current->getOptionalFromNullable->Option.forEach(elem => elem->DOMUtils.click())

  let downloadSampleFile = _ =>
    DownloadUtils.download(
      ~fileName="card_bin_sample.csv",
      ~content="CARD_BIN\n411111\n555555",
      ~fileType="text/csv",
    )

  <div className="flex flex-col gap-3">
    <div className={`text-nd_gray-700 ${body.md.medium}`}> {"Card BIN List"->React.string} </div>
    <p className={`text-nd_gray-500 ${body.sm.regular}`}>
      {`Upload a CSV with a CARD_BIN header and one 6 to 9 digit BIN per row (up to ${maxBinRows->Int.toString}). Only the listed BINs will be eligible for this offer.`->React.string}
    </p>
    <input
      type_="file"
      accept=".csv"
      className="hidden"
      ref={inputRef->ReactDOM.Ref.domRef}
      onChange=handleFileChange
    />
    <div className="flex items-center gap-3">
      <Button text="Choose File" buttonType=Secondary buttonSize=Small onClick=triggerFilePicker />
      <Button
        text="Download Sample" buttonType=Secondary buttonSize=Small onClick=downloadSampleFile
      />
    </div>
    <RenderIf condition={fileName->isNonEmptyString}>
      <div
        className="flex items-center justify-between gap-4 border border-nd_gray-200 rounded-lg bg-nd_gray-25 p-4">
        <div className={`text-nd_gray-700 ${body.md.medium}`}>
          {`${fileName} - ${binCount->Int.toString} BINs`->React.string}
        </div>
        <Button text="Remove" buttonType=Secondary buttonSize=Small onClick=removeFile />
      </div>
    </RenderIf>
  </div>
}
