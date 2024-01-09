open DisputesEntity

module DisputesNoteComponent = {
  open ConnectorUtils
  @react.component
  let make = (~disputesData: DisputesEntity.disputes) => {
    let dashboardLink = {
      switch disputesData.connector->getConnectorNameTypeFromString {
      | BLUESNAP | STRIPE =>
        <span
          className="underline underline-offset-2 cursor-pointer"
          onClick={_ => {
            let link = switch disputesData.connector->getConnectorNameTypeFromString {
            | BLUESNAP => "https://cp.bluesnap.com/jsp/developer_login.jsp"
            | STRIPE | _ => " https://dashboard.stripe.com/disputes"
            }
            link->Window._open
          }}>
          {"dashboard."->React.string}
        </span>
      | _ => <span> {"dashboard."->React.string} </span>
      }
    }

    <div
      className="flex border items-start border-blue-800 text-sm rounded-md gap-2 px-4 py-3 mt-5">
      <Icon name="info-vacent" className="text-blue-900 mt-1" size=18 />
      <span>
        {"Coming soon! You would soon be able to upload evidences against disputes directly from your Hyperswitch dashboard. Until then, please use Hyperswitch dashboard to track any changes in dispute status while uploading evidences from your relevant connector "->React.string}
        {dashboardLink}
      </span>
    </div>
  }
}

module DisputesInfo = {
  module Details = {
    @react.component
    let make = (
      ~data,
      ~getHeading,
      ~getCell,
      ~excludeColKeys=[],
      ~detailsFields,
      ~justifyClassName="justify-start",
      ~widthClass="w-1/4",
      ~bgColor="bg-white dark:bg-jp-gray-lightgray_background",
      ~children=?,
    ) => {
      <OrderUtils.Section
        customCssClass={`border border-jp-gray-940 border-opacity-75 dark:border-jp-gray-960 ${bgColor} rounded-md p-5`}>
        <div className="flex items-center">
          <div className="font-bold text-4xl m-3">
            {DisputesEntity.amountValue(data.amount, data.currency)->React.string}
          </div>
          {getStatus(data)}
        </div>
        <FormRenderer.DesktopRow>
          <div
            className={`flex flex-wrap ${justifyClassName} dark:bg-jp-gray-lightgray_background dark:border-jp-gray-no_data_border`}>
            {detailsFields
            ->Array.mapWithIndex((colType, i) => {
              <UIUtils.RenderIf condition={!(excludeColKeys->Array.includes(colType))}>
                <div className={`flex ${widthClass} items-center`} key={Belt.Int.toString(i)}>
                  <OrderUtils.DisplayKeyValueParams
                    heading={getHeading(colType)}
                    value={getCell(data, colType)}
                    customMoneyStyle="!font-normal !text-sm"
                    labelMargin="!py-0 mt-2"
                    overiddingHeadingStyles="text-black text-sm font-medium"
                    textColor="!font-normal !text-jp-gray-700"
                  />
                </div>
              </UIUtils.RenderIf>
            })
            ->React.array}
          </div>
        </FormRenderer.DesktopRow>
        <UIUtils.RenderIf condition={children->Belt.Option.isSome}>
          {children->Belt.Option.getWithDefault(React.null)}
        </UIUtils.RenderIf>
      </OrderUtils.Section>
    }
  }
  @react.component
  let make = (~orderDict) => {
    let disputesData = DisputesEntity.itemToObjMapper(orderDict)
    <>
      <div className={`font-bold text-fs-16 dark:text-white dark:text-opacity-75 mt-4 mb-4`}>
        {"Summary"->React.string}
      </div>
      <Details data=disputesData getHeading getCell detailsFields=allColumns />
      <DisputesNoteComponent disputesData />
    </>
  }
}

@react.component
let make = (~id) => {
  open APIUtils
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (disputeData, setDisputeData) = React.useState(_ => Js.Json.null)

  let fetchDisputesData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let disputesUrl = getURL(~entityName=DISPUTES, ~methodType=Get, ~id=Some(id), ())
      let response = await fetchDetails(disputesUrl)
      setDisputeData(_ => response)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Js.Exn.Error(e) =>
      let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }

  React.useEffect0(() => {
    fetchDisputesData()->ignore
    None
  })
  <PageLoaderWrapper screenState>
    <div className="flex flex-col overflow-scroll">
      <div className="mb-4 flex justify-between">
        <div className="flex items-center">
          <div>
            <PageUtils.PageHeading title="Disputes" />
            <BreadCrumbNavigation
              path=[{title: "Disputes", link: "/disputes"}]
              currentPageTitle=id
              cursorStyle="cursor-pointer"
            />
          </div>
          <div />
        </div>
      </div>
      <DisputesInfo orderDict={disputeData->LogicUtils.getDictFromJsonObject} />
    </div>
  </PageLoaderWrapper>
}
