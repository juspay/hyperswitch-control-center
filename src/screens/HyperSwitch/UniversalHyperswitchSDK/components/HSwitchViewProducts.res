@react.component
let make = (~shirtQuantity, ~setShirtQuantity, ~capQuantity, ~setCapQuantity) => {
  let isDesktop = HSwitchSDKUtils.getIsDesktop(
    Recoil.useRecoilValueFromAtom(HSwitchRecoilAtoms.size),
  )
  let themeColors = HSwitchSDKUtils.getThemeColorsFromTheme(
    Recoil.useRecoilValueFromAtom(HSwitchRecoilAtoms.theme),
  )

  let totalAmount = HSwitchSDKUtils.getTotalAmount(~shirtQuantity, ~capQuantity)
  let taxAmount = HSwitchSDKUtils.getTaxAmount(~shirtQuantity, ~capQuantity)
  let amountToDisplay = HSwitchSDKUtils.amountToDisplay(~shirtQuantity, ~capQuantity)

  let dividerElement = <div className={`w-full h-[1px] mt-4 ${themeColors.productDividerClass}`} />

  <div className={isDesktop ? "" : "flex justify-center flex-col"}>
    <HSwitchProduct
      productImg="assets/hyperswitchSDK/shirt.png"
      productTitle="HS Tshirt"
      productAmount=65.00
      productQuantity=shirtQuantity
      setProductQuantity=setShirtQuantity
    />
    <HSwitchProduct
      productImg="assets/hyperswitchSDK/cap.png"
      productTitle="HS Cap"
      productAmount=32.00
      productQuantity=capQuantity
      setProductQuantity=setCapQuantity
    />
    {dividerElement}
    <div className="flex justify-between mt-4 text-sm">
      <div> {React.string("Subtotal")} </div>
      <div> {React.string(`US$ ${totalAmount}`)} </div>
    </div>
    <div className="flex justify-between mt-2 text-sm">
      <div> {React.string("Tax")} </div>
      <div> {React.string(`US$ ${taxAmount}`)} </div>
    </div>
    <div className="flex justify-between mt-2 text-sm">
      <div> {React.string("Shipping")} </div>
      <div> {React.string(`Free`)} </div>
    </div>
    {dividerElement}
    <div className="flex justify-between mt-4 text-sm font-medium">
      <div> {React.string("Total")} </div>
      <div> {React.string(`US$ ${amountToDisplay}`)} </div>
    </div>
  </div>
}
