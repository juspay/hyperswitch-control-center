type passwordCheck = {
  number: bool,
  lowercase: bool,
  uppercase: bool,
  specialChar: bool,
  minEightChars: bool,
}

type chipType = Number | Lowercase | Uppercase | SpecialChar | MinEightChars

module PasswordChip = {
  @react.component
  let make = (~passwordChecks: passwordCheck, ~chipType: chipType, ~customTextStyle="") => {
    let initalClassName = " bg-gray-50 dark:bg-jp-gray-960/75 border-gray-300 inline-block text-xs p-2 border-0.5 dark:border-0 border-gray-300 rounded-2xl"
    let passedClassName = "flex items-center bg-green-200 dark:bg-green-800/25 border-gray-300 inline-block text-xs p-2 border-0.5 border-green-800 rounded-2xl gap-1"

    let (isCheckPassed, checkName) = switch chipType {
    | Number => (passwordChecks.number, "Numbers")
    | Lowercase => (passwordChecks.lowercase, "Lowercase Letters")
    | Uppercase => (passwordChecks.uppercase, "Uppercase Letters")
    | SpecialChar => (passwordChecks.specialChar, "Special Characters")
    | MinEightChars => (passwordChecks.minEightChars, "8 Characters")
    }

    let textClass = isCheckPassed ? "text-green-800 font-medium" : "font-base dark:text-gray-100"

    <p className={isCheckPassed ? passedClassName : initalClassName}>
      <UIUtils.RenderIf condition=isCheckPassed>
        <Icon name="check" size=9 />
      </UIUtils.RenderIf>
      <span className={`${textClass} ${customTextStyle}`}> {React.string(checkName)} </span>
    </p>
  }
}

module PasswordCheckModal = {
  @react.component
  let make = (~passwordChips: array<chipType>, ~passwordChecks, ~modalRef) => {
    let getDetails = chipType =>
      switch chipType {
      | Number => "4. Numbers (123)"
      | Lowercase => "2. Lowercase (abc)"
      | Uppercase => "1. Uppercase (ABC)"
      | SpecialChar => "3. Symbols ($#%&*)"
      | MinEightChars => "5. Minimum 8 characters"
      }
    let isCheckPassed = chipType =>
      switch chipType {
      | Number => passwordChecks.number
      | Lowercase => passwordChecks.lowercase
      | Uppercase => passwordChecks.uppercase
      | SpecialChar => passwordChecks.specialChar
      | MinEightChars => passwordChecks.minEightChars
      }
    <div
      ref={modalRef->ReactDOM.Ref.domRef}
      className="absolute z-40 right-0 mt-3 w-fit flex flex-col gap-1.5 p-4 bg-white border border-jp-2-light-gray-600 rounded-lg">
      <span className="text-jp-2-gray-700 font-semibold text-fs-12 whitespace-nowrap">
        {"Must have at least 8 characters"->React.string}
      </span>
      <div className="flex items-center justify-between gap-1.5">
        {passwordChips
        ->Js.Array2.mapi((chip, index) => {
          let barClass = isCheckPassed(chip)
            ? "w-10 h-0.5 bg-jp-2-green-200 rounded-sm"
            : "w-10 h-0.5 bg-jp-2-light-gray-600 rounded-sm"

          <div key={`${index->Belt.Int.toString} chip`} className=barClass />
        })
        ->React.array}
      </div>
      <span className="text-jp-2-gray-300 font-medium text-fs-10-lh-18">
        {"Password should contain:"->React.string}
      </span>
      {passwordChips
      ->Js.Array2.mapi((chip, index) => {
        let textClass = isCheckPassed(chip) ? "line-through opacity-50" : ""
        let detailText = getDetails(chip)
        <span key={`${index->Belt.Int.toString} info`} className=textClass>
          {detailText->React.string}
        </span>
      })
      ->React.array}
    </div>
  }
}

@react.component
let make = (
  ~input: ReactFinalForm.fieldRenderPropsInput,
  ~placeholder,
  ~leftIcon=?,
  ~autoComplete="new-password",
  ~customStyle="",
  ~customPaddingClass="",
  ~customTextStyle="",
  ~specialCharatersInfoText="",
  ~customDashboardClass=?,
) => {
  let initialPasswordState = {
    number: false,
    lowercase: false,
    uppercase: false,
    specialChar: false,
    minEightChars: false,
  }
  let (passwordChecks, setPasswordChecks) = React.useState(_ => initialPasswordState)
  let (showValidation, setShowValidation) = React.useState(_ => false)
  let modalRef = React.useRef(Js.Nullable.null)

  OutsideClick.useOutsideClick(
    ~refs={ArrayOfRef([modalRef])},
    ~isActive=showValidation,
    ~callback=() => {
      setShowValidation(_ => false)
    },
    (),
  )

  let validateFunc = strVal => {
    if strVal->Js.String2.length >= 8 {
      setPasswordChecks(prev => {
        ...prev,
        minEightChars: true,
      })
    }
    if Js.Re.test_(%re("/^(?=.*[A-Z])/"), strVal) {
      setPasswordChecks(prev => {
        ...prev,
        uppercase: true,
      })
    }
    if Js.Re.test_(%re("/^(?=.*[a-z])/"), strVal) {
      setPasswordChecks(prev => {
        ...prev,
        lowercase: true,
      })
    }
    if Js.Re.test_(%re("/^(?=.*[0-9])/"), strVal) {
      setPasswordChecks(prev => {
        ...prev,
        number: true,
      })
    }
    let specialCharCheck = Js.Re.test_(%re("/^(?=.*[!@#$%^&*_])/"), strVal)
    if specialCharCheck {
      setPasswordChecks(prev => {
        ...prev,
        specialChar: true,
      })
    }
  }
  let newInput = {
    ...input,
    onChange: ev => {
      input.onChange(ev)
      setPasswordChecks(_ => initialPasswordState)
      let strVal = ReactEvent.Form.target(ev)["value"]
      strVal != "" ? setShowValidation(_ => true) : setShowValidation(_ => false)
      strVal->validateFunc
    },
    onBlur: ev => {
      setShowValidation(_ => false)
      input.onBlur(ev)
    },
  }

  let passwordChips = [MinEightChars, Lowercase, Number, SpecialChar, Uppercase]

  <>
    <TextInput
      input=newInput
      placeholder
      type_="password"
      autoComplete
      ?leftIcon
      customStyle
      customPaddingClass
      ?customDashboardClass
    />
    <div
      className={`${showValidation
          ? "block"
          : "hidden"} flex flex-row flex-wrap gap-y-3 gap-x-2 mt-3`}>
      {passwordChips
      ->Js.Array2.mapi((chipType, index) => {
        if specialCharatersInfoText != "" && chipType === SpecialChar {
          <ToolTip
            tooltipWidthClass="w-fit"
            description=specialCharatersInfoText
            toolTipFor={<PasswordChip
              key={`check_${index->Belt.Int.toString}`} passwordChecks chipType customTextStyle
            />}
          />
        } else {
          <PasswordChip
            key={`check_${index->Belt.Int.toString}`} passwordChecks chipType customTextStyle
          />
        }
      })
      ->React.array}
    </div>
  </>
}
