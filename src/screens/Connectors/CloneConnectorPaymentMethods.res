module ClonePaymentMethodsModal = {
  @react.component
  let make = (~setShowModal, ~showModal) => {
    let setRetainCloneModal = Recoil.useSetRecoilState(HyperswitchAtom.retainCloneModalAtom)
    let cloneConnector = Recoil.useRecoilValueFromAtom(HyperswitchAtom.cloneConnectorAtom)
    let (buttonState, setButtonState) = Recoil.useRecoilState(
      HyperswitchAtom.cloneModalButtonStateAtom,
    )

    let handleNext = _ => {
      RescriptReactRouter.push(
        GlobalVars.appendDashboardPath(~url=`/connectors/new?name=${cloneConnector}`),
      )
      setRetainCloneModal(_ => false)
    }

    let modalBody = {
      <div className="m-4 p-2">
        <div className="pt-3 m-3 flex justify-between">
          <CardUtils.CardHeader
            heading="Clone Payment Method"
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
        <div className="m-4 flex flex-col gap-2">
          <p className="my-2">
            {"Select the target profile where you want to clone payment methods"->React.string}
          </p>
          <p> {"Target Profile"->React.string} </p>
          <div className="w-48">
            <ProfileSwitch
              showSwitchModal=false setButtonState showHeading=false customMargin="mt-8"
            />
          </div>
          <div className="flex justify-center my-4">
            <Button text="Next" onClick={_ => handleNext()} buttonState buttonType={Primary} />
          </div>
        </div>
      </div>
    }

    <div>
      <Modal
        showModal
        closeOnOutsideClick=true
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
  let getURL = useGetURL()
  let fetchDetails = useGetMethod()
  let showToast = ToastState.useShowToast()
  let (initialValues, setInitialValues) = React.useState(_ => JSON.Encode.null)
  let (paymentMethodsEnabled, setPaymentMethods) = React.useState(_ =>
    Dict.make()->JSON.Encode.object->getPaymentMethodEnabled
  )
  let setPaymentMethodsClone = Recoil.useSetRecoilState(HyperswitchAtom.paymentMethodsClonedAtom)
  let setRetainCloneModal = Recoil.useSetRecoilState(HyperswitchAtom.retainCloneModalAtom)
  let setCloneConnector = Recoil.useSetRecoilState(HyperswitchAtom.cloneConnectorAtom)
  let (showModal, setShowModal) = React.useState(_ => false)

  let setPaymentMethodDetails = async () => {
    try {
      let _ = initialValues->getConnectorPaymentMethods(setPaymentMethods)
    } catch {
    | _ => showToast(~message="Failed to Clone Payment methods", ~toastType=ToastError)
    }
  }

  React.useEffect(() => {
    if initialValues != JSON.Encode.null {
      setPaymentMethodDetails()->ignore
    }
    None
  }, [initialValues])

  React.useEffect(() => {
    if paymentMethodsEnabled->Array.length > 0 {
      let pmCLone =
        paymentMethodsEnabled
        ->Identity.genericTypeToJson
        ->JSON.stringify
        ->LogicUtils.safeParse
        ->getPaymentMethodEnabled
      setPaymentMethodsClone(_ => pmCLone)

      setShowModal(_ => true)
      setRetainCloneModal(_ => true)
    }
    None
  }, [paymentMethodsEnabled])

  let getConnectorDetails = async () => {
    try {
      let connectorUrl = getURL(~entityName=CONNECTOR, ~methodType=Get, ~id=Some(connectorID))
      let json = await fetchDetails(connectorUrl)
      setInitialValues(_ => json)
    } catch {
    | _ => Exn.raiseError("Something went wrong")
    }
  }

  let handleClick = e => {
    e->ReactEvent.Mouse.stopPropagation
    getConnectorDetails()->ignore
    setCloneConnector(_ => connectorName)
  }
  <>
    <div className="flex" onClick={handleClick}>
      <p> {"Clone"->React.string} </p>
      <img alt="copy" src={`/assets/CopyToClipboard.svg`} />
    </div>
    <ClonePaymentMethodsModal showModal setShowModal />
  </>
}
