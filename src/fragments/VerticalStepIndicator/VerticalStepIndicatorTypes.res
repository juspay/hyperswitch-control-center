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

let getSectionFromStep = (sections: array<section>, step: step): option<section> => {
  sections->Array.find(section => section.id === step.sectionId)
}

let getSubSectionFromStep = (sections: array<section>, step: step): option<subSection> => {
  sections
  ->Array.find(section => section.id === step.sectionId)
  ->Option.flatMap(section => {
    section.subSections->Option.flatMap(subSections => {
      switch step.subSectionId {
      | None => None
      | Some(subSectionId) => subSections->Array.find(subSection => subSection.id === subSectionId)
      }
    })
  })
}

let findSectionIndex = (sections: array<section>, sectionId: string): int => {
  sections->Array.findIndex(section => section.id === sectionId)
}

let findSubSectionIndex = (subSections: array<subSection>, subSectionId: string): int => {
  subSections->Array.findIndex(subSection => subSection.id === subSectionId)
}
