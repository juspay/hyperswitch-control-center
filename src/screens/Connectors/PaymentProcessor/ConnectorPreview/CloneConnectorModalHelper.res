open Typography

module ConnectorSourceDestination = {
  @react.component
  let make = (
    ~connectorInfo: ConnectorTypes.connectorPayload,
    ~sourceProfileName: string,
    ~destinationProfileOptions: array<SelectBox.dropdownOption>,
  ) => {
    <div className="flex flex-col gap-2">
      <div className="flex items-center gap-3">
        <p className={`flex-1 min-w-0 ${body.sm.semibold} text-nd_gray-400 tracking-wide`}>
          {"SOURCE"->React.string}
        </p>
        <span className="w-4 shrink-0" />
        <p className={`flex-1 min-w-0 ${body.sm.semibold} text-nd_gray-400 tracking-wide`}>
          {"DESTINATION"->React.string}
        </p>
      </div>
      <div className="flex items-stretch gap-3">
        <div
          className="flex-1 min-w-0 flex items-center gap-2.5 border border-nd_gray-150 bg-nd_gray-50 rounded-lg px-3">
          <GatewayIcon
            gateway={connectorInfo.connector_name->String.toUpperCase} className="w-6 h-6 shrink-0"
          />
          <p className="truncate min-w-0">
            <span className={`${body.sm.semibold} text-nd_gray-700`}>
              {ConnectorUtils.getDisplayNameForConnector(
                connectorInfo.connector_name,
              )->React.string}
            </span>
            <span className={`${body.sm.regular} text-nd_gray-400`}>
              {` · ${sourceProfileName}`->React.string}
            </span>
          </p>
        </div>
        <div className="w-4 shrink-0 self-center flex justify-center">
          <Icon name="nd-arrow-right" size=16 className="text-nd_gray-400" />
        </div>
        <div className="flex-1 min-w-0">
          <ReactFinalForm.Field
            name="destination_profile_id"
            render={({input}) =>
              <SelectBoxAdapter
                input
                options=destinationProfileOptions
                buttonText="Select a profile"
                allowMultiSelect=false
                deselectDisable=true
                fullLength=true
                buttonSize=Button.Medium
              />}
          />
        </div>
      </div>
    </div>
  }
}

module CloneScopeSummary = {
  @react.component
  let make = () => {
    <div className="flex flex-col gap-3">
      <div className="flex flex-col gap-2">
        <p className={`${body.sm.semibold} text-nd_gray-400 tracking-wide`}>
          {"INCLUDED IN THE CLONE"->React.string}
        </p>
        <div className="flex flex-wrap gap-2">
          {["Credentials", "Webhook", "Payment methods"]
          ->Array.map(item =>
            <TagBinding
              key=item
              text=item
              variant=Subtle
              color=Success
              shape=Squarical
              size=Xs
              leftSlot={<Icon name="nd-check" size=12 className="text-nd_green-600" />}
            />
          )
          ->React.array}
        </div>
      </div>
      <div className="flex flex-col gap-2">
        <p className={`${body.sm.semibold} text-nd_gray-400 tracking-wide`}>
          {"NOT INCLUDED"->React.string}
        </p>
        <div className="flex flex-wrap gap-2">
          {["Wallets", "Bank debits"]
          ->Array.map(item =>
            <TagBinding
              key=item
              text=item
              variant=Subtle
              color=Neutral
              shape=Squarical
              size=Xs
              leftSlot={<Icon name="nd-cross" size=12 className="text-nd_gray-500" />}
            />
          )
          ->React.array}
        </div>
        <p className={`${body.sm.regular} text-nd_gray-500`}>
          {"These payment methods aren't copied. Enable them manually if needed."->React.string}
        </p>
      </div>
    </div>
  }
}
