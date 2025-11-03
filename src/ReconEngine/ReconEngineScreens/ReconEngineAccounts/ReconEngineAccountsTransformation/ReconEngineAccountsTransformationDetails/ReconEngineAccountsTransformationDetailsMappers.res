open ReconEngineTypes
open Typography
open ReconEngineAccountsTransformationUtils
open LogicUtils

module ColumnMappingDisplay = {
  @react.component
  let make = (~columnMapping: Js.Dict.t<JSON.t>) => {
    let mappingItems =
      columnMapping
      ->Dict.toArray
      ->Array.map(((key, value)) => {
        let displayKey = key->snakeToTitle
        let displayValue = value->getStringFromJson("")
        (key, displayKey, displayValue)
      })

    <div className="flex flex-col gap-3 py-3">
      <div className="flex items-center gap-4 px-6">
        <div className="flex-1 mx-2.5">
          <p className={`${body.lg.medium} text-nd_gray-800`}> {"File column"->React.string} </p>
        </div>
        <div />
        <div className="flex-1 mx-2.5">
          <p className={`${body.lg.medium} text-nd_gray-800`}> {"System column"->React.string} </p>
        </div>
      </div>
      <div className="px-6 w-full">
        <div className="flex flex-col gap-y-4">
          {mappingItems
          ->Array.map(((key, label, value)) => {
            let sourceFieldInput = createFormInput(~name=`mapping_source_${key}`, ~value=label)
            let targetFieldInput = createFormInput(~name=`mapping_target_${key}`, ~value)

            let sourceFieldOptions = [createDropdownOption(~label, ~value=label)]
            let targetFieldOptions = [
              createDropdownOption(
                ~label=value->isNonEmptyString ? value : "Not configured",
                ~value,
              ),
            ]

            <div key className="flex items-center gap-4 p-3 border rounded-lg border-nd_gray-150">
              <div className="flex-1">
                <SelectBox.BaseDropdown
                  allowMultiSelect=false
                  buttonText={value->isNonEmptyString ? value : "Not configured"}
                  input=targetFieldInput
                  options=targetFieldOptions
                  hideMultiSelectButtons=true
                  deselectDisable=true
                  disableSelect=true
                  fullLength=true
                />
              </div>
              <div className="flex items-center">
                <Icon name="nd-arrow-right" size=14 className="text-nd_gray-500" />
              </div>
              <div className="flex-1">
                <SelectBox.BaseDropdown
                  allowMultiSelect=false
                  buttonText={label}
                  input=sourceFieldInput
                  options=sourceFieldOptions
                  hideMultiSelectButtons=true
                  deselectDisable=true
                  disableSelect=true
                  fullLength=true
                />
              </div>
            </div>
          })
          ->React.array}
        </div>
      </div>
    </div>
  }
}

@react.component
let make = (~showModal, ~setShowModal, ~selectedTransformationId: string) => {
  open APIUtils

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()

  let (screenState, setScreenState) = React.useState(() => PageLoaderWrapper.Custom)
  let (selectedTransformation, setSelectedTransformation) = React.useState(_ =>
    Dict.make()->getTransformationConfigPayloadFromDict
  )

  let fetchTransformationConfigDetails = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let transformationConfigUrl = getURL(
        ~entityName=V1(HYPERSWITCH_RECON),
        ~methodType=Get,
        ~hyperswitchReconType=#TRANSFORMATION_CONFIG,
        ~id=Some(selectedTransformationId),
      )
      let transformationConfigsRes = await fetchDetails(transformationConfigUrl)
      let transformationConfig =
        transformationConfigsRes->getDictFromJsonObject->getTransformationConfigPayloadFromDict

      if transformationConfig.transformation_id->isNonEmptyString {
        setSelectedTransformation(_ => transformationConfig)
        setScreenState(_ => PageLoaderWrapper.Success)
      } else {
        setScreenState(_ => PageLoaderWrapper.Custom)
      }
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  React.useEffect(() => {
    if showModal && selectedTransformationId->isNonEmptyString {
      fetchTransformationConfigDetails()->ignore
    }
    None
  }, [selectedTransformationId])

  let columnMapping = React.useMemo(() => {
    selectedTransformation.config->getDictFromJsonObject->getDictfromDict("column_mapping")
  }, [selectedTransformation])

  <Modal
    setShowModal
    showModal
    closeOnOutsideClick=true
    modalHeading="Mappers"
    modalHeadingDescription="Map columns from your file to the corresponding required system columns"
    modalHeadingClass={`text-nd_gray-800 ${heading.sm.semibold}`}
    modalClass="flex flex-col justify-start h-screen w-1/3 float-right overflow-hidden !bg-white"
    childClass="relative h-full">
    <PageLoaderWrapper
      screenState
      customUI={<NewAnalyticsHelper.NoData message="No data available." />}
      customLoader={<div className="h-full flex flex-col justify-center items-center">
        <div className="animate-spin mb-1">
          <Icon name="spinner" size=20 />
        </div>
      </div>}>
      <div className="h-full relative">
        <div className="absolute inset-0 overflow-y-auto py-2">
          {if columnMapping->isEmptyDict {
            <NewAnalyticsHelper.NoData height="h-52" message="No data available." />
          } else {
            <ColumnMappingDisplay columnMapping />
          }}
        </div>
        <div className="absolute bottom-0 left-0 right-0 bg-white p-4">
          <Button
            customButtonStyle="!w-full"
            buttonType=Button.Primary
            onClick={_ => setShowModal(_ => false)}
            text="OK"
          />
        </div>
      </div>
    </PageLoaderWrapper>
  </Modal>
}
