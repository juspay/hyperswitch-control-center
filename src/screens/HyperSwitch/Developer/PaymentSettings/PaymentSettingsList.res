@react.component
let make = (
  ~isFromSettings=true,
  ~showModalFromOtherScreen=false,
  ~setShowModalFromOtherScreen=_bool => (),
) => {
  open PaymentSettingsListEntity
  let (offset, setOffset) = React.useState(_ => 0)

  let businessProfileValues =
    HyperswitchAtom.businessProfilesAtom
    ->Recoil.useRecoilValueFromAtom
    ->MerchantAccountUtils.getArrayOfBusinessProfile

  <UIUtils.RenderIf condition=isFromSettings>
    <div className="relative h-full">
      <div className="flex flex-col-reverse md:flex-col">
        <PageUtils.PageHeading
          title="Payment settings"
          subTitle="Set up and monitor transaction webhooks for real-time notifications."
        />
        <LoadedTable
          title="Payment settings"
          hideTitle=true
          resultsPerPage=7
          visibleColumns
          entity={webhookProfileTableEntity}
          showSerialNumber=true
          actualData={businessProfileValues->Array.map(Js.Nullable.return)}
          totalResults={businessProfileValues->Array.length}
          offset
          setOffset
          currrentFetchCount={businessProfileValues->Array.length}
        />
      </div>
    </div>
  </UIUtils.RenderIf>
}
