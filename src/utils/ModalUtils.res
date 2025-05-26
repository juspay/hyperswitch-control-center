let getHeaderTextClass = _ => "text-lg font-semibold leading-6"

let getAnimationClass = showModal =>
  switch showModal {
  | true => "animate-slideUp animate-fadeIn"
  | _ => ""
  }

let getCloseIcon = onClick => {
  <Icon name="modal-close-icon" className="cursor-pointer text-nd_gray-600" size=28 onClick />
}
