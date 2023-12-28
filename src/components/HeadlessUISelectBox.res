open HeadlessUI

type updatedOptionWithIcons = {
  label: string,
  value: string,
  isDisabled: bool,
  leftIcon: Button.iconType,
  customTextStyle: option<string>,
  customIconStyle: option<string>,
  rightIcon: Button.iconType,
  description: option<string>,
}

@react.component
let make = (
  ~value: value=String(""),
  ~setValue,
  ~options: array<updatedOptionWithIcons>,
  ~children,
  ~dropdownPosition=Left,
  ~className="",
  ~dropDownClass="w-52",
  ~deSelectAllowed=true,
  ~showBottomUp=false,
  ~textClass="text-sm",
  ~closeListOnClick=false,
) => {
  let dropdownPositionClass = switch dropdownPosition {
  | Left => "right-0"
  | _ => "left-0"
  }
  let (showList, setShowList) = React.useState(_ => false)
  let closeClick = _ => {
    setShowList(_ => !showList)
  }

  <div className="text-left">
    <Menu \"as"="div" className="relative inline-block text-left">
      {menuProps =>
        <div>
          <Menu.Button className> {buttonProps => children} </Menu.Button>
          <Transition
            \"as"="span"
            enter="transition ease-out duration-100"
            enterFrom="transform opacity-0 scale-95"
            enterTo="transform opacity-100 scale-100"
            leave="transition ease-in duration-75"
            leaveFrom="transform opacity-100 scale-100"
            leaveTo="transform opacity-0 scale-95">
            {if showBottomUp {
              <BottomModal headerText="Select Action" onCloseClick=closeClick>
                <Menu.Items
                  className={`w-full p-1 origin-top-right bg-white dark:bg-jp-gray-950 rounded-md shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none`}>
                  {props =>
                    options
                    ->Array.mapWithIndex((option, index) => {
                      let selected = switch value {
                      | String(v) => v === option.value
                      | Array(arr) => arr->Array.includes(option.value)
                      }
                      let disabledClass = option.isDisabled ? "disabled cursor-not-allowed" : ""

                      <Menu.Item key={index->Js.Int.toString}>
                        {props => {
                          let isCloseIcon = props["active"] && deSelectAllowed

                          <div
                            onClick={ev => {
                              if !closeListOnClick {
                                ev->ReactEvent.Mouse.stopPropagation
                                ev->ReactEvent.Mouse.preventDefault
                              }
                              setValue(option.value)
                            }}
                            className={`group flex flex-row items-center justify-between rounded-md w-full p-3 text-fs-14 font-normal cursor-pointer ${props["active"]
                                ? "bg-gray-100 dark:bg-gray-700"
                                : ""} ${disabledClass}`}
                            disabled={option.isDisabled}>
                            <div className="flex flex-row items-center gap-2">
                              {switch option.leftIcon {
                              | FontAwesome(iconName) =>
                                <Icon
                                  className={`align-middle ${option.customIconStyle->Belt.Option.getWithDefault(
                                      "",
                                    )}`}
                                  size=14
                                  name=iconName
                                />
                              | CustomIcon(element) => element

                              | Euler(iconName) =>
                                <Icon className="align-middle" size=12 name=iconName />
                              | _ => React.null
                              }}
                              <AddDataAttributes attributes=[("data-options", option.label)]>
                                <div
                                  className={option.customTextStyle->Belt.Option.getWithDefault(
                                    "",
                                  )}>
                                  <span className={selected ? "text-blue-800 font-semibold" : ""}>
                                    {React.string(option.label)}
                                  </span>
                                </div>
                              </AddDataAttributes>
                              {switch option.rightIcon {
                              | FontAwesome(iconName) =>
                                <Icon
                                  className={`align-middle ${option.customIconStyle->Belt.Option.getWithDefault(
                                      "",
                                    )}`}
                                  size=12
                                  name=iconName
                                />
                              | CustomIcon(element) => element

                              | Euler(iconName) =>
                                <Icon className="align-middle" size=12 name=iconName />
                              | _ => React.null
                              }}
                            </div>
                            <UIUtils.RenderIf condition=selected>
                              {if isCloseIcon {
                                <Icon name="close" size=10 className="text-red-500 mr-1" />
                              } else {
                                <Tick isSelected=selected />
                              }}
                            </UIUtils.RenderIf>
                          </div>
                        }}
                      </Menu.Item>
                    })
                    ->React.array}
                </Menu.Items>
              </BottomModal>
            } else {
              <Menu.Items
                className={`absolute z-10 ${dropdownPositionClass} mt-2 p-1 origin-top-right bg-white dark:bg-jp-gray-950 rounded-md shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none  ${dropDownClass}`}>
                {props =>
                  options
                  ->Array.mapWithIndex((option, index) => {
                    let selected = switch value {
                    | String(v) => v === option.value
                    | Array(arr) => arr->Array.includes(option.value)
                    }

                    let disabledClass = option.isDisabled ? "disabled cursor-not-allowed" : ""

                    <Menu.Item key={index->Js.Int.toString}>
                      {props =>
                        <div
                          onClick={ev => {
                            if !closeListOnClick {
                              ev->ReactEvent.Mouse.stopPropagation
                              ev->ReactEvent.Mouse.preventDefault
                            }
                            setValue(option.value)
                          }}
                          className={`group flex flex-row items-center justify-between rounded-md w-full p-2 ${textClass} cursor-pointer ${props["active"]
                              ? "bg-gray-100 dark:bg-gray-700"
                              : ""} ${disabledClass}`}
                          disabled={option.isDisabled}>
                          <div className="flex flex-row items-center gap-2">
                            {switch option.leftIcon {
                            | FontAwesome(iconName) =>
                              <Icon
                                className={`align-middle ${option.customIconStyle->Belt.Option.getWithDefault(
                                    "",
                                  )}`}
                                size=12
                                name=iconName
                              />
                            | CustomIcon(element) => element

                            | Euler(iconName) =>
                              <Icon className="align-middle" size=12 name=iconName />
                            | _ => React.null
                            }}
                            <AddDataAttributes attributes=[("data-options", option.label)]>
                              <div
                                className={option.customTextStyle->Belt.Option.getWithDefault("")}>
                                <span className={selected ? "text-blue-800 font-semibold" : ""}>
                                  {React.string(option.label)}
                                </span>
                              </div>
                            </AddDataAttributes>
                            {switch option.rightIcon {
                            | FontAwesome(iconName) =>
                              <Icon
                                className={`align-middle ${option.customIconStyle->Belt.Option.getWithDefault(
                                    "",
                                  )}`}
                                size=12
                                name=iconName
                              />
                            | CustomIcon(element) => element

                            | Euler(iconName) =>
                              <Icon className="align-middle" size=12 name=iconName />
                            | _ => React.null
                            }}
                          </div>
                          {selected
                            ? props["active"] && deSelectAllowed
                                ? <Icon name="close" size=10 className="text-red-500 mr-1" />
                                : <Tick isSelected=selected />
                            : React.null}
                        </div>}
                    </Menu.Item>
                  })
                  ->React.array}
              </Menu.Items>
            }}
          </Transition>
        </div>}
    </Menu>
  </div>
}
