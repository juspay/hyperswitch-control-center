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
              labelMargin="!py-0"
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
    ~accountData=Dict.make()->ReconEngineAccountsUtils.getAccountPayloadFromDict,
  ) => {
    <div
      className={`flex ${customFlex} justify-start dark:bg-jp-gray-lightgray_background dark:border-jp-gray-no_data_border`}>
      {detailsFields
      ->Array.map(colType => {
        <div className=widthClass key={LogicUtils.randomString(~length=10)}>
          <DisplayKeyValueParams heading={getHeading(colType)} value={getCell(data, colType)} />
        </div>
      })
      ->React.array}
      <RenderIf condition={accountData.account_name->LogicUtils.isNonEmptyString}>
        <div className=widthClass>
          <DisplayKeyValueParams
            heading={Table.makeHeaderInfo(~key="account_name", ~title="Account Name")}
            value={Text(accountData.account_name)}
          />
        </div>
      </RenderIf>
    </div>
  }
}

module IngestionHistoryDetailsInfo = {
  open ReconEngineFileManagementTypes
  open ReconEngineFileManagementEntity

  @react.component
  let make = (~ingestionHistoryData: ingestionHistoryType, ~detailsFields) => {
    <div className="w-full border border-nd_gray-150 rounded-lg px-4 py-2 mt-2">
      <HistoryDetails
        data=ingestionHistoryData
        getHeading=getIngestionHistoryHeading
        getCell=getIngestionHistoryCell
        detailsFields
        widthClass="lg:w-1/4 md:w-1/3 w-1/2"
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
    ~accountData: ReconEngineTypes.accountType,
    ~ingestionHistoryData: ingestionHistoryType,
  ) => {
    let onClick = () => {
      RescriptReactRouter.push(
        GlobalVars.appendDashboardPath(
          ~url=`/v1/recon-engine/file-management/${ingestionHistoryData.id}/transformation-history/${transformationHistoryData.transformation_history_id}`,
        ),
      )
    }

    <div className="border border-nd_gray-150 rounded-lg p-3">
      <div
        className="flex flex-row flex-wrap gap-8 justify-start items-start dark:bg-jp-gray-lightgray_background dark:border-jp-gray-no_data_border">
        {detailsFields
        ->Array.map(colType => {
          <div className="flex-1 min-w-0" key={LogicUtils.randomString(~length=10)}>
            <DisplayKeyValueParams
              heading={getTransformationHistoryHeading(colType)}
              value={getTransformationHistoryCell(transformationHistoryData, colType)}
            />
          </div>
        })
        ->React.array}
        <RenderIf condition={accountData.account_name->LogicUtils.isNonEmptyString}>
          <div className="flex-1 min-w-0">
            <DisplayKeyValueParams
              heading={Table.makeHeaderInfo(~key="account_name", ~title="Account Name")}
              value={Text(accountData.account_name)}
            />
          </div>
        </RenderIf>
        <RenderIf condition={transformationHistoryData.status->statusMapper == Processed}>
          <div className="flex-1 min-w-0">
            <div className="flex flex-col gap-2">
              <div className="h-4" />
              <div className="text-left">
                <Button
                  text="View"
                  buttonType=Secondary
                  buttonState=Normal
                  buttonSize=Small
                  customButtonStyle="!w-fit"
                  onClick={_ => onClick()}
                />
              </div>
            </div>
          </div>
        </RenderIf>
      </div>
    </div>
  }
}
