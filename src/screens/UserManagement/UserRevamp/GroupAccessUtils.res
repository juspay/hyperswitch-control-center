open CommonAuthTypes

let linkForGetShowLinkViaAccess = (~authorization, ~url) => {
  authorization === Access ? url : ``
}

let cursorStyles = authorization =>
  authorization === Access ? "cursor-pointer" : "cursor-not-allowed"
