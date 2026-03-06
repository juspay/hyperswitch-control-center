module LocalStorage = {
  let setEmbeddedTokenToStorage = tokenStringFromParent => {
    LocalStorage.setItem("EMBEDDABLE_INFO", tokenStringFromParent)
  }

  let getEmbeddedTokenFromStorage = () => {
    open LogicUtils
    LocalStorage.getItem("EMBEDDABLE_INFO")->getValFromNullableValue("")
  }
}
