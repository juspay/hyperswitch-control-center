let h2OptionalStyle = HSwitchUtils.getTextClass((H2, Optional))

module UserAction = {
  @react.component
  let make = (~value: UserManagementTypes.userDetailstype) => {
    open UserManagementTypes

    let url = RescriptReactRouter.useUrl()
    let userPermissionJson = Recoil.useRecoilValueFromAtom(HyperswitchAtom.userPermissionAtom)
    let userEmail =
      url.search
      ->LogicUtils.getDictFromUrlSearchParams
      ->Dict.get("email")
      ->Option.getOr("")
    let {userInfo: {orgId, merchantId, profileId, email}} = React.useContext(
      UserInfoProvider.defaultContext,
    )

    let decideWhatToShow = {
      if userEmail === email {
        // User cannot update its own role
        NoActionAccess
      } else if userPermissionJson.usersManage === NoAccess {
        // User doesn't have user write permission
        NoActionAccess
      } else if (
        // Profile level user
        value.org.id->Option.getOr("") === orgId &&
        value.merchant.id->Option.getOr("") === merchantId &&
        value.profile.id->Option.getOr("") === profileId
      ) {
        ManageUser
      } else if (
        // Merchant level user
        value.org.id->Option.getOr("") === orgId &&
        value.merchant.id->Option.getOr("") === merchantId &&
        value.profile.id->Option.isNone
      ) {
        ManageUser
      } else if (
        // Org level user
        value.org.id->Option.getOr("") === orgId &&
        value.merchant.id->Option.isNone &&
        value.profile.id->Option.isNone
      ) {
        ManageUser
      } else {
        SwitchUser
      }
    }

    switch decideWhatToShow {
    | ManageUser => <ManageUserModal userInfoValue={value} />
    | SwitchUser => <UserManagementHelper.SwitchMerchantForUserAction userInfoValue={value} />
    | NoActionAccess => React.null
    }
  }
}

module TableRowForUserDetails = {
  @react.component
  let make = (
    ~arrayValue: array<UserManagementTypes.userDetailstype>,
    ~parentIndex,
    ~noOfElementsInParent,
  ) => {
    open LogicUtils

    let tableElementCss = "table-cell text-left h-fit w-fit p-4"
    let noOfElementsForMerchants = arrayValue->Array.length

    let borderStyle = index =>
      noOfElementsForMerchants - 1 == index && parentIndex != noOfElementsInParent - 1
        ? "border-b"
        : ""

    let cssValueWithMultipleValues = noOfElementsForMerchants > 1 ? "align-top" : "align-center"

    arrayValue
    ->Array.mapWithIndex((value, index) => {
      let (statusValue, statusColor) = value.status->UserUtils.getLabelForStatus

      let profileName = value.profile.name->isEmptyString ? value.profile.value : value.profile.name

      let merchantName =
        value.merchant.name->isEmptyString ? value.merchant.value : value.merchant.name

      <tr className={`${index->borderStyle}`}>
        <RenderIf condition={index == 0}>
          <td
            className={`${tableElementCss} ${cssValueWithMultipleValues} pt-4 font-semibold`}
            rowSpan={noOfElementsForMerchants}>
            {merchantName->capitalizeString->React.string}
          </td>
        </RenderIf>
        <td className=tableElementCss> {profileName->React.string} </td>
        <td className=tableElementCss>
          {value.roleId->snakeToTitle->capitalizeString->React.string}
        </td>
        <td className=tableElementCss>
          <p className={`${statusColor} px-4 py-1 w-fit rounded-full`}>
            {(statusValue :> string)->React.string}
          </p>
        </td>
        <td className={`${tableElementCss} text-right`}>
          <UserAction value />
        </td>
      </tr>
    })
    ->React.array
  }
}

module UserAccessInfo = {
  @react.component
  let make = (~userData: array<UserManagementTypes.userDetailstype>) => {
    let tableHeaderCss = "table-cell text-left py-2 px-4 text-sm font-normal text-gray-400"
    let groupByMerchantData = userData->UserUtils.groupByMerchants

    let getObjectForThekey = key =>
      switch groupByMerchantData->Dict.get(key) {
      | Some(value) => value
      | None => []
      }

    let noOfElementsInParent =
      groupByMerchantData
      ->Dict.keysToArray
      ->Array.length

    <table>
      <thead className="border-b">
        <tr className="p-4">
          <th className={`${tableHeaderCss} w-[15%]`}> {"Merchants"->React.string} </th>
          <th className={`${tableHeaderCss} w-[15%]`}> {"Profile Name"->React.string} </th>
          <th className={`${tableHeaderCss} w-[30%]`}> {"Role"->React.string} </th>
          <th className={`${tableHeaderCss} w-[20%]`}> {"Status"->React.string} </th>
          <th className={`${tableHeaderCss} w-[10%]`}> {""->React.string} </th>
        </tr>
      </thead>
      <tbody>
        {groupByMerchantData
        ->Dict.keysToArray
        ->Array.mapWithIndex((items, parentIndex) => {
          <TableRowForUserDetails
            arrayValue={items->getObjectForThekey} parentIndex noOfElementsInParent
          />
        })
        ->React.array}
      </tbody>
    </table>
  }
}

module UserDetails = {
  @react.component
  let make = (~userData: array<UserManagementTypes.userDetailstype>) => {
    open LogicUtils
    let url = RescriptReactRouter.useUrl()
    let userEmail =
      url.search
      ->getDictFromUrlSearchParams
      ->Dict.get("email")
      ->Option.getOr("")

    <div className="flex flex-col bg-white rounded-xl border p-6 gap-12">
      <div className="flex gap-4">
        <img alt="user_icon" src={`/icons/user_icon.svg`} className="h-16 w-16" />
        <div>
          <p className=h2OptionalStyle> {userEmail->getNameFromEmail->React.string} </p>
          <p className="text-grey-600 opacity-40"> {userEmail->React.string} </p>
        </div>
      </div>
      <i className="font-semibold text-gray-400">
        {"*Some roles are profile specific and may not be available for all profiles"->React.string}
      </i>
      <UserAccessInfo userData />
    </div>
  }
}
@react.component
let make = () => {
  open APIUtils
  open LogicUtils
  open UserUtils
  let getURL = useGetURL()
  let updateMethod = useUpdateMethod()
  let url = RescriptReactRouter.useUrl()
  let userEmail =
    url.search
    ->getDictFromUrlSearchParams
    ->Dict.get("email")
    ->Option.getOr("")
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (userData, setUserData) = React.useState(_ => JSON.Encode.null->valueToType)

  let userDetailsFetch = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(~entityName=USERS, ~userType=#USER_DETAILS, ~methodType=Post)
      let body = [("email", userEmail->JSON.Encode.string)]->getJsonFromArrayOfJson
      let response = await updateMethod(url, body, Post)
      setUserData(_ => response->valueToType)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Failed to fetch user details!"))
    }
  }

  React.useEffect(() => {
    userDetailsFetch()->ignore
    None
  }, [])

  <div className="flex flex-col overflow-y-scroll gap-12">
    <div className="flex flex-col gap-2">
      <PageUtils.PageHeading title={"Team management"} />
      <BreadCrumbNavigation
        path=[{title: "Team management", link: "/users"}]
        currentPageTitle=userEmail
        cursorStyle="cursor-pointer"
      />
    </div>
    <PageLoaderWrapper screenState>
      <UserDetails userData />
    </PageLoaderWrapper>
  </div>
}
