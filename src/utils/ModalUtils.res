let getHeaderTextClass = _ => "text-2xl font-semibold"

let getAnimationClass = showModal =>
  switch showModal {
  | true => "animate-slideUp animate-fadeIn"
  | _ => ""
  }

let getCloseIcon = onClick => {
  <div className="-mt-2 -mr-1" onClick>
    <Icon name="close" className="border-2 p-2  rounded-2xl bg-gray-100 cursor-pointer" size=30 />
  </div>
}
