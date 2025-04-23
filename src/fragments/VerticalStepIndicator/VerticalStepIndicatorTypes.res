type identifier = {id: string, name: string}

type rec section = {
  ...identifier,
  icon: string,
  subSections: option<array<subSection>>,
}
and subSection = {
  ...identifier,
}

type step = {
  sectionId: string,
  subSectionId: option<string>,
}
