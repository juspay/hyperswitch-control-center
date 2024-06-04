module Details = {
  open OrderUtils
  @react.component
  let make = (
    ~heading,
    ~data,
    ~getHeading,
    ~getCell,
    ~excludeColKeys=[],
    ~detailsFields,
    ~justifyClassName="justify-start",
    ~widthClass="w-3/12",
    ~chargeBackField=None,
    ~bgColor="bg-white dark:bg-jp-gray-lightgray_background",
    ~children=?,
    ~headRightElement=React.null,
    ~borderRequired=true,
    ~isHeadingRequired=true,
    ~cardView=false,
    ~showDetails=true,
    ~headingCss="",
    ~showTitle=true,
    ~flexClass="flex flex-wrap",
  ) => {
    if !cardView {
      <OrderUtils.Section
        customCssClass={`${borderRequired
            ? "border border-jp-gray-940 border-opacity-75 dark:border-jp-gray-960"
            : ""} ${bgColor} rounded-md `}>
        <UIUtils.RenderIf condition=isHeadingRequired>
          <Heading topic=heading headingCss> {headRightElement} </Heading>
        </UIUtils.RenderIf>
        <UIUtils.RenderIf condition=showDetails>
          <FormRenderer.DesktopRow>
            <div
              className={`${flexClass} ${justifyClassName} dark:bg-jp-gray-lightgray_background dark:border-jp-gray-no_data_border`}>
              {detailsFields
              ->Array.mapWithIndex((colType, i) => {
                if !(excludeColKeys->Array.includes(colType)) {
                  <div className=widthClass key={Int.toString(i)}>
                    <DisplayKeyValueParams
                      heading={getHeading(colType)}
                      value={getCell(data, colType)}
                      customMoneyStyle="!text-fs-13"
                      labelMargin="!py-0 mt-2"
                      customDateStyle="!font-fira-code"
                      showTitle
                    />
                    <div />
                  </div>
                } else {
                  React.null
                }
              })
              ->React.array}
              {switch chargeBackField {
              | Some(field) =>
                <div className="flex flex-col py-4">
                  <div
                    className="text-fs-11 leading-3 text-jp-gray-900 text-opacity-50 dark:text-jp-gray-text_darktheme dark:text-opacity-50">
                    {React.string("Chargeback Amount")}
                  </div>
                  <div
                    className="text-fs-13 font-semibold text-left dark:text-white text-jp-gray-900 break-all">
                    <Table.TableCell
                      cell=field
                      textAlign=Table.Left
                      fontBold=true
                      customDateStyle="!font-fira-code"
                      customMoneyStyle="!text-fs-13"
                      labelMargin="!py-0 mt-2 h-6"
                    />
                  </div>
                </div>

              | None => React.null
              }}
            </div>
          </FormRenderer.DesktopRow>
        </UIUtils.RenderIf>
        {switch children {
        | Some(ele) => ele
        | None => React.null
        }}
      </OrderUtils.Section>
    } else {
      <div
        className="flex flex-col w-full pt-4 gap-4 bg-white rounded-md dark:bg-jp-gray-lightgray_background">
        {detailsFields
        ->Array.map(item => {
          <div className="flex justify-between">
            <div className="text-jp-gray-900 dark:text-white opacity-50 font-medium">
              {getHeading(item).title->React.string}
            </div>
            <div className="font-semibold break-all">
              <Table.TableCell cell={getCell(data, item)} />
            </div>
          </div>
        })
        ->React.array}
      </div>
    }
  }
}

module AttemptsSection = {
  open PayoutsEntity
  @react.component
  let make = (~data: payoutAttempts) => {
    let widthClass = "w-1/3"
    <div className="flex flex-row flex-wrap">
      <div className="w-full p-2">
        <Details
          heading=String("Attempt Details")
          data
          detailsFields=attemptsColumns
          getHeading=getAttemptHeading
          getCell=getAttemptCell
          widthClass
        />
      </div>
    </div>
  }
}

module Attempts = {
  open PayoutsEntity
  open LogicUtils
  @react.component
  let make = (~data) => {
    let payoutObj = data->getDictFromJsonObject->itemToObjMapper
    let attemptsData = payoutObj.attempts
    let expand = -1
    let (expandedRowIndexArray, setExpandedRowIndexArray) = React.useState(_ => [-1])

    React.useEffect1(() => {
      if expand != -1 {
        setExpandedRowIndexArray(_ => [expand])
      }
      None
    }, [expand])

    let onExpandClick = idx => {
      setExpandedRowIndexArray(_ => {
        [idx]
      })
    }

    let collapseClick = idx => {
      let indexOfRemovalItem = expandedRowIndexArray->Array.findIndex(item => item === idx)
      setExpandedRowIndexArray(_ => {
        let array = expandedRowIndexArray->Array.map(item => item)
        array->Array.splice(~start=indexOfRemovalItem, ~remove=1, ~insert=[])

        array
      })
    }

    let onExpandIconClick = (isCurrentRowExpanded, rowIndex) => {
      if isCurrentRowExpanded {
        collapseClick(rowIndex)
      } else {
        onExpandClick(rowIndex)
      }
    }

    let heading = attemptsColumns->Array.map(getAttemptHeading)

    let rows = attemptsData->Array.map(item => {
      attemptsColumns->Array.map(colType => getAttemptCell(item, colType))
    })

    let getRowDetails = rowIndex => {
      switch attemptsData[rowIndex] {
      | Some(data) => <AttemptsSection data />
      | None => React.null
      }
    }

    <div className="flex flex-col gap-4">
      <p className="font-bold text-fs-16 text-jp-gray-900"> {"Payout Attempts"->React.string} </p>
      <CustomExpandableTable
        title="Attempts"
        heading
        rows
        onExpandIconClick
        expandedRowIndexArray
        getRowDetails
        showSerial=true
      />
    </div>
  }
}

module PayoutInfo = {
  open PayoutsEntity
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
              <UIUtils.RenderIf
                condition={!(excludeColKeys->Array.includes(colType))} key={Int.toString(i)}>
                <div className={`flex ${widthClass} items-center`}>
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
        <UIUtils.RenderIf condition={children->Option.isSome}>
          {children->Option.getOr(React.null)}
        </UIUtils.RenderIf>
      </OrderUtils.Section>
    }
  }
  @react.component
  let make = (~dict) => {
    let payoutData = itemToObjMapper(dict)
    <>
      <div className={`font-bold text-fs-16 dark:text-white dark:text-opacity-75 mt-4 mb-4`}>
        {"Summary"->React.string}
      </div>
      <Details data=payoutData getHeading getCell detailsFields=allColumns />
    </>
  }
}

@react.component
let make = (~id) => {
  open APIUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (payoutsData, setPayoutsData) = React.useState(_ => JSON.Encode.null)

  let fetchPayoutsData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let payoutsUrl = getURL(~entityName=PAYOUTS, ~methodType=Get, ~id=Some(id), ())
      let response = await fetchDetails(payoutsUrl)
      setPayoutsData(_ => response)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }

  React.useEffect0(() => {
    fetchPayoutsData()->ignore
    None
  })
  <PageLoaderWrapper screenState>
    <div className="flex flex-col overflow-scroll">
      <div className="mb-4 flex justify-between">
        <div className="flex items-center">
          <div>
            <PageUtils.PageHeading title="Payouts" />
            <BreadCrumbNavigation
              path=[{title: "Payouts", link: "/payouts"}]
              currentPageTitle=id
              cursorStyle="cursor-pointer"
            />
          </div>
          <div />
        </div>
      </div>
      <PayoutInfo dict={payoutsData->LogicUtils.getDictFromJsonObject} />
    </div>
  </PageLoaderWrapper>
}
