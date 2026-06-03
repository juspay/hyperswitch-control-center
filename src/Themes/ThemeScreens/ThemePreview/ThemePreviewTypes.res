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
  emailLogoPlaceholder: string,
  emailGreeting: string,
  emailLinkExpireText: string => string,
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
  emailLogoPlaceholder: "Your Logo Here",
  emailGreeting: "Dear User, we are thrilled to welcome you into our community!",
  emailLinkExpireText: name =>
    `This link provides instant access to ${name} account. It will expire in 24 hours and can only be used once.`,
}
