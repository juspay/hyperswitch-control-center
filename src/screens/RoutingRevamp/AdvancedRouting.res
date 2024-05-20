open APIUtils
open AdvancedRoutingTypes
open AdvancedRoutingUtils
open LogicUtils

external toWasm: Dict.t<JSON.t> => RoutingTypes.wasmModule = "%identity"

module Add3DSCondition = {
  @react.component
  let make = (~isFirst, ~id, ~isExpanded, ~threeDsType) => {
    let classStyle = "flex justify-center relative py-2 h-fit min-w-min hover:bg-jp-2-light-gray-100 focus:outline-none  rounded-md items-center border-2 border-border_gray border-opacity-50 text-jp-2-light-gray-1200 px-4 transition duration-[250ms] ease-out-[cubic-bezier(0.33, 1, 0.68, 1)] overflow-hidden"

    let options: array<SelectBox.dropdownOption> = [
      {value: "three_ds", label: "3DS"},
      {value: "no_three_ds", label: "No 3DS"},
    ]

    if isExpanded {
      <div className="flex flex-row ml-2">
        <UIUtils.RenderIf condition={!isFirst}>
          <div className="w-8 h-10 border-jp-gray-700 ml-10 border-dashed border-b border-l " />
        </UIUtils.RenderIf>
        <div className="flex flex-col gap-6 mt-6 mb-4 pt-0.5">
          <div className="flex flex-wrap gap-4 -mt-2">
            <div className=classStyle> {"Auth type"->React.string} </div>
            <div className=classStyle> {"= is Equal to"->React.string} </div>
            <FormRenderer.FieldRenderer
              field={FormRenderer.makeFieldInfo(
                ~label="",
                ~name=`${id}.connectorSelection.override_3ds`,
                ~customInput=InputFields.selectInput(
                  ~options,
                  ~buttonText="Select Field",
                  ~customButtonStyle=`!-mt-5 ${classStyle} !rounded-md`,
                  ~deselectDisable=true,
                  (),
                ),
                (),
              )}
            />
          </div>
        </div>
      </div>
    } else {
      <RulePreviewer.ThreedsTypeView threeDsType />
    }
  }
}

module AddSurchargeCondition = {
  let classStyle = "flex justify-center relative py-2 h-fit min-w-min hover:bg-jp-2-light-gray-100 focus:outline-none  rounded-md items-center border-2 border-border_gray border-opacity-50 text-jp-2-light-gray-1200 px-4 transition duration-[250ms] ease-out-[cubic-bezier(0.33, 1, 0.68, 1)] overflow-hidden"

  //keep the rate only for now.
  let options: array<SelectBox.dropdownOption> = [
    {value: "rate", label: "Rate"},
    {value: "fixed", label: "Fixed"},
  ]

  @react.component
  let make = (
    ~isFirst,
    ~id,
    ~isExpanded,
    ~surchargeType,
    ~surchargeTypeValue,
    ~surchargePercentage,
  ) => {
    let (surchargeValueType, setSurchargeValueType) = React.useState(_ => "")
    let surchargeTypeInput = ReactFinalForm.useField(
      `${id}.connectorSelection.surcharge_details.surcharge.type`,
    ).input

    React.useEffect1(() => {
      let valueType = switch surchargeTypeInput.value->LogicUtils.getStringFromJson("") {
      | "rate" => "percentage"
      | "fixed" => "amount"
      | _ => "percentage"
      }
      setSurchargeValueType(_ => valueType)
      None
    }, [surchargeTypeInput.value])

    {
      if isExpanded {
        <div className="flex flex-row ml-2">
          <UIUtils.RenderIf condition={!isFirst}>
            <div className="w-8 h-10 border-jp-gray-700 ml-10 border-dashed border-b border-l " />
          </UIUtils.RenderIf>
          <div className="flex flex-col gap-6 mt-6 mb-4 pt-0.5">
            <div className="flex flex-wrap gap-4">
              <div className=classStyle> {"Surcharge is"->React.string} </div>
              <FormRenderer.FieldRenderer
                field={FormRenderer.makeFieldInfo(
                  ~label="",
                  ~name=`${id}.connectorSelection.surcharge_details.surcharge.type`,
                  ~customInput=InputFields.selectInput(
                    ~options,
                    ~buttonText="Select Surcharge Type",
                    ~customButtonStyle=`!-mt-5 ${classStyle} !rounded-md`,
                    ~deselectDisable=true,
                    (),
                  ),
                  (),
                )}
              />
              <FormRenderer.FieldRenderer
                field={FormRenderer.makeFieldInfo(
                  ~label="",
                  ~name=`${id}.connectorSelection.surcharge_details.surcharge.value.${surchargeValueType}`,
                  ~customInput=InputFields.numericTextInput(
                    ~customStyle="!-mt-5",
                    ~precision=2,
                    (),
                  ),
                  (),
                )}
              />
            </div>
            <div className="flex flex-wrap gap-4">
              <div className=classStyle> {"Tax on Surcharge"->React.string} </div>
              <FormRenderer.FieldRenderer
                field={FormRenderer.makeFieldInfo(
                  ~label="",
                  ~name=`${id}.connectorSelection.surcharge_details.tax_on_surcharge.percentage`,
                  ~customInput=InputFields.numericTextInput(
                    ~precision=2,
                    ~customStyle="!-mt-5",
                    ~rightIcon=<Icon name="percent" size=16 />,
                    ~rightIconCustomStyle="-ml-7 -mt-5",
                    (),
                  ),
                  (),
                )}
              />
            </div>
          </div>
        </div>
      } else {
        <RulePreviewer.SurchargeCompressedView
          surchargeType surchargeTypeValue surchargePercentage
        />
      }
    }
  }
}
module Wrapper = {
  @react.component
  let make = (
    ~id,
    ~heading,
    ~onClickAdd,
    ~onClickCopy=?,
    ~onClickRemove,
    ~gatewayOptions,
    ~isFirst=false,
    ~notFirstRule=true,
    ~isDragging=false,
    ~wasm,
    ~isFrom3ds=false,
    ~isFromSurcharge=false,
  ) => {
    let {globalUIConfig: {border: {borderColor}}} = React.useContext(ConfigContext.configContext)
    let showToast = ToastState.useShowToast()
    let isMobileView = MatchMedia.useMobileChecker()
    let (isExpanded, setIsExpanded) = React.useState(_ => true)
    let (addBtnHover, setAddBtnHover) = React.useState(_ => false)
    let (dragBtnHover, setDragBtnHover) = React.useState(_ => false)
    let (copyBtnHover, setCopyBtnHover) = React.useState(_ => false)
    let (deleteBtnHover, setDeleteBtnHover) = React.useState(_ => false)
    let gateWaysInput = ReactFinalForm.useField(`${id}.connectorSelection.data`).input
    let name = ReactFinalForm.useField(`${id}.name`).input
    let conditionsInput = ReactFinalForm.useField(`${id}.statements`).input
    let threeDsType =
      ReactFinalForm.useField(
        `${id}.connectorSelection.override_3ds`,
      ).input.value->getStringFromJson("")

    let surchargeType =
      ReactFinalForm.useField(
        `${id}.connectorSelection.surcharge_details.surcharge.type`,
      ).input.value->getStringFromJson("")
    let surchargePercentage =
      ReactFinalForm.useField(
        `${id}.connectorSelection.surcharge_details.tax_on_surcharge.percentage`,
      ).input.value->getOptionFloatFromJson
    let surchargeValue =
      ReactFinalForm.useField(
        `${id}.connectorSelection.surcharge_details.surcharge.value`,
      ).input.value->getDictFromJsonObject

    let surchargePercent = surchargeValue->getFloat("percentage", 0.0)
    let surchargeAmount = surchargeValue->getFloat("amount", 0.0)
    let surchargeTypeValue = if surchargeAmount > 0.0 {
      surchargeAmount
    } else {
      surchargePercent
    }

    let areValidConditions =
      conditionsInput.value
      ->getArrayFromJson([])
      ->Array.every(ele =>
        ele->getDictFromJsonObject->statementTypeMapper->isStatementMandatoryFieldsPresent
      )

    let handleClickExpand = _ => {
      if isFrom3ds {
        if threeDsType->String.length > 0 {
          setIsExpanded(p => !p)
        } else {
          showToast(~toastType=ToastWarning, ~message="Auth type not selected", ~autoClose=true, ())
        }
      } else if isFromSurcharge {
        if surchargeTypeValue > 0.0 {
          setIsExpanded(p => !p)
        } else {
          showToast(~toastType=ToastWarning, ~message="Invalid condition", ~autoClose=true, ())
        }
      } else {
        let gatewayArrPresent = gateWaysInput.value->getArrayFromJson([])->Array.length > 0
        if gatewayArrPresent && areValidConditions {
          setIsExpanded(p => !p)
        } else if gatewayArrPresent {
          showToast(~toastType=ToastWarning, ~message="Invalid Conditions", ~autoClose=true, ())
        } else {
          showToast(~toastType=ToastWarning, ~message="No Gateway Selected", ~autoClose=true, ())
        }
      }
    }

    React.useEffect0(() => {
      name.onChange(heading->String.toLowerCase->titleToSnake->Identity.stringToFormReactEvent)

      let gatewayArrPresent = gateWaysInput.value->getArrayFromJson([])->Array.length > 0

      if gatewayArrPresent && areValidConditions {
        setIsExpanded(p => !p)
      }
      None
    })

    let border = isDragging ? "border-dashed" : "border-solid"
    let flex = isExpanded ? "flex-col" : "flex-wrap items-center gap-4"

    let actions =
      <div
        className={`flex flex-row gap-3 md:gap-10 items-center justify-end
        ${isMobileView ? "" : "w-1/3 mr-6"}`}>
        <UIUtils.RenderIf condition={notFirstRule}>
          <div
            onMouseEnter={_ => setDragBtnHover(_ => !isMobileView)}
            onMouseLeave={_ => setDragBtnHover(_ => false)}
            className={`flex flex-row gap-2 items-center justify-around p-2 ${dragBtnHover
                ? "py-1"
                : ""} bg-gray-100 dark:bg-jp-gray-970 rounded-full border border-jp-gray-600 cursor-pointer`}>
            <Icon name="grip-vertical" className="text-jp-gray-700" size=14 />
            <UIUtils.RenderIf condition={dragBtnHover}>
              <div className="text-sm "> {React.string("Drag Rule")} </div>
            </UIUtils.RenderIf>
          </div>
        </UIUtils.RenderIf>
        <div
          onClick=onClickAdd
          onMouseEnter={_ => setAddBtnHover(_ => !isMobileView)}
          onMouseLeave={_ => setAddBtnHover(_ => false)}
          className={`flex flex-row gap-2 items-center justify-around p-2 ${addBtnHover
              ? "py-1"
              : ""} bg-gray-100 dark:bg-jp-gray-970 rounded-full border border-jp-gray-600 cursor-pointer`}>
          <Icon name="plus" className="text-jp-gray-700" size=12 />
          <UIUtils.RenderIf condition={addBtnHover}>
            <div className="text-sm "> {React.string("Add New Rule")} </div>
          </UIUtils.RenderIf>
        </div>
        {switch onClickCopy {
        | Some(onClick) =>
          <div
            onClick
            onMouseEnter={_ => setCopyBtnHover(_ => !isMobileView)}
            onMouseLeave={_ => setCopyBtnHover(_ => false)}
            className={`flex flex-row gap-2 items-center justify-around p-2 ${copyBtnHover
                ? "py-1"
                : ""} bg-gray-100 dark:bg-jp-gray-970 rounded-full border border-jp-gray-600 cursor-pointer`}>
            <Icon name="copy" className="text-jp-gray-700" size=12 />
            <UIUtils.RenderIf condition={copyBtnHover}>
              <div className="text-sm "> {React.string("Copy Rule")} </div>
            </UIUtils.RenderIf>
          </div>
        | None => React.null
        }}
        <UIUtils.RenderIf condition={notFirstRule}>
          <div
            onClick=onClickRemove
            onMouseEnter={_ => setDeleteBtnHover(_ => !isMobileView)}
            onMouseLeave={_ => setDeleteBtnHover(_ => false)}
            className={`flex flex-row gap-2 items-center justify-around p-2 ${deleteBtnHover
                ? "py-1"
                : ""} bg-gray-100 dark:bg-jp-gray-970 rounded-full border border-jp-gray-600 cursor-pointer`}>
            <Icon name="trash" className="text-jp-gray-700" size=12 />
            <UIUtils.RenderIf condition={deleteBtnHover}>
              <div className="text-sm "> {React.string("Delete Rule")} </div>
            </UIUtils.RenderIf>
          </div>
        </UIUtils.RenderIf>
      </div>

    <div className="flex flex-col">
      <div className={`flex flex-row tems-center justify-between z-10 -mt-6 mx-2`}>
        <UIUtils.RenderIf condition={!isMobileView}>
          <div className="hidden lg:flex w-1/3" />
        </UIUtils.RenderIf>
        <div
          onClick={handleClickExpand}
          className={`cursor-pointer flex flex-row gap-2 items-center justify-between p-2 bg-blue-100 dark:bg-jp-gray-970 rounded-full border ${borderColor.primaryNormal} dark:${borderColor.primaryNormal}`}>
          <div className="font-semibold pl-2 text-sm md:text-base"> {React.string(heading)} </div>
          <Icon name={isExpanded ? "angle-up" : "angle-down"} size={isMobileView ? 14 : 16} />
        </div>
        {actions}
      </div>
      <div
        style={ReactDOMStyle.make(~marginTop="-17px", ())}
        className={`flex 
        ${flex} 
            p-4 py-6 bg-gray-50 dark:bg-jp-gray-lightgray_background rounded-md border 
            ${border} 
            ${borderColor.primaryNormal}`}>
        <UIUtils.RenderIf condition={!isFirst}>
          <AdvancedRoutingUIUtils.MakeRuleField id isExpanded wasm isFrom3ds isFromSurcharge />
        </UIUtils.RenderIf>
        <UIUtils.RenderIf condition={!isFrom3ds && !isFromSurcharge}>
          <AddRuleGateway id gatewayOptions isExpanded isFirst />
        </UIUtils.RenderIf>
        <UIUtils.RenderIf condition={isFrom3ds}>
          <Add3DSCondition isFirst id isExpanded threeDsType />
        </UIUtils.RenderIf>
        <UIUtils.RenderIf condition={isFromSurcharge}>
          <AddSurchargeCondition
            isFirst id isExpanded surchargeType surchargeTypeValue surchargePercentage
          />
        </UIUtils.RenderIf>
      </div>
    </div>
  }
}

module RuleBasedUI = {
  @react.component
  let make = (
    ~gatewayOptions,
    ~wasm,
    ~initialRule,
    ~pageState,
    ~setCurrentRouting,
    ~baseUrlForRedirection,
  ) => {
    let {globalUIConfig: {font: {textColor}}} = React.useContext(ConfigContext.configContext)
    let rulesJsonPath = `algorithm.data.rules`
    let ruleInput = ReactFinalForm.useField(rulesJsonPath).input
    let (rules, setRules) = React.useState(_ => ruleInput.value->getArrayFromJson([]))

    React.useEffect1(() => {
      ruleInput.onChange(rules->Identity.arrayOfGenericTypeToFormReactEvent)
      None
    }, [rules])

    let addRule = (index, copy) => {
      let existingRules = ruleInput.value->getArrayFromJson([])
      let newRule = copy
        ? existingRules[index]->Option.getOr(defaultRule->Identity.genericTypeToJson)
        : defaultRule->Identity.genericTypeToJson
      let newRules = existingRules->Array.concat([newRule])
      ruleInput.onChange(newRules->Identity.arrayOfGenericTypeToFormReactEvent)
    }

    let removeRule = index => {
      let existingRules = ruleInput.value->getArrayFromJson([])
      let newRules = existingRules->Array.filterWithIndex((_, i) => i !== index)
      ruleInput.onChange(newRules->Identity.arrayOfGenericTypeToFormReactEvent)
    }

    <div className="flex flex-col my-5">
      <div
        className={`flex flex-wrap items-center justify-between p-4 py-8 bg-white dark:bg-jp-gray-lightgray_background rounded-md border border-jp-gray-600 dark:border-jp-gray-850 
        `}>
        <div>
          <div className="font-bold"> {React.string("Rule Based Configuration")} </div>
          <div className="w-full text-jp-gray-700 dark:text-jp-gray-700 text-justify">
            {"Rule Based Configuration is useful when you prefer more granular definition of smart routing logic, based on multiple dimensions involved in a payment. Any number of conditions could be constructed with dimensions and logical operators.
For example: If card_type = credit && amount > 100, route 60% to Stripe and 40% to Adyen."->React.string}
          </div>
        </div>
      </div>
      {switch pageState {
      | Create =>
        <>
          {
            let notFirstRule = ruleInput.value->getArrayFromJson([])->Array.length > 1

            let rule = ruleInput.value->JSON.Decode.array->Option.getOr([])
            let keyExtractor = (index, _rule, isDragging) => {
              let id = {`${rulesJsonPath}[${Int.toString(index)}]`}

              <Wrapper
                key={index->Int.toString}
                id
                heading={`Rule ${Int.toString(index + 1)}`}
                onClickAdd={_ => addRule(index, false)}
                onClickCopy={_ => addRule(index, true)}
                onClickRemove={_ => removeRule(index)}
                gatewayOptions
                notFirstRule
                isDragging
                wasm
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
        </>

      | Preview =>
        switch initialRule {
        | Some(ruleInfo) => <RulePreviewer ruleInfo />
        | None => React.null
        }
      | _ => React.null
      }}
      <div className="bg-white rounded-md flex gap-2 p-4 border-2">
        <p className="text-jp-gray-700 dark:text-jp-gray-700">
          {"In case the above rule fails, the routing will follow fallback routing. You can configure it"->React.string}
        </p>
        <p
          className={`${textColor.primaryNormal} cursor-pointer`}
          onClick={_ => {
            setCurrentRouting(_ => RoutingTypes.DEFAULTFALLBACK)
            RescriptReactRouter.replace(
              HSwitchGlobalVars.appendDashboardPath(~url=`${baseUrlForRedirection}/default`),
            )
          }}>
          {"here"->React.string}
        </p>
      </div>
    </div>
  }
}

@react.component
let make = (
  ~routingRuleId,
  ~isActive,
  ~setCurrentRouting,
  ~connectorList: array<ConnectorTypes.connectorPayload>,
  ~urlEntityName,
  ~baseUrlForRedirection,
) => {
  let getURL = useGetURL()
  let url = RescriptReactRouter.useUrl()
  let businessProfiles = Recoil.useRecoilValueFromAtom(HyperswitchAtom.businessProfilesAtom)
  let defaultBusinessProfile = businessProfiles->MerchantAccountUtils.getValueFromBusinessProfile
  let (profile, setProfile) = React.useState(_ => defaultBusinessProfile.profile_id)
  let (initialValues, setInitialValues) = React.useState(_ =>
    initialValues->Identity.genericTypeToJson
  )
  let (initialRule, setInitialRule) = React.useState(() => None)
  let showToast = ToastState.useShowToast()
  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod(~showErrorToast=false, ())
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (wasm, setWasm) = React.useState(_ => None)
  let (formState, setFormState) = React.useState(_ => EditReplica)
  let (connectors, setConnectors) = React.useState(_ => [])
  let (pageState, setPageState) = React.useState(() => Create)
  let (showModal, setShowModal) = React.useState(_ => false)
  let currentTabName = Recoil.useRecoilValueFromAtom(HyperswitchAtom.currentTabNameRecoilAtom)

  let getConnectorsList = () => {
    setConnectors(_ =>
      connectorList->Array.filter(connector => connector.connector_name !== "applepay")
    )
  }

  let activeRoutingDetails = async () => {
    try {
      let routingUrl = getURL(~entityName=urlEntityName, ~methodType=Get, ~id=routingRuleId, ())
      let routingJson = await fetchDetails(routingUrl)
      let schemaValue = routingJson->getDictFromJsonObject
      let rulesValue = schemaValue->getObj("algorithm", Dict.make())->getDictfromDict("data")

      setInitialValues(_ => routingJson)
      setInitialRule(_ => Some(ruleInfoTypeMapper(rulesValue)))
      setProfile(_ => schemaValue->getString("profile_id", defaultBusinessProfile.profile_id))
      setFormState(_ => ViewConfig)
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Something went wrong")
      Exn.raiseError(err)
    }
  }

  let getWasm = async () => {
    try {
      let wasmResult = await Window.connectorWasmInit()
      let wasm = wasmResult->getDictFromJsonObject->getObj("wasm", Dict.make())
      setWasm(_ => Some(wasm->toWasm))
    } catch {
    | _ => ()
    }
  }

  React.useEffect1(() => {
    let fetchDetails = async () => {
      try {
        setScreenState(_ => Loading)
        await getWasm()
        getConnectorsList()
        switch routingRuleId {
        | Some(_id) => {
            await activeRoutingDetails()
            setPageState(_ => Preview)
          }

        | None => setPageState(_ => Create)
        }
        setScreenState(_ => Success)
      } catch {
      | Exn.Error(e) => {
          let err = Exn.message(e)->Option.getOr("Something went wrong")
          setScreenState(_ => Error(err))
        }
      }
    }
    fetchDetails()->ignore
    None
  }, [routingRuleId])

  let validate = (values: JSON.t) => {
    let dict = values->LogicUtils.getDictFromJsonObject
    let convertedObject = values->AdvancedRoutingUtils.getRoutingTypesFromJson

    let errors = Dict.make()

    AdvancedRoutingUtils.validateNameAndDescription(~dict, ~errors)

    let validateGateways = (connectorData: array<AdvancedRoutingTypes.connectorSelectionData>) => {
      if connectorData->Array.length === 0 {
        Some("Need atleast 1 Gateway")
      } else {
        let isDistibuted = connectorData->Array.every(ele => {
          switch ele {
          | PriorityObject(_) => false
          | VolumeObject(_) => true
          }
        })

        if isDistibuted {
          let distributionPercentageSum =
            connectorData->Array.reduce(0, (sum, value) =>
              sum + value->AdvancedRoutingUtils.getSplitFromConnectorSelectionData
            )

          let hasZero =
            connectorData->Array.some(ele =>
              ele->AdvancedRoutingUtils.getSplitFromConnectorSelectionData === 0
            )
          let isDistributeChecked = !(
            connectorData->Array.some(ele => {
              ele->AdvancedRoutingUtils.getSplitFromConnectorSelectionData === 100
            })
          )

          let isNotValid =
            isDistributeChecked &&
            (distributionPercentageSum > 100 || hasZero || distributionPercentageSum !== 100)

          if isNotValid {
            Some("Distribution Percent not correct")
          } else {
            None
          }
        } else {
          None
        }
      }
    }

    let rulesArray = convertedObject.algorithm.data.rules

    if rulesArray->Array.length === 0 {
      errors->Dict.set(`Rules`, "Minimum 1 rule needed"->JSON.Encode.string)
    } else {
      rulesArray->Array.forEachWithIndex((rule, i) => {
        let connectorDetails = rule.connectorSelection.data->Option.getOr([])

        switch connectorDetails->validateGateways {
        | Some(error) =>
          errors->Dict.set(`Rule ${(i + 1)->Int.toString} - Gateway`, error->JSON.Encode.string)
        | None => ()
        }

        if !AdvancedRoutingUtils.validateStatements(rule.statements) {
          errors->Dict.set(
            `Rule ${(i + 1)->Int.toString} - Condition`,
            `Invalid`->JSON.Encode.string,
          )
        }
      })
    }

    errors->JSON.Encode.object
  }

  let handleActivateConfiguration = async activatingId => {
    try {
      setScreenState(_ => Loading)
      let activateRuleURL = getURL(
        ~entityName=urlEntityName,
        ~methodType=Post,
        ~id=activatingId,
        (),
      )
      let _ = await updateDetails(activateRuleURL, Dict.make()->JSON.Encode.object, Post, ())
      showToast(~message="Successfully Activated !", ~toastType=ToastState.ToastSuccess, ())
      RescriptReactRouter.replace(
        HSwitchGlobalVars.appendDashboardPath(~url=`${baseUrlForRedirection}?`),
      )
      setScreenState(_ => Success)
    } catch {
    | Exn.Error(e) =>
      switch Exn.message(e) {
      | Some(message) =>
        if message->String.includes("IR_16") {
          showToast(~message="Algorithm is activated!", ~toastType=ToastState.ToastSuccess, ())
          RescriptReactRouter.replace(
            HSwitchGlobalVars.appendDashboardPath(~url=baseUrlForRedirection),
          )
          setScreenState(_ => Success)
        } else {
          showToast(
            ~message="Failed to Activate the Configuration!",
            ~toastType=ToastState.ToastError,
            (),
          )
          setScreenState(_ => Error(message))
        }
      | None => setScreenState(_ => Error("Something went wrong"))
      }
    }
  }
  let handleDeactivateConfiguration = async _ => {
    try {
      setScreenState(_ => Loading)
      let deactivateRoutingURL = `${getURL(
          ~entityName=urlEntityName,
          ~methodType=Post,
          (),
        )}/deactivate`
      let body = [("profile_id", profile->JSON.Encode.string)]->Dict.fromArray->JSON.Encode.object
      let _ = await updateDetails(deactivateRoutingURL, body, Post, ())
      showToast(~message="Successfully Deactivated !", ~toastType=ToastState.ToastSuccess, ())
      RescriptReactRouter.replace(
        HSwitchGlobalVars.appendDashboardPath(~url=`${baseUrlForRedirection}?`),
      )
      setScreenState(_ => Success)
    } catch {
    | Exn.Error(e) =>
      switch Exn.message(e) {
      | Some(message) => {
          showToast(
            ~message="Failed to Deactivate the Configuration!",
            ~toastType=ToastState.ToastError,
            (),
          )
          setScreenState(_ => Error(message))
        }
      | None => setScreenState(_ => Error("Something went wrong"))
      }
    }
  }

  let onSubmit = async (values, isSaveRule) => {
    try {
      setScreenState(_ => Loading)
      let valuesDict = values->getDictFromJsonObject
      let dataDict = valuesDict->getDictfromDict("algorithm")->getDictfromDict("data")

      let rulesDict = dataDict->getArrayFromDict("rules", [])

      let modifiedRules = rulesDict->generateRule

      let defaultSelection =
        dataDict
        ->getDictfromDict("defaultSelection")
        ->getStrArrayFromDict("data", [])
        ->Array.map(id => {
          {
            "connector": (
              connectorList->ConnectorTableUtils.getConnectorObjectFromListViaId(id)
            ).connector_name,
            "merchant_connector_id": id,
          }
        })
      let payload = {
        "name": valuesDict->getString("name", ""),
        "description": valuesDict->getString("description", ""),
        "profile_id": valuesDict->getString("profile_id", ""),
        "algorithm": {
          "type": "advanced",
          "data": {
            "defaultSelection": {
              "type": "priority",
              "data": defaultSelection,
            },
            "metadata": dataDict->getJsonObjectFromDict("metadata"),
            "rules": modifiedRules,
          },
        },
      }

      let getActivateUrl = getURL(~entityName=urlEntityName, ~methodType=Post, ~id=None, ())
      let response = await updateDetails(
        getActivateUrl,
        payload->Identity.genericTypeToJson,
        Post,
        (),
      )

      showToast(
        ~message="Successfully Created a new Configuration !",
        ~toastType=ToastState.ToastSuccess,
        (),
      )
      setScreenState(_ => Success)
      setShowModal(_ => false)
      if isSaveRule {
        RescriptReactRouter.replace(
          HSwitchGlobalVars.appendDashboardPath(~url=baseUrlForRedirection),
        )
      }
      Nullable.make(response)
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      showToast(~message="Failed to Save the Configuration!", ~toastType=ToastState.ToastError, ())
      setShowModal(_ => false)
      setScreenState(_ => PageLoaderWrapper.Error(err))
      Exn.raiseError(err)
    }
  }

  let connectorType = switch url->RoutingUtils.urlToVariantMapper {
  | PayoutRouting => RoutingTypes.PayoutConnector
  | _ => RoutingTypes.PaymentConnector
  }

  let connectorOptions = React.useMemo2(() => {
    connectors
    ->RoutingUtils.filterConnectorList(~retainInList=connectorType)
    ->Array.filter(item => item.profile_id === profile)
    ->Array.map((item): SelectBox.dropdownOption => {
      {
        label: item.connector_label,
        value: item.merchant_connector_id,
      }
    })
  }, (profile, connectors->Array.length))

  <div className="my-6">
    <PageLoaderWrapper screenState>
      {connectors->Array.length > 0
        ? <Form
            initialValues={initialValues} validate onSubmit={(values, _) => onSubmit(values, true)}>
            <div className="w-full flex flex-row  justify-between">
              <div className="w-full">
                <BasicDetailsForm
                  formState={pageState == Preview ? ViewConfig : CreateConfig}
                  currentTabName
                  profile
                  setProfile
                />
                <UIUtils.RenderIf condition={formState != CreateConfig}>
                  <div className="mb-5">
                    <RuleBasedUI
                      gatewayOptions=connectorOptions
                      wasm
                      initialRule
                      pageState
                      setCurrentRouting
                      baseUrlForRedirection
                    />
                    {switch pageState {
                    | Preview =>
                      <div className="flex flex-col md:flex-row gap-4 my-5">
                        <UIUtils.RenderIf condition={!isActive}>
                          <Button
                            text={"Activate Configuration"}
                            buttonType={Primary}
                            onClick={_ => {
                              handleActivateConfiguration(routingRuleId)->ignore
                            }}
                            customButtonStyle="w-1/5 rounded-sm"
                            buttonState=Normal
                          />
                        </UIUtils.RenderIf>
                        <UIUtils.RenderIf condition={isActive}>
                          <Button
                            text={"Deactivate Configuration"}
                            buttonType={Primary}
                            onClick={_ => {
                              handleDeactivateConfiguration()->ignore
                            }}
                            customButtonStyle="w-1/5 rounded-sm"
                            buttonState=Normal
                          />
                        </UIUtils.RenderIf>
                      </div>
                    | Create => <RoutingUtils.ConfigureRuleButton setShowModal />
                    | _ => React.null
                    }}
                  </div>
                </UIUtils.RenderIf>
                <CustomModal.RoutingCustomModal
                  showModal
                  setShowModal
                  cancelButton={<FormRenderer.SubmitButton
                    text="Save Rule"
                    buttonSize=Button.Small
                    buttonType=Button.Secondary
                    customSumbitButtonStyle="w-1/5 rounded-lg"
                    tooltipWidthClass="w-48"
                  />}
                  submitButton={<AdvancedRoutingUIUtils.SaveAndActivateButton
                    onSubmit handleActivateConfiguration
                  />}
                  headingText="Activate Current Configuration?"
                  subHeadingText="Activating the current configuration will override the current active configuration. Alternatively, save this configuration to access / activate it later from the configuration history. Please confirm."
                  leftIcon="hswitch-warning"
                />
              </div>
            </div>
            <FormValuesSpy />
          </Form>
        : <NoDataFound message="Please configure atleast 1 connector" renderType=InfoBox />}
    </PageLoaderWrapper>
  </div>
}
