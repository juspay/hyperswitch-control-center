open RolesMatrixTypes
open RolesMatrixUtils
open Table
open Typography

module PermissionPill = {
  @react.component
  let make = (~permissionLevel: permissionLevel) => {
    let baseCss = `inline-flex items-center gap-1`
    let pillCss = `bg-nd_gray-50 text-nd_gray-500 border-nd_gray-300 rounded-lg p-2 ${body.sm.medium}`

    switch permissionLevel {
    | NoAccess =>
      <div className="flex items-center justify-left text-nd_gray-400"> {"--"->React.string} </div>
    | _ => {
        let (icon, displayText) = switch permissionLevel {
        | View => (Some("eye-outlined"), "View")
        | ViewAndEdit => (Some("new-edit"), "View & Edit")
        | NoAccess => (None, "No Access")
        }
        <div className={`${baseCss} ${pillCss}`}>
          {switch icon {
          | Some(iconName) => <Icon name=iconName size=12 />
          | None => React.null
          }}
          {displayText->React.string}
        </div>
      }
    }
  }
}

let makeHeaders = (filteredRoles: array<roleData>): array<header> => {
  [
    makeHeaderInfo(~key="module_permission", ~title="Module Permission", ~customWidth="min-w-80"),
    ...filteredRoles->Array.map(role => {
      makeHeaderInfo(~key=role.roleId, ~title=role.roleName, ~customWidth="min-w-40")
    }),
  ]
}

let makeRows = (matrixData: matrixData, filteredRoles: array<roleData>): array<array<cell>> => {
  matrixData.modules->Array.map(moduleName => {
    let moduleDescription = getModuleDescription(moduleName, matrixData.roles)
    let modulePermissions = matrixData.permissions->Dict.get(moduleName)->Option.getOr(Dict.make())
    let moduleCell = CustomCell(
      <div className="flex flex-col min-w-80">
        <span className={`${body.md.semibold}  text-nd_gray-600`}>
          {moduleName->React.string}
        </span>
        <span className={`${body.sm.medium} text-nd_gray-400 mt-1`}>
          {moduleDescription->React.string}
        </span>
      </div>,
      "",
    )

    let permissionCells = filteredRoles->Array.map(role => {
      let permissionLevel = modulePermissions->Dict.get(role.roleId)->Option.getOr(NoAccess)
      CustomCell(<PermissionPill permissionLevel />, "")
    })

    [moduleCell, ...permissionCells]
  })
}
