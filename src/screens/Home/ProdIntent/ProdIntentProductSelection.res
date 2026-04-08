open ProductTypes

type productSelectionItem = {
  product: productTypes,
  name: string,
  icon: string,
  description: string,
}

let availableProducts = [
  {
    product: Orchestration(V1),
    name: "Orchestration",
    icon: "orchestrator-home",
    description: "Payment orchestration platform",
  },
  {
    product: Recon(V1),
    name: "Reconciliation",
    icon: "recon-home",
    description: "Automated reconciliation",
  },
  {
    product: Recovery,
    name: "Revenue Recovery",
    icon: "recovery-home",
    description: "Failed payment recovery",
  },
  {
    product: CostObservability,
    name: "Cost Observability",
    icon: "nd-piggy-bank",
    description: "Payment cost analytics",
  },
]

let getProductStringKey = product => {
  switch product {
  | Orchestration(_) => "orchestration"
  | Recon(_) => "recon"
  | Recovery => "recovery"
  | CostObservability => "cost_observability"
  | _ => ""
  }
}

module ProductCard = {
  @react.component
  let make = (
    ~item: productSelectionItem,
    ~isSelected: bool,
    ~isDisabled: bool,
    ~onToggle: unit => unit,
  ) => {
    let baseClasses = "flex flex-col gap-3 p-4 rounded-lg border-2 cursor-pointer transition-all duration-200"
    let stateClasses = if isDisabled {
      "border-nd_gray-200 bg-nd_gray-50 cursor-not-allowed opacity-60"
    } else if isSelected {
      "border-nd_blue-500 bg-nd_blue-50"
    } else {
      "border-nd_gray-200 hover:border-nd_gray-300 bg-white"
    }

    <div
      className={`${baseClasses} ${stateClasses}`}
      onClick={_ => {
        if !isDisabled {
          onToggle()
        }
      }}>
      <div className="flex items-center justify-between">
        <Icon name={item.icon} size=24 />
        <RenderIf condition={isSelected}>
          <div className="w-5 h-5 rounded-full bg-nd_blue-500 flex items-center justify-center">
            <Icon name="check" size=12 customIconColor="text-white" />
          </div>
        </RenderIf>
      </div>
      <div className="flex flex-col gap-1">
        <span className="text-sm font-semibold text-nd_gray-700"> {item.name->React.string} </span>
        <span className="text-xs text-nd_gray-500"> {item.description->React.string} </span>
      </div>
    </div>
  }
}

@react.component
let make = (~selectedProducts: array<string>, ~onProductToggle: (string, bool) => unit) => {
  <div className="grid grid-cols-2 gap-4">
    {availableProducts
    ->Array.map(item => {
      let productKey = item.product->getProductStringKey
      let isSelected = selectedProducts->Array.includes(productKey)
      let isDisabled = productKey === "orchestration"

      <ProductCard
        key={productKey}
        item
        isSelected
        isDisabled
        onToggle={() => onProductToggle(productKey, !isSelected)}
      />
    })
    ->React.array}
  </div>
}
