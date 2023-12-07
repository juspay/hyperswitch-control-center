@react.component
let make = (~setIsModalOpen, ~productQuantity, ~setProductQuantity) => {
  let setIsGlobalModalOpen = Recoil.useSetRecoilState(HSwitchRecoilAtoms.isModalOpen)
  let (quantity, setQuantity) = React.useState(_ => productQuantity)
  let themeColors = HSwitchSDKUtils.getThemeColorsFromTheme(
    Recoil.useRecoilValueFromAtom(HSwitchRecoilAtoms.theme),
  )

  let handleClose = () => {
    setIsModalOpen(_ => false)
    setIsGlobalModalOpen(._ => false)
  }

  let handleDec = () => {
    if quantity > 1 {
      setQuantity(prev => prev - 1)
    }
  }

  let handleInc = () => {
    if quantity < 10 {
      setQuantity(prev => prev + 1)
    }
  }

  let handleChange = ev => {
    let val = ReactEvent.Form.target(ev)["value"]
    switch val->Belt.Int.fromString {
    | Some(num) =>
      if num > 0 && num <= 99 {
        setQuantity(_ => num)
      }
    | None => ()
    }
  }

  let handleUpdate = () => {
    setProductQuantity(_ => quantity)
    handleClose()
  }

  let counterBtnClass = "text-sm font-normal mx-[15px] p-[10px] rounded-[20px] text-center w-8 h-8 flex items-center justify-center cursor-pointer"

  <>
    <div
      className={`flex justify-between items-center w-full py-4 px-5 box-border border-b border-solid ${themeColors.productBorderClass}`}>
      <div className="flex items-center">
        <img className="rounded h-8 mr-4" src="assets/hyperswitchSDK/shirt.png" />
        <div className="flex flex-col items-baseline">
          <div
            className="text-sm font-medium"
            style={ReactDOMStyle.make(~color=themeColors.hyperswitchHeaderColor, ())}>
            {React.string("Update Quantity")}
          </div>
          <div
            className="text-xs font-normal"
            style={ReactDOMStyle.make(~color=themeColors.textSecondaryColor, ())}>
            {React.string("The Pure Set")}
          </div>
        </div>
      </div>
      <Icon name="cross-hs" size=28 className="cursor-pointer" onClick={_ => handleClose()} />
    </div>
    <div className="flex justify-center items-center pt-6 px-5 pb-4 w-[23%]">
      <button
        className={`${counterBtnClass} ${quantity <= 1
            ? "opacity-50 cursor-default"
            : ""} ${themeColors.counterButtonClass}`}
        onClick={_ => handleDec()}>
        <Icon name="minus" size=12 />
      </button>
      <input
        className={`text-center w-[92px] rounded-md py-2 px-3 text-base font-normal h-11 text-[rgba(26,26,26,0.9)] box-border outline-none ${themeColors.inputClass}`}
        type_="tel"
        value={quantity->Belt.Int.toString}
        onChange={handleChange}
      />
      <button
        className={`${counterBtnClass} ${quantity >= 10
            ? "opacity-50 cursor-default"
            : ""} ${themeColors.counterButtonClass}`}
        onClick={_ => handleInc()}>
        <Icon name="plus" size=12 />
      </button>
    </div>
    <button
      className={`box-border cursor-pointer text-sm text-center font-medium h-[38px] w-[308px] py-2 px-4 rounded-md my-4 ${themeColors.checkoutButtonClass}`}
      style={ReactDOMStyle.make(~color=themeColors.tabLabelColor, ())}
      onClick={_ => handleUpdate()}>
      {React.string("Update")}
    </button>
  </>
}
