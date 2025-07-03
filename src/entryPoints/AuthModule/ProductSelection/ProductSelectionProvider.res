open ProductSelectionState
open ProductTypes

module ModalBody = {
  @react.component
  let make = (~action, ~setShowModal, ~selectedProduct, ~setActiveProductValue) => {
    switch action {
    | CreateNewMerchant =>
      <ProductSelectionProviderHelper.CreateNewMerchantBody
        setShowModal selectedProduct setActiveProductValue
      />
    | SwitchToMerchant(merchantDetails) =>
      <ProductSelectionProviderHelper.SwitchMerchantBody
        merchantDetails setShowModal selectedProduct setActiveProductValue
      />
    | SelectMerchantToSwitch(merchantDetails) =>
      <ProductSelectionProviderHelper.SelectMerchantBody
        setShowModal merchantList={merchantDetails} selectedProduct setActiveProductValue
      />
    }
  }
}

module ProductExistModal = {
  @react.component
  let make = (~showModal, ~setShowModal, ~action, ~selectedProduct, ~setActiveProductValue) => {
    <Modal
      showModal
      closeOnOutsideClick=false
      setShowModal
      childClass="p-0"
      borderBottom=true
      modalClass="w-full !max-w-lg mx-auto my-auto dark:!bg-jp-gray-lightgray_background">
      <ModalBody setShowModal action selectedProduct setActiveProductValue />
    </Modal>
  }
}

open SessionStorage
let currentProductValue =
  sessionStorage.getItem("product")
  ->Nullable.toOption
  ->Option.getOr("orchestration")

let defaultContext = React.createContext(
  defaultValueOfProductProvider(~currentProductValue, ~version=V1),
)

module Provider = {
  let make = React.Context.provider(defaultContext)
}

@react.component
let make = (~children) => {
  let merchantList: array<OMPSwitchTypes.ompListTypes> = Recoil.useRecoilValueFromAtom(
    HyperswitchAtom.merchantListAtom,
  )
  let {userInfo: {version}} = React.useContext(UserInfoProvider.defaultContext)
  let (activeProduct, setActiveProduct) = React.useState(_ =>
    currentProductValue->ProductUtils.getProductVariantFromString(~version)
  )
  let (action, setAction) = React.useState(_ => None)
  let (showModal, setShowModal) = React.useState(_ => false)
  let (selectedProduct, setSelectedProduct) = React.useState(_ => None)

  let setCreateNewMerchant = product => {
    setShowModal(_ => true)
    setAction(_ => Some(CreateNewMerchant))
    setSelectedProduct(_ => Some(product))
  }

  let setSwitchToMerchant = (merchantDetails, product) => {
    setShowModal(_ => true)
    setAction(_ => Some(SwitchToMerchant(merchantDetails)))
    setSelectedProduct(_ => Some(product))
  }

  let setSelectMerchantToSwitch = merchantList => {
    setShowModal(_ => true)
    setAction(_ => Some(SelectMerchantToSwitch(merchantList)))
  }

  let onProductSelectClick = product => {
    let productVariant = product->ProductUtils.getProductVariantFromDisplayName
    setSelectedProduct(_ => Some(product->ProductUtils.getProductVariantFromDisplayName))

    let midsWithProductValue = merchantList->Array.filter(mid => {
      mid.productType->Option.mapOr(false, productVaule => {
        switch (productVaule, productVariant) {
        | (Orchestration(v1), Orchestration(v2)) => v1 == v2
        | (produceValue, productVariant) => produceValue == productVariant ? true : false
        }
      })
    })

    if midsWithProductValue->Array.length == 0 {
      setCreateNewMerchant(productVariant)
    } else if midsWithProductValue->Array.length == 1 {
      let merchantIdToSwitch =
        midsWithProductValue
        ->Array.get(0)
        ->Option.getOr({
          name: "",
          id: "",
          productType: Orchestration(V1),
        })

      setSwitchToMerchant(merchantIdToSwitch, productVariant)
    } else if midsWithProductValue->Array.length > 1 {
      setSelectMerchantToSwitch(midsWithProductValue)
    } else {
      setAction(_ => None)
    }
  }
  let setActiveProductValue = product => {
    setActiveProduct(_ => product)
  }

  let merchantHandle = React.useMemo(() => {
    switch action {
    | Some(actionVariant) =>
      <ProductExistModal
        showModal
        setShowModal
        action={actionVariant}
        selectedProduct={selectedProduct->Option.getOr(Vault)}
        setActiveProductValue
      />
    | None => React.null
    }
  }, (action, showModal))

  <Provider
    value={
      setCreateNewMerchant,
      setSwitchToMerchant,
      setSelectMerchantToSwitch,
      onProductSelectClick,
      activeProduct,
      setActiveProductValue,
    }>
    children
    {merchantHandle}
  </Provider>
}
