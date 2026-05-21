open Table
open MerchantAcquirerDetailsTypes
open CurrencyFormatUtils

let defaultColumns = [
  Network,
  AcquirerBin,
  AcquirerIca,
  AcquirerFraudRate,
  AcquirerCountryCode,
  Update,
]

let getHeading = colType => {
  switch colType {
  | Network => makeHeaderInfo(~key="network", ~title="Network", ~dataType=TextType)
  | AcquirerBin => makeHeaderInfo(~key="acquirer_bin", ~title="Acquirer Bin", ~dataType=TextType)
  | AcquirerIca => makeHeaderInfo(~key="acquirer_ica", ~title="Acquirer ICA", ~dataType=TextType)
  | AcquirerFraudRate =>
    makeHeaderInfo(~key="acquirer_fraud_rate", ~title="Fraud rate", ~dataType=NumericType)
  | AcquirerCountryCode =>
    makeHeaderInfo(~key="acquirer_country_code", ~title="Acquirer country code", ~dataType=TextType)
  | Update => makeHeaderInfo(~key="update", ~title="", ~dataType=TextType)
  }
}

let getCellWithEdit = (
  data: BusinessProfileInterfaceTypes.acquirerNetworkEntry,
  colType,
  onEdit,
  networks: array<BusinessProfileInterfaceTypes.acquirerNetworkEntry>,
) => {
  let usaNumberAbbreviation = labelValue => {
    shortNum(~labelValue, ~numberFormat=getDefaultNumberFormat())
  }
  switch colType {
  | Network =>
    let idx = networks->Array.findIndex(n => n.network === data.network)
    CustomCell(
      <TagBinding
        text={data.network}
        color={MerchantAcquirerDetailsUtils.getNetworkTagColor(~index=idx)}
        variant=TagBinding.Subtle
        size=TagBinding.Sm
      />,
      data.network,
    )
  | AcquirerBin => Text(data.acquirer_bin)
  | AcquirerIca => Text(data.acquirer_ica->Option.getOr("-"))
  | AcquirerFraudRate => Numeric(data.acquirer_fraud_rate->Option.getOr(0.0), usaNumberAbbreviation)
  | AcquirerCountryCode => Text(data.acquirer_country_code->Option.getOr("-"))
  | Update =>
    CustomCell(
      <div className="flex gap-2 justify-end">
        <Icon
          name="edit"
          className="cursor-pointer text-blue-500 hover:text-blue-700 mr-1"
          size=16
          onClick={_ => onEdit->Option.forEach(editFn => editFn(data))}
        />
      </div>,
      "",
    )
  }
}

let makeEntityWithEditHandler = (~onEdit, ~networks) => {
  EntityType.makeEntity(
    ~uri="",
    ~getObjects=_ => [],
    ~defaultColumns,
    ~getHeading,
    ~getCell=(data, colType) => getCellWithEdit(data, colType, onEdit, networks),
    ~dataKey="",
    ~searchFields=[],
    ~searchUrl="",
  )
}
