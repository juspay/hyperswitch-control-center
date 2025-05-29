open RoutingTypes
external toWasm: Dict.t<JSON.t> => wasmModule = "%identity"

type pageState = NEW | LANDING

let pageStateMapper = pageType => {
  switch pageType {
  | "new" => NEW
  | _ => LANDING
  }
}

module ActiveRulePreview = {
  open LogicUtils
  open APIUtils
  @react.component
  let make = (~initialRule, ~setInitialRule=?, ~isIntelligence=false) => {
    let getURL = useGetURL()
    let updateDetails = useUpdateMethod()
    let showPopUp = PopUpState.useShowPopUp()
    let showToast = ToastState.useShowToast()
    let ruleInfo = initialRule->Option.getOr(Dict.make())
    let name = ruleInfo->getString("name", "")
    let description = ruleInfo->getString("description", "")
    let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()

    let ruleInfo =
      ruleInfo
      ->getJsonObjectFromDict("algorithm")
      ->getDictFromJsonObject
      ->AdvancedRoutingUtils.ruleInfoTypeMapper(~isFrom3dsIntelligence=isIntelligence)

    let deleteCurrentThreedsRule = async () => {
      try {
        let url = getURL(~entityName=V1(THREE_DS), ~methodType=Delete)
        let _ = await updateDetails(url, Dict.make()->JSON.Encode.object, Delete)
        showToast(~message="Successfully deleted current active 3ds rule", ~toastType=ToastSuccess)
        switch setInitialRule {
        | Some(setter) => setter(_ => None)
        | None => ()
        }
      } catch {
      | _ => showToast(~message="Failed to delete current active 3ds rule.", ~toastType=ToastError)
      }
    }

    let handleDeletePopup = () =>
      showPopUp({
        popUpType: (Warning, WithIcon),
        heading: "Confirm delete?",
        description: React.string(
          "Are you sure you want to delete currently active 3DS rule? Deleting the rule will remove its associated settings and configurations, potentially affecting functionality.",
        ),
        handleConfirm: {text: "Confirm", onClick: _ => deleteCurrentThreedsRule()->ignore},
      })

    <div className="relative flex flex-col gap-6 w-full border p-6 bg-white rounded-md">
      <div
        className="absolute top-0 right-0 bg-green-700 text-white py-2 px-4 rounded-bl font-semibold">
        {"ACTIVE"->React.string}
      </div>
      <div className="flex flex-col gap-2 ">
        <div className="flex gap-4 items-center ">
          <p className="text-xl font-semibold text-grey-700">
            {name->capitalizeString->React.string}
          </p>
          <RenderIf condition={!isIntelligence}>
            <ACLDiv
              authorization={userHasAccess(~groupAccess=WorkflowsManage)}
              onClick={_ => handleDeletePopup()}
              description="Delete existing 3ds rule">
              <Icon
                name="delete"
                size=20
                className="text-jp-gray-700 hover:text-jp-gray-900 dark:hover:text-white cursor-pointer"
              />
            </ACLDiv>
          </RenderIf>
        </div>
        <p className="text-base font-normal text-grey-700 opacity-50">
          {description->React.string}
        </p>
      </div>
      <RulePreviewer ruleInfo isFrom3ds={!isIntelligence} isFrom3dsIntelligence=isIntelligence />
    </div>
  }
}

module Configure3DSRule = {
  @react.component
  let make = (~wasm, ~isIntelligence=false) => {
    let ruleInput = ReactFinalForm.useField("algorithm.rules").input
    let (rules, setRules) = React.useState(_ => ruleInput.value->LogicUtils.getArrayFromJson([]))
    React.useEffect(() => {
      ruleInput.onChange(rules->Identity.arrayOfGenericTypeToFormReactEvent)
      None
    }, [rules])
    let addRule = (index, _copy) => {
      let existingRules = ruleInput.value->LogicUtils.getArrayFromJson([])
      let newRule = existingRules[index]->Option.getOr(JSON.Encode.null)
      let newRules = existingRules->Array.concat([newRule])
      ruleInput.onChange(newRules->Identity.arrayOfGenericTypeToFormReactEvent)
    }

    let removeRule = index => {
      let existingRules = ruleInput.value->LogicUtils.getArrayFromJson([])
      let newRules = existingRules->Array.filterWithIndex((_, i) => i !== index)
      ruleInput.onChange(newRules->Identity.arrayOfGenericTypeToFormReactEvent)
    }

    <div>
      {
        let notFirstRule = ruleInput.value->LogicUtils.getArrayFromJson([])->Array.length > 1
        let rule = ruleInput.value->JSON.Decode.array->Option.getOr([])
        let keyExtractor = (index, _rule, isDragging) => {
          let id = {`algorithm.rules[${Int.toString(index)}]`}
          let i = 1
          <AdvancedRouting.Wrapper
            key={index->Int.toString}
            id
            heading={`Rule ${Int.toString(index + i)}`}
            onClickAdd={_ => addRule(index, false)}
            onClickCopy={_ => addRule(index, true)}
            onClickRemove={_ => removeRule(index)}
            gatewayOptions={[]->SelectBox.makeOptions}
            notFirstRule
            isDragging
            wasm
            isFrom3ds={!isIntelligence}
            isFrom3dsIntelligence=isIntelligence
          />
        }
        if notFirstRule {
          <DragDropComponent
            listItems=rule setListItems={v => setRules(_ => v)} keyExtractor isHorizontal=false
          />
        } else {
          rule
          ->Array.mapWithIndex((rule, index) => {
            keyExtractor(index, rule, false)
          })
          ->React.array
        }
      }
    </div>
  }
}
type pageConfig = {
  isIntelligence: bool,
  pageTitle: string,
  pageSubtitle: string,
  configureTitle: string,
  configureDescription: string,
  baseUrl: string,
  newUrl: string,
  entityName: APIUtilsTypes.entityTypeWithVersion,
  mixpanelEvent: string,
}

@react.component
let make = (~isIntelligence=false) => {
  // Three Ds flow
  open APIUtils
  let getURL = useGetURL()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let url = RescriptReactRouter.useUrl()
  let fetchDetails = useGetMethod(~showErrorToast=false)
  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let (wasm, setWasm) = React.useState(_ => None)
  let (initialRule, setInitialRule) = React.useState(() => None)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (pageView, setPageView) = React.useState(_ => NEW)
  let showPopUp = PopUpState.useShowPopUp()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let showToast = ToastState.useShowToast()
  let {userInfo: {profileId}} = React.useContext(UserInfoProvider.defaultContext)

  let config = if isIntelligence {
    {
      isIntelligence: true,
      pageTitle: "3DS Exemption Rules",
      pageSubtitle: "Optimize  3DS strategy by correctly applying 3DS exemptions to offer a seamless experience to the users while balancing fraud",
      configureTitle: "Configure 3DS Exemption Rules",
      configureDescription: "Configure advanced rules on parameters like amount, currency, and method to automatically apply 3DS exemptions, balancing regulatory compliance with seamless user experience.",
      baseUrl: "/3ds-exemption",
      newUrl: "/3ds-exemption?type=new",
      entityName: V1(THREE_DS_EXEMPTION_RULES),
      mixpanelEvent: "create_new_3ds_rule",
    }
  } else {
    {
      isIntelligence: false,
      pageTitle: "3DS Decision Manager",
      pageSubtitle: "Make your payments more secure by enforcing 3DS authentication through custom rules defined on payment parameters",
      configureTitle: "Configure 3DS Rule",
      configureDescription: "Create advanced rules using various payment parameters like amount, currency,payment method etc to enforce 3DS authentication for specific payments to reduce fraudulent transactions",
      baseUrl: "/3ds",
      newUrl: "/3ds?type=new",
      entityName: V1(THREE_DS),
      mixpanelEvent: "create_new_3ds_rule",
    }
  }

  let (initialValues, _setInitialValues) = React.useState(_ => {
    if isIntelligence {
      ThreeDSIntelligenceUtils.buildInitial3DSValue->Identity.genericTypeToJson
    } else {
      ThreeDSUtils.buildInitial3DSValue->Identity.genericTypeToJson
    }
  })

  let getWasm = async () => {
    try {
      let wasmResult = await Window.connectorWasmInit()
      let fetchedWasm =
        wasmResult->LogicUtils.getDictFromJsonObject->LogicUtils.getObj("wasm", Dict.make())
      setWasm(_ => Some(fetchedWasm->toWasm))
    } catch {
    | _ => ()
    }
  }
  let activeRoutingDetails = async () => {
    open LogicUtils
    try {
      if isIntelligence {
        let threeDsUrl = getURL(~entityName=config.entityName, ~methodType=Get)
        let threeDsRuleDetail = await fetchDetails(threeDsUrl)
        let threeDsRuleArray = threeDsRuleDetail->JSON.Decode.array->Option.getOr([])
        let firstRule = threeDsRuleArray->Array.get(0)->Option.getOr(JSON.Encode.null)
        let ruleId = firstRule->LogicUtils.getDictFromJsonObject->LogicUtils.getString("id", "")

        if ruleId != "" {
          let activeRulesUrl = getURL(
            ~entityName=config.entityName,
            ~methodType=Get,
            ~id=Some(ruleId),
          )
          let threeDsActiveRuleDetail = await fetchDetails(activeRulesUrl)
          let responseDict = threeDsActiveRuleDetail->getDictFromJsonObject
          let programValue =
            responseDict->getObj("algorithm", Dict.make())->getObj("data", Dict.make())

          let intitialValue =
            [
              ("name", responseDict->LogicUtils.getString("name", "")->JSON.Encode.string),
              (
                "description",
                responseDict->LogicUtils.getString("description", "")->JSON.Encode.string,
              ),
              ("algorithm", programValue->JSON.Encode.object),
            ]->Dict.fromArray

          setInitialRule(_ => Some(intitialValue))
        }
      } else {
        let threeDsUrl = getURL(~entityName=config.entityName, ~methodType=Get)
        let threeDsRuleDetail = await fetchDetails(threeDsUrl)
        let responseDict = threeDsRuleDetail->getDictFromJsonObject
        let programValue = responseDict->getObj("program", Dict.make())

        let intitialValue =
          [
            ("name", responseDict->LogicUtils.getString("name", "")->JSON.Encode.string),
            (
              "description",
              responseDict->LogicUtils.getString("description", "")->JSON.Encode.string,
            ),
            ("algorithm", programValue->JSON.Encode.object),
          ]->Dict.fromArray

        setInitialRule(_ => Some(intitialValue))
      }
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Something went wrong")
      Exn.raiseError(err)
    }
  }

  let fetchDetails = async () => {
    try {
      setScreenState(_ => Loading)
      await getWasm()
      await activeRoutingDetails()
      setScreenState(_ => Success)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Something went wrong")
        if err->String.includes("HE_02") {
          setPageView(_ => LANDING)
          setScreenState(_ => Success)
          setInitialRule(_ => None)
        } else {
          setScreenState(_ => Error(err))
        }
      }
    }
  }

  // Reset state when switching between intelligence modes
  React.useEffect(() => {
    setInitialRule(_ => None)
    setScreenState(_ => PageLoaderWrapper.Loading)
    setPageView(_ => LANDING)
    None
  }, [isIntelligence])

  React.useEffect(() => {
    fetchDetails()->ignore
    None
  }, [isIntelligence])

  React.useEffect(() => {
    let searchParams = url.search
    let filtersFromUrl =
      LogicUtils.getDictFromUrlSearchParams(searchParams)->Dict.get("type")->Option.getOr("")
    setPageView(_ => filtersFromUrl->pageStateMapper)
    None
  }, [url.search])

  let onSubmit = async (values, _) => {
    try {
      setScreenState(_ => Loading)

      if isIntelligence {
        let valuesWithProfileId = values->LogicUtils.getDictFromJsonObject
        valuesWithProfileId->Dict.set("profile_id", profileId->JSON.Encode.string)
        let threeDsPayload =
          valuesWithProfileId->JSON.Encode.object->ThreeDSIntelligenceUtils.buildThreeDsPayloadBody
        let getActivateUrl = getURL(~entityName=config.entityName, ~methodType=Post)
        let result = await updateDetails(
          getActivateUrl,
          threeDsPayload->Identity.genericTypeToJson,
          Post,
        )
        let resultDict = result->LogicUtils.getDictFromJsonObject
        let routingId = resultDict->LogicUtils.getString("id", "")
        let body =
          [("transaction_type", "three_ds_authentication"->JSON.Encode.string)]
          ->Dict.fromArray
          ->JSON.Encode.object

        let activateUrl = getURL(
          ~entityName=config.entityName,
          ~methodType=Post,
          ~id=Some(routingId),
        )

        let _ = await updateDetails(activateUrl, body, Post)
      } else {
        let threeDsPayload = values->ThreeDSUtils.buildThreeDsPayloadBody
        let getActivateUrl = getURL(~entityName=config.entityName, ~methodType=Put)
        let _ = await updateDetails(getActivateUrl, threeDsPayload->Identity.genericTypeToJson, Put)
      }

      fetchDetails()->ignore
      RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url=config.baseUrl))
      setPageView(_ => LANDING)
      setScreenState(_ => Success)
      showToast(~message="Configuration saved successfully!", ~toastType=ToastState.ToastSuccess)
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      setScreenState(_ => Error(err))
    }
    Nullable.null
  }

  let validate = (values: JSON.t) => {
    let dict = values->LogicUtils.getDictFromJsonObject

    let errors = Dict.make()

    AdvancedRoutingUtils.validateNameAndDescription(
      ~dict,
      ~errors,
      ~validateFields=["name", "description"],
    )

    switch dict->Dict.get("algorithm")->Option.flatMap(obj => obj->JSON.Decode.object) {
    | Some(jsonDict) => {
        let index = 1
        let rules = jsonDict->LogicUtils.getArrayFromDict("rules", [])
        if index === 1 && rules->Array.length === 0 {
          errors->Dict.set(`Rules`, "Minimum 1 rule needed"->JSON.Encode.string)
        } else {
          rules->Array.forEachWithIndex((rule, i) => {
            let ruleDict = rule->LogicUtils.getDictFromJsonObject
            if !RoutingUtils.validateConditionsFor3ds(ruleDict) {
              errors->Dict.set(
                `Rule ${(i + 1)->Int.toString} - Condition`,
                `Invalid`->JSON.Encode.string,
              )
            }
          })
        }
      }

    | None => ()
    }

    errors->JSON.Encode.object
  }
  let redirectToNewRule = () => {
    setPageView(_ => NEW)
    RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url=config.newUrl))
  }

  let handleCreateNew = () => {
    mixpanelEvent(~eventName=config.mixpanelEvent)
    if initialRule->Option.isSome {
      showPopUp({
        popUpType: (Warning, WithIcon),
        heading: "Heads up!",
        description: "This will override the existing 3DS configuration. Please confirm to proceed"->React.string,
        handleConfirm: {
          text: "Confirm",
          onClick: {
            _ => redirectToNewRule()
          },
        },
        handleCancel: {
          text: "Cancel",
        },
      })
    } else {
      redirectToNewRule()
    }
  }

  <PageLoaderWrapper screenState>
    <div className="flex flex-col overflow-scroll gap-6">
      <PageUtils.PageHeading title={config.pageTitle} subTitle={config.pageSubtitle} />
      {switch pageView {
      | NEW =>
        <div className="w-full border p-8 bg-white rounded-md ">
          <Form initialValues validate formClass="flex flex-col gap-6 justify-between" onSubmit>
            <BasicDetailsForm isThreeDs=true />
            <div>
              <div
                className={`flex flex-wrap items-center justify-between p-4 py-8 bg-white dark:bg-jp-gray-lightgray_background rounded-md border border-jp-gray-600 dark:border-jp-gray-850`}>
                <div>
                  <div className="font-bold"> {React.string("Rule Based Configuration")} </div>
                  <div className="flex flex-col gap-4">
                    <span className="w-full text-jp-gray-700 dark:text-jp-gray-700 text-justify">
                      {"Rule-Based Configuration allows for detailed smart routing logic based on multiple dimensions of a payment. You can create any number of conditions using various dimensions and logical operators."->React.string}
                    </span>
                    <span className="flex flex-col text-jp-gray-700">
                      {"For example:"->React.string}
                      <p className="flex gap-2 items-center">
                        <div className="p-1 h-fit rounded-full bg-jp-gray-700 ml-2" />
                        {"If amount is > 100 and currency is USD, enforce 3DS authentication ."->React.string}
                      </p>
                    </span>
                    <span className="text-jp-gray-700 text-sm">
                      <i>
                        {"Ensure to enter the payment amount in the smallest currency unit (e.g., cents for USD, yen for JPY). 
            For instance, pass 100 to charge $1.00 (USD) and ¥100 (JPY) since ¥ is a zero-decimal currency."->React.string}
                      </i>
                    </span>
                  </div>
                </div>
              </div>
              <Configure3DSRule wasm isIntelligence />
            </div>
            <div className="flex gap-4">
              <Button
                text="Cancel"
                buttonType=Secondary
                onClick={_ => {
                  setPageView(_ => LANDING)
                  RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url=config.baseUrl))
                }}
              />
              <FormRenderer.SubmitButton
                text="Save " buttonSize=Button.Small buttonType=Button.Primary
              />
            </div>
          </Form>
        </div>
      | LANDING =>
        <div className="flex flex-col gap-6">
          <RenderIf condition={initialRule->Option.isSome}>
            <ActiveRulePreview initialRule setInitialRule=?{Some(setInitialRule)} isIntelligence />
          </RenderIf>
          <div className="w-full border p-6 flex flex-col gap-6 bg-white rounded-md">
            <p className="text-base font-semibold text-grey-700">
              {config.configureTitle->React.string}
            </p>
            <p className="text-base font-normal text-grey-700 opacity-50">
              {config.configureDescription->React.string}
            </p>
            <ACLButton
              text="Create New"
              authorization={userHasAccess(~groupAccess=WorkflowsManage)}
              buttonType=Primary
              customButtonStyle="!w-1/6"
              onClick={_ => handleCreateNew()}
            />
          </div>
        </div>
      }}
    </div>
  </PageLoaderWrapper>
}
