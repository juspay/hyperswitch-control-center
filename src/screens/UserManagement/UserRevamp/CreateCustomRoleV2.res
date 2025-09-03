open LogicUtils
open Typography
open UserManagementUtils
open UserManagementTypes
open CreateCustomRoleUtils

module RenderPermissionModule = {
  @react.component
  let make = (~moduleName, ~description, ~scopes, ~moduleIndex) => {
    let parentGroupsField = ReactFinalForm.useField("parent_groups")

    let getCurrentScopes = () => {
      let allGroups = parentGroupsField.input.value->getArrayFromJson([])
      let currentGroup = allGroups[moduleIndex]

      switch currentGroup {
      | Some(groupJson) => {
          let groupDict = groupJson->getDictFromJsonObject
          getStrArryFromJson(getJsonObjectFromDict(groupDict, "scopes"))
        }
      | None => []
      }
    }

    let updateScopes = newScopes => {
      let allGroups = parentGroupsField.input.value->getArrayFromJson([])
      let updatedGroups = allGroups->Array.mapWithIndex((group, index) => {
        if index === moduleIndex {
          let groupDict = group->getDictFromJsonObject
          groupDict->Dict.set("scopes", newScopes->JSON.Encode.array)
          groupDict->JSON.Encode.object
        } else {
          group
        }
      })
      parentGroupsField.input.onChange(updatedGroups->Identity.arrayOfGenericTypeToFormReactEvent)
    }

    let scopeToString = scope => {
      switch scope {
      | Read => "read"
      | Write => "write"
      }
    }

    let handleScopeChange = (scope, isSelected: bool) => {
      let currentScopes = getCurrentScopes()
      let scopeString = scope->scopeToString
      let newScopes = updateScope(currentScopes, isSelected ? Add : Remove, scopeString)

      let finalScopes = switch (scope, isSelected) {
      | (Write, true) => updateScope(newScopes, Add, "read")
      | (Read, false) => updateScope(newScopes, Remove, "write")
      | _ => newScopes
      }

      updateScopes(finalScopes->Array.map(JSON.Encode.string))
    }

    let isReadAvailable = scopes->Array.some(scope => scope === Read->scopeToString)
    let isWriteAvailable = scopes->Array.some(scope => scope === Write->scopeToString)
    let currentScopes = getCurrentScopes()
    let isReadSelected = currentScopes->Array.includes("read")
    let isWriteSelected = currentScopes->Array.includes("write")

    <div className="flex items-center py-4 px-6">
      <div className="flex-1">
        <div className={`${body.md.semibold} text-nd_gray-700`}> {moduleName->React.string} </div>
        <div className={`${body.sm.medium} text-nd_gray-400`}> {description->React.string} </div>
      </div>
      <div className="flex gap-8">
        <div className="w-20 flex justify-center">
          <CheckBoxIcon
            isSelected=isReadSelected
            setIsSelected={isSelected => {
              handleScopeChange(Read, isSelected)
            }}
            isDisabled={!isReadAvailable}
            size=Large
          />
        </div>
        <div className="w-24 flex justify-center">
          <CheckBoxIcon
            isSelected=isWriteSelected
            setIsSelected={isSelected => {
              handleScopeChange(Write, isSelected)
            }}
            isDisabled={!isWriteAvailable}
            size=Large
          />
        </div>
      </div>
    </div>
  }
}

module NewCustomRoleInputFields = {
  open CommonAuthHooks
  @react.component
  let make = (~onEntityTypeChange) => {
    let {userRole} = useCommonAuthInfo()->Option.getOr(defaultAuthInfo)
    <div className="flex flex-col gap-4">
      <div className={`${body.md.semibold} text-nd_gray-700`}> {"Role Details"->React.string} </div>
      <div className="flex flex-row gap-6 w-full">
        <FormRenderer.FieldRenderer
          field=createCustomRole fieldWrapperClass="w-3/5" labelClass="!text-black !-ml-[0.5px]"
        />
        <FormRenderer.FieldRenderer
          field={userRole->roleScope}
          fieldWrapperClass="w-fit"
          labelClass="!text-black !-ml-[0.5px]"
        />
        <FormRenderer.FieldRenderer
          field={entityType(~onEntityTypeChange)}
          fieldWrapperClass="w-fit"
          labelClass="!text-black !-ml-[0.5px]"
        />
      </div>
    </div>
  }
}

module PermissionTableWrapper = {
  @react.component
  let make = (~permissionModules) => {
    <div className="border border-nd_gray-150 rounded-lg">
      <div
        className={`flex items-center rounded-t-lg py-3 px-6 bg-nd_gray-25 border-b border-nd_gray-150 text-nd_gray-400 ${body.sm.medium}`}>
        <div className="flex-1"> {"Module"->React.string} </div>
        <div className="flex gap-8">
          <div className="w-20 text-center"> {"View"->React.string} </div>
          <div className="w-24 text-center"> {"Edit"->React.string} </div>
        </div>
      </div>
      <div className="divide-y divide-nd_gray-150">
        {permissionModules
        ->Array.mapWithIndex((moduleData, index) => {
          <RenderPermissionModule
            key={index->Int.toString}
            moduleName={moduleData.name}
            description={moduleData.description}
            scopes={moduleData.scopes}
            moduleIndex=index
          />
        })
        ->React.array}
      </div>
    </div>
  }
}

@react.component
let make = (~isInviteUserFlow=true, ~setNewRoleSelected=_ => (), ~baseUrl, ~breadCrumbHeader) => {
  open APIUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod()

  let (permissionModules, setPermissionModules) = React.useState(() => [])
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (currentEntityType, setCurrentEntityType) = React.useState(() => "merchant")
  let marginClass = isInviteUserFlow ? "mt-6" : ""
  let showToast = ToastState.useShowToast()
  let initialValues = React.useMemo(() => {
    let baseValues = getInitialValuesForForm(currentEntityType)
    let parentGroupsInitial = permissionModules->Array.map(module_ => {
      [
        ("name", module_.name->JSON.Encode.string),
        ("scopes", []->JSON.Encode.array), // Empty scopes array initially
      ]->getJsonFromArrayOfJson
    })
    baseValues->Dict.set("parent_groups", parentGroupsInitial->JSON.Encode.array)
    baseValues->JSON.Encode.object
  }, (currentEntityType, permissionModules))

  let onSubmit = async (values, _) => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let valuesDict = values->getDictFromJsonObject
      let roleName = getString(valuesDict, "role_name", "")->String.trim->titleToSnake
      valuesDict->Dict.set("role_name", roleName->JSON.Encode.string)
      let parentGroups =
        valuesDict
        ->getArrayFromDict("parent_groups", [])
        ->Array.filter(groupJson => {
          let groupDict = groupJson->getDictFromJsonObject
          let scopes = getStrArryFromJson(getJsonObjectFromDict(groupDict, "scopes"))
          scopes->Array.length > 0
        })
      valuesDict->Dict.set("parent_groups", parentGroups->JSON.Encode.array)

      let url = getURL(~entityName=V1(USERS), ~userType=#CREATE_CUSTOM_ROLE_V2, ~methodType=Post)
      let _ = await updateDetails(url, valuesDict->JSON.Encode.object, Post)
      showToast(~message="Custom role created successfully", ~toastType=ToastSuccess)
      setScreenState(_ => PageLoaderWrapper.Success)
      RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url=`/${baseUrl}`))
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Something went wrong")
        let errorCode = err->safeParse->getDictFromJsonObject->getString("code", "")
        let errorMessage = err->safeParse->getDictFromJsonObject->getString("message", "")
        switch errorCode->CommonAuthUtils.errorSubCodeMapper {
        | UR_35 => {
            showToast(~message="Custom role created successfully", ~toastType=ToastSuccess)
            setScreenState(_ => PageLoaderWrapper.Success)
          }
        | _ => {
            showToast(~message=errorMessage, ~toastType=ToastError)
            setScreenState(_ => PageLoaderWrapper.Error(err))
          }
        }
      }
    }
    Nullable.null
  }

  let getPermissionModules = async entityType => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(
        ~entityName=V1(USERS),
        ~userType=#ROLE_INFO,
        ~methodType=Get,
        ~queryParamerters=Some(`entity_type=${entityType}`),
      )
      let res = await fetchDetails(url)
      let modules = getArrayDataFromJson(res, permissionModuleMapper)
      setPermissionModules(_ => modules)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Something went wrong!"))
    }
  }

  let handleEntityTypeChange = entityType => {
    if entityType !== currentEntityType {
      setCurrentEntityType(_ => entityType)
      getPermissionModules(entityType)->ignore
    }
  }

  React.useEffect(() => {
    if permissionModules->Array.length === 0 {
      getPermissionModules(currentEntityType)->ignore
    } else {
      setScreenState(_ => PageLoaderWrapper.Success)
    }
    None
  }, [permissionModules])

  <div className="flex flex-col overflow-y-scroll h-full">
    <RenderIf condition={isInviteUserFlow}>
      <div className="flex flex-col gap-2">
        <PageUtils.PageHeading
          title="Create Custom Role"
          subTitle="Adjust permissions to create roles that match your requirement"
        />
        <BreadCrumbNavigation
          path=[{title: breadCrumbHeader, link: `/${baseUrl}`}]
          currentPageTitle="Create Custom Role"
        />
      </div>
    </RenderIf>
    <div
      className={`h-4/5 bg-white relative overflow-y-scroll flex flex-col gap-10 ${marginClass}`}>
      <PageLoaderWrapper screenState>
        <Form
          key={`invite-user-management-${currentEntityType}`}
          initialValues
          validate={values => validateCustomRoleForm(values, ~permissionModules, ~isV2=true)}
          onSubmit
          formClass="flex flex-col gap-8">
          <NewCustomRoleInputFields onEntityTypeChange=handleEntityTypeChange />
          <div className="flex flex-col gap-6">
            <div className={`${body.md.semibold} text-nd_gray-700`}>
              {"Select Permission Level"->React.string}
            </div>
            <PermissionTableWrapper permissionModules />
          </div>
          <div className="flex justify-end">
            <FormRenderer.SubmitButton text="Create role" loadingText="Loading..." />
          </div>
          <FormValuesSpy />
        </Form>
      </PageLoaderWrapper>
    </div>
  </div>
}
