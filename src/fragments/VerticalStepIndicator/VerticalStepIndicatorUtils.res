open VerticalStepIndicatorTypes

let default: section = {
  id: "",
  name: "",
  icon: "",
  subSections: None,
}

let getSectionById = (sections: array<section>, sectionId) =>
  sections->Array.find(section => section.id === sectionId)->Option.getOr(default)

let getSubSectionById = (subSections, subSectionId) =>
  subSections->Array.find(subSection => subSection.id === subSectionId)

let createStep = (sectionId, subSectionId) => {sectionId, subSectionId}

let getFirstSubSection = subSections => subSections->Array.get(0)
let getLastSubSection = subSections => subSections->Array.get(subSections->Array.length - 1)

let findNextStep = (sections: array<section>, currentStep: step): option<step> => {
  let currentSection = sections->getSectionById(currentStep.sectionId)
  let currentSectionIndex =
    sections->Array.findIndex(section => section.id === currentStep.sectionId)

  switch (currentSection.subSections, currentStep.subSectionId) {
  | (Some(subSections), Some(subSectionId)) => {
      let currentSubIndex = subSections->Array.findIndex(sub => sub.id === subSectionId)

      if currentSubIndex < subSections->Array.length - 1 {
        subSections
        ->Array.get(currentSubIndex + 1)
        ->Option.map(nextSub => createStep(currentStep.sectionId, Some(nextSub.id)))
      } else {
        sections
        ->Array.get(currentSectionIndex + 1)
        ->Option.map(nextSection => {
          let firstSubSection = nextSection.subSections->Option.flatMap(getFirstSubSection)
          createStep(nextSection.id, firstSubSection->Option.map(sub => sub.id))
        })
      }
    }
  | (None, _) =>
    sections
    ->Array.get(currentSectionIndex + 1)
    ->Option.map(nextSection => {
      let firstSubSection = nextSection.subSections->Option.flatMap(getFirstSubSection)
      createStep(nextSection.id, firstSubSection->Option.map(sub => sub.id))
    })
  | (_, None) => None
  }
}

let findPreviousStep = (sections: array<section>, currentStep: step): option<step> => {
  let currentSection = sections->getSectionById(currentStep.sectionId)
  let currentSectionIndex =
    sections->Array.findIndex(section => section.id === currentStep.sectionId)

  switch (currentSection.subSections, currentStep.subSectionId) {
  | (Some(subSections), Some(subSectionId)) => {
      let currentSubIndex = subSections->Array.findIndex(sub => sub.id === subSectionId)

      if currentSubIndex > 0 {
        subSections
        ->Array.get(currentSubIndex - 1)
        ->Option.map(prevSub => createStep(currentStep.sectionId, Some(prevSub.id)))
      } else {
        sections
        ->Array.get(currentSectionIndex - 1)
        ->Option.map(prevSection => {
          let lastSubSection = prevSection.subSections->Option.flatMap(getLastSubSection)
          createStep(prevSection.id, lastSubSection->Option.map(sub => sub.id))
        })
      }
    }
  | (None, _) =>
    sections
    ->Array.get(currentSectionIndex - 1)
    ->Option.map(prevSection => {
      let lastSubSection = prevSection.subSections->Option.flatMap(getLastSubSection)
      createStep(prevSection.id, lastSubSection->Option.map(sub => sub.id))
    })

  | (_, None) => None
  }
}

let isFirstStep = (sections: array<section>, step: step): bool => {
  sections
  ->Array.get(0)
  ->Option.flatMap(firstSection =>
    firstSection.subSections
    ->Option.flatMap(getFirstSubSection)
    ->Option.flatMap(firstSub =>
      step.subSectionId->Option.map(
        subId => step.sectionId === firstSection.id && subId === firstSub.id,
      )
    )
  )
  ->Option.getOr(false)
}

let isLastStep = (sections: array<section>, step: step): bool => {
  sections
  ->Array.get(sections->Array.length - 1)
  ->Option.flatMap(lastSection =>
    lastSection.subSections
    ->Option.flatMap(getLastSubSection)
    ->Option.flatMap(lastSub =>
      step.subSectionId->Option.map(
        subId => step.sectionId === lastSection.id && subId === lastSub.id,
      )
    )
  )
  ->Option.getOr(false)
}

let getSectionFromStep = (sections: array<section>, step: step): option<section> => {
  sections->Array.find(section => getSectionById(sections, step.sectionId) === section)
}

let getSubSectionFromStep = (sections: array<section>, step: step): option<subSection> => {
  sections
  ->Array.find(section => section.id === step.sectionId)
  ->Option.flatMap(section => {
    section.subSections->Option.flatMap(subSections => {
      switch step.subSectionId {
      | Some(subSectionId) => subSections->Array.find(subSection => subSection.id === subSectionId)
      | None => None
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
