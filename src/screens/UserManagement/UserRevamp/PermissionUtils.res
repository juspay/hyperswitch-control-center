open CommonAuthTypes

let linkForGetShowLinkViaAccess = (~permission, ~url) => {
  permission === Access ? url : ``
}

let cursorStyles = permission => permission === Access ? "cursor-pointer" : "cursor-not-allowed"
