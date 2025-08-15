open LogicUtils
open Typography
open UserManagementUtils
open UserManagementTypes
module RenderPermissionModule = {
  @react.component
  let make = (~moduleName, ~description, ~scopes) => {
    let parentGroupsInput = ReactFinalForm.useField(`parent_groups`).input
    let parentGroupsValue = parentGroupsInput.value->getArrayFromJson([])

    let existingModule = parentGroupsValue->Array.find(group => {
      group->getDictFromJsonObject->getString("name", "") === moduleName
    })

    let (selectedScopes, setSelectedScopes) = React.useState(_ => {
      switch existingModule {
      | Some(data) => data->getDictFromJsonObject->getStrArrayFromDict("scopes", [])
      | None => []
      }
    })

    let handleScopeChange = (scope: string, isSelected: bool) => {
      let newScopes = if isSelected {
        if !(selectedScopes->Array.includes(scope)) {
          if scope === "write" {
            let scopesToAdd = if selectedScopes->Array.includes("read") {
              ["write"]
            } else {
              ["read", "write"]
            }
            Array.concat(selectedScopes, scopesToAdd)
          } else {
            Array.concat(selectedScopes, [scope])
          }
        } else {
          selectedScopes
        }
      } else if scope === "read" {
        selectedScopes->Array.filter(s => s !== "read" && s !== "write")
      } else if scope === "write" {
        selectedScopes->Array.filter(s => s !== "read" && s !== "write")
      } else {
        selectedScopes->Array.filter(s => s !== scope)
      }

      setSelectedScopes(_ => newScopes)
      let updatedGroups = if newScopes->Array.length > 0 {
        let moduleConfig =
          [
            ("name", moduleName->JSON.Encode.string),
            ("scopes", newScopes->Array.map(scope => scope->JSON.Encode.string)->JSON.Encode.array),
          ]->getJsonFromArrayOfJson

        if existingModule->Option.isSome {
          parentGroupsValue->Array.map(group => {
            let groupDict = group->getDictFromJsonObject
            if getString(groupDict, "name", "") === moduleName {
              moduleConfig
            } else {
              group
            }
          })
        } else {
          Array.concat(parentGroupsValue, [moduleConfig])
        }
      } else {
        parentGroupsValue->Array.filter(group => {
          group->getDictFromJsonObject->getString("name", "") !== moduleName
        })
      }

      parentGroupsInput.onChange(updatedGroups->Identity.arrayOfGenericTypeToFormReactEvent)
    }

    let isReadSelected = selectedScopes->Array.includes("read")
    let isWriteSelected = selectedScopes->Array.includes("write")

    let isReadAvailable = scopes->Array.includes("read")
    let isWriteAvailable = scopes->Array.includes("write")

    <div className="flex items-center py-4 px-6">
      <div className="flex-1">
        <div className={`${body.md.semibold} text-nd_gray-700`}> {moduleName->React.string} </div>
        <div className={`${body.sm.medium} text-nd_gray-400`}> {description->React.string} </div>
      </div>
      <div className="flex gap-8">
        <div className="w-20 flex justify-center">
          <CheckBoxIcon
            isSelected=isReadSelected
            setIsSelected={scope => handleScopeChange("read", scope)}
            isDisabled={!isReadAvailable}
            size=Large
          />
        </div>
        <div className="w-24 flex justify-center">
          <CheckBoxIcon
            isSelected=isWriteSelected
            setIsSelected={scope => handleScopeChange("write", scope)}
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
  let make = () => {
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
          <div className="w-24 text-center"> {"View & Edit"->React.string} </div>
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

  let initialValuesForForm =
    [
      ("role_scope", "merchant"->JSON.Encode.string),
      ("role_name", ""->JSON.Encode.string),
      ("parent_groups", []->JSON.Encode.array),
    ]->Dict.fromArray

  let (permissionModules, setPermissionModules) = React.useState(() => [])
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (initalValue, setInitialValues) = React.useState(_ => initialValuesForForm)
  let marginClass = isInviteUserFlow ? "mt-6" : ""
  let showToast = ToastState.useShowToast()

  let onSubmit = async (values, _) => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let copiedJson = JSON.parseExn(JSON.stringify(values))
      let url = getURL(~entityName=V1(USERS), ~userType=#CREATE_CUSTOM_ROLE_V2, ~methodType=Post)

      let body = copiedJson->getDictFromJsonObject->JSON.Encode.object
      let roleNameValue =
        body->getDictFromJsonObject->getString("role_name", "")->String.trim->titleToSnake
      body->getDictFromJsonObject->Dict.set("role_name", roleNameValue->JSON.Encode.string)
      let _ = await updateDetails(url, body, Post)
      setScreenState(_ => PageLoaderWrapper.Success)
      RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url=`/${baseUrl}`))
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Something went wrong")
        let errorCode = err->safeParse->getDictFromJsonObject->getString("code", "")
        let errorMessage = err->safeParse->getDictFromJsonObject->getString("message", "")
        if errorCode === "UR_35" {
          setInitialValues(_ => values->getDictFromJsonObject)
          setScreenState(_ => PageLoaderWrapper.Success)
        } else {
          showToast(~message=errorMessage, ~toastType=ToastError)
          setScreenState(_ => PageLoaderWrapper.Error(err))
        }
      }
    }
    Nullable.null
  }

  let getPermissionModules = async () => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let url = getURL(
        ~entityName=V1(USERS),
        ~userType=#ROLE_INFO,
        ~methodType=Get,
        ~queryParamerters=Some(`entity_type=merchant`), // Currently we create custom roles with merchant entity type by default
      )
      let res = await fetchDetails(url)
      let modules = getArrayDataFromJson(res, permissionModuleMapper)
      setPermissionModules(_ => modules)
      setScreenState(_ => PageLoaderWrapper.Success)
    } catch {
    | _ => setScreenState(_ => PageLoaderWrapper.Error("Something went wrong!"))
    }
  }

  React.useEffect(() => {
    if permissionModules->Array.length === 0 {
      getPermissionModules()->ignore
    } else {
      setScreenState(_ => PageLoaderWrapper.Success)
    }
    None
  }, [])

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
          key="invite-user-management"
          initialValues={initalValue->JSON.Encode.object}
          validate={values => values->UserManagementUtils.validateFormForRoles}
          onSubmit
          formClass="flex flex-col gap-8">
          <NewCustomRoleInputFields />
          <div className="flex flex-col gap-6">
            <div className={`${body.md.semibold} text-nd_gray-700`}>
              {"Select Permission Level"->React.string}
            </div>
            <PermissionTableWrapper permissionModules />
          </div>
          <div className="flex justify-end">
            <FormRenderer.SubmitButton text="Create role" loadingText="Loading..." />
          </div>
        </Form>
      </PageLoaderWrapper>
    </div>
  </div>
}
