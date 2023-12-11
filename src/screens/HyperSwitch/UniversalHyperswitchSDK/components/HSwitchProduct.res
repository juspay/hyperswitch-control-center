@react.component
let make = (~productImg, ~productTitle, ~productAmount, ~productQuantity, ~setProductQuantity) => {
  let setIsGlobalModalOpen = Recoil.useSetRecoilState(HSwitchRecoilAtoms.isModalOpen)
  let (isModalOpen, setIsModalOpen) = React.useState(_ => false)

  let theme = Recoil.useRecoilValueFromAtom(HSwitchRecoilAtoms.theme)
  let themeColors = HSwitchSDKUtils.getThemeColorsFromTheme(theme)

  let handleModalOpen = () => {
    setIsModalOpen(_ => true)
    setIsGlobalModalOpen(._ => true)
  }

  <div className="mb-4 flex">
    <img className="rounded-[4px] h-[40px] w-[40px] mr-4" src={productImg} />
    <div className="flex flex-col w-full items-baseline">
      <div className="flex justify-between w-full">
        <div className="text-sm"> {React.string(productTitle)} </div>
        <div className="text-sm">
          {React.string(
            `US$ ${(productAmount *. productQuantity->Belt.Int.toFloat)
                ->Js.Float.toFixedWithPrecision(~digits=2)}`,
          )}
        </div>
      </div>
      <div className="flex justify-between w-full">
        <div
          className={`text-xs p-[0.2rem] rounded-[4px] flex items-end cursor-pointer ${themeColors.backgroundSecondaryClass}`}
          onClick={_ => handleModalOpen()}>
          <div> {React.string(`Qty ${productQuantity->Belt.Int.toString}`)} </div>
          <Icon
            name="arrow-down-hs"
            size=8
            className={`ml-[4px] mb-[0.2rem] mr-[0.1rem] text-sm text-[${themeColors.textSecondaryColor}]`}
          />
        </div>
        <UIUtils.RenderIf condition={productQuantity > 1}>
          <div
            className="text-xs mt-[0.3rem]"
            style={ReactDOMStyle.make(~color=themeColors.textSecondaryColor, ())}>
            {React.string(`US $${productAmount->Js.Float.toFixedWithPrecision(~digits=2)} each`)}
          </div>
        </UIUtils.RenderIf>
      </div>
    </div>
    <HSwitchModal isModalOpen setIsModalOpen>
      <HSwitchUpdateProductQuantity setIsModalOpen productQuantity setProductQuantity />
    </HSwitchModal>
  </div>
}
