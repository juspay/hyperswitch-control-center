open FeeEstimationTypes

module AppliedFeesBreakdown = {
  open FeeEstimationEntity
  @react.component
  let make = (~appliedFeesData: breakdownItem) => {
    let (expandedRowIndexArray, setExpandedRowIndexArray) = React.useState(_ => [-1])
    let heading = feesBreakdownColumns->Array.map(getFeeBreakdownHeading)
    let rows = [
      [
        Table.CustomCell(
          <p className="text-nd_gray-700 text-sm font-medium">
            {"Interchange fees"->React.string}
          </p>,
          "",
        ),
        Table.CustomCell(
          <p className="text-nd_gray-600 text-sm font-medium">
            {`${appliedFeesData.estimateInterchangeVariableRate->Float.toString} % + ${appliedFeesData.transactionCurrency} ${appliedFeesData.estimateInterchangeFixedRate->Float.toString}`->React.string}
          </p>,
          "",
        ),
        Table.CustomCell(
          <p className="text-nd_gray-600 text-sm font-medium">
            {`${appliedFeesData.transactionCurrency} ${appliedFeesData.estimateInterchangeCost->Float.toString}`->React.string}
          </p>,
          "",
        ),
      ],
      [
        Table.CustomCell(
          <p className="text-nd_gray-700 text-sm font-medium"> {"Scheme fees"->React.string} </p>,
          "",
        ),
        Table.CustomCell(
          <p className="text-nd_gray-600 text-sm font-medium">
            {"Charged differently"->React.string}
          </p>,
          "",
        ),
        Table.CustomCell(
          <p className="text-nd_gray-600 text-sm font-medium">
            {`${appliedFeesData.transactionCurrency} ${appliedFeesData.estimateSchemeTotalCost->Float.toString}`->React.string}
          </p>,
          "",
        ),
      ],
    ]

    let collapseClick = idx => {
      let indexOfRemovalItem = expandedRowIndexArray->Array.findIndex(item => item === idx)
      setExpandedRowIndexArray(_ => {
        let array = expandedRowIndexArray->Array.map(item => item)
        array->Array.splice(~start=indexOfRemovalItem, ~remove=1, ~insert=[])
        array
      })
    }

    let onExpandClick = idx => {
      if idx > 0 {
        setExpandedRowIndexArray(_ => {
          [idx]
        })
      }
    }

    let onExpandIconClick = (isCurrentRowExpanded, rowIndex) => {
      if isCurrentRowExpanded {
        collapseClick(rowIndex)
      } else {
        onExpandClick(rowIndex)
      }
    }

    let rowsSchemeBreakdown =
      <React.Fragment>
        {appliedFeesData.estimateSchemeBreakdown
        ->Array.mapWithIndex((item, index) => {
          <tr
            key={item.feeName ++ index->Int.toString}
            className="group h-full rounded-md bg-white dark:bg-jp-gray-lightgray_background hover:bg-jp-gray-table_hover dark:hover:bg-jp-gray-100 dark:hover:bg-opacity-10 text-jp-gray-900 dark:text-jp-gray-text_darktheme text-opacity-75 dark:text-opacity-75 font-fira-code transition duration-300 ease-in-out text-sm}">
            {feesBreakdownColumns
            ->Array.map(colType => {
              <td
                key={(colType :> string)}
                className="h-full p-0 align-top border-t border-jp-gray-500 dark:border-jp-gray-960 px-4 py-3">
                {switch colType {
                | FeeType =>
                  let feeName = item.feeName->LogicUtils.snakeToTitle
                  <div className="flex items-center gap-2">
                    <Icon name="expanded-arrow-icon" size=14 />
                    <span className="text-nd_gray-600 text-sm font-medium">
                      {feeName->React.string}
                    </span>
                  </div>
                | Rate =>
                  <p className="text-nd_gray-600 text-sm font-medium">
                    {`${item.variableRate->Float.toString} % + ${appliedFeesData.transactionCurrency} ${item.cost->Float.toString}`->React.string}
                  </p>
                | TotalCost =>
                  <p className="text-nd_gray-600 text-sm font-medium">
                    {`${appliedFeesData.transactionCurrency} ${LogicUtils.valueFormatter(
                        item.cost,
                        Amount,
                      )}`->React.string}
                  </p>
                }}
              </td>
            })
            ->React.array}
          </tr>
        })
        ->React.array}
      </React.Fragment>

    let getRowDetails = _ => {
      rowsSchemeBreakdown
    }

    <CustomExpandableTable
      title="Refunds"
      heading
      rows
      onExpandIconClick
      expandedRowIndexArray
      getRowDetails
      showSerial=false
      rowComponentInCell=false
    />
  }
}

module TransactionViewSideModal = {
  @react.component
  let make = (~selectedTransaction: breakdownItem) => {
    <div className="p-2 overflow-y-auto min-h-screen">
      <div className="grid grid-cols-2 gap-y-8 justify-between">
        <div className="flex flex-col gap-1">
          <p className="text-sm text-[#717784] font-medium"> {"Payment ID"->React.string} </p>
          <p className="text-nd_gray-600 font-semibold">
            {selectedTransaction.paymentId->String.slice(~start=0, ~end=20)->React.string}
          </p>
        </div>
        <div className="flex flex-col gap-1">
          <p className="text-sm text-[#717784] font-medium"> {"Processor"->React.string} </p>
          <div className="flex items-center gap-2">
            <GatewayIcon
              gateway={selectedTransaction.connector->String.toUpperCase} className="w-5 h-5"
            />
            <p className="text-nd_gray-600 font-semibold">
              {selectedTransaction.connector->LogicUtils.camelCaseToTitle->React.string}
            </p>
          </div>
        </div>
        <div className="flex flex-col gap-1">
          <p className="text-sm text-[#717784] font-medium"> {"Type of Card"->React.string} </p>
          <p className="text-nd_gray-600 font-semibold">
            {selectedTransaction.fundingSource->LogicUtils.camelCaseToTitle->React.string}
          </p>
        </div>
        <div className="flex flex-col gap-1">
          <p className="text-sm text-[#717784] font-medium"> {"Card Brand"->React.string} </p>
          <p className="text-nd_gray-600 font-semibold">
            {selectedTransaction.cardBrand->LogicUtils.camelCaseToTitle->React.string}
          </p>
        </div>
        <div className="flex flex-col gap-1">
          <p className="text-sm text-[#717784] font-medium"> {"Regionality"->React.string} </p>
          <p className="text-nd_gray-600 font-semibold">
            {selectedTransaction.regionality->LogicUtils.camelCaseToTitle->React.string}
          </p>
        </div>
        <div className="flex flex-col gap-1">
          <p className="text-sm text-[#717784] font-medium"> {"Card Variant"->React.string} </p>
          <p className="text-nd_gray-600 font-semibold">
            {selectedTransaction.cardVariant->LogicUtils.camelCaseToTitle->React.string}
          </p>
        </div>
        <div className="flex flex-col gap-1">
          <p className="text-sm text-[#717784] font-medium">
            {"Transaction value"->React.string}
          </p>
          <p className="text-nd_gray-600 font-semibold">
            {`${selectedTransaction.transactionCurrency} ${LogicUtils.valueFormatter(
                selectedTransaction.gross,
                Amount,
              )}`->React.string}
          </p>
        </div>
        <div className="flex flex-col gap-1">
          <p className="text-sm text-[#717784] font-medium"> {"Transaction Fees"->React.string} </p>
          <p className="text-nd_gray-600 font-semibold">
            {`${selectedTransaction.transactionCurrency} ${LogicUtils.valueFormatter(
                selectedTransaction.totalCost,
                Amount,
              )}`->React.string}
          </p>
        </div>
      </div>
      <div className="flex flex-col gap-4 mt-10">
        <p className="text-nd_gray-700 font-semibold"> {"Fee Applied"->React.string} </p>
        <AppliedFeesBreakdown appliedFeesData=selectedTransaction />
      </div>
    </div>
  }
}
