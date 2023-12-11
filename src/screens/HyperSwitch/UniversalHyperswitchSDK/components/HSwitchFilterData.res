type tabName = CustomerLocation | Size | Theme | Layout

let getStringFromTabName = name => {
  switch name {
  | CustomerLocation => "Customer Location"
  | Size => "Size"
  | Theme => "Theme"
  | Layout => "Layout"
  }
}

let customerLocations = [
  "United Arab Emirates (AED)",
  "Australia (AUD)",
  "Brazil (BRL)",
  "China (CNY)",
  "Germany (EUR)",
  "United Kingdom (GBP)",
  "Indonesia (IDR)",
  "Japan (JPY)",
  "Mexico (MXN)",
  "Malaysia (MYR)",
  "Poland (PLN)",
  "Singapore (SGD)",
  "Thailand (THB)",
  "United States (USD)",
]

let sizes = ["Desktop", "Mobile"]

let themes = ["Default", "Brutal", "Midnight", "Soft", "Charcoal"]

let layouts = ["Tabs", "Accordion", "Spaced Accordion"]
