module CustomFilters = {
  @react.component
  let make = (
    ~setShowModal,
    ~tabNames,
    ~moduleName as _,
    ~setCustomFilter,
    ~currentFilterValue,
  ) => {
    open LogicUtils
    let (errMessage, setErrMessage) = React.useState(_ => "")

    let (completionDisposable, setCompletionDisposable) = Recoil.useRecoilState(
      AnalyticsAtoms.completionProvider,
    )
    let theme = switch ThemeProvider.useTheme() {
    | Dark => "vs-dark"
    | Light => "light"
    }
    let (localData, setLocalData) = React.useState(_ => currentFilterValue)
    let placeholderText = "ex: payment_method_type = 'UPI' and payment_method_type in ('WALLET', 'UPI') or currency not in ('GBP', 'AED') and auth_type != 'OTP'"
    let (placeholderTextSt, setPlaceHolder) = React.useState(_ => placeholderText)
    let onSubmit = _ => {
      setCustomFilter(localData)
      setShowModal(_ => false)
    }
    let onChange = str => {
      if str->isEmptyString {
        setPlaceHolder(_ => placeholderText)
      }
      setLocalData(_ => str)
    }
    React.useEffect(() => {
      setErrMessage(_ => "")
      if String.includes(localData, `"`) {
        setErrMessage(str => `${str} Please use ' instead of ".`)
      }
      let validatorArr =
        String.replaceRegExp(localData, %re("/ AND /gi"), "@@")
        ->String.replaceRegExp(%re("/ OR /gi"), "@@")
        ->String.split("@@")
      validatorArr->Array.forEach(ele => {
        let mArr =
          String.replaceRegExp(ele, %re("/ != /gi"), "@@")
          ->String.replaceRegExp(%re("/ > /gi"), "@@")
          ->String.replaceRegExp(%re("/ < /gi"), "@@")
          ->String.replaceRegExp(%re("/ >= /gi"), "@@")
          ->String.replaceRegExp(%re("/ <= /gi"), "@@")
          ->String.replaceRegExp(%re("/ = /gi"), "@@")
          ->String.replaceRegExp(%re("/ IN /gi"), "@@")
          ->String.replaceRegExp(%re("/ NOT IN /gi"), "@@")
          ->String.replaceRegExp(%re("/ LIKE /gi"), "@@")
          ->String.split("@@")

        let firstEle = mArr[0]->Option.getOr("")
        if (
          firstEle->isNonEmptyString &&
            tabNames->Array.indexOf(firstEle->String.trim->String.toLowerCase) < 0
        ) {
          setErrMessage(str => `${str} ${firstEle} is not a valid dimension.`)
        }
      })

      None
    }, [localData])

    let beforeMount = (monaco: Monaco.monaco) => {
      let provideCompletionItems = (model, position: Monaco.Language.position) => {
        let word = Monaco.Language.getWordUntilPosition(model, position)
        let range: Monaco.Language.range = {
          startLineNumber: position.lineNumber,
          endLineNumber: position.lineNumber,
          startColumn: word.startColumn,
          endColumn: word.endColumn,
        }
        let createSuggest = range => {
          Array.map(tabNames, val => {
            let value: Monaco.Language.labels = {
              label: val,
              insertText: val,
              range,
            }
            value
          })
        }
        {
          Monaco.Language.suggestions: createSuggest(range),
        }
      }
      switch completionDisposable {
      | Some(_val) => ()
      | None =>
        setCompletionDisposable(_ =>
          Monaco.Language.registerCompletionItemProvider(
            monaco.languages,
            "sql",
            {provideCompletionItems: provideCompletionItems},
          )->Some
        )
      }
    }
    let (mounseEnter, setMouseEnter) = React.useState(_ => false)
    <div
      className="border-t border-gray-200 p-5"
      onClick={_ => {setPlaceHolder(_ => "")}}
      onKeyPress={_ => {setMouseEnter(_ => true)}}
      onMouseLeave={_ => {setMouseEnter(_ => false)}}>
      {if placeholderTextSt->isNonEmptyString && localData->isEmptyString && !mounseEnter {
        <div className="monaco-placeholder text-black opacity-50 ml-6 ">
          {placeholderTextSt->React.string}
        </div>
      } else {
        React.null
      }}
      <Monaco.Editor
        language=#sql
        height="40vh"
        value={localData}
        theme
        onChange
        beforeMount
        options={
          emptySelectionClipboard: true,
          wordWrap: #on,
          lineNumbers: #off,
          minimap: {enabled: false},
          roundedSelection: false,
        }
      />
      <div>
        <span className="flex break-words text-red-800">
          {errMessage->isEmptyString ? React.null : React.string(errMessage)}
        </span>
        <div className="mt-6">
          <Button
            text="Apply Filter"
            buttonType=Primary
            buttonSize=Small
            onClick=onSubmit
            buttonState={errMessage->isEmptyString ? Normal : Disabled}
          />
        </div>
      </div>
    </div>
  }
}

@react.component
let make = (
  ~title="",
  ~initialFilters: array<EntityType.initialFilters<'t>>,
  ~options: array<EntityType.optionType<'t>>,
  ~popupFilterFields,
  ~initialFixedFilters: array<EntityType.initialFilters<'t>>,
  ~defaultFilterKeys: array<string>,
  ~tabNames: array<string>,
  ~updateUrlWith=?,
  ~showCustomFilter=true,
  ~customLeftView=React.null,
  ~filterButtonStyle="",
  ~moduleName="",
  ~customFilterKey="",
  ~filterFieldsPortalName="navbarSecondRow",
  ~filtersDisplayOption=true,
  ~showSelectFiltersSearch=false,
  ~refreshFilters=true,
) => {
  open LogicUtils
  let {globalUIConfig: {font: {textColor}}} = React.useContext(ThemeProvider.themeContext)
  let localFilters = initialFilters->Array.filter(item => item.localFilter->Option.isSome)
  let remoteOptions = options->Array.filter(item => item.localFilter->Option.isNone)
  let defaultFilters = ""->JSON.Encode.string
  let (showModal, setShowModal) = React.useState(_ => false)

  let {updateExistingKeys, filterValue, removeKeys} = React.useContext(FilterContext.filterContext)

  let currentCustomFilterValue = filterValue->Dict.get(customFilterKey)->Option.getOr("")

  let setCustomFilter = customFilter => {
    updateExistingKeys(Dict.fromArray([(customFilterKey, customFilter)]))
  }

  let customFilters = if customFilterKey->isNonEmptyString {
    <>
      <div className="mx-2">
        <Button
          text="Add Custom Filters"
          buttonType=Button.FilterAdd
          showBorder=false
          buttonSize=Small
          leftIcon={CustomIcon(<Icon name="add_custom_img" size=14 />)}
          textStyle={`${textColor.primaryNormal}`}
          onClick={_ => setShowModal(_ => true)}
        />
      </div>
      <Modal
        modalHeading="Add Custom Filter"
        showModal
        setShowModal
        modalClass="w-full md:w-2/3 mx-auto">
        <CustomFilters
          setShowModal
          tabNames
          moduleName
          setCustomFilter
          currentFilterValue=currentCustomFilterValue
        />
      </Modal>
    </>
  } else {
    React.null
  }

  let clearFilters = () => {
    let clearFilterKeys = [customFilterKey]->Array.concat(tabNames)
    removeKeys(clearFilterKeys)
  }

  <div className="flex-1 ml-1">
    <Filter
      title
      defaultFilters
      fixedFilters=initialFixedFilters
      requiredSearchFieldsList=[]
      localFilters
      localOptions=[]
      remoteOptions
      remoteFilters=initialFilters
      popupFilterFields
      autoApply=false
      addFilterStyle="pt-4"
      filterButtonStyle
      defaultFilterKeys
      customRightView=customFilters
      customLeftView
      ?updateUrlWith
      clearFilters
      initalCount={currentCustomFilterValue->isNonEmptyString ? 1 : 0}
      showSelectFiltersSearch
      tableName=moduleName
    />
  </div>
}
