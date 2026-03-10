open APIUtils
open RoutingTypes
open AdvancedRoutingUtils
open LogicUtils

external toWasm: Dict.t<JSON.t> => RoutingTypes.wasmModule = "%identity"

module Add3DSCondition = {
  @react.component
  let make = (~isFirst, ~id, ~isExpanded, ~threeDsType) => {
    let classStyle = "flex justify-center relative py-2.5 h-fit min-w-min hover:bg-jp-2-light-gray-100 focus:outline-none  rounded-md items-center border-2 border-border_gray border-opacity-50 text-jp-2-light-gray-1200 px-4 transition duration-[250ms] ease-out-[cubic-bezier(0.33, 1, 0.68, 1)] overflow-hidden"

    let options: array<SelectBox.dropdownOption> = [
      {value: "three_ds", label: "3DS"},
      {value: "no_three_ds", label: "No 3DS"},
    ]

    if isExpanded {
      <div className="flex flex-row ml-2">
        <RenderIf condition={!isFirst}>
          <div className="w-8 h-10 border-jp-gray-700 ml-10 border-dashed border-b border-l " />
        </RenderIf>
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
                  ~customButtonStyle=`!-mt-5 ${classStyle} !py-0 !rounded-md`,
                  ~deselectDisable=true,
                ),
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

module Add3DSConditionForThreeDsExemption = {
  @react.component
  let make = (~isFirst, ~id, ~isExpanded, ~threeDsType) => {
    let classStyle = "flex justify-center relative py-2.5 h-fit min-w-min hover:bg-jp-2-light-gray-100 focus:outline-none  rounded-md items-center border-2 border-border_gray border-opacity-50 text-jp-2-light-gray-1200 px-4 transition duration-[250ms] ease-out-[cubic-bezier(0.33, 1, 0.68, 1)] overflow-hidden"

    let options: array<SelectBox.dropdownOption> = [
      {value: "no_three_ds", label: "Request No-3DS"},
      {value: "challenge_requested", label: "Mandate 3DS Challenge"},
      {value: "challenge_preferred", label: "Prefer 3DS Challenge"},
      {value: "three_ds_exemption_requested_tra", label: "Request 3DS Exemption, Type: TRA"},
      {
        value: "three_ds_exemption_requested_low_value",
        label: "Request 3DS Exemption, Type: Low Value Transaction",
      },
      {value: "issuer_three_ds_exemption_requested", label: "No challenge requested"},
    ]

    if isExpanded {
      <div className="flex flex-row ml-2">
        <RenderIf condition={!isFirst}>
          <div className="w-8 h-10 border-jp-gray-700 ml-10 border-dashed border-b border-l " />
        </RenderIf>
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
                  ~customButtonStyle=`!-mt-5 ${classStyle} !py-0 !rounded-md`,
                  ~deselectDisable=true,
                ),
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

    React.useEffect(() => {
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
          <RenderIf condition={!isFirst}>
            <div className="w-8 h-10 border-jp-gray-700 ml-10 border-dashed border-b border-l " />
          </RenderIf>
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
                    ~customButtonStyle=`!-mt-5 ${classStyle} !p-0 !rounded-md`,
                    ~deselectDisable=true,
                    ~textStyle="!px-2 !py-2",
                  ),
                )}
              />
              <FormRenderer.FieldRenderer
                field={FormRenderer.makeFieldInfo(
                  ~label="",
                  ~name=`${id}.connectorSelection.surcharge_details.surcharge.value.${surchargeValueType}`,
                  ~customInput=InputFields.numericTextInput(~customStyle="!-mt-5", ~precision=2),
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
                  ),
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
    ~isFrom3DsExemptions=false,
  ) => {
    let {globalUIConfig: {border: {borderColor}}} = React.useContext(ThemeProvider.themeContext)
    let showToast = ToastState.useShowToast()
    let isMobileView = MatchMedia.useMobileChecker()
    let (isExpanded, setIsExpanded) = React.useState(_ => true)
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
      if isFrom3ds || isFrom3DsExemptions {
        if threeDsType->String.length > 0 {
          setIsExpanded(p => !p)
        } else {
          showToast(~toastType=ToastWarning, ~message="Auth type not selected", ~autoClose=true)
        }
      } else if isFromSurcharge {
        if surchargeTypeValue > 0.0 {
          setIsExpanded(p => !p)
        } else {
          showToast(~toastType=ToastWarning, ~message="Invalid condition", ~autoClose=true)
        }
      } else {
        let gatewayArrPresent = gateWaysInput.value->getArrayFromJson([])->Array.length > 0
        if gatewayArrPresent && areValidConditions {
          setIsExpanded(p => !p)
        } else if gatewayArrPresent {
          showToast(~toastType=ToastWarning, ~message="Invalid Conditions", ~autoClose=true)
        } else {
          showToast(~toastType=ToastWarning, ~message="No Gateway Selected", ~autoClose=true)
        }
      }
    }

    React.useEffect(() => {
      name.onChange(heading->String.toLowerCase->titleToSnake->Identity.stringToFormReactEvent)

      let gatewayArrPresent = gateWaysInput.value->getArrayFromJson([])->Array.length > 0

      if gatewayArrPresent && areValidConditions {
        setIsExpanded(p => !p)
      }
      None
    }, [])

    let border = isDragging ? "border-dashed" : "border-solid"
    let flex = isExpanded ? "flex-col" : "flex-wrap items-center gap-4"
    let hoverCss = "transition-all duration-150 hover:bg-gray-200 active:scale-95 active:bg-gray-300 "
    let actionIconCss = "flex items-center justify-center p-2 bg-gray-100 dark:bg-jp-gray-970 rounded-xl border border-jp-gray-600 cursor-pointer h-8"
    let actions =
      <div className={`flex flex-row gap-3 md:gap-4 mr-4 w-1/3 items-center justify-end `}>
        <RenderIf condition={notFirstRule}>
          <ToolTip
            description="Drag Rule"
            toolTipFor={<div className={`${actionIconCss} ${hoverCss}`}>
              <Icon name="grip-vertical" className="text-jp-gray-700" size={14} />
            </div>}
            toolTipPosition=Top
          />
        </RenderIf>
        <ToolTip
          description="Add New Rule"
          toolTipFor={<div onClick={onClickAdd} className={`${actionIconCss} ${hoverCss}`}>
            <Icon name="plus" className="text-jp-gray-700" size={14} />
          </div>}
          toolTipPosition=Top
        />
        {switch onClickCopy {
        | Some(onClick) =>
          <ToolTip
            description="Copy Rule"
            toolTipFor={<div onClick={onClick} className={`${actionIconCss} ${hoverCss}`}>
              <Icon name="nd-copy" className="text-jp-gray-700" size={12} />
            </div>}
            toolTipPosition=Top
          />

        | None => React.null
        }}
        <RenderIf condition={notFirstRule}>
          <ToolTip
            description="Delete Rule"
            toolTipFor={<div onClick={onClickRemove} className={`${actionIconCss} ${hoverCss}`}>
              <Icon name="trash" className="text-jp-gray-700" size={12} />
            </div>}
            toolTipPosition=Top
          />
        </RenderIf>
      </div>

    <div className="flex flex-col">
      <div className={`flex flex-row tems-center justify-between z-10 -mt-6 mx-2`}>
        <RenderIf condition={!isMobileView}>
          <div className="hidden lg:flex w-1/3" />
        </RenderIf>
        <div
          onClick={handleClickExpand}
          className={`cursor-pointer flex flex-row gap-2 items-center justify-between p-2 bg-blue-100 dark:bg-jp-gray-970 rounded-xl border ${borderColor.primaryNormal} dark:${borderColor.primaryNormal}`}>
          <div className="font-semibold pl-2 text-sm md:text-base"> {React.string(heading)} </div>
          <Icon name={isExpanded ? "angle-up" : "angle-down"} size={isMobileView ? 14 : 16} />
        </div>
        {actions}
      </div>
      <div
        style={marginTop: "-17px"}
        className={`flex 
        ${flex} 
            p-4 py-6 bg-gray-50 dark:bg-jp-gray-lightgray_background rounded-md border 
            ${border} 
            ${borderColor.primaryNormal}`}>
        <RenderIf condition={!isFirst}>
          <AdvancedRoutingUIUtils.MakeRuleField
            id isExpanded wasm isFrom3ds isFromSurcharge isFrom3DsExemptions
          />
        </RenderIf>
        <RenderIf condition={!isFrom3ds && !isFromSurcharge && !isFrom3DsExemptions}>
          <AddRuleGateway id gatewayOptions isExpanded isFirst />
        </RenderIf>
        <RenderIf condition={isFrom3ds}>
          <Add3DSCondition isFirst id isExpanded threeDsType />
        </RenderIf>
        <RenderIf condition={isFrom3DsExemptions}>
          <Add3DSConditionForThreeDsExemption isFirst id isExpanded threeDsType />
        </RenderIf>
        <RenderIf condition={isFromSurcharge}>
          <AddSurchargeCondition
            isFirst id isExpanded surchargeType surchargeTypeValue surchargePercentage
          />
        </RenderIf>
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
    let {globalUIConfig: {font: {textColor}}} = React.useContext(ThemeProvider.themeContext)
    let rulesJsonPath = `algorithm.data.rules`
    let showToast = ToastState.useShowToast()
    let ruleInput = ReactFinalForm.useField(rulesJsonPath).input
    let (rules, setRules) = React.useState(_ => ruleInput.value->getArrayFromJson([]))

    React.useEffect(() => {
      ruleInput.onChange(rules->Identity.arrayOfGenericTypeToFormReactEvent)
      None
    }, [rules])

    let isEmptyRule = rule => {
      defaultRule->Identity.genericTypeToJson->getDictFromJsonObject->Dict.delete("name")
      rule->getDictFromJsonObject->Dict.delete("name")
      defaultRule->Identity.genericTypeToJson == rule
    }

    let addRule = (index, copy) => {
      let existingRules = ruleInput.value->getArrayFromJson([])
      if !copy && existingRules->Array.some(isEmptyRule) {
        showToast(
          ~message="Unable to add a new rule while an empty rule exists!",
          ~toastType=ToastState.ToastError,
        )
      } else if copy {
        switch existingRules[index] {
        | Some(rule) =>
          if isEmptyRule(rule) {
            showToast(
              ~message="Unable to copy an empty rule configuration!",
              ~toastType=ToastState.ToastError,
            )
          } else {
            let newRule = rule->Identity.genericTypeToJson
            let newRules = existingRules->Array.concat([newRule])
            ruleInput.onChange(newRules->Identity.arrayOfGenericTypeToFormReactEvent)
          }
        | None => ()
        }
      } else {
        let newRule = defaultRule->Identity.genericTypeToJson
        let newRules = existingRules->Array.concat([newRule])
        ruleInput.onChange(newRules->Identity.arrayOfGenericTypeToFormReactEvent)
      }
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
          <div className="flex flex-col gap-4">
            <span className="w-full text-jp-gray-700 dark:text-jp-gray-700 text-justify">
              {"Rule-Based Configuration allows for detailed smart routing logic based on multiple dimensions of a payment. You can create any number of conditions using various dimensions and logical operators."->React.string}
            </span>
            <span className="flex flex-col text-jp-gray-700">
              {"For example:"->React.string}
              <p className="flex gap-2 items-center">
                <div className="p-1 h-fit rounded-full bg-jp-gray-700 ml-2" />
                {"If card_type = credit && amount > 100, route 60% to Stripe and 40% to Adyen."->React.string}
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
      {switch pageState {
      | Create =>
        <>
          {
            let notFirstRule = ruleInput.value->getArrayFromJson([])->Array.length > 1

            let rule = ruleInput.value->JSON.Decode.array->Option.getOr([])
            let keyExtractor = (index, _rule, isDragging, _) => {
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
                keyExtractor(index, rule, false, false)
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
              GlobalVars.appendDashboardPath(~url=`${baseUrlForRedirection}/default`),
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
  ~connectorList: array<ConnectorTypes.connectorPayloadCommonType>,
  ~urlEntityName,
  ~baseUrlForRedirection,
) => {
  let getURL = useGetURL()
  let url = RescriptReactRouter.useUrl()
  let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  let (profile, setProfile) = React.useState(_ => profileId)
  let getTimeInCustomTimeZone = TimeZoneHook.useGetTimeInCustomTimeZone()

  let (initialValues, setInitialValues) = React.useState(_ => {
    let currentTime = getTimeInCustomTimeZone("ddd, DD MMM YYYY HH:mm:ss", ~includeTimeZone=true)
    let currentDate = getTimeInCustomTimeZone("YYYY-MM-DD")
    getInitialValues(~currentDate, ~currentTime)->Identity.genericTypeToJson
  })
  let (initialRule, setInitialRule) = React.useState(() => None)
  let showToast = ToastState.useShowToast()
  let fetchDetails = useGetMethod()
  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (wasm, setWasm) = React.useState(_ => None)
  let (formState, setFormState) = React.useState(_ => EditReplica)
  let (connectors, setConnectors) = React.useState(_ => [])
  let (pageState, setPageState) = React.useState(() => Create)
  let (showModal, setShowModal) = React.useState(_ => false)
  let currentTabName = Recoil.useRecoilValueFromAtom(HyperswitchAtom.currentTabNameRecoilAtom)
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()

  let getConnectorsList = () => {
    setConnectors(_ =>
      connectorList->Array.filter(connector => connector.connector_name !== "applepay")
    )
  }

  let activeRoutingDetails = async () => {
    try {
      let routingUrl = getURL(~entityName=urlEntityName, ~methodType=Get, ~id=routingRuleId)
      let routingJson = await fetchDetails(routingUrl)
      let schemaValue = routingJson->getDictFromJsonObject
      let rulesValue = schemaValue->getObj("algorithm", Dict.make())->getDictfromDict("data")

      setInitialValues(_ => routingJson)
      setInitialRule(_ => Some(ruleInfoTypeMapper(rulesValue)))
      setProfile(_ => schemaValue->getString("profile_id", profileId))
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

  React.useEffect(() => {
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

    AdvancedRoutingUtils.validateNameAndDescription(
      ~dict,
      ~errors,
      ~validateFields=[Name, Description],
    )

    let validateGateways = (connectorData: array<RoutingTypes.connectorSelectionData>) => {
      if connectorData->Array.length === 0 {
        Some("Need at least 1 Gateway")
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
      let activateRuleURL = getURL(~entityName=urlEntityName, ~methodType=Post, ~id=activatingId)
      let _ = await updateDetails(activateRuleURL, Dict.make()->JSON.Encode.object, Post)
      showToast(~message="Successfully Activated !", ~toastType=ToastState.ToastSuccess)
      RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url=`${baseUrlForRedirection}?`))
      setScreenState(_ => Success)
    } catch {
    | Exn.Error(e) =>
      switch Exn.message(e) {
      | Some(message) =>
        if message->String.includes("IR_16") {
          showToast(~message="Algorithm is activated!", ~toastType=ToastState.ToastSuccess)
          RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url=baseUrlForRedirection))
          setScreenState(_ => Success)
        } else {
          showToast(
            ~message="Failed to Activate the Configuration!",
            ~toastType=ToastState.ToastError,
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

      let deactivateRoutingURL = `${getURL(~entityName=urlEntityName, ~methodType=Post)}/deactivate`
      let body = [("profile_id", profile->JSON.Encode.string)]->Dict.fromArray->JSON.Encode.object
      let _ = await updateDetails(deactivateRoutingURL, body, Post)
      showToast(~message="Successfully Deactivated !", ~toastType=ToastState.ToastSuccess)
      RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url=`${baseUrlForRedirection}?`))
      setScreenState(_ => Success)
    } catch {
    | Exn.Error(e) =>
      switch Exn.message(e) {
      | Some(message) => {
          showToast(
            ~message="Failed to Deactivate the Configuration!",
            ~toastType=ToastState.ToastError,
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
              connectorList->ConnectorInterfaceTableEntity.getConnectorObjectFromListViaId(
                id,
                ~version=V1,
              )
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

      let getActivateUrl = getURL(~entityName=urlEntityName, ~methodType=Post, ~id=None)
      let response = await updateDetails(getActivateUrl, payload->Identity.genericTypeToJson, Post)

      showToast(
        ~message="Successfully Created a new Configuration !",
        ~toastType=ToastState.ToastSuccess,
      )
      setScreenState(_ => Success)
      setShowModal(_ => false)
      if isSaveRule {
        RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url=baseUrlForRedirection))
      }
      Nullable.make(response)
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Failed to Fetch!")
      showToast(~message="Failed to Save the Configuration!", ~toastType=ToastState.ToastError)
      setShowModal(_ => false)
      setScreenState(_ => PageLoaderWrapper.Error(err))
      Exn.raiseError(err)
    }
  }

  let connectorType = switch url->RoutingUtils.urlToVariantMapper {
  | PayoutRouting => RoutingTypes.PayoutProcessor
  | _ => RoutingTypes.PaymentConnector
  }

  let connectorOptions = React.useMemo(() => {
    connectors
    ->RoutingUtils.filterConnectorList(~retainInList=connectorType)
    ->Array.filter(item => item.profile_id === profile)
    ->Array.map((item): SelectBox.dropdownOption => {
      {
        label: item.disabled ? `${item.connector_label} (disabled)` : item.connector_label,
        value: item.id,
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
                <RenderIf condition={formState != CreateConfig}>
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
                      <div className="flex flex-col md:flex-row gap-4 p-1">
                        <ACLButton
                          text={"Duplicate and Edit Configuration"}
                          buttonType={isActive ? Primary : Secondary}
                          authorization={userHasAccess(~groupAccess=WorkflowsManage)}
                          onClick={_ => {
                            setPageState(_ => Create)
                            let manipualtedJSONValue =
                              initialValues->DuplicateAndEditUtils.manipulateInitialValuesForDuplicate

                            let rulesValue =
                              manipualtedJSONValue
                              ->getDictFromJsonObject
                              ->getObj("algorithm", Dict.make())
                              ->getDictfromDict("data")

                            setInitialValues(_ =>
                              initialValues->DuplicateAndEditUtils.manipulateInitialValuesForDuplicate
                            )
                            setInitialRule(_ => Some(ruleInfoTypeMapper(rulesValue)))
                          }}
                          customButtonStyle="w-1/5"
                          buttonState=Normal
                        />
                        <RenderIf condition={!isActive}>
                          <ACLButton
                            text={"Activate Configuration"}
                            buttonType={Primary}
                            authorization={userHasAccess(~groupAccess=WorkflowsManage)}
                            onClick={_ => {
                              handleActivateConfiguration(routingRuleId)->ignore
                            }}
                            customButtonStyle="w-1/5"
                            buttonState=Normal
                          />
                        </RenderIf>
                        <RenderIf condition={isActive}>
                          <ACLButton
                            text={"Deactivate Configuration"}
                            buttonType={Secondary}
                            authorization={userHasAccess(~groupAccess=WorkflowsManage)}
                            onClick={_ => {
                              handleDeactivateConfiguration()->ignore
                            }}
                            customButtonStyle="w-1/5"
                            buttonState=Normal
                          />
                        </RenderIf>
                      </div>
                    | Create => <RoutingUtils.ConfigureRuleButton setShowModal />
                    | _ => React.null
                    }}
                  </div>
                </RenderIf>
                <CustomModal.RoutingCustomModal
                  showModal
                  setShowModal
                  cancelButton={<FormRenderer.SubmitButton
                    text="Save Rule"
                    buttonSize=Button.Small
                    buttonType=Button.Secondary
                    customSumbitButtonStyle="w-1/5 rounded-xl"
                    tooltipWidthClass="w-48"
                  />}
                  submitButton={<AdvancedRoutingUIUtils.SaveAndActivateButton
                    onSubmit handleActivateConfiguration
                  />}
                  headingText="Activate Current Configuration?"
                  subHeadingText="Activating this configuration will override the current one. Alternatively, save it to access later from the configuration history. Please confirm."
                  leftIcon="warning-modal"
                  iconSize=35
                />
              </div>
            </div>
          </Form>
        : <NoDataFound message="Please configure at least 1 connector" renderType=InfoBox />}
    </PageLoaderWrapper>
  </div>
}
