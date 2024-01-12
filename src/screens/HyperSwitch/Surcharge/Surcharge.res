module ActiveRulePreview = {
  open LogicUtils
  @react.component
  let make = (~initialRule) => {
    let rule = initialRule->Belt.Option.getWithDefault(Dict.make())

    let name = rule->getString("name", "")
    let description = rule->getString("description", "")

    let ruleInfo = rule->getDictfromDict("algorithm")->SurchargeUtils.ruleInfoTypeMapper

    <UIUtils.RenderIf condition={initialRule->Belt.Option.isSome}>
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
      let newRule = existingRules[index]->Belt.Option.getWithDefault(Js.Json.null)
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
        let rule = ruleInput.value->Js.Json.decodeArray->Belt.Option.getWithDefault([])
        let keyExtractor = (index, _rule, isDragging) => {
          let id = {`algorithm.rules[${string_of_int(index)}]`}
          <AdvancedRouting.Wrapper
            key={index->string_of_int}
            id
            heading={`Rule ${string_of_int(index + 1)}`}
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
  let (formState, setFormState) = React.useState(_ => AdvancedRoutingTypes.EditReplica)
  let showPopUp = PopUpState.useShowPopUp()
  let (showWarning, setShowWarning) = React.useState(_ => true)

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
          ("name", responseDict->LogicUtils.getString("name", "")->Js.Json.string),
          ("description", responseDict->LogicUtils.getString("description", "")->Js.Json.string),
          ("algorithm", programValue->Js.Json.object_),
        ]->Dict.fromArray

      setInitialRule(_ => Some(intitialValue))
    } catch {
    | Js.Exn.Error(e) =>
      let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Something went wrong")
      Js.Exn.raiseError(err)
    }
  }

  let fetchDetails = async () => {
    try {
      setScreenState(_ => Loading)
      await getWasm()
      await activeRoutingDetails()
      setScreenState(_ => Success)
    } catch {
    | Js.Exn.Error(e) => {
        let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Something went wrong")
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
      let _ = await updateDetails(getActivateUrl, surchargePayload->Identity.genericTypeToJson, Put)
      fetchDetails()->ignore
      setShowWarning(_ => true)
      RescriptReactRouter.replace(`/surcharge`)
      setPageView(_ => LANDING)
      setScreenState(_ => Success)
    } catch {
    | Js.Exn.Error(e) =>
      let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Failed to Fetch!")
      showToast(~message=err, ~toastType=ToastError, ())
    }
    Js.Nullable.null
  }

  let validate = (values: Js.Json.t) => {
    let dict = values->LogicUtils.getDictFromJsonObject

    let errors = Dict.make()

    RoutingUtils.validateNameAndDescription(~dict, ~errors)

    switch dict->Dict.get("algorithm")->Belt.Option.flatMap(Js.Json.decodeObject) {
    | Some(jsonDict) => {
        let rules = jsonDict->LogicUtils.getArrayFromDict("rules", [])
        if rules->Array.length === 0 {
          errors->Dict.set(`Rules`, "Minimum 1 rule needed"->Js.Json.string)
        } else {
          rules->Array.forEachWithIndex((rule, i) => {
            let ruleDict = rule->LogicUtils.getDictFromJsonObject

            if !validateConditionsForSurcharge(ruleDict) {
              errors->Dict.set(
                `Rule ${(i + 1)->string_of_int} - Condition`,
                `Invalid`->Js.Json.string,
              )
            }
          })
        }
      }

    | None => ()
    }
    errors->Js.Json.object_
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
      <PageUtils.PageHeading title={"Surcharge"} subTitle="Add your surcharge" />
      {switch pageView {
      | NEW =>
        <div className="w-full border p-8 bg-white rounded-md ">
          <Form initialValues validate formClass="flex flex-col gap-6 justify-between" onSubmit>
            <BasicDetailsForm formState setFormState isThreeDs=true />
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
              {"Add Surcharge"->React.string}
            </p>
            <p className="text-base font-normal text-grey-700 opacity-50">
              {"Surcharge info description can come here"->React.string}
            </p>
            <Button
              text="Create New"
              buttonType={Primary}
              customButtonStyle="!w-1/6"
              leftIcon={FontAwesome("plus")}
              onClick={_ => handleCreateNew()}
            />
          </div>
        </div>
      }}
    </div>
  </PageLoaderWrapper>
}
