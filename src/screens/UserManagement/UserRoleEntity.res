open LogicUtils

type role = Admin | ViewOnly | Operator | Developer | OrgAdmin | CustomerSupport | IAM | None

type userStatus = Active | InviteSent | None

type userTableTypes = {
  email: string,
  name: string,
  role_id: string,
  role_name: string,
  status: string,
}

type userColTypes =
  | Email
  | Name
  | Role
  | Status

let defaultColumnsForUser = [Name, Role, Email, Status]

let allColumnsForUser = [Name, Role, Email, Status]

type roleColTypes =
  | CreatedOn
  | Role
  | CreatedBy
  | Description
  | ActiveUsers

let itemToObjMapperForUser = dict => {
  {
    email: getString(dict, "email", ""),
    name: getString(dict, "name", ""),
    role_id: getString(dict, "role_id", ""),
    role_name: getString(dict, "role_name", ""),
    status: getString(dict, "status", ""),
  }
}

type roleListResponse = {
  role_id: string,
  role_name: string,
}

let getHeadingForUser = (colType: userColTypes) => {
  switch colType {
  | Name => Table.makeHeaderInfo(~key="name", ~title="Name", ~showSort=true, ())
  | Email => Table.makeHeaderInfo(~key="email", ~title="Email", ~showSort=true, ())
  | Role => Table.makeHeaderInfo(~key="role", ~title="Role", ~showSort=true, ())
  | Status => Table.makeHeaderInfo(~key="status", ~title="Status", ~showSort=true, ())
  }
}

let roleToVariantMapper = role => {
  switch role {
  | "ADMIN" => Admin
  | "VIEW ONLY" => ViewOnly
  | "OPERATOR" => Operator
  | "DEVELOPER" => Developer
  | "ORGANIZATION ADMIN" => OrgAdmin
  | "CUSTOMER SUPPORT" => CustomerSupport
  | "IAM" => IAM
  | _ => None
  }
}

let statusToVariantMapper = role => {
  switch role->String.toUpperCase {
  | "ACTIVE" => Active
  | "INVITATIONSENT" => InviteSent
  | _ => None
  }
}

let getCssMapperForRole = role => {
  switch role {
  | OrgAdmin
  | Admin => "border-blue-200 bg-blue-200"
  | ViewOnly
  | Developer
  | Operator
  | CustomerSupport
  | IAM => "border-light-grey bg-extra-light-grey"
  | None => ""
  }
}

let getCssMapperForStatus = status => {
  switch status {
  | Active => "text-green-700"
  | InviteSent => "text-grey-700 opacity-50"
  | None => ""
  }
}

let getCellForUser = (data: userTableTypes, colType: userColTypes): Table.cell => {
  let role_name = data.role_name->LogicUtils.snakeToTitle->String.toUpperCase
  let role = role_name->roleToVariantMapper
  let status = data.status->statusToVariantMapper
  switch colType {
  | Name => Text(data.name)
  | Email => Text(data.email)
  | Role =>
    CustomCell(
      <div
        className={`w-fit font-semibold text-sm px-3 py-1 rounded-full border-1 ${role->getCssMapperForRole}`}>
        {role_name->React.string}
      </div>,
      "",
    )
  | Status =>
    CustomCell(
      <div className={`font-semibold text-sm ${status->getCssMapperForStatus}`}>
        {switch status {
        | InviteSent => "INVITE SENT"->String.toUpperCase->React.string
        | _ => data.status->String.toUpperCase->React.string
        }}
      </div>,
      "",
    )
  }
}

let getUserData: JSON.t => array<userTableTypes> = json => {
  getArrayDataFromJson(json, itemToObjMapperForUser)
}

let userEntity = EntityType.makeEntity(
  ~uri="",
  ~getObjects=getUserData,
  ~defaultColumns=defaultColumnsForUser,
  ~allColumns=allColumnsForUser,
  ~getHeading=getHeadingForUser,
  ~getCell=getCellForUser,
  ~dataKey="",
  ~getShowLink=userId =>
    HSwitchGlobalVars.appendDashboardPath(~url=`/users/details?email=${userId.email}`),
  (),
)
