open VerticalStepIndicatorTypes

let getSectionById = (sections: array<section>, sectionId) =>
  sections->Array.find(section => section.id === sectionId)

let getSubSectionById = (subSections, subSectionId) =>
  subSections->Array.find(subSection => subSection.id === subSectionId)

let createStep = (sectionId, subSectionId) => {sectionId, subSectionId}

let getFirstSubSection = subSections => subSections->Array.get(0)
let getLastSubSection = subSections => subSections->Array.get(subSections->Array.length - 1)

let findNextStep = (sections: array<section>, currentStep: step): option<step> => {
  let currentSection = sections->getSectionById(currentStep.sectionId)->Option.getExn
  let currentSectionIndex =
    sections->Array.findIndex(section => section.id === currentStep.sectionId)

  switch (currentSection.subSections, currentStep.subSectionId) {
  | (None, _) =>
    sections
    ->Array.get(currentSectionIndex + 1)
    ->Option.map(nextSection => {
      let firstSubSection = nextSection.subSections->Option.flatMap(getFirstSubSection)
      createStep(nextSection.id, firstSubSection->Option.map(sub => sub.id))
    })

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
  | (_, None) => None
  }
}

let findPreviousStep = (sections: array<section>, currentStep: step): option<step> => {
  let currentSection = sections->getSectionById(currentStep.sectionId)->Option.getExn
  let currentSectionIndex =
    sections->Array.findIndex(section => section.id === currentStep.sectionId)

  switch (currentSection.subSections, currentStep.subSectionId) {
  | (None, _) =>
    sections
    ->Array.get(currentSectionIndex - 1)
    ->Option.map(prevSection => {
      let lastSubSection = prevSection.subSections->Option.flatMap(getLastSubSection)
      createStep(prevSection.id, lastSubSection->Option.map(sub => sub.id))
    })

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
