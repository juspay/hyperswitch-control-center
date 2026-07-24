open Typography
open ReconEngineTypes

@react.component
let make = (
  ~showModal: bool,
  ~setShowModal: (bool => bool) => unit,
  ~selectedTransformation: transformationHistoryType,
  ~accountData: array<accountType>,
) => {
  open ReconEngineHooks
  open LogicUtils
  open ReconEngineUtils
  open ReconEnginePipelinesUtils
  open ReconEnginePipelinesHelper
  open APIUtils

  let fetchMetadataSchema = useFetchMetadataSchema()
  let getURL = useGetURL()
  let fetchTransformationConfigDetails = useGetMethod()

  let (screenState, setScreenState) = React.useState(() => PageLoaderWrapper.Custom)
  let (metadataSchema, setMetadataSchema) = React.useState(_ =>
    Dict.make()->metadataSchemaItemToObjMapper
  )
  let (transformationConfig, setTransformationConfig) = React.useState(_ =>
    Dict.make()->transformationConfigItemToObjMapper
  )

  let fetchDetails = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let jsonMetadataSchema = await fetchMetadataSchema(
        ~transformationId=selectedTransformation.transformation_id,
      )
      let jsonTransformationConfig = await fetchTransformationConfigDetails(
        getURL(
          ~entityName=V1(HYPERSWITCH_RECON),
          ~methodType=Get,
          ~hyperswitchReconType=#TRANSFORMATION_CONFIG,
          ~id=Some(selectedTransformation.transformation_id),
        ),
      )

      let parsedMetadataSchema =
        jsonMetadataSchema->getDictFromJsonObject->metadataSchemaItemToObjMapper
      let parsedTransformationConfig =
        jsonTransformationConfig
        ->getDictFromJsonObject
        ->transformationConfigItemToObjMapper

      if parsedMetadataSchema.id->isNonEmptyString {
        setMetadataSchema(_ => parsedMetadataSchema)
        setTransformationConfig(_ => parsedTransformationConfig)
        setScreenState(_ => PageLoaderWrapper.Success)
      } else {
        setScreenState(_ => PageLoaderWrapper.Custom)
      }
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Custom)
    }
  }

  React.useEffect(() => {
    if showModal && selectedTransformation.transformation_id->isNonEmptyString {
      fetchDetails()->ignore
    }
    None
  }, [selectedTransformation.transformation_id])

  let accountName = ReconEnginePipelinesTableEntity.getAccountName(
    ~accountData,
    selectedTransformation.account_id,
  )

  let skipConditions =
    transformationConfig.config
    ->getDictFromJsonObject
    ->getArrayFromDict("skip_configs", [])
    ->Array.map(getDictFromJsonObject)
    ->Array.flatMap(skipConfig =>
      skipConfig->getArrayFromDict("conditions", [])->Array.map(getDictFromJsonObject)
    )

  let parsingConfig =
    transformationConfig.config
    ->getDictFromJsonObject
    ->getDictfromDict("parsing_config")
    ->parsingConfigMapper

  let (fileFormatLabel, headerRowLabel, sheetLabel) = switch parsingConfig {
  | CsvParsingConfig => ("CSV", "—", "")
  | XlsxParsingConfig({headerRowIndex, sheetSelection}) => (
      "XLSX",
      headerRowIndex->Int.toString,
      switch sheetSelection {
      | ByName(name) => name
      | ByIndex(index) => `Sheet ${index->Int.toString}`
      | UnknownSheetSelection => ""
      },
    )
  | FixedWidthParsingConfig => ("FIXED WIDTH", "—", "")
  | UnknownParsingConfig => ("—", "—", "")
  }

  <Modal
    setShowModal
    showModal
    closeOnOutsideClick=true
    modalHeading="Transformation run"
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
        <div className="absolute inset-0 overflow-y-auto px-6 py-5 pb-16">
          <div className="flex flex-col gap-5">
            <div className="flex flex-col gap-1.5">
              <div className="flex items-center gap-2 flex-wrap">
                <p className={`${body.sm.semibold} text-nd_gray-800 break-words`}>
                  {selectedTransformation.transformation_name->React.string}
                </p>
                <TableUtils.LabelCell
                  labelColor={switch selectedTransformation.status {
                  | Processed => LabelGreen
                  | Failed => LabelRed
                  | Processing => LabelOrange
                  | Pending => LabelYellow
                  | Discarded | UnknownIngestionTransformationStatus => LabelGray
                  }}
                  text={(selectedTransformation.status :> string)->capitalizeString}
                />
                <RenderIf condition={metadataSchema.schema_data.processing_mode->isNonEmptyString}>
                  <span
                    className={`${body.xs.semibold} uppercase bg-nd_primary_blue-50 text-nd_primary_blue-600 rounded px-1.5 py-0.5`}>
                    {metadataSchema.schema_data.processing_mode->React.string}
                  </span>
                </RenderIf>
              </div>
              <div className={`flex items-center gap-1.5 ${body.xs.regular} text-nd_gray-500`}>
                <span> {"writes into"->React.string} </span>
                <Icon name="nd-arrow-right" size=10 className="text-nd_gray-300" />
                <span className={`${body.xs.medium} text-nd_gray-700`}>
                  {accountName->React.string}
                </span>
              </div>
            </div>
            <div
              className="border border-nd_gray-150 rounded-lg flex divide-x divide-nd_gray-150 overflow-hidden">
              <FunnelStat label="Total" value=selectedTransformation.data.total_count />
              <FunnelStat
                label="Transformed"
                value=selectedTransformation.data.transformed_count
                valueColor="text-nd_green-400"
              />
              <FunnelStat
                label="Ignored"
                value=selectedTransformation.data.ignored_count
                valueColor={selectedTransformation.data.ignored_count > 0
                  ? "text-nd_orange-600"
                  : "text-nd_gray-800"}
              />
              <FunnelStat
                label="Errors"
                value={selectedTransformation.data.errors->Array.length}
                valueColor={selectedTransformation.data.errors->isNonEmptyArray
                  ? "text-nd_red-500"
                  : "text-nd_gray-800"}
              />
            </div>
            <div className="flex flex-col gap-2">
              <MetaRow
                label="Started"
                value={<TableUtils.DateCell
                  timestamp=selectedTransformation.created_at
                  isCard=true
                  hideTimeZone=true
                  textStyle={`${body.sm.medium} text-nd_gray-700`}
                />}
              />
              <MetaRow
                label="Finished"
                value={selectedTransformation.processed_at->isNonEmptyString
                  ? <TableUtils.DateCell
                      timestamp=selectedTransformation.processed_at
                      isCard=true
                      hideTimeZone=true
                      textStyle={`${body.sm.medium} text-nd_gray-700`}
                    />
                  : <span className={`${body.sm.medium} text-nd_gray-700`}>
                      {"—"->React.string}
                    </span>}
              />
              <MetaRow
                label="Duration"
                value={formatDuration(
                  selectedTransformation.created_at,
                  selectedTransformation.processed_at,
                )->React.string}
              />
              <MetaRow
                label="Run ID"
                value={<span className="font-mono text-xs">
                  {selectedTransformation.transformation_history_id->React.string}
                </span>}
              />
            </div>
            <div className="h-px bg-nd_gray-150" />
            <RenderIf condition={selectedTransformation.data.errors->isNonEmptyArray}>
              <div className="flex flex-col gap-2">
                <SectionTitle count={selectedTransformation.data.errors->Array.length}>
                  {"Errors"->React.string}
                </SectionTitle>
                <div className="flex flex-col gap-1.5">
                  {selectedTransformation.data.errors
                  ->Array.mapWithIndex((error, index) =>
                    <div
                      key={index->Int.toString}
                      className={`${body.xs.regular} bg-nd_red-50 border border-nd_red-100 rounded-lg px-2.5 py-1.5 text-nd_red-600 break-words`}>
                      {error->React.string}
                    </div>
                  )
                  ->React.array}
                </div>
              </div>
            </RenderIf>
            <div className="flex flex-col gap-2">
              <SectionTitle> {"Parsing"->React.string} </SectionTitle>
              <div className="flex flex-col gap-1.5">
                <MetaRow label="Format" value={fileFormatLabel->React.string} />
                <MetaRow label="Header row" value={headerRowLabel->React.string} />
                <RenderIf condition={sheetLabel->isNonEmptyString}>
                  <MetaRow label="Sheet" value={sheetLabel->React.string} />
                </RenderIf>
                <MetaRow
                  label="Unique key"
                  value={(
                    metadataSchema.schema_data.unique_constraint.description->isNonEmptyString
                      ? metadataSchema.schema_data.unique_constraint.description
                      : "—"
                  )->React.string}
                />
              </div>
            </div>
            <div className="flex flex-col gap-2">
              <SectionTitle count={skipConditions->Array.length}>
                {"Skip rules"->React.string}
              </SectionTitle>
              {skipConditions->isEmptyArray
                ? <p className={`${body.xs.regular} text-nd_gray-500`}>
                    {"No rows skipped — every parsed row is mapped."->React.string}
                  </p>
                : <div className="flex flex-col gap-1.5">
                    {skipConditions
                    ->Array.mapWithIndex((condition, index) =>
                      <div
                        key={index->Int.toString}
                        className={`${body.xs.regular} bg-nd_gray-50 border border-nd_gray-150 rounded-lg px-2.5 py-1.5 text-nd_gray-700 break-words`}>
                        {describeSkipCondition(condition)->React.string}
                      </div>
                    )
                    ->React.array}
                  </div>}
            </div>
            <div className="flex flex-col gap-2">
              <SectionTitle
                count={metadataSchema.schema_data.fields->getDisplayFields->Array.length}>
                {"Fields & rules"->React.string}
              </SectionTitle>
              <div className="border border-nd_gray-150 rounded-lg overflow-hidden">
                {metadataSchema.schema_data.fields
                ->getDisplayFields
                ->Array.map(field => <FieldRow key={field.target} field />)
                ->React.array}
              </div>
            </div>
          </div>
        </div>
        <div className="absolute bottom-0 left-0 right-0 bg-white p-4 border-t border-nd_gray-150">
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
