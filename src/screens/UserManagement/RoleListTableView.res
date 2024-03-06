@react.component
let make = () => {
  open APIUtils
  open RolesEntity

  let fetchDetails = useGetMethod()
  let (screenStateRoles, setScreenStateRoles) = React.useState(_ => PageLoaderWrapper.Loading)
  let (rolesAvailableData, setRolesAvailableData) = React.useState(_ => [])
  let (rolesOffset, setRolesOffset) = React.useState(_ => 0)

  let getRolesAvailable = async () => {
    setScreenStateRoles(_ => PageLoaderWrapper.Loading)
    try {
      let userDataURL = getURL(
        ~entityName=USER_MANAGEMENT,
        ~methodType=Get,
        ~userRoleTypes=ROLE_LIST,
        (),
      )
      let res = await fetchDetails(`${userDataURL}?groups=true`)
      let rolesData = res->LogicUtils.getArrayDataFromJson(itemToObjMapperForRoles)
      setRolesAvailableData(_ => rolesData->Array.map(Nullable.make))
      setScreenStateRoles(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenStateRoles(_ => PageLoaderWrapper.Error(""))
    }
  }

  React.useEffect0(() => {
    if rolesAvailableData->Array.length == 0 {
      getRolesAvailable()->ignore
    } else {
      setScreenStateRoles(_ => PageLoaderWrapper.Success)
    }

    None
  })

  <div className="mt-5">
    <PageLoaderWrapper screenState={screenStateRoles}>
      <LoadedTable
        title="Roles"
        hideTitle=true
        actualData=rolesAvailableData
        totalResults={rolesAvailableData->Array.length}
        resultsPerPage=10
        offset=rolesOffset
        setOffset=setRolesOffset
        entity={rolesEntity}
        currrentFetchCount={rolesAvailableData->Array.length}
        showSerialNumber=true
        collapseTableRow=false
        tableheadingClass="h-12"
      />
    </PageLoaderWrapper>
  </div>
}
