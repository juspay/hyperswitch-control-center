let getHeaderTextClass = _ => "text-2xl font-semibold"

let getAnimationClass = showModal =>
  switch showModal {
  | true => "animate-slideUp animate-fadeIn"
  | _ => ""
  }

let getCloseIcon = onClick => {
  <Icon name="modal-close-icon" className="cursor-pointer" size=30 onClick />
}
