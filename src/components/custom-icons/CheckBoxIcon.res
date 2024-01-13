type size = Small | Large

open LottieFiles
@react.component
let make = (
  ~isSelected,
  ~isDisabled=false,
  ~setIsSelected=?,
  ~size: size=Small,
  ~isSelectedStateMinus=false,
  ~checkboxDimension="w-4 h-4",
  ~isCheckboxSelectedClass=false,
  ~stopPropagationNeeded=false,
) => {
  let onClick = ev => {
    if stopPropagationNeeded {
      ev->ReactEvent.Mouse.stopPropagation
    }
    switch setIsSelected {
    | Some(fn) => fn(!isSelected)
    | None => ()
    }
  }

  let enterCheckBoxJson = useLottieJson(enterCheckBox)
  let exitCheckBoxJson = useLottieJson(exitCheckBox)
  let (defaultState, autoplay) = LottieIcons.useLottieIcon(
    isSelected,
    enterCheckBoxJson,
    exitCheckBoxJson,
  )
  let checkboxUpiClass = isCheckboxSelectedClass ? "border-2" : "border"
  let checkboxBorderClass = `rounded-md ${checkboxUpiClass} border-gray-300 dark:border-gray-600`
  <AddDataAttributes
    attributes=[("data-selected-checkbox", isSelected ? "Selected" : "NotSelected")]>
    {if isDisabled {
      if isSelected {
        <svg
          width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
          <rect width="16" height="16" rx="4" fill="#b0b0b0" />
          <path
            fillRule="evenodd"
            clipRule="evenodd"
            d="M11.3135 5.29325C10.9225 4.90225 10.2895 4.90225 9.8995 5.29325L6.5355 8.65725L5.7065 7.82925C5.3165 7.43825 4.6835 7.43825 4.2925 7.82925C3.9025 8.21925 3.9025 8.85225 4.2925 9.24325L5.8285 10.7783C6.2185 11.1693 6.8515 11.1693 7.2425 10.7783L11.3135 6.70725C11.7045 6.31725 11.7045 5.68425 11.3135 5.29325Z"
            fill="white"
          />
        </svg>
      } else {
        <svg
          width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
          <rect width="16" height="16" rx="4" fill="url(#paint0_linear)" />
          <rect
            x="0.5" y="0.5" width="15" height="15" rx="3.5" stroke="#CCD2E2" strokeOpacity="0.75"
          />
          <defs>
            <linearGradient
              id="paint0_linear" x1="16" y1="16" x2="16" y2="0" gradientUnits="userSpaceOnUse">
              <stop stopColor="#F1F5FA" />
              <stop offset="1" stopColor="#FDFEFF" />
            </linearGradient>
          </defs>
        </svg>
      }
    } else if isSelectedStateMinus {
      if isSelected {
        <div className={`${checkboxDimension}`} onClick>
          <svg viewBox="0 0 16 17" fill="none" xmlns="http://www.w3.org/2000/svg">
            <rect y="0.5" width="16" height="16" rx="4" fill="#0EB025" />
            <rect x="4" y="7.5" width="8" height="2" rx="1" fill="white" />
          </svg>
        </div>
      } else {
        <div className={`${checkboxDimension} ${checkboxBorderClass}`} onClick />
      }
    } else {
      <div className={`${checkboxDimension} ${!isSelected ? checkboxBorderClass : ""}`} onClick>
        <ReactSuspenseWrapper>
          <Lottie
            key={autoplay ? "true" : "false"}
            animationData={defaultState}
            autoplay={autoplay}
            loop=false
          />
        </ReactSuspenseWrapper>
      </div>
    }}
  </AddDataAttributes>
}
