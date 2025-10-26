open CustomersType

let defaultColumns = [
  CustomerId,
  Name,
  Email,
  PhoneCountryCode,
  Phone,
  Description,
  Address,
  CreatedAt,
]

let allColumns = [CustomerId, Name, Email, Phone, PhoneCountryCode, Description, Address, CreatedAt]

let getHeading = colType => {
  switch colType {
  | CustomerId => Table.makeHeaderInfo(~key="customer_id", ~title="Customer Id")
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
      <HelperComponents.CopyTextCustomComp
        customTextCss="w-36 truncate whitespace-nowrap"
        displayValue={Some(customersData.customer_id)}
        copyValue={Some(customersData.customer_id)}
      />,
      "",
    )
  | Name => Text(customersData.name)
  | Email => Text(customersData.email)
  | Phone => Text(customersData.phone)
  | PhoneCountryCode => Text(customersData.phone_country_code)
  | Description => Text(customersData.description)
  | Address => Text(customersData.address)
  | CreatedAt => Date(customersData.created_at)
  }
}

let itemToObjMapper = dict => {
  open LogicUtils
  let formatAddress = addressDict => {
    let line1 = addressDict->getString("line1", "")
    let line2 = addressDict->getString("line2", "")
    let line3 = addressDict->getString("line3", "")
    let city = addressDict->getString("city", "")
    let state = addressDict->getString("state", "")
    let country = addressDict->getString("country", "")
    let zip = addressDict->getString("zip", "")

    let addressParts =
      [line1, line2, line3, city, state, country, zip]->Array.filter(part => part->isNonEmptyString)

    addressParts->Array.joinWith(", ")
  }

  let address = switch dict->Dict.get("address") {
  | Some(addressJson) =>
    switch addressJson->JSON.Decode.object {
    | Some(addressObj) => addressObj->formatAddress
    | None => addressJson->JSON.Decode.string->Option.getOr("")
    }
  | None => ""
  }

  {
    customer_id: dict->getString("customer_id", ""),
    name: dict->getString("name", ""),
    email: dict->getString("email", ""),
    phone: dict->getString("phone", ""),
    phone_country_code: dict->getString("phone_country_code", ""),
    description: dict->getString("description", ""),
    address,
    created_at: dict->getString("created_at", ""),
    metadata: dict->getJsonObjectFromDict("metadata"),
  }
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
    customerData => GlobalVars.appendDashboardPath(~url=`/customers/${customerData.customer_id}`)
  },
)
