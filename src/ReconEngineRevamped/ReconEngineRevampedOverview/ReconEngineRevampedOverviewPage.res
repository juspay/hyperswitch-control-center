@react.component
let make = () => {
  open ReconEngineRevampedHelper
  open DateRangePickerAdapter

  <div className="flex flex-row items-center justify-between w-full">
    <PageHeading title="Overview" />
    <Form formClass="flex flex-row items-center gap-4">
      <BlendDateRangePicker
        startKey="start_time"
        endKey="end_time"
        disable=false
        disablePastDates=false
        disableFutureDates=true
        predefinedDays=[Today, Yesterday, ThisMonth, LastMonth, LastSixMonths]
        format="YYYY-MM-DDTHH:mm:ss[Z]"
        dateRangeLimit=None
      />
      <Button
        rightIcon={CustomIcon(<Icon name="nd-arrow-right" size=12 />)}
        text="Work Exceptions"
        buttonType=Primary
        buttonSize=Small
        onClick={_ => ()}
        maxButtonWidth="!w-fit"
      />
    </Form>
  </div>
}
