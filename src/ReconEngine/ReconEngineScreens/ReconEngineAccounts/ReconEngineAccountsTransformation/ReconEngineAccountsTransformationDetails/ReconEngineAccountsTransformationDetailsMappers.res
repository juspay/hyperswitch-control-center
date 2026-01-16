open ReconEngineTypes
open Typography
open ReconEngineAccountsTransformationUtils
open LogicUtils

module FileAndSystemColumnMapping = {
  @react.component
  let make = (~fileColumn: string, ~systemColumn: string) => {
    let cardScrollbarCss = `
      @supports (-webkit-appearance: none){
        .card-scrollbar {
            scrollbar-width: auto;
            scrollbar-color: #CACFD8;
          }
      
        .card-scrollbar::-webkit-scrollbar {
          display: block;
          height: 4px;
          width: 5px;
        }
      
        .card-scrollbar::-webkit-scrollbar-thumb {
          background-color: #CACFD8;
          border-radius: 3px;
        }
      
        .card-scrollbar::-webkit-scrollbar-track {
          display: none;
        }
    }`

    <>
      <style> {React.string(cardScrollbarCss)} </style>
      <div
        key={systemColumn}
        className="flex items-center gap-4 p-3 border rounded-lg border-nd_gray-150 overflow-scroll card-scrollbar">
        <div className="flex-1">
          <SelectBox.BaseDropdown
            allowMultiSelect=false
            buttonText={fileColumn}
            input={createFormInput(~name=`mapping_file_${systemColumn}`, ~value=fileColumn)}
            options=[createDropdownOption(~label=fileColumn, ~value=fileColumn)]
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
            buttonText={systemColumn}
            input={createFormInput(~name=`mapping_system_${systemColumn}`, ~value=systemColumn)}
            options=[createDropdownOption(~label=systemColumn, ~value=systemColumn)]
            hideMultiSelectButtons=true
            deselectDisable=true
            disableSelect=true
            fullLength=true
          />
        </div>
      </div>
    </>
  }
}

module TabDetails = {
  @react.component
  let make = (~activeTab: columnMappingTabs, ~metadataSchema, ~jsonMetadataSchema) => {
    let schemaData =
      jsonMetadataSchema
      ->getDictFromJsonObject
      ->getJsonObjectFromDict("schema_data")

    <div className="overflow-scroll mt-4">
      {switch activeTab {
      | #advanced =>
        <div className="p-4">
          <div className="w-full bg-nd_gray-50 rounded-xl overflow-y-scroll py-2">
            <PrettyPrintJson jsonToDisplay={schemaData->JSON.stringify} />
          </div>
        </div>
      | #default =>
        <div className="flex flex-col gap-3 py-3 overflow-y-auto h-93-per">
          <div className="flex items-center gap-4">
            <div className="flex-1 mx-2.5">
              <p className={`${body.lg.medium} text-nd_gray-800`}>
                {"File column"->React.string}
              </p>
            </div>
            <div />
            <div className="flex-1 mx-2.5">
              <p className={`${body.lg.medium} text-nd_gray-800`}>
                {"System column"->React.string}
              </p>
            </div>
          </div>
          <div className="w-full">
            <div className="flex flex-col gap-y-4">
              {basicFieldMappingList
              ->Array.map(fieldType => {
                <FileAndSystemColumnMapping
                  fileColumn={metadataSchema.schema_data.fields->getBasicFieldIdentifier(fieldType)}
                  systemColumn={(fieldType :> string)}
                />
              })
              ->React.array}
              {metadataSchema.schema_data.fields.metadata_fields
              ->Array.map(field => {
                <FileAndSystemColumnMapping
                  fileColumn=field.identifier systemColumn={field.field_name}
                />
              })
              ->React.array}
            </div>
          </div>
        </div>
      }}
    </div>
  }
}

module ColumnMappingDisplay = {
  @react.component
  let make = (~metadataSchema: metadataSchemaType, ~jsonMetadataSchema: JSON.t) => {
    let tabList: array<Tabs.tab> = [
      {
        title: "Default",
        renderContent: () => <TabDetails activeTab=#default metadataSchema jsonMetadataSchema />,
      },
      {
        title: "Advanced",
        renderContent: () => <TabDetails activeTab=#advanced metadataSchema jsonMetadataSchema />,
      },
    ]

    <div className="px-6">
      <Tabs
        tabs=tabList
        disableIndicationArrow=true
        showBorder=false
        includeMargin=false
        lightThemeColor="black"
        defaultClasses={`font-ibm-plex w-max flex flex-auto flex-row items-center justify-center text-body ${body.md.semibold}`}
      />
    </div>
  }
}

@react.component
let make = (~showModal, ~setShowModal, ~selectedTransformationId: string) => {
  open ReconEngineUtils
  open ReconEngineHooks

  let fetchMetadataSchema = useFetchMetadataSchema()
  let (screenState, setScreenState) = React.useState(() => PageLoaderWrapper.Custom)
  let (metadataSchema, setMetadataSchema) = React.useState(_ =>
    Dict.make()->metadataSchemaItemToObjMapper
  )
  let (jsonMetadataSchema, setJsonMetadataSchema) = React.useState(_ => JSON.Encode.null)

  let fetchTransformationConfigDetails = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let jsonMetadataSchema = await fetchMetadataSchema(~transformationId=selectedTransformationId)
      setJsonMetadataSchema(_ => jsonMetadataSchema)

      let parsedMetadataSchema =
        jsonMetadataSchema
        ->getDictFromJsonObject
        ->metadataSchemaItemToObjMapper

      if parsedMetadataSchema.id->isNonEmptyString {
        setMetadataSchema(_ => parsedMetadataSchema)
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

  <Modal
    setShowModal
    showModal
    closeOnOutsideClick=true
    modalHeading="Column Mapping"
    modalHeadingDescription="Map columns from your file to the corresponding required system columns"
    modalHeadingClass={`text-nd_gray-800 ${heading.sm.semibold}`}
    modalClass="flex flex-col justify-start h-screen w-1/3 float-right overflow-hidden !bg-white"
    childClass="relative h-full">
    <PageLoaderWrapper
      screenState
      customUI={<NewAnalyticsHelper.NoData height="h-52" message="No data available." />}
      customLoader={<div className="h-full flex flex-col justify-center items-center">
        <div className="animate-spin mb-1">
          <Icon name="spinner" size=20 />
        </div>
      </div>}>
      <div className="h-full relative">
        <div className="absolute inset-0 overflow-y-auto py-2">
          <ColumnMappingDisplay metadataSchema jsonMetadataSchema />
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
