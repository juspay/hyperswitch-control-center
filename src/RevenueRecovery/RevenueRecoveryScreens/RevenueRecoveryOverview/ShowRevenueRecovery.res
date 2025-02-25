open RevenueRecoveryEntity
open LogicUtils
open RecoveryOverviewHelper
open RevenueRecoveryOrderTypes
module ShowOrderDetails = {
  @react.component
  let make = (
    ~data,
    ~getHeading,
    ~getCell,
    ~detailsFields,
    ~justifyClassName="justify-start",
    ~widthClass="w-1/3",
    ~bgColor="bg-white dark:bg-jp-gray-lightgray_background",
    ~isButtonEnabled=false,
    ~border="border border-jp-gray-940 border-opacity-75 dark:border-jp-gray-960",
    ~customFlex="flex-wrap",
    ~isHorizontal=false,
  ) => {
    <FormRenderer.DesktopRow>
      <div
        className={`flex ${customFlex} ${justifyClassName} dark:bg-jp-gray-lightgray_background dark:border-jp-gray-no_data_border `}>
        {detailsFields
        ->Array.mapWithIndex((colType, i) => {
          <div className=widthClass key={i->Int.toString}>
            <DisplayKeyValueParams
              heading={getHeading(colType)}
              value={getCell(data, colType)}
              customMoneyStyle="!font-normal !text-sm"
              labelMargin="!py-0 mt-2"
              overiddingHeadingStyles="text-nd_gray-400 text-sm font-medium"
              isHorizontal
            />
          </div>
        })
        ->React.array}
      </div>
    </FormRenderer.DesktopRow>
  }
}
module OrderInfo = {
  @react.component
  let make = (~order) => {
    let headingStyles = "font-bold text-lg mb-5 px-4"

    <div className="flex flex-col mb-10 ">
      <div className="w-full mb-6 ">
        <ShowOrderDetails
          data=order
          getHeading=getHeadingForSummary
          getCell=getCellForSummary
          detailsFields=[OrderAmount, Created, LastUpdated, PaymentId, ProductName]
          isButtonEnabled=true
        />
      </div>
      <div className="w-full">
        <div className={`${headingStyles}`}> {"Payment Details"->React.string} </div>
        <ShowOrderDetails
          data=order
          getHeading=getHeadingForAboutPayment
          getCell=getCellForAboutPayment
          detailsFields=[Connector, ProfileId, PaymentMethodType, CardNetwork, MandateId]
        />
      </div>
    </div>
  }
}
module AttemptsSection = {
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
module Attempts = {
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
      let rowValue_a = a.id
      let rowValue_b = b.id

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

@react.component
let make = (~id) => {
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (revenueRecoveryData, setRevenueRecoveryData) = React.useState(_ =>
    Dict.make()->RevenueRecoveryEntity.itemToObjMapper
  )
  let showToast = ToastState.useShowToast()
  let {globalUIConfig: {primaryColor}} = React.useContext(ThemeProvider.themeContext)

  let fetchOrderDetails = async _ => {
    try {
      setScreenState(_ => Loading)

      // let res = await fetchDetails(url)
      let res = {
        {
          "id": "12345_pay_01926c58bc6e77c09e809964e72af8c8",
          "status": "succeeded",
          "amount": {
            "order_amount": 6540,
            "currency": "AED",
            "shipping_cost": 123,
            "order_tax_amount": 123,
            "external_tax_calculation": "skip",
            "surcharge_calculation": "skip",
            "surcharge_amount": 123,
            "tax_on_surcharge": 123,
            "net_amount": 123,
            "amount_to_capture": 123,
            "amount_capturable": 123,
            "amount_captured": 123,
          },
          "customer_id": "12345_cus_01926c58bc6e77c09e809964e72af8c8",
          "connector": "stripe",
          "client_secret": "<string>",
          "created": "2022-09-10T10:11:12Z",
          "payment_method_data": {
            "card": {
              "last4": "<string>",
              "card_type": "<string>",
              "card_network": "Visa",
              "card_issuer": "<string>",
              "card_issuing_country": "<string>",
              "card_isin": "<string>",
              "card_extended_bin": "<string>",
              "card_exp_month": "<string>",
              "card_exp_year": "<string>",
              "card_holder_name": "<string>",
              "payment_checks": "<any>",
              "authentication_data": "<any>",
            },
            "billing": {
              "address": {
                "city": "New York",
                "country": "AF",
                "line1": "123, King Street",
                "line2": "Powelson Avenue",
                "line3": "Bridgewater",
                "zip": "08807",
                "state": "New York",
                "first_name": "John",
                "last_name": "Doe",
              },
              "phone": {
                "number": "9123456789",
                "country_code": "+1",
              },
              "email": "<string>",
            },
          },
          "payment_method_type": "card",
          "payment_method_subtype": "ach",
          "connector_transaction_id": "993672945374576J",
          "connector_reference_id": "993672945374576J",
          "merchant_connector_id": "<string>",
          "browser_info": {
            "color_depth": 1,
            "java_enabled": true,
            "java_script_enabled": true,
            "language": "<string>",
            "screen_height": 1,
            "screen_width": 1,
            "time_zone": 123,
            "ip_address": "<string>",
            "accept_header": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
            "user_agent": "<string>",
            "os_type": "<string>",
            "os_version": "<string>",
            "device_model": "<string>",
            "accept_language": "<string>",
          },
          "error": {
            "code": "<string>",
            "message": "<string>",
            "unified_code": "<string>",
            "unified_message": "<string>",
          },
          "shipping": {
            "address": {
              "city": "New York",
              "country": "AF",
              "line1": "123, King Street",
              "line2": "Powelson Avenue",
              "line3": "Bridgewater",
              "zip": "08807",
              "state": "New York",
              "first_name": "John",
              "last_name": "Doe",
            },
            "phone": {
              "number": "9123456789",
              "country_code": "+1",
            },
            "email": "<string>",
          },
          "billing": {
            "address": {
              "city": "New York",
              "country": "AF",
              "line1": "123, King Street",
              "line2": "Powelson Avenue",
              "line3": "Bridgewater",
              "zip": "08807",
              "state": "New York",
              "first_name": "John",
              "last_name": "Doe",
            },
            "phone": {
              "number": "9123456789",
              "country_code": "+1",
            },
            "email": "<string>",
          },
          "attempts": [
            {
              "id": "<string>",
              "status": "started",
              "amount": {
                "net_amount": 123,
                "amount_to_capture": 123,
                "surcharge_amount": 123,
                "tax_on_surcharge": 123,
                "amount_capturable": 123,
                "shipping_cost": 123,
                "order_tax_amount": 123,
              },
              "connector": "stripe",
              "error": {
                "code": "<string>",
                "message": "<string>",
                "unified_code": "<string>",
                "unified_message": "<string>",
              },
              "authentication_type": "three_ds",
              "created_at": "2023-11-07T05:31:56Z",
              "modified_at": "2023-11-07T05:31:56Z",
              "cancellation_reason": "<string>",
              "payment_token": "187282ab-40ef-47a9-9206-5099ba31e432",
              "connector_metadata": {
                "apple_pay": {
                  "session_token_data": {
                    "payment_processing_certificate": "<string>",
                    "payment_processing_certificate_key": "<string>",
                    "payment_processing_details_at": "Hyperswitch",
                    "certificate": "<string>",
                    "certificate_keys": "<string>",
                    "merchant_identifier": "<string>",
                    "display_name": "<string>",
                    "initiative": "web",
                    "initiative_context": "<string>",
                    "merchant_business_country": "AF",
                  },
                },
                "airwallex": {
                  "payload": "<string>",
                },
                "noon": {
                  "order_category": "<string>",
                },
              },
              "payment_experience": "redirect_to_url",
              "payment_method_type": "card",
              "connector_reference_id": "993672945374576J",
              "payment_method_subtype": "ach",
              "connector_payment_id": "993672945374576J",
              "payment_method_id": "12345_pm_01926c58bc6e77c09e809964e72af8c8",
              "client_source": "<string>",
              "client_version": "<string>",
            },
          ],
        }
      }->Identity.genericTypeToJson

      let order = RevenueRecoveryEntity.itemToObjMapper(res->getDictFromJsonObject)
      setRevenueRecoveryData(_ => order)
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
    fetchOrderDetails()->ignore
    None
  }, [])
  let statusUI = getStatus(revenueRecoveryData, primaryColor)

  <div className="flex flex-col gap-8">
    <BreadCrumbNavigation
      path=[{title: "Overview", link: "/v2/recovery/overview"}]
      currentPageTitle=id
      cursorStyle="cursor-pointer"
      customTextClass="text-nd_gray-400"
      titleTextClass="text-nd_gray-600 font-medium"
      fontWeight="font-medium"
      dividerVal=Slash
      childGapClass="gap-2"
    />
    <div className="flex flex-col gap-10">
      <div className="flex flex-row justify-between items-center">
        <div className="flex gap-2 items-center">
          <PageUtils.PageHeading title={`${revenueRecoveryData.invoice_id}`} />
          {statusUI}
        </div>
        //Todo: Enable Stop recovery and refund amount buttons when needed"
        // <div className="flex gap-2 ">
        //   <ACLButton text="Stop Recovery" customButtonStyle="!w-fit" buttonType={Secondary} />
        //   <ACLButton text="Refund Amount" customButtonStyle="!w-fit" buttonType={Primary} />
        // </div>
      </div>
      <PageLoaderWrapper
        screenState
        customUI={<NoDataFound
          message="Payment does not exists in out record" renderType=NotFound
        />}>
        <div className="grid grid-cols-4  ">
          <div className="col-span-3">
            <OrderInfo order=revenueRecoveryData />
          </div>
          <div className="col-span-1">
            <div className="border rounded-lg rounded-b-none bg-nd_gray-100 px-4 py-2">
              <p className="text-nd_gray-700 text-base font-semibold px-2 ">
                {"Amount Details"->React.string}
              </p>
            </div>
            <div className="border border-t-none rounded-t-none rounded-lg bg-nd_gray-100 p-2">
              <ShowOrderDetails
                data=revenueRecoveryData
                widthClass="w-full"
                getHeading=getHeadingForAboutPayment
                getCell=getCellForAboutPayment
                detailsFields=[AmountCapturable, AmountReceived, AuthenticationType]
                isButtonEnabled=true
                customFlex="flex-col"
                isHorizontal=true
              />
            </div>
          </div>
        </div>
      </PageLoaderWrapper>
    </div>
    <div className="overflow-scroll">
      <Attempts order={revenueRecoveryData} />
    </div>
  </div>
}
