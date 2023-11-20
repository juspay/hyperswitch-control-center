@module("react-dom/server")
external renderToStaticMarkup: React.element => string = "renderToStaticMarkup"

let getPaymentFormStr = () => {
  renderToStaticMarkup(<div />)
}

let getRedirectPage = () => {
  renderToStaticMarkup(<div />)
}

let getMetatagsStr = () => {
  renderToStaticMarkup(<div />)
}
