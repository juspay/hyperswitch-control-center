@react.component
let make = (~isSelected, ~size: CheckBoxIcon.size=Small, ~fill="#0EB025", ~isDisabled=false) => {
  <AddDataAttributes attributes=[("data-radio", LogicUtils.getStringFromBool(isSelected))]>
    {if isSelected {
      <svg
        width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
        <rect width="16" height="16" rx="8" fill />
        <path
          fillRule="evenodd"
          clipRule="evenodd"
          d="M8 11C9.65685 11 11 9.65685 11 8C11 6.34315 9.65685 5 8 5C6.34315 5 5 6.34315 5 8C5 9.65685 6.34315 11 8 11Z"
          fill="white"
        />
      </svg>
    } else {
      <svg
        width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
        <rect width="16" height="16" rx="8" fill="url(#paint0_linear)" />
        <rect
          x="0.5" y="0.5" width="15" height="15" rx="7.5" stroke="#CCD2E2" strokeOpacity="0.75"
        />
        <defs>
          <linearGradient
            id="paint0_linear" x1="16" y1="16" x2="16" y2="0" gradientUnits="userSpaceOnUse">
            <stop stopColor="#F1F5FA" />
            <stop offset="1" stopColor="#FDFEFF" />
          </linearGradient>
        </defs>
      </svg>
    }}
  </AddDataAttributes>
}
