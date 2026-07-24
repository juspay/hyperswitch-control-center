open LogicUtils
open OrderUtils
open HSwitchOrderUtils
open PaymentInterfaceTypes
open Typography

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
    ~openVoidModal=() => (),
    ~openCaptureModal=() => (),
    ~paymentId,
    ~border="border border-jp-gray-940 border-opacity-75 dark:border-jp-gray-960",
    ~sectionTitle=?,
  ) => {
    let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
    let {version} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
    let typedPaymentStatus = paymentStatus->statusVariantMapper
    let statusUI = useGetStatus(data)

    let amountToDisplay = CurrencyUtils.convertCurrencyFromLowestDenomination(
      ~amount=data.amount,
      ~currency=data.currency,
    )

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
              {`${amountToDisplay->Float.toString} ${data.currency} `->React.string}
            </div>
            <ToolTip
              description="Original amount that was authorized for the payment"
              toolTipFor={<Icon name="tooltip_info" className={`mt-1 ml-1`} />}
              toolTipPosition=Top
            />
          </div>
          {statusUI}
          <ACLButton
            authorization={userHasAccess(~groupAccess=OperationsManage)}
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
          <RenderIf
            condition={version === V1 &&
            typedPaymentStatus === RequiresCapture &&
            !(paymentId->isTestData)}>
            <ACLButton
              authorization={userHasAccess(~groupAccess=OperationsManage)}
              text="+ Void"
              onClick={_ => {
                openVoidModal()
              }}
              buttonType={Secondary}
            />
          </RenderIf>
          <RenderIf
            condition={version === V1 &&
            typedPaymentStatus === RequiresCapture &&
            !(paymentId->isTestData)}>
            <ACLButton
              authorization={userHasAccess(~groupAccess=OperationsManage)}
              text="+ Capture"
              onClick={_ => openCaptureModal()}
              buttonType={Secondary}
            />
          </RenderIf>
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
                overridingHeadingStyles="text-black text-sm font-medium"
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
  let make = (
    ~order,
    ~openRefundModal,
    ~openVoidModal,
    ~openCaptureModal,
    ~isNonRefundConnector,
    ~paymentId,
  ) => {
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
              NetAmount,
              SurchargeAmount,
              ConnectorTransactionID,
              ErrorMessage,
            ]
            isButtonEnabled=true
            isNonRefundConnector
            paymentStatus
            openRefundModal
            openVoidModal
            openCaptureModal
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
            openVoidModal
            openCaptureModal
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
          detailsFields=OrderEntity.attemptDetailsField
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
    let {orgId, merchantId, profileId} = React.useContext(
      UserInfoProvider.defaultContext,
    ).getCommonSessionDetails()
    let widthClass = "w-1/3"
    <div className="flex flex-row flex-wrap">
      <div className="w-full p-2">
        <Details
          heading=String("Dispute Details")
          data
          detailsFields=DisputesEntity.columnsInPaymentPage
          getHeading=DisputesEntity.getHeading
          getCell={(disputes, disputesColsType) =>
            DisputesEntity.getCell(disputes, disputesColsType, merchantId, orgId, ~profileId)}
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
    let noExpandIndex = -1
    let (expandedRowIndexArray, setExpandedRowIndexArray) = React.useState(_ => [-1])
    let heading = refundColumns->Array.map(getRefundHeading)
    React.useEffect(() => {
      if noExpandIndex != -1 {
        setExpandedRowIndexArray(_ => [noExpandIndex])
      }
      None
    }, [noExpandIndex])
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

    <div className="flex flex-col gap-4">
      <p className={`${body.lg.bold} text-nd_gray-900`}> {"Refunds"->React.string} </p>
      <CustomExpandableTable
        title="Refunds"
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

module Attempts = {
  open OrderEntity
  @react.component
  let make = (~order, ~showHeading=true) => {
    let noExpandIndex = -1
    let (expandedRowIndexArray, setExpandedRowIndexArray) = React.useState(_ => [-1])

    React.useEffect(() => {
      if noExpandIndex != -1 {
        setExpandedRowIndexArray(_ => [noExpandIndex])
      }
      None
    }, [noExpandIndex])

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
      let rowValueA = a.attempt_id
      let rowValueB = b.attempt_id

      rowValueA <= rowValueB ? 1. : -1.
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
      <RenderIf condition=showHeading>
        <p className={`${body.lg.bold} text-nd_gray-900`}> {"Payment Attempts"->React.string} </p>
      </RenderIf>
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
    let {orgId, merchantId, profileId} = React.useContext(
      UserInfoProvider.defaultContext,
    ).getCommonSessionDetails()
    let noExpandIndex = -1
    let (expandedRowIndexArray, setExpandedRowIndexArray) = React.useState(_ => [-1])
    let heading = columnsInPaymentPage->Array.map(getHeading)
    React.useEffect(() => {
      if noExpandIndex != -1 {
        setExpandedRowIndexArray(_ => [noExpandIndex])
      }
      None
    }, [noExpandIndex])
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
      columnsInPaymentPage->Array.map(colType =>
        getCell(item, colType, merchantId, orgId, ~profileId)
      )
    })

    let getRowDetails = rowIndex => {
      switch disputesData[rowIndex] {
      | Some(data) => <DisputesSection data />
      | None => React.null
      }
    }

    <div className="flex flex-col gap-4">
      <p className={`${body.lg.bold} text-nd_gray-900`}> {"Disputes"->React.string} </p>
      <CustomExpandableTable
        title="Disputes"
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

module OrderActions = {
  @react.component
  let make = (
    ~orderData,
    ~refetch,
    ~showModal,
    ~setShowModal,
    ~showVoidModal,
    ~setShowVoidModal,
    ~showCaptureModal,
    ~setShowCaptureModal,
  ) => {
    let (amountAvailableToRefund, setAmountAvailableToRefund) = React.useState(_ => 0.0)
    let refundData = orderData.refunds
    let disputeData = orderData.disputes

    let conversionFactor = CurrencyUtils.getCurrencyConversionFactor(orderData.currency)
    let amountRefunded = ref(0.0)
    let requestedRefundAmount = ref(0.0)
    let disputeAmount = ref(0.0)

    let _ = refundData->Array.map(ele => {
      let refundStatus = ele.status->HSwitchOrderUtils.refundStatusVariantMapper
      if refundStatus === Pending {
        requestedRefundAmount := requestedRefundAmount.contents +. ele.amount
      } else if refundStatus === Success {
        amountRefunded := amountRefunded.contents +. ele.amount
      }
    })

    let _ = disputeData->Array.map(ele => {
      let disputeStatus = ele.dispute_status->DisputesUtils.disputeStatusVariantMapper
      if disputeStatus === DisputeLost {
        disputeAmount := disputeAmount.contents +. ele.amount->Float.fromString->Option.getOr(0.0)
      }
    })

    React.useEffect(_ => {
      let amountToBeRefunded =
        orderData.amount_captured /. conversionFactor -.
        amountRefunded.contents /. conversionFactor -.
        disputeAmount.contents /. conversionFactor -.
        requestedRefundAmount.contents /. conversionFactor
      setAmountAvailableToRefund(_ => amountToBeRefunded > 0.0 ? amountToBeRefunded : 0.0)
      None
    }, [orderData])

    <div className="flex flex-row justify-right gap-2">
      <Modal
        showModal
        setShowModal
        borderBottom=true
        childClass=""
        modalClass="w-full md:w-4/12 mx-auto mt-20"
        bgClass="bg-white dark:bg-jp-gray-darkgray_background">
        <OrderRefundForm
          order={orderData}
          setShowModal
          requestedRefundAmount
          amountRefunded
          amountAvailableToRefund
          refetch
        />
      </Modal>
      <Modal
        showModal=showVoidModal
        setShowModal=setShowVoidModal
        borderBottom=true
        childClass=""
        modalClass="w-full md:w-4/12 mx-auto mt-20"
        bgClass="bg-nd_gray-0">
        <OrderVoidForm order={orderData} setShowModal=setShowVoidModal refetch />
      </Modal>
      <Modal
        showModal=showCaptureModal
        setShowModal=setShowCaptureModal
        borderBottom=true
        childClass=""
        modalClass="w-full md:w-4/12 mx-auto mt-20"
        bgClass="bg-nd_gray-0">
        <OrderCaptureForm order={orderData} setShowModal=setShowCaptureModal refetch />
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
    let showToast = ToastAdapter.useShowToast()
    let showPopUp = PopUpState.useShowPopUp()

    let updateMerchantDecision = async (~decision) => {
      try {
        let ordersDecisionUrl = `${getURL(
            ~entityName=V1(ORDERS),
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

    let openPopUp = (~decision: OrderTypes.frmStatus) => {
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
        className={`flex flex-wrap dark:bg-jp-gray-lightgray_background dark:border-jp-gray-no_data_border lg:flex-row flex-col`}>
        {frmColumns
        ->Array.mapWithIndex((colType, i) => {
          <div className="w-1/3" key={i->Int.toString}>
            <DisplayKeyValueParams
              heading={getFrmHeading(colType)}
              value={getFrmCell(order, colType)}
              customMoneyStyle="!font-normal !text-sm"
              labelMargin="!py-0 mt-2"
              overridingHeadingStyles="text-black text-sm font-medium"
              textColor="!font-normal !text-jp-gray-700"
            />
          </div>
        })
        ->React.array}
      </div>
      <RenderIf
        condition={order.frm_merchant_decision->String.length === 0 &&
        order.frm_message.frm_status === "fraud" &&
        order.status->HSwitchOrderUtils.statusVariantMapper === Succeeded}>
        <div className="flex items-center gap-5 justify-end">
          <Button
            text="Refund"
            buttonType={Secondary}
            customTextSize="text-sm"
            onClick={_ => openPopUp(~decision=#REJECT)}
          />
          <Button
            text="Mark as true"
            buttonType={Primary}
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
        className={`flex flex-wrap dark:bg-jp-gray-lightgray_background dark:border-jp-gray-no_data_border lg:flex-row flex-col`}>
        {authenticationColumns
        ->Array.mapWithIndex((colType, i) => {
          <div className="w-1/3" key={i->Int.toString}>
            <DisplayKeyValueParams
              heading={getAuthenticationHeading(colType)}
              value={getAuthenticationCell(order, colType)}
              customMoneyStyle="!font-normal !text-sm"
              labelMargin="!py-0 mt-2"
              overridingHeadingStyles="text-black text-sm font-medium"
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
  let make = (~frmMessage: frmMessage, ~onReviewDetailsClick) => {
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
        onClick={_ => onReviewDetailsClick()}>
        {"Review details"->React.string}
      </div>
    </div>
  }
}

@react.component
let make = (~id, ~profileId, ~merchantId, ~orgId) => {
  open APIUtils
  open OrderUIUtils
  let getURL = useGetURL()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let {version} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let showToast = ToastAdapter.useShowToast()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (showModal, setShowModal) = React.useState(_ => false)
  let (showVoidModal, setShowVoidModal) = React.useState(_ => false)
  let (showCaptureModal, setShowCaptureModal) = React.useState(_ => false)
  let (orderData, setOrderData) = React.useState(_ =>
    Dict.make()->PaymentInterfaceUtils.mapDictToPaymentPayload
  )
  let frmDetailsRef = React.useRef(Nullable.null)
  let fetchDetails = useGetMethod()
  let internalSwitch = OMPSwitchHooks.useInternalSwitch()

  let fetchOrderDetails = async url => {
    open PaymentsInterface
    try {
      setScreenState(_ => Loading)
      let _ = await internalSwitch(
        ~expectedOrgId=orgId,
        ~expectedMerchantId=merchantId,
        ~expectedProfileId=profileId,
        ~version,
      )
      let res = await fetchDetails(url)
      let order = switch version {
      | V1 => mapJsonDictToCommonPaymentPayload(paymentInterfaceV1, res->getDictFromJsonObject)
      | V2 => mapJsonDictToCommonPaymentPayload(paymentInterfaceV2, res->getDictFromJsonObject)
      }
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
    let accountUrl = switch version {
    | V1 =>
      getURL(
        ~entityName=V1(ORDERS),
        ~methodType=Get,
        ~id=Some(id),
        ~queryParameters=Some("expand_attempts=true"),
      )
    | V2 =>
      getURL(
        ~entityName=V2(V2_ORDERS_LIST),
        ~methodType=Get,
        ~id=Some(id),
        ~queryParameters=Some("expand_attempts=true"),
      )
    }

    fetchOrderDetails(accountUrl)->ignore
    None
  }, [id])

  let isRefundDataAvailable = orderData.refunds->Array.length !== 0

  let isDisputeDataVisible = orderData.disputes->Array.length !== 0

  let openRefundModal = _ => {
    setShowModal(_ => true)
  }

  let openVoidModal = _ => {
    setShowVoidModal(_ => true)
  }

  let openCaptureModal = _ => {
    setShowCaptureModal(_ => true)
  }

  let showSyncButton = React.useCallback(_ => {
    let status = orderData.status->statusVariantMapper

    !(id->isTestData) &&
    status !== Succeeded &&
    status !== Failed &&
    status !== Cancelled &&
    status !== Expired &&
    status !== CancelledPostCapture &&
    status !== RequiresPaymentMethod
  }, [orderData])

  let refreshStatus = async () => {
    try {
      let getRefreshStatusUrl = switch version {
      | V1 =>
        getURL(
          ~entityName=V1(ORDERS),
          ~methodType=Get,
          ~id=Some(id),
          ~queryParameters=Some("force_sync=true&expand_attempts=true"),
        )
      | V2 =>
        getURL(
          ~entityName=V2(V2_ORDERS_LIST),
          ~methodType=Get,
          ~id=Some(id),
          ~queryParameters=Some("force_sync=true&expand_attempts=true"),
        )
      }
      let _ = await fetchOrderDetails(getRefreshStatusUrl)
      showToast(~message="Details Updated", ~toastType=ToastSuccess)
    } catch {
    | _ => ()
    }
  }

  let breadCrumbLink = RouteUtils.getPath(~path="/payments", version)
  let (selectedTabIndex, setSelectedTabIndex) = React.useState(_ => 0)

  let renderDetailsPanel = (~title, ~children) =>
    <div className="border border-nd_gray-200 rounded-lg overflow-hidden bg-nd_gray-0">
      <div className="px-5 py-4 border-b border-nd_gray-200">
        <p className={`${body.md.semibold} text-nd_gray-700`}> {title->React.string} </p>
      </div>
      <div className="px-5 py-4"> {children} </div>
    </div>

  let renderTabContent = children => <div className="mt-5"> {children} </div>

  let renderEventsAndLogs = () =>
    renderTabContent(
      renderDetailsPanel(
        ~title="Events and logs",
        ~children=<LogsWrapper wrapperFor={#PAYMENT}>
          <PaymentLogs paymentId={id} createdAt={orderData.created_at} />
        </LogsWrapper>,
      ),
    )

  let detailAccordionItem = (title, renderContent): AccordionAdapter.accordion => {
    title,
    renderContent,
    renderContentOnTop: None,
  }

  let renderCustomerDetails = () => {
    let accordionItems = [
      detailAccordionItem("Customer", (~currentAccordionState as _, ~closeAccordionFn as _) =>
        <ShowOrderDetails
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
      ),
      detailAccordionItem("Shipping", (~currentAccordionState as _, ~closeAccordionFn as _) =>
        <ShowOrderDetails
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
      ),
      detailAccordionItem("Billing", (~currentAccordionState as _, ~closeAccordionFn as _) =>
        <ShowOrderDetails
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
      ),
      detailAccordionItem("Payment Method", (~currentAccordionState as _, ~closeAccordionFn as _) =>
        <ShowOrderDetails
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
      ),
      detailAccordionItem("Fraud & Risk Management", (
        ~currentAccordionState as _,
        ~closeAccordionFn as _,
      ) =>
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
      ),
    ]

    renderTabContent(
      <AccordionAdapter
        accordion=accordionItems
        accordionTopContainerCss="rounded-lg"
        accordionBottomContainerCss="p-4"
        contentExpandCss="px-4 py-3"
        titleStyle={`${body.md.semibold} text-nd_gray-700`}
        accordionHeaderTextClass="flex-1"
        gapClass="space-y-5"
        arrowPosition=Left
        initialExpandedArray=[0, 1, 2]
      />,
    )
  }

  let renderPaymentMethodDetails = () =>
    renderTabContent(
      <div className="flex flex-col gap-5">
        {renderDetailsPanel(
          ~title="Payment Details",
          ~children=<ShowOrderDetails
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
              ExtendedAuthApplied,
              ExtendedAuthLastAppliedAt,
              RequestExtendedAuth,
              HyperswitchErrorDescription,
            ]
            isNonRefundConnector={isNonRefundConnector(orderData.connector)}
            paymentStatus={orderData.status}
            openRefundModal={() => ()}
            widthClass="md:w-1/3 w-full"
            paymentId={orderData.payment_id}
            border=""
          />,
        )}
        <RenderIf
          condition={orderData.payment_method === "card" &&
            orderData.payment_method_data->Option.isSome}>
          <RenderAccordion
            accordion={[
              {
                title: "Payment Method Details",
                renderContent: (~currentAccordionState as _, ~closeAccordionFn as _) => {
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
          <RenderAccordion
            accordion={[
              {
                title: "External Authentication Details",
                renderContent: (~currentAccordionState as _, ~closeAccordionFn as _) => {
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
          <RenderAccordion
            accordion={[
              {
                title: "Payment Metadata",
                renderContent: (~currentAccordionState as _, ~closeAccordionFn as _) => {
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
      </div>,
    )

  let renderFrmDetails = () =>
    renderTabContent(
      <div className="overflow-scroll" ref={frmDetailsRef->ReactDOM.Ref.domRef}>
        {renderDetailsPanel(
          ~title="FRM Details",
          ~children=<FraudRiskBannerDetails order={orderData} refetch={refreshStatus} />,
        )}
      </div>,
    )

  let paymentDetailsTabs: array<Tabs.tab> = []

  if (
    version == V1 &&
    featureFlagDetails.auditTrail &&
    userHasAccess(~groupAccess=AnalyticsView) === Access
  ) {
    paymentDetailsTabs->Array.push({
      title: "Event and Logs",
      renderContent: renderEventsAndLogs,
    })
  }

  paymentDetailsTabs->Array.push({
    title: "Payment Attempts",
    renderContent: () =>
      <div className="mt-5 overflow-scroll">
        <Attempts order={orderData} showHeading=false />
      </div>,
  })

  if isRefundDataAvailable {
    paymentDetailsTabs->Array.push({
      title: "Refunds",
      renderContent: () =>
        <div className="mt-5 overflow-scroll">
          <Refunds refundData={orderData.refunds} />
        </div>,
    })
  }

  if isDisputeDataVisible {
    paymentDetailsTabs->Array.push({
      title: "Disputes",
      renderContent: () =>
        <div className="mt-5 overflow-scroll">
          <Disputes disputesData={orderData.disputes} />
        </div>,
    })
  }

  paymentDetailsTabs->Array.push({
    title: "Customer Details",
    renderContent: renderCustomerDetails,
  })

  paymentDetailsTabs->Array.push({
    title: "Payment Method Details",
    renderContent: renderPaymentMethodDetails,
  })

  paymentDetailsTabs->Array.push({
    title: "FRM Details",
    renderContent: renderFrmDetails,
  })

  let selectTabByTitle = title => {
    let tabIndex = paymentDetailsTabs->Array.findIndex(tab => tab.title === title)
    tabIndex >= 0 ? setSelectedTabIndex(_ => tabIndex) : ()
  }

  <div className="flex flex-col overflow-scroll gap-8">
    <div className="flex justify-between w-full">
      <div className="flex items-end justify-between w-full">
        <div className="w-full">
          <PageUtils.PageHeading title="Payments" />
          <BreadCrumbNavigation
            path=[{title: "Payments", link: breadCrumbLink}] currentPageTitle=id
          />
        </div>
        <RenderIf condition={showSyncButton()}>
          <ACLButton
            authorization={userHasAccess(~groupAccess=OperationsView)}
            text="Sync"
            leftIcon={Button.CustomIcon(<Icon name="sync" className="text-nd_gray-0" />)}
            customButtonStyle="mr-1"
            buttonType={Primary}
            onClick={_ => refreshStatus()->ignore}
          />
        </RenderIf>
        <div />
      </div>
      <OrderActions
        orderData={orderData}
        refetch={refreshStatus}
        showModal
        setShowModal
        showVoidModal
        setShowVoidModal
        showCaptureModal
        setShowCaptureModal
      />
    </div>
    <RenderIf condition={orderData.frm_message.frm_status === "fraud"}>
      <FraudRiskBanner
        frmMessage={orderData.frm_message}
        onReviewDetailsClick={() => selectTabByTitle("FRM Details")}
      />
    </RenderIf>
    <RenderIf condition={orderData.status->statusVariantMapper === Review}>
      <ReviewStatusBanner order={orderData} refetch={refreshStatus} />
    </RenderIf>
    <PageLoaderWrapper
      screenState
      customUI={<NoDataFound
        message="Payment does not exist in our records" renderType=NotFound
      />}>
      <div className="flex flex-col gap-8">
        <OrderInfo
          paymentId=id
          order={orderData}
          openRefundModal
          openVoidModal
          openCaptureModal
          isNonRefundConnector={isNonRefundConnector(orderData.connector)}
        />
        <Tabs
          tabs=paymentDetailsTabs
          initialIndex=selectedTabIndex
          onTitleClick={index => setSelectedTabIndex(_ => index)}
          variant=TabsBinding.Underline
          size=TabsBinding.Md
        />
      </div>
    </PageLoaderWrapper>
  </div>
}
