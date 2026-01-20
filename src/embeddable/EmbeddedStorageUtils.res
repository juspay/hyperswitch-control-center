let setEmbeddedTokenToStorage = tokenStringFromParent => {
  LocalStorage.setItem("EMBEDDABLE_INFO", tokenStringFromParent)
}

let getEmbeddableInfoDetailsFromLocalStorage = () => {
  open LogicUtils
  LocalStorage.getItem("EMBEDDABLE_INFO")->getValFromNullableValue("")
}
