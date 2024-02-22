open HSwitchUtils
open FormDataUtils

let h3Leading2Text = getTextClass((H3, Leading_2))
let p1RegularText = getTextClass((P1, Regular))
let p1MediumText = getTextClass((P1, Medium))
let p2RegularText = getTextClass((P2, Regular))
let p3RegularText = getTextClass((P3, Regular))

module EvidenceUploadForm = {
  @react.component
  let make = (~uploadEvidenceType, ~index, ~fileUploadedDict, ~setFileUploadedDict) => {
    open LogicUtils
    let handleBrowseChange = (event, uploadEvidenceType) => {
      let target = ReactEvent.Form.target(event)
      let fileDict =
        [
          ("uploadedFile", target["files"]["0"]->Identity.genericTypeToJson),
          ("fileName", target["files"]["0"]["name"]->JSON.Encode.string),
        ]->getJsonFromArrayOfJson

      setFileUploadedDict(prev => {
        let arr = prev->Dict.toArray
        let newDict = [(uploadEvidenceType, fileDict)]->Array.concat(arr)->Dict.fromArray
        newDict
      })
    }

    <div className="flex justify-between items-center" key={index->Int.toString}>
      <div className="flex gap-2">
        <Icon name="file-icon" size=22 />
        <p> {uploadEvidenceType->stringReplaceAll("_", " ")->capitalizeString->React.string} </p>
      </div>
      {if fileUploadedDict->Dict.get(uploadEvidenceType)->Option.isNone {
        <label>
          <p className="text-blue-700 underline cursor-pointer">
            {"Upload"->React.string}
            <input
              key={Int.toString(index)}
              type_="file"
              accept=".pdf,.csv,.img,.jpeg"
              onChange={ev => ev->handleBrowseChange(uploadEvidenceType)}
              hidden=true
            />
          </p>
        </label>
      } else {
        let fileName =
          fileUploadedDict->getDictfromDict(uploadEvidenceType)->getString("fileName", "")
        let truncatedFileName = truncateFileNameWithEllipses(~fileName, ~maxTextLength=10)

        <div className="flex gap-4 items-center ">
          <p className={`${p1RegularText} text-grey-700`}> {truncatedFileName->React.string} </p>
          <Icon
            name="cross-skeleton"
            className="cursor-pointer"
            size=12
            onClick={_ => {
              setFileUploadedDict(prev => {
                let prevCopy = prev->Dict.copy
                prevCopy->Dict.delete(uploadEvidenceType)
                prevCopy
              })
            }}
          />
        </div>
      }}
    </div>
  }
}
module UploadDisputeEvidenceModal = {
  @react.component
  let make = (
    ~uploadEvidenceModal,
    ~setUploadEvidenceModal,
    ~disputeId,
    ~setDisputeEvidenceStatus,
    ~fileUploadedDict,
    ~setFileUploadedDict,
  ) => {
    open APIUtils
    open LogicUtils
    let updateDetails = useUpdateMethod()
    let acceptFile = (keyValue, fileValue) => {
      let url = getURL(~entityName=DISPUTES_ATTACH_EVIDENCE, ~methodType=Put, ())
      let formData = formData()
      append(formData, "dispute_id", disputeId)
      append(formData, "evidence_type", keyValue)
      append(formData, "file", fileValue)

      updateDetails(
        ~bodyFormData=formData,
        ~headers=Dict.make(),
        url,
        Dict.make()->JSON.Encode.object,
        Put,
        ~contentType=AuthHooks.Unknown,
        (),
      )
    }

    let onAttachEvidence = async () => {
      let keyFromDictArray = fileUploadedDict->Dict.keysToArray

      let dictToIterate = keyFromDictArray->Array.filter(ele => {
        let keyObject = fileUploadedDict->getDictfromDict(ele)
        keyObject->Dict.get("fileId")->Option.isNone
      })

      let promisesOfAttachEvidence = dictToIterate->Array.map(ele => {
        let jsonObject = fileUploadedDict->Dict.get(ele)->Option.getOr(JSON.Encode.null)
        let fileValue = jsonObject->getDictFromJsonObject->getJsonObjectFromDict("uploadedFile")
        let res = acceptFile(ele, fileValue)
        res
      })

      let response = await PromiseUtils.allSettledPolyfill(promisesOfAttachEvidence)
      let copyFileUploadedDict = fileUploadedDict->Dict.copy

      response->Array.forEachWithIndex((ele, index) => {
        let keyValue = keyFromDictArray[index]->Option.getOr("")
        let dictValue = fileUploadedDict->getDictfromDict(keyValue)
        switch JSON.Classify.classify(ele) {
        | Object(jsonDict) => {
            let fileId = jsonDict->getString("file_id", "")
            dictValue->Dict.set("fileId", fileId->JSON.Encode.string)
            copyFileUploadedDict->Dict.set(keyValue, dictValue->JSON.Encode.object)
          }
        | _ => copyFileUploadedDict->Dict.delete(keyValue)
        }
      })

      setUploadEvidenceModal(_ => false)

      if copyFileUploadedDict->Dict.keysToArray->Array.length > 0 {
        setDisputeEvidenceStatus(_ => DisputeTypes.EvidencePresent)
      }
      setFileUploadedDict(_ => copyFileUploadedDict)
    }

    <Modal
      modalHeading="Attach supporting evidence"
      headingClass="!bg-transparent dark:!bg-jp-gray-lightgray_background"
      showModal={uploadEvidenceModal}
      setShowModal={setUploadEvidenceModal}
      borderBottom=true
      closeOnOutsideClick=true
      childClass="!p-0 !m-0"
      modalHeadingClass="!text-lg"
      showModalHeadingIconName="attach-file-icon"
      modalHeaderIconSize=24
      modalClass="w-full max-w-xl mx-auto my-8 dark:!bg-jp-gray-lightgray_background pb-3">
      <div className="flex flex-col p-6 gap-8">
        <div className="flex flex-col gap-2">
          <p className=p1RegularText>
            {"Upload evidence that is most relevant to this dispute"->React.string}
          </p>
          <p className={`${p2RegularText} text-grey-800 opacity-50`}>
            {"The evidence can be ANY ONE or MORE of the following:"->React.string}
          </p>
        </div>
        <div className="flex flex-col gap-4">
          {DisputesUtils.evidenceList
          ->Array.mapWithIndex((value, index) => {
            let uploadEvidenceType = value->String.toLowerCase->titleToSnake
            <EvidenceUploadForm
              uploadEvidenceType
              index
              fileUploadedDict
              setFileUploadedDict
              key={Int.toString(index)}
            />
          })
          ->React.array}
        </div>
      </div>
      <div className="h-px w-full bg-grey-900 opacity-20" />
      <div className="flex flex-1 justify-end gap-4 pt-5 pb-3 px-6">
        <Button
          buttonType={Secondary} text="Go Back" buttonSize={Small} customButtonStyle="!py-3 !px-2.5"
        />
        <Button
          buttonType={Primary}
          text="Attach Evidence"
          buttonSize={Small}
          customButtonStyle="!py-3 !px-2.5"
          buttonState={fileUploadedDict->Dict.keysToArray->Array.length > 0 ? Normal : Disabled}
          onClick={_ => onAttachEvidence()->ignore}
        />
      </div>
    </Modal>
  }
}
module DisputesInfoBarComponent = {
  @react.component
  let make = (
    ~disputeEvidenceStatus,
    ~isFromPayments=false,
    ~disputeDataValue=None,
    ~fileUploadedDict,
    ~disputeId,
    ~setDisputeEvidenceStatus,
    ~setUploadEvidenceModal,
    ~disputeStatus,
    ~setFileUploadedDict,
    ~setDisputeData,
  ) => {
    open DisputeTypes
    open APIUtils
    open LogicUtils
    open DisputesUtils
    open PageLoaderWrapper

    let fetchDetails = useGetMethod()
    let updateDetails = useUpdateMethod()
    let showToast = ToastState.useShowToast()
    let (screenState, setScreenState) = React.useState(_ => Loading)

    let onEvidenceSubmit = async () => {
      try {
        let url = getURL(~entityName=DISPUTES_ATTACH_EVIDENCE, ~methodType=Post, ())
        let body = constructDisputesBody(fileUploadedDict, disputeId)
        let response = await updateDetails(url, body->JSON.Encode.object, Post, ())
        setDisputeData(_ => response)
        setDisputeEvidenceStatus(_ => EvidencePresent)
      } catch {
      | _ =>
        showToast(~message=`Failed to submit the evidence. Try again !`, ~toastType=ToastError, ())
      }
    }

    let retrieveEvidence = async () => {
      try {
        setScreenState(_ => Loading)
        let url = getURL(
          ~entityName=DISPUTES_ATTACH_EVIDENCE,
          ~methodType=Get,
          ~id=Some(disputeId),
          (),
        )
        let response = await url->fetchDetails
        let reponseArray = response->getArrayFromJson([])
        if reponseArray->Array.length > 0 {
          setFileUploadedDict(_ =>
            DictionaryUtils.mergeDicts([fileUploadedDict, reponseArray->getDictFromFilesAvailable])
          )
          setDisputeEvidenceStatus(_ => EvidencePresent)
        }
        setScreenState(_ => Success)
      } catch {
      | _ =>
        showToast(
          ~message="Failed to retrieve evidence for the dispute !",
          ~toastType=ToastError,
          (),
        )
      }
    }

    React.useEffect0(() => {
      retrieveEvidence()->ignore
      None
    })

    <PageLoaderWrapper screenState>
      <div
        className="border w-full rounded-md border-blue-700 border-opacity-40 bg-blue-info_blue_background p-6 flex gap-6">
        <div className="flex gap-3 items-start justify-start">
          <Icon name="note-icon" size=22 />
          {switch disputeStatus {
          | DisputeOpened =>
            switch disputeEvidenceStatus {
            | Landing =>
              <div className="flex flex-col gap-6">
                <div className="flex flex-col gap-2">
                  <p className=h3Leading2Text> {"Why was the dispute raised?"->React.string} </p>
                  <p className={`${p1RegularText} opacity-60`}>
                    {"The customer claims that they did not authorise this purchase."->React.string}
                  </p>
                </div>
                <div
                  className="flex gap-2 group items-center cursor-pointer"
                  onClick={_ =>
                    Window._open(
                      "https://docs.hyperswitch.io/features/merchant-controls/disputes",
                    )}>
                  <p className={`${p1MediumText}  text-blue-900`}>
                    {"Learn how to respond"->React.string}
                  </p>
                  <Icon
                    name="thin-right-arrow"
                    size=20
                    className="group-hover:scale-125 transition duration-200 ease-in-out"
                    customIconColor="#006DF9"
                  />
                </div>
              </div>
            | EvidencePresent =>
              <div className="flex flex-col gap-8">
                <div className="flex flex-col gap-2">
                  <p className=h3Leading2Text>
                    {"Your dispute evidence has been attached"->React.string}
                  </p>
                  <div className="flex gap-4 flex-wrap">
                    {fileUploadedDict
                    ->Dict.keysToArray
                    ->Array.map(value => {
                      let fileName =
                        fileUploadedDict->getDictfromDict(value)->getString("fileName", "")
                      let iconName = switch fileName->getFileTypeFromFileName {
                      | "jpeg" | "jpg" | "png" => "image-icon"
                      | _ => `${fileName->getFileTypeFromFileName}-icon`
                      }
                      <div
                        className={`p-2 border rounded-md bg-white w-fit flex gap-2 items-center border-grey-200`}>
                        <Icon name=iconName size=16 />
                        <p className={`${p3RegularText} text-grey-700 `}>
                          {fileName->React.string}
                        </p>
                      </div>
                    })
                    ->React.array}
                  </div>
                </div>
                <div className="flex gap-4">
                  <Button
                    buttonType={Primary}
                    text="Submit your evidence"
                    buttonSize={Small}
                    onClick={_ => onEvidenceSubmit()->ignore}
                  />
                  <Button
                    buttonType={Secondary}
                    text="Attach More"
                    buttonSize={Small}
                    customButtonStyle="!bg-white"
                    leftIcon={FontAwesome("paper-clip")}
                    onClick={_ => setUploadEvidenceModal(_ => true)}
                  />
                </div>
              </div>
            }
          | DisputeChallenged =>
            <div className="flex flex-col gap-4">
              <p className=h3Leading2Text>
                {"These are the attachments you have provided as evidence."->React.string}
              </p>
              <div className="flex gap-4 flex-wrap">
                {fileUploadedDict
                ->Dict.keysToArray
                ->Array.map(eachFileValue => {
                  let jsonObject =
                    fileUploadedDict->Dict.get(eachFileValue)->Option.getOr(JSON.Encode.null)
                  let fileName = jsonObject->getDictFromJsonObject->getString("fileName", "")

                  <div
                    className={`p-2 border rounded-md bg-white w-fit flex gap-6 items-center border-grey-200 border-opacity-50`}>
                    <div className="flex gap-2 items-center">
                      <Icon name="pdf-icon" size=20 />
                      <p className={`${p2RegularText} text-grey-700`}> {fileName->React.string} </p>
                    </div>
                    <Icon name="cross-skeleton" size=12 />
                  </div>
                })
                ->React.array}
              </div>
            </div>
          | DisputeAccepted =>
            <div className="flex flex-col gap-2">
              <p className=h3Leading2Text> {"You accepted this dispute"->React.string} </p>
              <p className={`${p1RegularText} opacity-60`}>
                {"A refund is issued for the customer. No further action is required from you."->React.string}
              </p>
            </div>
          | _ => React.null
          }}
        </div>
      </div>
    </PageLoaderWrapper>
  }
}

@react.component
let make = (~disputeID, ~setUploadEvidenceModal, ~setDisputeData, ~connector) => {
  open APIUtils
  open DisputesUtils

  let updateDetails = useUpdateMethod()
  let showPopUp = PopUpState.useShowPopUp()
  let showToast = ToastState.useShowToast()

  let handleAcceptDispute = async () => {
    try {
      let url = getURL(~entityName=ACCEPT_DISPUTE, ~methodType=Post, ~id=Some(disputeID), ())
      let response = await updateDetails(url, Dict.make()->JSON.Encode.object, Post, ())
      setDisputeData(_ => response)
    } catch {
    | _ => showToast(~message="Something went wrong. Please try again", ~toastType=ToastError, ())
    }
  }

  let handlePopupOpen = () => {
    showPopUp({
      popUpType: (Warning, WithIcon),
      heading: "Accept this dispute?",
      description: "By accepting you will lose this dispute and will have to refund the amount to the user. You won’t be able to submit evidence once you accept"->React.string,
      handleConfirm: {text: "Proceed", onClick: _ => handleAcceptDispute()->ignore},
      handleCancel: {text: "Cancel"},
    })
  }

  <div className="flex gap-2">
    <UIUtils.RenderIf
      condition={connectorsSupportAcceptDispute->Array.includes(
        connector->ConnectorUtils.getConnectorNameTypeFromString(),
      )}>
      <Button
        buttonType={Secondary}
        text="Accept Dispute"
        buttonSize={Small}
        customButtonStyle="!py-3 !px-2.5"
        onClick={_ => handlePopupOpen()}
      />
    </UIUtils.RenderIf>
    <Button
      buttonType={Primary}
      text="Counter Dispute"
      buttonSize={Small}
      customButtonStyle="!py-3 !px-2.5"
      onClick={_ => setUploadEvidenceModal(_ => true)}
    />
  </div>
}
