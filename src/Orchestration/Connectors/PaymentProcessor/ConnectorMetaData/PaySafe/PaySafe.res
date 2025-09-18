open LogicUtils
open Typography
module AccountIdCurrencyFields = {
  @react.component
  let make = (
    ~configDict,
    ~selectedConfig,
    ~account,
    ~currency,
    ~setShowAccountConfigModal,
    ~handleShowConfigModal: (~showModal: bool) => unit,
  ) => {
    let dict =
      configDict->getArrayFromDict(selectedConfig, [])->getValueFromArray(0, JSON.Encode.null)
    let fields = dict->convertMapObjectToDict->CommonConnectorUtils.inputFieldMapper

    let {\"type": inputType, name} = fields
    let name = `metadata.account_id.${account}.${currency}.${name}`
    <>
      <FormRenderer.FieldRenderer
        labelClass="font-semibold !text-hyperswitch_black"
        field={ConnectorMetaDataUtils.getField(~inputType, ~name, ~connectorMetaDataFields=fields)}
      />
      <div className="w-full flex gap-2 justify-end p-6">
        <Button
          text="Go Back"
          buttonType={Secondary}
          onClick={_ => {
            handleShowConfigModal(~showModal=false)
          }}
        />
        <Button
          text="Enable"
          buttonType={Primary}
          onClick={_ => {
            setShowAccountConfigModal(_ => false)
          }}
        />
      </div>
    </>
  }
}

module AccountCheckBox = {
  @react.component
  let make = (~config, ~configDict, ~account, ~currency) => {
    let (showConfigModal, setShowAccountConfigModal) = React.useState(_ => false)
    let form = ReactFinalForm.useForm()
    let formState: ReactFinalForm.formState = ReactFinalForm.useFormState(
      ReactFinalForm.useFormSubscription(["values"])->Nullable.make,
    )

    let meteDataInitialValues = React.useMemo(() => {
      let formValues = formState.values->getDictFromJsonObject
      formValues->getDictfromDict("metadata")
    }, [])

    let handleShowConfigModal = (~showModal) => {
      setShowAccountConfigModal(_ => showModal)
      if !showModal {
        form.change("metadata", meteDataInitialValues->Identity.genericTypeToJson)
      }
    }

    let checkIsSelected = () => {
      let flatten = formState.values->JsonFlattenUtils.flattenObject(true)
      let name = `metadata.account_id.${account}.${currency}.${config}`
      flatten->Dict.get(name)->Option.isSome
    }
    let {globalUIConfig: {font: {textColor}}} = React.useContext(ThemeProvider.themeContext)
    <>
      <div
        className={"flex gap-1.5 items-center cursor-pointer"}
        onClick={_ => handleShowConfigModal(~showModal=true)}>
        <CheckBoxIcon isSelected={checkIsSelected()} />
        <p className={`${body.md.medium} text-nd_gray-700 opacity-50`}>
          {config->snakeToTitle->React.string}
        </p>
      </div>
      <RenderIf condition=showConfigModal>
        <Modal
          modalHeading="Additional Details to enable"
          headerTextClass={`${textColor.primaryNormal} font-bold text-xl`}
          headBgClass="sticky top-0 z-30 bg-white"
          showModal={showConfigModal}
          setShowModal={setShowAccountConfigModal}
          onCloseClickCustomFun={() => handleShowConfigModal(~showModal=false)}
          paddingClass=""
          revealFrom=Reveal.Right
          modalClass="w-full md:w-1/3 !h-full overflow-y-scroll !overflow-x-hidden rounded-none text-jp-gray-900"
          childClass={""}>
          <AccountIdCurrencyFields
            configDict
            selectedConfig=config
            account
            currency
            handleShowConfigModal
            setShowAccountConfigModal
          />
        </Modal>
      </RenderIf>
    </>
  }
}

module AccountIdMethod = {
  @react.component
  let make = (~currency, ~currencyDict, ~account) => {
    let configDict = currencyDict->getDictfromDict(currency)
    <div className="border border-nd_gray-150 rounded-xl overflow-hidden p-6 flex flex-col gap-4">
      <p className={`${body.md.semibold}`}> {currency->snakeToTitle->React.string} </p>
      <hr />
      <div className="grid grid-cols-4 gap-2">
        {configDict
        ->Dict.keysToArray
        ->Array.map(config => {
          <AccountCheckBox key={randomString(~length=10)} config configDict account currency />
        })
        ->React.array}
      </div>
    </div>
  }
}

module AccountId = {
  @react.component
  let make = (~accountIdDict, ~account) => {
    let currencyDict =
      accountIdDict->getDictfromDict(account)->JSON.Encode.object->convertMapObjectToDict

    <div className="flex flex-col gap-6 col-span-3">
      <div className="max-w-3xl flex flex-col gap-8">
        {currencyDict
        ->Dict.keysToArray
        ->Array.map(currency => {
          <AccountIdMethod key={randomString(~length=10)} currency currencyDict account />
        })
        ->React.array}
      </div>
    </div>
  }
}

@react.component
let make = (~connectorMetaDataFields) => {
  let accountIdDict = connectorMetaDataFields->getDictfromDict("account_id")
  let accountIdKeys = accountIdDict->Dict.keysToArray

  {
    accountIdKeys
    ->Array.map(account => {
      <div className="px-8 py-4" key={randomString(~length=10)}>
        <div
          className="border border-nd_gray-200 rounded-xl overflow-hidden p-6 flex flex-col gap-4">
          <p className={`${body.lg.semibold}`}>
            {account->snakeToTitle->String.toUpperCase->React.string}
          </p>
          <AccountId accountIdDict account />
        </div>
      </div>
    })
    ->React.array
  }
}
