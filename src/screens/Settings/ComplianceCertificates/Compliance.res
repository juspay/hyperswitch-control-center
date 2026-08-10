module DownloadCertificateTile = {
  @react.component
  let make = (~header, ~onClick, ~buttonState) => {
    <div
      className="flex flex-col bg-white pt-6 pl-6 pr-8 pb-8 justify-between gap-10 border border-jp-gray-border_gray rounded">
      <div>
        <p className="text-fs-16 font-semibold m-2"> {header->React.string} </p>
      </div>
      <Button
        buttonState
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
  let showToast = ToastAdapter.useShowToast()
  let fetchApi = AuthHooks.useApiFetcher()
  let (buttonState, setButtonState) = React.useState(_ => Button.Normal)
  let {xFeatureRoute, forceCookies, sendV1DummyApiKeyHeader, hyperswitchResources} =
    HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let customCompliance = WhitelabelUtils.getApprovedComplianceConfig()
  let isComplianceAvailable = hyperswitchResources || customCompliance->Option.isSome
  let certificateTitle = switch customCompliance {
  | Some(config) if !hyperswitchResources => config.certificateTitle
  | _ => "Hyperswitch's PCI Attestation of Compliance"
  }
  let downloadPDF = _ => {
    setButtonState(_ => Button.Loading)
    let currentDate =
      Date.now()
      ->Js.Date.fromFloat
      ->Date.toISOString
      ->TimeZoneHook.formattedISOString("YYYY-MM-DD HH:mm:ss")

    let (downloadURL, fileName) = switch customCompliance {
    | Some(config) if !hyperswitchResources => (
        config.certificateUrl,
        config.certificateDownloadFilename,
      )
    | _ => (
        Window.env.dssCertificateUrl->Option.getOr(""),
        `HyperswitchPCICertificate-${currentDate}.pdf`,
      )
    }

    // For local testing this condition is added
    if downloadURL->LogicUtils.isNonEmptyString {
      open Promise
      fetchApi(downloadURL, ~method_=Get, ~xFeatureRoute, ~forceCookies, ~sendV1DummyApiKeyHeader)
      ->then(resp => {
        Fetch.Response.blob(resp)
      })
      ->then(content => {
        DownloadUtils.download(~fileName, ~content, ~fileType="application/pdf")
        showToast(
          ~toastType=ToastSuccess,
          ~message="PCI Attestation of Compliance certificate download complete",
        )

        resolve()
      })
      ->catch(_ => {
        showToast(
          ~toastType=ToastError,
          ~message="Oops, something went wrong with the download. Please try again.",
        )
        resolve()
      })
      ->ignore
      setButtonState(_ => Button.Normal)
    } else {
      showToast(~toastType=ToastError, ~message="Oops, something went wrong with the download.")
      setButtonState(_ => Button.Normal)
    }
  }

  if !isComplianceAvailable {
    React.null
  } else {
    <div className="flex flex-col gap-12">
      <PageUtils.PageHeading
        title="Compliance" subTitle="Achieve and Maintain Industry Compliance Standards"
      />
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 md:gap-8">
        <DownloadCertificateTile header=certificateTitle onClick=downloadPDF buttonState />
      </div>
    </div>
  }
}
