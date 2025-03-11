open VaultCustomersType

let defaultColumns = [CustomerId, Name, Email, PhoneCountryCode, Phone, Description, CreatedAt]

let allColumns = [CustomerId, Name, Email, Phone, PhoneCountryCode, Description, Address, CreatedAt]

let getHeading = colType => {
  switch colType {
  | CustomerId => Table.makeHeaderInfo(~key="id", ~title="Customer Id")
  | Name => Table.makeHeaderInfo(~key="name", ~title="Customer Name")
  | Email => Table.makeHeaderInfo(~key="email", ~title="Email")
  | PhoneCountryCode => Table.makeHeaderInfo(~key="phone_country_code", ~title="Phone Country Code")
  | Phone => Table.makeHeaderInfo(~key="phone", ~title="Phone")
  | Description => Table.makeHeaderInfo(~key="description", ~title="Description")
  | Address => Table.makeHeaderInfo(~key="address", ~title="Address")
  | CreatedAt => Table.makeHeaderInfo(~key="created_at", ~title="Created")
  }
}

let getCell = (customersData, colType): Table.cell => {
  switch colType {
  | CustomerId =>
    CustomCell(
      <HSwitchOrderUtils.CopyLinkTableCell
        url={`/customers/${customersData.id}`}
        displayValue={customersData.id}
        copyValue={Some(customersData.id)}
      />,
      "",
    )
  | Name => Text(customersData.name)
  | Email => Text(customersData.email)
  | Phone => Text(customersData.phone)
  | PhoneCountryCode => Text(customersData.phone_country_code)
  | Description => Text(customersData.description)
  | Address => Date(customersData.address)
  | CreatedAt => Date(customersData.created_at)
  }
}

let vaultCustomersMapDefaultCols = Recoil.atom("vaultCustomersMapDefaultCols", defaultColumns)

let itemToObjMapper = dict => {
  open LogicUtils
  {
    id: dict->getString("id", ""),
    name: dict->getString("name", ""),
    email: dict->getString("email", ""),
    phone: dict->getString("phone", ""),
    phone_country_code: dict->getString("phone_country_code", ""),
    description: dict->getString("description", ""),
    address: dict->getString("address", ""),
    created_at: dict->getString("created_at", ""),
    metadata: dict->getJsonObjectFromDict("metadata"),
  }
}
let getArrayOfCustomerListPayloadType = json => {
  json->Array.map(reportJson => {
    reportJson->LogicUtils.getDictFromJsonObject->itemToObjMapper
  })
}

let getCustomers: JSON.t => array<customers> = json => {
  open LogicUtils
  getArrayDataFromJson(json, itemToObjMapper)
}

let customersEntity = EntityType.makeEntity(
  ~uri="",
  ~getObjects=getCustomers,
  ~defaultColumns,
  ~allColumns,
  ~getHeading,
  ~getCell,
  ~dataKey="",
  ~getShowLink={
    customerData =>
      GlobalVars.appendDashboardPath(~url=`/v2/vault/customers-tokens/${customerData.id}`)
  },
)
