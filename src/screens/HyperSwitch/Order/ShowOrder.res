open LogicUtils
open OrderUtils
open HSwitchOrderUtils
open OrderTypes

type scrollIntoViewParams = {behavior: string, block: string, inline: string}
@send external scrollIntoView: (Dom.element, scrollIntoViewParams) => unit = "scrollIntoView"

module OrderInfo = {
  open OrderEntity
  module Details = {
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
      ~connectorList=?,
      ~border="border border-jp-gray-940 border-opacity-75 dark:border-jp-gray-960",
    ) => {
      let typedPaymentStatus = paymentStatus->statusVariantMapper
      <Section customCssClass={`${border} ${bgColor} rounded-md p-5 h-full`}>
        <UIUtils.RenderIf condition=isButtonEnabled>
          <div className="flex items-center flex-wrap gap-3 m-3">
            <div className="flex items-start">
              <div className="md:text-5xl font-bold">
                {`${(data.amount /. 100.00)->Belt.Float.toString} ${data.currency} `->React.string}
              </div>
              <ToolTip
                description="Original amount that was authorized for the payment"
                toolTipFor={<Icon name="tooltip_info" className={`mt-1 ml-1`} />}
                toolTipPosition=Top
                tooltipWidthClass="w-fit"
              />
            </div>
            {getStatus(data)}
            <Button
              text="+ Refund"
              onClick={_ => {
                openRefundModal()
              }}
              buttonType={Secondary}
              buttonState={!isNonRefundConnector &&
              (typedPaymentStatus === Succeeded || typedPaymentStatus === PartiallyCaptured) &&
              !(paymentId->isTestPayment)
                ? Normal
                : Disabled}
            />
          </div>
        </UIUtils.RenderIf>
        <FormRenderer.DesktopRow>
          <div
            className={`flex flex-wrap ${justifyClassName} dark:bg-jp-gray-lightgray_background dark:border-jp-gray-no_data_border`}>
            {detailsFields
            ->Array.mapWithIndex((colType, i) => {
              <div className=widthClass key={i->string_of_int}>
                <DisplayKeyValueParams
                  heading={getHeading(colType)}
                  value={getCell(data, colType, connectorList->Option.getWithDefault([]))}
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
  @react.component
  let make = (
    ~orderDict,
    ~openRefundModal,
    ~isNonRefundConnector,
    ~paymentId,
    ~isMetadata=false,
  ) => {
    let order = itemToObjMapper(orderDict)
    let paymentStatus = order.status
    let headingStyles = "font-bold text-lg mb-5"
    let connectorList =
      HyperswitchAtom.connectorListAtom
      ->Recoil.useRecoilValueFromAtom
      ->LogicUtils.safeParse
      ->LogicUtils.getObjectArrayFromJson
    <div className="md:flex md:flex-col md:gap-5">
      <UIUtils.RenderIf condition={!isMetadata}>
        <div className="md:flex md:gap-10 md:items-stretch md:mt-5 mb-10">
          <div className="md:w-1/2 w-full">
            <div className={`${headingStyles}`}> {"Summary"->React.string} </div>
            <Details
              data=order
              getHeading=getHeadingForSummary
              getCell=getCellForSummary
              detailsFields=[
                Created,
                NetAmount,
                LastUpdated,
                AmountReceived,
                PaymentId,
                Currency,
                ConnectorTransactionID,
                ClientSecret,
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
            <Details
              data=order
              getHeading=getHeadingForAboutPayment
              getCell=getCellForAboutPayment
              detailsFields=[
                ProfileId,
                ProfileName,
                Connector,
                ConnectorLabel,
                CardBrand,
                PaymentMethodType,
                PaymentMethod,
                Refunds,
                AuthenticationType,
                CaptureMethod,
              ]
              isNonRefundConnector
              paymentStatus
              openRefundModal
              paymentId
              connectorList
            />
          </div>
        </div>
      </UIUtils.RenderIf>
      <UIUtils.RenderIf condition={isMetadata}>
        <div className="mb-10">
          <Details
            data=order
            getHeading=getHeadingForOtherDetails
            getCell=getCellForOtherDetails
            detailsFields=[
              FirstName,
              LastName,
              Phone,
              Email,
              CustomerId,
              Description,
              Shipping,
              Billing,
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
              FRMName,
              FRMTransactionType,
              FRMStatus,
            ]
            isNonRefundConnector
            paymentStatus
            openRefundModal
            widthClass="md:w-1/4 w-full"
            paymentId
            border=""
          />
        </div>
      </UIUtils.RenderIf>
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
  let make = (~data: DisputesEntity.disputes) => {
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
  let make = (~orderDict) => {
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

    let attemptsData =
      orderDict->getArrayFromDict("attempts", [])->Js.Json.array->OrderEntity.getAttempts

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
      <div className="flex border items-start border-blue-800 text-sm rounded-md gap-2 px-4 py-3">
        <Icon name="info-vacent" className="text-blue-900 mt-1" size=18 />
        <span>
          {`You can validate the information shown here by cross checking the hyperswitch payment attempt identifier (Attempt ID) in your payment processor portal.`->React.string}
        </span>
      </div>
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
  open OrderEntity
  @react.component
  let make = (~orderDict, ~refetch, ~showModal, ~setShowModal) => {
    let (amoutAvailableToRefund, setAmoutAvailableToRefund) = React.useState(_ => 0.0)
    let refundData = orderDict->getArrayFromDict("refunds", [])->Js.Json.array->getRefunds

    let amountRefunded = ref(0.0)
    let requestedRefundAmount = ref(0.0)
    let _ = refundData->Array.map(ele => {
      if ele.status === "pending" {
        requestedRefundAmount := requestedRefundAmount.contents +. ele.amount
      } else if ele.status === "succeeded" {
        amountRefunded := amountRefunded.contents +. ele.amount
      }
    })
    React.useEffect1(_ => {
      setAmoutAvailableToRefund(_ =>
        orderDict->getFloat("amount", 0.0) /. 100.0 -.
        amountRefunded.contents /. 100.0 -.
        requestedRefundAmount.contents /. 100.0
      )

      None
    }, [orderDict->Dict.keysToArray->Array.length])

    let order = itemToObjMapper(orderDict)

    <div className="flex flex-row justify-right gap-2">
      <Modal
        showModal
        setShowModal
        borderBottom=true
        childClass=""
        modalClass="w-fit absolute top-0 lg:top-0 md:top-1/3 left-0 lg:left-1/3 md:left-1/3 md:w-4/12 mt-10"
        bgClass="bg-white dark:bg-jp-gray-darkgray_background">
        <OrderRefundForm
          order setShowModal requestedRefundAmount amountRefunded amoutAvailableToRefund refetch
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
    let updateDetails = useUpdateMethod()
    let showToast = ToastState.useShowToast()
    let showPopUp = PopUpState.useShowPopUp()

    let updateMerchantDecision = async (~decision) => {
      try {
        let ordersDecisionUrl = `${getURL(
            ~entityName=ORDERS,
            ~methodType=Get,
            ~id=Some(order.payment_id),
            (),
          )}/${decision->String.toLowerCase}`

        let _ = await updateDetails(ordersDecisionUrl, Dict.make()->Js.Json.object_, Post)
        showToast(~message="Details Updated", ~toastType=ToastSuccess, ())
        refetch()
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
          <div className="w-1/3" key={i->string_of_int}>
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
      <UIUtils.RenderIf
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
      </UIUtils.RenderIf>
    </div>
  }
}

module FraudRiskBanner = {
  @react.component
  let make = (~frmMessage: frmMessage, ~refElement: React.ref<Js.nullable<Dom.element>>) => {
    <div
      className="flex justify-between items-center w-full border p-4 rounded-md bg-white border border-[#C04141]/50 ">
      <div className="flex gap-2">
        <img src={`/icons/redFlag.svg`} />
        <p className="text-lightgray_background font-medium text-fs-16">
          {`This payment is marked fraudulent by ${frmMessage.frm_name}.`->React.string}
        </p>
        <GatewayIcon
          gateway={frmMessage.frm_name->String.toUpperCase} className="w-6 h-6 rounded-full"
        />
      </div>
      <div
        className="text-blue-700 font-semibold text-fs-16 cursor-pointer"
        onClick={_ => {
          refElement.current
          ->Js.Nullable.toOption
          ->Belt.Option.forEach(input =>
            input->scrollIntoView(_, {behavior: "smooth", block: "start", inline: "nearest"})
          )
        }}>
        {"Review details"->React.string}
      </div>
    </div>
  }
}

module RenderAccordian = {
  @react.component
  let make = (~initialExpandedArray=[], ~accordion) => {
    <Accordion
      initialExpandedArray
      accordion
      accordianTopContainerCss="border"
      accordianBottomContainerCss="p-5"
      contentExpandCss="px-4 py-3 !border-t-0"
      titleStyle="font-semibold text-bold text-md"
    />
  }
}

@react.component
let make = (~id) => {
  open APIUtils
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let fetchDetails = useGetMethod()
  let showToast = ToastState.useShowToast()

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (refetchCounter, setRefetchCounter) = React.useState(_ => 0)
  let (showModal, setShowModal) = React.useState(_ => false)

  let frmDetailsRef = React.useRef(Js.Nullable.null)

  let orderData = OrderHooks.useGetOrdersData(id, refetchCounter, setScreenState)
  let order = OrderEntity.itemToObjMapper(orderData->getDictFromJsonObject)

  let refundData =
    orderData
    ->getDictFromJsonObject
    ->getArrayFromDict("refunds", [])
    ->Js.Json.array
    ->OrderEntity.getRefunds

  let isRefundDataAvailable = refundData->Array.length !== 0

  let disputesData =
    orderData
    ->getDictFromJsonObject
    ->getArrayFromDict("disputes", [])
    ->Js.Json.array
    ->DisputesEntity.getDisputes

  let isDisputeDataVisible = disputesData->Array.length !== 0

  let createdAt = React.useMemo1(() => {
    orderData->getDictFromJsonObject->getString("created", "")
  }, [orderData])

  let refetch = React.useCallback1(() => {
    setRefetchCounter(p => p + 1)
  }, [setRefetchCounter])

  let openRefundModal = _ => {
    setShowModal(_ => true)
  }

  let showSyncButton = React.useCallback1(_ => {
    let status = orderData->getDictFromJsonObject->getString("status", "")->statusVariantMapper

    !(id->isTestPayment) && status !== Succeeded && status !== Failed
  }, [orderData])

  let refreshStatus = async () => {
    try {
      let getRefreshStatusUrl = getURL(
        ~entityName=ORDERS,
        ~methodType=Get,
        ~id=Some(id),
        ~queryParamerters=Some("force_sync=true"),
        (),
      )
      let _ = await fetchDetails(getRefreshStatusUrl)
      showToast(~message="Details Updated", ~toastType=ToastSuccess, ())
      refetch()
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
        <UIUtils.RenderIf condition={showSyncButton()}>
          <Button
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
        </UIUtils.RenderIf>
        <div />
      </div>
      <OrderActions orderDict={orderData->getDictFromJsonObject} refetch showModal setShowModal />
    </div>
    <UIUtils.RenderIf condition={order.frm_message.frm_status === "fraud"}>
      <FraudRiskBanner frmMessage={order.frm_message} refElement=frmDetailsRef />
    </UIUtils.RenderIf>
    <PageLoaderWrapper
      screenState
      customUI={<NoDataFound
        message="Payment does not exists in out record" renderType=NotFound
      />}>
      <div className="flex flex-col gap-8">
        <OrderInfo
          paymentId=id
          orderDict={orderData->getDictFromJsonObject}
          openRefundModal
          isNonRefundConnector={isNonRefundConnector(orderData)}
        />
        <div className="overflow-scroll">
          <Attempts orderDict={orderData->getDictFromJsonObject} />
        </div>
        <UIUtils.RenderIf condition={isRefundDataAvailable}>
          <div className="overflow-scroll">
            <RenderAccordian
              initialExpandedArray={isRefundDataAvailable ? [0] : []}
              accordion={[
                {
                  title: "Refunds",
                  renderContent: () => {
                    <Refunds refundData />
                  },
                  renderContentOnTop: None,
                },
              ]}
            />
          </div>
        </UIUtils.RenderIf>
        <UIUtils.RenderIf condition={isDisputeDataVisible}>
          <div className="overflow-scroll">
            <RenderAccordian
              initialExpandedArray={isDisputeDataVisible ? [0] : []}
              accordion={[
                {
                  title: "Disputes",
                  renderContent: () => {
                    <Disputes disputesData />
                  },
                  renderContentOnTop: None,
                },
              ]}
            />
          </div>
        </UIUtils.RenderIf>
        <div className="overflow-scroll">
          <RenderAccordian
            accordion={[
              {
                title: "FRM Details",
                renderContent: () => {
                  <div ref={frmDetailsRef->ReactDOM.Ref.domRef}>
                    <FraudRiskBannerDetails order refetch />
                  </div>
                },
                renderContentOnTop: None,
              },
            ]}
          />
        </div>
        <UIUtils.RenderIf condition={featureFlagDetails.auditTrail}>
          <RenderAccordian
            accordion={[
              {
                title: "Events and logs",
                renderContent: () => {
                  <OrderUIUtils.PaymentLogs id createdAt />
                },
                renderContentOnTop: None,
              },
            ]}
          />
        </UIUtils.RenderIf>
        <UIUtils.RenderIf condition={!(order.metadata->LogicUtils.isEmptyDict)}>
          <RenderAccordian
            accordion={[
              {
                title: "Payment Metadata",
                renderContent: () => {
                  <div className="bg-white p-2">
                    <PaymentLogs.PrettyPrintJson
                      jsonToDisplay={order.metadata
                      ->Js.Json.stringifyAny
                      ->Belt.Option.getWithDefault("")}
                      overrideBackgroundColor="bg-white"
                    />
                  </div>
                },
                renderContentOnTop: None,
              },
            ]}
          />
        </UIUtils.RenderIf>
        <RenderAccordian
          accordion={[
            {
              title: "More Payment Details",
              renderContent: () => {
                <OrderInfo
                  paymentId=id
                  orderDict={orderData->getDictFromJsonObject}
                  openRefundModal
                  isNonRefundConnector={isNonRefundConnector(orderData)}
                  isMetadata=true
                />
              },
              renderContentOnTop: None,
            },
          ]}
        />
      </div>
    </PageLoaderWrapper>
  </div>
}
