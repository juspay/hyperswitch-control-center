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

  let fetchMetadataSchema = useFetchMetadataSchema()
  let fetchTransformationConfig = useGetTransformationConfig()

  let (screenState, setScreenState) = React.useState(() => PageLoaderWrapper.Custom)
  let (metadataSchema, setMetadataSchema) = React.useState(_ =>
    Dict.make()->metadataSchemaItemToObjMapper
  )
  let (transformationConfig, setTransformationConfig) = React.useState(_ =>
    Dict.make()->transformationConfigItemToObjMapper
  )

  let fetchDetails = async () => {
    let requestedId = selectedTransformation.transformation_id
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let metadataSchemaPromise = fetchMetadataSchema(~transformationId=requestedId)
      let transformationConfigPromise = fetchTransformationConfig(~transformationId=requestedId)
      let (jsonMetadataSchema, jsonTransformationConfig) = await Promise.all2((
        metadataSchemaPromise,
        transformationConfigPromise,
      ))

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
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to load transformation run details"))
    }
  }

  React.useEffect(() => {
    if showModal && selectedTransformation.transformation_id->isNonEmptyString {
      fetchDetails()->ignore
    }
    None
  }, (showModal, selectedTransformation.transformation_id))

  let accountName = ReconEnginePipelinesTableEntity.getAccountName(
    ~accountData,
    selectedTransformation.account_id,
  )

  let (skipConfigs, parsingConfig) = React.useMemo(() => {
    let config = transformationConfig.config->getDictFromJsonObject
    let skipConfigs =
      config->getArrayFromDict("skip_configs", [])->getMappedValueFromArrayOfJson(skipConfigMapper)
    let parsingConfig = config->getDictfromDict("parsing_config")->parsingConfigMapper

    (skipConfigs, parsingConfig)
  }, [transformationConfig])

  let (fileFormatLabel, headerRowLabel, sheetLabel) = parsingConfig->getParsingConfigLabels

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
        <div className="absolute inset-0 overflow-y-auto px-6 py-5 pb-20">
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
              <div className={`flex items-center gap-1.5 ${body.sm.regular} text-nd_gray-500`}>
                <span> {"writes into"->React.string} </span>
                <Icon name="nd-arrow-right" size=10 className="text-nd_gray-300" />
                <span className={`${body.sm.medium} text-nd_gray-700`}>
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
                value={selectedTransformation.data.failed_count}
                valueColor={selectedTransformation.data.failed_count > 0
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
                  textStyle={body.sm.medium}
                />}
              />
              <MetaRow
                label="Finished"
                value={selectedTransformation.processed_at->isNonEmptyString
                  ? <TableUtils.DateCell
                      timestamp=selectedTransformation.processed_at
                      isCard=true
                      hideTimeZone=true
                      textStyle={body.sm.medium}
                    />
                  : <span className={body.sm.medium}> {"—"->React.string} </span>}
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
                value={<span className={`${body.sm.medium}`}>
                  {selectedTransformation.transformation_history_id->React.string}
                </span>}
              />
            </div>
            <div className="h-px bg-nd_gray-150" />
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
              <SectionTitle count={skipConfigs->Array.length}>
                {"Skip rules"->React.string}
              </SectionTitle>
              {skipConfigs->isEmptyArray
                ? <p className={`${body.xs.regular} text-nd_gray-500`}>
                    {"No rows skipped — every parsed row is mapped."->React.string}
                  </p>
                : <div className="flex flex-col gap-1.5">
                    {skipConfigs
                    ->Array.mapWithIndex((skipConfig, index) =>
                      <div
                        key={index->Int.toString}
                        className={`${body.sm.regular} bg-nd_gray-50 border border-nd_gray-150 rounded-lg px-2.5 py-1.5 text-nd_gray-700 break-words`}>
                        {describeSkipConfig(skipConfig)->React.string}
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
                ->Array.mapWithIndex((field, index) =>
                  <FieldRow key={`${field.target}-${index->Int.toString}`} field />
                )
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
