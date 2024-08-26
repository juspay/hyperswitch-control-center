let h2OptionalStyle = HSwitchUtils.getTextClass((H2, Optional))

module TableRowForUserDetails = {
  @react.component
  let make = (
    ~arrayValue: array<UserManagementTypes.userDetailstype>,
    ~merchantName,
    ~parentIndex,
  ) => {
    let (showModal, setShowModal) = React.useState(_ => false)

    let tableElementCss = "table-cell text-left h-fit w-fit p-4"
    let noOfElementsForMerchants = arrayValue->Array.length
    let borderStyle = index =>
      noOfElementsForMerchants - 1 == index && parentIndex != 2 ? "border-b" : ""

    arrayValue
    ->Array.mapWithIndex((value, index) => {
      let (statusValue, statusColor) = value.status->UserUtils.getLabelForStatus

      <tr className={`${index->borderStyle}`}>
        <RenderIf condition={index == 0}>
          <td
            className={`${tableElementCss} align-top pt-4 font-semibold`}
            rowSpan={noOfElementsForMerchants}>
            {merchantName->LogicUtils.capitalizeString->React.string}
          </td>
        </RenderIf>
        <td className=tableElementCss> {value.profile.name->React.string} </td>
        <td className=tableElementCss> {value.roleId->React.string} </td>
        <td className=tableElementCss>
          <p className={`${statusColor} px-4 py-1 w-fit rounded-full`}>
            {(statusValue :> string)->React.string}
          </p>
        </td>
        <td className={`${tableElementCss} text-right`}>
          <Button
            text="Manage user"
            customButtonStyle="!p-2 !bg-white "
            onClick={_ => setShowModal(_ => true)}
          />
        </td>
        <ManageUserModal showModal setShowModal />
      </tr>
    })
    ->React.array
  }
}

module UserAccessInfo = {
  @react.component
  let make = (~userData: Dict.t<array<UserManagementTypes.userDetailstype>>) => {
    let tableHeaderCss = "table-cell text-left py-2 px-4 text-sm font-normal text-gray-400"

    let getObjectForThekey = key =>
      switch userData->Dict.get(key) {
      | Some(value) => value
      | None => []
      }

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
        {userData
        ->Dict.keysToArray
        ->Array.mapWithIndex((items, parentIndex) => {
          <TableRowForUserDetails
            merchantName={items} arrayValue={items->getObjectForThekey} parentIndex
          />
        })
        ->React.array}
      </tbody>
    </table>
  }
}

module UserDetails = {
  @react.component
  let make = (~userEmail, ~userData: Dict.t<array<UserManagementTypes.userDetailstype>>) => {
    <div className="flex flex-col bg-white rounded-xl border p-6 gap-12">
      <div className="flex gap-4">
        <img alt="user_icon" src={`/icons/user_icon.svg`} className="h-16 w-16" />
        <div>
          <p className=h2OptionalStyle> {userEmail->React.string} </p>
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
  open Promise
  let url = RescriptReactRouter.useUrl()
  let userEmail =
    url.search
    ->LogicUtils.getDictFromUrlSearchParams
    ->Dict.get("email")
    ->Option.getOr("")

  let (userData, setUserData) = React.useState(_ => Dict.make())

  let userDetailsFetch = async () => {
    // TODO : add API to fetch the details of a particular user
    try {
      Fetch.fetchWithInit(
        "http://localhost:8082/get_user_details",
        Fetch.RequestInit.make(~method_=Get),
      )
      ->then(res => res->Fetch.Response.json)
      ->then(json => {
        let finalResp = json->UserUtils.valueToType
        setUserData(_ => finalResp->UserUtils.groupByMerchants)
        resolve()
      })
      ->catch(_err => {
        resolve()
      })
      ->ignore
    } catch {
    | _ => ()
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
        path=[{title: "Team management", link: "/users-revamp"}]
        currentPageTitle=userEmail
        cursorStyle="cursor-pointer"
      />
    </div>
    <UserDetails userEmail userData />
  </div>
}
