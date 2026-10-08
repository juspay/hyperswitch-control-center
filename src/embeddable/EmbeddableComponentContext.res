type displayOptions = {
  showPageHeading: bool,
  showColumnCustomisation: bool,
  fullPageModals: bool,
}

let dashboardDisplayOptions = {
  showPageHeading: true,
  showColumnCustomisation: true,
  fullPageModals: false,
}

let embeddableDisplayOptions = {
  showPageHeading: false,
  showColumnCustomisation: false,
  fullPageModals: true,
}

let embeddableComponentContext = React.createContext(dashboardDisplayOptions)

module Provider = {
  let make = React.Context.provider(embeddableComponentContext)
}

let useDisplayOptions = () => React.useContext(embeddableComponentContext)

let modalRootId = "embeddable-modal-root"

let getModalRoot = () => Webapi.Dom.document->Webapi.Dom.Document.querySelector(`#${modalRootId}`)

let isModalRootEmpty = modalRoot => modalRoot->Webapi.Dom.Element.childElementCount === 0

let hasOtherModals = modalRoot => modalRoot->Webapi.Dom.Element.childElementCount > 1
