module ActiveRulePreview = {
  open LogicUtils
  open APIUtils
  @react.component
  let make = (~initialRule, ~setInitialRule, ~setPageView, ~setShowWarning) => {
    let rule = initialRule->Option.getOr(Dict.make())
    let getURL = useGetURL()
    let updateDetails = useUpdateMethod()
    let showToast = ToastState.useShowToast()
    let showPopUp = PopUpState.useShowPopUp()
    let name = rule->getString("name", "")
    let description = rule->getString("description", "")
    let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()

    let ruleInfo = rule->getDictfromDict("algorithm")->SurchargeUtils.ruleInfoTypeMapper

    let deleteCurrentSurchargeRule = async () => {
      try {
        let url = getURL(~entityName=V1(SURCHARGE), ~methodType=Delete)
        let _ = await updateDetails(url, Dict.make()->JSON.Encode.object, Delete)
        showToast(
          ~message="Successfully deleted current active surcharge rule",
          ~toastType=ToastSuccess,
        )
        setInitialRule(_ => None)
        setShowWarning(_ => false)
      } catch {
      | _ =>
        showToast(~message="Failed to delete current active surcharge rule.", ~toastType=ToastError)
      }
    }

    let handleDeletePopup = () =>
      showPopUp({
        popUpType: (Warning, WithIcon),
        heading: "Confirm delete?",
        description: React.string(
          "Are you sure you want to delete currently active surcharge rule? Deleting the rule will remove its associated settings and configurations, potentially affecting functionality.",
        ),
        handleConfirm: {text: "Confirm", onClick: _ => deleteCurrentSurchargeRule()->ignore},
      })

    let handleEditPopup = () => {
      setPageView(_ => ThreeDSUtils.NEW)
    }

    <RenderIf condition={initialRule->Option.isSome}>
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
              description="Delete existing surcharge rule"
              authorization={userHasAccess(~groupAccess=WorkflowsManage)}
              onClick={_ => handleDeletePopup()}>
              <Icon
                name="delete"
                size=20
                className="text-jp-gray-700 hover:text-jp-gray-900 dark:hover:text-white cursor-pointer"
              />
            </ACLDiv>
            <ACLDiv
              description="Edit existing surcharge rule"
              authorization={userHasAccess(~groupAccess=WorkflowsManage)}
              onClick={_ => handleEditPopup()}>
              <Icon
                name="edit"
                size=20
                className="text-jp-gray-700 hover:text-jp-gray-900 dark:hover:text-white cursor-pointer"
              />
            </ACLDiv>
          </div>
          <p className="text-base font-normal text-grey-700 opacity-50">
            {description->React.string}
          </p>
        </div>
        <RulePreviewer ruleInfo isFromSurcharge=true />
      </div>
    </RenderIf>
  }
}

module ConfigureSurchargeRule = {
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
          <AdvancedRouting.Wrapper
            key={index->Int.toString}
            id
            heading={`Rule ${Int.toString(index + 1)}`}
            onClickAdd={_ => addRule(index, false)}
            onClickCopy={_ => addRule(index, true)}
            onClickRemove={_ => removeRule(index)}
            gatewayOptions={[]->SelectBox.makeOptions}
            notFirstRule
            isDragging
            wasm
            isFromSurcharge=true
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
  open APIUtils
  open ThreeDSUtils
  open SurchargeUtils
  let getURL = useGetURL()
  let showToast = ToastState.useShowToast()
  let fetchDetails = useGetMethod(~showErrorToast=false)
  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let (wasm, setWasm) = React.useState(_ => None)
  let getTimeInCustomTimeZone = TimeZoneHook.useGetTimeInCustomTimeZone()

  let (initialValues, setInitialValues) = React.useState(_ => {
    let currentTime = getTimeInCustomTimeZone("ddd, DD MMM YYYY HH:mm:ss", ~includeTimeZone=true)
    let currentDate = getTimeInCustomTimeZone("YYYY-MM-DD")
    buildInitialSurchargeValue(~currentDate, ~currentTime)->Identity.genericTypeToJson
  })
  let (initialRule, setInitialRule) = React.useState(() => None)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (pageView, setPageView) = React.useState(_ => LANDING)
  let showPopUp = PopUpState.useShowPopUp()
  let (showWarning, setShowWarning) = React.useState(_ => true)
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let mixpanelEvent = MixpanelHook.useSendEvent()

  let getWasm = async () => {
    try {
      let wasmResult = await Window.connectorWasmInit()
      let wasm =
        wasmResult->LogicUtils.getDictFromJsonObject->LogicUtils.getObj("wasm", Dict.make())
      setWasm(_ => Some(wasm->Identity.toWasm))
    } catch {
    | _ => ()
    }
  }
  let activeRoutingDetails = async () => {
    open LogicUtils
    try {
      let surchargeUrl = getURL(~entityName=V1(SURCHARGE), ~methodType=Get)
      let surchargeRuleDetail = await fetchDetails(surchargeUrl)
      let responseDict = surchargeRuleDetail->getDictFromJsonObject
      let programValue = responseDict->getObj("algorithm", Dict.make())

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
      setInitialValues(_ => responseDict->mapResponseToFormValues->Identity.genericTypeToJson)
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
          setShowWarning(_ => false)
          setPageView(_ => LANDING)
          setScreenState(_ => Success)
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

  let onSubmit = async (values, _) => {
    try {
      mixpanelEvent(~eventName="surcharge_save")
      let surchargePayload = values->buildSurchargePayloadBody
      let getActivateUrl = getURL(~entityName=V1(SURCHARGE), ~methodType=Put)
      let _ = await updateDetails(getActivateUrl, surchargePayload->Identity.genericTypeToJson, Put)
      fetchDetails()->ignore
      setShowWarning(_ => true)
      RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/surcharge"))
      setPageView(_ => LANDING)
      setScreenState(_ => Success)
      showToast(~message="Saved successfully!", ~toastType=ToastState.ToastSuccess)
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      showToast(~message=err, ~toastType=ToastError)
    }
    Nullable.null
  }

  let validate = (values: JSON.t) => {
    let dict = values->LogicUtils.getDictFromJsonObject

    let errors = Dict.make()

    AdvancedRoutingUtils.validateNameAndDescription(~dict, ~errors, ~validateFields=[Name])

    switch dict->Dict.get("algorithm")->Option.flatMap(obj => obj->JSON.Decode.object) {
    | Some(jsonDict) => {
        let rules = jsonDict->LogicUtils.getArrayFromDict("rules", [])
        if rules->Array.length === 0 {
          errors->Dict.set(`Rules`, "Minimum 1 rule needed"->JSON.Encode.string)
        } else {
          rules->Array.forEachWithIndex((rule, i) => {
            let ruleDict = rule->LogicUtils.getDictFromJsonObject

            if !validateConditionsForSurcharge(ruleDict) {
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
  }

  let handleCreateNew = () => {
    mixpanelEvent(~eventName="create_new_surcharge")
    if showWarning {
      showPopUp({
        popUpType: (Warning, WithIcon),
        heading: "Heads up!",
        description: "This will override the existing surcharge configuration. Please confirm to proceed"->React.string,
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
    let currentTime = getTimeInCustomTimeZone("ddd, DD MMM YYYY HH:mm:ss", ~includeTimeZone=true)
    let currentDate = getTimeInCustomTimeZone("YYYY-MM-DD")
    setInitialValues(_ =>
      buildInitialSurchargeValue(~currentDate, ~currentTime)->Identity.genericTypeToJson
    )
  }

  <PageLoaderWrapper screenState>
    <div className="flex flex-col overflow-scroll gap-6">
      <PageUtils.PageHeading
        title={"Surcharge"} subTitle="Configure advanced rules to apply surcharges"
      />
      {switch pageView {
      | NEW =>
        <div className="w-full border p-8 bg-white rounded-md ">
          <Form initialValues validate formClass="flex flex-col gap-6 justify-between" onSubmit>
            <BasicDetailsForm isThreeDs=true showDescription=false />
            <div>
              <div
                className={`flex flex-wrap items-center justify-between p-4 py-8 bg-white dark:bg-jp-gray-lightgray_background rounded-md border border-jp-gray-600 dark:border-jp-gray-850 
        `}>
                <div>
                  <div className="font-bold"> {React.string("Surcharge")} </div>
                  <div className="flex flex-col gap-4">
                    <span className="w-full text-jp-gray-700 dark:text-jp-gray-700 text-justify">
                      {"Configure Advanced Rules to apply surcharges"->React.string}
                    </span>
                    <span className="flex flex-col text-jp-gray-700">
                      {"For example:"->React.string}
                      <p className="flex gap-2 items-center">
                        <div className="p-1 h-fit rounded-full bg-jp-gray-700 ml-2" />
                        {"If payment_method = card && amount > 50000, apply 5% or 2500 surcharge."->React.string}
                      </p>
                    </span>
                    <span className="text-jp-gray-700 text-sm">
                      <i>
                        {"Ensure to enter the payment amount and surcharge fixed amount in the smallest currency unit (e.g., cents for USD, yen for JPY). 
                For instance, pass 100 to charge $1.00 (USD) and ¥100 (JPY) since ¥ is a zero-decimal currency."->React.string}
                      </i>
                    </span>
                  </div>
                </div>
              </div>
              <ConfigureSurchargeRule wasm />
            </div>
            <div className="flex gap-4">
              <Button
                text="Cancel"
                buttonType=Secondary
                onClick={_ => {
                  setPageView(_ => LANDING)
                  RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/surcharge"))
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
          <ActiveRulePreview initialRule setInitialRule setPageView setShowWarning />
          <RenderIf condition={initialRule->Option.isNone}>
            <div className="w-full border p-6 flex flex-col gap-6 bg-white rounded-md">
              <p className="text-base font-semibold text-grey-700">
                {"Configure Surcharge"->React.string}
              </p>
              <p className="text-base font-normal text-grey-700 opacity-50">
                {"Create advanced rules using various payment parameters like amount, currency,payment method etc to enforce a surcharge on your payments"->React.string}
              </p>
              <ACLButton
                text="Create New"
                authorization={userHasAccess(~groupAccess=WorkflowsManage)}
                buttonType=Primary
                customButtonStyle="!w-1/6 "
                onClick={_ => handleCreateNew()}
              />
            </div>
          </RenderIf>
        </div>
      }}
    </div>
  </PageLoaderWrapper>
}
