module ActiveRulePreview = {
  open LogicUtils
  @react.component
  let make = (~initialRule) => {
    let rule = initialRule->Option.getOr(Dict.make())

    let name = rule->getString("name", "")
    let description = rule->getString("description", "")

    let ruleInfo = rule->getDictfromDict("algorithm")->SurchargeUtils.ruleInfoTypeMapper

    <UIUtils.RenderIf condition={initialRule->Option.isSome}>
      <div className="relative flex flex-col gap-6 w-full border p-6 bg-white rounded-md">
        <div
          className="absolute top-0 right-0 bg-green-800 text-white py-2 px-4 rounded-bl font-semibold">
          {"ACTIVE"->React.string}
        </div>
        <div className="flex flex-col gap-2 ">
          <p className="text-xl font-semibold text-grey-700">
            {name->capitalizeString->React.string}
          </p>
          <p className="text-base font-normal text-grey-700 opacity-50">
            {description->React.string}
          </p>
        </div>
        <RulePreviewer ruleInfo isFromSurcharge=true />
      </div>
    </UIUtils.RenderIf>
  }
}

module ConfigureSurchargeRule = {
  @react.component
  let make = (~wasm) => {
    let ruleInput = ReactFinalForm.useField("algorithm.rules").input
    let (rules, setRules) = React.useState(_ => ruleInput.value->LogicUtils.getArrayFromJson([]))
    React.useEffect1(() => {
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
            keyExtractor(index, rule, false)
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
  let showToast = ToastState.useShowToast()
  let fetchDetails = useGetMethod(~showErrorToast=false, ())
  let updateDetails = useUpdateMethod(~showErrorToast=false, ())
  let (wasm, setWasm) = React.useState(_ => None)
  let (initialValues, _setInitialValues) = React.useState(_ =>
    buildInitialSurchargeValue->Identity.genericTypeToJson
  )
  let (initialRule, setInitialRule) = React.useState(() => None)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (pageView, setPageView) = React.useState(_ => LANDING)
  let showPopUp = PopUpState.useShowPopUp()
  let (showWarning, setShowWarning) = React.useState(_ => true)
  let userPermissionJson = Recoil.useRecoilValueFromAtom(HyperswitchAtom.userPermissionAtom)

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
      let surchargeUrl = getURL(~entityName=SURCHARGE, ~methodType=Get, ())
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

  React.useEffect0(() => {
    fetchDetails()->ignore
    None
  })

  let onSubmit = async (values, _) => {
    try {
      let surchargePayload = values->buildSurchargePayloadBody
      let getActivateUrl = getURL(~entityName=SURCHARGE, ~methodType=Put, ())
      let _ = await updateDetails(
        getActivateUrl,
        surchargePayload->Identity.genericTypeToJson,
        Put,
        (),
      )
      fetchDetails()->ignore
      setShowWarning(_ => true)
      RescriptReactRouter.replace(`/surcharge`)
      setPageView(_ => LANDING)
      setScreenState(_ => Success)
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      showToast(~message=err, ~toastType=ToastError, ())
    }
    Nullable.null
  }

  let validate = (values: JSON.t) => {
    let dict = values->LogicUtils.getDictFromJsonObject

    let errors = Dict.make()

    AdvancedRoutingUtils.validateNameAndDescription(~dict, ~errors)

    switch dict->Dict.get("algorithm")->Option.flatMap(JSON.Decode.object) {
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
            <BasicDetailsForm isThreeDs=true />
            <ConfigureSurchargeRule wasm />
            <FormValuesSpy />
            <div className="flex gap-4">
              <Button
                text="Cancel"
                buttonType=Secondary
                onClick={_ => {
                  setPageView(_ => LANDING)
                  RescriptReactRouter.replace(`/surcharge`)
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
          <ActiveRulePreview initialRule />
          <div className="w-full border p-6 flex flex-col gap-6 bg-white rounded-md">
            <p className="text-base font-semibold text-grey-700">
              {"Configure Surcharge"->React.string}
            </p>
            <p className="text-base font-normal text-grey-700 opacity-50">
              {"Create advanced rules using various payment parameters like amount, currency,payment method etc to enforce a surcharge on your payments"->React.string}
            </p>
            <ACLButton
              text="Create New"
              access=userPermissionJson.workflowsManage
              buttonType=Primary
              customButtonStyle="!w-1/6"
              leftIcon=FontAwesome("plus")
              onClick={_ => handleCreateNew()}
            />
          </div>
        </div>
      }}
    </div>
  </PageLoaderWrapper>
}
