module CustomerInfo = {
  open CustomersEntity
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
  let make = (~dict) => {
    let customerData = itemToObjMapper(dict)
    <>
      <div className={`font-bold text-fs-16 dark:text-white dark:text-opacity-75 mt-4 mb-4`}>
        {"Summary"->React.string}
      </div>
      <Details data=customerData getHeading getCell detailsFields=allColumns />
    </>
  }
}

@react.component
let make = (~id) => {
  open APIUtils
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (customersData, setCustomersData) = React.useState(_ => Js.Json.null)

  let fetchCustomersData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let customersUrl = getURL(~entityName=CUSTOMERS, ~methodType=Get, ~id=Some(id), ())
      let response = await fetchDetails(customersUrl)
      setCustomersData(_ => response)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Js.Exn.Error(e) =>
      let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }

  React.useEffect0(() => {
    fetchCustomersData()->ignore
    None
  })
  <PageLoaderWrapper screenState>
    <div className="flex flex-col overflow-scroll">
      <div className="mb-4 flex justify-between">
        <div className="flex items-center">
          <div>
            <PageUtils.PageHeading title="Customers" />
            <BreadCrumbNavigation
              path=[{title: "Customers", link: "/customers"}]
              currentPageTitle=id
              cursorStyle="cursor-pointer"
            />
          </div>
          <div />
        </div>
      </div>
      <CustomerInfo dict={customersData->LogicUtils.getDictFromJsonObject} />
    </div>
  </PageLoaderWrapper>
}
