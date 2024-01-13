open RoutingUtils
open APIUtils
open RoutingTypes
open PriorityLogicUtils
open RoutingPreviewer
module SimpleRoutingView = {
  @react.component
  let make = (
    ~showModal,
    ~setShowModal,
    ~gateways,
    ~setGateways,
    ~setScreenState,
    ~routingId,
    ~pageState,
    ~setPageState,
    ~connectors,
    ~setFormState,
    ~isActive,
  ) => {
    let nameFromForm = ReactFinalForm.useField(`name`).input.value
    let descriptionFromForm = ReactFinalForm.useField(`description`).input.value
    let modalObj = RoutingUtils.getModalObj(PRIORITY, "priority")
    let updateDetails = useUpdateMethod()
    let showPopUp = PopUpState.useShowPopUp()
    let showToast = ToastState.useShowToast()
    let onSubmit = values => {
      setGateways(_ => values)
      setShowModal(_ => false)
    }

    let saveConfiguration = async () => {
      try {
        setScreenState(_ => PageLoaderWrapper.Loading)
        let data = gateways->Array.map(str => str->Js.Json.string)

        let activateRuleURL = getURL(~entityName=ROUTING, ~methodType=Post, ~id=None, ())

        let _ = await updateDetails(
          activateRuleURL,
          getRoutingPayload(
            data,
            "priority",
            nameFromForm->LogicUtils.getStringFromJson(""),
            descriptionFromForm->LogicUtils.getStringFromJson(""),
            "",
          )->Js.Json.object_,
          Post,
        )

        showToast(
          ~message="Successfully Created a new Configuraion !",
          ~toastType=ToastState.ToastSuccess,
          (),
        )
        RescriptReactRouter.replace(`/routing`)
        setScreenState(_ => Success)
      } catch {
      | Js.Exn.Error(e) =>
        let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Failed to Fetch!")
        setScreenState(_ => PageLoaderWrapper.Error(err))
      }->ignore
    }
    let handleActivateConfiguration = async _ => {
      try {
        setScreenState(_ => Loading)
        let activateRuleURL = getURL(~entityName=ROUTING, ~methodType=Post, ~id=routingId, ())
        let _ = await updateDetails(activateRuleURL, Dict.make()->Js.Json.object_, Post)
        showToast(
          ~message="Successfully Activated Selected Configuration !",
          ~toastType=ToastState.ToastSuccess,
          (),
        )
        RescriptReactRouter.replace(`/routing`)
        setScreenState(_ => Success)
      } catch {
      | Js.Exn.Error(e) =>
        switch Js.Exn.message(e) {
        | Some(message) =>
          if message->String.includes("IR_16") {
            setScreenState(_ => Success)
          } else {
            setScreenState(_ => Error(message))
          }
        | None => setScreenState(_ => Error("Failed to Fetch!"))
        }
      }->ignore
      Js.Nullable.null
    }

    let openConfirmPopUp = () => {
      showPopUp({
        popUpType: (Warning, WithIcon),
        heading: modalObj.conType,
        description: modalObj.conText,
        handleConfirm: {
          text: "Yes, Save it",
          onClick: {
            _ => saveConfiguration()->ignore
          },
        },
        handleCancel: {
          text: "No, don't save",
        },
      })
    }
    <>
      <div
        className="flex flex-col gap-4 p-6 my-6 bg-white dark:bg-jp-gray-lightgray_background rounded-md border border-jp-gray-600 dark:border-jp-gray-850">
        <div className="flex flex-col lg:flex-row ">
          <div>
            <div className="font-bold mb-1"> {React.string("Simple Configuration")} </div>
            <div className="text-jp-gray-800 dark:text-jp-gray-700 text-sm flex flex-col">
              <p>
                {React.string(
                  "Simple Routing is helpful when you wish to define a simple pecking order of priority among the configured connectors. You may add the gateway and do a simple drag and drop.",
                )}
              </p>
              <p> {React.string("For example: 1. Stripe, 2. Adyen, 3.Braintree")} </p>
            </div>
          </div>
          <Button
            text="Add Processors"
            onClick={_ => setShowModal(_ => true)}
            buttonType=SecondaryFilled
            leftIcon={FontAwesome("plus")}
            rightIcon={FontAwesome("angle-right")}
            fullLength=true
            customButtonStyle="w-48 lg:w-1/5 h-10 mt-4 lg:mt-0 lg:h-12 lg:ml-8"
            textWeight="font-bold"
            textStyle="text-base text-left"
            buttonState={pageState !== Preview ? Normal : Disabled}
          />
          <SelectModal
            modalHeading="Select Gateways"
            showModal
            setShowModal
            onSubmit
            initialValues=gateways
            options={connectors->SelectBox.makeOptions}
            title="Gateways"
            showDeSelectAll=true
          />
        </div>
        {switch pageState {
        | Create => {
            let keyExtractor = (index, gateway, isDragging) => {
              let style = isDragging ? "border rounded-md bg-jp-gray-100 dark:bg-jp-gray-950" : ""
              <div
                className={`h-14 px-3 flex flex-row items-center justify-between text-jp-gray-900 dark:text-jp-gray-600 border-jp-gray-500 dark:border-jp-gray-960
            ${index !== 0 ? "border-t" : ""} ${style}`}>
                <div className="flex flex-row items-center gap-4 ml-2">
                  <Icon name="grip-vertical" size=14 className={"cursor-pointer"} />
                  <div className="px-1.5 rounded-full bg-blue-800 text-white font-semibold text-sm">
                    {React.string(string_of_int(index + 1))}
                  </div>
                  <div> {React.string(gateway)} </div>
                </div>
              </div>
            }
            <div className="flex border border-jp-gray-500 dark:border-jp-gray-960 rounded-md ">
              <DragDropComponent
                listItems=gateways
                setListItems={v => setGateways(_ => v)}
                keyExtractor
                isHorizontal=false
              />
            </div>
          }

        | Preview => <SimplePreview gateways />
        | _ => React.null
        }}
      </div>
      <div className="flex gap-4">
        {switch pageState {
        | Create =>
          <Button
            onClick={_ => openConfirmPopUp()}
            text="Save Rule"
            buttonSize=Small
            customButtonStyle="rounded-sm w-1/5"
            buttonType=Primary
            leftIcon={FontAwesome("check")}
            loadingText="Activating..."
            buttonState={gateways->Array.length > 0 ? Button.Normal : Button.Disabled}
          />
        | Preview =>
          <>
            <Button
              text={"Duplicate & Edit Configuration"}
              buttonType=Primary
              onClick={_ => {
                setFormState(_ => EditConfig)
                setPageState(_ => Create)
              }}
              customButtonStyle="w-1/5 rounded-sm"
            />
            <Button
              text={"Activate Configuration"}
              buttonType=Secondary
              onClick={_ => handleActivateConfiguration()->ignore}
              customButtonStyle="w-1/5 rounded-sm"
              buttonState={isActive ? Disabled : Normal}
            />
          </>
        | _ => React.null
        }}
      </div>
    </>
  }
}
@react.component
let make = (~routingRuleId, ~isActive) => {
  open LogicUtils
  let fetchDetails = useGetMethod()
  let (formState, setFormState) = React.useState(_ => CreateConfig)
  let (pageState, setPageState) = React.useState(() => Create)
  let (screenState, setScreenState) = React.useState(_ => PageLoaderWrapper.Loading)
  let (gateways, setGateways) = React.useState(() => [])
  let (showModal, setShowModal) = React.useState(_ => false)
  let (initialValues, setInitialValues) = React.useState(_ => Dict.make())
  let (connectors, setConnectors) = React.useState(_ => [])
  let connectorListJson =
    HyperswitchAtom.connectorListAtom->Recoil.useRecoilValueFromAtom->LogicUtils.safeParse

  let activeRoutingDetails = async () => {
    try {
      setScreenState(_ => Loading)
      let routingUrl = getURL(~entityName=ROUTING, ~methodType=Get, ~id=routingRuleId, ())
      let routingJson = await fetchDetails(routingUrl)

      let connectorsOrder =
        routingJson
        ->getDictFromJsonObject
        ->getObj("algorithm", Dict.make())
        ->getArrayFromDict("data", [])
        ->getStrArrayFromJsonArray

      let initialValueDict = Dict.fromArray([
        (
          "name",
          routingJson
          ->getDictFromJsonObject
          ->getString("name", "This is a default text")
          ->Js.Json.string,
        ),
        (
          "description",
          routingJson
          ->getDictFromJsonObject
          ->getString("description", "This is a default text")
          ->Js.Json.string,
        ),
      ])
      setFormState(_ => ViewConfig)
      setInitialValues(_ => initialValueDict)
      setGateways(_ => connectorsOrder)
      setScreenState(_ => Success)
    } catch {
    | Js.Exn.Error(e) =>
      let err = Js.Exn.message(e)->Belt.Option.getWithDefault("Failed to Fetch!")
      setScreenState(_ => PageLoaderWrapper.Error(err))
    }
  }

  let getConnectorsList = () => {
    let arr =
      connectorListJson
      ->HSwitchUtils.getProcessorsListFromJson()
      ->Array.map(connectorDict => connectorDict->getString("connector_name", ""))
      ->Array.filter(x => x !== "applepay")
      ->getUniqueArray
    setConnectors(_ => arr)
    setScreenState(_ => Success)
  }

  React.useEffect1(() => {
    switch routingRuleId {
    | Some(_id) => {
        activeRoutingDetails()->ignore
        setPageState(_ => Preview)
      }

    | None => setPageState(_ => Create)
    }
    getConnectorsList()
    None
  }, [routingRuleId])

  <div>
    <PageLoaderWrapper screenState>
      <Form initialValues={initialValues->Js.Json.object_}>
        <div className="w-full flex flex-row  justify-between">
          <div className="w-full">
            {if formState != CreateConfig {
              <SimpleRoutingView
                showModal
                setShowModal
                gateways
                setGateways
                setScreenState
                pageState
                setPageState
                connectors
                setFormState
                routingId=routingRuleId
                isActive
              />
            } else {
              React.null
            }}
          </div>
        </div>
      </Form>
    </PageLoaderWrapper>
  </div>
}
