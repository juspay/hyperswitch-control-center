open BlocklistUtils
open BlocklistTypes
open LogicUtils
open APIUtils
open Typography

@react.component
let make = (~operation, ~title, ~description, ~buttonText, ~eventName) => {
  let getURL = useGetURL()
  let updateDetails = useUpdateMethod(~showErrorToast=false)
  let showToast = ToastAdapter.useShowToast()
  let {userHasAccess} = GroupACLHooks.useUserGroupACLHook()
  let mixpanelEvent = MixpanelHook.useSendEvent()
  let (dataKind, setDataKind) = React.useState(_ => CardBin)
  let (data, setData) = React.useState(_ => "")
  let (dataError, setDataError) = React.useState(_ => None)
  let (buttonState, setButtonState) = React.useState(_ => Button.Normal)

  let submitBlocklistEntry = async () => {
    switch validateBlocklistEntryData(~dataKind, ~data, ~operation) {
    | Some(validationError) => setDataError(_ => Some(validationError))
    | None =>
      setDataError(_ => None)
      let trimmedData = data->String.trim
      try {
        setButtonState(_ => Button.Loading)
        let methodType = operation->getBlocklistEntryMethod
        let url = getURL(~entityName=V1(BLOCKLIST), ~methodType)
        let body = blocklistEntryBody(~dataKind, ~data=trimmedData)
        let response = await updateDetails(url, body, methodType)
        let entry = response->getDictFromJsonObject->blocklistEntryItemToObjMapper
        let fingerprintId = entry.fingerprint_id
        showToast(
          ~message=getBlocklistEntrySuccessMessage(
            ~operation,
            ~submittedData=trimmedData,
            ~fingerprintId,
          ),
          ~toastType=ToastSuccess,
        )
        setData(_ => "")
      } catch {
      | Exn.Error(e) =>
        let rawErrorMessage =
          Exn.message(e)->Option.getOr(operation->getBlocklistEntryFallbackError)
        let errorDict = rawErrorMessage->safeParse->getDictFromJsonObject
        let errorMessage =
          errorDict
          ->getObj("error", errorDict)
          ->getString("message", rawErrorMessage)
        showToast(~message=errorMessage, ~toastType=ToastError)
      }
      setButtonState(_ => Button.Normal)
    }
  }

  let onDataKindSelect = value => {
    setDataKind(_ => value->getBlocklistDataKindFromString)
    setDataError(_ => None)
  }

  let onDataChange = ev => {
    let inputValue = ReactEvent.Form.target(ev)["value"]->getStringFromJson("")
    if isValidBlocklistEntryInput(~dataKind, ~data=inputValue) {
      setData(_ => inputValue)
      setDataError(_ => None)
    }
  }

  let onClick = _ => {
    mixpanelEvent(~eventName)
    submitBlocklistEntry()->ignore
  }

  let isDataEmpty = data->String.trim->isEmptyString
  let actionButtonState = isDataEmpty ? Button.Disabled : buttonState
  let dataHelperText = dataError->Option.getOr(dataKind->blocklistEntryDataHint)
  let dataHelperClass = dataError->Option.isSome ? "text-nd_red-500" : "text-nd_gray-500"
  let typeDropdownInput: ReactFinalForm.fieldRenderPropsInput = {
    name: "blocklist-entry-type",
    onBlur: _ => (),
    onChange: value => onDataKindSelect(value->Identity.formReactEventToString),
    onFocus: _ => (),
    value: dataKind->blocklistDataKindToString->JSON.Encode.string,
    checked: true,
  }
  let dataInput: ReactFinalForm.fieldRenderPropsInput = {
    name: `${eventName}-data`,
    onBlur: _ => (),
    onChange: onDataChange,
    onFocus: _ => (),
    value: data->JSON.Encode.string,
    checked: true,
  }

  <div className="max-w-3xl">
    <section className="border border-nd_gray-200 rounded-lg bg-white p-5 flex flex-col gap-4">
      <div>
        <h2 className={`text-nd_gray-700 ${body.lg.semibold}`}> {title->React.string} </h2>
        <p className={`text-nd_gray-500 mt-1 ${body.md.medium}`}> {description->React.string} </p>
      </div>
      <div className="grid grid-cols-1 sm:grid-cols-[180px_320px_auto] gap-4 sm:items-start">
        <div className="w-full sm:w-44 min-w-0">
          <p className={`text-nd_gray-700 mb-1 ${body.sm.medium}`}> {"Type"->React.string} </p>
          <SelectBoxAdapter.BaseDropdown
            buttonText="Select type"
            allowMultiSelect=false
            input=typeDropdownInput
            options=blocklistDataKindOptions
            hideMultiSelectButtons=true
            deselectDisable=true
            fullLength=true
            showSelectionAsChips=false
            showClearAll=false
            showSelectAll=false
            customButtonStyle="!rounded-lg"
            dropdownCustomWidth="w-44"
            fixedDropDownDirection=BottomRight
          />
          <div className="mt-1 min-h-5" />
        </div>
        <div className="w-full sm:w-auto min-w-0">
          <p className={`text-nd_gray-700 mb-1 ${body.sm.medium}`}> {"Data"->React.string} </p>
          <TextInputAdapter
            input=dataInput
            placeholder={dataKind->blocklistEntryPlaceholder}
            description=""
            inputMode={dataKind->blocklistEntryInputMode}
            maxLength=?{dataKind->blocklistEntryMaxLength}
            shouldSubmitForm=false
            customWidth="w-full"
          />
          <p className={`mt-1 min-h-5 ${dataHelperClass} ${body.sm.medium}`}>
            {dataHelperText->React.string}
          </p>
        </div>
        <div className="w-full min-w-0">
          <p className={`mb-1 invisible ${body.sm.medium}`}> {"Action"->React.string} </p>
          <ACLButton
            text=buttonText
            onClick
            buttonState=actionButtonState
            authorization={userHasAccess(~groupAccess=AccountManage)}
          />
          <div className="mt-1 min-h-5" />
        </div>
      </div>
    </section>
  </div>
}
