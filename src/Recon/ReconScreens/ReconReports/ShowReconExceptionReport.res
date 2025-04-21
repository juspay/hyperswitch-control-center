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
            <ReconReportsHelper.DisplayKeyValueParams
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
  let make = (~exceptionReportDetails) => {
    open ReportsExceptionTableEntity

    <div className="w-full pb-6 border-b border-nd_gray-150">
      <ShowOrderDetails
        data=exceptionReportDetails
        getHeading
        getCell
        detailsFields=[
          TransactionId,
          OrderId,
          TransactionDate,
          PaymentGateway,
          PaymentMethod,
          TxnAmount,
          SettlementAmount,
          ExceptionType,
        ]
        isButtonEnabled=true
      />
    </div>
  }
}
@react.component
let make = (~showOnBoarding, ~id) => {
  open LogicUtils
  open ReconExceptionsUtils

  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let showToast = ToastState.useShowToast()
  let (offset, setOffset) = React.useState(_ => 0)
  let (reconExceptionReport, setReconExceptionReport) = React.useState(_ =>
    Dict.make()->ReconExceptionsUtils.getExceptionReportPayloadType
  )
  let (attemptData, setAttemptData) = React.useState(_ => [])
  let (showModal, setShowModal) = React.useState(_ => false)
  let defaultObject = Dict.make()->ReconExceptionsUtils.getExceptionReportPayloadType
  let fetchApi = AuthHooks.useApiFetcher()

  let fetchOrderDetails = async _ => {
    if showOnBoarding {
      RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/v2/recon"))
    } else {
      try {
        setScreenState(_ => Loading)
        let url = `${GlobalVars.getHostUrl}/test-data/recon/reconExceptions.json`
        let exceptionsResponse = await fetchApi(
          url,
          ~method_=Get,
          ~xFeatureRoute=false,
          ~forceCookies=false,
        )
        let res = await exceptionsResponse->(res => res->Fetch.Response.json)
        let data =
          res
          ->getDictFromJsonObject
          ->getArrayFromDict("data", [])
          ->ReconExceptionsUtils.getArrayOfReportsListPayloadType
        let selectedDataArray = data->Array.filter(item => {item.transaction_id == id})
        let selectedDataObject = selectedDataArray->getValueFromArray(0, defaultObject)
        let exceptionMatrixArray = selectedDataObject.exception_matrix

        setAttemptData(_ => exceptionMatrixArray)
        setReconExceptionReport(_ => selectedDataObject)
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
  }

  React.useEffect(() => {
    fetchOrderDetails()->ignore
    None
  }, [])

  let modalHeading = {
    <div className="flex justify-between border-b">
      <div className="flex gap-4 items-center my-5">
        <p className="font-semibold text-nd_gray-700 px-6 leading-5 text-lg">
          {"Resolve Issue"->React.string}
        </p>
      </div>
      <Icon
        name="modal-close-icon"
        className="cursor-pointer mr-4"
        size=30
        onClick={_ => setShowModal(_ => false)}
      />
    </div>
  }

  let onSubmit = async (_values, _form: ReactFinalForm.formApi) => {
    showToast(~message="Resolved Successfully!", ~toastType=ToastState.ToastSuccess)
    setReconExceptionReport(_ => {...reconExceptionReport, exception_type: "Resolved"})
    setShowModal(_ => false)
    Nullable.null
  }

  <div className="flex flex-col gap-8">
    <BreadCrumbNavigation
      path=[{title: "Recon", link: `/v2/recon/reports?tab=exceptions`}]
      currentPageTitle="Exceptions Summary"
      cursorStyle="cursor-pointer"
      customTextClass="text-nd_gray-400"
      titleTextClass="text-nd_gray-600 font-medium"
      fontWeight="font-medium"
      dividerVal=Slash
      childGapClass="gap-2"
    />
    <div className="flex flex-col gap-4">
      <div className="flex flex-row justify-between items-center">
        <div className="flex gap-6 items-center">
          <PageUtils.PageHeading title={`Transaction ID: ${reconExceptionReport.transaction_id}`} />
          {switch reconExceptionReport.exception_type->getExceptionsStatusTypeFromString {
          | AmountMismatch
          | StatusMismatch
          | Both =>
            <div
              className="text-sm text-white font-semibold px-3  py-1 rounded-md bg-nd_red-50 dark:bg-opacity-50 flex gap-2">
              <p className="text-nd_red-400">
                {reconExceptionReport.exception_type
                ->getExceptionsStatusTypeFromString
                ->getExceptionStringFromStatus
                ->React.string}
              </p>
            </div>
          | Resolved =>
            <div
              className="text-sm text-white font-semibold px-3  py-1 rounded-md bg-nd_green-50 dark:bg-opacity-50 flex gap-2">
              <p className="text-nd_green-400"> {"Resolved"->React.string} </p>
            </div>
          }}
        </div>
        <RenderIf
          condition={reconExceptionReport.exception_type->getExceptionsStatusTypeFromString !=
            Resolved}>
          <ACLButton
            text="Resolve Issue"
            customButtonStyle="!w-fit"
            buttonType={Primary}
            onClick={_ => setShowModal(_ => true)}
          />
        </RenderIf>
      </div>
      <div className="w-full py-3 px-4 bg-orange-50 flex justify-between items-center rounded-lg">
        <div className="flex gap-4 items-center">
          <Icon name="nd-hour-glass" size=16 />
          <p className="text-nd_gray-600 text-base leading-6 font-medium">
            {"Payment Gateway processed the payment, but no matching record exists in the bank statement (Settlement Missing)."->React.string}
          </p>
        </div>
      </div>
      <PageLoaderWrapper
        screenState
        customUI={<NoDataFound
          message="Payment does not exists in out record" renderType=NotFound
        />}>
        <OrderInfo exceptionReportDetails=reconExceptionReport />
        <LoadedTable
          title="Exception Matrix"
          actualData={attemptData->Array.map(Nullable.make)}
          entity={ReportsExceptionTableEntity.exceptionAttemptsEntity()}
          totalResults={attemptData->Array.length}
          resultsPerPage=20
          offset
          setOffset
          currrentFetchCount={attemptData->Array.length}
        />
      </PageLoaderWrapper>
    </div>
    <Modal
      setShowModal
      showModal
      closeOnOutsideClick=true
      modalClass="w-full max-w-xl mx-auto my-auto dark:!bg-jp-gray-lightgray_background"
      childClass="m-4 h-full"
      customModalHeading=modalHeading>
      <div className="flex flex-col gap-4">
        <Form onSubmit validate={validateNoteField} initialValues={Dict.make()->JSON.Encode.object}>
          <FormRenderer.FieldRenderer
            labelClass="font-semibold"
            field={FormRenderer.makeFieldInfo(
              ~label="Add a Note",
              ~name="note",
              ~placeholder="You can log comments",
              ~customInput=InputFields.multiLineTextInput(
                ~isDisabled=false,
                ~rows=Some(4),
                ~cols=Some(50),
                ~maxLength=500,
                ~customClass="!h-28 !rounded-xl",
              ),
              ~isRequired=true,
            )}
          />
          <FormRenderer.DesktopRow wrapperClass="!w-full" itemWrapperClass="!mx-0.5">
            <FormRenderer.SubmitButton
              tooltipForWidthClass="w-full"
              text="Done"
              buttonType={Primary}
              customSumbitButtonStyle="!w-full mt-4"
            />
          </FormRenderer.DesktopRow>
        </Form>
      </div>
    </Modal>
  </div>
}
