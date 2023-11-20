@react.component
let make = (~children) => {
  <div className={"flex flex-row flex-wrap items-center"}>
    {children->React.Children.map(element => {
      <span className="pl-6 mobile:py-2"> element </span>
    })}
  </div>
}
