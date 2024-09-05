let p1MediumTextClass = HSwitchUtils.getTextClass((P1, Medium))
let p2MediumTextClass = HSwitchUtils.getTextClass((P2, Medium))
let p3MediumTextClass = HSwitchUtils.getTextClass((P3, Medium))
let p3RegularTextClass = HSwitchUtils.getTextClass((P3, Regular))

module ModulePermissionRender = {
  @react.component
  let make = (~elem: UserManagementTypes.userModuleType, ~index, ~customCss="") => {
    open UserUtils

    let iconForAccess = access =>
      switch access->stringToVariantMapperForAccess {
      | View => "eye-outlined"
      | Manage => "pencil-outlined"
      }

    <div key={index->Int.toString} className={`flex justify-between ${customCss}`}>
      <div className="flex flex-col gap-2 basis-3/5 ">
        <p className=p2MediumTextClass> {elem.parentGroup->React.string} </p>
        <p className=p3RegularTextClass> {elem.description->React.string} </p>
      </div>
      <div className="flex gap-2 h-fit">
        {elem.groups
        ->Array.map(item => {
          <p
            className={`py-0.5 px-2 rounded-full bg-gray-200 ${p3RegularTextClass} flex gap-1 items-center`}>
            <Icon name={item->iconForAccess} size=12 />
            <span> {(item :> string)->React.string} </span>
          </p>
        })
        ->React.array}
      </div>
    </div>
  }
}
module RoleToPermission = {
  @react.component
  let make = (~roleDict, ~role) => {
    open LogicUtils
    let userAcessGroup = roleDict->getDictfromDict(role)->getStrArrayFromDict("groups", [])
    let roleInfo = Recoil.useRecoilValueFromAtom(HyperswitchAtom.moduleListRecoil)
    let (modulesWithAccess, moduleWithoutAccess) = UserUtils.modulesWithUserAccess(
      roleInfo,
      userAcessGroup,
    )

    <div className="flex flex-col gap-8">
      {modulesWithAccess
      ->Array.mapWithIndex((elem, index) => {
        <ModulePermissionRender elem index />
      })
      ->React.array}
      {moduleWithoutAccess
      ->Array.mapWithIndex((elem, index) => {
        <ModulePermissionRender elem index customCss="text-grey-200" />
      })
      ->React.array}
    </div>
  }
}

module NoteComponent = {
  @react.component
  let make = () => {
    let {userInfo: {orgId, merchantId, profileId, userEntity}} = React.useContext(
      UserInfoProvider.defaultContext,
    )

    // TODO : Chnage id to name once backend starts sending name in userinfo
    let descriptionBasedOnEntity = switch userEntity {
    | #Organization =>
      `You can only invite people for ${orgId} here. To invite users to another organisation, please switch the organisation.`
    | #Merchant =>
      `You can only invite people for ${merchantId} here. To invite users to another merchant, please switch the merchant.`
    | #Profile =>
      `You can only invite people for ${profileId} here. To invite users to another profile, please switch the profile.`
    | _ => ""
    }

    <div className="flex gap-2 items-start justify-start">
      <Icon name="info-vacent" size=18 customIconColor="!text-gray-400" />
      <span className={`${p3RegularTextClass} text-gray-500`}>
        {descriptionBasedOnEntity->React.string}
      </span>
    </div>
  }
}

@react.component
let make = () => {
  open APIUtils
  open LogicUtils
  open UserUtils
  open UserManagementHelper

  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let (roleDict, setRoleDict) = React.useState(_ => Dict.make())
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let roleTypeValue =
    ReactFinalForm.useField(`role_id`).input.value->getStringFromJson("")->getNonEmptyString
  let (options, setOptions) = React.useState(_ => []->SelectBox.makeOptions)
  let (dropDownLoaderState, setDropDownLoaderState) = React.useState(_ =>
    DropdownWithLoading.Success
  )

  let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
    ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
  )

  let getMemberAcessBasedOnRole = async _ => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(
        ~entityName=USER_MANAGEMENT,
        ~userRoleTypes=ROLE_ID,
        ~id=roleTypeValue,
        ~methodType=Get,
        ~queryParamerters=Some("groups=true"),
      )
      let res = await fetchDetails(url)
      setRoleDict(prevDict => {
        prevDict->Dict.set(roleTypeValue->Option.getOr(""), res)
        prevDict
      })

      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
        setScreenState(_ => PageLoaderWrapper.Error(err))
      }
    }
  }

  React.useEffect(() => {
    if roleTypeValue->Option.isSome {
      getMemberAcessBasedOnRole()->ignore
    }
    None
  }, [roleTypeValue])

  let onClickDropDownApi = async () => {
    try {
      setDropDownLoaderState(_ => DropdownWithLoading.Loading)

      let roleEntity = formState.values->getDictFromJsonObject->getEntityType

      let url = getURL(
        ~entityName=USERS,
        ~userType=#LIST_ROLES_FOR_INVITE,
        ~methodType=Get,
        ~queryParamerters=Some(`entity_type=${roleEntity}`),
      )
      let result = await fetchDetails(url)
      setOptions(_ => result->makeSelectBoxOptions)
      if result->getArrayFromJson([])->Array.length > 0 {
        setDropDownLoaderState(_ => DropdownWithLoading.Success)
      } else {
        setDropDownLoaderState(_ => DropdownWithLoading.NoData)
      }
    } catch {
    | _ => setDropDownLoaderState(_ => DropdownWithLoading.NoData)
    }
  }

  <div className="flex flex-col">
    <div className="grid grid-cols-6 gap-6 items-end p-6 !pb-10 border-b">
      <div className="col-span-5 w-full">
        <FormRenderer.FieldRenderer
          field=inviteEmail labelClass="!text-black !text-base !-ml-[0.5px]"
        />
      </div>
      <div className="col-span-1 w-full p-1">
        <FormRenderer.SubmitButton
          text={"Send Invite"}
          loadingText="Loading..."
          buttonSize={Small}
          customSumbitButtonStyle="w-full !h-12"
          tooltipForWidthClass="w-full"
        />
      </div>
    </div>
    <div className="grid grid-cols-5">
      <div className="col-span-2 border-r p-6  flex flex-col gap-2">
        <OrganisationSelection />
        <MerchantSelection />
        <ProfileSelection />
        <DropdownWithLoading
          options onClickDropDownApi formKey="role_id" dropDownLoaderState isRequired=true
        />
        <NoteComponent />
        <FormValuesSpy />
      </div>
      <div className="p-6 flex flex-col gap-2 col-span-3">
        {switch roleTypeValue {
        | Some(role) =>
          <>
            <p className={`${p1MediumTextClass} !font-semibold py-2`}>
              {`Role Description - '${role->snakeToTitle}'`->React.string}
            </p>
            <PageLoaderWrapper screenState>
              <div className="border rounded-md p-4 flex flex-col">
                <RoleToPermission roleDict role={roleTypeValue->Option.getOr("")} />
              </div>
            </PageLoaderWrapper>
          </>
        | None =>
          <>
            <p className={`${p1MediumTextClass} !font-semibold`}>
              {"Role Description"->React.string}
            </p>
            <p className={`${p3RegularTextClass} text-gray-400`}>
              {"Choose a role to see its description"->React.string}
            </p>
          </>
        }}
      </div>
    </div>
  </div>
}
