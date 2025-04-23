@react.component
let make = (~fill="#7c7d82", ~onClick) => {
  <AddDataAttributes attributes=[("data-component", `modalCloseIcon`)]>
    <div className="" onClick>
      <Icon name="close" className="border-2 p-2 rounded-2xl bg-gray-100 cursor-pointer" size=30 />
    </div>
  </AddDataAttributes>
}
