open HSwitchRecoilAtoms

@react.component
let make = (~tabName: HSwitchFilterData.tabName) => {
  let (isShowFilterDropdown, setIsShowFilterDropdown) = React.useState(_ => false)
  let isMobileScreen = Recoil.useRecoilValueFromAtom(HSwitchRecoilAtoms.isMobileScreen)

  let list = switch tabName {
  | CustomerLocation => HSwitchFilterData.customerLocations
  | Size => HSwitchFilterData.sizes
  | Theme => HSwitchFilterData.themes
  | Layout => HSwitchFilterData.layouts
  }

  let (selectedValue, setSelectedValue) = switch tabName {
  | CustomerLocation => Recoil.useRecoilState(customerLocation)
  | Size => Recoil.useRecoilState(size)
  | Theme => Recoil.useRecoilState(theme)
  | Layout => Recoil.useRecoilState(layout)
  }

  let showExtra = switch tabName {
  | CustomerLocation
  | Theme => true
  | _ => false
  }

  let extraTitle = switch tabName {
  | CustomerLocation => HSwitchSDKUtils.customerLocationExtraTitle
  | Theme => HSwitchSDKUtils.themeExtraTitle
  | _ => ""
  }

  let extraDesc = switch tabName {
  | CustomerLocation => HSwitchSDKUtils.customerLocationExtraDesc
  | Theme => HSwitchSDKUtils.themeExtraDesc
  | _ => ""
  }

  let extraWidth = switch tabName {
  | CustomerLocation => "250px"
  | Theme => "185px"
  | _ => "185px"
  }

  let isShowFlag = tabName === CustomerLocation
  let isSize = tabName === Size

  let iconName =
    selectedValue->HSwitchSDKUtils.getCountryFromCustomerLocation->Js.String2.toLowerCase

  let tabNameString = tabName->HSwitchFilterData.getStringFromTabName
  let filterId = `filter-btn-${tabNameString->Js.String2.replace(" ", "_")}`

  React.useLayoutEffect0(() => {
    Window.addEventListener("click", ev => {
      let targetId = ReactEvent.Mouse.target(ev)["id"]
      if targetId !== filterId && targetId !== filterId->Js.String2.concat("-arrow") {
        setIsShowFilterDropdown(_ => false)
      }
    })
    Some(
      () => {
        Window.removeEventListener("click", ev => {
          let targetId = ReactEvent.Mouse.target(ev)["id"]
          if targetId !== filterId && targetId !== filterId->Js.String2.concat("-arrow") {
            setIsShowFilterDropdown(_ => false)
          }
        })
      },
    )
  })

  <div
    className="flex relative text-[rgb(65,69,82)] text-sm border-solid border-[rgba(60,66,87,0.12)] border-[1px] rounded px-2 py-2">
    <div className="text-[rgb(105,115,134)]">
      {React.string(tabName->HSwitchFilterData.getStringFromTabName)}
    </div>
    <div className="mx-1 text-[rgb(105,115,134)] font-normal text-sm"> {React.string("|")} </div>
    <div
      id=filterId
      className="ml-1 text-[rgb(84,105,212)] flex items-center font-medium cursor-pointer hover:text-[rgb(26,31,54)]"
      onClick={_ => setIsShowFilterDropdown(_ => true)}>
      <UIUtils.RenderIf condition={isShowFlag}>
        <Icon size=16 name={`${iconName}-flag`} className="mr-1" />
      </UIUtils.RenderIf>
      <UIUtils.RenderIf condition={isSize}>
        <Icon size=16 name={`${selectedValue->Js.String2.toLowerCase}-hs`} className="mr-1" />
      </UIUtils.RenderIf>
      {React.string(selectedValue)}
      <Icon
        id={filterId->Js.String2.concat("-arrow")}
        name="arrow-down-hs"
        size=9
        className="ml-1 text-[#5d5d5d]"
      />
    </div>
    <UIUtils.RenderIf condition={isShowFilterDropdown}>
      <HSwitchFilterDropdown
        list selectedValue setSelectedValue showExtra extraTitle extraDesc extraWidth isShowFlag
      />
    </UIUtils.RenderIf>
  </div>
}
