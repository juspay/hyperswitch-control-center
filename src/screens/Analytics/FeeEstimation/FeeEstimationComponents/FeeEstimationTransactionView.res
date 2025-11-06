open FeeEstimationTypes
open LogicUtils
open Typography
open FeeEstimationEntity
open FeeEstimationHelper
open FeeEstimationUtils
open CurrencyFormatUtils

module ExpandedTableCustom = {
  @react.component
  let make = (~appliedFeesData, ~feesBreakdownColumns) => {
    <React.Fragment>
      {appliedFeesData.estimateSchemeBreakdown
      ->Array.map(item => {
        <tr
          key={randomString(~length=10)}
          className={`group h-full rounded-md bg-white dark:bg-jp-gray-lightgray_background hover:bg-jp-gray-table_hover dark:hover:bg-jp-gray-100 dark:hover:bg-opacity-10 text-jp-gray-900 dark:text-jp-gray-text_darktheme text-opacity-75 dark:text-opacity-75 font-fira-code transition duration-300 ease-in-out ${body.md.medium}`}>
          {feesBreakdownColumns
          ->Array.map(colType => {
            <td
              key={randomString(~length=10)}
              className="h-full p-0 align-top border-t border-jp-gray-500 dark:border-jp-gray-960 px-4 py-3">
              {switch colType {
              | FeeType =>
                let feeName = item.feeName->snakeToTitle
                <div className="flex items-center gap-2">
                  <Icon name="expanded-arrow-icon" size=14 />
                  <span className={`text-nd_gray-600 ${body.md.medium}`}>
                    {feeName->React.string}
                  </span>
                </div>
              | Rate =>
                <p className={`text-nd_gray-600 ${body.md.medium}`}>
                  {`${item.variableRate->Float.toString} % + ${appliedFeesData.transactionCurrency} ${item.cost->Float.toString}`->React.string}
                </p>
              | TotalCost =>
                <p className={`text-nd_gray-600 ${body.md.medium}`}>
                  {`${appliedFeesData.transactionCurrency} ${valueFormatter(
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
  }
}

module AppliedFeesBreakdown = {
  @react.component
  let make = (~appliedFeesData: breakdownItem) => {
    let (expandedRowIndexArray, setExpandedRowIndexArray) = React.useState(_ => [-1])
    let heading = feesBreakdownColumns->Array.map(getFeeBreakdownHeading)
    let rows = React.useMemo(() => expandedTableRows(~appliedFeesData), [appliedFeesData])

    let collapseClick = idx => {
      let indexOfRemovalItem = expandedRowIndexArray->Array.findIndex(item => item === idx)
      setExpandedRowIndexArray(prev =>
        prev->Array.filterWithIndex((_, i) => i != indexOfRemovalItem)
      )
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

    let getRowDetails = _ => {
      <ExpandedTableCustom appliedFeesData feesBreakdownColumns />
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
    let modalInfoData = modalInfoDataTransactionView(selectedTransaction)
    <div className="p-2 overflow-y-auto min-h-screen">
      <div className="grid grid-cols-2 gap-y-8 justify-between">
        <FeeEstimationHelper.ModalInfoSection modalInfoData />
      </div>
      <div className="flex flex-col gap-4 mt-10">
        <p className={`text-nd_gray-700 ${body.lg.semibold}`}> {"Fee Applied"->React.string} </p>
        <AppliedFeesBreakdown appliedFeesData=selectedTransaction />
      </div>
    </div>
  }
}
