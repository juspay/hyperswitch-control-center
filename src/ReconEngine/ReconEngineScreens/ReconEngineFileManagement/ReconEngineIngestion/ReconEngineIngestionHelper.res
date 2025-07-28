open Typography

module DisplayKeyValueParams = {
  @react.component
  let make = (
    ~showTitle: bool=true,
    ~heading: Table.header,
    ~value: Table.cell,
    ~wordBreak=true,
  ) => {
    let description = heading.description->Option.getOr("")

    {
      <AddDataAttributes attributes=[("data-label", heading.title)]>
        <div className="flex flex-col gap-2 py-4">
          <div
            className="flex flex-row text-fs-11 text-nd_gray-500 text-opacity-50 dark:text-nd_gray-500 dark:text-opacity-50">
            <div className={`text-nd_gray-500 ${body.md.medium}`}>
              {React.string(showTitle ? heading.title : " x")}
            </div>
            <RenderIf condition={description->LogicUtils.isNonEmptyString}>
              <div className="text-sm text-gray-500 mx-2 -mt-1">
                <ToolTip description={description} toolTipPosition={ToolTip.Top} />
              </div>
            </RenderIf>
          </div>
          <div className={`text-left text-nd_gray-600 ${body.md.semibold}`}>
            <Table.TableCell
              cell=value
              textAlign=Table.Left
              fontBold=true
              customMoneyStyle="!font-normal !text-sm"
              labelMargin="!py-0 mt-2"
            />
          </div>
        </div>
      </AddDataAttributes>
    }
  }
}

module HistoryDetails = {
  @react.component
  let make = (
    ~data,
    ~getHeading,
    ~getCell,
    ~detailsFields,
    ~widthClass="w-1/5",
    ~customFlex="flex-wrap",
    ~accountData=Dict.make()->ReconEngineOverviewUtils.accountItemToObjMapper,
  ) => {
    <FormRenderer.DesktopRow>
      <div
        className={`flex ${customFlex} justify-start dark:bg-jp-gray-lightgray_background dark:border-jp-gray-no_data_border `}>
        {detailsFields
        ->Array.mapWithIndex((colType, i) => {
          <div className=widthClass key={i->Int.toString}>
            <DisplayKeyValueParams heading={getHeading(colType)} value={getCell(data, colType)} />
          </div>
        })
        ->React.array}
        <RenderIf condition={accountData.account_name->LogicUtils.isNonEmptyString}>
          <DisplayKeyValueParams
            heading={Table.makeHeaderInfo(~key="account_name", ~title="Account Name")}
            value={Text(accountData.account_name)}
          />
        </RenderIf>
      </div>
    </FormRenderer.DesktopRow>
  }
}

module IngestionHistoryDetailsInfo = {
  open ReconEngineFileManagementTypes
  open ReconEngineFileManagementEntity

  @react.component
  let make = (~ingestionHistoryData: ingestionHistoryType, ~detailsFields) => {
    <div className="w-full border border-nd_gray-150 rounded-lg p-2 mt-2">
      <HistoryDetails
        data=ingestionHistoryData
        getHeading=getIngestionHistoryHeading
        getCell=getIngestionHistoryCell
        detailsFields
      />
    </div>
  }
}

module TransformationHistoryDetailsInfo = {
  open ReconEngineFileManagementTypes
  open ReconEngineFileManagementUtils
  open ReconEngineFileManagementEntity

  @react.component
  let make = (
    ~transformationHistoryData: transformationHistoryType,
    ~detailsFields,
    ~accountData: ReconEngineOverviewTypes.accountType,
  ) => {
    let onClick = () => {
      RescriptReactRouter.push(
        GlobalVars.appendDashboardPath(
          ~url=`/v1/recon-engine/file-management/${transformationHistoryData.ingestion_history_id}/transformation-history/${transformationHistoryData.transformation_history_id}`,
        ),
      )
    }

    <div className="flex flex-row border border-nd_gray-150 rounded-lg items-center p-3">
      <div className="flex-[8]">
        <HistoryDetails
          data=transformationHistoryData
          getHeading=getTransformationHistoryHeading
          getCell=getTransformationHistoryCell
          detailsFields
          widthClass=""
          customFlex="flex-row lg:gap-32 md:gap-16 gap-16"
          accountData
        />
      </div>
      <RenderIf condition={transformationHistoryData.status->statusMapper == Processed}>
        <div className="flex-[1]">
          <Button
            text="View"
            buttonType=Secondary
            buttonState=Normal
            buttonSize=Small
            customButtonStyle="!w-fit"
            onClick={_ => onClick()}
          />
        </div>
      </RenderIf>
    </div>
  }
}
