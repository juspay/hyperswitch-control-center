module DownloadCertificateTile = {
  @react.component
  let make = (~header, ~onClick) => {
    <div
      className="flex flex-col bg-white pt-6 pl-6 pr-8 pb-8 justify-between gap-10 border border-jp-gray-border_gray rounded">
      <div>
        <p className="text-fs-16 font-semibold m-2"> {header->React.string} </p>
      </div>
      <Button
        text="Download"
        buttonSize={Medium}
        buttonType={Primary}
        rightIcon={FontAwesome("download-api-key")}
        onClick
      />
    </div>
  }
}

@react.component
let make = () => {
  let showToast = ToastState.useShowToast()
  let fetchApi = AuthHooks.useApiFetcher()

  let downloadPDF = () => {
    let currentDate =
      Date.now()
      ->Js.Date.fromFloat
      ->Date.toISOString
      ->TimeZoneHook.formattedISOString("YYYY-MM-DD HH:mm:ss")

    let downloadURL = Window.env.dssCertificateUrl->Option.getOr("")

    //? - For localtesting this condn added
    if downloadURL->LogicUtils.isNonEmptyString {
      open Promise
      fetchApi(downloadURL, ~method_=Get, ())
      ->then(resp => {
        Fetch.Response.blob(resp)
      })
      ->then(content => {
        DownloadUtils.download(
          ~fileName=`HyperswitchPCICertificate-${currentDate}.pdf`,
          ~content,
          ~fileType="application/pdf",
        )
        showToast(
          ~toastType=ToastSuccess,
          ~message="PCI Attestation of Compliance certificate download complete",
          (),
        )

        resolve()
      })
      ->catch(_ => {
        showToast(
          ~toastType=ToastError,
          ~message="Oops, something went wrong with the download. Please try again.",
          (),
        )
        resolve()
      })
      ->ignore
    } else {
      showToast(~toastType=ToastError, ~message="Oops, something went wrong with the download ", ())
    }
  }

  <div className="flex flex-col gap-12">
    <PageUtils.PageHeading
      title="Compliance" subTitle="Achieve and Maintain Industry Compliance Standards"
    />
    <div className="grid grid-cols-1 md:grid-cols-3 gap-4 md:gap-8">
      <DownloadCertificateTile
        header="Hyperswitch's PCI Attestation of Compliance" onClick={_ => downloadPDF()}
      />
    </div>
  </div>
}
