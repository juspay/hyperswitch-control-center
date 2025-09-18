open Typography

@react.component
let make = (~accountId) => {
  open APIUtils
  open LogicUtils
  open ReconEngineAccountsTransformationUtils
  open ReconEngineAccountsUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let url = RescriptReactRouter.useUrl()

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (transformationConfigs, setTransformationConfigs) = React.useState(_ => [
    Dict.make()->getTransformationConfigPayloadFromDict,
  ])
  let (accountData, setAccountData) = React.useState(_ => Dict.make()->getAccountPayloadFromDict)
  let (showModal, setShowModal) = React.useState(_ => false)
  let (selectedTransformation, setSelectedTransformation) = React.useState(_ =>
    Dict.make()->getTransformationConfigPayloadFromDict
  )

  let getTransformationDetails = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let transformationConfigUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#TRANSFORMATION_CONFIG,
        ~queryParamerters=Some(`account_id=${accountId}`),
      )
      let accountUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#ACCOUNTS_LIST,
        ~id=Some(accountId),
      )
      let transformationConfigsRes = await fetchDetails(transformationConfigUrl)
      let accountRes = await fetchDetails(accountUrl)
      let transformationConfigs =
        transformationConfigsRes->getArrayDataFromJson(getTransformationConfigPayloadFromDict)
      let accountData = accountRes->getDictFromJsonObject->getAccountPayloadFromDict

      switch url.search->getTransformationIdFromUrl {
      | Some(id) => {
          let transformation = transformationConfigs->Array.find(config => config.id === id)
          setSelectedTransformation(_ =>
            switch transformation {
            | Some(config) => config
            | None => Dict.make()->getTransformationConfigPayloadFromDict
            }
          )
        }
      | None => ()
      }

      setAccountData(_ => accountData)
      setTransformationConfigs(_ => transformationConfigs)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  let tabs: array<Tabs.tab> = React.useMemo(() => {
    open Tabs
    transformationConfigs->Array.map(config => {
      title: config.name,
      onTabSelection: {
        _ => {
          setSelectedTransformation(_ => config)
          RescriptReactRouter.push(
            GlobalVars.appendDashboardPath(
              ~url=`/v1/recon-engine/transformation/${config.account_id}?transformationId=${config.id}`,
            ),
          )
        }
      },
      renderContent: () =>
        <FilterContext
          key="recon-engine-accounts-transformation-details"
          index="recon-engine-accounts-transformation-details">
          <ReconEngineAccountsTransformationTabDetails config />
        </FilterContext>,
    })
  }, [transformationConfigs])

  let getActiveTabIndex = React.useMemo(() => {
    switch url.search->getTransformationIdFromUrl {
    | Some(transformationId) =>
      transformationConfigs->Array.findIndex(config => config.id === transformationId)
    | None => 0
    }
  }, (url.search, transformationConfigs))

  React.useEffect(() => {
    getTransformationDetails()->ignore
    None
  }, [url.search, accountId])

  <div className="flex flex-col gap-6 w-full">
    <div className="flex flex-row items-center justify-between">
      <BreadCrumbNavigation
        path=[{title: "Transformation", link: `/v1/recon-engine/transformation`}]
        currentPageTitle=accountData.account_name
        cursorStyle="cursor-pointer"
        customTextClass="text-nd_gray-400"
        titleTextClass="text-nd_gray-600 font-medium"
        fontWeight="font-medium"
        dividerVal=Slash
        childGapClass="gap-2"
      />
      <div className="flex flex-row items-center gap-4">
        <Button
          text="View Mapping"
          buttonState=Normal
          buttonType=Secondary
          onClick={_ => setShowModal(_ => true)}
          buttonSize=Large
        />
        <ToolTip
          toolTipPosition=Bottom
          description="This feature is available in prod"
          toolTipFor={<Button
            text="Add New Transformation"
            customButtonStyle="!cursor-not-allowed"
            buttonState=Normal
            buttonType=Primary
            onClick={_ => ()}
            buttonSize=Large
          />}
        />
      </div>
    </div>
    <div className="flex flex-col gap-2">
      <PageUtils.PageHeading
        title=accountData.account_name
        customTitleStyle={`${heading.lg.semibold}`}
        customHeadingStyle="py-0"
      />
      <PageLoaderWrapper screenState>
        <RenderIf condition={transformationConfigs->Array.length == 0}>
          <div className="my-4">
            <NoDataFound
              message="No ingestion configs found. Please create a config to view the details."
              renderType={Painting}
              customMessageCss={`${body.lg.semibold} text-nd_gray-400`}
            />
          </div>
        </RenderIf>
        <RenderIf condition={transformationConfigs->Array.length > 0}>
          <Tabs
            tabs
            showBorder=true
            includeMargin=false
            initialIndex={getActiveTabIndex}
            defaultClasses={`!w-max flex flex-auto flex-row items-center justify-center ${body.md.semibold}`}
            selectTabBottomBorderColor="bg-primary"
          />
        </RenderIf>
      </PageLoaderWrapper>
    </div>
    <RenderIf condition=showModal>
      <ReconEngineAccountsTransformationDetailsMappers
        showModal setShowModal selectedTransformation
      />
    </RenderIf>
  </div>
}
