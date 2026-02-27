open RoutingTypes
external toWasm: Dict.t<JSON.t> => wasmModule = "%identity"

module ActiveRulePreview = {
  open LogicUtils
  open APIUtils
  @react.component
  let make = (~initialRule, ~setInitialRule) => {
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
      ->AdvancedRoutingUtils.ruleInfoTypeMapper

    let deleteCurrentThreedsRule = async () => {
      try {
        let url = getURL(~entityName=V1(THREE_DS), ~methodType=Delete)
        let _ = await updateDetails(url, Dict.make()->JSON.Encode.object, Delete)
        showToast(~message="Successfully deleted current active 3ds rule", ~toastType=ToastSuccess)
        setInitialRule(_ => None)
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
        </div>
        <p className="text-base font-normal text-grey-700 opacity-50">
          {description->React.string}
        </p>
      </div>
      <RulePreviewer ruleInfo isFrom3ds=true />
    </div>
  }
}

module Configure3DSRule = {
  @react.component
  let make = (~wasm) => {
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
        let keyExtractor = (index, _rule, isDragging, _) => {
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
            isFrom3ds=true
          />
        }
        if notFirstRule {
          <DragDropComponent
            listItems=rule setListItems={v => setRules(_ => v)} keyExtractor isHorizontal=false
          />
        } else {
          rule
          ->Array.mapWithIndex((rule, index) => {
            keyExtractor(index, rule, false, false)
          })
          ->React.array
        }
      }
    </div>
  }
}
@react.component
let make = () => {
  // Three Ds flow
  open APIUtils
  open ThreeDSUtils
  let getURL = useGetURL()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let url = RescriptReactRouter.useUrl()
  let fetchDetails = useGetMethod(~showErrorToast=false)
  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let (wasm, setWasm) = React.useState(_ => None)
  let getTimeInCustomTimeZone = TimeZoneHook.useGetTimeInCustomTimeZone()

  let (initialValues, _setInitialValues) = React.useState(_ => {
    let currentTime = getTimeInCustomTimeZone("ddd, DD MMM YYYY HH:mm:ss", ~includeTimeZone=true)
    let currentDate = getTimeInCustomTimeZone("YYYY-MM-DD")
    getInitial3DSValue(~currentDate, ~currentTime)->Identity.genericTypeToJson
  })
  let (initialRule, setInitialRule) = React.useState(() => None)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (pageView, setPageView) = React.useState(_ => NEW)
  let showPopUp = PopUpState.useShowPopUp()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let showToast = ToastState.useShowToast()

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
      let threeDsUrl = getURL(~entityName=V1(THREE_DS), ~methodType=Get)
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

  React.useEffect(() => {
    fetchDetails()->ignore
    None
  }, [])

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
      let threeDsPayload = values->buildThreeDsPayloadBody

      let getActivateUrl = getURL(~entityName=V1(THREE_DS), ~methodType=Put)
      let _ = await updateDetails(getActivateUrl, threeDsPayload->Identity.genericTypeToJson, Put)
      fetchDetails()->ignore
      RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/3ds"))
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
      ~validateFields=[Name, Description],
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
    RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/3ds?type=new"))
  }

  let handleCreateNew = () => {
    mixpanelEvent(~eventName="create_new_3ds_rule")
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
      <PageUtils.PageHeading
        title={"3DS Decision Manager"}
        subTitle="Make your payments more secure by enforcing 3DS authentication through custom rules defined on payment parameters"
      />
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
              <Configure3DSRule wasm />
            </div>
            <div className="flex gap-4">
              <Button
                text="Cancel"
                buttonType=Secondary
                onClick={_ => {
                  setPageView(_ => LANDING)
                  RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/3ds"))
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
            <ActiveRulePreview initialRule setInitialRule />
          </RenderIf>
          <div className="w-full border p-6 flex flex-col gap-6 bg-white rounded-md">
            <p className="text-base font-semibold text-grey-700">
              {"Configure 3DS Rule"->React.string}
            </p>
            <p className="text-base font-normal text-grey-700 opacity-50">
              {"Create advanced rules using various payment parameters like amount, currency,payment method etc to enforce 3DS authentication for specific payments to reduce fraudulent transactions"->React.string}
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
