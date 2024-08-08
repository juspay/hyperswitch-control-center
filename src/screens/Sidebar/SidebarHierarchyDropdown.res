@react.component
let make = (
  ~title: string,
  ~user: string,
  ~leftIcon: Button.iconType,
  ~customIconStyle="",
  ~heading="",
  ~headingClass="text-blue-700 text-sm px-4 py-2",
  ~listUsers: array<string>,
) => {
  open HeadlessUI

  let (arrow, setArrow) = React.useState(_ => false)
  let icon = switch leftIcon {
  | FontAwesome(iconName) =>
    <Icon className={`align-middle ${customIconStyle}`} size=14 name=iconName />
  | CustomIcon(element) => element
  | Euler(iconName) => <Icon className="align-middle" size=12 name=iconName />
  | _ => React.null
  }

  <>
    <div className="flex flex-col items-end gap-2 mx-4 my-2 mb-4">
      <Menu \"as"="div" className=" relative inline-block text-left w-full rounded">
        {_menuProps =>
          <div>
            <Menu.Button
              className="flex items-center justify-between whitespace-pre text-sm  text-center font-medium rounded hover:bg-opacity-80 bg-popover-background text-white w-full ring-1  ring-blue-800 ring-opacity-15">
              {_buttonProps => {
                <>
                  {icon}
                  <div className="flex flex-col items-start px-2 py-2 ">
                    <p className="text-xs text-gray-400"> {title->React.string} </p>
                    <p className="fs-10"> {user->React.string} </p>
                  </div>
                  <div className="px-2 py-2">
                    <Icon
                      className={arrow
                        ? `-rotate-180 transition duration-[250ms] opacity-70`
                        : `rotate-0 transition duration-[250ms] opacity-70`}
                      name="arrow-without-tail-new"
                      size=15
                    />
                  </div>
                </>
              }}
            </Menu.Button>
            <Transition
              \"as"="span"
              enter="transition ease-out duration-100"
              enterFrom="transform opacity-0 scale-95"
              enterTo="transform opacity-100 scale-100"
              leave="transition ease-in duration-75"
              leaveFrom="transform opacity-100 scale-100"
              leaveTo="transform opacity-0 scale-95">
              {<Menu.Items
                className="absolute right-0 z-50 w-full mt-2 origin-top-right bg-popover-background text-white dark:bg-jp-gray-950 rounded-md shadow-lg focus:outline-none ring-1  ring-blue-800 ring-opacity-15">
                {props => {
                  if props["open"] {
                    setArrow(_ => true)
                  } else {
                    setArrow(_ => false)
                  }
                  <>
                    <div className="px-1 py-1">
                      <p className=headingClass> {heading->React.string} </p>
                      {listUsers
                      ->Array.mapWithIndex((user, i) =>
                        <Menu.Item key={i->Int.toString}>
                          {props =>
                            <div className="relative">
                              <button
                                className={
                                  let activeClasses = if props["active"] {
                                    "group flex rounded-md items-center w-full px-4 py-2 text-sm bg-gray-100 dark:bg-black hover:bg-[#495d8a]"
                                  } else {
                                    "group flex rounded-md items-center w-full px-4 py-2 text-sm"
                                  }
                                  `${activeClasses} font-medium text-start`
                                }>
                                <div className="mr-5"> {user->React.string} </div>
                              </button>
                              <RenderIf condition={user === "user1"}>
                                <Icon
                                  className={`absolute top-2 right-2 text-white`}
                                  name="check"
                                  size=15
                                />
                              </RenderIf>
                            </div>}
                        </Menu.Item>
                      )
                      ->React.array}
                    </div>
                  </>
                }}
              </Menu.Items>}
            </Transition>
          </div>}
      </Menu>
    </div>
  </>
}
