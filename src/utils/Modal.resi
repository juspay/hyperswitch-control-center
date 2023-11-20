type modalData = {heading: string, content: React.element}
module ModalHeading: {
  @react.component
  let make: (
    ~headingClass: string,
    ~headerTextClass: string,
    ~headerAlignmentClass: string,
    ~modalHeading: string,
    ~showCloseIcon: bool,
    ~showCloseOnLeft: bool,
    ~showBackIcon: bool,
    ~leftHeadingIcon: option<React.element>,
    ~rightHeading: option<React.element>,
    ~onCloseClick: JsxEvent.Mouse.t => unit,
    ~onBackClick: ReactEvent.Mouse.t => unit,
    ~modalHeadingDescription: string,
    ~modalSubInfo: string,
    ~showBorderBottom: bool,
    ~centerHeading: bool=?,
    ~headBgClass: string,
    ~modalHeadingDescriptionElement: React.element,
    ~showModalHeadingIconName: string,
    ~modalHeadingClass: string,
    ~modalParentHeadingClass: string,
    ~customIcon: option<React.element>,
  ) => React.element
}
module ModalContent: {
  @react.component
  let make: (
    ~handleContainerClick: JsxEvent.Mouse.t => unit,
    ~bgClass: string,
    ~modalClass: string,
    ~children: React.element,
    ~customHeight: string=?,
  ) => React.element
}
module ModalOverlay: {
  @react.component
  let make: (
    ~handleOverlayClick: JsxEvent.Mouse.t => unit,
    ~showModal: bool,
    ~children: React.element,
    ~paddingClass: string,
    ~modalHeading: option<string>,
    ~overlayBG: string,
    ~modalPosition: string=?,
    ~noBackDrop: bool=?,
    ~isBackdropBlurReq: bool=?,
    ~addAttributeId: string=?,
    ~alignModal: string,
  ) => React.element
}
@react.component
let make: (
  ~showModal: bool,
  ~setShowModal: (bool => bool) => unit,
  ~children: React.element,
  ~modalHeading: string=?,
  ~customModalHeading: React.element=?,
  ~bgClass: string=?,
  ~modalClass: string=?,
  ~childClass: string=?,
  ~headingClass: string=?,
  ~paddingClass: string=?,
  ~centerHeading: bool=?,
  ~modalHeadingDescription: string=?,
  ~modalSubInfo: string=?,
  ~closeOnOutsideClick: bool=?,
  ~headerTextClass: string=?,
  ~borderBottom: bool=?,
  ~showCloseIcon: bool=?,
  ~showCloseOnLeft: bool=?,
  ~showBackIcon: bool=?,
  ~leftHeadingIcon: React.element=?,
  ~rightHeading: React.element=?,
  ~onBackClick: unit => unit=?,
  ~headBgClass: string=?,
  ~revealFrom: Reveal.postion=?,
  ~modalHeadingDescriptionElement: React.element=?,
  ~onCloseClickCustomFun: unit => unit=?,
  ~modalFooter: React.element=?,
  ~overlayBG: string=?,
  ~showModalHeadingIconName: string=?,
  ~customHeight: string=?,
  ~modalHeadingClass: string=?,
  ~modalPosition: string=?,
  ~modalParentHeadingClass: string=?,
  ~headerAlignmentClass: string=?,
  ~noBackDrop: bool=?,
  ~isBackdropBlurReq: bool=?,
  ~addAttributeId: string=?,
  ~customIcon: option<React.element>=?,
  ~alignModal: string=?,
) => React.element
