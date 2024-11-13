open LogicUtils

type role = Admin | ViewOnly | Operator | Developer | OrgAdmin | CustomerSupport | IAM | None

type userStatus = Active | InviteSent | None

type rolesType = {
  role_id: string,
  role_name: string,
}

type userTableTypes = {
  email: string,
  roles: array<rolesType>,
}

type userColTypes =
  | Email
  | Role

let defaultColumnsForUser = [Email, Role]

type roleColTypes =
  | CreatedOn
  | Role
  | CreatedBy
  | Description
  | ActiveUsers

let itemToObjectMapperForRoles = dict => {
  {
    role_id: dict->getString("role_id", ""),
    role_name: dict->getString("role_name", ""),
  }
}

let itemToObjMapperForUser = dict => {
  {
    email: getString(dict, "email", ""),
    roles: dict->getJsonObjectFromDict("roles")->getArrayDataFromJson(itemToObjectMapperForRoles),
  }
}

let getHeadingForUser = (colType: userColTypes) => {
  switch colType {
  | Email => Table.makeHeaderInfo(~key="email", ~title="Email")
  | Role => Table.makeHeaderInfo(~key="role", ~title="Role")
  }
}

let customCellForRoles = listOfRoles => {
  if listOfRoles->Array.length > 1 {
    <div className="flex gap-1 items-center">
      <Icon size=18 name="person" />
      {"Multiple roles"->React.string}
    </div>
  } else {
    let firstRole = listOfRoles->LogicUtils.getValueFromArray(
      0,
      {
        role_id: "",
        role_name: "",
      },
    )

    <div className="flex gap-1 items-center">
      <Icon size=18 name="person" />
      {firstRole.role_name->LogicUtils.snakeToTitle->LogicUtils.capitalizeString->React.string}
    </div>
  }
}

let getCellForUser = (data: userTableTypes, colType: userColTypes): Table.cell => {
  switch colType {
  | Email => Text(data.email)
  | Role => CustomCell(data.roles->customCellForRoles, "")
  }
}

let getUserData: JSON.t => array<userTableTypes> = json => {
  getArrayDataFromJson(json, itemToObjMapperForUser)
}

let userEntity = EntityType.makeEntity(
  ~uri="",
  ~getObjects=getUserData,
  ~defaultColumns=defaultColumnsForUser,
  ~allColumns=defaultColumnsForUser,
  ~getHeading=getHeadingForUser,
  ~getCell=getCellForUser,
  ~dataKey="",
  ~getShowLink=userId =>
    GlobalVars.appendDashboardPath(~url=`/users/details?email=${userId.email}`),
)
