module DownloadCertificateTile = {
  @react.component
  let make = (~header, ~onClick) => {
    <div
      className="flex flex-col bg-white pt-6 pl-6 pr-8 pb-8 justify-between gap-10 border border-jp-gray-border_gray rounded">
      <div>
        <p className="text-fs-16 font-semibold m-2"> {header->React.string} </p>
      </div>
      <Button
        text="View"
        buttonSize=Medium
        buttonType=Primary
        rightIcon=FontAwesome("nd-external-link-square")
        onClick
        customButtonStyle="!w-fit"
        customTextPaddingClass="!pr-0"
      />
    </div>
  }
}

@react.component
let make = () => {
  open LogicUtils

  let usCertificateUrl = Window.env.dssCertificateUsUrl->Option.getOr("")
  let euCertificateUrl = Window.env.dssCertificateEuUrl->Option.getOr("")
  let hasCertificates = usCertificateUrl->isNonEmptyString || euCertificateUrl->isNonEmptyString

  <div className="flex flex-col gap-12">
    <PageUtils.PageHeading
      title="Compliance" subTitle="Achieve and Maintain Industry Compliance Standards"
    />
    <RenderIf condition={hasCertificates}>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 md:gap-8">
        <RenderIf condition={usCertificateUrl->isNonEmptyString}>
          <DownloadCertificateTile
            header="Hyperswitch's PCI Attestation of Compliance (US)"
            onClick={_ => usCertificateUrl->Window._open}
          />
        </RenderIf>
        <RenderIf condition={euCertificateUrl->isNonEmptyString}>
          <DownloadCertificateTile
            header="Hyperswitch's PCI Attestation of Compliance (EU)"
            onClick={_ => euCertificateUrl->Window._open}
          />
        </RenderIf>
      </div>
    </RenderIf>
    <RenderIf condition={!hasCertificates}>
      <NoDataFound
        message="No compliance certificates are available at the moment. Please contact support if you need access."
      />
    </RenderIf>
  </div>
}
