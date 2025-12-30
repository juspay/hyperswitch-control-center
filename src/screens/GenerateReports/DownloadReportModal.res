type startAndEndTime = {
  startTime: JSON.t,
  endTime: JSON.t,
}

type timeRange = {timeRange: startAndEndTime}

@react.component
let make = (~reportModal, ~setReportModal, ~entityName) => {
  open APIUtils
  open HSwitchRemoteFilter
  open LogicUtils
  open OrderUIUtils

  let getURL = useGetURL()
  let showToast = ToastState.useShowToast()
  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let {getCommonTokenDetails, getResolvedUserInfo} = React.useContext(
    UserInfoProvider.defaultContext,
  )
  let {transactionEntity} = getResolvedUserInfo()
  let {version} = getCommonTokenDetails()
  let (_, getNameForId) = OMPSwitchHooks.useOMPData()
  let defaultDate = getDateFilteredObject(~range=30)
  let {filterValueJson} = FilterContext.filterContext->React.useContext

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
    let metadata = values->Identity.genericTypeToJson
    mixpanelEvent(~eventName="generate_reports_download", ~metadata)
    downloadReport(values->Identity.genericTypeToJson)
  }

  let initialValues = {
    timeRange: {
      startTime: filterValueJson
      ->getString(startTimeFilterKey(version), defaultDate.start_time)
      ->JSON.Encode.string,
      endTime: filterValueJson
      ->getString(endTimeFilterKey(version), defaultDate.end_time)
      ->JSON.Encode.string,
    },
  }->Identity.genericTypeToJson

  let category = switch entityName {
  | V1(PAYMENT_REPORT) => "Payment"
  | V1(PAYOUT_REPORT) => "Payout"
  | V1(REFUND_REPORT) => "Refund"
  | V1(DISPUTE_REPORT) => "Dispute"
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
    modalClass="m-auto">
    <Form onSubmit initialValues>
      <FormRenderer.FieldRenderer
        field={FormRenderer.makeMultiInputFieldInfo(
          ~label="Date Range",
          ~comboCustomInput=InputFields.dateRangeField(
            ~startKey="timeRange.startTime",
            ~endKey="timeRange.endTime",
            ~format="YYYY-MM-DDTHH:mm:ss[Z]",
            ~showTime=true,
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
        field={FormRenderer.makeFieldInfo(~label="Report Type", ~name="view", ~customInput=(
          ~input as _,
          ~placeholder as _,
        ) => <TextInput input={viewInput} placeholder="" isDisabled=true />)}
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
    </Form>
  </Modal>
}
