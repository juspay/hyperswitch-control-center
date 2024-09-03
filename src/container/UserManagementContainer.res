/*
This container holds the APIs needed for all user management-related modules. 
It ensures that the necessary data is available before any user management component loads.

Pre-requisite APIs :
 - ROLE_INFO : To get the list available permissions for modules 
*/

@react.component
let make = () => {
  open HSwitchUtils
  open HyperswitchAtom
  open APIUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let url = RescriptReactRouter.useUrl()
  let userPermissionJson = Recoil.useRecoilValueFromAtom(userPermissionAtom)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let setRoleInfo = Recoil.useSetRecoilState(HyperswitchAtom.moduleListRecoil)
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom

  let fetchModuleList = async () => {
    try {
      let url = getURL(
        ~entityName=USERS,
        ~userType=#ROLE_INFO,
        ~methodType=Get,
        ~queryParamerters=Some(`groups=true`),
      )
      let res = await fetchDetails(url)
      let roleInfo = res->LogicUtils.getArrayDataFromJson(UserUtils.itemToObjMapperForGetRoleInfro)
      setRoleInfo(_ => roleInfo)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error(""))
    }
  }

  React.useEffect(() => {
    fetchModuleList()->ignore
    None
  }, [userPermissionJson])

  <PageLoaderWrapper screenState={screenState} sectionHeight="!h-screen" showLogoutButton=true>
    {switch url.path->urlPath {
    // User Management modules
    | list{"users-revamp", "invite-users"} =>
      <AccessControl isEnabled={featureFlagDetails.userManagementRevamp} permission={Access}>
        <InviteMember />
      </AccessControl>
    | list{"users-revamp", ...remainingPath} =>
      <AccessControl isEnabled={featureFlagDetails.userManagementRevamp} permission={Access}>
        <EntityScaffold
          entityName="UserManagement"
          remainingPath
          renderList={_ => <UserManagementLanding />}
          renderShow={_ => <ShowUserData />}
        />
      </AccessControl>
    | list{"unauthorized"} => <UnauthorizedPage />
    | _ => <> </>
    }}
  </PageLoaderWrapper>
}
