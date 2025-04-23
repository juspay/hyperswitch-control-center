module ClonePaymentMethodsModal = {
  @react.component
  let make = (~setShowModal, ~showModal) => {
    let showToast = ToastState.useShowToast()
    let (retainCloneModal, setRetainCloneModal) = Recoil.useRecoilState(
      HyperswitchAtom.retainCloneModalAtom,
    )
    let cloneConnector = Recoil.useRecoilValueFromAtom(HyperswitchAtom.cloneConnectorAtom)
    let (buttonState, setButtonState) = Recoil.useRecoilState(
      HyperswitchAtom.cloneModalButtonStateAtom,
    )
    let setIsClonePMFlow = Recoil.useSetRecoilState(HyperswitchAtom.isClonePMFlow)

    let onNextClick = _ => {
      RescriptReactRouter.push(
        GlobalVars.appendDashboardPath(~url=`/connectors/new?name=${cloneConnector}`),
      )
      setRetainCloneModal(_ => false)
      showToast(
        ~toastType=ToastSuccess,
        ~message="Payment Methods Cloned Successfully",
        ~autoClose=true,
      )
      setIsClonePMFlow(_ => true)
    }

    let modalBody = {
      <>
        <div className="pt-3 m-3 flex justify-between">
          <CardUtils.CardHeader
            heading="Clone Payment Methods"
            subHeading=""
            customSubHeadingStyle="w-full !max-w-none pr-10"
          />
          <div
            className="h-fit"
            onClick={_ => {
              setShowModal(_ => false)
              setRetainCloneModal(_ => false)
            }}>
            <Icon name="modal-close-icon" className="cursor-pointer" size=30 />
          </div>
        </div>
        <hr />
        <div>
          <div className="flex flex-col gap-2 py-10 text-sm leading-7 text-gray-600 mx-3">
            <p>
              {"Select the target profile where you want to clone payment methods"->React.string}
            </p>
            <div>
              <p> {"Target Profile"->React.string} </p>
              <RenderIf condition={retainCloneModal && showModal}>
                <div className="w-48">
                  <ProfileSwitch
                    showSwitchModal=false setButtonState showHeading=false customMargin="mt-8"
                  />
                </div>
              </RenderIf>
            </div>
          </div>
          <hr className="mt-4" />
          <div className="flex justify-end my-4 mr-4">
            <Button text="Next" onClick={_ => onNextClick()} buttonState buttonType={Primary} />
          </div>
        </div>
      </>
    }

    <div>
      <Modal
        showModal
        closeOnOutsideClick=false
        setShowModal
        childClass="p-0"
        borderBottom=true
        modalClass="w-full max-w-xl mx-auto my-auto dark:!bg-jp-gray-lightgray_background">
        {modalBody}
      </Modal>
    </div>
  }
}

@react.component
let make = (~connectorID, ~connectorName) => {
  open APIUtils
  open ConnectorUtils
  open LogicUtils
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let showToast = ToastState.useShowToast()
  let setClonedConnectorData = Recoil.useSetRecoilState(HyperswitchAtom.clonedConnectorData)
  let setRetainCloneModal = Recoil.useSetRecoilState(HyperswitchAtom.retainCloneModalAtom)
  let setCloneConnector = Recoil.useSetRecoilState(HyperswitchAtom.cloneConnectorAtom)
  let (showModal, setShowModal) = React.useState(_ => false)

  let getConnectorDetails = async () => {
    try {
      let connectorUrl = getURL(~entityName=V1(CONNECTOR), ~methodType=Get, ~id=Some(connectorID))
      let response = await fetchDetails(connectorUrl)
      let json = Window.getResponsePayload(response)
      let metaData = json->getDictFromJsonObject->getJsonObjectFromDict("metadata")
      let paymentMethodEnabled =
        json
        ->getDictFromJsonObject
        ->getJsonObjectFromDict("payment_methods_enabled")
        ->getPaymentMethodEnabled

      if paymentMethodEnabled->Array.length > 0 {
        let paymentMethodsClone =
          paymentMethodEnabled
          ->Identity.genericTypeToJson
          ->JSON.stringify
          ->LogicUtils.safeParse
          ->getPaymentMethodEnabled

        let clonedData: HyperswitchAtom.clonedConnectorData = {
          paymentMethods: paymentMethodsClone,
          metaData,
        }
        setClonedConnectorData((_): HyperswitchAtom.clonedConnectorData => clonedData)
        setShowModal(_ => true)
        setRetainCloneModal(_ => true)
      }
    } catch {
    | _ =>
      showToast(
        ~message="Unable to fetch Payment Methods. Please try cloning again.",
        ~toastType=ToastError,
      )
    }
  }

  let handleCloneClick = e => {
    e->ReactEvent.Mouse.stopPropagation
    getConnectorDetails()->ignore
    setCloneConnector(_ => connectorName)
  }
  <>
    <div onClick={handleCloneClick}>
      <ToolTip
        description="Clone Payment Methods"
        toolTipFor={<Icon name="clone" size=15 />}
        toolTipPosition=Top
      />
    </div>
    <ClonePaymentMethodsModal showModal setShowModal />
  </>
}
