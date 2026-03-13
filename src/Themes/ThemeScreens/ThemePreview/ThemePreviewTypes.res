type sidebarConfig = {
  primary: string,
  textColor: string,
  textColorPrimary: string,
}

type sidebarItem = {
  label: string,
  active: bool,
}

type mockValues = {
  orgs: array<string>,
  merchantName: string,
  userEmail: string,
  profileName: string,
  pageHeading: string,
  pageDescription: string,
  cardHeading: string,
  cardDescription: string,
  primaryButtonText: string,
  secondaryButtonText: string,
}

let mockValues: mockValues = {
  orgs: ["S", "A"],
  merchantName: "Merchant Name",
  userEmail: "user@example.com",
  profileName: "Profile Name",
  pageHeading: "Page Heading",
  pageDescription: "This is where the page description will go.",
  cardHeading: "Card Heading",
  cardDescription: "This is where the card description will go.",
  primaryButtonText: "Primary Button",
  secondaryButtonText: "Secondary Button",
}
