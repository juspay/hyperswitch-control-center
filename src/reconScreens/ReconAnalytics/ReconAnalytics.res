@react.component
let make = () => {
  open ReconAnalyticsHelper

  let fetchAnalyticsListResponse = AnalyticsData.useFetchAnalyticsCardList()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (analyticsCardData, setAnalyticsCardData) = React.useState(_ => Dict.make())
  let (startDate, setStartDate) = React.useState(_ => ConfigUtils.getTodayDate())
  let (endDate, setEndDate) = React.useState(_ => ConfigUtils.getTomorrowDate())

  let (initialValues, _) = React.useState(_ =>
    JSON.Encode.object(
      Dict.fromArray([
        ("startDate", JSON.Encode.string(ConfigUtils.getTodayDate())),
        ("endDate", JSON.Encode.string(ConfigUtils.getTomorrowDate())),
      ]),
    )
  )

  let getAnalyticsCardList = async _ => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let response = await fetchAnalyticsListResponse(
        ~start=`${startDate}T00:00:00Z`,
        ~end=`${endDate}T23:59:59Z`,
      )
      setAnalyticsCardData(_ => response->LogicUtils.getDictFromJsonObject)
      setScreenState(_ => Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch"))
    }
  }

  React.useEffect(() => {
    getAnalyticsCardList()->ignore
    None
  }, [startDate, endDate])

  let onSubmit = (values, _) => {
    let metadata = values->LogicUtils.getDictFromJsonObject
    let startDate = metadata->LogicUtils.getString("startDate", "")
    let endDate = metadata->LogicUtils.getString("endDate", "")

    setStartDate(_ => startDate)
    setEndDate(_ => endDate)
    open Promise
    Nullable.null->resolve
  }

  <div>
    <div className="relative">
      <PageUtils.PageHeading
        title={"Reconciliation Analytics"}
        customTitleStyle="!text-lg !font-semibold"
        subTitle={"View all the reconciliation analytics here"}
        customSubTitleStyle="text-base font-medium"
      />
      <div className="flex flex-row gap-6 absolute bottom-0 right-0">
        <Form initialValues onSubmit>
          <div className="flex flex-row gap-6">
            <FormRenderer.FieldRenderer
              field={FormRenderer.makeMultiInputFieldInfo(
                ~label="",
                ~comboCustomInput=InputFields.dateRangeField(
                  ~startKey="startDate",
                  ~endKey="endDate",
                  ~format="YYYY-MM-DD",
                  ~showTime=false,
                  ~disablePastDates={false},
                  ~disableFutureDates={true},
                  ~predefinedDays=[Today, Yesterday, ThisMonth, LastMonth, LastSixMonths],
                  ~numMonths=2,
                  ~dateRangeLimit=400,
                  ~disableApply=true,
                  ~isTooltipVisible=false,
                  ~customButtonStyle="!w-1/2",
                ),
                ~inputFields=[],
              )}
            />
            <FormRenderer.SubmitButton
              text="Apply" customSumbitButtonStyle="w-full mt-4" buttonType={Primary}
            />
          </div>
        </Form>
      </div>
    </div>
    <PageLoaderWrapper screenState>
      <ReconAnalyticsCards analyticsCardData />
      <ReconAnalyticsBarChart />
    </PageLoaderWrapper>
  </div>
}
