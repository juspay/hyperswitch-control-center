type ompListTypes = {id: string, name: string}

type opmView = {
  lable: string,
  entity: UserInfoTypes.entity,
}
type ompViews = array<opmView>

type ompList = {
  orgList: array<ompListTypes>,
  merchantList: array<ompListTypes>,
  profileList: array<ompListTypes>,
}
