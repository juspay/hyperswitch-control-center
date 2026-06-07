open MerchantAcquirerDetailsTypes
open MerchantAcquirerDetailsModals
open Typography
open LogicUtils

module AccordionTitle = {
  @react.component
  let make = (
    ~bucket: acquirerBucket,
    ~isSelectionMode=false,
    ~isSelected=false,
    ~onSelect=() => (),
  ) => {
    let showToast = ToastState.useShowToast()
    let onCopyClick = ev => {
      ev->ReactEvent.Mouse.stopPropagation
      Clipboard.writeText(bucket.id)
      showToast(~message="Copied to Clipboard!", ~toastType=ToastSuccess)
    }
    <div className="flex flex-col gap-1 w-full px-4 py-1">
      <div className="flex items-center gap-3">
        <RenderIf condition={isSelectionMode}>
          <div
            className="cursor-pointer shrink-0"
            onClick={ev => {
              ev->ReactEvent.Mouse.stopPropagation
              onSelect()
            }}>
            <RadioIcon isSelected />
          </div>
        </RenderIf>
        <span className={`${body.lg.semibold} text-nd_gray-800`}>
          {bucket.merchant_name->isEmptyString
            ? "Unnamed Acquirer"->React.string
            : bucket.merchant_name->React.string}
        </span>
        <RenderIf condition={bucket.is_default}>
          <TagBinding text="Default" variant=Subtle size=Sm />
        </RenderIf>
      </div>
      <div className={`flex items-center gap-1 ${isSelectionMode ? "pl-7" : ""}`}>
        <span className={`${body.sm.regular} text-nd_gray-400`}>
          {`ID: ${bucket.id}`->React.string}
        </span>
        <Icon
          name="nd-copy" className="cursor-pointer text-nd_gray-400" size=12 onClick={onCopyClick}
        />
      </div>
    </div>
  }
}

module BucketBody = {
  @react.component
  let make = (~bucket: acquirerBucket) => {
    let (offset, setOffset) = React.useState(_ => 0)
    let (showAddNetwork, setShowAddNetwork) = React.useState(_ => false)
    let (editNetworkEntry, setEditNetworkEntry) = React.useState(_ => None)
    let actualData = bucket.networks->Array.map(Nullable.make)
    let totalResults = bucket.networks->Array.length

    <div className="flex flex-col w-full px-4 py-3">
      <RenderIf condition={bucket.networks->isNonEmptyArray}>
        <LoadedTable
          title="Networks"
          hideTitle=true
          actualData
          totalResults
          resultsPerPage=10
          offset
          setOffset
          entity={MerchantAcquirerDetailsEntity.makeEntityWithEditHandler(
            ~onEdit=Some(entry => setEditNetworkEntry(_ => Some(entry))),
            ~networks=bucket.networks,
          )}
          currentFetchCount=totalResults
          showPagination={totalResults > 10}
          tableLocalFilter=false
          showSerialNumber=false
          showAutoScroll=true
          tableheadingClass="bg-transparent text-nd_gray-600 border-b border-nd_br_gray-150"
        />
      </RenderIf>
      <RenderIf condition={bucket.networks->isEmptyArray}>
        <div className={`px-4 py-6 ${body.sm.medium} text-nd_gray-500`}>
          {"No networks configured."->React.string}
        </div>
      </RenderIf>
      <div className="px-4 py-3">
        <Button
          buttonType=Secondary
          onClick={_ => setShowAddNetwork(_ => true)}
          text="Add New Network"
          leftIcon={CustomIcon(<Icon name="nd-plus" size=16 />)}
          customIconMargin="pl-1"
        />
      </div>
      <RenderIf condition={showAddNetwork}>
        <AddNetworkModal showModal=showAddNetwork setShowModal=setShowAddNetwork bucket />
      </RenderIf>
      <RenderIf condition={editNetworkEntry->Option.isSome}>
        <EditNetworkModal entry=editNetworkEntry bucket setEntry=setEditNetworkEntry />
      </RenderIf>
    </div>
  }
}
