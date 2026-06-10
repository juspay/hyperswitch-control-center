open Typography

module NoProcessorFound = {
  @react.component
  let make = (
    ~connectorPath,
    ~subtitle="Please connect at least 1 processor in order to create a rule.",
  ) => {
    <div
      className="flex flex-col items-center justify-center gap-6 min-h-80-vh w-full border border-nd_gray-150 rounded-lg">
      <div className="flex flex-col items-center gap-2">
        <p className={`${heading.sm.semibold} text-nd_gray-800`}>
          {React.string("No Processor Found")}
        </p>
        <p className={`${body.md.medium} text-nd_gray-500`}> {React.string(subtitle)} </p>
      </div>
      <Button
        text="Connect Processor"
        buttonType=Primary
        buttonSize=Medium
        onClick={_ => RescriptReactRouter.push(GlobalVars.appendDashboardPath(~url=connectorPath))}
      />
    </div>
  }
}
