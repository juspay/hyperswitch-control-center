open Typography
open ReconEngineGenerateReportTypes
open ReconEngineGenerateReportUtils

module ReportFields = {
  @react.component
  let make = (~reportConfig: reportConfig) => {
    open LogicUtils
    let form = ReactFinalForm.useForm()
    let validateRange = React.useCallback((_, values) =>
      getReportDateRangeError(~limit=reportConfig.dateRangeLimit, values)
      ->Nullable.fromOption
      ->Promise.resolve
    , [reportConfig.dateRangeLimit])
    let recipients =
      form.getState().values
      ->getDictFromJsonObject
      ->getArrayFromDict("emails", [])
      ->Array.map(email => email->getStringFromJson(""))

    <>
      <div className="mb-4">
        <AlertV2Binding
          alertType=Primary
          slot={{
            slot: <Icon name="nd-toast-info" size=20 className="text-nd_primary_blue-450" />,
          }}
          description=reportConfig.description
        />
      </div>
      <ReactFinalForm.Field name="end_time" validate=validateRange>
        {({meta}) => <>
          <FormRenderer.FieldRenderer
            field={FormRenderer.makeMultiInputFieldInfo(
              ~label="Date Range",
              ~comboCustomInput=InputFields.dateRangeField(
                ~startKey="start_time",
                ~endKey="end_time",
                ~format="YYYY-MM-DDTHH:mm:ss[Z]",
                ~showTime=true,
                ~disablePastDates=false,
                ~disableFutureDates=true,
                ~predefinedDays=reportConfig.predefinedDays,
                ~numMonths=2,
                ~dateRangeLimit=reportConfig.dateRangeLimit,
                ~disableApply=false,
                ~optFieldKey="opt",
                ~isTooltipVisible=false,
              ),
              ~inputFields=[],
              ~isRequired=true,
            )}
          />
          <RenderIf condition={meta.error->Nullable.toOption->Option.isSome}>
            <p role="alert" className="mt-1 text-sm text-red-700 dark:text-red-400">
              {meta.error->Nullable.toOption->Option.getOr("")->React.string}
            </p>
          </RenderIf>
        </>}
      </ReactFinalForm.Field>
      <FormRenderer.FieldRenderer
        field={FormRenderer.makeFieldInfo(
          ~label="Additional Recipients",
          ~name="emails",
          ~customInput=(~input as _, ~placeholder as _) => {
            <PillInput
              name="emails" initialItems=recipients placeholder="Enter email(s)" singleLine=true
            />
          },
        )}
      />
      <FormRenderer.SubmitButton text="Generate" customSubmitButtonStyle="mt-5 mb-3" />
    </>
  }
}

module ReportTypeSelector = {
  @react.component
  let make = (~reportType, ~setReportType) => {
    let tabs: array<Tabs.tab> = React.useMemo(() =>
      [TransactionReport, LinkedReport]->Array.map(selectedReport => {
        Tabs.title: selectedReport->getReportTabTitle,
        renderContent: () =>
          <div className="mt-4">
            <ReportFields reportConfig={getReportConfig(Transactions, selectedReport)} />
          </div>,
        onTabSelection: () => setReportType(_ => selectedReport),
      })
    , [setReportType])

    <Tabs tabs initialIndex={reportType->getReportTabIndex} variant=Boxed size=Md fitContent=true />
  }
}

module ReportForm = {
  @react.component
  let make = (~setShowModal, ~rule: ReconEngineRulesTypes.rulePayload, ~variant: reportVariant) => {
    open APIUtils
    open LogicUtils
    open ReconEngineFilterUtils

    let getURL = useGetURL()
    let showToast = ToastAdapter.useShowToast()
    let updateDetails = useUpdateMethod(~showErrorToast=false)
    let mixpanelEvent = MixpanelHook.useSendEvent()
    let globalDateFilters = ReconEngineAtoms.globalDateFiltersAtom->Recoil.useRecoilValueFromAtom
    let (reportType, setReportType) = React.useState(_ => TransactionReport)
    let reportConfig = getReportConfig(variant, reportType)

    let initialValues = React.useMemo(() => {
      let defaultDate = HSwitchRemoteFilter.getDateFilteredObject(~range=30)
      let (startTime, endTime) = ReconEngineFilterUtils.hasGlobalDateFilterValue(~globalDateFilters)
        ? (globalDateFilters.startTime, globalDateFilters.endTime)
        : (defaultDate.start_time, defaultDate.end_time)
      {
        "start_time": startTime,
        "end_time": endTime,
      }->Identity.genericTypeToJson
    }, (globalDateFilters.startTime, globalDateFilters.endTime))

    let generateReport = async body => {
      try {
        let url = getURL(
          ~entityName=V1(HYPERSWITCH_RECON),
          ~hyperswitchReconType=reportConfig.endpoint,
          ~methodType=Post,
        )
        let _ = await updateDetails(url, body, Post)
        setShowModal(_ => false)
        showToast(
          ~message="Report requested. You'll receive an email when it's ready.",
          ~toastType=ToastSuccess,
        )
      } catch {
      | _ => showToast(~message="Something went wrong. Please try again.", ~toastType=ToastError)
      }
      Nullable.null
    }

    let onSubmit = (values, _) => {
      let formValues = values->Identity.genericTypeToJson->getDictFromJsonObject
      let startTime = formValues->getString("start_time", "")->toReconTimeString
      let endTime = formValues->getString("end_time", "")->toReconTimeString
      let metadata = {
        "report_type": getReportEventType(variant, reportType),
        "start_time": startTime,
        "end_time": endTime,
      }->Identity.genericTypeToJson
      mixpanelEvent(~eventName="recon_engine_generate_report_submit", ~metadata)
      let body =
        {
          "rule_id": rule.rule_id,
          "start_time": startTime,
          "end_time": endTime,
        }
        ->Identity.genericTypeToJson
        ->getDictFromJsonObject
      formValues->Dict.get("emails")->Option.forEach(emails => body->Dict.set("emails", emails))
      generateReport(body->JSON.Encode.object)
    }

    <Form onSubmit initialValues>
      <RenderIf condition={variant === Transactions}>
        <ReportTypeSelector reportType setReportType />
      </RenderIf>
      <RenderIf condition={variant === Exceptions}>
        <ReportFields reportConfig />
      </RenderIf>
    </Form>
  }
}

@react.component
let make = (
  ~showModal,
  ~setShowModal,
  ~rule: ReconEngineRulesTypes.rulePayload,
  ~variant: reportVariant,
) => {
  let reportConfig = getReportConfig(variant, TransactionReport)
  <Modal
    modalHeading=reportConfig.modalHeading
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
    <ReportForm rule variant setShowModal />
  </Modal>
}
