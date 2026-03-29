open APIUtils
open RoutingTypes
open VolumeSplitRoutingPreviewer
open LogicUtils

module IndividualConnectorSelect = {
  @react.component
  let make = (
    ~index: int, 
    ~split: int, 
    ~connectorOptions: array<SelectBox.dropdownOption>, 
    ~selectedMci: string,
    ~onChange: string => unit,
    ~connectorList: array<ConnectorTypes.connectorPayloadCommonType>,
  ) => {
    let isSelected = selectedMci !== ""
    
    let getConnectorLabel = mci => {
      switch connectorList->Array.find(c => c.id === mci) {
      | Some(connector) => connector.connector_label
      | None => mci
      }
    }
    
    <div className="flex flex-row items-center gap-4 p-3 border border-jp-gray-300 rounded-md bg-white">
      <div className="font-medium text-jp-gray-700">
        {React.string(`Slot ${(index + 1)->Int.toString}`)}
      </div>
      {if isSelected {
        // Show selected connector name instead of dropdown
        <div className="flex items-center gap-2 px-3 py-2 bg-jp-gray-100 rounded-md min-w-48">
          <span className="font-medium text-jp-gray-800">
            {React.string(selectedMci->getConnectorLabel)}
          </span>
          <Icon 
            name="close" 
            size=12 
            className="cursor-pointer text-jp-gray-500 hover:text-jp-gray-700"
            onClick={_ => onChange("")}
          />
        </div>
      } else {
        // Show dropdown for selection
        <SelectBox.BaseDropdown
          allowMultiSelect={false}
          input={{
            name: `connector-${index->Int.toString}`,
            onBlur: _ => (),
            onChange: ev => {
              let value = ev->Identity.formReactEventToString
              onChange(value)
            },
            onFocus: _ => (),
            value: ""->JSON.Encode.string,
            checked: true,
          }}
          options={connectorOptions}
          buttonText="Select Connector"
          buttonType={Button.SecondaryFilled}
          searchable=true
          hideMultiSelectButtons=true
          customButtonStyle="w-48"
        />
      }}
      <div className="flex items-center gap-1">
        <div className="w-16 text-right px-2 py-1 border border-jp-gray-300 rounded-md bg-jp-gray-50">
          <span className="font-medium">{React.string(split->Int.toString)}</span>
          <span className="text-jp-gray-600 ml-1">{React.string("%")}</span>
        </div>
      </div>
    </div>
  }
}

module VolumeRoutingView = {
  open RoutingUtils
  @react.component
  let make = (
    ~setScreenState,
    ~routingId,
    ~pageState,
    ~setPageState,
    ~connectors: array<ConnectorTypes.connectorPayloadCommonType>,
    ~isActive,
    ~profile,
    ~setFormState,
    ~initialValues,
    ~onSubmit,
    ~urlEntityName,
    ~connectorList,
    ~baseUrlForRedirection,
    ~clipboardData: clipboardValidationResult=?,
    ~onPasteConfiguration: ((clipboardRoutingData, ReactFinalForm.formApi) => unit)=?,
    ~pastedSplits: array<int>=[],
  ) => {
    let getURL = useGetURL()
    let updateDetails = useUpdateMethod(~showErrorToast=false)
    let showToast = ToastState.useShowToast()
    let form = ReactFinalForm.useForm()
    let listLength = connectors->Array.length
    let (showModal, setShowModal) = React.useState(_ => false)
    let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
    
    // Track selected MCIs for filtering dropdown options
    let (selectedMcis, setSelectedMcis) = React.useState(_ => [])
    
    // Sync selectedMcis when pastedSplits changes (e.g., after paste)
    React.useEffect(() => {
      if pastedSplits->Array.length > 0 {
        setSelectedMcis(_ => pastedSplits->Array.map(_ => ""))
      }
      None
    }, [pastedSplits])
    
    // Check if all pasted slots have connectors selected
    let allSlotsFilled = pastedSplits->Array.length === 0 || 
      selectedMcis->Array.every(mci => mci !== "")

    let gateways =
      initialValues
      ->getJsonObjectFromDict("algorithm")
      ->getDictFromJsonObject
      ->getArrayFromDict("data", [])

    let handleActivateConfiguration = async activatingId => {
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)
        let activateRuleURL = getURL(~entityName=urlEntityName, ~methodType=Post, ~id=activatingId)
        let _ = await updateDetails(activateRuleURL, Dict.make()->JSON.Encode.object, Post)
        showToast(~message="Successfully Activated !", ~toastType=ToastState.ToastSuccess)
        RescriptReactRouter.replace(
          GlobalVars.appendDashboardPath(~url=`${baseUrlForRedirection}?`),
        )
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
        let deactivateRoutingURL = `${getURL(
            ~entityName=urlEntityName,
            ~methodType=Post,
          )}/deactivate`
        let body = [("profile_id", profile->JSON.Encode.string)]->Dict.fromArray->JSON.Encode.object
        let _ = await updateDetails(deactivateRoutingURL, body, Post)
        showToast(~message="Successfully Deactivated !", ~toastType=ToastState.ToastSuccess)
        RescriptReactRouter.replace(
          GlobalVars.appendDashboardPath(~url=`${baseUrlForRedirection}?`),
        )
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

    let connectorOptions = React.useMemo(() => {
      connectors
      ->Array.filter(item => item.profile_id === profile)
      ->Array.map((item): SelectBox.dropdownOption => {
        {
          label: item.disabled ? `${item.connector_label} (disabled)` : item.connector_label,
          value: item.id,
        }
      })
    }, [profile])

    <>
      <div
        className="flex flex-col gap-4 p-6 my-2 bg-white dark:bg-jp-gray-lightgray_background rounded-md border border-jp-gray-600 dark:border-jp-gray-850">
        <div className="flex flex-col lg:flex-row  ">
          <div>
            <div className="font-bold mb-1"> {React.string("Volume Based Configuration")} </div>
            <div className="text-jp-gray-800 dark:text-jp-gray-700 text-sm">
              {"Volume Based Configuration is helpful when you want a specific traffic distribution for each of the configured connectors. For eg: Stripe (70%), Adyen (20%), Checkout (10%)."->React.string}
            </div>
          </div>
        </div>
      </div>
      <div className="flex w-full flex-start">
        {switch pageState {
        | Create =>
          <div className="flex flex-col gap-4">
            {switch clipboardData->Option.getOr(RoutingTypes.NotFound) {
            | Valid(data) =>
              let volumeSplits = {
                let algoDict = data.algorithm->Identity.genericTypeToJson->getDictFromJsonObject
                let dataArray = algoDict->getArrayFromDict("data", [])
                dataArray->Array.filterMap(json => {
                  switch json->JSON.Decode.object {
                  | Some(dict) => {
                      let split = dict->getInt("split", 0)
                      Some(split)
                    }
                  | None => None
                  }
                })
              }
              let splitsText = volumeSplits->Array.map(s => `${s->Int.toString}%`)->Array.joinWith(", ")
              <div
                className="flex flex-col gap-3 p-4 bg-blue-50 border border-blue-200 rounded-md">
                <div className="flex items-center gap-2">
                  <Icon name="nd-info" size=16 className="text-blue-600" />
                  <span className="font-medium text-blue-900">
                    {React.string("Paste configuration from another profile?")}
                  </span>
                </div>
                <div className="text-sm text-blue-700">
                  {React.string(
                    `Copy "${data.name}" from profile ${data.source_profile->String.slice(~start=0, ~end=8)}...`,
                  )}
                </div>
                <div className="text-sm font-medium text-blue-800 bg-blue-100 p-2 rounded">
                  {React.string(`Original volume splits: ${splitsText}`)}
                </div>
                <div className="flex gap-2">
                  <Button
                    text="Paste Configuration"
                    buttonType={Primary}
                    buttonSize={Small}
                    onClick={_ => {
                      switch onPasteConfiguration {
                      | Some(callback) => callback(data, form)
                      | None => ()
                      }
                    }}
                  />
                  <Button
                    text="Dismiss"
                    buttonType={Secondary}
                    buttonSize={Small}
                    onClick={_ => ()}
                  />
                </div>
              </div>
            | Expired => React.null
            | Invalid => React.null
            | NotFound => React.null
            }}
            {listLength > 0
              ? <>
                  {pastedSplits->Array.length > 0
                    ? <div className="flex flex-col gap-3">
                        <div className="font-medium text-jp-gray-700 mb-2">
                          {React.string("Select connector for each volume split:")}
                        </div>
                        {pastedSplits->Array.mapWithIndex((split, index) => {
                          let key = `slot-${index->Int.toString}`
                          // Get currently selected MCI for this slot
                          let currentSelection = switch selectedMcis->Array.get(index) {
                          | Some(mci) => mci
                          | None => ""
                          }
                          // Filter out connectors selected in OTHER slots
                          let availableOptions = connectorOptions->Array.filter(opt => {
                            let isSelectedElsewhere = selectedMcis->Array.someWithIndex((mci, i) => {
                              i !== index && mci === opt.value
                            })
                            !isSelectedElsewhere || opt.value === currentSelection
                          })
                          <IndividualConnectorSelect
                            key
                            index
                            split
                            connectorOptions={availableOptions}
                            selectedMci={currentSelection}
                            onChange={mciId => {
                              // Get connector name using the same function as AddPLGateway
                              let connectorObj = connectorList->ConnectorInterfaceTableEntity.getConnectorObjectFromListViaId(
                                mciId,
                                ~version=V1,
                              )
                              let connectorName = connectorObj.connector_name
                              // Update state to filter other dropdowns
                              setSelectedMcis(prev => {
                                prev->Array.mapWithIndex((mci, i) => {
                                  if i === index {
                                    mciId
                                  } else {
                                    mci
                                  }
                                })
                              })
                              // Update form with correct connector name and MCI ID
                              form.change(
                                `algorithm.data[${index->Int.toString}].connector.merchant_connector_id`,
                                mciId->JSON.Encode.string
                              )
                              form.change(
                                `algorithm.data[${index->Int.toString}].connector.connector`,
                                connectorName->JSON.Encode.string
                              )
                            }}
                            connectorList
                          />
                        })->React.array}
                        {allSlotsFilled
                          ? <ConfigureRuleButton setShowModal />
                          : <div className="text-sm text-orange-600 bg-orange-50 p-3 rounded-md">
                              {React.string("Please select a connector for each slot to continue.")}
                            </div>}
                      </div>
                    : <>
                        <AddPLGateway
                          id="algorithm.data"
                          gatewayOptions={connectorOptions}
                          isExpanded={true}
                          isFirst={true}
                          showPriorityIcon={false}
                          showDistributionIcon={false}
                          showFallbackIcon={false}
                          dropDownButtonText="Add Processors"
                          connectorList
                        />
                        <ConfigureRuleButton setShowModal />
                      </>}
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
                    subHeadingText="Activating this configuration will override the current one. Alternatively, save it to access later from the configuration history. Please confirm."
                    leftIcon="warning-modal"
                    iconSize=35
                  />
                </>
              : <NoDataFound message="Please configure at least 1 connector" renderType=InfoBox />}
          </div>
        | Preview =>
          <div className="flex flex-col w-full gap-3">
            <div
              className="flex flex-col gap-4 p-6 my-2 bg-white rounded-md border border-jp-gray-600 ">
              <GatewayView gateways={gateways->getGatewayTypes} connectorList />
            </div>
            <div className="flex flex-col md:flex-row gap-4">
              <ACLButton
                text={"Duplicate & Edit Configuration"}
                buttonType={Secondary}
                authorization={userHasAccess(~groupAccess=WorkflowsManage)}
                onClick={_ => {
                  setFormState(_ => RoutingTypes.EditConfig)
                  setPageState(_ => Create)
                }}
                customButtonStyle="w-1/5"
              />
              <ACLButton
                text={"Copy Configuration"}
                buttonType={Secondary}
                authorization={userHasAccess(~groupAccess=WorkflowsManage)}
                onClick={_ => {
                  copyRoutingToClipboard(
                    ~routingConfig=initialValues,
                    ~profileId=profile,
                    ~showToast,
                  )
                }}
                customButtonStyle="w-1/5"
              />
              <RenderIf condition={!isActive}>
                <ACLButton
                  text={"Activate Configuration"}
                  buttonType={Primary}
                  authorization={userHasAccess(~groupAccess=WorkflowsManage)}
                  onClick={_ => {
                    handleActivateConfiguration(routingId)->ignore
                  }}
                  buttonState={Normal}
                />
              </RenderIf>
              <RenderIf condition={isActive}>
                <ACLButton
                  text={"Deactivate Configuration"}
                  buttonType={Primary}
                  authorization={userHasAccess(~groupAccess=WorkflowsManage)}
                  onClick={_ => {
                    handleDeactivateConfiguration()->ignore
                  }}
                  buttonState=Normal
                />
              </RenderIf>
            </div>
          </div>
        | _ => React.null
        }}
      </div>
    </>
  }
}

@react.component
let make = (
  ~routingRuleId,
  ~isActive,
  ~connectorList: array<ConnectorTypes.connectorPayloadCommonType>,
  ~urlEntityName,
  ~baseUrlForRedirection,
) => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let {profileId} = React.useContext(UserInfoProvider.defaultContext).getCommonSessionDetails()
  let (profile, setProfile) = React.useState(_ => profileId)
  let (formState, setFormState) = React.useState(_ => RoutingTypes.EditReplica)
  let (initialValues, setInitialValues) = React.useState(_ => Dict.make())
  let fetchDetails = useGetMethod()
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (pageState, setPageState) = React.useState(() => Create)
  let (connectors, setConnectors) = React.useState(_ => [])
  let currentTabName = Recoil.useRecoilValueFromAtom(HyperswitchAtom.currentTabNameRecoilAtom)
  let showToast = ToastState.useShowToast()
  let (clipboardData, setClipboardData) = React.useState(_ => None)
  let (pastedSplits, setPastedSplits) = React.useState(_ => [])
  let getConnectorsList = () => {
    setConnectors(_ => connectorList)
  }
  let getTimeInCustomTimeZone = TimeZoneHook.useGetTimeInCustomTimeZone()

  let activeRoutingDetails = async () => {
    let routingUrl = getURL(~entityName=urlEntityName, ~methodType=Get, ~id=routingRuleId)
    let routingJson = await fetchDetails(routingUrl)
    let routingJsonToDict = routingJson->getDictFromJsonObject
    setFormState(_ => ViewConfig)
    setInitialValues(_ => routingJsonToDict)
    setProfile(_ => routingJsonToDict->getString("profile_id", profileId))
  }

  let getDetails = async _ => {
    try {
      setScreenState(_ => Loading)
      getConnectorsList()
      switch routingRuleId {
      | Some(_id) => {
          await activeRoutingDetails()
          setPageState(_ => Preview)
        }

      | None => {
          let currentTime = getTimeInCustomTimeZone(
            "ddd, DD MMM YYYY HH:mm:ss",
            ~includeTimeZone=true,
          )
          let currentDate = getTimeInCustomTimeZone("YYYY-MM-DD")
          setInitialValues(_ => {
            let dict = RoutingUtils.constructNameDescription(
              ~routingType=VOLUME_SPLIT,
              ~currentTime,
              ~currentDate,
            )
            dict->Dict.set("profile_id", profile->JSON.Encode.string)
            dict->Dict.set(
              "algorithm",
              {
                "type": "volume_split",
              }->Identity.genericTypeToJson,
            )
            dict
          })
          setPageState(_ => Create)
        }
      }
      setScreenState(_ => Success)
    } catch {
    | Exn.Error(e) => {
        let err = Exn.message(e)->Option.getOr("Something went wrong")
        setScreenState(_ => PageLoaderWrapper.Error(err))
      }
    }
  }

  let validate = (values: JSON.t) => {
    let errors = Dict.make()
    let dict = values->getDictFromJsonObject

    AdvancedRoutingUtils.validateNameAndDescription(
      ~dict,
      ~errors,
      ~validateFields=[Name, Description],
    )

    let validateGateways = dict => {
      let gateways = dict->getArrayFromDict("data", [])
      if gateways->Array.length === 0 {
        Some("Need atleast 1 Gateway")
      } else {
        let distributionPercentages = gateways->Belt.Array.keepMap(json => {
          json->JSON.Decode.object->Option.flatMap(val => val->(getOptionFloat(_, "split")))
        })
        let distributionPercentageSum =
          distributionPercentages->Array.reduce(0., (sum, distribution) => sum +. distribution)
        let hasZero = distributionPercentages->Array.some(ele => ele === 0.)
        let isDistributeChecked = !(distributionPercentages->Array.some(ele => ele === 100.0))

        let isNotValid =
          isDistributeChecked &&
          (distributionPercentageSum > 100. || hasZero || distributionPercentageSum !== 100.)

        if isNotValid {
          Some("Distribution Percent not correct")
        } else {
          None
        }
      }
    }

    let volumeBasedDistributionDict = dict->getObj("algorithm", Dict.make())
    switch volumeBasedDistributionDict->validateGateways {
    | Some(error) => errors->Dict.set("Volume Based Distribution", error->JSON.Encode.string)
    | None => ()
    }
    errors->JSON.Encode.object
  }

  let onSubmit = async (values, isSaveRule) => {
    try {
      setScreenState(_ => PageLoaderWrapper.Loading)
      let updateUrl = getURL(~entityName=urlEntityName, ~methodType=Post, ~id=None)
      let res = await updateDetails(updateUrl, values, Post)
      showToast(
        ~message="Successfully Created a new Configuration !",
        ~toastType=ToastState.ToastSuccess,
      )
      setScreenState(_ => Success)
      if isSaveRule {
        RescriptReactRouter.replace(GlobalVars.appendDashboardPath(~url="/routing"))
      }
      Nullable.make(res)
    } catch {
    | Exn.Error(e) =>
      let err = Exn.message(e)->Option.getOr("Something went wrong!")
      showToast(~message="Failed to Save the Configuration !", ~toastType=ToastState.ToastError)
      setScreenState(_ => PageLoaderWrapper.Error(err))
      Exn.raiseError(err)
    }
  }

  let checkClipboard = async () => {
    switch routingRuleId {
    | None => {
        // Only check clipboard when creating new routing
        let clipboardText = await RoutingUtils.readRoutingFromClipboard()
        switch clipboardText {
        | Some(text) => {
            let validationResult = RoutingUtils.validateClipboardData(text)
            // Only show banner if the clipboard data is from a different profile
            let shouldShow = switch validationResult {
            | Valid(data) => data.source_profile !== profile
            | _ => false
            }
            if shouldShow {
              setClipboardData(_ => Some(validationResult))
            }
          }
        | None => ()
        }
      }
    | Some(_) => ()
    }
  }

  let handlePasteConfiguration = (data: clipboardRoutingData, form: ReactFinalForm.formApi) => {
    let newName = data.name ++ " (Copy)"
    let newDescription = data.description ++ " (Cloned from another profile)"
    
    // Extract volume splits from clipboard data
    let algoDict = data.algorithm->Identity.genericTypeToJson->getDictFromJsonObject
    let volumeDataArray = algoDict->getArrayFromDict("data", [])
    let splits = volumeDataArray->Array.filterMap(json => {
      switch json->JSON.Decode.object {
      | Some(dict) => {
          let split = dict->getInt("split", 0)
          Some(split)
        }
      | None => None
      }
    })
    
    // Pre-fill algorithm data with empty connectors but preserve splits
    let algorithmDataArray = splits->Array.map(split => {
      let gatewayDict = Dict.make()
      gatewayDict->Dict.set("split", split->Int.toFloat->JSON.Encode.float)
      let connectorDict = Dict.make()
      connectorDict->Dict.set("connector", ""->JSON.Encode.string)
      connectorDict->Dict.set("merchant_connector_id", ""->JSON.Encode.string)
      gatewayDict->Dict.set("connector", connectorDict->JSON.Encode.object)
      gatewayDict->JSON.Encode.object
    })
    
    let algorithmDict = Dict.make()
    algorithmDict->Dict.set("type", "volume_split"->JSON.Encode.string)
    algorithmDict->Dict.set("data", algorithmDataArray->JSON.Encode.array)
    
    // Store splits for rendering individual selects
    setPastedSplits(_ => splits)
    
    // Update form values using ReactFinalForm API
    form.change("name", newName->JSON.Encode.string)
    form.change("description", newDescription->JSON.Encode.string)
    form.change("algorithm", algorithmDict->JSON.Encode.object)
    
    // Clear clipboard data to prevent duplicate paste
    setClipboardData(_ => None)
    
    // Show success message
    showToast(
      ~message=`Configuration pasted! ${splits->Array.length->Int.toString} slots ready. Select connector for each.`,
      ~toastType=ToastState.ToastSuccess,
      ~autoClose=true,
      ~toastDuration=5000,
    )
  }

  React.useEffect(() => {
    getDetails()->ignore
    None
  }, [routingRuleId])

  React.useEffect(() => {
    // Only check clipboard on initial mount when in Create mode
    if pageState === Create {
      checkClipboard()->ignore
    }
    None
  }, [])

  <div className="my-6">
    <PageLoaderWrapper screenState>
      <Form
        onSubmit={(values, _) => onSubmit(values, true)}
        validate
        initialValues={initialValues->JSON.Encode.object}>
        <div className="w-full flex justify-between">
          <div className="w-full">
            <BasicDetailsForm
              currentTabName formState setInitialValues profile setProfile routingType=VOLUME_SPLIT
            />
          </div>
        </div>
        <RenderIf condition={formState != CreateConfig}>
          <VolumeRoutingView
            setScreenState
            pageState
            setPageState
            connectors
            routingId={routingRuleId}
            isActive
            initialValues
            profile
            setFormState
            onSubmit
            urlEntityName
            connectorList
            baseUrlForRedirection
            clipboardData={clipboardData->Option.getOr(RoutingTypes.NotFound)}
            onPasteConfiguration={handlePasteConfiguration}
            pastedSplits
          />
        </RenderIf>
      </Form>
    </PageLoaderWrapper>
  </div>
}
