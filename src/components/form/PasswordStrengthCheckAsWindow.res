type passwordCheck = {
  number: bool,
  lowercase: bool,
  uppercase: bool,
  specialChar: bool,
  minEightChars: bool,
}

type chipType = Number | Lowercase | Uppercase | SpecialChar

module PasswordCheckWindow = {
  @react.component
  let make = (~passwordChecks: passwordCheck, ~chipType: chipType, ~customTextStyle="") => {
    let (isCheckPassed, checkName) = switch chipType {
    | Number => (passwordChecks.number, "2. Numbers")
    | Lowercase => (passwordChecks.lowercase, "1. Lowercase Letters")
    | Uppercase => (passwordChecks.uppercase, "4. Uppercase Letters")
    | SpecialChar => (passwordChecks.specialChar, "3. Special Characters")
    }
    let textClass = isCheckPassed ? "line-through opacity-50" : ""
    <div className="flex flex-row gap-x-2 text-[10px] font-medium text-[#616771]">
      <span className={`${textClass} ${customTextStyle}`}> {React.string(checkName)} </span>
    </div>
  }
}

module BarCounter = {
  @react.component
  let make = (~totalBar: int, ~passwordChecks) => {
    let bars = Belt.Array.makeUninitialized(totalBar)
    let greenBar =
      (passwordChecks.number ? 1 : 0) +
      (passwordChecks.lowercase ? 1 : 0) +
      (passwordChecks.uppercase ? 1 : 0) + (passwordChecks.specialChar ? 1 : 0)

    let updatedBars = Belt.Array.mapWithIndex(bars, (i, _) => {
      if i < greenBar {
        <div className="w-full bar bg-green-500 h-1  rounded" />
      } else {
        <div className="w-full bar bg-gray-300 h-1 rounded" />
      }
    })
    <div className="flex flex-1 items-center justify-center space-x-1">
      {React.array(updatedBars)}
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
    if strVal->String.length >= 8 {
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
    if Js.Re.test_(%re("/^(?=.*[!@#$%^&*_])/"), strVal) {
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
  }

  let passwordChips = [Lowercase, Number, SpecialChar, Uppercase]

  <div className="relative">
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
      ref={modalRef->ReactDOM.Ref.domRef}
      className={`${showValidation
          ? "block"
          : "hidden"}  z-10 absolute  bg-white p-4 border  border-gray-300 rounded-md w-[217px] flex flex-col gap-[6px] mt-2`}>
      <div className="text-jp-2-gray-700 text-xs font-semibold">
        {"Must have at least 8 characters"->React.string}
      </div>
      <BarCounter totalBar=4 passwordChecks />
      <div>
        {passwordChips
        ->Array.mapWithIndex((chipType, index) => {
          <PasswordCheckWindow
            key={`check_${index->Belt.Int.toString}`} passwordChecks chipType customTextStyle
          />
        })
        ->React.array}
      </div>
    </div>
  </div>
}
