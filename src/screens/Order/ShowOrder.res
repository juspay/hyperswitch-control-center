open LogicUtils
open OrderUtils
open HSwitchOrderUtils
open OrderTypes

type scrollIntoViewParams = {behavior: string, block: string, inline: string}
@send external scrollIntoView: (Dom.element, scrollIntoViewParams) => unit = "scrollIntoView"
module ShowOrderDetails = {
  open OrderEntity
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
    ~isNonRefundConnector,
    ~paymentStatus,
    ~openRefundModal,
    ~paymentId,
    ~border="border border-jp-gray-940 border-opacity-75 dark:border-jp-gray-960",
    ~sectionTitle=?,
  ) => {
    let userPermissionJson = Recoil.useRecoilValueFromAtom(HyperswitchAtom.userPermissionAtom)
    let typedPaymentStatus = paymentStatus->statusVariantMapper
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
              description="Original amount that was authorized for the payment"
              toolTipFor={<Icon name="tooltip_info" className={`mt-1 ml-1`} />}
              toolTipPosition=Top
              tooltipWidthClass="w-fit"
            />
          </div>
          {statusUI}
          <ACLButton
            access={userPermissionJson.operationsManage}
            text="+ Refund"
            onClick={_ => {
              openRefundModal()
            }}
            buttonType={Secondary}
            buttonState={!isNonRefundConnector &&
            (typedPaymentStatus === Succeeded || typedPaymentStatus === PartiallyCaptured) &&
            !(paymentId->isTestData)
              ? Normal
              : Disabled}
          />
        </div>
      </RenderIf>
      <FormRenderer.DesktopRow>
        <div
          className={`flex flex-wrap ${justifyClassName} dark:bg-jp-gray-lightgray_background dark:border-jp-gray-no_data_border`}>
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

module OrderInfo = {
  open OrderEntity
  @react.component
  let make = (~order, ~openRefundModal, ~isNonRefundConnector, ~paymentId) => {
    let paymentStatus = order.status
    let headingStyles = "font-bold text-lg mb-5"
    <div className="md:flex md:flex-col md:gap-5">
      <div className="md:flex md:gap-10 md:items-stretch md:mt-5 mb-10">
        <div className="md:w-1/2 w-full">
          <div className={`${headingStyles}`}> {"Summary"->React.string} </div>
          <ShowOrderDetails
            data=order
            getHeading=getHeadingForSummary
            getCell=getCellForSummary
            detailsFields=[
              Created,
              LastUpdated,
              AmountReceived,
              PaymentId,
              ConnectorTransactionID,
              ErrorMessage,
            ]
            isButtonEnabled=true
            isNonRefundConnector
            paymentStatus
            openRefundModal
            paymentId
          />
        </div>
        <div className="md:w-1/2 w-full">
          <div className={`${headingStyles}`}> {"About Payment"->React.string} </div>
          <ShowOrderDetails
            data=order
            getHeading=getHeadingForAboutPayment
            getCell=getCellForAboutPayment
            detailsFields=[
              ProfileId,
              ProfileName,
              Connector,
              ConnectorLabel,
              PaymentMethodType,
              PaymentMethod,
              AuthenticationType,
              CardNetwork,
            ]
            isNonRefundConnector
            paymentStatus
            openRefundModal
            paymentId
          />
        </div>
      </div>
    </div>
  }
}

module RefundSection = {
  open OrderEntity
  @react.component
  let make = (~data) => {
    let widthClass = "w-1/3"
    <div className="flex flex-row flex-wrap">
      <div className="w-full p-2">
        <Details
          heading=String("Refund Details")
          data
          detailsFields=refundDetailsFields
          getHeading=getRefundHeading
          getCell=getRefundCell
          widthClass
        />
      </div>
    </div>
  }
}

module AttemptsSection = {
  open OrderEntity
  @react.component
  let make = (~data: attempts) => {
    let widthClass = "w-1/3"
    <div className="flex flex-row flex-wrap">
      <div className="w-full p-2">
        <Details
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

module DisputesSection = {
  @react.component
  let make = (~data: DisputeTypes.disputes) => {
    let widthClass = "w-4/12"
    <div className="flex flex-row flex-wrap">
      <div className="w-1/2 p-2">
        <Details
          heading=String("Dispute Details")
          data
          detailsFields=DisputesEntity.columnsInPaymentPage
          getHeading=DisputesEntity.getHeading
          getCell=DisputesEntity.getCell
          widthClass
        />
      </div>
    </div>
  }
}

module Refunds = {
  open OrderEntity
  @react.component
  let make = (~refundData) => {
    let expand = -1
    let (expandedRowIndexArray, setExpandedRowIndexArray) = React.useState(_ => [-1])
    let heading = refundColumns->Array.map(getRefundHeading)
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

    let rows = refundData->Array.map(item => {
      refundColumns->Array.map(colType => getRefundCell(item, colType))
    })

    let getRowDetails = rowIndex => {
      switch refundData[rowIndex] {
      | Some(data) => <RefundSection data />
      | None => React.null
      }
    }

    <CustomExpandableTable
      title="Refunds"
      heading
      rows
      onExpandIconClick
      expandedRowIndexArray
      getRowDetails
      showSerial=true
    />
  }
}

module Attempts = {
  open OrderEntity
  @react.component
  let make = (~order) => {
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

    let attemptsData = order.attempts->Array.toSorted((a, b) => {
      let rowValue_a = a.attempt_id
      let rowValue_b = b.attempt_id

      rowValue_a <= rowValue_b ? 1. : -1.
    })

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
      <p className="font-bold text-fs-16 text-jp-gray-900"> {"Payment Attempts"->React.string} </p>
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
module Disputes = {
  open DisputesEntity
  @react.component
  let make = (~disputesData) => {
    let expand = -1
    let (expandedRowIndexArray, setExpandedRowIndexArray) = React.useState(_ => [-1])
    let heading = columnsInPaymentPage->Array.map(getHeading)
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

    let rows = disputesData->Array.map(item => {
      columnsInPaymentPage->Array.map(colType => getCell(item, colType))
    })

    let getRowDetails = rowIndex => {
      switch disputesData[rowIndex] {
      | Some(data) => <DisputesSection data />
      | None => React.null
      }
    }

    <CustomExpandableTable
      title="Disputes"
      heading
      rows
      onExpandIconClick
      expandedRowIndexArray
      getRowDetails
      showSerial=true
    />
  }
}

module OrderActions = {
  @react.component
  let make = (~orderData, ~refetch, ~showModal, ~setShowModal) => {
    let (amoutAvailableToRefund, setAmoutAvailableToRefund) = React.useState(_ => 0.0)
    let refundData = orderData.refunds

    let amountRefunded = ref(0.0)
    let requestedRefundAmount = ref(0.0)
    let _ = refundData->Array.map(ele => {
      if ele.status === "pending" {
        requestedRefundAmount := requestedRefundAmount.contents +. ele.amount
      } else if ele.status === "succeeded" {
        amountRefunded := amountRefunded.contents +. ele.amount
      }
    })
    React.useEffect(_ => {
      setAmoutAvailableToRefund(_ =>
        orderData.amount /. 100.0 -.
        amountRefunded.contents /. 100.0 -.
        requestedRefundAmount.contents /. 100.0
      )

      None
    }, [orderData])

    <div className="flex flex-row justify-right gap-2">
      <Modal
        showModal
        setShowModal
        borderBottom=true
        childClass=""
        modalClass="w-fit absolute top-0 lg:top-0 md:top-1/3 left-0 lg:left-1/3 md:left-1/3 md:w-4/12 mt-10"
        bgClass="bg-white dark:bg-jp-gray-darkgray_background">
        <OrderRefundForm
          order={orderData}
          setShowModal
          requestedRefundAmount
          amountRefunded
          amoutAvailableToRefund
          refetch
        />
      </Modal>
    </div>
  }
}

module FraudRiskBannerDetails = {
  open OrderEntity
  open APIUtils
  @react.component
  let make = (~order: order, ~refetch) => {
    let getURL = useGetURL()
    let updateDetails = useUpdateMethod()
    let showToast = ToastState.useShowToast()
    let showPopUp = PopUpState.useShowPopUp()

    let updateMerchantDecision = async (~decision) => {
      try {
        let ordersDecisionUrl = `${getURL(
            ~entityName=ORDERS,
            ~methodType=Get,
            ~id=Some(order.payment_id),
          )}/${decision->String.toLowerCase}`

        let _ = await updateDetails(ordersDecisionUrl, Dict.make()->JSON.Encode.object, Post)
        showToast(~message="Details Updated", ~toastType=ToastSuccess)
        refetch()->ignore
      } catch {
      | _ => ()
      }
    }

    let openPopUp = (~decision: frmStatus) => {
      showPopUp({
        popUpType: (Warning, WithIcon),
        heading: `Confirm Action?`,
        description: React.string(
          decision === #APPROVE
            ? "This transaction was deemed fraudulent, to confirm that this is a legitimate transaction and submit it for review in their feedback loop, kindly confirm."
            : "Please confirm if you will like to refund the payment.",
        ),
        handleConfirm: {
          text: "Confirm",
          onClick: _ =>
            updateMerchantDecision(~decision=(decision :> string)->String.toLowerCase)->ignore,
        },
        handleCancel: {text: `Cancel`},
      })
    }

    <div
      className="w-full bg-white dark:bg-jp-gray-lightgray_background rounded-md px-4 pb-5 h-full">
      <div
        className={`flex flex-wrap dark:bg-jp-gray-lightgray_background dark:border-jp-gray-no_data_border`}>
        {frmColumns
        ->Array.mapWithIndex((colType, i) => {
          <div className="w-1/3" key={i->Int.toString}>
            <DisplayKeyValueParams
              heading={getFrmHeading(colType)}
              value={getFrmCell(order, colType)}
              customMoneyStyle="!font-normal !text-sm"
              labelMargin="!py-0 mt-2"
              overiddingHeadingStyles="text-black text-sm font-medium"
              textColor="!font-normal !text-jp-gray-700"
            />
          </div>
        })
        ->React.array}
      </div>
      <RenderIf
        condition={order.merchant_decision->String.length === 0 &&
        order.frm_message.frm_status === "fraud" &&
        order.status->HSwitchOrderUtils.statusVariantMapper === Succeeded}>
        <div className="flex items-center gap-5 justify-end">
          <Button
            text="Refund"
            buttonType={Secondary}
            customButtonStyle="!p-2"
            customTextSize="text-sm"
            onClick={_ => openPopUp(~decision=#REJECT)}
          />
          <Button
            text="Mark as true"
            buttonType={Primary}
            customButtonStyle="!p-2"
            customTextSize="text-sm"
            onClick={_ => openPopUp(~decision=#APPROVE)}
          />
        </div>
      </RenderIf>
    </div>
  }
}

module AuthenticationDetails = {
  open OrderEntity
  @react.component
  let make = (~order: order) => {
    <div
      className="w-full bg-white dark:bg-jp-gray-lightgray_background rounded-md px-4 pb-5 h-full">
      <div
        className={`flex flex-wrap dark:bg-jp-gray-lightgray_background dark:border-jp-gray-no_data_border`}>
        {authenticationColumns
        ->Array.mapWithIndex((colType, i) => {
          <div className="w-1/3" key={i->Int.toString}>
            <DisplayKeyValueParams
              heading={getAuthenticationHeading(colType)}
              value={getAuthenticationCell(order, colType)}
              customMoneyStyle="!font-normal !text-sm"
              labelMargin="!py-0 mt-2"
              overiddingHeadingStyles="text-black text-sm font-medium"
              textColor="!font-normal !text-jp-gray-700"
            />
          </div>
        })
        ->React.array}
      </div>
    </div>
  }
}

module FraudRiskBanner = {
  @react.component
  let make = (~frmMessage: frmMessage, ~refElement: React.ref<Js.nullable<Dom.element>>) => {
    let {globalUIConfig: {font: {textColor}}} = React.useContext(ThemeProvider.themeContext)
    <div
      className="flex justify-between items-center w-full  p-4 rounded-md bg-white border border-[#C04141]/50 ">
      <div className="flex gap-2">
        <img alt="image" src={`/icons/redFlag.svg`} />
        <p className="text-lightgray_background font-medium text-fs-16">
          {`This payment is marked fraudulent by ${frmMessage.frm_name}.`->React.string}
        </p>
        <GatewayIcon
          gateway={frmMessage.frm_name->String.toUpperCase} className="w-6 h-6 rounded-full"
        />
      </div>
      <div
        className={`${textColor.primaryNormal} font-semibold text-fs-16 cursor-pointer`}
        onClick={_ => {
          refElement.current
          ->Nullable.toOption
          ->Option.forEach(input =>
            input->(scrollIntoView(_, {behavior: "smooth", block: "start", inline: "nearest"}))
          )
        }}>
        {"Review details"->React.string}
      </div>
    </div>
  }
}

@react.component
let make = (~id, ~profileId) => {
  open APIUtils
  open OrderUIUtils
  let url = RescriptReactRouter.useUrl()
  let getURL = useGetURL()
  let userPermissionJson = Recoil.useRecoilValueFromAtom(HyperswitchAtom.userPermissionAtom)
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let showToast = ToastState.useShowToast()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (showModal, setShowModal) = React.useState(_ => false)
  let (orderData, setOrderData) = React.useState(_ => Dict.make()->OrderEntity.itemToObjMapper)

  let frmDetailsRef = React.useRef(Nullable.null)
  let fetchDetails = useGetMethod()
  let internalSwitch = OMPSwitchHooks.useInternalSwitch()
  let fetchOrderDetails = async url => {
    try {
      setScreenState(_ => Loading)
      let _ = await internalSwitch(~expectedProfileId=Some(profileId))
      let res = await fetchDetails(url)
      let order = OrderEntity.itemToObjMapper(res->getDictFromJsonObject)
      setOrderData(_ => order)
      setScreenState(_ => Success)
    } catch {
    | Exn.Error(e) =>
      switch Exn.message(e) {
      | Some(message) =>
        if message->String.includes("HE_02") {
          setScreenState(_ => Custom)
        } else {
          showToast(~message="Failed to Fetch!", ~toastType=ToastState.ToastError)
          setScreenState(_ => Error("Failed to Fetch!"))
        }

      | None => setScreenState(_ => Error("Failed to Fetch!"))
      }
    }
  }

  React.useEffect(() => {
    let accountUrl = getURL(
      ~entityName=ORDERS,
      ~methodType=Get,
      ~id=Some(id),
      ~queryParamerters=Some("expand_attempts=true"),
    )
    fetchOrderDetails(accountUrl)->ignore
    None
  }, [url])

  let isRefundDataAvailable = orderData.refunds->Array.length !== 0

  let isDisputeDataVisible = orderData.disputes->Array.length !== 0

  let openRefundModal = _ => {
    setShowModal(_ => true)
  }

  let showSyncButton = React.useCallback(_ => {
    let status = orderData.status->statusVariantMapper

    !(id->isTestData) && status !== Succeeded && status !== Failed
  }, [orderData])

  let refreshStatus = async () => {
    try {
      let getRefreshStatusUrl = getURL(
        ~entityName=ORDERS,
        ~methodType=Get,
        ~id=Some(id),
        ~queryParamerters=Some("force_sync=true&expand_attempts=true"),
      )
      let _ = await fetchOrderDetails(getRefreshStatusUrl)
      showToast(~message="Details Updated", ~toastType=ToastSuccess)
    } catch {
    | _ => ()
    }
  }

  <div className="flex flex-col overflow-scroll gap-8">
    <div className="flex justify-between w-full">
      <div className="flex items-end justify-between w-full">
        <div className="w-full">
          <PageUtils.PageHeading title="Payments" />
          <BreadCrumbNavigation
            path=[{title: "Payments", link: "/payments"}]
            currentPageTitle=id
            cursorStyle="cursor-pointer"
          />
        </div>
        <RenderIf condition={showSyncButton()}>
          <ACLButton
            access={userPermissionJson.operationsView}
            text="Sync"
            leftIcon={Button.CustomIcon(
              <Icon
                name="sync" className="jp-gray-900 fill-opacity-50 dark:jp-gray-text_darktheme"
              />,
            )}
            customButtonStyle="!w-fit !px-4"
            buttonType={Primary}
            onClick={_ => refreshStatus()->ignore}
          />
        </RenderIf>
        <div />
      </div>
      <OrderActions orderData={orderData} refetch={refreshStatus} showModal setShowModal />
    </div>
    <RenderIf condition={orderData.frm_message.frm_status === "fraud"}>
      <FraudRiskBanner frmMessage={orderData.frm_message} refElement=frmDetailsRef />
    </RenderIf>
    <PageLoaderWrapper
      screenState
      customUI={<NoDataFound
        message="Payment does not exists in out record" renderType=NotFound
      />}>
      <div className="flex flex-col gap-8">
        <OrderInfo
          paymentId=id
          order={orderData}
          openRefundModal
          isNonRefundConnector={isNonRefundConnector(orderData.connector)}
        />
        <RenderIf condition={featureFlagDetails.auditTrail}>
          <RenderAccordian
            initialExpandedArray=[0]
            accordion={[
              {
                title: "Events and logs",
                renderContent: () => {
                  <LogsWrapper wrapperFor={#PAYMENT}>
                    <PaymentLogs paymentId={id} createdAt={orderData.created} />
                  </LogsWrapper>
                },
                renderContentOnTop: None,
              },
            ]}
          />
        </RenderIf>
        <div className="overflow-scroll">
          <Attempts order={orderData} />
        </div>
        <RenderIf condition={isRefundDataAvailable}>
          <div className="overflow-scroll">
            <RenderAccordian
              initialExpandedArray={isRefundDataAvailable ? [0] : []}
              accordion={[
                {
                  title: "Refunds",
                  renderContent: () => {
                    <Refunds refundData={orderData.refunds} />
                  },
                  renderContentOnTop: None,
                },
              ]}
            />
          </div>
        </RenderIf>
        <RenderIf condition={isDisputeDataVisible}>
          <div className="overflow-scroll">
            <RenderAccordian
              initialExpandedArray={isDisputeDataVisible ? [0] : []}
              accordion={[
                {
                  title: "Disputes",
                  renderContent: () => {
                    <Disputes disputesData={orderData.disputes} />
                  },
                  renderContentOnTop: None,
                },
              ]}
            />
          </div>
        </RenderIf>
        <RenderAccordian
          accordion={[
            {
              title: "Customer Details",
              renderContent: () => {
                <div>
                  <ShowOrderDetails
                    sectionTitle="Customer"
                    data=orderData
                    getHeading=OrderEntity.getHeadingForOtherDetails
                    getCell=OrderEntity.getCellForOtherDetails
                    detailsFields=[FirstName, LastName, Phone, Email, CustomerId, Description]
                    isNonRefundConnector={isNonRefundConnector(orderData.connector)}
                    paymentStatus={orderData.status}
                    openRefundModal={() => ()}
                    widthClass="md:w-1/4 w-full"
                    paymentId={orderData.payment_id}
                    border=""
                  />
                  <div className="border-b-2 border-border-light-grey mx-5" />
                  <ShowOrderDetails
                    sectionTitle="Billing"
                    data=orderData
                    getHeading=OrderEntity.getHeadingForOtherDetails
                    getCell=OrderEntity.getCellForOtherDetails
                    detailsFields=[BillingEmail, BillingPhone, BillingAddress]
                    isNonRefundConnector={isNonRefundConnector(orderData.connector)}
                    paymentStatus={orderData.status}
                    openRefundModal={() => ()}
                    widthClass="md:w-1/4 w-full"
                    paymentId={orderData.payment_id}
                    border=""
                  />
                  <div className="border-b-2 border-border-light-grey mx-5" />
                  <ShowOrderDetails
                    sectionTitle="Shipping"
                    data=orderData
                    getHeading=OrderEntity.getHeadingForOtherDetails
                    getCell=OrderEntity.getCellForOtherDetails
                    detailsFields=[ShippingEmail, ShippingPhone, ShippingAddress]
                    isNonRefundConnector={isNonRefundConnector(orderData.connector)}
                    paymentStatus={orderData.status}
                    openRefundModal={() => ()}
                    widthClass="md:w-1/4 w-full"
                    paymentId={orderData.payment_id}
                    border=""
                  />
                  <div className="border-b-2 border-border-light-grey mx-5" />
                  <ShowOrderDetails
                    sectionTitle="Payment Method"
                    data=orderData
                    getHeading=OrderEntity.getHeadingForOtherDetails
                    getCell=OrderEntity.getCellForOtherDetails
                    detailsFields=[
                      PMBillingFirstName,
                      PMBillingLastName,
                      PMBillingEmail,
                      PMBillingPhone,
                      PMBillingAddress,
                    ]
                    isNonRefundConnector={isNonRefundConnector(orderData.connector)}
                    paymentStatus={orderData.status}
                    openRefundModal={() => ()}
                    widthClass="md:w-1/4 w-full"
                    paymentId={orderData.payment_id}
                    border=""
                  />
                  <div className="border-b-2 border-border-light-grey mx-5" />
                  <ShowOrderDetails
                    sectionTitle="Fraud & risk management (FRM)"
                    data=orderData
                    getHeading=OrderEntity.getHeadingForOtherDetails
                    getCell=OrderEntity.getCellForOtherDetails
                    detailsFields=[FRMName, FRMTransactionType, FRMStatus]
                    isNonRefundConnector={isNonRefundConnector(orderData.connector)}
                    paymentStatus={orderData.status}
                    openRefundModal={() => ()}
                    widthClass="md:w-1/4 w-full"
                    paymentId={orderData.payment_id}
                    border=""
                  />
                </div>
              },
              renderContentOnTop: None,
            },
          ]}
        />
        <RenderAccordian
          accordion={[
            {
              title: "More Payment Details",
              renderContent: () => {
                <div className="mb-10">
                  <ShowOrderDetails
                    data=orderData
                    getHeading=OrderEntity.getHeadingForOtherDetails
                    getCell=OrderEntity.getCellForOtherDetails
                    detailsFields=[
                      AmountCapturable,
                      ErrorCode,
                      MandateData,
                      MerchantId,
                      ReturnUrl,
                      OffSession,
                      CaptureOn,
                      NextAction,
                      SetupFutureUsage,
                      CancellationReason,
                      StatementDescriptorName,
                      StatementDescriptorSuffix,
                      PaymentExperience,
                      MerchantOrderReferenceId,
                    ]
                    isNonRefundConnector={isNonRefundConnector(orderData.connector)}
                    paymentStatus={orderData.status}
                    openRefundModal={() => ()}
                    widthClass="md:w-1/4 w-full"
                    paymentId={orderData.payment_id}
                    border=""
                  />
                </div>
              },
              renderContentOnTop: None,
            },
          ]}
        />
        <RenderIf
          condition={orderData.payment_method === "card" &&
            orderData.payment_method_data->Option.isSome}>
          <RenderAccordian
            accordion={[
              {
                title: "Payment Method Details",
                renderContent: () => {
                  <div className="bg-white p-2">
                    <PrettyPrintJson
                      jsonToDisplay={orderData.payment_method_data
                      ->JSON.stringifyAny
                      ->Option.getOr("")}
                      overrideBackgroundColor="bg-white"
                    />
                  </div>
                },
                renderContentOnTop: None,
              },
            ]}
          />
        </RenderIf>
        <RenderIf condition={orderData.external_authentication_details->Option.isSome}>
          <RenderAccordian
            accordion={[
              {
                title: "External Authentication Details",
                renderContent: () => {
                  <div className="bg-white p-2">
                    <AuthenticationDetails order={orderData} />
                  </div>
                },
                renderContentOnTop: None,
              },
            ]}
          />
        </RenderIf>
        <RenderIf condition={!(orderData.metadata->LogicUtils.isEmptyDict)}>
          <RenderAccordian
            accordion={[
              {
                title: "Payment Metadata",
                renderContent: () => {
                  <div className="bg-white p-2">
                    <PrettyPrintJson
                      jsonToDisplay={orderData.metadata->JSON.stringifyAny->Option.getOr("")}
                      overrideBackgroundColor="bg-white"
                    />
                  </div>
                },
                renderContentOnTop: None,
              },
            ]}
          />
        </RenderIf>
        <div className="overflow-scroll">
          <RenderAccordian
            accordion={[
              {
                title: "FRM Details",
                renderContent: () => {
                  <div ref={frmDetailsRef->ReactDOM.Ref.domRef}>
                    <FraudRiskBannerDetails order={orderData} refetch={refreshStatus} />
                  </div>
                },
                renderContentOnTop: None,
              },
            ]}
          />
        </div>
      </div>
    </PageLoaderWrapper>
  </div>
}
