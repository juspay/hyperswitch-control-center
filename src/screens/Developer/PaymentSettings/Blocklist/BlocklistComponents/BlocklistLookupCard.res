open BlocklistUtils
open LogicUtils
open APIUtils
open Typography
open BlocklistHelper

@react.component
let make = (~transactionType) => {
  let getURL = useGetURL()
  let fetchDetails = useGetMethod(~showErrorToast=false)
  let showToast = ToastAdapter.useShowToast()
  let (data, setData) = React.useState(_ => "")
  let (lookupResult, setLookupResult) = React.useState(_ => None)
  let (buttonState, setButtonState) = React.useState(_ => Button.Normal)

  let checkBlocklistEntry = async () => {
    try {
      setButtonState(_ => Button.Loading)
      let url = getURL(
        ~entityName=V1(BLOCKLIST_LOOKUP),
        ~methodType=Get,
        ~queryParameters=Some(
          `data=${data
            ->String.trim
            ->encodeURIComponent}&${transactionType->blocklistTransactionTypeQueryParam}`,
        ),
      )
      let response = await fetchDetails(url)
      setLookupResult(_ => Some(response->getBlocklistLookupFromResponse))
    } catch {
    | Exn.Error(e) =>
      let errorMessage =
        Exn.message(e)
        ->Option.getOr("Failed to check the blocklist")
        ->parseBlocklistErrorMessage
      showToast(~message=errorMessage, ~toastType=ToastError)
    }
    setButtonState(_ => Button.Normal)
  }

  let onDataChange = ev => {
    let inputValue = ReactEvent.Form.target(ev)["value"]->getStringFromJson("")
    setData(_ => inputValue)
    setLookupResult(_ => None)
  }

  let actionButtonState = data->String.trim->isEmptyString ? Button.Disabled : buttonState
  let dataInput: ReactFinalForm.fieldRenderPropsInput = {
    name: "blocklist-lookup-data",
    onBlur: _ => (),
    onChange: onDataChange,
    onFocus: _ => (),
    value: data->JSON.Encode.string,
    checked: true,
  }

  <Panel>
    <PanelHeader
      title="Check an entry"
      description="Look up a card BIN or fingerprint to see if it is currently blocked."
    />
    <div className="flex flex-col sm:flex-row gap-4 sm:items-end">
      <div className="w-full sm:w-80 min-w-0">
        <p className={`text-nd_gray-700 mb-1 ${body.sm.medium}`}> {"Data"->React.string} </p>
        <TextInputAdapter
          input=dataInput
          placeholder="411111"
          description=""
          maxLength=maxBlocklistLookupLength
          shouldSubmitForm=false
          customWidth="w-full"
        />
        <p className={`mt-1 min-h-5 text-nd_gray-500 ${body.sm.medium}`}>
          {"Checked against every type, e.g. 411111 or fp_abc123"->React.string}
        </p>
      </div>
      <div className="w-full sm:w-auto min-w-0 sm:mb-6">
        <Button
          text="Check"
          buttonType=Secondary
          onClick={_ => checkBlocklistEntry()->ignore}
          buttonState=actionButtonState
        />
      </div>
      <div className="w-full sm:w-auto min-w-0 sm:mb-6">
        {lookupResult->mapOptionOrDefault(React.null, lookup =>
          <div className="flex items-center gap-2">
            <span className={`text-nd_gray-700 ${body.md.medium}`}>
              {lookup.data->React.string}
            </span>
            <TagBinding
              text={lookup.blocked ? "Blocked" : "Not blocked"}
              color={lookup.blocked ? Error : Success}
              variant=Subtle
              shape=Squarical
              size=Sm
            />
          </div>
        )}
      </div>
    </div>
  </Panel>
}
