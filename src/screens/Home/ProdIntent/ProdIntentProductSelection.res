open ProductTypes

type productSelection = {
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

module ProductCard = {
  @react.component
  let make = (
    ~product: productSelection,
    ~isSelected: bool,
    ~isDisabled: bool,
    ~onToggle: unit => unit,
  ) => {
    let baseClasses = "flex flex-col gap-3 p-4 rounded-lg border-2 cursor-pointer transition-all duration-200"
    let selectedClasses = isSelected
      ? "border-hyperswitch_blue bg-blue-50"
      : "border-gray-200 hover:border-gray-300 bg-white"
    let disabledClasses = isDisabled ? "opacity-60 cursor-not-allowed" : ""

    <div
      className={`${baseClasses} ${selectedClasses} ${disabledClasses}`}
      onClick={_ => {
        if !isDisabled {
          onToggle()
        }
      }}>
      <div className="flex items-center gap-3">
        <Icon name={product.icon} size=24 />
        <div className="flex flex-col">
          <span className="font-semibold text-sm text-gray-900"> {product.name->React.string} </span>
          <span className="text-xs text-gray-500"> {product.description->React.string} </span>
        </div>
      </div>
      <div className="flex justify-end">
        <div
          className={`w-5 h-5 rounded border-2 flex items-center justify-center ${
            isSelected ? "bg-hyperswitch_blue border-hyperswitch_blue" : "border-gray-300"
          }`}>
          <RenderIf condition={isSelected}>
            <Icon name="check" size=12 customIconColor="text-white" />
          </RenderIf>
        </div>
      </div>
    </div>
  }
}

@react.component
let make = (~selectedProducts: array<productTypes>, ~onProductToggle: productTypes => unit) => {
  <div className="flex flex-col gap-3">
    <div className="text-sm font-medium text-gray-700">
      {"Select products for production access"->React.string}
    </div>
    <div className="grid grid-cols-2 gap-3">
      {availableProducts
      ->Array.map(productSelection => {
        let isSelected = selectedProducts->Array.some(p => p == productSelection.product)
        let isDisabled = productSelection.product == Orchestration(V1)

        <ProductCard
          key={productSelection.name}
          product={productSelection}
          isSelected
          isDisabled
          onToggle={() => onProductToggle(productSelection.product)}
        />
      })
      ->React.array}
    </div>
  </div>
}
