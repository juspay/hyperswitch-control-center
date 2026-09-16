open Typography
open LogicUtils
open OffersTypes
open OffersUtils
open OfferDetailHelper
open OffersEntity

module SummarySection = {
  @react.component
  let make = (~detail: offerDetail) =>
    <SectionCard title="Offer Summary">
      <DetailsGrid
        data=detail
        getHeading=getHeadingForSummary
        getCell=getCellForSummary
        detailsFields=summaryDetailsFields
      />
    </SectionCard>
}

module BenefitsSection = {
  @react.component
  let make = (~benefits: array<benefit>) =>
    <SectionCard title="Benefits">
      <DetailsTable
        title="Benefits"
        columns=benefitColumns
        getHeading=getHeadingForBenefit
        getCell=getCellForBenefit
        items=benefits
        emptyMessage="No benefits configured on this offer"
      />
    </SectionCard>
}

module PaymentSection = {
  @react.component
  let make = (~ruleDsl: ruleDsl) =>
    <SectionCard title="Payment Details">
      <div className="flex flex-col gap-5">
        <DetailsTable
          title="Payment Instruments"
          columns=paymentInstrumentColumns
          getHeading=getHeadingForPaymentInstrument
          getCell=getCellForPaymentInstrument
          items=ruleDsl.paymentInstrument
          emptyMessage="No payment instrument restrictions - this offer applies to all payment methods"
        />
        <DetailsGrid
          data=ruleDsl
          getHeading=getHeadingForPaymentSummary
          getCell=getCellForPaymentSummary
          detailsFields=paymentSummaryFields
          widthClass="md:w-1/2 w-full"
        />
      </div>
    </SectionCard>
}

module OrderSection = {
  @react.component
  let make = (~order: orderConstraint) =>
    <SectionCard title="Order Constraints">
      <div className="flex flex-col gap-5">
        <DetailsTable
          title="Order Currencies"
          columns=currencyColumns
          getHeading=getHeadingForCurrency
          getCell=getCellForCurrency
          items=order.currencies
          emptyMessage="No order amount constraints"
        />
        <DetailsGrid
          data=order
          getHeading=getHeadingForOrderSummary
          getCell=getCellForOrderSummary
          detailsFields=orderSummaryFields
          widthClass="md:w-1/3 w-full"
        />
      </div>
    </SectionCard>
}

module CountersSection = {
  @react.component
  let make = (~counters: array<counter>, ~counterInfo: array<counterInfo>) =>
    <SectionCard title="Counters and Limits">
      <div className="flex flex-col gap-5">
        <DetailsTable
          title="Counters"
          columns=counterColumns
          getHeading=getHeadingForCounter
          getCell=getCellForCounter
          items=counters
          emptyMessage="No counters configured on this offer"
        />
        <RenderIf condition={counterInfo->isNonEmptyArray}>
          <div className="flex flex-col gap-2">
            <p className={`${body.md.semibold} text-nd_gray-700`}>
              {"Current usage"->React.string}
            </p>
            <DetailsTable
              title="Counter Usage"
              columns=counterInfoColumns
              getHeading=getHeadingForCounterInfo
              getCell=getCellForCounterInfo
              items=counterInfo
              emptyMessage=emptyValuePlaceholder
            />
          </div>
        </RenderIf>
      </div>
    </SectionCard>
}

module FiltersSection = {
  @react.component
  let make = (~filters: filters) => {
    let renderEntries = (entries: array<filterEntry>, ~emptyMessage) =>
      entries->isEmptyArray
        ? <div className={`${body.md.medium} text-nd_gray-400`}> {emptyMessage->React.string} </div>
        : <div className="flex flex-col gap-4">
            {entries
            ->Array.mapWithIndex((entry, index) =>
              <div key={index->Int.toString} className="flex flex-col gap-2">
                <div className={`${body.md.medium} text-nd_gray-500`}>
                  {entry.filterType->snakeToTitle->React.string}
                </div>
                {entry.isValueUploaded
                  ? <div className={`${body.md.medium} text-nd_gray-400`}>
                      {"Values uploaded via CSV"->React.string}
                    </div>
                  : <Chips values=entry.values />}
              </div>
            )
            ->React.array}
          </div>

    <SectionCard title="Filters">
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="flex flex-col gap-3">
          <p className={`${body.md.semibold} text-nd_gray-700`}> {"Whitelist"->React.string} </p>
          {filters.whitelist->renderEntries(~emptyMessage="No whitelist filters")}
        </div>
        <div className="flex flex-col gap-3">
          <p className={`${body.md.semibold} text-nd_gray-700`}> {"Blacklist"->React.string} </p>
          {filters.blacklist->renderEntries(~emptyMessage="No blacklist filters")}
        </div>
      </div>
    </SectionCard>
  }
}

module ScheduleSection = {
  @react.component
  let make = (~schedule: schedule) =>
    <SectionCard title="Schedule">
      <DetailsGrid
        data=schedule
        getHeading=getHeadingForSchedule
        getCell=getCellForSchedule
        detailsFields=scheduleDetailsFields
      />
    </SectionCard>
}

module AdditionalConfigSection = {
  @react.component
  let make = (~detail: offerDetail) =>
    <SectionCard title="Additional Configuration">
      <div className="flex flex-col gap-5">
        <DetailsGrid
          data=detail
          getHeading=getHeadingForAdditionalConfig
          getCell=getCellForAdditionalConfig
          detailsFields=additionalConfigFields
        />
        <RenderIf condition={detail.udfs->isNonEmptyArray}>
          <div className="flex flex-col gap-2">
            <p className={`${body.md.semibold} text-nd_gray-700`}> {"UDFs"->React.string} </p>
            <DetailsGrid
              data=detail.udfs
              getHeading={((key, _)) => Table.makeHeaderInfo(~key, ~title=key->String.toUpperCase)}
              getCell={(_, (_, value)) => Table.Text(value->displayOrPlaceholder)}
              detailsFields=detail.udfs
            />
          </div>
        </RenderIf>
        <RenderIf condition={detail.offer.offerDescription.description->isNonEmptyString}>
          <DisplayKeyValueParams
            heading={Table.makeHeaderInfo(~key="description", ~title="Description")}
            value={Table.Text(detail.offer.offerDescription.description)}
          />
        </RenderIf>
      </div>
    </SectionCard>
}

module RawRuleDslSection = {
  @react.component
  let make = (~ruleDsl: JSON.t) => {
    let (isExpanded, setIsExpanded) = React.useState(_ => false)

    <SectionCard
      title="Raw Rule DSL"
      rightElement={<Button
        text={isExpanded ? "Hide" : "Show"}
        buttonType={SecondaryFilled}
        buttonSize={Small}
        onClick={_ => setIsExpanded(prev => !prev)}
      />}>
      <RenderIf condition=isExpanded>
        <pre
          className={`${code.md.regular} bg-nd_gray-50 border border-nd_gray-150 rounded-lg p-4 overflow-x-auto text-nd_gray-700`}>
          {ruleDsl->JSON.stringifyWithIndent(2)->React.string}
        </pre>
      </RenderIf>
    </SectionCard>
  }
}

@react.component
let make = (~id) => {
  let fetchOfferDetail = OffersHooks.useOfferDetail()
  let fetchUiConfig = OffersHooks.useOffersUiConfig()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (offerDetail, setOfferDetail) = React.useState(_ => None)
  let (uiConfig, setUiConfig) = React.useState(_ => Dict.make())
  let (refetchCounter, setRefetchCounter) = React.useState(_ => 0)

  let hasManageAccess = userHasAccess(~groupAccess=OperationsManage) === Access

  let getUiConfig = async () => {
    try {
      let config = await fetchUiConfig()
      setUiConfig(_ => config)
    } catch {
    | _ => ()
    }
  }

  let getOfferDetail = async () => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    try {
      switch await fetchOfferDetail(id) {
      | Some(detail) =>
        setOfferDetail(_ => Some(detail))
        setScreenState(_ => PageLoaderWrapper.Success)
      | None => setScreenState(_ => PageLoaderWrapper.Custom)
      }
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to fetch the offer")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }

  React.useEffect(() => {
    getOfferDetail()->ignore
    None
  }, [refetchCounter])

  React.useEffect(() => {
    getUiConfig()->ignore
    None
  }, [])

  let customUI = <NoDataFound message="Offer not found" renderType={Painting} />

  <div className="flex flex-col overflow-scroll gap-8">
    <PageLoaderWrapper screenState customUI>
      {switch offerDetail {
      | Some(detail) =>
        let offer = detail.offer
        let {ruleDsl} = offer
        <div className="flex flex-col gap-6">
          <div className="flex flex-col gap-4">
            <BreadCrumbNavigation
              path=[{title: "Offers", link: "/offers"}] currentPageTitle={offer.offerCode}
            />
            <div className="flex items-end justify-between w-full">
              <PageUtils.PageHeading
                title={offer->offerTitle->displayOrPlaceholder}
                customHeadingStyle="!mb-0"
                customTagComponent={<Table.TableCell
                  cell={Label({
                    title: offer.status->statusToDisplayName->String.toUpperCase,
                    color: offer.status->statusToLabelColor,
                  })}
                />}
              />
              <RenderIf condition=hasManageAccess>
                <OfferRowActions
                  offer
                  onStatusToggled={() => setRefetchCounter(prev => prev + 1)}
                  onDiscarded={() => setRefetchCounter(prev => prev + 1)}
                />
              </RenderIf>
            </div>
          </div>
          <SummarySection detail />
          <BenefitsSection benefits=ruleDsl.benefits />
          <RenderIf condition={uiConfig->isFieldEnabled("rule_dsl.payment_instrument")}>
            <PaymentSection ruleDsl />
          </RenderIf>
          <RenderIf condition={uiConfig->isFieldEnabled("rule_dsl.order")}>
            <OrderSection order=ruleDsl.order />
          </RenderIf>
          <RenderIf condition={uiConfig->isFieldEnabled("rule_dsl.counters")}>
            <CountersSection counters=ruleDsl.counters counterInfo=detail.counterInfo />
          </RenderIf>
          <RenderIf condition={uiConfig->isFieldEnabled("rule_dsl.filters")}>
            <FiltersSection filters=ruleDsl.filters />
          </RenderIf>
          {switch ruleDsl.schedule {
          | Some(schedule) =>
            <RenderIf condition={uiConfig->isFieldEnabled("rule_dsl.schedule")}>
              <ScheduleSection schedule />
            </RenderIf>
          | None => React.null
          }}
          <AdditionalConfigSection detail />
          <RawRuleDslSection ruleDsl=ruleDsl.raw />
        </div>
      | None => React.null
      }}
    </PageLoaderWrapper>
  </div>
}
