module InfoViewForWebhooks = {
  @react.component
  let make = (~heading, ~subHeading, ~isCopy=false, ~isTruncated=false, ~copyValue="") => {
    let showToast = ToastState.useShowToast()
    let onCopyClick = ev => {
      ev->ReactEvent.Mouse.stopPropagation
      Clipboard.writeText(isTruncated ? copyValue : subHeading)
      showToast(~message="Copied to Clipboard!", ~toastType=ToastSuccess)
    }

    <div className={`flex flex-col gap-2 m-2 md:m-4 w-1/3`}>
      <p className="font-medium text-fs-14 text-nd_gray-400"> {heading->React.string} </p>
      <div className="flex gap-2 break-all w-full items-start">
        <p className="font-medium text-fs-16 text-nd_gray-600 "> {subHeading->React.string} </p>
        <RenderIf condition={isCopy}>
          <Icon
            name="nd-copy"
            className="cursor-pointer"
            onClick={ev => {
              onCopyClick(ev)
            }}
          />
        </RenderIf>
      </div>
    </div>
  }
}
@react.component
let make = () => {
  open HSwitchSettingTypes
  open Typography

  let businessProfileRecoilVal = BusinessProfileInterface.useBusinessProfileMapper(
    ~interface=BusinessProfileInterface.businessProfileInterfaceV1,
  )

  let (tabIndex, setTabIndex) = React.useState(_ => 0)

  let tabs: array<Tabs.tab> = [
    {
      title: "Payment Behaviour",
      renderContent: () => {
        React.null
      },
    },
    {
      title: "3DS",
      renderContent: () => React.null,
    },
    {
      title: "Custom Headers",
      renderContent: () => React.null,
    },
    {
      title: "Metadata Headers",
      renderContent: () => React.null,
    },
  ]
  let hashKeyVal = businessProfileRecoilVal.payment_response_hash_key->Option.getOr("NA")
  let truncatedHashKey = hashKeyVal->String.slice(~start=0, ~end=20)

  <div className="flex flex-col gap-8">
    <div className="flex flex-col gap-2">
      <p className={`${heading.md.semibold} ml-4`}> {"Payment settings"->React.string} </p>
      <p className={`${body.md.medium} text-nd_gray-400 ml-4`}>
        {"Set up and monitor transaction webhooks for real-time notifications."->React.string}
      </p>
    </div>
    <div className={`flex flex-col`}>
      <div className="flex">
        <InfoViewForWebhooks
          heading="Profile Name" subHeading=businessProfileRecoilVal.profile_name
        />
        <InfoViewForWebhooks
          heading="Profile ID" subHeading=businessProfileRecoilVal.profile_id isCopy=true
        />
      </div>
      <div className="flex ">
        <InfoViewForWebhooks
          heading="Merchant ID" subHeading={businessProfileRecoilVal.merchant_id}
        />
        <InfoViewForWebhooks
          heading="Payment Response Hash Key"
          subHeading={truncatedHashKey}
          isCopy=true
          isTruncated=true
          copyValue=hashKeyVal
        />
      </div>
      <Tabs
        tabs
        showBorder=true
        includeMargin=false
        initialIndex={tabIndex}
        onTitleClick={index => setTabIndex(_ => index)}
        selectTabBottomBorderColor="bg-nd_primary_blue-500"
      />
    </div>
  </div>
}
