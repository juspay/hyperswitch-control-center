external toJson: 'a => Js.Json.t = "%identity"

type lteGte = {
  gte: Js.Json.t,
  lte: Js.Json.t,
}

type dateCreated = {dateCreated: lteGte}

type filters = {filters: dateCreated}

type startAndEndTime = {
  startTime: Js.Json.t,
  endTime: Js.Json.t,
}

type timeRange = {timeRange: startAndEndTime, dimensions: array<string>}

@react.component
let make = (~reportModal, ~setReportModal) => {
  open APIUtils
  let showToast = ToastState.useShowToast()
  let hyperswitchMixPanel = HSMixPanel.useSendEvent()
  let url = RescriptReactRouter.useUrl()
  let updateDetails = useUpdateMethod(~showErrorToast=false, ())

  let downloadReport = async body => {
    try {
      let url = getURL(~entityName=ANALYTICS_PAYMENT_REPORT, ~methodType=Post, ())
      let _res = await updateDetails(url, body, Post)
      setReportModal(_ => false)
      showToast(~message="Email Sent", ~toastType=ToastSuccess, ())
    } catch {
    | _ => showToast(~message="Something went wrong. Please try again.", ~toastType=ToastError, ())
    }
    Js.Nullable.null
  }

  let onSubmit = (values, _) => {
    hyperswitchMixPanel(
      ~pageName=url.path->LogicUtils.getListHead,
      ~contextName="analytics_report",
      ~actionName="download_btn_clicked",
      (),
    )

    open LogicUtils
    let dateCreatedDict =
      values
      ->getDictFromJsonObject
      ->getJsonObjectFromDict("filters")
      ->getDictFromJsonObject
      ->getJsonObjectFromDict("dateCreated")
      ->getDictFromJsonObject

    let gte = dateCreatedDict->getJsonObjectFromDict("gte")
    let lte = dateCreatedDict->getJsonObjectFromDict("lte")

    let body = {
      timeRange: {
        startTime: gte,
        endTime: lte,
      },
      dimensions: [],
    }->toJson
    downloadReport(body)
  }

  let getPreviousDate = () => {
    let currentDate = Js.Date.getTime(Js.Date.make())
    let previousDateMilliseconds = currentDate -. 86400000.0
    let previousDate = Js.Date.fromFloat(previousDateMilliseconds)->Js.Date.toISOString
    previousDate->TimeZoneHook.formattedISOString("YYYY-MM-DDTHH:mm:ss[Z]")
  }

  let initialValues = {
    filters: {
      dateCreated: {
        gte: getPreviousDate()->Js.Json.string,
        lte: Js.Date.now()->Js.Date.fromFloat->Js.Date.toISOString->Js.Json.string,
      },
    },
  }->toJson

  <Modal
    modalHeading="Generate Reports"
    showModal=reportModal
    modalHeadingDescriptionElement={<div
      className="text-md font-medium leading-7 opacity-50 mt-1 w-full">
      {"The date range is in UTC, and reports will be emailed to you."->React.string}
    </div>}
    setShowModal=setReportModal
    modalClass="w-1/4 m-auto">
    <Form onSubmit initialValues>
      <FormRenderer.FieldRenderer
        field={FormRenderer.makeMultiInputFieldInfo(
          ~label="Date Range",
          ~comboCustomInput=InputFields.dateRangeField(
            ~startKey="filters.dateCreated.gte",
            ~endKey="filters.dateCreated.lte",
            ~format="YYYY-MM-DDTHH:mm:ss[Z]",
            ~showTime=false,
            ~disablePastDates={false},
            ~disableFutureDates={true},
            ~predefinedDays=[Today, Yesterday, ThisMonth, LastMonth],
            ~numMonths=2,
            ~dateRangeLimit=90,
            ~disableApply=false,
            ~optFieldKey="filters.dateCreated.opt",
            ~isTooltipVisible=false,
            (),
          ),
          ~inputFields=[],
          ~isRequired=true,
          (),
        )}
      />
      <FormRenderer.SubmitButton text="Generate" customSumbitButtonStyle="mt-10 ml-3" />
    </Form>
  </Modal>
}
