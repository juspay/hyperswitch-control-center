open HSwitchUtils
let p1MediumTextStyle = HSwitchUtils.getTextClass((P1, Medium))
let p1RegularText = getTextClass((P1, Regular))

module APIKeysAndLiveEndpoints = {
  @react.component
  let make = (~currentStep, ~setCurrentStep) => {
    open ReconConfigurationUtils
    open ConnectorUtils
    open ConnectorTypes
    open TempAPIUtils

    let connectorList = [Processors(FIUU)]
    let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
    let (selectedConnector, setSelectedConnector) = React.useState(() => "")
    let stepConfig = useStepConfig(
      ~step=currentStep->getSubsectionFromStep,
      ~paymentEntity=selectedConnector->String.toUpperCase,
    )

    let onSubmit = async () => {
      try {
        let _ = await stepConfig()
        setCurrentStep(prev => getNextStep(prev))
      } catch {
      | _ => ()
      }
    }

    <div className="flex flex-col h-full">
      <div className="flex flex-col gap-4 flex-grow p-2 md:p-7">
        <p className="text-medium text-grey-800 font-semibold mb-5">
          {"Setup Your API Keys & Live Endpoints"->React.string}
        </p>
        <div className={`grid gap-x-5 gap-y-6 md:grid-cols-2 grid-cols-1`}>
          {connectorList
          ->Array.mapWithIndex((connector: ConnectorTypes.connectorTypes, i) => {
            let connectorName = connector->ConnectorUtils.getConnectorNameString
            let connectorInfo = connector->getConnectorInfo
            let size = "w-14 h-14 rounded-sm"

            <ACLDiv
              authorization={userHasAccess(~groupAccess=ConnectorsManage)}
              onClick={_ => setSelectedConnector(_ => connectorName)}
              key={i->string_of_int}
              className={`${selectedConnector === connectorName
                  ? "border-blue-500"
                  : ""} border p-6 gap-4 bg-white rounded flex flex-col justify-between cursor-pointer`}
              dataAttrStr=connectorName>
              <div className="flex flex-col gap-3 items-start">
                <GatewayIcon gateway={connectorName->String.toUpperCase} className=size />
                <p className={`${p1MediumTextStyle} break-all`}>
                  {connectorName
                  ->getDisplayNameForConnector(~connectorType=Processor)
                  ->React.string}
                </p>
              </div>
              <p className="overflow-hidden text-gray-400 flex-1 line-clamp-3">
                {connectorInfo.description->React.string}
              </p>
            </ACLDiv>
          })
          ->React.array}
        </div>
      </div>
      <div className="flex justify-end items-center border-t">
        <ReconConfigurationHelper.Footer
          currentStep={currentStep}
          setCurrentStep={setCurrentStep}
          buttonName="Continue"
          onSubmit={_ => onSubmit()->ignore}
        />
      </div>
    </div>
  }
}

module WebHooks = {
  @react.component
  let make = (~currentStep, ~setCurrentStep) => {
    open ReconConfigurationUtils
    open LogicUtils
    open TempAPIUtils

    let (fileUploadedDict, setFileUploadedDict) = React.useState(_ => Dict.make())
    let uploadEvidenceType = "PSPfile"->String.toLowerCase->titleToSnake
    let showToast = ToastState.useShowToast()
    let stepConfig = useStepConfig(
      ~step=currentStep->getSubsectionFromStep,
      ~fileUploadedDict,
      ~paymentEntity="FIUU",
    )

    let toast = (message, toastType) => {
      showToast(~message, ~toastType)
    }

    let handleBrowseChange = (event, uploadEvidenceType) => {
      let target = ReactEvent.Form.target(event)
      let fileDict =
        [
          ("uploadedFile", target["files"]["0"]->Identity.genericTypeToJson),
          ("fileName", target["files"]["0"]["name"]->JSON.Encode.string),
        ]->getJsonFromArrayOfJson

      setFileUploadedDict(prev => {
        let arr = prev->Dict.toArray
        let newDict = [(uploadEvidenceType, fileDict)]->Array.concat(arr)->Dict.fromArray
        newDict
      })
    }

    let onSubmit = async () => {
      if fileUploadedDict->Dict.get(uploadEvidenceType)->Option.isNone {
        toast("Please upload a file", ToastError)
      } else {
        try {
          let _ = await stepConfig()
          setCurrentStep(prev => getNextStep(prev))
        } catch {
        | _ => ()
        }
      }
    }

    <div className="flex flex-col h-full">
      <div className="flex flex-col gap-4 flex-grow p-2 md:p-7">
        <p className="text-medium text-grey-800 font-semibold mb-5">
          {"Setup Webhook"->React.string}
        </p>
        <div className="flex items-center">
          {if fileUploadedDict->Dict.get(uploadEvidenceType)->Option.isNone {
            <label>
              <p className="cursor-pointer text-gray-500">
                <div className="flex gap-2 border border-gray-500 rounded-lg p-2 items-center">
                  <Icon name="plus" size=14 />
                  <p> {"Upload PSP file"->React.string} </p>
                </div>
                <input
                  type_="file"
                  accept=".csv"
                  onChange={ev => ev->handleBrowseChange(uploadEvidenceType)}
                  required=true
                  hidden=true
                />
              </p>
            </label>
          } else {
            let fileName =
              fileUploadedDict->getDictfromDict(uploadEvidenceType)->getString("fileName", "")
            let truncatedFileName = truncateFileNameWithEllipses(~fileName, ~maxTextLength=10)

            <div className="flex gap-4 items-center ">
              <p className={`${p1RegularText} text-grey-700`}>
                {truncatedFileName->React.string}
              </p>
              <Icon
                name="cross-skeleton"
                className="cursor-pointer"
                size=12
                onClick={_ => {
                  setFileUploadedDict(prev => {
                    let prevCopy = prev->Dict.copy
                    prevCopy->Dict.delete(uploadEvidenceType)
                    prevCopy
                  })
                }}
              />
            </div>
          }}
        </div>
      </div>
      <div className="flex justify-end items-center border-t">
        <ReconConfigurationHelper.Footer
          currentStep={currentStep}
          setCurrentStep={setCurrentStep}
          buttonName="Continue"
          onSubmit={_ => onSubmit()->ignore}
        />
      </div>
    </div>
  }
}
