open LogicUtils
open Typography
open UserManagementUtils
open UserManagementTypes
open CreateCustomRoleUtils
module RenderPermissionModule = {
  @react.component
  let make = (~moduleName, ~description, ~scopes) => {
    let readField = ReactFinalForm.useField(`${moduleName}.read`)
    let writeField = ReactFinalForm.useField(`${moduleName}.write`)

    let handleScopeChange = (scope: string, isSelected: bool) => {
      if scope === "write" && isSelected && !getBoolFromJson(readField.input.value, false) {
        readField.input.onChange(true->Identity.anyTypeToReactEvent)
      }
      if scope === "read" && !isSelected {
        writeField.input.onChange(false->Identity.anyTypeToReactEvent)
      }
    }

    let isReadAvailable = scopes->Array.includes("read")
    let isWriteAvailable = scopes->Array.includes("write")
    let isReadSelected = getBoolFromJson(readField.input.value, false)
    let isWriteSelected = getBoolFromJson(writeField.input.value, false)

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
              handleScopeChange("read", isSelected)
              readField.input.onChange(isSelected->Identity.anyTypeToReactEvent)
            }}
            isDisabled={!isReadAvailable}
            size=Large
          />
        </div>
        <div className="w-24 flex justify-center">
          <CheckBoxIcon
            isSelected=isWriteSelected
            setIsSelected={isSelected => {
              handleScopeChange("write", isSelected)
              writeField.input.onChange(isSelected->Identity.anyTypeToReactEvent)
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
          field={entityType(userRole, ~onEntityTypeChange)}
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

  let (permissionModules, setPermissionModules) = React.useState(() => [])
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (currentEntityType, setCurrentEntityType) = React.useState(() => "merchant")
  let marginClass = isInviteUserFlow ? "mt-6" : ""
  let showToast = ToastState.useShowToast()
  let initialValues = React.useMemo(() => {
    getInitialValuesForForm(currentEntityType)->JSON.Encode.object
  }, [currentEntityType])

  let onSubmit = async (values, _) => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let valuesDict = values->getDictFromJsonObject
      let roleScope = getString(valuesDict, "role_scope", "")
      let roleName = getString(valuesDict, "role_name", "")->String.trim->titleToSnake
      let entityType = getString(valuesDict, "entity_type", "")
      let parentGroups =
        permissionModules
        ->Array.map(module_ => {
          let moduleName = module_.name
          let moduleData = Dict.get(valuesDict, moduleName)

          switch moduleData {
          | Some(moduleJson) => {
              let moduleDict = moduleJson->getDictFromJsonObject
              let readSelected = getBool(moduleDict, "read", false)
              let writeSelected = getBool(moduleDict, "write", false)

              let scopes = []
              if readSelected {
                scopes->Array.push("read")->ignore
              }
              if writeSelected {
                scopes->Array.push("write")->ignore
              }

              if scopes->Array.length > 0 {
                Some(
                  [
                    ("name", moduleName->JSON.Encode.string),
                    ("scopes", scopes->Array.map(JSON.Encode.string)->JSON.Encode.array),
                  ]->getJsonFromArrayOfJson,
                )
              } else {
                None
              }
            }
          | None => None
          }
        })
        ->Array.filter(Option.isSome)
        ->Array.map(Option.getExn)

      let body =
        [
          ("role_name", roleName->JSON.Encode.string),
          ("role_scope", roleScope->JSON.Encode.string),
          ("entity_type", entityType->JSON.Encode.string),
          ("parent_groups", parentGroups->JSON.Encode.array),
        ]->getJsonFromArrayOfJson

      let url = getURL(~entityName=V1(USERS), ~userType=#CREATE_CUSTOM_ROLE_V2, ~methodType=Post)
      let _ = await updateDetails(url, body, Post)
      setScreenState(_ => PageLoaderWrapper.Success)
      RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url=`/${baseUrl}`))
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Something went wrong")
        let errorCode = err->safeParse->getDictFromJsonObject->getString("code", "")
        let errorMessage = err->safeParse->getDictFromJsonObject->getString("message", "")
        if errorCode === "UR_35" {
          setScreenState(_ => PageLoaderWrapper.Success)
        } else {
          showToast(~message=errorMessage, ~toastType=ToastError)
          setScreenState(_ => PageLoaderWrapper.Error(err))
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
        </Form>
      </PageLoaderWrapper>
    </div>
  </div>
}
