@react.component
let make = () => {
  let {updateExistingKeys, filterKeys} = React.useContext(FilterContext.filterContext)
  let startTimeFilterKey = HSAnalyticsUtils.startTimeFilterKey
  let endTimeFilterKey = HSAnalyticsUtils.endTimeFilterKey

  let setInitialFilters = HSwitchRemoteFilter.useSetInitialFilters(
    ~updateExistingKeys,
    ~startTimeFilterKey,
    ~endTimeFilterKey,
    ~origin="recon_engine_revamped_pipelines",
    ~range=90,
    (),
  )

  React.useEffect(() => {
    setInitialFilters()
    None
  }, [])

  let (statusFilter, setStatusFilter) = React.useState(_ => "all")
  let (showUploadModal, setShowUploadModal) = React.useState(_ => false)

  <div className="w-full">
    <div className="flex flex-row items-center justify-between w-full">
      <ReconEngineRevampedHelper.PageHeading title="Pipelines" />
      <div className="flex flex-row items-center gap-4">
        <div className="-translate-y-1">
          <DynamicFilter
            title="ReconEngineRevampedPipelinesFilters"
            initialFilters=[]
            options=[]
            popupFilterFields=[]
            initialFixedFilters={HSAnalyticsUtils.initialFixedFilterFields(null)}
            defaultFilterKeys=[startTimeFilterKey, endTimeFilterKey]
            tabNames=filterKeys
            key="ReconEngineRevampedPipelinesFilters"
            updateUrlWith=updateExistingKeys
            filterFieldsPortalName={HSAnalyticsUtils.filterFieldsPortalName}
            showCustomFilter=false
            refreshFilters=false
          />
        </div>
        <Button
          rightIcon={CustomIcon(<Icon name="nd-upload-file" size=12 />)}
          text="Upload a file"
          buttonType=Primary
          buttonSize=Small
          onClick={_ => setShowUploadModal(_ => true)}
          maxButtonWidth="!w-fit"
        />
      </div>
    </div>
    <ReconEngineRevampedPipelinesStatCards onCardClick={s => setStatusFilter(_ => s)} />
    <ReconEngineRevampedPipelinesTable statusFilter setStatusFilter />
    <ReconEngineRevampedPipelinesUploadModal
      showModal=showUploadModal setShowModal=setShowUploadModal onUploadSuccess={() => ()}
    />
  </div>
}
