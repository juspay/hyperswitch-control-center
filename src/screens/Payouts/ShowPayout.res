open PayoutsEntity
open OrderUtils
open OrderUIUtils
open LogicUtils
module AttemptsSection = {
  @react.component
  let make = (~data: payoutAttempts) => {
    let widthClass = "w-1/3"
    <div className="flex flex-row flex-wrap">
      <div className="w-full p-2">
        <OrderUtils.Details
          heading=String("Attempt Details")
          data
          detailsFields=attemptDetailsField
          getHeading=getAttemptHeading
          getCell=getAttemptCell
          widthClass
        />
      </div>
    </div>
  }
}

module Attempts = {
  @react.component
  let make = (~data) => {
    let attemptsData = data.attempts
    let expand = -1
    let (expandedRowIndexArray, setExpandedRowIndexArray) = React.useState(_ => [-1])

    React.useEffect(() => {
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
      | Some(attemptData) => <AttemptsSection data=attemptData />
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

module ShowPayoutDetails = {
  @react.component
  let make = (
    ~data,
    ~getHeading,
    ~getCell,
    ~detailsFields,
    ~justifyClassName="justify-start",
    ~widthClass="md:w-1/2 w-full",
    ~bgColor="bg-white dark:bg-jp-gray-lightgray_background",
    ~isButtonEnabled=false,
    ~border="border border-jp-gray-940 border-opacity-75 dark:border-jp-gray-960",
    ~sectionTitle=?,
  ) => {
    let statusUI = useGetStatus(data)
    <Section customCssClass={`${border} ${bgColor} rounded-md px-5 pt-5 h-full`}>
      {switch sectionTitle {
      | Some(title) =>
        <div className="font-bold text-base ml-4 mb-3 opacity-70 underline underline-offset-4">
          {title->React.string}
        </div>
      | _ => React.null
      }}
      <RenderIf condition=isButtonEnabled>
        <div className="flex items-center flex-wrap gap-3 m-3">
          <div className="flex items-start">
            <div className="md:text-5xl font-bold">
              {`${(data.amount /. 100.00)->Float.toString} ${data.currency} `->React.string}
            </div>
            <ToolTip
              description="Original amount that was authorized for the payout"
              toolTipFor={<Icon name="tooltip_info" className={`mt-1 ml-1`} />}
              toolTipPosition=Top
              tooltipWidthClass="w-fit"
            />
          </div>
          {statusUI}
        </div>
      </RenderIf>
      <FormRenderer.DesktopRow>
        <div
          className={`flex flex-wrap ${justifyClassName} lg:flex-row flex-col dark:bg-jp-gray-lightgray_background dark:border-jp-gray-no_data_border`}>
          {detailsFields
          ->Array.mapWithIndex((colType, i) => {
            <div className=widthClass key={i->Int.toString}>
              <DisplayKeyValueParams
                heading={getHeading(colType)}
                value={getCell(data, colType)}
                customMoneyStyle="!font-normal !text-sm"
                labelMargin="!py-0 mt-2"
                overiddingHeadingStyles="text-black text-sm font-medium"
                textColor="!font-normal !text-jp-gray-700"
              />
            </div>
          })
          ->React.array}
        </div>
      </FormRenderer.DesktopRow>
    </Section>
  }
}

module PayoutInfo = {
  @react.component
  let make = (~payoutData) => {
    let headingStyles = "font-bold text-lg mb-5"
    <div className="md:flex md:flex-col md:gap-5">
      <div className="md:flex md:gap-10 md:items-stretch md:mt-5 mb-10">
        <div className="md:w-1/2 w-full">
          <div className={`${headingStyles}`}> {"Summary"->React.string} </div>
          <ShowPayoutDetails
            data=payoutData
            getHeading=getHeadingForSummary
            getCell=getCellForSummary
            detailsFields=[Created, AmountReceived, PayoutId, ConnectorTransactionID, ErrorMessage]
            isButtonEnabled=true
          />
        </div>
        <div className="md:w-1/2 w-full">
          <div className={`${headingStyles}`}> {"About Payout"->React.string} </div>
          <ShowPayoutDetails
            data=payoutData
            getHeading=getHeadingForAboutPayment
            getCell=getCellForAboutPayment
            detailsFields=[
              ProfileId,
              ProfileName,
              Connector,
              ConnectorLabel,
              PayoutMethodType,
              PayoutMethod,
              CardNetwork,
            ]
          />
        </div>
      </div>
    </div>
  }
}

module CustomerDetails = {
  @react.component
  let make = (~payoutData) => {
    <div>
      <ShowPayoutDetails
        sectionTitle="Customer"
        data=payoutData
        getHeading=getHeadingForOtherDetails
        getCell=getCellForOtherDetails
        detailsFields=[CustomerId, FirstName, LastName, Email, Phone, PhoneCountryCode, Description]
        widthClass="md:w-1/4 w-full"
        border=""
      />
      <div className="border-b-2 border-border-light-grey mx-5" />
      <ShowPayoutDetails
        sectionTitle="Billing"
        data=payoutData
        getHeading=getHeadingForOtherDetails
        getCell=getCellForOtherDetails
        detailsFields=[BillingEmail, BillingPhone, BillingAddress]
        widthClass="md:w-1/4 w-full"
        border=""
      />
      <div className="border-b-2 border-border-light-grey mx-5" />
      <ShowPayoutDetails
        sectionTitle="Payout Method"
        data=payoutData
        getHeading=getHeadingForOtherDetails
        getCell=getCellForOtherDetails
        detailsFields=[FirstName, LastName, PayoutMethodEmail, PayoutMethodAddress]
        widthClass="md:w-1/4 w-full"
        border=""
      />
    </div>
  }
}

module MorePayoutDetails = {
  @react.component
  let make = (~payoutData) => {
    <div className="mb-10">
      <ShowPayoutDetails
        data=payoutData
        getHeading=getHeadingForOtherDetails
        getCell=getCellForOtherDetails
        detailsFields=[
          AutoFulfill,
          Recurring,
          EntityType,
          BusinessCountry,
          BusinessLabel,
          ReturnUrl,
          ClientSecret,
          Priority,
          ErrorCode,
          MerchantId,
        ]
        widthClass="md:w-1/4 w-full"
        border=""
      />
    </div>
  }
}

@react.component
let make = (~id, ~profileId, ~merchantId, ~orgId) => {
  open APIUtils
  let getURL = useGetURL()
  let fetchDetails = useUpdateMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (payoutData, setPayoutsData) = React.useState(_ => Dict.make()->PayoutsEntity.itemToObjMapper)
  let internalSwitch = OMPSwitchHooks.useInternalSwitch()

  let fetchPayoutsData = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let payoutsUrl = getURL(~entityName=V1(PAYOUTS), ~methodType=Post)
      let filterData = Dict.make()
      filterData->Dict.set("payout_id", id->JSON.Encode.string)
      filterData->Dict.set("limit", 1->JSON.Encode.int)
      let _ = await internalSwitch(
        ~expectedOrgId=orgId,
        ~expectedMerchantId=merchantId,
        ~expectedProfileId=profileId,
      )
      let response = await fetchDetails(payoutsUrl, filterData->JSON.Encode.object, Post)
      let payoutData =
        response
        ->getDictFromJsonObject
        ->getArrayFromDict("data", [])
        ->getValueFromArray(0, JSON.Encode.null)
        ->getDictFromJsonObject
        ->PayoutsEntity.itemToObjMapper
      setPayoutsData(_ => payoutData)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }

  React.useEffect(() => {
    fetchPayoutsData()->ignore
    None
  }, [])

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
      {<div className="flex flex-col gap-8">
        <PayoutInfo payoutData />
        <div className="overflow-scroll">
          <Attempts data=payoutData />
        </div>
        <RenderAccordian
          accordion=[
            {
              title: "Customer Details",
              renderContent: () => {
                <CustomerDetails payoutData />
              },
              renderContentOnTop: None,
            },
          ]
        />
        <RenderAccordian
          accordion=[
            {
              title: "More Payout Details",
              renderContent: () => {
                <MorePayoutDetails payoutData />
              },
              renderContentOnTop: None,
            },
          ]
        />
        <RenderIf
          condition={payoutData.payout_type === "card" &&
            payoutData.payout_method_data->Option.isSome}>
          <RenderAccordian
            accordion=[
              {
                title: "Payout Method Details",
                renderContent: () => {
                  <div className="bg-white p-2">
                    <PrettyPrintJson
                      jsonToDisplay={payoutData.payout_method_data
                      ->JSON.stringifyAny
                      ->Option.getOr("")}
                      overrideBackgroundColor="bg-white"
                    />
                  </div>
                },
                renderContentOnTop: None,
              },
            ]
          />
        </RenderIf>
        <RenderIf condition={!(payoutData.metadata->LogicUtils.isEmptyDict)}>
          <RenderAccordian
            accordion=[
              {
                title: "Payout Metadata",
                renderContent: () => {
                  <div className="bg-white p-2">
                    <PrettyPrintJson
                      jsonToDisplay={payoutData.metadata->JSON.stringifyAny->Option.getOr("")}
                      overrideBackgroundColor="bg-white"
                    />
                  </div>
                },
                renderContentOnTop: None,
              },
            ]
          />
        </RenderIf>
      </div>}
    </div>
  </PageLoaderWrapper>
}
