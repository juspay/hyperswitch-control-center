module Transition = {
  @module("@headlessui/react") @react.component
  external make: (
    ~\"as": string,
    ~show: bool=?,
    ~appear: bool=?,
    ~unmount: bool=?,
    ~enter: string=?,
    ~enterFrom: string=?,
    ~enterTo: string=?,
    ~leave: string=?,
    ~leaveFrom: string=?,
    ~leaveTo: string=?,
    ~beforeEnter: unit => unit=?,
    ~afterEnter: unit => unit=?,
    ~beforeLeave: unit => unit=?,
    ~afterLeave: unit => unit=?,
    ~className: string=?,
    ~children: React.element=?,
  ) => React.element = "Transition"

  module Child = {
    @module("@headlessui/react") @scope("Transition") @react.component
    external make: (
      ~\"as": string=?,
      ~appear: bool=?,
      ~unmount: bool=?,
      ~enter: string=?,
      ~enterFrom: string=?,
      ~enterTo: string=?,
      ~leave: string=?,
      ~leaveFrom: string=?,
      ~leaveTo: string=?,
      ~beforeEnter: unit => unit=?,
      ~afterEnter: unit => unit=?,
      ~beforeLeave: unit => unit=?,
      ~afterLeave: unit => unit=?,
      ~children: React.element=?,
    ) => React.element = "Child"
  }
}

//---------------------------------------

module RadioGroup = {
  type optionRenderArgs = {"active": bool, "checked": bool, "disabled": bool}

  @module("@headlessui/react") @react.component
  external make: (
    ~\"as": string=?,
    ~value: 't,
    ~className: string=?,
    ~onChange: 't => unit,
    ~disabled: bool=?,
    ~children: React.element=?,
  ) => React.element = "RadioGroup"

  module Option = {
    @module("@headlessui/react") @scope("RadioGroup") @react.component
    external make: (
      ~\"as": string=?,
      ~value: 't,
      ~disabled: bool=?,
      ~className: string=?,
      ~children: optionRenderArgs => React.element,
    ) => React.element = "Option"
  }

  module Label = {
    @module("@headlessui/react") @scope("RadioGroup") @react.component
    external make: (
      ~\"as": string=?,
      ~className: string=?,
      ~children: React.element=?,
    ) => React.element = "Label"
  }

  module Description = {
    @module("@headlessui/react") @scope("RadioGroup") @react.component
    external make: (
      ~\"as": string=?,
      ~className: string=?,
      ~children: React.element=?,
    ) => React.element = "Description"
  }
}

//----------------------------------------------------

module Popover = {
  type popoverRenderArgs = {"open": bool}
  type overlayRenderArgs = {"open": bool}
  type buttonRenderArgs = {"open": bool}
  type panelRenderArgs = {"open": bool, "close": unit => unit}

  @module("@headlessui/react") @react.component
  external make: (
    ~\"as": string=?,
    ~className: string=?,
    ~children: popoverRenderArgs => React.element=?,
  ) => React.element = "Popover"

  module Overlay = {
    @module("@headlessui/react") @scope("Popover") @react.component
    external make: (
      ~\"as": string=?,
      ~className: string=?,
      ~children: overlayRenderArgs => React.element=?,
    ) => React.element = "Overlay"
  }

  module Button = {
    @module("@headlessui/react") @scope("Popover") @react.component
    external make: (
      ~\"as": string=?,
      ~className: string=?,
      ~children: buttonRenderArgs => React.element=?,
    ) => React.element = "Button"
  }

  module Panel = {
    @module("@headlessui/react") @scope("Popover") @react.component
    external make: (
      ~\"as": string=?,
      ~focus: bool=?,
      ~static: bool=?,
      ~unmount: bool=?,
      ~className: string=?,
      ~children: panelRenderArgs => React.element=?,
    ) => React.element = "Panel"
  }

  module Group = {
    @module("@headlessui/react") @scope("Popover") @react.component
    external make: (~\"as": string=?, ~className: string=?) => React.element = "Group"
  }
}

//---------------------------------------------------------

module Dialog = {
  type dialogRenderArgs = {"open": bool}
  type overlayRenderArgs = {"open": bool}
  type titleRenderArgs = {"open": bool}
  type descriptionRenderArgs = {"open": bool}

  @module("@headlessui/react") @react.component
  external make: (
    ~\"open": bool=?,
    ~onClose: unit => unit=?,
    ~initialFocus: React.ref<unit>=?,
    ~\"as": string=?,
    ~static: bool=?,
    ~unmount: bool=?,
    ~className: string=?,
    ~children: dialogRenderArgs => React.element,
  ) => React.element = "Dialog"

  module Overlay = {
    @module("@headlessui/react") @scope("Dialog") @react.component
    external make: (
      ~\"as": string=?,
      ~className: string=?,
    ) => // ~children: overlayRenderArgs => React.element,
    React.element = "Overlay"
  }

  module Title = {
    @module("@headlessui/react") @scope("Dialog") @react.component
    external make: (
      ~\"as": string=?,
      ~className: string=?,
      ~children: titleRenderArgs => React.element,
    ) => React.element = "Title"
  }

  module Description = {
    @module("@headlessui/react") @scope("Dialog") @react.component
    external make: (
      ~\"as": string=?,
      ~className: string=?,
      ~children: descriptionRenderArgs => React.element,
    ) => React.element = "Description"
  }
}

//--------------------------------------------

module Disclosure = {
  type disclosureRenderArgs = {"open": bool}
  type panelRenderArgs = {"open": bool}
  type buttonRenderArgs = {"open": bool}

  @module("@headlessui/react") @react.component
  external make: (
    ~\"as": string=?,
    ~defaultOpen: bool=?,
    ~className: string=?,
    ~children: disclosureRenderArgs => React.element,
  ) => React.element = "Disclosure"

  module Panel = {
    @module("@headlessui/react") @scope("Disclosure") @react.component
    external make: (
      ~\"as": string=?,
      ~static: bool=?,
      ~unmount: bool=?,
      ~className: string=?,
      ~children: panelRenderArgs => React.element,
    ) => React.element = "Panel"
  }

  module Button = {
    @module("@headlessui/react") @scope("Disclosure") @react.component
    external make: (
      ~\"as": string=?,
      ~className: string=?,
      ~children: buttonRenderArgs => React.element,
    ) => React.element = "Button"
  }
}

//----------------------------------------------------

module Switch = {
  type switchRenderArgs = {"checked": bool}

  @module("@headlessui/react") @react.component
  external make: (
    ~\"as": React.element=?,
    ~checked: bool,
    ~onChange: bool => unit,
    ~className: string=?,
    ~children: switchRenderArgs => React.element=?,
  ) => React.element = "Switch"

  module Label = {
    @module("@headlessui/react") @react.component
    external make: (
      ~\"as": React.element=?,
      ~passive: bool=?,
      ~className: string,
    ) => React.element = "Label"
  }

  module Description = {
    @module("@headlessui/react") @react.component
    external make: (~\"as": React.element=?, ~className: string) => React.element = "Description"
  }

  module Group = {
    @module("@headlessui/react") @react.component
    external make: (~\"as": React.element=?, ~className: string) => React.element = "Group"
  }
}

//--------------------------------------------------------

module Listbox = {
  type listboxRenderArgs = {"open": bool, "disabled": bool}
  type buttonRenderArgs = {"open": bool, "disabled": bool}
  type labelRenderArgs = {"open": bool, "disabled": bool}
  type optionsRenderArgs = {"open": bool}
  type optionRenderArgs = {"active": bool, "selected": bool, "disabled": bool}

  @module("@headlessui/react") @react.component
  external make: (
    ~\"as": React.element=?,
    ~disabled: bool=?,
    ~value: 't=?,
    ~className: string=?,
    ~onChange: 't => unit=?,
    ~children: listboxRenderArgs => React.element=?,
  ) => React.element = "Listbox"

  module Button = {
    @module("@headlessui/react") @scope("Listbox") @react.component
    external make: (
      ~\"as": React.element=?,
      ~className: string=?,
      ~children: buttonRenderArgs => React.element=?,
    ) => React.element = "Button"
  }

  module Label = {
    @module("@headlessui/react") @scope("Listbox") @react.component
    external make: (
      ~\"as": React.element=?,
      ~className: string=?,
      ~children: buttonRenderArgs => React.element=?,
    ) => React.element = "Label"
  }

  module Options = {
    @module("@headlessui/react") @scope("Listbox") @react.component
    external make: (
      ~\"as": React.element=?,
      ~static: bool=?,
      ~unmount: bool=?,
      ~className: string=?,
      ~children: optionsRenderArgs => React.element=?,
    ) => React.element = "Options"
  }

  module Option = {
    @module("@headlessui/react") @scope("Listbox") @react.component
    external make: (
      ~\"as": React.element=?,
      ~value: 't=?,
      ~disabled: bool=?,
      ~className: string=?,
      ~onClick: unit => unit=?, //added externally
      ~children: optionRenderArgs => React.element=?,
    ) => React.element = "Option"
  }
}

module Combobox = {
  type comboboxRenderArgs = {"open": bool, "disabled": bool}
  type buttonRenderArgs = {"open": bool, "disabled": bool}
  type labelRenderArgs = {"open": bool, "disabled": bool}
  type optionsRenderArgs = {"open": bool}
  type optionRenderArgs = {"active": bool, "selected": bool, "disabled": bool}

  @module("@headlessui/react") @react.component
  external make: (
    ~\"as": React.element=?,
    ~disabled: bool=?,
    ~value: 't=?,
    ~className: string=?,
    ~onChange: 't => unit=?,
    ~children: comboboxRenderArgs => React.element=?,
  ) => React.element = "Combobox"

  module Input = {
    @module("@headlessui/react") @scope("Combobox") @react.component
    external make: (
      ~\"as": string=?,
      ~className: string=?,
      ~autoFocus: bool=?,
      ~autoComplete: string=?,
      ~placeholder: string=?,
      ~displayValue: _ => string=?,
      ~onChange: 't => unit=?,
    ) => React.element = "Input"
  }

  module Button = {
    @module("@headlessui/react") @scope("Combobox") @react.component
    external make: (
      ~\"as": React.element=?,
      ~className: string=?,
      ~children: buttonRenderArgs => React.element=?,
    ) => React.element = "Button"
  }

  module Label = {
    @module("@headlessui/react") @scope("Combobox") @react.component
    external make: (
      ~\"as": React.element=?,
      ~className: string=?,
      ~children: buttonRenderArgs => React.element=?,
    ) => React.element = "Label"
  }

  module Options = {
    @module("@headlessui/react") @scope("Combobox") @react.component
    external make: (
      ~\"as": React.element=?,
      ~static: bool=?,
      ~unmount: bool=?,
      ~className: string=?,
      ~children: optionsRenderArgs => React.element=?,
    ) => React.element = "Options"
  }

  module Option = {
    @module("@headlessui/react") @scope("Combobox") @react.component
    external make: (
      ~\"as": React.element=?,
      ~value: 't=?,
      ~disabled: bool=?,
      ~className: string=?,
      ~onClick: unit => unit=?,
      ~children: optionRenderArgs => React.element=?,
    ) => React.element = "Option"
  }
}

//----------------------------------------------------

module Menu = {
  type buttonRenderArgs = {"open": bool}
  type menuRenderArgs = {"open": bool}
  type itemsRenderArgs = {"open": bool}
  type itemRenderArgs = {"active": bool, "disabled": bool}

  @module("@headlessui/react") @react.component
  external make: (
    ~\"as": string=?,
    ~className: string=?,
    ~children: menuRenderArgs => React.element=?,
  ) => React.element = "Menu"

  module Items = {
    @module("@headlessui/react") @scope("Menu") @react.component
    external make: (
      ~\"as": string=?,
      ~static: bool=?,
      ~unmount: bool=?,
      ~className: string=?,
      ~children: itemsRenderArgs => React.element=?,
    ) => React.element = "Items"
  }

  module Item = {
    @module("@headlessui/react") @scope("Menu") @react.component
    external make: (
      ~\"as": string=?,
      ~className: string=?,
      ~disabled: bool=?,
      ~children: itemRenderArgs => React.element=?,
    ) => React.element = "Item"
  }

  module Button = {
    @module("@headlessui/react") @scope("Menu") @react.component
    external make: (
      ~\"as": string=?,
      ~className: string=?,
      ~children: buttonRenderArgs => React.element=?,
    ) => React.element = "Button"
  }
}
type dropdownPosition = Left | Right | Top

type value = String(string) | Array(array<string>)
module SelectBoxHeadlessUI = {
  @react.component
  let make = (
    ~value: value=String(""),
    ~setValue,
    ~options: array<SelectBox.dropdownOption>,
    ~children,
    ~dropdownPosition=Left,
    ~className="",
    ~deSelectAllowed=true,
    ~dropdownWidth="w-52",
  ) => {
    let transformedOptions = SelectBox.useTransformed(options)
    let dropdownPositionClass = switch dropdownPosition {
    | Left => "right-0"
    | Right => "left-0"
    | Top => "bottom-12"
    }
    let isMultiSelect = switch value {
    | String(_) => false
    | Array(_) => true
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
              <Menu.Items
                className={`absolute z-10 ${dropdownPositionClass} ${dropdownWidth} max-h-[225px] overflow-auto mt-2 p-1 origin-top-right bg-white dark:bg-jp-gray-950 rounded-md shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none`}>
                {props =>
                  transformedOptions
                  ->Array.mapWithIndex((option, index) => {
                    let selected = switch value {
                    | String(v) => v === option.value
                    | Array(arr) => arr->Array.includes(option.value)
                    }

                    <Menu.Item key={index->Js.Int.toString}>
                      {props =>
                        <div
                          onClick={ev => {
                            if isMultiSelect {
                              ev->ReactEvent.Mouse.stopPropagation
                              ev->ReactEvent.Mouse.preventDefault
                            }
                            setValue(option.value)
                          }}
                          className={`group flex flex-row items-center justify-between rounded-md w-full p-2 text-sm cursor-pointer ${props["active"]
                              ? "bg-gray-100 dark:bg-gray-700"
                              : ""}`}>
                          <div className="flex flex-row items-center gap-2">
                            {switch option.icon {
                            | FontAwesome(iconName) =>
                              <Icon className="align-middle" size=12 name=iconName />
                            | CustomIcon(element) => element

                            | Euler(iconName) =>
                              <Icon className="align-middle" size=12 name=iconName />
                            | _ => React.null
                            }}
                            <span className={selected ? "text-blue-800 font-semibold" : ""}>
                              {React.string(option.label)}
                            </span>
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
            </Transition>
          </div>}
      </Menu>
    </div>
  }
}
