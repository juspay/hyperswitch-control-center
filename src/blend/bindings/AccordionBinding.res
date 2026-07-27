module Value = {
  type t
  external fromString: string => t = "%identity"
  external fromArray: array<string> => t = "%identity"
  external toString: t => string = "%identity"
  external toArray: t => array<string> = "%identity"
}

type accordionType =
  | @as("border") Border
  | @as("noBorder") NoBorder

type accordionChevronPosition =
  | @as("left") Left
  | @as("right") Right

module Item = {
  @module("@juspay/blend-design-system") @react.component
  external make: (
    ~value: string,
    ~title: React.element,
    ~subtext: string=?,
    ~leftSlot: React.element=?,
    ~rightSlot: React.element=?,
    ~subtextSlot: React.element=?,
    ~children: React.element,
    ~isDisabled: bool=?,
    ~className: string=?,
    ~chevronPosition: accordionChevronPosition=?,
  ) => React.element = "AccordionItem"
}

@module("@juspay/blend-design-system") @react.component
external make: (
  ~children: React.element,
  ~accordionType: accordionType=?,
  ~defaultValue: Value.t=?,
  ~value: Value.t=?,
  ~isCollapsible: bool=?,
  ~isMultiple: bool=?,
  ~onValueChange: Value.t => unit=?,
  ~className: string=?,
) => React.element = "Accordion"
