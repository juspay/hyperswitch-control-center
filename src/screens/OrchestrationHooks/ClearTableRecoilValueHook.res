let useClearTableRecoilValue = () => {
  open TableAtoms

  let setOrdersMapDefaultCols = ordersMapDefaultCols->Recoil.useSetRecoilState
  let clearTableRecoilValue = () => {
    setOrdersMapDefaultCols(_ => OrderEntity.defaultColumns)
  }
  clearTableRecoilValue
}
