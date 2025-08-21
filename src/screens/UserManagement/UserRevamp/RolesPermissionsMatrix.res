open RolesMatrixTypes
open RolesMatrixUtils
open Table
open Typography

module PermissionPill = {
  @react.component
  let make = (~permissionLevel: permissionLevel) => {
    switch permissionLevel {
    | NoAccess =>
      <div className="flex items-center justify-left text-nd_gray-400"> {"--"->React.string} </div>
    | _ => {
        let baseCss = `inline-flex items-center gap-1`
        let pillCss = `bg-nd_gray-50 text-nd_gray-500 border-nd_gray-300 rounded-lg p-2 ${body.sm.medium}`

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

@react.component
let make = (
  ~matrixData: matrixData,
  ~rolesData: array<roleData>,
  ~filteredRoles: array<roleData>,
) => {
  let headers = [
    makeHeaderInfo(
      ~key="module_permission",
      ~title="Module Permission",
      ~customWidth="min-w-25-rem",
    ),
    ...filteredRoles->Array.map(role => {
      makeHeaderInfo(~key=role.roleId, ~title=role.roleName, ~customWidth="min-w-40")
    }),
  ]

  let rows = matrixData.modules->Array.map(moduleName => {
    let moduleDescription = getModuleDescription(moduleName, rolesData)
    let modulePermissions = matrixData.permissions->Dict.get(moduleName)->Option.getOr(Dict.make())
    let moduleCell = CustomCell(
      <div className="flex flex-col w-80">
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

  <div className="roles-matrix-container">
    <style>
      {React.string(`
        .roles-matrix-container th:first-child,
        .roles-matrix-container .tableHeader:first-child {
          position: sticky !important;
          left: 0 !important;
          z-index: 20 !important;
          background-color: rgb(249 250 251) !important;
        }
        .roles-matrix-container td:first-child,
        .roles-matrix-container tbody tr td:first-child {
          position: sticky !important;
          left: 0 !important;
          z-index: 10 !important;
          background-color: inherit !important;
        }
        .roles-matrix-container th:first-child::after,
        .roles-matrix-container td:first-child::after {
          content: '';
          position: absolute;
          top: 0;
          right: -3px;
          bottom: 0;
          width: 2px;
          background: linear-gradient(to right, rgba(0, 0, 0, 0.05), transparent);
          pointer-events: none;
        }
      `)}
    </style>
    <Table
      title="Roles Matrix"
      heading=headers
      rows
      removeVerticalLines=true
      removeHorizontalLines=false
      showAutoScroll=true
    />
  </div>
}
