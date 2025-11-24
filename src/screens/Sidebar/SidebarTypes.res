type optionType = {
  name: string,
  icon: string,
  link: string,
  access: CommonAuthTypes.authorization,
  searchOptions?: array<(string, string)>,
  remoteIcon?: bool,
  selectedIcon?: string,
}
type optionTypeWithTag = {
  name: string,
  icon: string,
  iconTag: string,
  iconStyles?: string,
  iconSize?: int,
  link: string,
  access: CommonAuthTypes.authorization,
  searchOptions?: array<(string, string)>,
}
type nestedOption = {
  name: string,
  link: string,
  access: CommonAuthTypes.authorization,
  searchOptions?: array<(string, string)>,
  remoteIcon?: bool,
  iconTag?: string,
  iconStyles?: string,
  iconSize?: int,
}

type subLevelItem = SubLevelLink(nestedOption)

type sectionType = {
  name: string,
  icon: string,
  links: array<subLevelItem>,
  showSection: bool,
  selectedIcon?: string,
}

type headingType = {
  name: string,
  icon?: string,
  iconTag?: string,
  iconStyles?: string,
  iconSize?: int,
}

type customComponentType = {component: React.element}

type topLevelItem =
  | CustomComponent(customComponentType)
  | Heading(headingType)
  | RemoteLink(optionType)
  | Link(optionType)
  | LinkWithTag(optionTypeWithTag)
  | Section(sectionType)

type productTypeSection = {
  name: string,
  links: array<topLevelItem>,
  icon: string,
  showSection: bool,
}

type urlRoute = Local(string) | Remote(string) | LocalSection(array<(string, string)>)
