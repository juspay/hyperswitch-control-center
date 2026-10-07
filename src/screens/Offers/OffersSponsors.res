open OffersTypes

let allSponsors = [
  Merchant,
  Citi,
  Cred,
  Diners,
  Maestro,
  Mastercard,
  Rupay,
  Sodexo,
  Visa,
  AmericanExpress,
  Discover,
  Jcb,
  IciciBank,
  Sbi,
  PhonePe,
  GooglePay,
  AmazonPay,
  Paytm,
]

let sponsorFromString = sponsor =>
  allSponsors
  ->Array.find(knownSponsor => (knownSponsor :> string) == sponsor)
  ->Option.getOr(UnknownSponsor(sponsor))

let sponsorToDisplayName = sponsor =>
  switch sponsor {
  | Merchant => "Merchant"
  | Citi => "Citi"
  | Cred => "Cred"
  | Diners => "Diners"
  | Maestro => "Maestro"
  | Mastercard => "Mastercard"
  | Rupay => "Rupay"
  | Sodexo => "Sodexo"
  | Visa => "Visa"
  | AmericanExpress => "American Express"
  | Discover => "Discover"
  | Jcb => "JCB"
  | IciciBank => "ICICI Bank"
  | Sbi => "SBI"
  | PhonePe => "PhonePe"
  | GooglePay => "Google Pay"
  | AmazonPay => "Amazon Pay"
  | Paytm => "Paytm"
  | UnknownSponsor(other) => other->LogicUtils.snakeToTitle
  }

let sponsorOptions = allSponsors->Array.map((sponsor): SelectBox.dropdownOption => {
  label: sponsor->sponsorToDisplayName,
  value: (sponsor :> string),
})
