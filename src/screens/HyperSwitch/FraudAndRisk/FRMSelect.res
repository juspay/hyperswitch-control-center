module NewProcessorCards = {
  open FRMTypes
  open FRMInfo
  @react.component
  let make = (~configuredFRMs: array<frmName>, ~showIcons: bool) => {
    let frmAvailableForIntegration = frmList
    let unConfiguredFRMs =
      frmAvailableForIntegration->Array.filter(total =>
        configuredFRMs->Array.find(item => item === total)->Belt.Option.isNone
      )

    let handleClick = frmName => {
      RescriptReactRouter.push(`/fraud-risk-management/new?name=${frmName}`)
    }
    let unConfiguredFRMCount = unConfiguredFRMs->Array.length

    let descriptedFRMs = (frmList, heading) => {
      <>
        <h2
          className="font-bold text-xl text-black text-opacity-75 dark:text-white dark:text-opacity-75">
          {heading->React.string}
        </h2>
        <div className="grid gap-4 lg:grid-cols-4 md:grid-cols-2 grid-cols-1 mb-5">
          {frmList
          ->Array.mapWithIndex((frm, i) => {
            let frmName = frm->getFRMNameString
            let frmInfo = frm->getFRMInfo

            <CardUtils.CardLayout key={Belt.Int.toString(i)} width="w-full">
              <div className="flex gap-2 items-center mb-3">
                <GatewayIcon
                  gateway={frmName->String.toUpperCase} className="w-10 h-10 rounded-lg"
                />
                <h1 className="text-xl font-semibold break-all">
                  {frmName->LogicUtils.capitalizeString->React.string}
                </h1>
              </div>
              <div className="overflow-hidden text-gray-400 flex-1 mb-6">
                {frmInfo.description->React.string}
              </div>
              <Button
                text="+  Connect"
                buttonType={Secondary}
                buttonSize={Small}
                onClick={_ => {
                  handleClick(frmName)
                }}
              />
            </CardUtils.CardLayout>
          })
          ->React.array}
        </div>
      </>
    }

    let iconsFRMs = (frmList, heading) => {
      <>
        <h2
          className="font-bold text-xl text-black text-opacity-75 dark:text-white dark:text-opacity-75">
          {heading->React.string}
        </h2>
        <div className="flex gap-2 flex-wrap">
          {frmList
          ->Array.mapWithIndex((frm, i) => {
            let frmName = frm->getFRMNameString
            let size = "w-14 h-14 rounded-full"
            <ToolTip
              key={i->string_of_int}
              description={frmName->LogicUtils.capitalizeString}
              toolTipFor={<div
                className="bg-white p-2 cursor-pointer" onClick={_ => handleClick(frmName)}>
                <GatewayIcon gateway={frmName->String.toUpperCase} className=size />
              </div>}
              toolTipPosition={Top}
              tooltipWidthClass="w-30"
            />
          })
          ->React.array}
        </div>
      </>
    }

    let headerText = "Connect a new fraud & risk management player"

    <UIUtils.RenderIf condition={unConfiguredFRMCount > 0}>
      <div className="flex flex-col gap-4">
        {if showIcons {
          frmAvailableForIntegration->iconsFRMs(headerText)
        } else {
          frmAvailableForIntegration->descriptedFRMs(headerText)
        }}
      </div>
    </UIUtils.RenderIf>
  }
}

@react.component
let make = () => {
  open FRMInfo
  open UIUtils

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let fetchDetails = APIUtils.useGetMethod()
  let isMobileView = MatchMedia.useMatchMedia("(max-width: 844px)")
  let (configuredFRMs, setConfiguredFRMs) = React.useState(_ => [])
  let (previouslyConnectedData, setPreviouslyConnectedData) = React.useState(_ => [])
  let (filteredFRMData, setFilteredFRMData) = React.useState(_ => [])
  let (offset, setOffset) = React.useState(_ => 0)
  let detailedCardCount = 5
  let (searchText, setSearchText) = React.useState(_ => "")
  let showFRMIcons = configuredFRMs->Array.length > detailedCardCount

  let customUI =
    <HelperComponents.BluredTableComponent
      infoText="No connectors configured yet. Try connecting a connector."
      buttonText="Take me to connectors"
      onClickElement={React.null}
      onClickUrl="connectors"
      moduleName="Fraud & Risk Management"
      moduleSubtitle="Connect and configure processors to screen transactions and mitigate fraud"
    />

  React.useEffect0(() => {
    open Promise
    open LogicUtils
    fetchDetails(APIUtils.getURL(~entityName=FRAUD_RISK_MANAGEMENT, ~methodType=Get, ()))
    ->thenResolve(json => {
      let processorsList = json->getArrayFromJson([])->Array.map(getDictFromJsonObject)

      let connectorsCount =
        processorsList->FRMUtils.filterList(~removeFromList=FRMPlayer, ())->Array.length

      if connectorsCount > 0 {
        let frmList = processorsList->FRMUtils.filterList(~removeFromList=Connector, ())
        let previousData = frmList->Array.map(ConnectorTableUtils.getProcessorPayloadType)
        setFilteredFRMData(_ => previousData->Array.map(Js.Nullable.return))
        setPreviouslyConnectedData(_ => previousData->Array.map(Js.Nullable.return))
        let arr =
          frmList->Array.map(
            paymentMethod =>
              paymentMethod->getString("connector_name", "")->getFRMNameTypeFromString,
          )
        setConfiguredFRMs(_ => arr)
        setScreenState(_ => Success)
      } else {
        setScreenState(_ => Custom)
      }
    })
    ->catch(_ => {
      setScreenState(_ => Error("Failed to fetch"))
      resolve()
    })
    ->ignore
    None
  })
  // TODO: Convert it to remote filter
  let filterLogic = ReactDebounce.useDebounced(ob => {
    open LogicUtils
    let (searchText, arr) = ob
    let filteredList = if searchText->String.length > 0 {
      arr->Array.filter((frmPlayer: Js.Nullable.t<ConnectorTypes.connectorPayload>) => {
        switch Js.Nullable.toOption(frmPlayer) {
        | Some(frmPlayer) => isContainingStringLowercase(frmPlayer.connector_name, searchText)
        | None => false
        }
      })
    } else {
      arr
    }
    setFilteredFRMData(_ => filteredList)
  }, ~wait=200)

  <PageLoaderWrapper screenState customUI>
    <div className="flex flex-col gap-10 ">
      <PageUtils.PageHeading
        title="Fraud & Risk Management"
        subTitle="Connect and configure processors to screen transactions and mitigate fraud"
      />
      <RenderIf condition={showFRMIcons}>
        <NewProcessorCards configuredFRMs showIcons={showFRMIcons} />
      </RenderIf>
      <RenderIf condition={configuredFRMs->Array.length > 0}>
        <LoadedTable
          title="Previously Connected"
          actualData=filteredFRMData
          totalResults={filteredFRMData->Array.length}
          filters={<TableSearchFilter
            data={previouslyConnectedData}
            filterLogic
            placeholder="Search FRM Player Name"
            customSearchBarWrapperWidth="w-full lg:w-1/3"
            customInputBoxWidth="w-full"
            searchVal=searchText
            setSearchVal=setSearchText
          />}
          resultsPerPage=20
          offset
          setOffset
          entity={FRMTableUtils.connectorEntity("fraud-risk-management")}
          currrentFetchCount={filteredFRMData->Array.length}
          collapseTableRow=false
        />
      </RenderIf>
      <RenderIf condition={!showFRMIcons}>
        <NewProcessorCards configuredFRMs showIcons={showFRMIcons} />
      </RenderIf>
      <RenderIf condition={!isMobileView}>
        <img className="w-full max-w-[1400px] mb-10" src="/assets/frmBanner.svg" />
      </RenderIf>
    </div>
  </PageLoaderWrapper>
}
