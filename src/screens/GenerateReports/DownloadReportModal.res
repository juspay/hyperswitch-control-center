type startAndEndTime = {
  startTime: JSON.t,
  endTime: JSON.t,
}

type timeRange = {timeRange: startAndEndTime}

@react.component
let make = (~reportModal, ~setReportModal, ~entityName) => {
  open APIUtils
  let getURL = useGetURL()
  let showToast = ToastState.useShowToast()
  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let {userInfo: {transactionEntity}} = React.useContext(UserInfoProvider.defaultContext)
  let (_, getNameForId) = OMPSwitchHooks.useOMPData()

  let downloadReport = async body => {
    try {
      let url = getURL(~entityName, ~methodType=Post)
      let _ = await updateDetails(url, body, Post)
      setReportModal(_ => false)
      showToast(~message="Email Sent", ~toastType=ToastSuccess)
    } catch {
    | _ => showToast(~message="Something went wrong. Please try again.", ~toastType=ToastError)
    }
    Nullable.null
  }

  let onSubmit = (values, _) => {
    let body = values
    let metadata = body->Identity.genericTypeToJson
    mixpanelEvent(~eventName="generate_reports_download", ~metadata)
    downloadReport(body->Identity.genericTypeToJson)
  }

  let getPreviousDate = () => {
    let currentDate = Date.getTime(Date.make())
    let previousDateMilliseconds = currentDate -. 86400000.0
    let previousDate = Js.Date.fromFloat(previousDateMilliseconds)->Date.toISOString
    previousDate->TimeZoneHook.formattedISOString("YYYY-MM-DDTHH:mm:ss[Z]")
  }

  let initialValues = {
    timeRange: {
      startTime: getPreviousDate()->JSON.Encode.string,
      endTime: Date.now()->Js.Date.fromFloat->Date.toISOString->JSON.Encode.string,
    },
  }->Identity.genericTypeToJson

  let category = switch entityName {
  | PAYMENT_REPORT => "Payment"
  | REFUND_REPORT => "Refund"
  | DISPUTE_REPORT => "Dispute"
  | _ => ""
  }
  let currentview = `${(transactionEntity :> string)} (${getNameForId(transactionEntity)})`
  let viewInput: ReactFinalForm.fieldRenderPropsInput = {
    name: "view",
    onBlur: _ => (),
    onChange: _ => (),
    onFocus: _ => (),
    value: currentview->JSON.Encode.string,
    checked: true,
  }
  <Modal
    modalHeading={`Generate ${category} Reports`}
    showModal=reportModal
    modalHeadingDescriptionElement={<div
      className="text-md font-medium leading-7 opacity-50 mt-1 w-full">
      {"The generated reports will be emailed to you."->React.string}
    </div>}
    setShowModal=setReportModal
    modalClass="w-1/4 m-auto">
    <Form onSubmit initialValues>
      <FormRenderer.FieldRenderer
        field={FormRenderer.makeFieldInfo(~label="Report Type", ~name="view", ~customInput=(
          ~input as _,
          ~placeholder as _,
        ) => <TextInput input={viewInput} placeholder="" isDisabled=true />)}
      />
      <FormRenderer.FieldRenderer
        field={FormRenderer.makeMultiInputFieldInfo(
          ~label="Date Range",
          ~comboCustomInput=InputFields.dateRangeField(
            ~startKey="timeRange.startTime",
            ~endKey="timeRange.endTime",
            ~format="YYYY-MM-DDTHH:mm:ss[Z]",
            ~showTime=false,
            ~disablePastDates={false},
            ~disableFutureDates={true},
            ~predefinedDays=[Today, Yesterday, ThisMonth, LastMonth],
            ~numMonths=2,
            ~dateRangeLimit=400,
            ~disableApply=false,
            ~optFieldKey="timeRange.opt",
            ~isTooltipVisible=false,
          ),
          ~inputFields=[],
          ~isRequired=true,
        )}
      />
      <FormRenderer.FieldRenderer
        field={FormRenderer.makeFieldInfo(
          ~label="Additional Recipients",
          ~name="emails",
          ~customInput=(~input as _, ~placeholder as _) => {
            <PillInput name="emails" placeholder="Enter email(s)" />
          },
        )}
      />
      <FormRenderer.SubmitButton text="Generate" customSumbitButtonStyle="mt-5 mb-3  " />
      // <FormValuesSpy />
    </Form>
  </Modal>
}
