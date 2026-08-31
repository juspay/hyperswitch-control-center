open Typography

@react.component
let make = (
  ~showModal,
  ~setShowModal,
  ~rule: ReconEngineRulesTypes.rulePayload,
  ~hyperswitchReconType: APIUtilsTypes.hyperswitchReconType,
  ~modalHeading,
) => {
  open APIUtils
  open LogicUtils

  let getURL = useGetURL()
  let showToast = ToastAdapter.useShowToast()
  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let globalDateFilters = ReconEngineAtoms.globalDateFiltersAtom->Recoil.useRecoilValueFromAtom
  let defaultDate = HSwitchRemoteFilter.getDateFilteredObject(~range=30)

  let (startTime, endTime) = ReconEngineFilterUtils.hasGlobalDateFilterValue(~globalDateFilters)
    ? (globalDateFilters.startTime, globalDateFilters.endTime)
    : (defaultDate.start_time, defaultDate.end_time)

  let generateReport = async body => {
    try {
      let url = getURL(~entityName=V1(HYPERSWITCH_RECON), ~hyperswitchReconType, ~methodType=Post)
      let _ = await updateDetails(url, body, Post)
      setShowModal(_ => false)
      showToast(~message="Email Sent", ~toastType=ToastSuccess)
    } catch {
    | _ => showToast(~message="Something went wrong. Please try again.", ~toastType=ToastError)
    }
    Nullable.null
  }

  let onSubmit = (values, _) => {
    let metadata = values->Identity.genericTypeToJson
    mixpanelEvent(~eventName="recon_engine_generate_report_submit", ~metadata)
    let bodyDict = metadata->getDictFromJsonObject
    bodyDict->Dict.set("rule_id", rule.rule_id->JSON.Encode.string)
    generateReport(bodyDict->JSON.Encode.object)
  }

  let initialValues = {
    "start_time": startTime,
    "end_time": endTime,
  }->Identity.genericTypeToJson

  <Modal
    modalHeading
    showModal
    modalHeadingDescriptionElement={<div className="flex items-center gap-1 mt-1 w-full min-w-0">
      <span className={`${body.sm.regular} text-nd_gray-500 shrink-0`}>
        {"Rule: "->React.string}
      </span>
      <span className={`${body.sm.medium} text-nd_gray-700 truncate`}>
        {rule.rule_name->React.string}
      </span>
    </div>}
    setShowModal
    modalClass="w-full max-w-2xl mx-auto my-auto">
    <Form onSubmit initialValues>
      <div className="mb-4">
        <AlertV2Binding
          alertType=Primary
          slot={{
            slot: <Icon name="nd-toast-info" size=20 className="text-nd_primary_blue-450" />,
          }}
          description="The generated report will be emailed to you."
        />
      </div>
      <FormRenderer.FieldRenderer
        field={FormRenderer.makeMultiInputFieldInfo(
          ~label="Date Range",
          ~comboCustomInput=InputFields.dateRangeField(
            ~startKey="start_time",
            ~endKey="end_time",
            ~format="YYYY-MM-DDTHH:mm:ss[Z]",
            ~showTime=true,
            ~disablePastDates={false},
            ~disableFutureDates={true},
            ~predefinedDays=[Today, Yesterday, ThisMonth, LastMonth],
            ~numMonths=2,
            ~dateRangeLimit=180,
            ~disableApply=false,
            ~optFieldKey="opt",
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
            <PillInput name="emails" placeholder="Enter email(s)" singleLine=true />
          },
        )}
      />
      <FormRenderer.SubmitButton text="Generate" customSubmitButtonStyle="mt-5 mb-3" />
    </Form>
  </Modal>
}
