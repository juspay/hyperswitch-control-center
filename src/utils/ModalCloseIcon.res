@react.component
let make = (~fill="#7c7d82", ~onClick) => {
  let isMobileView = MatchMedia.useMobileChecker()
  let marginStyle = isMobileView ? "" : "mr-2"
  <AddDataAttributes attributes=[("data-component", `modalCloseIcon`)]>
    {if HSwitchGlobalVars.isHyperSwitchDashboard {
      <div className="" onClick>
        <Icon
          name="close" className="border-2 p-2 rounded-2xl bg-gray-100 cursor-pointer" size=30
        />
      </div>
    } else {
      <div className={`cursor-pointer opacity-50 dark:opacity-100 p-2 ${marginStyle}`} onClick>
        <svg
          width="14" height="14" viewBox="0 0 12 12" fill="none" xmlns="http://www.w3.org/2000/svg">
          <path
            d="M11.8339 1.34102L10.6589 0.166016L6.00057 4.82435L1.34224 0.166016L0.167236 1.34102L4.82557 5.99935L0.167236 10.6577L1.34224 11.8327L6.00057 7.17435L10.6589 11.8327L11.8339 10.6577L7.17557 5.99935L11.8339 1.34102Z"
            fill
          />
        </svg>
      </div>
    }}
  </AddDataAttributes>
}
