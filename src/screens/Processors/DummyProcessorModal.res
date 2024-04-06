open ProcessorCards

@react.component
let make = (
  ~processorModal,
  ~setProcessorModal,
  ~urlPrefix,
  ~configuredConnectors,
  ~connectorsAvailableForIntegration,
) => {
  let featureFlagDetails = HyperswitchAtom.featureFlagAtom->Recoil.useRecoilValueFromAtom
  let showTestProcessor = featureFlagDetails.testProcessors

  <UIUtils.RenderIf condition={processorModal}>
    <Modal
      modalHeading="Connect a Dummy Processor"
      showModal=processorModal
      setShowModal=setProcessorModal
      closeOnOutsideClick=true
      modalClass="w-1/2 max-w-xl m-auto">
      <ProcessorCards
        connectorsAvailableForIntegration
        configuredConnectors
        showTestProcessor
        urlPrefix
        showAllConnectors=false
        connectorType=ConnectorTypes.Processor
      />
    </Modal>
  </UIUtils.RenderIf>
}
