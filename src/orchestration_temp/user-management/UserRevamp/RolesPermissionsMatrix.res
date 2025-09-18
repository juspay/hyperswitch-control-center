open RolesMatrixTypes
open RolesPermissionsMatrixHelper
open Table

@react.component
let make = (~matrixData: matrixData, ~filteredRoles: array<roleData>) => {
  let headers = makeHeaders(filteredRoles)
  let rows = makeRows(matrixData, filteredRoles)

  <div className="w-full overflow-hidden">
    <Table
      title="Roles Matrix"
      heading=headers
      rows
      removeVerticalLines=true
      removeHorizontalLines=false
      showAutoScroll=true
      fullWidth=true
      freezeFirstColumn=true
    />
  </div>
}
