open AuditTrailStepIndicatorTypes

let getSectionById = (sections: array<section>, sectionId) =>
  sections->Array.find(section => section.id === sectionId)

let findSectionIndex = (sections: array<section>, sectionId: string): int => {
  sections->Array.findIndex(section => section.id === sectionId)
}
