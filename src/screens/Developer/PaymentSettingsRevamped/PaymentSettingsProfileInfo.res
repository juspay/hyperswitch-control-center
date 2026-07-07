open BusinessProfileInterfaceTypes
open Typography

module InfoView = {
  @react.component
  let make = (~heading, ~subHeading, ~isCopy=false, ~isTruncated=false, ~copyValue="") => {
    <div className="flex flex-col gap-2 mx-1 my-4 w-1/3">
      <p className={`text-nd_gray-400 ${body.md.medium}`}> {heading->React.string} </p>
      <div className="flex gap-2 break-all w-full items-start">
        <p className={`text-nd_gray-600 ${body.lg.medium}`}> {subHeading->React.string} </p>
        <RenderIf condition={isCopy}>
          <HelperComponents.CopyTextCustomComp
            displayValue=Some("") copyValue={isTruncated ? Some(copyValue) : Some(subHeading)}
          />
        </RenderIf>
      </div>
    </div>
  }
}

module ProfileInfoHeader = {
  @react.component
  let make = (
    ~businessProfileRecoilVal: commonProfileEntity,
    ~profileId: string,
    ~merchantId: string,
  ) => {
    let hashKeyVal = businessProfileRecoilVal.payment_response_hash_key->Option.getOr("NA")
    let truncatedHashKey = `${hashKeyVal->String.slice(~start=0, ~end=20)}....`

    <div className="flex flex-col">
      <div className="flex">
        <InfoView heading="Profile Name" subHeading=businessProfileRecoilVal.profile_name />
        <InfoView heading="Profile ID" subHeading=profileId isCopy=true />
      </div>
      <div className="flex">
        <InfoView heading="Merchant ID" subHeading=merchantId />
        <InfoView
          heading="Payment Response Hash Key"
          subHeading=truncatedHashKey
          isCopy=true
          isTruncated=true
          copyValue=hashKeyVal
        />
      </div>
    </div>
  }
}
