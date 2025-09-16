module RenderAccordian = {
  @react.component
  let make = (~initialExpandedArray=[], ~accordion) => {
    <Accordion
      initialExpandedArray
      accordion
      accordianTopContainerCss="border"
      accordianBottomContainerCss="p-5"
      contentExpandCss="px-4 py-3 !border-t-0"
      titleStyle="font-semibold text-bold text-md"
    />
  }
}

module AccountIdCurrencyFields = {
  @react.component
  let make = (~configDict, ~selectedConfig, ~account, ~currency) => {
    open LogicUtils
    let dict = configDict->getArrayFromDict(selectedConfig, [])->Array.at(0)
    let fields = switch dict {
    | Some(val) => val->convertMapObjectToDict
    | _ => Dict.make()
    }->CommonConnectorUtils.inputFieldMapper
    let {\"type": inputType, name} = fields
    let name = `metadata.account_id.${account}.${currency}.${name}`
    <FormRenderer.FieldRenderer
      labelClass="font-semibold !text-hyperswitch_black"
      field={ConnectorMetaDataUtils.getField(~inputType, ~name, ~connectorMetaDataFields=fields)}
    />
  }
}

module AccountCheckBox = {
  @react.component
  let make = (~config, ~configDict, ~account, ~currency) => {
    open LogicUtils
    let (showConfigModal, setShowAccountConfigModal) = React.useState(_ => false)
    let (selectedConfig, setSelectedConfig) = React.useState(_ => "")
    let handleCheckBox = (~config) => {
      setShowAccountConfigModal(_ => !showConfigModal)
      setSelectedConfig(_ => config)
    }
    let {globalUIConfig: {font: {textColor}}} = React.useContext(ThemeProvider.themeContext)
    <div>
      <div className={"flex gap-1.5 items-center"} onClick={_ => handleCheckBox(~config)}>
        <CheckBoxIcon isSelected=true />
        <p className="text-sm font-medium leading-5 text-grey-700 opacity-50 cursor-pointer">
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
          //   onCloseClickCustomFun={removeSelectedWallet}
          paddingClass=""
          revealFrom=Reveal.Right
          modalClass="w-full md:w-1/3 !h-full overflow-y-scroll !overflow-x-hidden rounded-none text-jp-gray-900"
          childClass={""}>
          <AccountIdCurrencyFields configDict selectedConfig account currency />
        </Modal>
      </RenderIf>
    </div>
  }
}

module AccountIdMethod = {
  @react.component
  let make = (~currency, ~currencyDict, ~account) => {
    open LogicUtils

    let configDict = currencyDict->getDictfromDict(currency)

    <div className="border border-nd_gray-150 rounded-xl overflow-hidden p-6 flex flex-col gap-4">
      <p className="font-semibold text-bold text-lg"> {currency->snakeToTitle->React.string} </p>
      <hr />
      <div className="grid grid-cols-4 gap-2">
        {configDict
        ->Dict.keysToArray
        ->Array.map(config => {
          <AccountCheckBox config configDict account currency />
        })
        ->React.array}
      </div>
    </div>
  }
}

module AccountId = {
  @react.component
  let make = (~accountIdDict, ~account) => {
    open LogicUtils

    let currencyDict =
      accountIdDict->getDictfromDict(account)->JSON.Encode.object->convertMapObjectToDict

    <div className="flex flex-col gap-6 col-span-3">
      <div className="max-w-3xl flex flex-col gap-8">
        {currencyDict
        ->Dict.keysToArray
        ->Array.map(currency => {
          <AccountIdMethod currency currencyDict account />
        })
        ->React.array}
      </div>
    </div>
  }
}

@react.component
let make = (~connectorMetaDataFields, ~initialValues) => {
  open LogicUtils
  let accountIdDict = connectorMetaDataFields->getDictfromDict("account_id")
  let accountIdKeys = accountIdDict->Dict.keysToArray
  let onSubmit = async (values, _form: ReactFinalForm.formApi) => {
    Nullable.null
  }
  <div>
    <Form onSubmit initialValues={initialValues}>
      {accountIdKeys
      ->Array.map(account => {
        <div className="p-1" key={randomString(~length=10)}>
          <RenderAccordian
            //   initialExpandedArray=[0]
            accordion=[
              {
                title: account->snakeToTitle,
                renderContent: () => {
                  <AccountId accountIdDict account />
                },
                renderContentOnTop: None,
              },
            ]
          />
        </div>
      })
      ->React.array}
      <FormValuesSpy />
    </Form>
  </div>
}
