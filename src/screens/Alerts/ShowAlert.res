@react.component
let make = (~id: string) => {
  open AlertsUtils
  open AlertsHelper
  open LogicUtils
  open Typography
  open AlertsEntity

  let fetchAlertDetails = AlertsHooks.useAlertDetails()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (alert, setAlert) = React.useState(_ => Dict.make()->itemToObjMapper)
  let (showBlacklistModal, setShowBlacklistModal) = React.useState(_ => false)
  let (showSnoozeModal, setShowSnoozeModal) = React.useState(_ => false)
  let (showResolveModal, setShowResolveModal) = React.useState(_ => false)

  let getAlertDetails = async () => {
    try {
      let fetchedAlert = await fetchAlertDetails(~id)
      setAlert(_ => fetchedAlert)
      setScreenState(_ =>
        fetchedAlert.id->isNonEmptyString ? PageLoaderWrapper.Success : PageLoaderWrapper.Custom
      )
    } catch {
    | Exn.Error(e) =>
      setScreenState(_ => PageLoaderWrapper.Error(
        Exn.message(e)->Option.getOr("Failed to fetch alert"),
      ))
    }
  }

  React.useEffect(() => {
    setScreenState(_ => PageLoaderWrapper.Loading)
    getAlertDetails()->ignore
    None
  }, [id])

  let customUI = <NoDataFound message="Alert not found" renderType={Painting} />

  <PageLoaderWrapper screenState customUI>
    <RenderIf condition={alert.id->isNonEmptyString}>
      <div className="flex flex-col gap-5">
        <div className="flex justify-between items-start flex-wrap gap-3 mb-4">
          <div>
            <PageUtils.PageHeading title=alert.name customHeadingStyle="mb-2" />
            <BreadCrumbNavigation
              path=[{title: "Alerts", link: "/alerts-business-insights"}]
              currentPageTitle=alert.name
            />
          </div>
          <ActionButtons
            isBlacklisted=alert.isBlacklisted
            onBlacklist={() => setShowBlacklistModal(_ => true)}
            onSnooze={() => setShowSnoozeModal(_ => true)}
            onResolve={() => setShowResolveModal(_ => true)}
          />
        </div>
        <Card
          title="Details"
          titleRight={<div className="flex items-center gap-2">
            <TableUtils.LabelCell labelColor=LabelGray text=alert.product />
            <RenderIf condition=alert.isBlacklisted>
              <TableUtils.LabelCell
                labelColor=LabelRed text={(AlertsTypes.Blacklisted :> string)}
              />
            </RenderIf>
            <RenderIf condition=alert.isSnoozed>
              <TableUtils.LabelCell labelColor=LabelOrange text="Snoozed" />
            </RenderIf>
          </div>}>
          <AlertDetailsGrid
            alert
            columns=[
              AlertDate,
              AlertPriority,
              AlertStatus,
              AlertDuration,
              AlertMerchantId,
              AlertProfileId,
              AlertConnector,
            ]
            getHeading
            getCell>
            <div className="flex flex-col gap-1.5 min-w-0">
              <span className={`${body.sm.medium} text-nd_gray-500`}>
                {"Comment"->React.string}
              </span>
              <AlertsCommentEditor alert onSaved={() => getAlertDetails()->ignore} />
            </div>
          </AlertDetailsGrid>
        </Card>
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-5 items-start">
          <div className="flex flex-col gap-5">
            <Card title="Summary">
              <div className="flex flex-col max-h-96 overflow-y-auto">
                <AlertDetailRow label="Attribution" cell={Text(alert.attribution)} />
                <RenderIf condition={alert.total > 0.0}>
                  <AlertDetailRow
                    label="Success Rate" cell={Text(alert->formatSuccessRateSummary)}
                  />
                </RenderIf>
                {alert.metadata
                ->getDictFromJsonObject
                ->Dict.toArray
                ->Array.filterMap(((key, value)) =>
                  value->JSON.Decode.string->Option.map(text => (key, text))
                )
                ->Array.filter(((_, text)) => text->isNonEmptyString && text !== "Unknown")
                ->Array.map(((key, text)) =>
                  <AlertDetailRow key label={key->snakeToTitle} cell={Text(text)} />
                )
                ->React.array}
              </div>
            </Card>
          </div>
          <Card title="Raw Data">
            <div className="h-96 overflow-y-auto">
              <Tabs tabs={alert->rawDataTabs} />
            </div>
          </Card>
        </div>
        <AlertsBlacklistModal
          alert
          showModal=showBlacklistModal
          setShowModal=setShowBlacklistModal
          onSaved={() => getAlertDetails()->ignore}
        />
        <AlertsSnoozeModal
          alert
          showModal=showSnoozeModal
          setShowModal=setShowSnoozeModal
          onSaved={() => getAlertDetails()->ignore}
        />
        <AlertsResolveModal
          alert
          showModal=showResolveModal
          setShowModal=setShowResolveModal
          onSaved={() => getAlertDetails()->ignore}
        />
      </div>
    </RenderIf>
  </PageLoaderWrapper>
}
